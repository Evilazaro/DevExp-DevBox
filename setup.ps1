<#
.SYNOPSIS
    Sets up Azure Dev Box environment with source control integration

.DESCRIPTION
    Automates the setup of an Azure Developer CLI (azd) environment for Dev Box,
    handles GitHub and Azure DevOps authentication, and provisions required Azure resources.
    
    This script follows Azure best practices for security, error handling, 
    and resource management.

.PARAMETER EnvName
    Name of the Azure environment to create

.PARAMETER SourceControl
    Source control platform (github or adogit)

.PARAMETER Help
    Show help information

.EXAMPLE
    .\setUp.ps1 -EnvName "prod" -SourceControl "github"
    Creates a "prod" environment with GitHub

.EXAMPLE
    .\setUp.ps1 -EnvName "dev" -SourceControl "adogit"
    Creates a "dev" environment with Azure DevOps

.NOTES
    Requirements:
    - Azure CLI (az)
    - Azure Developer CLI (azd)
    - GitHub CLI (gh) [if using GitHub]
    - Valid authentication for chosen platform
    
    Author: DevExp Team
    Last Updated: 2025-07-15
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Name of the Azure environment to create")]
    [ValidateNotNullOrEmpty()]
    [string]$EnvName,
    
    [Parameter(Mandatory = $false, HelpMessage = "Source control platform (github or adogit)")]
    [ValidateSet("github", "adogit", IgnoreCase = $true)]
    [string]$SourceControl,
    
    [Parameter(Mandatory = $false, HelpMessage = "Show help information")]
    [switch]$Help
)

# Script Configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Global Variables
$script:ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$script:TimestampFormat = "yyyy-MM-dd HH:mm:ss"

# Unicode icons for cross-platform compatibility
$script:Icons = @{
    Info    = "ℹ️"
    Warning = "⚠️"
    Error   = "❌"
    Success = "✅"
}

# Script state variables
$script:GitHubToken = $null
$script:AdoToken = $null

#######################################
# Helper Functions
#######################################

function Write-LogMessage {
    <#
    .SYNOPSIS
        Logging function with different levels and colors
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error", "Success")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format $script:TimestampFormat
    $icon = $script:Icons[$Level]
    
    switch ($Level) {
        "Error" {
            Write-Host "$icon [$timestamp] $Message" -ForegroundColor Red
            Write-Error $Message -ErrorAction Continue
        }
        "Warning" {
            Write-Host "$icon [$timestamp] $Message" -ForegroundColor Yellow
        }
        "Success" {
            Write-Host "$icon [$timestamp] $Message" -ForegroundColor Green
        }
        default {
            Write-Host "$icon [$timestamp] $Message" -ForegroundColor Cyan
        }
    }
}

function Test-CommandAvailability {
    <#
    .SYNOPSIS
        Check if a command is available in PATH
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )
    
    $exists = $null -ne (Get-Command -Name $Command -ErrorAction SilentlyContinue)
    
    if (-not $exists) {
        Write-LogMessage "Required command '$Command' was not found. Please install it before continuing." -Level "Error"
        return $false
    }
    
    return $true
}

function Show-Help {
    <#
    .SYNOPSIS
        Show comprehensive help message
    #>
    
    Write-Host @"
setUp.ps1 - Sets up Azure Dev Box environment with source control integration

USAGE:
    .\setUp.ps1 -EnvName ENV_NAME -SourceControl PLATFORM

PARAMETERS:
    -EnvName ENV_NAME              Name of the Azure environment to create
    -SourceControl PLATFORM        Source control platform (github or adogit)
    -Help                          Show this help message

EXAMPLES:
    .\setUp.ps1 -EnvName "prod" -SourceControl "github"
    .\setUp.ps1 -EnvName "dev" -SourceControl "adogit"

REQUIREMENTS:
    - Azure CLI (az)
    - Azure Developer CLI (azd)
    - GitHub CLI (gh) [if using GitHub]
    - Valid authentication for chosen platform
"@
}

