

<#
.SYNOPSIS
    Updates Microsoft Store applications using winget.

.DESCRIPTION
    This script automates the process of updating all Microsoft Store applications
    on a Windows system using the Windows Package Manager (winget). It performs
    multiple upgrade passes to ensure all apps are updated, including those with
    unknown versions.

    The script:
    - Resolves the winget executable path from the App Installer package
    - Ensures the Microsoft Store Install Service is running
    - Configures and refreshes winget sources
    - Runs multiple upgrade passes (standard, forced, and safety net)
    - Logs all operations to a timestamped log file

.NOTES
    File Name      : winget-update.ps1
    Prerequisite   : Windows PowerShell 5.1 or later
                     Microsoft Desktop App Installer (winget)
    Log Location   : %ProgramData%\Winget-StoreUpgrade\

.EXAMPLE
    .\winget-update.ps1
    
    Runs the script to update all Microsoft Store applications.

.OUTPUTS
    None. This script does not return any objects. All output is written to the
    console and to a timestamped log file in %ProgramData%\Winget-StoreUpgrade\.

.INPUTS
    None. This script does not accept pipeline input.

.LINK
    https://github.com/microsoft/winget-cli

.LINK
    https://learn.microsoft.com/en-us/windows/package-manager/winget/
#>

#Requires -Version 5.1

Set-ExecutionPolicy Bypass -Scope Process -Force
Clear-Host

# Script Configuration
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$env:WINGET_DISABLE_INTERACTIVITY = '1'

# Logging Configuration
$Script:LogRoot = Join-Path $env:ProgramData 'Winget-StoreUpgrade'
if (-not (Test-Path $Script:LogRoot)) {
    New-Item -Path $Script:LogRoot -ItemType Directory -Force | Out-Null
}
$Script:Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$Script:LogFile = Join-Path $Script:LogRoot "upgrade-$Script:Timestamp.log"

function Write-LogInfo {
    <#
    .SYNOPSIS
        Writes an informational message to console and log file.
    
    .PARAMETER Message
        The message to write.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    "[INFO ] $Message" | Tee-Object -FilePath $Script:LogFile -Append
}

function Write-LogWarning {
    <#
    .SYNOPSIS
        Writes a warning message to console and log file.
    
    .PARAMETER Message
        The message to write.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    "[WARN ] $Message" | Tee-Object -FilePath $Script:LogFile -Append
}

function Write-LogError {
    <#
    .SYNOPSIS
        Writes an error message to console and log file.
    
    .PARAMETER Message
        The message to write.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    "[ERROR] $Message" | Tee-Object -FilePath $Script:LogFile -Append
}

Write-LogInfo "Log file: $Script:LogFile"
Write-LogInfo "Starting Microsoft Store updates..."

function Resolve-WinGetExecutable {
    <#
    .SYNOPSIS
        Resolves the path to winget.exe.
    
    .DESCRIPTION
        Prefers the packaged App Installer location (more stable than user alias).
        Falls back to whatever PowerShell resolves.
    
    .OUTPUTS
        System.String - The path to winget.exe.
    
    .EXAMPLE
        $wingetPath = Resolve-WinGetExecutable
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    # Prefer packaged App Installer location (more stable than user alias)
    $pkg = Get-AppxPackage -Name Microsoft.DesktopAppInstaller -ErrorAction SilentlyContinue
    if ($pkg) {
        $candidate = Join-Path $pkg.InstallLocation 'winget.exe'
        if (Test-Path $candidate) {
            return $candidate
        }
    }
    
    # Fallback to whatever PowerShell resolves
    return (Get-Command winget.exe -ErrorAction Stop).Source
}

$Script:WinGetExe = Resolve-WinGetExecutable

function Invoke-WinGetCommand {
    <#
    .SYNOPSIS
        Invokes a winget command with proper logging.
    
    .DESCRIPTION
        Executes winget directly by absolute path and logs output.
        Optionally retries if winget updated itself mid-run.
    
    .PARAMETER CommandArgs
        The arguments to pass to winget.
    
    .PARAMETER RetryOnSelfUpdate
        If specified, retries once if winget self-updated.
    
    .OUTPUTS
        System.String - The output from winget.
    
    .EXAMPLE
        Invoke-WinGetCommand -CommandArgs @('upgrade', '--all') -RetryOnSelfUpdate
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('Arguments')]
        [string[]]$CommandArgs,

        [Parameter(Mandatory = $false)]
        [switch]$RetryOnSelfUpdate
    )

    # Execute the EXE directly
    $output = & $Script:WinGetExe @CommandArgs 2>&1
    $text = $output | Out-String
    $text | Tee-Object -FilePath $Script:LogFile -Append | Out-Null

    if ($RetryOnSelfUpdate -and $text -match 'Restart the application to complete the upgrade') {
        Write-LogInfo "winget/App Installer updated itself; re-resolving path and retrying once..."
        Start-Sleep -Milliseconds 500
        $Script:WinGetExe = Resolve-WinGetExecutable
        $output = & $Script:WinGetExe @CommandArgs 2>&1
        $text = $output | Out-String
        $text | Tee-Object -FilePath $Script:LogFile -Append | Out-Null
    }

    return $text
}

