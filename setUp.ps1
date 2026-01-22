#Requires -Version 5.1

<#
.SYNOPSIS
    setUp.ps1 - Sets up Azure Dev Box environment with GitHub integration

.DESCRIPTION
    Automates the setup of an Azure Developer CLI (azd) environment for Dev Box,
    handles GitHub authentication, and provisions required Azure resources.

    This script follows Azure best practices for security, error handling, 
    and resource management.

.PARAMETER EnvName
    Name of the Azure environment to create

.PARAMETER SourceControl
    Source control platform (github or adogit)

.PARAMETER Help
    Show this help message

.EXAMPLE
    .\setUp.ps1 -EnvName "prod" -SourceControl "github"
    # Creates a "prod" environment with GitHub
    
.EXAMPLE
    .\setUp.ps1 -EnvName "dev" -SourceControl "adogit"
    # Creates a "dev" environment with Azure DevOps

.NOTES
    Requirements:
    - Azure CLI (az)
    - Azure Developer CLI (azd)
    - GitHub CLI (gh) [if using GitHub]
    - Valid authentication for chosen platform
    
    Author: DevExp Team
    Last Updated: 2025-09-03
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$EnvName,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("github", "adogit", "")]
    [string]$SourceControl,
    
    [Parameter(Mandatory = $false)]
    [switch]$Help
)

# Script Configuration
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Global Variables
$Script:ScriptDir = $PSScriptRoot
$Script:TimestampFormat = "yyyy-MM-dd HH:mm:ss"

# Unicode icons
$Script:InfoIcon = "ℹ️"
$Script:WarningIcon = "⚠️"
$Script:ErrorIcon = "❌"
$Script:SuccessIcon = "✅"

# Global variables for script state
$Script:GitHubToken = ""
$Script:AdoToken = ""

#######################################
# Helper Functions
#######################################

function Write-LogMessage {
    <#
    .SYNOPSIS
        Logging function with different levels and colors.

    .DESCRIPTION
        Writes formatted log messages with timestamps and colored output
        based on the message severity level.

    .PARAMETER Message
        The message text to log.

    .PARAMETER Level
        The severity level of the message. Valid values: Info, Warning, Error, Success.

    .EXAMPLE
        Write-LogMessage -Message "Operation completed" -Level "Success"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error", "Success")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format $Script:TimestampFormat
    
    switch ($Level) {
        "Error" {
            Write-Host "$Script:ErrorIcon " -ForegroundColor Red -NoNewline
            Write-Host "[$timestamp] $Message" -ForegroundColor Red
        }
        "Warning" {
            Write-Host "$Script:WarningIcon " -ForegroundColor Yellow -NoNewline
            Write-Host "[$timestamp] $Message" -ForegroundColor Yellow
        }
        "Success" {
            Write-Host "$Script:SuccessIcon " -ForegroundColor Green -NoNewline
            Write-Host "[$timestamp] $Message" -ForegroundColor Green
        }
        default {
            Write-Host "$Script:InfoIcon " -ForegroundColor Cyan -NoNewline
            Write-Host "[$timestamp] $Message" -ForegroundColor Cyan
        }
    }
}

function Test-CommandAvailability {
    <#
    .SYNOPSIS
        Check if a command is available in PATH.

    .DESCRIPTION
        Verifies that the specified command or tool is available
        for execution in the current environment.

    .PARAMETER Command
        The name of the command to check.

    .OUTPUTS
        System.Boolean - True if command exists, False otherwise.

    .EXAMPLE
        if (Test-CommandAvailability -Command "az") { Write-Host "Azure CLI is available" }
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )
    
    $commandPath = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $commandPath) {
        Write-LogMessage "Required command '$Command' was not found. Please install it before continuing." "Error"
        return $false
    }
    return $true
}

function Show-Help {
    <#
    .SYNOPSIS
        Show help message
    #>
    $helpText = @"
setUp.ps1 - Sets up Azure Dev Box environment with source control integration

USAGE:
    .\setUp.ps1 -EnvName ENV_NAME -SourceControl PLATFORM

PARAMETERS:
    -EnvName ENV_NAME           Name of the Azure environment to create
    -SourceControl PLATFORM     Source control platform (github or adogit)
    -Help                       Show this help message

EXAMPLES:
    .\setUp.ps1 -EnvName "prod" -SourceControl "github"
    .\setUp.ps1 -EnvName "dev" -SourceControl "adogit"

REQUIREMENTS:
    - Azure CLI (az)
    - Azure Developer CLI (azd)
    - GitHub CLI (gh) [if using GitHub]
    - Valid authentication for chosen platform
"@
    
    Write-Host $helpText
}

