#Requires -Version 7.0
<#
.SYNOPSIS
    Configure-Windows365.ps1 - Provisions Windows 365 Cloud PCs and applies the
    Dev Box customization DSC to them, via Microsoft Graph.

.DESCRIPTION
    Reads the Windows 365 provisioning contract produced by the Bicep deployment
    (output AZURE_CLOUD_PC_PROVISIONING) and, for each project that has Cloud PCs
    enabled, idempotently creates/updates:

      1. (Optional) an Azure Network Connection - only when a customer subnet is
         supplied (Unmanaged network). Microsoft-hosted networks use a region.
      2. A Cloud PC provisioning policy (image, Microsoft Entra join, SSO).
      3. The assignment of that policy to the project's Microsoft Entra group.
      4. Customization parity with Dev Box: for each configured WinGet
         Configuration DSC file, an Intune platform script that runs
         `winget configure` against that DSC, assigned to the same group - so a
         Cloud PC receives the SAME tooling a Dev Box does, applied at
         provisioning (mirroring the Dev Box customization model).

    Windows 365 and Intune are managed through Microsoft Graph, which has no
    ARM/Bicep resource types - hence this script rather than Bicep resources.

    All Graph request shapes used here were verified against Microsoft Learn:
    - virtualendpoint-post-onpremisesconnections
    - virtualendpoint-post-provisioningpolicies
    - cloudpcprovisioningpolicy-assign
    - intune-shared-devicemanagementscript-create / -assign

.PARAMETER ProvisioningJson
    JSON array of provisioning contracts. Defaults to the AZURE_CLOUD_PC_PROVISIONING
    environment variable exported by azd, falling back to `azd env get-value`.

.PARAMETER GraphBaseUri
    Microsoft Graph base URI. Windows 365 and Intune beta APIs live under /beta.

.NOTES
    Authentication is app-only (client credentials) - no interactive sign-in, so
    it runs identically in WSL, Windows, or CI. The app registration is created
    automatically (via Setup-Windows365App.ps1) when missing, and an EPHEMERAL
    client secret is minted per run and used immediately - nothing is stored, so
    no Key Vault permission is required.

    Requirements:
    - PowerShell 7+ and Azure CLI (signed in to the target tenant)
    - An identity that can create an app registration and grant admin consent
    - Windows 365 Enterprise licenses + an active Intune license on the tenant

    Caveat: WinGet Configuration applied by an Intune platform script runs in
    system context. Validate WinGet availability for your image; some resources
    (WSL, Docker Desktop) may need a reboot/user context to complete.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProvisioningJson = $env:AZURE_CLOUD_PC_PROVISIONING,

    [Parameter(Mandatory = $false)]
    [string]$TenantId = $env:AZURE_TENANT_ID,

    [Parameter(Mandatory = $false)]
    [string]$ClientId = $env:AZURE_W365_CLIENT_ID,

    [Parameter(Mandatory = $false)]
    [string]$ClientSecret = $env:AZURE_W365_CLIENT_SECRET,

    [Parameter(Mandatory = $false)]
    [string]$GraphBaseUri = 'https://graph.microsoft.com/beta'
)

$ErrorActionPreference = 'Stop'

function Write-Info { param([string]$Message) Write-Host "[Windows365] $Message" -ForegroundColor Cyan }
function Write-Note { param([string]$Message) Write-Warning "[Windows365] $Message" }

# ---------------------------------------------------------------------------
# 1. Resolve the provisioning contract (param -> azd env)
# ---------------------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($ProvisioningJson)) {
    if (Get-Command azd -ErrorAction SilentlyContinue) {
        try { $ProvisioningJson = (azd env get-value AZURE_CLOUD_PC_PROVISIONING 2>$null) } catch { }
    }
}
if ([string]::IsNullOrWhiteSpace($ProvisioningJson)) {
    Write-Info 'No Windows 365 provisioning contract found (AZURE_CLOUD_PC_PROVISIONING). Nothing to do.'
    return
}

try { $contracts = $ProvisioningJson | ConvertFrom-Json }
catch { Write-Note "Unable to parse AZURE_CLOUD_PC_PROVISIONING JSON: $($_.Exception.Message)"; return }

