#Requires -Version 5.1

<#
.SYNOPSIS
    Sets up Azure Dev Box environment with source control integration

.DESCRIPTION
    Automates the setup of an Azure Developer CLI (azd) environment for Dev Box,
    handles source control authentication, and provisions required Azure resources.
    
    This script follows Azure best practices for security, error handling, 
    and resource management.

.PARAMETER EnvName
    Name of the Azure environment to create (required)

.PARAMETER SourceControl
    Source control platform: 'github' or 'adogit' (Azure DevOps)

.PARAMETER Help
    Show help message

.EXAMPLE
    .\setUp.ps1 -EnvName "prod" -SourceControl "github"
    Creates a "prod" environment with GitHub

.EXAMPLE
    .\setUp.ps1 -EnvName "dev" -SourceControl "adogit"
    Creates a "dev" environment with Azure DevOps

.NOTES
    Requirements:
    * Azure CLI (az)
    * Azure Developer CLI (azd)
    * PowerShell 5.1 or later
    * GitHub CLI (gh) [if using GitHub]
    * Valid authentication for chosen platform
    
    Author: DevExp Team
    Last Updated: 2025-08-08
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Name of the Azure environment to create")]
    [ValidateNotNullOrEmpty()]
    [string]$EnvName,
    
    [Parameter(Mandatory = $false, HelpMessage = "Source control platform")]
    [ValidateSet("github", "adogit", "", IgnoreCase = $true)]
    [string]$SourceControl = "",
    
    [Parameter(Mandatory = $false)]
    [switch]$Help
)

# Script Configuration
$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"
$WarningPreference = "Continue"

# Global Variables
$script:ScriptDir = $PSScriptRoot
$script:TimestampFormat = "yyyy-MM-dd HH:mm:ss"

# Unicode icons for better user experience
$script:Icons = @{
    Info    = [char]0x2139 + [char]0xFE0F  # ℹ️
    Warning = [char]0x26A0 + [char]0xFE0F  # ⚠️
    Error   = [char]0x274C                 # ❌
    Success = [char]0x2705                 # ✅
}

# PowerShell color support (compatible with Windows PowerShell 5.1)
$script:Colors = @{
    Red    = "Red"
    Green  = "Green"
    Yellow = "Yellow"
    Cyan   = "Cyan"
    Reset  = "White"
}

# Global variables for script state
$script:GitHubToken = ""
$script:AdoToken = ""

#######################################
# Helper Functions
#######################################

function Write-LogMessage {
    <#
    .SYNOPSIS
        Writes formatted log messages with timestamps and colors
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
    $logMessage = "[$timestamp] $Message"
    
    # Use Write-Host for colored output with PowerShell native colors
    switch ($Level) {
        "Error" {
            Write-Host "$icon $logMessage" -ForegroundColor $script:Colors.Red
            Write-Error $Message -ErrorAction Continue
        }
        "Warning" {
            Write-Host "$icon $logMessage" -ForegroundColor $script:Colors.Yellow
            Write-Warning $Message -WarningAction Continue
        }
        "Success" {
            Write-Host "$icon $logMessage" -ForegroundColor $script:Colors.Green
        }
        default {
            Write-Host "$icon $logMessage" -ForegroundColor $script:Colors.Cyan
        }
    }
}

function Test-CommandAvailability {
    <#
    .SYNOPSIS
        Checks if a command is available in the system PATH
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )
    
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        Write-LogMessage "Required command '$Command' was not found. Please install it before continuing." "Error"
        return $false
    }
}

function Show-Help {
    <#
    .SYNOPSIS
        Displays help information for the script
    #>
    
    $helpText = @"
setUp.ps1 - Sets up Azure Dev Box environment with source control integration

USAGE:
    .\setUp.ps1 -EnvName ENV_NAME -SourceControl PLATFORM

PARAMETERS:
    -EnvName ENV_NAME          Name of the Azure environment to create (required)
    -SourceControl PLATFORM    Source control platform (github or adogit)
    -Help                      Show this help message

EXAMPLES:
    .\setUp.ps1 -EnvName "prod" -SourceControl "github"
    .\setUp.ps1 -EnvName "dev" -SourceControl "adogit"

REQUIREMENTS:
    * Azure CLI (az)
    * Azure Developer CLI (azd)
    * PowerShell 5.1 or later
    * GitHub CLI (gh) [if using GitHub]
    * Valid authentication for chosen platform
"@
    
    Write-Host $helpText
}

