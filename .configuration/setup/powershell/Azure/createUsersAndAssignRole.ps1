#Requires -Version 5.1

<#
.SYNOPSIS
    Creates user assignments and assigns Azure DevCenter roles to the current user.

.DESCRIPTION
    This script retrieves the current signed-in Azure user and assigns
    DevCenter-related roles including:
    - DevCenter Dev Box User
    - DevCenter Project Admin
    - Deployment Environments Reader
    - Deployment Environments User

    The roles are assigned at the subscription scope.

.PARAMETER SubscriptionId
    The Azure subscription ID where roles will be assigned. If not provided,
    uses the current subscription.

.EXAMPLE
    .\createUsersAndAssignRole.ps1
    Assigns DevCenter roles to the current user using the current subscription.

.EXAMPLE
    .\createUsersAndAssignRole.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012"
    Assigns DevCenter roles using a specific subscription.

.NOTES
    Author: DevExp Team
    Requires: Azure CLI (az) authenticated with appropriate permissions
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
    [string]$SubscriptionId
)

# Script Configuration
$ErrorActionPreference = 'Stop'
$WarningPreference = 'Stop'

# Get the subscription ID if not provided
if ([string]::IsNullOrWhiteSpace($SubscriptionId)) {
    $SubscriptionId = az account show --query id --output tsv
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to retrieve current subscription ID."
        exit 1
    }
}

function Set-AzureRole {
    <#
    .SYNOPSIS
        Assigns an Azure RBAC role to a user or service principal.

    .DESCRIPTION
        Checks if the specified role is already assigned to the identity,
        and if not, creates a new role assignment at the subscription scope.

    .PARAMETER UserIdentityId
        The object ID of the user or service principal.

    .PARAMETER RoleName
        The name of the Azure RBAC role to assign.

    .PARAMETER PrincipalType
        The type of principal (User, ServicePrincipal, Group).

    .PARAMETER SubscriptionId
        The subscription ID for the role scope.

    .OUTPUTS
        System.Boolean - True if assignment succeeded or already exists, False on error.

    .EXAMPLE
        Set-AzureRole -UserIdentityId $userId -RoleName "Contributor" -PrincipalType "User" -SubscriptionId $subId
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$UserIdentityId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RoleName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('User', 'ServicePrincipal', 'Group')]
        [string]$PrincipalType,

        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId
    )

    try {
        Write-Verbose "Checking if '$RoleName' role is already assigned to identity $UserIdentityId..."

        # Check if the role is already assigned
        $existingAssignment = az role assignment list `
            --assignee $UserIdentityId `
            --role $RoleName `
            --scope "/subscriptions/$SubscriptionId" `
            --query "[?principalType=='$PrincipalType']" `
            --output tsv

        if (-not [string]::IsNullOrWhiteSpace($existingAssignment)) {
            Write-Output "Role '$RoleName' is already assigned to identity $UserIdentityId. Skipping."
            return $true
        }

        Write-Output "Assigning '$RoleName' role to identity $UserIdentityId..."

        # Attempt to assign the role
        $result = az role assignment create `
            --assignee-object-id $UserIdentityId `
            --assignee-principal-type $PrincipalType `
            --role $RoleName `
            --scope "/subscriptions/$SubscriptionId"

        if ($LASTEXITCODE -ne 0) {
            throw "Failed to assign role '$RoleName' to identity $UserIdentityId."
        }

        Write-Output "Role '$RoleName' assigned successfully."
        return $true
    }
    catch {
        Write-Error "Error assigning role '$RoleName': $_"
        return $false
    }
}

function New-UserRoleAssignments {
    <#
    .SYNOPSIS
        Creates DevCenter role assignments for the current signed-in user.

    .DESCRIPTION
        Retrieves the current Azure AD signed-in user and assigns all
        required DevCenter roles at the subscription scope.

    .PARAMETER SubscriptionId
        The subscription ID for role assignments.

    .OUTPUTS
        System.Boolean - True if all assignments succeeded, False otherwise.

    .EXAMPLE
        New-UserRoleAssignments -SubscriptionId $subscriptionId
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId
    )

    try {
        # Get the current signed-in user's object ID
        $currentUser = az ad signed-in-user show --query id --output tsv

        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($currentUser)) {
            throw "Failed to retrieve current signed-in user's object ID."
        }

        Write-Output "Creating role assignments for user: $currentUser"

        # Define DevCenter roles to assign
        $roles = @(
            "DevCenter Dev Box User",
            "DevCenter Project Admin",
            "Deployment Environments Reader",
            "Deployment Environments User"
        )

        $allSucceeded = $true

        foreach ($role in $roles) {
            $success = Set-AzureRole `
                -UserIdentityId $currentUser `
                -RoleName $role `
                -PrincipalType 'User' `
                -SubscriptionId $SubscriptionId

            if (-not $success) {
                Write-Warning "Failed to assign role '$role' to user $currentUser"
                $allSucceeded = $false
            }
        }

        if ($allSucceeded) {
            Write-Output "All role assignments completed successfully for user: $currentUser"
        }

        return $allSucceeded
    }
    catch {
        Write-Error "Error creating user assignments: $_"
        return $false
    }
}

# Main script execution
try {
    $success = New-UserRoleAssignments -SubscriptionId $SubscriptionId
    if (-not $success) {
        exit 1
    }
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}