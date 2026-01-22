#Requires -Version 5.1

<#
.SYNOPSIS
    Creates a custom Azure RBAC role for role assignment management.

.DESCRIPTION
    This script creates a custom Azure role definition that grants permissions
    to manage role assignments. The role includes permissions to read, write,
    and delete role assignments within a specified subscription scope.

.PARAMETER RoleName
    The display name for the custom role. Defaults to 'Contoso DevBox - Role Assignment Writer'.

.PARAMETER SubscriptionId
    The Azure subscription ID where the role will be scoped. If not provided,
    the current subscription is used.

.PARAMETER Description
    Description for the custom role. Defaults to 'Allows creating role assignments.'

.PARAMETER Force
    If specified, deletes any existing role with the same name before creating.

.EXAMPLE
    .\createCustomRole.ps1
    Creates the custom role using the current subscription.

.EXAMPLE
    .\createCustomRole.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012"
    Creates the custom role scoped to a specific subscription.

.EXAMPLE
    .\createCustomRole.ps1 -RoleName "MyCompany Role Writer" -Force
    Creates a custom role with a different name, removing any existing role first.

.NOTES
    Author: DevExp Team
    Requires: Azure CLI (az) authenticated with appropriate permissions
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$RoleName = "Contoso DevBox - Role Assignment Writer",

    [Parameter(Mandatory = $false)]
    [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$Description = "Allows creating role assignments.",

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# Script Configuration
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Get-CurrentSubscriptionId {
    <#
    .SYNOPSIS
        Retrieves the current Azure subscription ID.

    .OUTPUTS
        System.String - The subscription ID GUID.

    .EXAMPLE
        $subId = Get-CurrentSubscriptionId
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    try {
        $subscriptionId = az account show --query id --output tsv
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($subscriptionId)) {
            throw "Failed to retrieve current subscription ID. Ensure you are logged into Azure CLI."
        }
        return $subscriptionId
    }
    catch {
        Write-Error "Error retrieving subscription ID: $_"
        throw
    }
}

function New-CustomRoleDefinition {
    <#
    .SYNOPSIS
        Creates a custom Azure RBAC role definition.

    .DESCRIPTION
        Creates a JSON role definition file and uses Azure CLI to create
        the custom role in Azure.

    .PARAMETER RoleName
        The name of the custom role.

    .PARAMETER SubscriptionId
        The subscription ID for the assignable scope.

    .PARAMETER Description
        The description for the role.

    .PARAMETER RemoveExisting
        If true, removes any existing role with the same name first.

    .OUTPUTS
        System.Boolean - True if successful, False otherwise.

    .EXAMPLE
        New-CustomRoleDefinition -RoleName "MyRole" -SubscriptionId $subId -Description "My custom role"
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RoleName,

        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $false)]
        [string]$Description = "Allows creating role assignments.",

        [Parameter(Mandatory = $false)]
        [switch]$RemoveExisting
    )

    # Define the role definition
    $roleDefinition = @{
        Name             = $RoleName
        IsCustom         = $true
        Description      = $Description
        Actions          = @(
            "Microsoft.Authorization/roleAssignments/write"
            "Microsoft.Authorization/roleAssignments/delete"
            "Microsoft.Authorization/roleAssignments/read"
        )
        NotActions       = @()
        DataActions      = @()
        NotDataActions   = @()
        AssignableScopes = @(
            "/subscriptions/$SubscriptionId"
        )
    }

    # Create temporary file for role definition
    $tempFilePath = Join-Path -Path $env:TEMP -ChildPath "custom-role-$(Get-Date -Format 'yyyyMMddHHmmss').json"

    try {
        # Convert to JSON and write to file
        $roleDefinitionJson = $roleDefinition | ConvertTo-Json -Depth 10
        $roleDefinitionJson | Out-File -FilePath $tempFilePath -Encoding utf8

        Write-Verbose "Role definition written to: $tempFilePath"

        # Remove existing role if requested
        if ($RemoveExisting) {
            if ($PSCmdlet.ShouldProcess($RoleName, "Delete existing role definition")) {
                Write-Verbose "Removing existing role definition: $RoleName"
                $null = az role definition delete --name $RoleName 2>$null
                # Ignore errors if role doesn't exist
            }
        }

        # Create the custom role
        if ($PSCmdlet.ShouldProcess($RoleName, "Create custom role definition")) {
            Write-Verbose "Creating custom role: $RoleName"
            $result = az role definition create --role-definition $tempFilePath
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to create custom role definition. Exit code: $LASTEXITCODE"
            }

            Write-Output "Custom role '$RoleName' created successfully."
            Write-Output "Assignable scope: /subscriptions/$SubscriptionId"
            return $true
        }

        return $true
    }
    catch {
        Write-Error "Error creating custom role: $_"
        return $false
    }
    finally {
        # Cleanup temporary file
        if (Test-Path $tempFilePath) {
            Remove-Item -Path $tempFilePath -Force -ErrorAction SilentlyContinue
        }
    }
}

# Main script execution
try {
    # Get subscription ID if not provided
    if ([string]::IsNullOrWhiteSpace($SubscriptionId)) {
        Write-Verbose "No subscription ID provided, retrieving current subscription..."
        $SubscriptionId = Get-CurrentSubscriptionId
    }

    Write-Output "Creating custom role '$RoleName' in subscription: $SubscriptionId"

    # Create the custom role
    $success = New-CustomRoleDefinition -RoleName $RoleName `
        -SubscriptionId $SubscriptionId `
        -Description $Description `
        -RemoveExisting:$Force

    if (-not $success) {
        exit 1
    }
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}