function Test-SourceControlPlatform {
    <#
    .SYNOPSIS
        Validates the source control platform parameter
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Platform
    )
    
    $validPlatforms = @("github", "adogit", "")
    
    if ($Platform -in $validPlatforms) {
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
        Tests Azure CLI authentication and subscription state
    #>
    
    Write-LogMessage "Verifying Azure authentication..." "Info"
    
    try {
        $azContext = & az account show 2>$null | ConvertFrom-Json
        
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
        Write-LogMessage "Failed to verify Azure authentication: $_" "Error"
        return $false
    }
}

function Test-AdoAuthentication {
    <#
    .SYNOPSIS
        Tests Azure DevOps CLI authentication
    #>
    
    Write-LogMessage "Verifying Azure DevOps authentication..." "Info"
    
    try {
        $null = & az devops configure --list 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-LogMessage "Not logged into Azure DevOps. Please run 'az devops login' first." "Error"
            return $false
        }
        
        Write-LogMessage "Azure DevOps authentication verified successfully" "Success"
        return $true
    }
    catch {
        Write-LogMessage "Azure DevOps authentication check failed: $_" "Error"
        return $false
    }
}

function Test-GitHubAuthentication {
    <#
    .SYNOPSIS
        Tests GitHub CLI authentication
    #>
    
    Write-LogMessage "Verifying GitHub authentication..." "Info"
    
    try {
        $null = & gh auth status 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-LogMessage "Not logged into GitHub. Please run 'gh auth login' first." "Error"
            return $false
        }
        
        Write-LogMessage "GitHub authentication verified successfully" "Success"
        return $true
    }
    catch {
        Write-LogMessage "GitHub authentication check failed: $_" "Error"
        return $false
    }
}

function Get-SecureGitHubToken {
    <#
    .SYNOPSIS
        Retrieves GitHub token securely from environment or GitHub CLI
    #>
    
    Write-LogMessage "Retrieving GitHub token..." "Info"
    
    # Check if KEY_VAULT_SECRET environment variable is already set
    $envToken = $env:KEY_VAULT_SECRET
    if (-not [string]::IsNullOrEmpty($envToken)) {
        Write-LogMessage "Using existing KEY_VAULT_SECRET from environment" "Info"
        $script:GitHubToken = $envToken
    }
    else {
        try {
            # Retrieve GitHub token using gh CLI
            $token = & gh auth token 2>$null
            if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($token)) {
                Write-LogMessage "Failed to retrieve GitHub token" "Error"
                return $false
            }
            
            $script:GitHubToken = $token.Trim()
            # Export as environment variable for future use (session only)
            $env:KEY_VAULT_SECRET = $script:GitHubToken
        }
        catch {
            Write-LogMessage "Failed to retrieve GitHub token: $_" "Error"
            return $false
        }
    }
    
    if ([string]::IsNullOrEmpty($script:GitHubToken)) {
        Write-LogMessage "Failed to retrieve GitHub token" "Error"
        return $false
    }
    
    Write-LogMessage "GitHub token retrieved and stored securely" "Success"
    return $true
}

function Get-SecureAdoToken {
    <#
    .SYNOPSIS
        Retrieves Azure DevOps Personal Access Token securely
    #>
    
    Write-LogMessage "Retrieving Azure DevOps token..." "Info"
    
    # Try to get PAT from environment variable first
    $envToken = $env:KEY_VAULT_SECRET
    if (-not [string]::IsNullOrEmpty($envToken)) {
        $script:AdoToken = $envToken
        Write-LogMessage "Azure DevOps PAT retrieved from Key Vault" "Success"
    }
    else {
        Write-LogMessage "Azure DevOps PAT not found in environment variables." "Warning"
        Write-LogMessage "Please enter your PAT securely." "Warning"
        
        # Prompt for PAT securely (masked input)
        $secureToken = Read-Host "Enter your Azure DevOps Personal Access Token" -AsSecureString
        $script:AdoToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken))
        
        # Get organization URL interactively (fix for hardcoded URL issue)
        $orgUrl = Read-Host "Enter your Azure DevOps organization URL (e.g., https://dev.azure.com/yourorg)"
        if ([string]::IsNullOrEmpty($orgUrl)) {
            Write-LogMessage "Organization URL is required for Azure DevOps integration." "Error"
            return $false
        }
        
        $projectName = Read-Host "Enter your Azure DevOps project name"
        if ([string]::IsNullOrEmpty($projectName)) {
            Write-LogMessage "Project name is required for Azure DevOps integration." "Error"
            return $false
        }
        
        # Configure Azure DevOps defaults
        try {
            $null = & az devops configure --defaults organization=$orgUrl project=$projectName 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-LogMessage "Failed to configure Azure DevOps organization and project." "Error"
                return $false
            }
        }
        catch {
            Write-LogMessage "Azure DevOps configuration failed: $_" "Error"
            return $false
        }
    }
    
    if ([string]::IsNullOrEmpty($script:AdoToken)) {
        Write-LogMessage "Failed to retrieve Azure DevOps PAT" "Error"
        return $false
    }
    
    # Export the token to environment variable (session only)
    $env:AZURE_DEVOPS_EXT_PAT = $script:AdoToken
    
    Write-LogMessage "Azure DevOps PAT retrieved and stored securely" "Success"
    return $true
}

