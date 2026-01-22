#Requires -Version 5.1

<#
.SYNOPSIS
    Deletes user role assignments for DevCenter resources.

.DESCRIPTION
    This script removes Azure RBAC role assignments for the current signed-in
    user that were created for DevCenter operations. It removes the following roles:
    - DevCenter Dev Box User
    - DevCenter Project Admin
    - Deployment Environments Reader
    - Deployment Environments User

.PARAMETER AppDisplayName
    The display name of the associated application (used for logging purposes).

.PARAMETER SubscriptionId
    The Azure subscription ID where roles will be removed. If not provided,
    uses the current subscription.

.EXAMPLE
    .\deleteUsersAndAssignedRoles.ps1 -AppDisplayName "ContosoDevEx GitHub Actions Enterprise App"
    Removes DevCenter role assignments from the current user.

.NOTES
    Author: DevExp Team
    Requires: Azure CLI (az) authenticated with appropriate permissions
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$AppDisplayName,

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

function Remove-UserRoleAssignment {
    <#
    .SYNOPSIS
        Removes an Azure RBAC role assignment from a user.

    .DESCRIPTION
        Checks if the specified role is assigned to the user,
        and if so, removes the role assignment at the subscription scope.

    .PARAMETER UserIdentityId
        The object ID of the user.

    .PARAMETER RoleName
        The name of the Azure RBAC role to remove.

    .PARAMETER SubscriptionId
        The subscription ID for the role scope.

    .OUTPUTS
        System.Boolean - True if removal succeeded or role not assigned, False on error.

    .EXAMPLE
        Remove-UserRoleAssignment -UserIdentityId $userId -RoleName "Contributor" -SubscriptionId $subId
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$UserIdentityId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RoleName,

        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId
    )

    try {
        Write-Verbose "Checking if '$RoleName' role is assigned to identity $UserIdentityId..."

        # Check if the role is assigned
        $existingAssignment = az role assignment list `
            --assignee $UserIdentityId `
            --role $RoleName `
            --scope "/subscriptions/$SubscriptionId" `
            --query "[0].id" `
            --output tsv

        if ([string]::IsNullOrWhiteSpace($existingAssignment)) {
            Write-Output "Role '$RoleName' is not assigned to identity $UserIdentityId. Skipping."
            return $true
        }

        if ($PSCmdlet.ShouldProcess("Role '$RoleName' for user $UserIdentityId", "Remove")) {
            Write-Output "Removing '$RoleName' role from identity $UserIdentityId..."

            $null = az role assignment delete `
                --assignee $UserIdentityId `
                --role $RoleName `
                --scope "/subscriptions/$SubscriptionId"

            if ($LASTEXITCODE -ne 0) {
                throw "Failed to remove role '$RoleName' from identity $UserIdentityId."
            }

            Write-Output "Role '$RoleName' removed successfully."
        }

        return $true
    }
    catch {
        Write-Error "Error removing role '$RoleName': $_"
        return $false
    }
}

function Remove-UserRoleAssignments {
    <#
    .SYNOPSIS
        Removes DevCenter role assignments from the current signed-in user.

    .DESCRIPTION
        Retrieves the current Azure AD signed-in user and removes all
        DevCenter-related role assignments at the subscription scope.

    .PARAMETER SubscriptionId
        The subscription ID for role removal.

    .OUTPUTS
        System.Boolean - True if all removals succeeded, False otherwise.

    .EXAMPLE
        Remove-UserRoleAssignments -SubscriptionId $subscriptionId
    #>
    [CmdletBinding(SupportsShouldProcess)]
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

        Write-Output "Removing role assignments for user: $currentUser"

        # Define DevCenter roles to remove
        $roles = @(
            "DevCenter Dev Box User",
            "DevCenter Project Admin",
            "Deployment Environments Reader",
            "Deployment Environments User"
        )

        $allSucceeded = $true

        foreach ($role in $roles) {
            $success = Remove-UserRoleAssignment `
                -UserIdentityId $currentUser `
                -RoleName $role `
                -SubscriptionId $SubscriptionId

            if (-not $success) {
                Write-Warning "Failed to remove role '$role' from user $currentUser"
                $allSucceeded = $false
            }
        }

        if ($allSucceeded) {
            Write-Output "All role assignments removed successfully for user: $currentUser"
        }

        return $allSucceeded
    }
    catch {
        Write-Error "Error removing user role assignments: $_"
        return $false
    }
}

# Main script execution
try {
    if (-not [string]::IsNullOrWhiteSpace($AppDisplayName)) {
        Write-Output "Starting role cleanup for application: $AppDisplayName"
    }

    $success = Remove-UserRoleAssignments -SubscriptionId $SubscriptionId
    if (-not $success) {
        exit 1
    }

    Write-Output "User role assignments cleanup completed successfully."
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}