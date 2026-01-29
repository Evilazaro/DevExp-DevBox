#Requires -Version 5.1

<#
.SYNOPSIS
    Cleans up the DevExp-DevBox setup including users, credentials, and GitHub secrets.

.DESCRIPTION
    This script orchestrates the complete cleanup of DevExp-DevBox infrastructure by
    performing the following operations in sequence:
    
    1. Deletes all Azure subscription-level deployments
    2. Removes user role assignments and associated Azure AD users
    3. Deletes deployment credentials including service principals and app registrations
    4. Removes GitHub repository secrets for Azure credentials
    5. Cleans up Azure resource groups associated with the environment

    The script uses helper scripts located in the .configuration directory to perform
    individual cleanup tasks. Each operation is executed with proper error handling,
    and the script continues with remaining tasks even if individual operations fail.

    The script supports -WhatIf and -Confirm parameters for safe execution previews.

.PARAMETER EnvName
    The environment name used in resource naming conventions.
    This value is used to identify and clean up environment-specific resource groups.
    Defaults to 'gitHub'.

.PARAMETER Location
    The Azure region where resources are deployed.
    Used to identify region-specific resources during cleanup.
    Defaults to 'eastus2'.
    Valid values: eastus, eastus2, westus, westus2, westus3, northeurope, westeurope

.PARAMETER AppDisplayName
    The display name of the Azure AD application (service principal) to delete.
    This is used to identify and remove the app registration and associated credentials.
    Defaults to 'ContosoDevEx GitHub Actions Enterprise App'.

.PARAMETER GhSecretName
    The name of the GitHub repository secret to delete.
    This secret typically contains Azure credentials used for GitHub Actions workflows.
    Defaults to 'AZURE_CREDENTIALS'.

.EXAMPLE
    .\cleanSetUp.ps1
    Runs cleanup with all default parameters. Deletes the default 'gitHub' environment
    resources in 'eastus2' region.

.EXAMPLE
    .\cleanSetUp.ps1 -EnvName "prod" -Location "westus2"
    Runs cleanup for the 'prod' environment deployed in the 'westus2' region.

.EXAMPLE
    .\cleanSetUp.ps1 -WhatIf
    Shows what cleanup operations would be performed without making any changes.

.EXAMPLE
    .\cleanSetUp.ps1 -AppDisplayName "MyCustomApp" -GhSecretName "MY_AZURE_CREDS"
    Runs cleanup targeting a custom Azure AD application and GitHub secret name.

.INPUTS
    None. This script does not accept pipeline input.

.OUTPUTS
    None. This script outputs status messages to the console.

.NOTES
    File Name  : cleanSetUp.ps1
    Author     : DevExp Team
    Repository : Evilazaro/DevExp-DevBox
    
    Prerequisites:
    - Azure CLI (az) must be installed and authenticated
    - GitHub CLI (gh) must be installed and authenticated
    - Appropriate Azure permissions (Owner or Contributor on subscription)
    - Appropriate GitHub permissions (admin access to repository secrets)

.LINK
    https://github.com/Evilazaro/DevExp-DevBox
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$EnvName = "gitHub",

    [Parameter(Mandatory = $false)]
    [ValidateSet("eastus", "eastus2", "westus", "westus2", "westus3", "northeurope", "westeurope")]
    [string]$Location = "eastus2",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$AppDisplayName = "ContosoDevEx GitHub Actions Enterprise App",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$GhSecretName = "AZURE_CREDENTIALS"
)

# Script Configuration
$ErrorActionPreference = 'Stop'
$WarningPreference = 'Stop'

# Script directory for relative path resolution
$Script:ScriptDirectory = $PSScriptRoot

function Remove-SubscriptionDeployments {
    <#
    .SYNOPSIS
        Deletes all subscription-level deployments.

    .DESCRIPTION
        Lists and deletes all Azure Resource Manager deployments at the
        subscription level.

    .OUTPUTS
        System.Boolean - True if successful, False otherwise.

    .EXAMPLE
        Remove-SubscriptionDeployments
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param()

    try {
        Write-Output "Retrieving subscription deployments..."
        $deployments = az deployment sub list --query "[].name" --output tsv

        if ($LASTEXITCODE -ne 0) {
            throw "Failed to list subscription deployments."
        }

        if ([string]::IsNullOrWhiteSpace($deployments)) {
            Write-Output "No subscription deployments found."
            return $true
        }

        foreach ($deployment in ($deployments -split "`n")) {
            if (-not [string]::IsNullOrWhiteSpace($deployment)) {
                if ($PSCmdlet.ShouldProcess($deployment, "Delete subscription deployment")) {
                    Write-Output "Deleting deployment: $deployment"
                    $null = az deployment sub delete --name $deployment 2>&1
                    if ($LASTEXITCODE -ne 0) {
                        Write-Warning "Failed to delete deployment: $deployment"
                    }
                    else {
                        Write-Output "Deployment '$deployment' deleted."
                    }
                }
            }
        }

        return $true
    }
    catch {
        Write-Error "Error deleting subscription deployments: $_"
        return $false
    }
}