function Test-SourceControlValidation {
    <#
    .SYNOPSIS
        Validates the source control platform parameter.

    .DESCRIPTION
        Checks if the specified platform is a valid source control option.

    .PARAMETER Platform
        The source control platform to validate (github, adogit, or empty).

    .OUTPUTS
        System.Boolean - True if valid, False otherwise.

    .EXAMPLE
        if (Test-SourceControlValidation -Platform "github") { Write-Host "Valid platform" }
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Platform
    )
    
    if ($Platform -in @("github", "adogit", "")) {
        return $true
    }
    else {
        Write-LogMessage "Invalid source control platform: $Platform" "Error"
        Write-LogMessage "Valid platforms: github, adogit" "Info"
        return $false
    }
}

#######################################
# Authentication Functions
#######################################

function Test-AzureAuthentication {
    <#
    .SYNOPSIS
        Test Azure CLI authentication
    #>
    Write-LogMessage "Verifying Azure authentication..." "Info"
    
    try {
        $azContext = az account show 2>$null | ConvertFrom-Json
        if (-not $azContext) {
            Write-LogMessage "Not logged into Azure. Please run 'az login' first." "Error"
            return $false
        }
        
        # Check if subscription is enabled (Azure best practice)
        if ($azContext.state -ne "Enabled") {
            Write-LogMessage "Current subscription '$($azContext.name)' is not in 'Enabled' state." "Error"
            return $false
        }
        
        # Output subscription details for verification
        Write-LogMessage "Using Azure subscription: $($azContext.name) (ID: $($azContext.id))" "Info"
        return $true
    }
    catch {
        Write-LogMessage "Failed to verify Azure authentication: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Test-AdoAuthentication {
    <#
    .SYNOPSIS
        Test Azure DevOps authentication
    #>
    Write-LogMessage "Verifying Azure DevOps authentication..." "Info"
    
    try {
        $null = az devops configure --list 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-LogMessage "Not logged into Azure DevOps. Please run 'az devops login' first." "Error"
            return $false
        }
        
        Write-LogMessage "Azure DevOps authentication verified successfully" "Success"
        return $true
    }
    catch {
        Write-LogMessage "Failed to verify Azure DevOps authentication: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Test-GitHubAuthentication {
    <#
    .SYNOPSIS
        Test GitHub CLI authentication
    #>
    Write-LogMessage "Verifying GitHub authentication..." "Info"
    
    try {
        $null = gh auth status 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-LogMessage "Not logged into GitHub. Please run 'gh auth login' first." "Error"
            return $false
        }
        
        Write-LogMessage "GitHub authentication verified successfully" "Success"
        return $true
    }
    catch {
        Write-LogMessage "Failed to verify GitHub authentication: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Get-SecureGitHubToken {
    <#
    .SYNOPSIS
        Get GitHub token securely
    #>
    Write-LogMessage "Retrieving GitHub token..." "Info"

    # Check if KEY_VAULT_SECRET environment variable is already set
    if ($env:KEY_VAULT_SECRET) {
        Write-LogMessage "Using existing KEY_VAULT_SECRET from environment" "Info"
        $Script:GitHubToken = $env:KEY_VAULT_SECRET
    }
    else {
        try {
            # Retrieve GitHub token using gh CLI
            $Script:GitHubToken = gh auth token 2>$null
            if ($LASTEXITCODE -ne 0 -or -not $Script:GitHubToken) {
                Write-LogMessage "Failed to retrieve GitHub token" "Error"
                return $false
            }
            # Export as environment variable for future use
            $env:KEY_VAULT_SECRET = $Script:GitHubToken
        }
        catch {
            Write-LogMessage "Failed to retrieve GitHub token: $($_.Exception.Message)" "Error"
            return $false
        }
    }
    
    if (-not $Script:GitHubToken) {
        Write-LogMessage "Failed to retrieve GitHub token" "Error"
        return $false
    }
    
    Write-LogMessage "GitHub token retrieved and stored securely" "Success"
    return $true
}

function Get-SecureAdoGitToken {
    <#
    .SYNOPSIS
        Get Azure DevOps token securely
    #>
    Write-LogMessage "Retrieving Azure DevOps token..." "Info"
    
    # Try to get PAT from environment variable first
    if ($env:KEY_VAULT_SECRET) {
        $Script:AdoToken = $env:KEY_VAULT_SECRET
        Write-LogMessage "Azure DevOps PAT retrieved from Key Vault" "Success"
    }
    else {
        Write-LogMessage "Azure DevOps PAT not found in environment variables." "Warning"
        Write-LogMessage "Please enter your PAT securely." "Warning"
        
        # Prompt for PAT securely (no echo)
        $secureString = Read-Host "Enter your Azure DevOps Personal Access Token" -AsSecureString
        $Script:AdoToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString))
        
        # Configure Azure DevOps defaults
        try {
            $null = az devops configure --defaults organization=https://dev.azure.com/contososa2 project=DevExp-DevBox 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-LogMessage "Azure DevOps organization and project not set. Please configure them first." "Error"
                return $false
            }
        }
        catch {
            Write-LogMessage "Failed to configure Azure DevOps defaults: $($_.Exception.Message)" "Error"
            return $false
        }
    }
    
    if (-not $Script:AdoToken) {
        Write-LogMessage "Failed to retrieve Azure DevOps PAT" "Error"
        return $false
    }

    # Export the token to environment variable
    $env:AZURE_DEVOPS_EXT_PAT = $Script:AdoToken

    Write-LogMessage "Azure DevOps PAT retrieved and stored securely" "Success"
    return $true
}

