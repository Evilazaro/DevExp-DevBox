# PowerShell script to clean up the setup by deleting users, credentials, and GitHub secrets

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
$ErrorActionPreference = "Stop"
$WarningPreference = "Stop"

$appDisplayName = "ContosoDevEx GitHub Actions Enterprise App"
$ghSecretName = "AZURE_CREDENTIALS"

function Delete-Deployments {
    param (
        [string]$resourceGroupName
    )

    $deployments = az deployment sub list --query "[].name" -o tsv
    foreach ($deployment in $deployments) {
        Write-Output "Deleting deployment: $deployment"
        az deployment sub delete --name $deployment
        Write-Output "Deployment $deployment deleted."
    }
}

# Function to clean up the setup by deleting users, credentials, and GitHub secrets
function Clean-SetUp {
    param (
        [string]$appDisplayName,
        [string]$ghSecretName
    )

    Delete-Deployments

    # Check if required parameters are provided
    if ([string]::IsNullOrEmpty($appDisplayName) -or [string]::IsNullOrEmpty($ghSecretName)) {
        Write-Output "Error: Missing required parameters."
        Write-Output "Usage: Clean-SetUp -appDisplayName <appDisplayName> -ghSecretName <ghSecretName>"
        return 1
    }

    Write-Output "Starting cleanup process for appDisplayName: $appDisplayName and ghSecretName: $ghSecretName"

    # Delete users and assigned roles
    Write-Output "Deleting users and assigned roles..."
    .\Azure\deleteUsersAndAssignedRoles.ps1 $appDisplayName
    
    # Delete deployment credentials
    Write-Output "Deleting deployment credentials..."
    .\Azure\deleteDeploymentCredentials.ps1 $appDisplayName
   
    # Delete GitHub secret for Azure credentials
    Write-Output "Deleting GitHub secret for Azure credentials..."
    .\GitHub\deleteGitHubSecretAzureCredentials.ps1 $ghSecretName
    

    Write-Output "Cleanup process completed successfully for appDisplayName: $appDisplayName and ghSecretName: $ghSecretName"
}

# Main script execution
Clear-Host
Clean-SetUp -appDisplayName $appDisplayName -ghSecretName $ghSecretName