function Test-WinGetAvailability {
    <#
    .SYNOPSIS
        Verifies winget is available and working.
    
    .OUTPUTS
        System.Boolean - True if winget is available, False otherwise.
    
    .EXAMPLE
        if (Test-WinGetAvailability) { Write-Host "WinGet is ready" }
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        $null = Invoke-WinGetCommand -CommandArgs @('--version')
        return $true
    }
    catch {
        Write-LogError "winget (App Installer) not found. Install/update 'App Installer' from Microsoft Store and re-run."
        return $false
    }
}

function Start-StoreInstallService {
    <#
    .SYNOPSIS
        Ensures the Microsoft Store Install Service is running.
    
    .DESCRIPTION
        Starts the InstallService if it's not already running.
        This helps with Store app updates.
    #>
    [CmdletBinding()]
    param()

    try {
        $svc = Get-Service -Name InstallService -ErrorAction SilentlyContinue
        if ($svc -and $svc.Status -ne 'Running') {
            Write-LogInfo "Starting Microsoft Store Install Service (InstallService)..."
            Start-Service -Name InstallService -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-LogWarning "Could not verify/start InstallService. Continuing..."
    }
}

function Initialize-WinGetSources {
    <#
    .SYNOPSIS
        Ensures winget sources are properly configured.
    
    .DESCRIPTION
        Verifies the msstore source exists and refreshes all sources.
    #>
    [CmdletBinding()]
    param()

    try {
        $sources = Invoke-WinGetCommand -CommandArgs @('source', 'list', '--disable-interactivity')
        if ($sources -notmatch '(?im)^\s*msstore\b') {
            Write-LogInfo "msstore source not found; resetting..."
            $null = Invoke-WinGetCommand -CommandArgs @('source', 'reset', '--force', 'msstore', '--disable-interactivity')
        }
        $null = Invoke-WinGetCommand -CommandArgs @('source', 'update', '--disable-interactivity')
    }
    catch {
        Write-LogWarning "Winget source operations reported issues; continuing..."
    }
}

function Update-MicrosoftStoreApps {
    <#
    .SYNOPSIS
        Performs multiple passes to update all Microsoft Store apps.
    
    .DESCRIPTION
        Runs three passes:
        1. Standard upgrade with include-unknown
        2. Forced upgrade for stubborn apps
        3. Safety net pass for apps mapped under other sources
    #>
    [CmdletBinding()]
    param()

    # Pass 1: Accept msstore terms & upgrade what winget can detect
    Write-LogInfo "Pass 1: upgrading Microsoft Store apps (include-unknown)..."
    $null = Invoke-WinGetCommand -CommandArgs @(
        'upgrade', '--all',
        '--source', 'msstore',
        '--include-unknown',
        '--silent',
        '--accept-source-agreements', '--accept-package-agreements',
        '--disable-interactivity'
    ) -RetryOnSelfUpdate

    # Pass 2: Force re-install latest for stragglers where version compare is unknown
    Write-LogInfo "Pass 2: forced upgrade (msstore) for remaining/unknown version apps..."
    $null = Invoke-WinGetCommand -CommandArgs @(
        'upgrade', '--all',
        '--source', 'msstore',
        '--include-unknown',
        '--force',
        '--silent',
        '--accept-source-agreements', '--accept-package-agreements',
        '--disable-interactivity'
    ) -RetryOnSelfUpdate

    # Safety net pass: catch apps mapped under other sources
    Write-LogInfo "Safety net: unfiltered pass to catch any remaining packages..."
    $null = Invoke-WinGetCommand -CommandArgs @(
        'upgrade', '--all',
        '--include-unknown',
        '--silent',
        '--accept-source-agreements', '--accept-package-agreements',
        '--disable-interactivity'
    ) -RetryOnSelfUpdate

    # Summary: show any remaining Store upgrades
    Write-LogInfo "Summary check for remaining Microsoft Store upgrades..."
    $null = Invoke-WinGetCommand -CommandArgs @('upgrade', '--source', 'msstore', '--disable-interactivity')
}

# Main script execution
try {
    # Preflight check
    if (-not (Test-WinGetAvailability)) {
        exit 1
    }

    # Ensure Store service is running
    Start-StoreInstallService

    # Configure sources
    Initialize-WinGetSources

    # Run updates
    Update-MicrosoftStoreApps

    Write-LogInfo "Completed. Full log: $Script:LogFile"
}
catch {
    Write-LogError "Script execution failed: $_"
    exit 1
}
