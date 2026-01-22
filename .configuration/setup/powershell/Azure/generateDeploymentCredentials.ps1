#Requires -Version 5.1

<#
.SYNOPSIS
    Generates Azure deployment credentials for CI/CD pipelines.

.DESCRIPTION
    Creates an Azure AD service principal with Contributor, User Access Administrator,
    and Managed Identity Contributor roles. Additionally creates user role assignments
    and stores credentials as a GitHub secret for GitHub Actions workflows.

.PARAMETER AppName
    The name for the Azure AD application registration.

.PARAMETER DisplayName
    The display name for the service principal.

.EXAMPLE
    .\generateDeploymentCredentials.ps1 -AppName "contoso-cicd" -DisplayName "Contoso CI/CD Service Principal"
    Creates a service principal and configures GitHub secrets.

.NOTES
    Author: DevExp Team
    Requires: Azure CLI (az), GitHub CLI (gh), and appropriate permissions
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "The name for the Azure AD application.")]
    [ValidateNotNullOrEmpty()]
    [string]$AppName,

    [Parameter(Mandatory = $true, HelpMessage = "The display name for the service principal.")]
    [ValidateNotNullOrEmpty()]
    [string]$DisplayName
)

# Script Configuration
$ErrorActionPreference = 'Stop'
$WarningPreference = 'Stop'

# Script directory for relative path resolution
$Script:ScriptDirectory = $PSScriptRoot

function New-AzureDeploymentCredentials {
    <#
    .SYNOPSIS
        Creates an Azure service principal with required role assignments.

    .DESCRIPTION
        Creates a service principal with Contributor role and adds User Access Administrator
        and Managed Identity Contributor roles for deployment scenarios.

    .PARAMETER AppName
        The name for the Azure AD application.

    .PARAMETER DisplayName
        The display name for the service principal.

    .OUTPUTS
        System.String - The JSON credentials body for GitHub Actions, or $null on failure.

    .EXAMPLE
        $creds = New-AzureDeploymentCredentials -AppName "my-app" -DisplayName "My App SP"
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $true)]
        [string]$DisplayName
    )

    try {
        # Get the subscription ID
        $subscriptionId = az account show --query id --output tsv
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($subscriptionId)) {
            throw "Failed to retrieve subscription ID. Ensure you are logged into Azure CLI."
        }

        Write-Output "Creating service principal '$DisplayName' in subscription: $subscriptionId"

        # Create the service principal with Contributor role
        $ghSecretBody = az ad sp create-for-rbac `
            --name $AppName `
            --display-name $DisplayName `
            --role "Contributor" `
            --scopes "/subscriptions/$subscriptionId" `
            --json-auth `
            --output json

        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($ghSecretBody)) {
            throw "Failed to create service principal."
        }

        # Get the App ID for additional role assignments
        $appId = az ad sp list --display-name $DisplayName --query "[0].appId" --output tsv
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($appId)) {
            throw "Failed to retrieve service principal App ID."
        }

        Write-Output "Service principal created with App ID: $appId"
        Write-Output "Assigning additional roles..."

        # Assign User Access Administrator role
        $null = az role assignment create `
            --assignee $appId `
            --role "User Access Administrator" `
            --scope "/subscriptions/$subscriptionId"

        if ($LASTEXITCODE -ne 0) {
            throw "Failed to assign User Access Administrator role."
        }
        Write-Output "Assigned: User Access Administrator"

        # Assign Managed Identity Contributor role
        $null = az role assignment create `
            --assignee $appId `
            --role "Managed Identity Contributor" `
            --scope "/subscriptions/$subscriptionId"

        if ($LASTEXITCODE -ne 0) {
            throw "Failed to assign Managed Identity Contributor role."
        }
        Write-Output "Assigned: Managed Identity Contributor"

        Write-Output "Role assignments completed successfully."
        return $ghSecretBody
    }
    catch {
        Write-Error "Error creating deployment credentials: $_"
        return $null
    }
}

function Invoke-UserRoleAssignment {
    <#
    .SYNOPSIS
        Invokes the user role assignment script.

    .DESCRIPTION
        Executes the createUsersAndAssignRole.ps1 script to assign DevCenter roles
        to the current user.

    .OUTPUTS
        System.Boolean - True if successful, False otherwise.

    .EXAMPLE
        Invoke-UserRoleAssignment
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        Write-Output "Creating user role assignments..."

        $scriptPath = Join-Path -Path $Script:ScriptDirectory -ChildPath "createUsersAndAssignRole.ps1"

        if (-not (Test-Path -Path $scriptPath)) {
            throw "User role assignment script not found: $scriptPath"
        }

        & $scriptPath
        if ($LASTEXITCODE -ne 0) {
            throw "User role assignment script failed with exit code: $LASTEXITCODE"
        }

        Write-Output "User role assignments completed successfully."
        return $true
    }
    catch {
        Write-Error "Error creating user role assignments: $_"
        return $false
    }
}

function Invoke-GitHubSecretCreation {
    <#
    .SYNOPSIS
        Invokes the GitHub secret creation script.

    .DESCRIPTION
        Executes the createGitHubSecretAzureCredentials.ps1 script to store
        Azure credentials as a GitHub secret.

    .PARAMETER CredentialsJson
        The JSON credentials body to store as a secret.

    .OUTPUTS
        System.Boolean - True if successful, False otherwise.

    .EXAMPLE
        Invoke-GitHubSecretCreation -CredentialsJson $jsonBody
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$CredentialsJson
    )

    try {
        Write-Output "Creating GitHub secret for Azure credentials..."

        $scriptPath = Join-Path -Path $Script:ScriptDirectory -ChildPath "..\GitHub\createGitHubSecretAzureCredentials.ps1"
        $scriptPath = [System.IO.Path]::GetFullPath($scriptPath)

        if (-not (Test-Path -Path $scriptPath)) {
            throw "GitHub secret script not found: $scriptPath"
        }

        & $scriptPath -ghSecretBody $CredentialsJson
        if ($LASTEXITCODE -ne 0) {
            throw "GitHub secret creation script failed with exit code: $LASTEXITCODE"
        }

        Write-Output "GitHub secret created successfully."
        return $true
    }
    catch {
        Write-Error "Error creating GitHub secret: $_"
        return $false
    }
}

# Main script execution
try {
    Write-Output "Starting deployment credentials generation..."
    Write-Output "App Name: $AppName"
    Write-Output "Display Name: $DisplayName"

    # Create the deployment credentials
    $ghSecretBody = New-AzureDeploymentCredentials -AppName $AppName -DisplayName $DisplayName
    if ([string]::IsNullOrWhiteSpace($ghSecretBody)) {
        throw "Failed to create deployment credentials."
    }

    Write-Output ""
    Write-Output "Service principal credentials (for reference):"
    Write-Output $ghSecretBody
    Write-Output ""

    # Create user role assignments
    $userSuccess = Invoke-UserRoleAssignment
    if (-not $userSuccess) {
        Write-Warning "User role assignment failed, but continuing..."
    }

    # Create GitHub secret
    $ghSuccess = Invoke-GitHubSecretCreation -CredentialsJson $ghSecretBody
    if (-not $ghSuccess) {
        Write-Warning "GitHub secret creation failed, but credentials were created."
        Write-Warning "You may need to manually configure the AZURE_CREDENTIALS secret."
    }

    Write-Output ""
    Write-Output "Deployment credentials generation completed."
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}