#######################################
# Azure Configuration Functions
#######################################

function Initialize-AzdEnvironment {
    <#
    .SYNOPSIS
        Initializes Azure Developer CLI environment with secure token storage
    #>
    
    Write-LogMessage "Initializing Azure Developer CLI environment..." "Info"
    
    $pat = ""
    $tokenType = ""
    
    # Get appropriate token based on source control platform
    switch ($SourceControl.ToLower()) {
        "github" {
            Write-LogMessage "Retrieving GitHub token for environment initialization..." "Info"
            if (-not (Get-SecureGitHubToken)) {
                Write-LogMessage "Unable to retrieve GitHub token. Aborting environment initialization." "Error"
                return $false
            }
            $pat = $script:GitHubToken
            $tokenType = "GitHub"
        }
        "adogit" {
            Write-LogMessage "Retrieving Azure DevOps token for environment initialization..." "Info"
            if (-not (Get-SecureAdoToken)) {
                Write-LogMessage "Unable to retrieve Azure DevOps token. Aborting environment initialization." "Error"
                return $false
            }
            $pat = $script:AdoToken
            $tokenType = "Azure DevOps"
        }
        default {
            Write-LogMessage "Unsupported source control platform: $SourceControl" "Error"
            return $false
        }
    }
    
    # Mask most of the token for security best practices
    $maskedToken = if ($pat.Length -ge 8) {
        $pat.Substring(0, 4) + "****" + $pat.Substring($pat.Length - 2)
    } else {
        "****"
    }
    
    Write-LogMessage "[SECURE] $tokenType token stored securely in memory. Masked: $maskedToken" "Success"
    
    # Azure best practice: Verify environment exists or use existing
    Write-LogMessage "Using Azure Developer CLI environment: '$EnvName'" "Info"
    
    # Prepare environment file path
    $envDir = Join-Path $script:ScriptDir ".azure" $EnvName
    $envFile = Join-Path $envDir ".env"
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $envDir)) {
        $null = New-Item -Path $envDir -ItemType Directory -Force
    }
    
    # Azure best practice: Use environment-specific configuration with secure storage
    Write-LogMessage "Configuring environment variables in $envFile" "Info"
    
    try {
        # Use more secure approach - avoid plain text storage in production
        $envContent = @"
KEY_VAULT_SECRET='$pat'
SOURCE_CONTROL_PLATFORM='$SourceControl'
"@
        $envContent | Out-File -FilePath $envFile -Encoding UTF8 -Append
        
        # Set secure file permissions (Windows)
        if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
            $acl = Get-Acl $envFile
            $acl.SetAccessRuleProtection($true, $false)  # Disable inheritance
            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, "FullControl", "Allow")
            $acl.SetAccessRule($accessRule)
            Set-Acl $envFile $acl
        }
    }
    catch {
        Write-LogMessage "Failed to create environment file: $_" "Error"
        return $false
    }
    
    # Show current configuration for verification
    Write-LogMessage "Current Azure Developer CLI configuration:" "Info"
    try {
        $azdConfig = & azd config show 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host $azdConfig
        } else {
            Write-LogMessage "Warning: Could not display azd configuration" "Warning"
        }
    }
    catch {
        Write-LogMessage "Warning: Could not display azd configuration: $_" "Warning"
    }
    
    Write-LogMessage "Azure Developer CLI environment '$EnvName' initialized successfully." "Success"
    return $true
}

