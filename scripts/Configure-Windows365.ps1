#Requires -Version 7.0
<#
.SYNOPSIS
    Configure-Windows365.ps1 - Provisions Windows 365 Cloud PCs via Microsoft Graph.

.DESCRIPTION
    Reads the Windows 365 provisioning contract produced by the Bicep deployment
    (output AZURE_CLOUD_PC_PROVISIONING) and, for each project that has Cloud PCs
    enabled, idempotently creates/updates the supporting Microsoft Graph resources
    under deviceManagement/virtualEndpoint:

      1. (Optional) Azure Network Connection - only when a customer subnet is supplied
         (Unmanaged network). Microsoft-hosted networks use a region instead.
      2. Cloud PC provisioning policy (image, size, Microsoft Entra join, SSO).
      3. Assignment of the provisioning policy to the project's Microsoft Entra group.

    Windows 365 Enterprise is managed through Microsoft Graph (Intune), which has
    no ARM/Bicep resource types - hence this script rather than a Bicep resource.

.PARAMETER ProvisioningJson
    JSON array of provisioning contracts. Defaults to the AZURE_CLOUD_PC_PROVISIONING
    environment variable exported by azd, falling back to `azd env get-value`.

.PARAMETER GraphScopes
    Delegated Microsoft Graph scopes to request. CloudPC.ReadWrite.All is required.

.PARAMETER GraphBaseUri
    Microsoft Graph base URI. Windows 365 provisioning APIs live under /beta.

.NOTES
    Requirements:
    - PowerShell 7+
    - Microsoft.Graph.Authentication module (installed automatically if missing)
    - A signed-in user with the Windows 365 admin role and CloudPC.ReadWrite.All consent
    - Windows 365 Enterprise licenses assigned to the target group's members

    References:
    - https://learn.microsoft.com/graph/api/virtualendpoint-post-onpremisesconnections
    - https://learn.microsoft.com/graph/api/virtualendpoint-post-provisioningpolicies
    - https://learn.microsoft.com/graph/api/cloudpcprovisioningpolicy-assign
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProvisioningJson = $env:AZURE_CLOUD_PC_PROVISIONING,

    [Parameter(Mandatory = $false)]
    [string[]]$GraphScopes = @('CloudPC.ReadWrite.All', 'Group.Read.All'),

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

try {
    $contracts = $ProvisioningJson | ConvertFrom-Json
}
catch {
    Write-Note "Unable to parse AZURE_CLOUD_PC_PROVISIONING JSON: $($_.Exception.Message)"
    return
}

if ($contracts -isnot [System.Array]) { $contracts = @($contracts) }
$enabled = @($contracts | Where-Object { $_ -and $_.enabled })

if ($enabled.Count -eq 0) {
    Write-Info 'No projects have Windows 365 Cloud PC enabled. Nothing to do.'
    return
}

# ---------------------------------------------------------------------------
# 2. Connect to Microsoft Graph (delegated)
# ---------------------------------------------------------------------------
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
    Write-Info 'Installing Microsoft.Graph.Authentication (CurrentUser scope)...'
    Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force -AllowClobber
}
Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

Write-Info "Connecting to Microsoft Graph (scopes: $($GraphScopes -join ', '))..."
Connect-MgGraph -Scopes $GraphScopes -NoWelcome | Out-Null

function Invoke-Graph {
    param(
        [Parameter(Mandatory)][ValidateSet('GET', 'POST', 'PATCH', 'DELETE')][string]$Method,
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory = $false)][object]$Body
    )
    $uri = if ($Path -match '^https?://') { $Path } else { "$GraphBaseUri$Path" }
    $params = @{ Method = $Method; Uri = $uri }
    if ($Body) {
        $params.Body = ($Body | ConvertTo-Json -Depth 10)
        $params.ContentType = 'application/json'
    }
    return Invoke-MgGraphRequest @params
}

function Resolve-GalleryImage {
    param([string]$ImageId, [string]$ImageDisplayName)
    try {
        $images = (Invoke-Graph -Method GET -Path '/deviceManagement/virtualEndpoint/galleryImages').value
        if ($images | Where-Object { $_.id -eq $ImageId }) { return $ImageId }

        $byName = $images |
        Where-Object { $_.displayName -eq $ImageDisplayName -and $_.status -eq 'supported' } |
        Select-Object -First 1
        if ($byName) {
            Write-Note "Configured imageId '$ImageId' not found in the gallery; using '$($byName.id)' (matched on display name)."
            return $byName.id
        }
        Write-Note "Gallery image '$ImageId' not found and no display-name match; proceeding with the configured value."
        return $ImageId
    }
    catch {
        Write-Note "Could not query gallery images: $($_.Exception.Message). Proceeding with the configured imageId."
        return $ImageId
    }
}

# ---------------------------------------------------------------------------
# 3. Per-project configuration (idempotent upserts)
# ---------------------------------------------------------------------------
foreach ($c in $enabled) {
    Write-Info "Configuring Windows 365 for project '$($c.projectName)'..."

    # 3a. Resolve the gallery image (custom images are used as-is).
    $imageId = if ($c.imageType -eq 'gallery') {
        Resolve-GalleryImage -ImageId $c.imageId -ImageDisplayName $c.imageDisplayName
    }
    else { $c.imageId }

    # 3b. Azure Network Connection - only when a customer subnet is supplied.
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
            $ancBody = @{
                displayName      = $ancName
                connectionType   = $c.joinType
                subscriptionId   = $c.subscriptionId
                resourceGroupId  = $c.resourceGroupId
                virtualNetworkId = $c.virtualNetworkId
                subnetId         = $c.subnetId
            }
            $anc = Invoke-Graph -Method POST -Path '/deviceManagement/virtualEndpoint/onPremisesConnections' -Body $ancBody
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
        $policyBody = @{
            displayName              = $displayName
            description              = "Windows 365 $($c.licenseEdition) $($c.size) for project $($c.projectName)"
            imageId                  = $imageId
            imageType                = $c.imageType
            imageDisplayName         = $c.imageDisplayName
            enableSingleSignOn       = [bool]$c.enableSingleSignOn
            provisioningType         = $c.provisioningType
            domainJoinConfigurations = @($domainJoin)
        }
        $policy = Invoke-Graph -Method POST -Path '/deviceManagement/virtualEndpoint/provisioningPolicies' -Body $policyBody
        Write-Info "Created provisioning policy '$displayName' ($($policy.id))."
    }
    else {
        Write-Info "Provisioning policy '$displayName' already exists ($($policy.id))."
    }

    # 3e. Assign the policy to the project's Microsoft Entra group.
    if (-not [string]::IsNullOrWhiteSpace($c.userGroupId)) {
        $assignBody = @{
            assignments = @(
                @{
                    target = @{
                        '@odata.type' = '#microsoft.graph.cloudPcManagementGroupAssignmentTarget'
                        groupId       = $c.userGroupId
                    }
                }
            )
        }
        Invoke-Graph -Method POST -Path "/deviceManagement/virtualEndpoint/provisioningPolicies/$($policy.id)/assign" -Body $assignBody | Out-Null
        Write-Info "Assigned policy '$displayName' to Microsoft Entra group $($c.userGroupId)."
    }
    else {
        Write-Note "No userGroupId for project '$($c.projectName)'; skipping assignment. Assign the policy to a group in the Windows 365 admin center."
    }
}

Write-Info 'Windows 365 Cloud PC configuration complete.'
Write-Info 'Cloud PCs provision asynchronously once licenses are assigned to the group members.'
