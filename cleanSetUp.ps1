# PowerShell script to clean up the setup by deleting users, credentials, and GitHub secrets

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$EnvName = "gitHub",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("eastus", "eastus2", "westus", "westus2", "westus3", "northeurope", "westeurope")]
    [string]$Location = "eastus2"
)

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
$ErrorActionPreference = "Stop"
$WarningPreference = "Stop"

$appDisplayName = "ContosoDevEx GitHub Actions Enterprise App"
$ghSecretName = "AZURE_CREDENTIALS"

# Function to delete deployments
function Remove-Deployments {
    param (
        [string]$resourceGroupName
    )

    try {
        $deployments = az deployment sub list --query "[].name" -o tsv
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to list deployments."
        }
        
        foreach ($deployment in $deployments) {
            if (-not [string]::IsNullOrEmpty($deployment)) {
                Write-Output "Deleting deployment: $deployment"
                az deployment sub delete --name $deployment
                if ($LASTEXITCODE -ne 0) {
                    throw "Failed to delete deployment: $deployment"
                }
                Write-Output "Deployment $deployment deleted."
            }
        }
        return $true
    }
    catch {
        Write-Error "Error deleting deployments: $_"
        return $false
    }
}

# Function to clean up the setup by deleting users, credentials, and GitHub secrets
function Remove-SetUp {
    param (
        [Parameter(Mandatory = $true)]
        [string]$appDisplayName,

        [Parameter(Mandatory = $true)]
        [string]$ghSecretName
    )

    try {
        # Check if required parameters are provided
        if ([string]::IsNullOrEmpty($appDisplayName) -or [string]::IsNullOrEmpty($ghSecretName)) {
            throw "Missing required parameters."
        }

        Write-Output "Starting cleanup process for appDisplayName: $appDisplayName and ghSecretName: $ghSecretName"

        # Delete deployments
        Write-Output "Deleting deployments..."
        $deploymentResult = Remove-Deployments
        if (-not $deploymentResult) {
            throw "Failed to delete deployments."
        }

        # Delete users and assigned roles
        Write-Output "Deleting users and assigned roles..."
        & ".\.configuration\setup\powershell\Azure\deleteUsersAndAssignedRoles.ps1" -appDisplayName $appDisplayName
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to delete users and assigned roles."
        }

        # Delete deployment credentials
        Write-Output "Deleting deployment credentials..."
        & ".\.configuration\setup\powershell\Azure\deleteDeploymentCredentials.ps1" -appDisplayName $appDisplayName
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to delete deployment credentials."
        }

        # Delete GitHub secret for Azure credentials
        Write-Output "Deleting GitHub secret for Azure credentials..."
        & ".\GitHub\deleteGitHubSecretAzureCredentials.ps1" -ghSecretName $ghSecretName
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to delete GitHub secret for Azure credentials."
        }

        Write-Output "Cleanup process completed successfully for appDisplayName: $appDisplayName and ghSecretName: $ghSecretName"
        return $true
    }
    catch {
        Write-Error "Error during cleanup process: $_"
        return $false
    }
}

# Main script execution
try {
    Clear-Host
    
    # Call the cleanup function with the required parameters
    Write-Output "Starting cleanup process with EnvName: $EnvName and Location: $Location"
    
    # Additional cleanup script if it exists
    $cleanupScriptPath = ".\.configuration\powershell\cleanUp.ps1"
    if (Test-Path $cleanupScriptPath) {
        & $cleanupScriptPath $EnvName $Location
        if ($LASTEXITCODE -ne 0) {
            throw "Cleanup script failed."
        }
    }
    
    Write-Output "All cleanup operations completed successfully."
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}