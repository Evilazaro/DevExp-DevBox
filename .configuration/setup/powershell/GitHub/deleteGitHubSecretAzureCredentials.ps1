#Requires -Version 5.1

<#
.SYNOPSIS
    Deletes a GitHub repository secret.

.DESCRIPTION
    Authenticates to GitHub using the GitHub CLI and removes the specified
    secret from the current repository. Typically used to remove the
    AZURE_CREDENTIALS secret during cleanup operations.

    The script performs the following operations:
    1. Verifies GitHub CLI authentication status
    2. Prompts for interactive login if not authenticated
    3. Removes the specified secret from the repository

.PARAMETER GhSecretName
    The name of the GitHub secret to delete. This parameter is mandatory
    and must not be null or empty.

.INPUTS
    None. This script does not accept pipeline input.

.OUTPUTS
    None. This script does not return any objects.

.EXAMPLE
    .\deleteGitHubSecretAzureCredentials.ps1 -GhSecretName "AZURE_CREDENTIALS"
    Deletes the AZURE_CREDENTIALS secret from the current repository.

.EXAMPLE
    .\deleteGitHubSecretAzureCredentials.ps1 -GhSecretName "MY_SECRET" -WhatIf
    Shows what would happen if the script runs without actually deleting the secret.

.EXAMPLE
    .\deleteGitHubSecretAzureCredentials.ps1 -ghSecretName "AZURE_CREDENTIALS" -Verbose
    Deletes the secret with verbose output enabled.

.LINK
    https://cli.github.com/manual/gh_secret_delete

.NOTES
    Author: DevExp Team
    Requires: GitHub CLI (gh) installed and accessible
    The script supports -WhatIf and -Confirm parameters via SupportsShouldProcess.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true, HelpMessage = "The name of the GitHub secret to delete.")]
    [ValidateNotNullOrEmpty()]
    [Alias('ghSecretName')]
    [string]$GhSecretName
)

# Script Configuration
$ErrorActionPreference = 'Stop'
$WarningPreference = 'Stop'

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

function Remove-GitHubRepositorySecret {
    <#
    .SYNOPSIS
        Removes a GitHub repository secret.

    .DESCRIPTION
        Deletes a secret from the current GitHub repository using the GitHub CLI.

    .PARAMETER SecretName
        The name of the secret to remove.

    .OUTPUTS
        System.Boolean - True if secret was removed successfully, False otherwise.

    .EXAMPLE
        Remove-GitHubRepositorySecret -SecretName "MY_SECRET"
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SecretName
    )

    try {
        if ($PSCmdlet.ShouldProcess("GitHub Secret '$SecretName'", "Remove")) {
            Write-Output "Removing GitHub secret: $SecretName"

            # Remove the secret using gh CLI
            $null = gh secret remove $SecretName 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Secret '$SecretName' may not exist or could not be removed."
                return $true  # Not a fatal error if secret doesn't exist
            }

            Write-Output "GitHub secret '$SecretName' removed successfully."
        }
        return $true
    }
    catch {
        Write-Error "Error removing GitHub secret: $_"
        return $false
    }
}

# Main script execution
try {
    Write-Output "Starting GitHub secret deletion..."

    # Authenticate to GitHub
    if (-not (Connect-GitHubCli)) {
        throw "GitHub authentication failed."
    }

    # Remove the secret
    if (-not (Remove-GitHubRepositorySecret -SecretName $GhSecretName)) {
        throw "Failed to remove GitHub secret."
    }

    Write-Output ""
    Write-Output "GitHub secret deletion completed."
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}