if ($contracts -isnot [System.Array]) { $contracts = @($contracts) }
$enabled = @($contracts | Where-Object { $_ -and $_.enabled })
if ($enabled.Count -eq 0) { Write-Info 'No projects have Windows 365 Cloud PC enabled. Nothing to do.'; return }

# ---------------------------------------------------------------------------
# 2. Acquire a Microsoft Graph token (app-only / client credentials)
#    No interactive sign-in - identical behavior in WSL, Windows, and CI.
#    The app registration is auto-created if missing, and an EPHEMERAL secret is
#    minted per run and used immediately (nothing is stored - no Key Vault
#    permission required).
# ---------------------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($TenantId)) {
    try { $TenantId = (az account show --query tenantId -o tsv 2>$null) } catch { }
}

# Use explicitly-provided credentials if present; otherwise use the auto-managed
# app registration with an ephemeral secret.
if ([string]::IsNullOrWhiteSpace($ClientId) -or [string]::IsNullOrWhiteSpace($ClientSecret)) {
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) { Write-Note 'Azure CLI (az) is required; skipping.'; return }

    # Ensure the app registration exists with the current Graph permissions and
    # admin consent. Idempotent - reconciles permissions on every run, so an
    # existing app picks up newly-required scopes automatically.
    $setup = Join-Path $PSScriptRoot 'Setup-Windows365App.ps1'
    Write-Info 'Ensuring Windows 365 app registration and Graph permissions...'
    try { & $setup } catch { Write-Note "App setup failed: $($_.Exception.Message)"; return }
    $ClientId = (az ad app list --display-name 'DevExp-Windows365' --query "[0].appId" -o tsv 2>$null)
    if ([string]::IsNullOrWhiteSpace($ClientId)) {
        Write-Note 'Could not create or resolve the app registration.'
        Write-Note 'The deploying identity needs rights to create an app registration and grant admin consent. Skipping.'
        return
    }

    # Mint an ephemeral client secret used only for this run (nothing is stored).
    Write-Info 'Minting an ephemeral client secret...'
    $ClientSecret = (az ad app credential reset --id $ClientId --display-name 'w365-ephemeral' --query password -o tsv 2>$null)
    if ([string]::IsNullOrWhiteSpace($ClientSecret)) { Write-Note 'Could not create a client secret. Skipping.'; return }
    Write-Info 'Waiting for the credential/consent to propagate...'
    Start-Sleep -Seconds 20
}

if ([string]::IsNullOrWhiteSpace($TenantId)) { Write-Note 'Could not resolve the tenant ID. Skipping.'; return }

Write-Info 'Acquiring Microsoft Graph token (app-only, client credentials)...'
$graphToken = $null
for ($attempt = 1; $attempt -le 6; $attempt++) {
    try {
        $tokenResponse = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Body @{
            client_id     = $ClientId
            client_secret = $ClientSecret
            scope         = 'https://graph.microsoft.com/.default'
            grant_type    = 'client_credentials'
        }
        if ($tokenResponse.access_token) { $graphToken = $tokenResponse.access_token; break }
    }
    catch { }
    if ($attempt -lt 6) { Write-Info "Token not ready (consent propagating); retrying in 15s ($attempt/6)..."; Start-Sleep -Seconds 15 }
}
if ([string]::IsNullOrWhiteSpace($graphToken)) {
    Write-Note 'Could not acquire a Graph token (admin consent may still be propagating). Re-run to retry. Skipping.'
    return
}
$graphHeaders = @{ Authorization = "Bearer $graphToken" }

function Invoke-Graph {
    param(
        [Parameter(Mandatory)][ValidateSet('GET', 'POST', 'PATCH', 'DELETE')][string]$Method,
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory = $false)][object]$Body
    )
    $uri = if ($Path -match '^https?://') { $Path } else { "$GraphBaseUri$Path" }
    $params = @{ Method = $Method; Uri = $uri; Headers = $graphHeaders }
    if ($Body) { $params.Body = ($Body | ConvertTo-Json -Depth 12); $params.ContentType = 'application/json' }
    try { return Invoke-RestMethod @params }
    catch {
        $detail = $null
        try { $detail = $_.ErrorDetails.Message } catch { }
        if ($detail) { throw "Graph $Method $Path -> $detail" } else { throw }
    }
}