function Invoke-CleanupScript {
    <#
    .SYNOPSIS
        Invokes a cleanup script with proper error handling.

    .DESCRIPTION
        Executes a PowerShell script with specified parameters, handling
        path resolution and error checking.

    .PARAMETER ScriptPath
        The relative path to the script from the script directory.

    .PARAMETER Parameters
        Hashtable of parameters to pass to the script.

    .PARAMETER Description
        Description of what the script does (for logging).

    .OUTPUTS
        System.Boolean - True if successful, False otherwise.

    .EXAMPLE
        Invoke-CleanupScript -ScriptPath "Azure\deleteUsers.ps1" -Parameters @{Name="test"} -Description "Delete users"
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,

        [Parameter(Mandatory = $false)]
        [hashtable]$Parameters = @{},

        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    try {
        $fullPath = Join-Path -Path $Script:ScriptDirectory -ChildPath $ScriptPath
        $fullPath = [System.IO.Path]::GetFullPath($fullPath)

        if (-not (Test-Path -Path $fullPath)) {
            Write-Warning "Script not found: $fullPath. Skipping $Description."
            return $true
        }

        Write-Output "$Description..."

        if ($Parameters.Count -gt 0) {
            & $fullPath @Parameters
        }
        else {
            & $fullPath
        }

        if ($LASTEXITCODE -ne 0) {
            throw "Script failed with exit code: $LASTEXITCODE"
        }

        Write-Output "$Description completed."
        return $true
    }
    catch {
        Write-Error "Error during ${Description}: $_"
        return $false
    }
}

function Start-FullCleanup {
    <#
    .SYNOPSIS
        Orchestrates the complete cleanup process.

    .DESCRIPTION
        Runs all cleanup operations in sequence: deployments, users,
        credentials, GitHub secrets, and resource groups.

    .PARAMETER AppDisplayName
        The Azure AD application display name.

    .PARAMETER GhSecretName
        The GitHub secret name.

    .PARAMETER EnvName
        The environment name.

    .PARAMETER Location
        The Azure region.

    .OUTPUTS
        System.Boolean - True if all cleanup succeeded, False otherwise.

    .EXAMPLE
        Start-FullCleanup -AppDisplayName "MyApp" -GhSecretName "SECRET" -EnvName "dev" -Location "eastus"
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AppDisplayName,

        [Parameter(Mandatory = $true)]
        [string]$GhSecretName,

        [Parameter(Mandatory = $true)]
        [string]$EnvName,

        [Parameter(Mandatory = $true)]
        [string]$Location
    )

    try {
        Write-Output "Starting full cleanup process..."
        Write-Output "App Display Name: $AppDisplayName"
        Write-Output "GitHub Secret: $GhSecretName"
        Write-Output "Environment: $EnvName"
        Write-Output "Location: $Location"
        Write-Output ""

        $allSucceeded = $true

        # Delete subscription deployments
        if (-not (Remove-SubscriptionDeployments)) {
            Write-Warning "Subscription deployment cleanup had issues."
            $allSucceeded = $false
        }

        # Delete users and assigned roles
        $success = Invoke-CleanupScript `
            -ScriptPath ".configuration\setup\powershell\Azure\deleteUsersAndAssignedRoles.ps1" `
            -Parameters @{ AppDisplayName = $AppDisplayName } `
            -Description "Deleting users and assigned roles"

        if (-not $success) { $allSucceeded = $false }

        # Delete deployment credentials
        $success = Invoke-CleanupScript `
            -ScriptPath ".configuration\setup\powershell\Azure\deleteDeploymentCredentials.ps1" `
            -Parameters @{ AppDisplayName = $AppDisplayName } `
            -Description "Deleting deployment credentials"

        if (-not $success) { $allSucceeded = $false }

        # Delete GitHub secret
        $success = Invoke-CleanupScript `
            -ScriptPath ".configuration\setup\powershell\GitHub\deleteGitHubSecretAzureCredentials.ps1" `
            -Parameters @{ GhSecretName = $GhSecretName } `
            -Description "Deleting GitHub secret for Azure credentials"

        if (-not $success) { $allSucceeded = $false }

        # Clean up resource groups
        $cleanupScriptPath = ".configuration\powershell\cleanUp.ps1"
        $success = Invoke-CleanupScript `
            -ScriptPath $cleanupScriptPath `
            -Parameters @{ EnvName = $EnvName; Location = $Location } `
            -Description "Cleaning up resource groups"

        if (-not $success) { $allSucceeded = $false }

        return $allSucceeded
    }
    catch {
        Write-Error "Error during full cleanup: $_"
        return $false
    }
}

# Main script execution
try {
    Clear-Host

    Write-Output "DevExp-DevBox Full Cleanup"
    Write-Output "=========================="
    Write-Output ""

    $success = Start-FullCleanup `
        -AppDisplayName $AppDisplayName `
        -GhSecretName $GhSecretName `
        -EnvName $EnvName `
        -Location $Location

    if ($success) {
        Write-Output ""
        Write-Output "All cleanup operations completed successfully."
    }
    else {
        Write-Warning "Some cleanup operations failed. Check errors above."
        exit 1
    }
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}