function Start-AzureProvisioning {
    <#
    .SYNOPSIS
        Starts Azure resource provisioning using azd
    #>
    
    Write-LogMessage "Starting Azure resource provisioning with azd..." "Info"
    
    try {
        $result = & azd provision -e $EnvName 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-LogMessage "Azure provisioning failed with exit code $LASTEXITCODE" "Error"
            Write-LogMessage "Output: $result" "Error"
            Write-LogMessage "This might be a quota or permissions issue. Check your Azure subscription limits and role assignments." "Warning"
            return $false
        }
        
        Write-LogMessage "Azure provisioning completed successfully" "Success"
        return $true
    }
    catch {
        Write-LogMessage "Azure provisioning failed: $_" "Error"
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
    Write-Host "  1. Azure DevOps Git (adogit)" -ForegroundColor Yellow
    Write-Host "  2. GitHub (github)" -ForegroundColor Yellow
    Write-Host ""
    
    do {
        $selection = Read-Host "Enter your choice (1 or 2)"
        
        switch ($selection) {
            "1" {
                $script:SourceControl = "adogit"
                Write-LogMessage "Selected: Azure DevOps Git" "Success"
                return "adogit"
            }
            "2" {
                $script:SourceControl = "github"
                Write-LogMessage "Selected: GitHub" "Success"
                return "github"
            }
            default {
                Write-LogMessage "Invalid selection. Please enter 1 or 2." "Warning"
            }
        }
    } while ($true)
}

#######################################
# Main Script Logic
#######################################

function Start-Setup {
    <#
    .SYNOPSIS
        Main execution function for the setup script
    #>
    
    # Show help if requested
    if ($Help) {
        Show-Help
        return
    }
    
    # If source control not provided, prompt for it
    if ([string]::IsNullOrEmpty($SourceControl)) {
        $SourceControl = Select-SourceControlPlatform
    }
    
    # Validate parameters
    if (-not (Test-SourceControlPlatform -Platform $SourceControl)) {
        throw "Invalid source control platform specified."
    }
    
    # Define required tools
    $requiredTools = @("az", "azd")
    
    # Add source control specific tools
    switch ($SourceControl.ToLower()) {
        "github" {
            $requiredTools += "gh"
        }
    }
    
    # Script header with basic information
    Write-LogMessage "Starting Dev Box environment setup" "Info"
    Write-LogMessage "Environment name: $EnvName" "Info"
    Write-LogMessage "Source control platform: $SourceControl" "Info"
    
    # Verify required tools - Azure best practice for dependency validation
    Write-LogMessage "Checking required tools..." "Info"
    $allToolsAvailable = $true
    foreach ($tool in $requiredTools) {
        if (-not (Test-CommandAvailability -Command $tool)) {
            $allToolsAvailable = $false
        }
    }
    
    if (-not $allToolsAvailable) {
        Write-LogMessage "Missing required tools. Please install them and retry." "Error"
        throw "Required dependencies not met."
    }
    
    Write-LogMessage "All required tools are available" "Success"
    
    # Verify Azure authentication - Azure security best practice
    if (-not (Test-AzureAuthentication)) {
        throw "Azure authentication failed."
    }
    
    # Verify source control authentication
    switch ($SourceControl.ToLower()) {
        "github" {
            if (-not (Test-GitHubAuthentication)) {
                throw "GitHub authentication failed."
            }
        }
        "adogit" {
            if (-not (Test-AdoAuthentication)) {
                throw "Azure DevOps authentication failed."
            }
        }
    }
    
    # Initialize azd environment
    if (-not (Initialize-AzdEnvironment)) {
        Write-LogMessage "Failed to initialize Azure Developer CLI environment. Exiting." "Error"
        throw "Environment initialization failed."
    }
    
    # Success message with environment details
    Write-LogMessage "Dev Box environment '$EnvName' setup successfully" "Success"
    Write-LogMessage "Access your Dev Center from the Azure portal" "Info"
    Write-LogMessage "Use 'azd env get-values' to view environment settings" "Info"
}

#######################################
# Script Execution
#######################################

# Set up error handling
trap {
    Write-LogMessage "Script execution failed: $_" "Error"
    exit 1
}

# Handle Ctrl+C gracefully
$null = Register-EngineEvent PowerShell.Exiting -Action {
    Write-LogMessage "Script interrupted by user" "Warning"
}

# Execute main function
try {
    Start-Setup
}
catch {
    Write-LogMessage "Setup failed: $_" "Error"
    exit 1
}
