#Requires -Version 5.1

<#
.SYNOPSIS
    Cleans up Azure resource groups created for DevExp-DevBox environment.

.DESCRIPTION
    This script deletes Azure resource groups and their associated deployments
    for the DevExp-DevBox infrastructure. It removes workload, connectivity,
    monitoring, security, and supporting resource groups.

.PARAMETER EnvName
    The environment name used in resource group naming. Defaults to 'demo'.

.PARAMETER Location
    The Azure region where resources are deployed. Defaults to 'eastus2'.
    Valid values: eastus, eastus2, westus, westus2, westus3, northeurope, westeurope

.PARAMETER WorkloadName
    The workload name prefix used in resource group naming. Defaults to 'devexp'.

.EXAMPLE
    .\cleanUp.ps1
    Cleans up resources using default environment 'demo' in 'eastus2'.

.EXAMPLE
    .\cleanUp.ps1 -EnvName "prod" -Location "westus2"
    Cleans up resources for the 'prod' environment in 'westus2'.

.NOTES
    Author: DevExp Team
    Requires: Azure CLI (az) authenticated with appropriate permissions
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$EnvName = "demo",

    [Parameter(Mandatory = $false)]
    [ValidateSet("eastus", "eastus2", "westus", "westus2", "westus3", "northeurope", "westeurope")]
    [string]$Location = "eastus2",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$WorkloadName = "devexp"
)

# Script Configuration
$ErrorActionPreference = 'Stop'
$WarningPreference = 'Stop'

function Remove-AzureResourceGroup {
    <#
    .SYNOPSIS
        Deletes an Azure resource group and its deployments.

    .DESCRIPTION
        First deletes all deployments within the resource group, then initiates
        an asynchronous deletion of the resource group itself.

    .PARAMETER ResourceGroupName
        The name of the resource group to delete.

    .OUTPUTS
        System.Boolean - True if deletion initiated successfully, False otherwise.

    .EXAMPLE
        Remove-AzureResourceGroup -ResourceGroupName "my-resource-group"
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroupName
    )

    try {
        # Check if resource group exists
        $groupExists = az group exists --name $ResourceGroupName
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to check if resource group exists."
        }

        if ($groupExists -ne "true") {
            Write-Output "Resource group '$ResourceGroupName' does not exist. Skipping."
            return $true
        }

        if ($PSCmdlet.ShouldProcess($ResourceGroupName, "Delete resource group")) {
            # List and delete all deployments in the resource group
            Write-Verbose "Listing deployments in resource group: $ResourceGroupName"
            $deployments = az deployment group list --resource-group $ResourceGroupName --query "[].name" --output tsv

            if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($deployments)) {
                foreach ($deployment in ($deployments -split "`n")) {
                    if (-not [string]::IsNullOrWhiteSpace($deployment)) {
                        Write-Output "Deleting deployment: $deployment"
                        $null = az deployment group delete --resource-group $ResourceGroupName --name $deployment 2>&1
                        Write-Output "Deployment '$deployment' deleted."
                    }
                }
            }

            # Wait for deployments to finish deleting
            Start-Sleep -Seconds 10

            # Delete the resource group asynchronously
            Write-Output "Deleting resource group: $ResourceGroupName (async)..."
            $null = az group delete --name $ResourceGroupName --yes --no-wait
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to initiate resource group deletion."
            }
            Write-Output "Resource group '$ResourceGroupName' deletion initiated."
        }

        return $true
    }
    catch {
        Write-Error "Error deleting resource group '$ResourceGroupName': $_"
        return $false
    }
}

function Remove-AllResourceGroups {
    <#
    .SYNOPSIS
        Removes all DevExp-DevBox related resource groups.

    .DESCRIPTION
        Deletes workload, connectivity, monitoring, security, and supporting
        resource groups based on the naming convention.

    .PARAMETER WorkloadName
        The workload name prefix.

    .PARAMETER Environment
        The environment name (e.g., demo, dev, prod).

    .PARAMETER Location
        The Azure region.

    .OUTPUTS
        System.Boolean - True if all deletions initiated successfully, False otherwise.

    .EXAMPLE
        Remove-AllResourceGroups -WorkloadName "devexp" -Environment "demo" -Location "eastus2"
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkloadName,

        [Parameter(Mandatory = $true)]
        [string]$Environment,

        [Parameter(Mandatory = $true)]
        [string]$Location
    )

    try {
        Clear-Host

        # Define resource group names based on naming convention
        $resourceGroups = @(
            "${WorkloadName}-workload-${Environment}-${Location}-rg",
            "${WorkloadName}-connectivity-${Environment}-${Location}-rg",
            "${WorkloadName}-monitoring-${Environment}-${Location}-rg",
            "${WorkloadName}-security-${Environment}-${Location}-rg",
            "NetworkWatcherRG",
            "Default-ActivityLogAlerts",
            "DefaultResourceGroup-WUS2"
        )

        Write-Output "Starting cleanup of resource groups..."
        Write-Output "Environment: $Environment"
        Write-Output "Location: $Location"
        Write-Output ""

        $allSucceeded = $true

        foreach ($rg in $resourceGroups) {
            $success = Remove-AzureResourceGroup -ResourceGroupName $rg
            if (-not $success) {
                $allSucceeded = $false
            }
        }

        if ($allSucceeded) {
            Write-Output ""
            Write-Output "All resource group deletions initiated successfully."
        }
        else {
            Write-Warning "Some resource group deletions failed. Check errors above."
        }

        return $allSucceeded
    }
    catch {
        Write-Error "Error during cleanup process: $_"
        return $false
    }
}

# Main script execution
try {
    Write-Output "DevExp-DevBox Resource Cleanup"
    Write-Output "=============================="

    $success = Remove-AllResourceGroups `
        -WorkloadName $WorkloadName `
        -Environment $EnvName `
        -Location $Location

    if (-not $success) {
        exit 1
    }
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}