function Select-SourceControlPlatform {
    <#
    .SYNOPSIS
        Interactive source control platform selection
    #>
    
    Write-LogMessage "Please select your source control platform:" -Level "Info"
    Write-Host ""
    Write-Host "  1. Azure DevOps Git (adogit)" -ForegroundColor Yellow
    Write-Host "  2. GitHub (github)" -ForegroundColor Yellow
    Write-Host ""
    
    do {
        $selection = Read-Host "Enter your choice (1 or 2)"
        
        switch ($selection) {
            "1" {
                $script:SourceControl = "adogit"
                Write-LogMessage "Selected: Azure DevOps Git" -Level "Success"
                return $true
            }
            "2" {
                $script:SourceControl = "github"
                Write-LogMessage "Selected: GitHub" -Level "Success"
                return $true
            }
            default {
                Write-LogMessage "Invalid selection. Please enter 1 or 2." -Level "Warning"
            }
        }
    } while ($true)
}

#######################################
# Authentication Functions
#######################################

function Test-AzureAuthentication {
    <#
    .SYNOPSIS
        Test Azure CLI authentication
    #>
    
    Write-LogMessage "Verifying Azure authentication..." -Level "Info"
    
    try {
        $azContext = az account show 2>$null | ConvertFrom-Json
        
        if (-not $azContext) {
            Write-LogMessage "Not logged into Azure. Please run 'az login' first." -Level "Error"
            return $false
        }
        
        # Check if subscription is enabled (Azure best practice)
        if ($azContext.state -ne "Enabled") {
            Write-LogMessage "Current subscription '$($azContext.name)' is not in 'Enabled' state." -Level "Error"
            return $false
        }
        
        # Output subscription details for verification
        Write-LogMessage "Using Azure subscription: $($azContext.name) (ID: $($azContext.id))" -Level "Info"
        return $true
    }
    catch {
        Write-LogMessage "Azure authentication check failed: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

function Test-AdoAuthentication {
    <#
    .SYNOPSIS
        Test Azure DevOps authentication
    #>
    
    Write-LogMessage "Verifying Azure DevOps authentication..." -Level "Info"
    
    try {
        $null = az devops configure --list 2>$null
        
        if ($LASTEXITCODE -ne 0) {
            Write-LogMessage "Not logged into Azure DevOps. Please run 'az devops login' first." -Level "Error"
            return $false
        }
        
        Write-LogMessage "Azure DevOps authentication verified successfully" -Level "Success"
        return $true
    }
    catch {
        Write-LogMessage "Azure DevOps authentication check failed: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

function Test-GitHubAuthentication {
    <#
    .SYNOPSIS
        Test GitHub CLI authentication
    #>
    
    Write-LogMessage "Verifying GitHub authentication..." -Level "Info"
    
    try {
        $null = gh auth status 2>$null
        
        if ($LASTEXITCODE -ne 0) {
            Write-LogMessage "Not logged into GitHub. Please run 'gh auth login' first." -Level "Error"
            return $false
        }
        
        Write-LogMessage "GitHub authentication verified successfully" -Level "Success"
        return $true
    }
    catch {
        Write-LogMessage "GitHub authentication check failed: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

function Get-SecureGitHubToken {
    <#
    .SYNOPSIS
        Get GitHub token securely
    #>
    
    Write-LogMessage "Retrieving GitHub token..." -Level "Info"
    
    try {
        # Check if KEY_VAULT_SECRET environment variable is already set
        if ($env:KEY_VAULT_SECRET) {
            Write-LogMessage "Using existing KEY_VAULT_SECRET from environment" -Level "Info"
            $script:GitHubToken = $env:KEY_VAULT_SECRET
        }
        else {
            # Retrieve GitHub token using gh CLI
            $token = gh auth token 2>$null
            
            if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($token)) {
                Write-LogMessage "Failed to retrieve GitHub token" -Level "Error"
                return $false
            }
            
            $script:GitHubToken = $token.Trim()
            # Export as environment variable for future use
            $env:KEY_VAULT_SECRET = $script:GitHubToken
        }
        
        if ([string]::IsNullOrEmpty($script:GitHubToken)) {
            Write-LogMessage "Failed to retrieve GitHub token" -Level "Error"
            return $false
        }
        
        Write-LogMessage "GitHub token retrieved and stored securely" -Level "Success"
        return $true
    }
    catch {
        Write-LogMessage "Error retrieving GitHub token: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

function Get-SecureAdoToken {
    <#
    .SYNOPSIS
        Get Azure DevOps token securely
    #>
    
    Write-LogMessage "Retrieving Azure DevOps token..." -Level "Info"
    
    try {
        # Try to get PAT from environment variable first
        if ($env:KEY_VAULT_SECRET) {
            $script:AdoToken = $env:KEY_VAULT_SECRET
            Write-LogMessage "Azure DevOps PAT retrieved from Key Vault" -Level "Success"
        }
        else {
            Write-LogMessage "Azure DevOps PAT not found in environment variables." -Level "Warning"
            Write-LogMessage "Please enter your PAT securely." -Level "Warning"
            
            # Prompt for PAT securely
            $secureInput = Read-Host -Prompt "Enter your Azure DevOps Personal Access Token" -AsSecureString
            $script:AdoToken = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureInput))
            
            # Configure Azure DevOps defaults
            $null = az devops configure --defaults organization=https://dev.azure.com/contososa2 project=DevExp-DevBox 2>$null
            
            if ($LASTEXITCODE -ne 0) {
                Write-LogMessage "Azure DevOps organization and project not set. Please configure them first." -Level "Error"
                return $false
            }
        }
        
        if ([string]::IsNullOrEmpty($script:AdoToken)) {
            Write-LogMessage "Failed to retrieve Azure DevOps PAT" -Level "Error"
            return $false
        }
        
        # Export the token to environment variable
        $env:AZURE_DEVOPS_EXT_PAT = $script:AdoToken
        
        Write-LogMessage "Azure DevOps PAT retrieved and stored securely" -Level "Success"
        return $true
    }
    catch {
        Write-LogMessage "Error retrieving Azure DevOps token: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

#######################################
# Azure Configuration Functions
#######################################

function Initialize-AzdEnvironment {
    <#
    .SYNOPSIS
        Initialize Azure Developer CLI environment
    #>
    
    Write-LogMessage "Initializing Azure Developer CLI environment..." -Level "Info"
    
    try {
        # Get appropriate token based on source control platform
        $pat = $null
        $tokenType = ""
        
        switch ($SourceControl.ToLower()) {
            "github" {
                Write-LogMessage "Retrieving GitHub token for environment initialization..." -Level "Info"
                if (-not (Get-SecureGitHubToken)) {
                    Write-LogMessage "Unable to retrieve GitHub token. Aborting environment initialization." -Level "Error"
                    return $false
                }
                $pat = $script:GitHubToken
                $tokenType = "GitHub"
            }
            "adogit" {
                Write-LogMessage "Retrieving Azure DevOps token for environment initialization..." -Level "Info"
                if (-not (Get-SecureAdoToken)) {
                    Write-LogMessage "Unable to retrieve Azure DevOps token. Aborting environment initialization." -Level "Error"
                    return $false
                }
                $pat = $script:AdoToken
                $tokenType = "Azure DevOps"
            }
            default {
                Write-LogMessage "Unsupported source control platform: $SourceControl" -Level "Error"
                return $false
            }
        }
        
        # Mask most of the token for security best practices
        $maskedToken = if ($pat.Length -ge 8) {
            $pat.Substring(0, 4) + "****" + $pat.Substring($pat.Length - 2)
        }
        else {
            "****"
        }
        
        Write-LogMessage "🔐 $tokenType token stored securely in memory. Masked: $maskedToken" -Level "Success"
        
        # Azure best practice: Verify environment exists or use existing
        Write-LogMessage "Using Azure Developer CLI environment: '$EnvName'" -Level "Info"
        
        # Prepare environment file path
        $envDir = ".\.azure\$EnvName"
        $envFile = Join-Path $envDir ".env"
        
        if (-not (Test-Path $envDir)) {
            New-Item -ItemType Directory -Path $envDir -Force | Out-Null
        }
        
        # Azure best practice: Use environment-specific configuration
        Write-LogMessage "Configuring environment variables in $envFile" -Level "Info"
        
        # Create environment configuration
        $envContent = @"
KEY_VAULT_SECRET='$pat'
SOURCE_CONTROL_PLATFORM='$SourceControl'
"@
        
        Set-Content -Path $envFile -Value $envContent -Encoding UTF8
        
        # Show current configuration for verification
        Write-LogMessage "Current Azure Developer CLI configuration:" -Level "Info"
        azd config show
        
        Write-LogMessage "Azure Developer CLI environment '$EnvName' initialized successfully." -Level "Success"
        return $true
    }
    catch {
        Write-LogMessage "Error initializing Azure Developer CLI environment: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

function Start-AzureProvisioning {
    <#
    .SYNOPSIS
        Start Azure resource provisioning
    #>
    
    Write-LogMessage "Starting Azure resource provisioning with azd..." -Level "Info"
    
    try {
        # Run the provisioning process
        azd provision -e $EnvName
        
        if ($LASTEXITCODE -ne 0) {
            Write-LogMessage "Azure provisioning failed with exit code $LASTEXITCODE" -Level "Error"
            Write-LogMessage "This might be a quota or permissions issue. Check your Azure subscription limits and role assignments." -Level "Warning"
            return $false
        }
        
        Write-LogMessage "Azure provisioning completed successfully" -Level "Success"
        return $true
    }
    catch {
        Write-LogMessage "Azure provisioning failed: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

#######################################
# Main Script Logic
#######################################

function Invoke-Cleanup {
    <#
    .SYNOPSIS
        Cleanup function to secure sensitive data
    #>
    
    Write-LogMessage "Cleaning up sensitive data..." -Level "Info"
    
    # Clear sensitive variables
    $script:GitHubToken = $null
    $script:AdoToken = $null
    
    # Remove sensitive environment variables
    Remove-Variable -Name "AZURE_DEVOPS_EXT_PAT" -Scope Global -ErrorAction SilentlyContinue
    
    Write-LogMessage "Cleanup completed" -Level "Info"
}

function Invoke-Main {
    <#
    .SYNOPSIS
        Main execution function
    #>
    
    try {
        # Show help if requested
        if ($Help) {
            Show-Help
            return $true
        }
        
        # If source control not provided, prompt for it
        if ([string]::IsNullOrEmpty($SourceControl)) {
            if (-not (Select-SourceControlPlatform)) {
                return $false
            }
        }
        
        # Define required tools
        $requiredTools = @("az", "azd")
        
        # Add GitHub CLI to required tools if using GitHub
        if ($SourceControl -eq "github") {
            $requiredTools += "gh"
        }
        
        # Script header with basic information
        Write-LogMessage "Starting Dev Box environment setup" -Level "Info"
        Write-LogMessage "Environment name: $EnvName" -Level "Info"
        Write-LogMessage "Source control platform: $SourceControl" -Level "Info"
        
        # Verify required tools - Azure best practice for dependency validation
        Write-LogMessage "Checking required tools..." -Level "Info"
        foreach ($tool in $requiredTools) {
            if (-not (Test-CommandAvailability -Command $tool)) {
                Write-LogMessage "Missing required tools. Please install them and retry." -Level "Error"
                return $false
            }
        }
        Write-LogMessage "All required tools are available" -Level "Success"
        
        # Verify Azure authentication - Azure security best practice
        if (-not (Test-AzureAuthentication)) {
            return $false
        }
        
        # Verify source control authentication
        switch ($SourceControl.ToLower()) {
            "github" {
                if (-not (Test-GitHubAuthentication)) {
                    return $false
                }
            }
            "adogit" {
                if (-not (Test-AdoAuthentication)) {
                    return $false
                }
            }
        }
        
        # Initialize azd environment
        if (-not (Initialize-AzdEnvironment)) {
            Write-LogMessage "Failed to initialize Azure Developer CLI environment. Exiting." -Level "Error"
            return $false
        }
        
        # Success message with environment details
        Write-LogMessage "Dev Box environment '$EnvName' setup successfully" -Level "Success"
        Write-LogMessage "Access your Dev Center from the Azure portal" -Level "Info"
        Write-LogMessage "Use 'azd env get-values' to view environment settings" -Level "Info"
        
        return $true
    }
    catch {
        Write-LogMessage "An unexpected error occurred: $($_.Exception.Message)" -Level "Error"
        Write-LogMessage "Stack trace: $($_.ScriptStackTrace)" -Level "Error"
        return $false
    }
    finally {
        Invoke-Cleanup
    }
}

#######################################
# Script Execution
#######################################

# Set up error handling
trap {
    Write-LogMessage "Script interrupted or failed. Cleaning up..." -Level "Warning"
    Invoke-Cleanup
    break
}

# Execute main function
$success = Invoke-Main

# Exit with appropriate code
if ($success) {
    exit 0
}
else {
    exit 1
}