function Resolve-GalleryImage {
    param([string]$ImageId, [string]$ImageDisplayName)
    try {
        $images = (Invoke-Graph -Method GET -Path '/deviceManagement/virtualEndpoint/galleryImages').value
        # Return the gallery's canonical id (handles casing/format differences).
        $byId = $images | Where-Object { $_.id -eq $ImageId } | Select-Object -First 1
        if ($byId) { return $byId.id }
        $byName = $images | Where-Object { $_.displayName -eq $ImageDisplayName -and $_.status -eq 'supported' } | Select-Object -First 1
        if ($byName) { Write-Note "Using gallery image '$($byName.id)' (matched display name '$ImageDisplayName')."; return $byName.id }
        # Fuzzy: newest supported Windows 11 + Microsoft 365 image.
        $fuzzy = $images | Where-Object { $_.status -eq 'supported' -and $_.id -match 'win11' -and $_.id -match 'm365' } | Sort-Object id -Descending | Select-Object -First 1
        if ($fuzzy) { Write-Note "Using gallery image '$($fuzzy.id)' (closest Windows 11 + M365 supported match)."; return $fuzzy.id }
        $anySupported = $images | Where-Object { $_.status -eq 'supported' } | Select-Object -First 1
        if ($anySupported) { Write-Note "Configured image not found; using first supported gallery image '$($anySupported.id)'."; return $anySupported.id }
        Write-Note "No supported gallery images returned; using configured '$ImageId'."
        return $ImageId
    }
    catch { Write-Note "Could not query gallery images: $($_.Exception.Message). Using configured imageId."; return $ImageId }
}

function Set-CustomizationScript {
    param([string]$ProjectName, [string]$DscUrl, [string]$GroupId)
    $fileName = [System.IO.Path]::GetFileName($DscUrl)
    $displayName = "w365-$ProjectName-$fileName"

    $inner = @"
`$ErrorActionPreference = 'Stop'
`$work = Join-Path `$env:ProgramData 'DevExp-Win365'
New-Item -ItemType Directory -Force -Path `$work | Out-Null
`$dsc = Join-Path `$work '$fileName'
Invoke-WebRequest -Uri '$DscUrl' -OutFile `$dsc -UseBasicParsing
winget configure --file `$dsc --accept-configuration-agreements --disable-interactivity
"@
    $scriptContent = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($inner))

    $existing = (Invoke-Graph -Method GET -Path '/deviceManagement/deviceManagementScripts').value |
    Where-Object { $_.displayName -eq $displayName } | Select-Object -First 1

    if ($existing) {
        Write-Info "Customization script '$displayName' already exists ($($existing.id))."
        $scriptId = $existing.id
    }
    else {
        $body = @{
            '@odata.type'         = '#microsoft.graph.deviceManagementScript'
            displayName           = $displayName
            description           = "Applies $fileName to Windows 365 Cloud PCs for project $ProjectName"
            runAsAccount          = 'system'
            enforceSignatureCheck = $false
            fileName              = 'apply-winget-configure.ps1'
            scriptContent         = $scriptContent
        }
        $created = Invoke-Graph -Method POST -Path '/deviceManagement/deviceManagementScripts' -Body $body
        $scriptId = $created.id
        Write-Info "Created customization script '$displayName' ($scriptId)."
    }

    $assignBody = @{
        deviceManagementScriptGroupAssignments = @(
            @{
                '@odata.type' = '#microsoft.graph.deviceManagementScriptGroupAssignment'
                targetGroupId = $GroupId
            }
        )
    }
    Invoke-Graph -Method POST -Path "/deviceManagement/deviceManagementScripts/$scriptId/assign" -Body $assignBody | Out-Null
    Write-Info "Assigned customization script '$displayName' to group $GroupId."
}

