#Requires -Version 7.0
<#
.SYNOPSIS
    Setup-Windows365App.ps1 - One-time setup for non-interactive Windows 365 config.

.DESCRIPTION
    Creates (or reuses) a Microsoft Entra app registration used by
    Configure-Windows365.ps1 to call Microsoft Graph app-only (client
    credentials), so Cloud PC configuration runs non-interactively in WSL,
    Windows, or CI. It:

      1. Resolves the required Microsoft Graph *application* role IDs at runtime
         (no hardcoded GUIDs).
      2. Creates the app registration + service principal.
      3. Adds the Graph application permissions and grants admin consent.

    No secret is created or stored here - Configure-Windows365.ps1 mints an
    ephemeral client secret per run and uses it immediately (nothing persisted,
    so no Key Vault permission is required). This script is invoked automatically
    by Configure-Windows365.ps1 when the app registration is missing.

    Windows 365 Azure Network Connections (Unmanaged networks) require *delegated*
    auth and are therefore out of scope for this app-only path; Managed /
    Microsoft-hosted projects (the default) need no ANC.

.NOTES
    Requires an identity that can create app registrations and grant admin
    consent (Application Administrator + Privileged Role Administrator, or Global
    Administrator), with Azure CLI signed in to the target tenant.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$DisplayName = 'DevExp-Windows365'
)

$ErrorActionPreference = 'Stop'
function Write-Info { param([string]$Message) Write-Host "[Windows365-Setup] $Message" -ForegroundColor Cyan }

# Microsoft Graph well-known first-party application ID (stable, not tenant-specific).
$graphAppId = '00000003-0000-0000-c000-000000000000'
$requiredRoles = @('CloudPC.ReadWrite.All', 'DeviceManagementScripts.ReadWrite.All')

if (-not (Get-Command az -ErrorAction SilentlyContinue)) { throw 'Azure CLI (az) is required.' }

Write-Info 'Resolving Microsoft Graph application role IDs...'
$graphSp = az ad sp show --id $graphAppId | ConvertFrom-Json
$roleIds = @{}
foreach ($r in $requiredRoles) {
    $role = $graphSp.appRoles | Where-Object { $_.value -eq $r -and $_.allowedMemberTypes -contains 'Application' }
    if (-not $role) { throw "Application role '$r' not found on Microsoft Graph." }
    $roleIds[$r] = $role.id
}

# 1. Create or reuse the app registration.
$app = az ad app list --display-name $DisplayName --query "[0]" | ConvertFrom-Json
if (-not $app) {
    Write-Info "Creating app registration '$DisplayName'..."
    $app = az ad app create --display-name $DisplayName | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0 -or -not $app) { throw 'Failed to create the app registration (need app-registration rights).' }
}
else { Write-Info "Reusing app registration '$DisplayName' ($($app.appId))." }
$appId = $app.appId

# 2. Ensure a service principal exists for the app.
if (-not (az ad sp show --id $appId 2>$null)) {
    az ad sp create --id $appId | Out-Null
    Write-Info 'Created service principal.'
}

# 3. Add the required Graph application permissions.
foreach ($r in $requiredRoles) {
    az ad app permission add --id $appId --api $graphAppId --api-permissions "$($roleIds[$r])=Role" | Out-Null
    Write-Info "Added Graph application permission: $r"
}

# 4. Grant admin consent (requires an administrator: Privileged Role /
#    Application Administrator, or Global Administrator).
Write-Info 'Granting admin consent...'
az ad app permission admin-consent --id $appId
if ($LASTEXITCODE -ne 0) { throw 'Admin consent failed - the deploying identity cannot grant admin consent.' }

Write-Info "App registration ready ($appId). An ephemeral client secret is minted per run by Configure-Windows365.ps1."
