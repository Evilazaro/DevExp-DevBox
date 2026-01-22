#Requires -Version 5.1

<#
.SYNOPSIS
    Deletes Azure deployment credentials (service principal and app registration).

.DESCRIPTION
    This script removes an Azure AD service principal and its associated
    application registration by looking up the display name. This is typically
    used to clean up credentials created for CI/CD pipelines.

.PARAMETER AppDisplayName
    The display name of the application registration to delete.

.EXAMPLE
    .\deleteDeploymentCredentials.ps1 -AppDisplayName "ContosoDevEx GitHub Actions Enterprise App"
    Deletes the service principal and app registration with the specified name.

.NOTES
    Author: DevExp Team
    Requires: Azure CLI (az) authenticated with Azure AD admin permissions
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true, HelpMessage = "The display name of the application to delete.")]
    [ValidateNotNullOrEmpty()]
    [string]$AppDisplayName
)

# Script Configuration
$ErrorActionPreference = 'Stop'
$WarningPreference = 'Stop'

function Remove-AzureDeploymentCredentials {
    <#
    .SYNOPSIS
        Removes an Azure AD service principal and application registration.

    .DESCRIPTION
        Looks up an application by display name, retrieves its App ID,
        then deletes both the service principal and the application registration.

    .PARAMETER DisplayName
        The display name of the application to delete.

    .OUTPUTS
        System.Boolean - True if deletion succeeded, False otherwise.

    .EXAMPLE
        Remove-AzureDeploymentCredentials -DisplayName "My CI/CD App"
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName
    )

    try {
        # Get the application ID using the display name
        Write-Verbose "Looking up application with display name: $DisplayName"
        $appId = az ad app list --display-name $DisplayName --query "[0].appId" --output tsv

        if ($LASTEXITCODE -ne 0) {
            throw "Failed to query Azure AD applications."
        }

        if ([string]::IsNullOrWhiteSpace($appId)) {
            Write-Warning "Application with display name '$DisplayName' not found. Nothing to delete."
            return $true
        }

        Write-Output "Found application with App ID: $appId"

        # Delete the service principal
        if ($PSCmdlet.ShouldProcess("Service Principal with App ID: $appId", "Delete")) {
            Write-Output "Deleting service principal..."
            $null = az ad sp delete --id $appId 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Service principal deletion returned non-zero exit code. It may not exist."
            }
            else {
                Write-Output "Service principal deleted successfully."
            }
        }

        # Delete the application registration
        if ($PSCmdlet.ShouldProcess("Application Registration with App ID: $appId", "Delete")) {
            Write-Output "Deleting application registration..."
            $null = az ad app delete --id $appId 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to delete application registration."
            }
            Write-Output "Application registration deleted successfully."
        }

        Write-Output "Deployment credentials cleanup completed for: $DisplayName"
        return $true
    }
    catch {
        Write-Error "Error removing deployment credentials: $_"
        return $false
    }
}

# Main script execution
try {
    Write-Output "Starting deployment credentials cleanup for: $AppDisplayName"

    $success = Remove-AzureDeploymentCredentials -DisplayName $AppDisplayName
    if (-not $success) {
        exit 1
    }

    Write-Output "Cleanup completed successfully."
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}