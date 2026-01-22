#Requires -Version 5.1

<#
.SYNOPSIS
    Creates a GitHub secret for Azure credentials.

.DESCRIPTION
    Authenticates to GitHub using the GitHub CLI and creates a repository secret
    named AZURE_CREDENTIALS containing the Azure service principal credentials
    for use in GitHub Actions workflows.

.PARAMETER GhSecretBody
    The JSON body containing Azure service principal credentials.
    This should be the output from 'az ad sp create-for-rbac --json-auth'.

.EXAMPLE
    .\createGitHubSecretAzureCredentials.ps1 -GhSecretBody '{"clientId":"...","clientSecret":"..."}'
    Creates the AZURE_CREDENTIALS secret in the current repository.

.NOTES
    Author: DevExp Team
    Requires: GitHub CLI (gh) installed and accessible
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "The JSON credentials body to store as a secret.")]
    [ValidateNotNullOrEmpty()]
    [Alias('ghSecretBody')]
    [string]$GhSecretBody
)

# Script Configuration
$ErrorActionPreference = 'Stop'
$WarningPreference = 'Stop'

# Secret name constant
$Script:SecretName = "AZURE_CREDENTIALS"

function Connect-GitHubCli {
    <#
    .SYNOPSIS
        Authenticates to GitHub using the GitHub CLI.

    .DESCRIPTION
        Checks if already authenticated and prompts for login if needed.
        Uses the interactive gh auth login flow.

    .OUTPUTS
        System.Boolean - True if authentication succeeded, False otherwise.

    .EXAMPLE
        Connect-GitHubCli
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        Write-Output "Checking GitHub authentication status..."

        # Check if already authenticated
        $null = gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Output "Already authenticated to GitHub."
            return $true
        }

        Write-Output "Not authenticated. Starting GitHub login..."
        gh auth login
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to authenticate to GitHub."
        }

        Write-Output "Successfully authenticated to GitHub."
        return $true
    }
    catch {
        Write-Error "Error during GitHub authentication: $_"
        return $false
    }
}

function Set-GitHubRepositorySecret {
    <#
    .SYNOPSIS
        Creates or updates a GitHub repository secret.

    .DESCRIPTION
        Sets a secret in the current GitHub repository using the GitHub CLI.

    .PARAMETER SecretName
        The name of the secret to create.

    .PARAMETER SecretValue
        The value to store in the secret.

    .OUTPUTS
        System.Boolean - True if secret was set successfully, False otherwise.

    .EXAMPLE
        Set-GitHubRepositorySecret -SecretName "MY_SECRET" -SecretValue "secret-value"
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SecretName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SecretValue
    )

    try {
        Write-Output "Setting GitHub secret: $SecretName"

        # Set the secret using gh CLI
        $null = gh secret set $SecretName --body $SecretValue
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to set GitHub secret: $SecretName"
        }

        Write-Output "GitHub secret '$SecretName' set successfully."
        return $true
    }
    catch {
        Write-Error "Error setting GitHub secret: $_"
        return $false
    }
}

# Main script execution
try {
    Write-Output "Creating GitHub secret for Azure credentials..."

    # Authenticate to GitHub
    if (-not (Connect-GitHubCli)) {
        throw "GitHub authentication failed."
    }

    # Set the secret
    if (-not (Set-GitHubRepositorySecret -SecretName $Script:SecretName -SecretValue $GhSecretBody)) {
        throw "Failed to create GitHub secret."
    }

    Write-Output ""
    Write-Output "GitHub secret '$Script:SecretName' created successfully."
    Write-Output "You can now use this secret in your GitHub Actions workflows."
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}