# ---------------------------------------------------------------------------
# 3. Per-project configuration (idempotent upserts)
# ---------------------------------------------------------------------------
foreach ($c in $enabled) {
    try {
        Write-Info "Configuring Windows 365 for project '$($c.projectName)'..."

    # 3a. Resolve the image (custom images are used as-is).
    $imageId = if ($c.imageType -eq 'gallery') { Resolve-GalleryImage -ImageId $c.imageId -ImageDisplayName $c.imageDisplayName } else { $c.imageId }

    # 3b. Azure Network Connection - only when a customer subnet is supplied.
    #     ANC creation requires DELEGATED Graph auth (app-only is not supported),
    #     so it cannot run under this non-interactive path. Managed / Microsoft-
    #     hosted projects (the default) need no ANC.
    $ancId = $null
    if ($c.networkType -eq 'azureNetworkConnection' -and -not [string]::IsNullOrWhiteSpace($c.subnetId)) {
        $ancName = $c.azureNetworkConnectionName
        $existingAnc = (Invoke-Graph -Method GET -Path '/deviceManagement/virtualEndpoint/onPremisesConnections').value |
        Where-Object { $_.displayName -eq $ancName } | Select-Object -First 1
        if ($existingAnc) {
            $ancId = $existingAnc.id
            Write-Info "Reusing Azure Network Connection '$ancName' ($ancId)."
        }
        else {
            Write-Note "Project '$($c.projectName)' uses an Unmanaged network, which needs an Azure Network Connection."
            Write-Note 'Creating an ANC requires delegated auth and is not supported app-only. Create the ANC once in the'
            Write-Note 'Windows 365 admin center (or via a delegated run), then re-run. Skipping this project.'
            continue
        }
    }

    # 3c. Domain join configuration - Entra join via ANC (subnet) or region (Microsoft-hosted).
    $domainJoin = @{ domainJoinType = $c.joinType }
    if ($ancId) { $domainJoin.onPremisesConnectionId = $ancId } else { $domainJoin.regionName = $c.region }

    # 3d. Provisioning policy - upsert by display name.
    $displayName = $c.displayName
    $policy = (Invoke-Graph -Method GET -Path '/deviceManagement/virtualEndpoint/provisioningPolicies').value |
    Where-Object { $_.displayName -eq $displayName } | Select-Object -First 1
    if (-not $policy) {
        $policy = Invoke-Graph -Method POST -Path '/deviceManagement/virtualEndpoint/provisioningPolicies' -Body @{
            displayName              = $displayName
            description              = "Windows 365 $($c.licenseEdition) $($c.size) for project $($c.projectName)"
            imageId                  = $imageId
            imageType                = $c.imageType
            imageDisplayName         = $c.imageDisplayName
            enableSingleSignOn       = [bool]$c.enableSingleSignOn
            provisioningType         = $c.provisioningType
            domainJoinConfigurations = @($domainJoin)
        }
        Write-Info "Created provisioning policy '$displayName' ($($policy.id))."
    }
    else { Write-Info "Provisioning policy '$displayName' already exists ($($policy.id))." }

    # 3e. Assign the policy to the project's Microsoft Entra group.
    if (-not [string]::IsNullOrWhiteSpace($c.userGroupId)) {
        Invoke-Graph -Method POST -Path "/deviceManagement/virtualEndpoint/provisioningPolicies/$($policy.id)/assign" -Body @{
            assignments = @(@{ target = @{ '@odata.type' = '#microsoft.graph.cloudPcManagementGroupAssignmentTarget'; groupId = $c.userGroupId } })
        } | Out-Null
        Write-Info "Assigned policy '$displayName' to Microsoft Entra group $($c.userGroupId)."
    }
    else { Write-Note "No userGroupId for project '$($c.projectName)'; skipping policy assignment." }

    # 3f. Customization parity - apply the same Dev Box DSC via Intune winget configure.
    if ($c.dscConfigurations -and $c.dscConfigurations.Count -gt 0) {
        if ([string]::IsNullOrWhiteSpace($c.userGroupId)) {
            Write-Note "No userGroupId; skipping customization scripts for '$($c.projectName)'."
        }
        else {
            $baseUri = ($c.dscBaseUri).TrimEnd('/')
            foreach ($dsc in $c.dscConfigurations) {
                $dscUrl = "$baseUri/$($dsc.TrimStart('/'))"
                Set-CustomizationScript -ProjectName $c.projectName -DscUrl $dscUrl -GroupId $c.userGroupId
            }
        }
    }
    }
    catch {
        Write-Note "Failed to configure project '$($c.projectName)': $($_.Exception.Message)"
        continue
    }
}

Write-Info 'Windows 365 Cloud PC configuration complete.'
Write-Info 'Cloud PCs provision asynchronously once licenses are assigned to the group members.'