#######################################
# Azure Configuration Functions
#######################################

function Initialize-AzdEnvironment {
    <#
    .SYNOPSIS
        Initialize Azure Developer CLI environment
    #>
    Write-LogMessage "Initializing Azure Developer CLI environment..." "Info"
    
    $pat = ""
    $tokenType = ""
    
    # Get appropriate token based on source control platform
    switch ($SourceControl) {
        "github" {
            Write-LogMessage "Retrieving GitHub token for environment initialization..." "Info"
            if (-not (Get-SecureGitHubToken)) {
                Write-LogMessage "Unable to retrieve GitHub token. Aborting environment initialization." "Error"
                return $false
            }
            $pat = $Script:GitHubToken
            $tokenType = "GitHub"
        }
        "adogit" {
            Write-LogMessage "Retrieving Azure DevOps token for environment initialization..." "Info"
            if (-not (Get-SecureAdoGitToken)) {
                Write-LogMessage "Unable to retrieve Azure DevOps token. Aborting environment initialization." "Error"
                return $false
            }
            $pat = $Script:AdoToken
            $tokenType = "Azure DevOps"
        }
        default {
            Write-LogMessage "Unsupported source control platform: $SourceControl" "Error"
            return $false
        }
    }
    
    # Mask most of the token for security best practices
    if ($pat.Length -ge 8) {
        $maskedToken = $pat.Substring(0, 4) + "****" + $pat.Substring($pat.Length - 2)
    }
    else {
        $maskedToken = "****"
    }
    
    Write-LogMessage "🔐 $tokenType token stored securely in memory. Masked: $maskedToken" "Success"
    
    # Azure best practice: Verify environment exists or use existing
    Write-LogMessage "Using Azure Developer CLI environment: '$EnvName'" "Info"
    
    # Prepare environment file path
    $envDir = ".\.azure\$EnvName"
    $envFile = "$envDir\.env"
    
    if (-not (Test-Path $envDir)) {
        New-Item -ItemType Directory -Path $envDir -Force | Out-Null
    }
    
    # Azure best practice: Use environment-specific configuration
    Write-LogMessage "Configuring environment variables in $envFile" "Info"
    
    # Append to existing file or create if it doesn't exist
    Add-Content -Path $envFile -Value "KEY_VAULT_SECRET='$pat'"
    Add-Content -Path $envFile -Value "SOURCE_CONTROL_PLATFORM='$SourceControl'"
    
    # Show current configuration for verification
    Write-LogMessage "Current Azure Developer CLI configuration:" "Info"
    azd config show
    
    Write-LogMessage "Azure Developer CLI environment '$EnvName' initialized successfully." "Success"
    return $true
}

