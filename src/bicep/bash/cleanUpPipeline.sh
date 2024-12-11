#!/bin/bash

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
set -euo pipefail


# Azure Resource Group Names Constants
devBoxResourceGroupName="$1"
networkResourceGroupName="$2"
managementResourceGroupName="$3"
location="$4"

# Identity Parameters Constants
customRoleName="$5"

# Function to delete a resource group
deleteResourceGroup() {
    local resourceGroupName="$1"
    local groupExists=$(az group exists --name "$resourceGroupName")

    if $groupExists; then
        # List and delete all deployments in the resource group
        for deployment in $(az deployment group list --resource-group "$resourceGroupName" --query "[].name" -o tsv); do
            echo "Deleting deployment: $deployment"
            az deployment group delete --resource-group "$resourceGroupName" --name "$deployment"
            echo "Deployment $deployment deleted."
        done
        sleep 10
        echo "Deleting resource group: $resourceGroupName..."
        az group delete --name "$resourceGroupName" --yes --no-wait
        echo "Resource group $resourceGroupName deletion initiated."
    else
        echo "Resource group $resourceGroupName does not exist. Skipping deletion."
    fi
}

# Function to remove a role assignment
removeRoleAssignment() {
    local roleId="$1"
    local subscription="$2"

    echo "Checking the role assignments for the identity..."

    if [[ -z "$roleId" ]]; then
        echo "Role not defined. Skipping role assignment deletion."
        return
    fi

    local assignmentExists
    assignmentExists=$(az role assignment list --role "$roleId" )
#--scope /subscriptions/"$subscription"
    if [[ -z "$assignmentExists" || "$assignmentExists" == "[]" ]]; then
        echo "'$roleId' role assignment does not exist. Skipping deletion."
    else
        echo "Removing '$roleId' role assignment from the identity..."   
        az role assignment delete --role "$roleId"
        echo "'$roleId' role assignment successfully removed."
    fi
}

# Function to delete a custom role
deleteCustomRole() {
    local roleName="$1"
    echo "Deleting the '$roleName' role..."
    local roleExists=$(az role definition list --name "$roleName")

    if [[ -z "$roleExists" || "$roleExists" == "[]" ]]; then
        echo "'$roleName' role does not exist. Skipping deletion."
        return
    fi
    
    az role definition delete --name "$roleName"

    while [ "$(az role definition list --name "$roleName" --query [].roleName -o tsv)" == "$roleName" ]; do
        echo "Waiting for the role to be deleted..."
        sleep 10
    done	
    echo "'$roleName' role successfully deleted."
}

# Function to delete role assignments
deleteRoleAssignments() {
    # Deleting role assignments and role definitions
   
    echo "Getting the role ID for '$customRoleName'..."
    local roleId=$(az role definition list --name "$customRoleName" --query [].name --output tsv)
    if [[ -z "$roleId" ]]; then
        echo "Role ID for '$customRoleName' not found. Skipping role assignment deletion."
    else
        echo "Role ID for '$customRoleName' is '$roleId'."
        echo "Removing '$customRoleName' role assignment..."
    fi
    removeRoleAssignment "$roleId"
}

# Function to clean up resources
cleanUpResources() {
    deleteResourceGroup "$devBoxResourceGroupName"
    deleteResourceGroup "$networkResourceGroupName"
    deleteResourceGroup "$managementResourceGroupName"
    deleteResourceGroup "NetworkWatcherRG"
    deleteResourceGroup "Default-ActivityLogAlerts"
    deleteResourceGroup "DefaultResourceGroup-WUS2"
    deleteCustomRole "$customRoleName" 
}

# Main script execution
cleanUpResources