# PowerShell script to clean up Azure resources


[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$EnvName = "demo",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("eastus", "eastus2", "westus", "westus2", "westus3", "northeurope", "westeurope")]
    [string]$Location = "eastus2"
)

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
$ErrorActionPreference = "Stop"
$WarningPreference = "Stop"

$workloadname = "devexp"  # Replace with your workload name
$environment = $EnvName          # Replace with your environment name (e.g., dev, prod)
$location = $Location        # Replace with your environment (e.g., dev, prod)
# Azure Resource Group Names Constants
$workloadResourceGroup = "${workloadname}-workload-${environment}-${location}-rg"
$connectivityResourceGroup = "${workloadname}-connectivity-${environment}-${location}-rg"
$managementResourceGroup = "${workloadname}-monitoring-${environment}-${location}-rg"
$securityResourceGroup = "${workloadname}-security-${environment}-${location}-rg"

# Function to delete a resource group
function Remove-ResourceGroup {
    param (
        [Parameter(Mandatory = $true)]
        [string]$resourceGroupName
    )

    try {
        $groupExists = (az group exists --name $resourceGroupName)

        if ($groupExists -eq "true") {
            # List and delete all deployments in the resource group
            $deployments = az deployment group list --resource-group $resourceGroupName --query "[].name" -o tsv
            foreach ($deployment in $deployments) {
                Write-Output "Deleting deployment: $deployment"
                az deployment group delete --resource-group $resourceGroupName --name $deployment
                Write-Output "Deployment $deployment deleted."
            }
            Start-Sleep -Seconds 10
            Write-Output "Deleting resource group: $resourceGroupName..."
            az group delete --name $resourceGroupName --yes --no-wait
            Write-Output "Resource group $resourceGroupName deletion initiated."
        }
        else {
            Write-Output "Resource group $resourceGroupName does not exist. Skipping deletion."
        }
    }
    catch {
        Write-Error "Error deleting resource group ${resourceGroupName}: $_"
        return 1
    }
}

# Function to clean up resources
function Remove-Resources {
    try {
        Clear-Host
        Remove-ResourceGroup -resourceGroupName $workloadResourceGroup
        Remove-ResourceGroup -resourceGroupName $connectivityResourceGroup
        Remove-ResourceGroup -resourceGroupName $managementResourceGroup
        Remove-ResourceGroup -resourceGroupName $securityResourceGroup
        Remove-ResourceGroup -resourceGroupName "NetworkWatcherRG"
        Remove-ResourceGroup -resourceGroupName "Default-ActivityLogAlerts"
        Remove-ResourceGroup -resourceGroupName "DefaultResourceGroup-WUS2"
    }
    catch {
        Write-Error "Error during cleanup process: $_"
        return 1
    }
}

# Main script execution
try {
    Remove-Resources
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}