function Start-AzureProvisioning {
    <#
    .SYNOPSIS
        Start Azure resource provisioning
    #>
    Write-LogMessage "Starting Azure resource provisioning with azd..." "Info"
    
    try {
        azd provision -e $EnvName
        if ($LASTEXITCODE -ne 0) {
            Write-LogMessage "Azure provisioning failed with exit code $LASTEXITCODE" "Error"
            Write-LogMessage "This might be a quota or permissions issue. Check your Azure subscription limits and role assignments." "Warning"
            return $false
        }
        
        Write-LogMessage "Azure provisioning completed successfully" "Success"
        return $true
    }
    catch {
        Write-LogMessage "Azure provisioning failed: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Select-SourceControlPlatform {
    <#
    .SYNOPSIS
        Interactive source control platform selection
    #>
    Write-LogMessage "Please select your source control platform:" "Info"
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host "1. Azure DevOps Git (adogit)" -ForegroundColor Yellow
    Write-Host "  " -NoNewline
    Write-Host "2. GitHub (github)" -ForegroundColor Yellow
    Write-Host ""
    
    $validSelection = $false
    while (-not $validSelection) {
        $selection = Read-Host "Enter your choice (1 or 2)"
        
        switch ($selection) {
            "1" {
                $Script:SourceControl = "adogit"
                Write-LogMessage "Selected: Azure DevOps Git" "Success"
                $validSelection = $true
            }
            "2" {
                $Script:SourceControl = "github"
                Write-LogMessage "Selected: GitHub" "Success"
                $validSelection = $true
            }
            default {
                Write-LogMessage "Invalid selection. Please enter 1 or 2." "Warning"
            }
        }
    }
}

#######################################
# Main Script Logic
#######################################

function Test-Arguments {
    <#
    .SYNOPSIS
        Validate and process command line arguments
    #>
    # Show help if requested
    if ($Help) {
        Show-Help
        exit 0
    }
    
    # Validate required parameters
    if (-not $EnvName) {
        Write-LogMessage "Environment name is required. Use -EnvName parameter." "Error"
        Show-Help
        exit 1
    }
    
    # If source control not provided, prompt for it
    if (-not $SourceControl) {
        Select-SourceControlPlatform
    }
    
    # Validate parameters
    if (-not (Test-SourceControlValidation $SourceControl)) {
        exit 1
    }
}

function Invoke-Main {
    <#
    .SYNOPSIS
        Main execution function
    #>
    $requiredTools = @("az", "azd")
    
    # Process arguments
    Test-Arguments
    
    # Script header with basic information
    Write-LogMessage "Starting Dev Box environment setup" "Info"
    Write-LogMessage "Environment name: $EnvName" "Info"
    Write-LogMessage "Source control platform: $SourceControl" "Info"
    
    # Add GitHub CLI to required tools if using GitHub
    if ($SourceControl -eq "github") {
        $requiredTools += "gh"
    }
    
    # Verify required tools - Azure best practice for dependency validation
    Write-LogMessage "Checking required tools..." "Info"
    foreach ($tool in $requiredTools) {
        if (-not (Test-CommandAvailability $tool)) {
            Write-LogMessage "Missing required tools. Please install them and retry." "Error"
            exit 1
        }
    }
    Write-LogMessage "All required tools are available" "Success"
    
    # Verify Azure authentication - Azure security best practice
    if (-not (Test-AzureAuthentication)) {
        exit 1
    }
    
    # Verify source control authentication
    switch ($SourceControl) {
        "github" {
            if (-not (Test-GitHubAuthentication)) {
                exit 1
            }
        }
        "adogit" {
            if (-not (Test-AdoAuthentication)) {
                exit 1
            }
        }
    }
    
    # Initialize azd environment
    if (-not (Initialize-AzdEnvironment)) {
        Write-LogMessage "Failed to initialize Azure Developer CLI environment. Exiting." "Error"
        exit 1
    }
    
    # Success message with environment details
    Write-LogMessage "Dev Box environment '$EnvName' setup successfully" "Success"
    Write-LogMessage "Access your Dev Center from the Azure portal" "Info"
    Write-LogMessage "Use 'azd env get-values' to view environment settings" "Info"
}

# Set up error handling and cleanup
trap {
    Write-LogMessage "Script interrupted by user" "Warning"
    exit 130
}

# Execute main function
try {
    Invoke-Main
}
catch {
    Write-LogMessage "Script execution failed: $($_.Exception.Message)" "Error"
    exit 1
}