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
    Requirements:
    - PowerShell 7+, Microsoft.Graph.Authentication (installed automatically)
    - A signed-in user with the Windows 365 + Intune admin roles
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
# 2. Connect to Microsoft Graph (delegated)
# ---------------------------------------------------------------------------
$graphScopes = @('CloudPC.ReadWrite.All', 'Group.Read.All')
if ($enabled | Where-Object { $_.dscConfigurations -and $_.dscConfigurations.Count -gt 0 }) {
    # Extra scope requested only when customizations are configured (least privilege).
    $graphScopes += 'DeviceManagementScripts.ReadWrite.All'
}

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
    Write-Info 'Installing Microsoft.Graph.Authentication (CurrentUser scope)...'
    Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force -AllowClobber
}
Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

Write-Info "Connecting to Microsoft Graph (scopes: $($graphScopes -join ', '))..."
$connectParams = @{ Scopes = $graphScopes; NoWelcome = $true }
# On Linux/WSL there is typically no browser, so use device-code auth. Do NOT
# swallow output - the user must see the code + URL. Allow an override via
# W365_USE_DEVICE_CODE=true for other headless hosts.
if ($IsLinux -or $env:W365_USE_DEVICE_CODE -eq 'true') {
    $connectParams.UseDeviceCode = $true
    Write-Info 'Headless host detected - using device-code sign-in. Follow the URL/code below.'
}
Connect-MgGraph @connectParams

# Fail fast with a clear message if no session was established.
if (-not (Get-MgContext)) {
    Write-Note 'Microsoft Graph sign-in did not complete. Re-run: pwsh -File ./scripts/Configure-Windows365.ps1'
    return
}

function Invoke-Graph {
    param(
        [Parameter(Mandatory)][ValidateSet('GET', 'POST', 'PATCH', 'DELETE')][string]$Method,
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory = $false)][object]$Body
    )
    $uri = if ($Path -match '^https?://') { $Path } else { "$GraphBaseUri$Path" }
    $params = @{ Method = $Method; Uri = $uri }
    if ($Body) { $params.Body = ($Body | ConvertTo-Json -Depth 12); $params.ContentType = 'application/json' }
    return Invoke-MgGraphRequest @params
}

function Resolve-GalleryImage {
    param([string]$ImageId, [string]$ImageDisplayName)
    try {
        $images = (Invoke-Graph -Method GET -Path '/deviceManagement/virtualEndpoint/galleryImages').value
        if ($images | Where-Object { $_.id -eq $ImageId }) { return $ImageId }
        $byName = $images | Where-Object { $_.displayName -eq $ImageDisplayName -and $_.status -eq 'supported' } | Select-Object -First 1
        if ($byName) { Write-Note "imageId '$ImageId' not in gallery; using '$($byName.id)' (matched display name)."; return $byName.id }
        Write-Note "Gallery image '$ImageId' not found; proceeding with the configured value."
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
    Write-Info "Configuring Windows 365 for project '$($c.projectName)'..."

    # 3a. Resolve the image (custom images are used as-is).
    $imageId = if ($c.imageType -eq 'gallery') { Resolve-GalleryImage -ImageId $c.imageId -ImageDisplayName $c.imageDisplayName } else { $c.imageId }

    # 3b. Azure Network Connection - only when a customer subnet is supplied.
    $ancId = $null
    if ($c.networkType -eq 'azureNetworkConnection' -and -not [string]::IsNullOrWhiteSpace($c.subnetId)) {
        $ancName = $c.azureNetworkConnectionName
        $existingAnc = (Invoke-Graph -Method GET -Path '/deviceManagement/virtualEndpoint/onPremisesConnections').value |
        Where-Object { $_.displayName -eq $ancName } | Select-Object -First 1
        if ($existingAnc) { $ancId = $existingAnc.id; Write-Info "Reusing Azure Network Connection '$ancName' ($ancId)." }
        else {
            $anc = Invoke-Graph -Method POST -Path '/deviceManagement/virtualEndpoint/onPremisesConnections' -Body @{
                displayName      = $ancName
                connectionType   = $c.joinType
                subscriptionId   = $c.subscriptionId
                resourceGroupId  = $c.resourceGroupId
                virtualNetworkId = $c.virtualNetworkId
                subnetId         = $c.subnetId
            }
            $ancId = $anc.id
            Write-Info "Created Azure Network Connection '$ancName' ($ancId)."
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

Write-Info 'Windows 365 Cloud PC configuration complete.'
Write-Info 'Cloud PCs provision asynchronously once licenses are assigned to the group members.'
