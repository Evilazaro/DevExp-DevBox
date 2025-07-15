<#
.SYNOPSIS
    Setup script wrapper for Azure Dev Box environment configuration

.DESCRIPTION
    This script configures the SOURCE_CONTROL_PLATFORM environment variable
    and executes the setup script with appropriate parameters.
#>

[CmdletBinding()]
param()

try {
    # Set error action preference to stop on errors (equivalent to 'set -e')
    $ErrorActionPreference = "Stop"
    
    # Define default platform
    $defaultPlatform = "github"
    
    # Check if the environment variable is set and handle accordingly
    if ([string]::IsNullOrEmpty($env:SOURCE_CONTROL_PLATFORM)) {
        Write-Host "SOURCE_CONTROL_PLATFORM is not set. Setting it to '$defaultPlatform' by default." -ForegroundColor Yellow
        $env:SOURCE_CONTROL_PLATFORM = $defaultPlatform
    }
    else {
        Write-Host "Existing SOURCE_CONTROL_PLATFORM is set to '$($env:SOURCE_CONTROL_PLATFORM)'." -ForegroundColor Green
    }
    
    # Validate that AZURE_ENV_NAME is set
    if ([string]::IsNullOrEmpty($env:AZURE_ENV_NAME)) {
        throw "AZURE_ENV_NAME environment variable is not set. Please set it before running this script."
    }
    
    # Validate that setup script exists
    $setupScript = ".\setup.ps1"
    if (-not (Test-Path $setupScript)) {
        throw "Setup script not found at: $setupScript"
    }
    
    # Execute the setup script with parameters
    Write-Host "Executing setup script with environment: $($env:AZURE_ENV_NAME) and platform: $($env:SOURCE_CONTROL_PLATFORM)" -ForegroundColor Cyan
    & $setupScript -e $env:AZURE_ENV_NAME -s $env:SOURCE_CONTROL_PLATFORM
    
    # Check if the setup script executed successfully
    if ($LASTEXITCODE -ne 0) {
        throw "Setup script failed with exit code: $LASTEXITCODE"
    }
    
    Write-Host "Setup completed successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
}