Set-ExecutionPolicy Bypass -Scope Process -Force
Clear-Host

<# 
.SYNOPSIS
  Quietly updates all Microsoft Store apps using winget (v1.11.x compatible).

.DESCRIPTION
  - Runs fully non-interactive (no prompts).
  - Properly orders command + flags for winget 1.11.x.
  - Accepts msstore/package agreements on upgrade/install only.
  - Uses include-unknown and a forced second pass to catch stubborn Store apps.
  - Detects if winget/App Installer updated itself mid-run and retries once.
  - Executes winget by absolute path (no App Execution Alias quirks).
  - Logs to C:\ProgramData\Winget-StoreUpgrade\upgrade-YYYYMMDD-HHMMSS.log

.NOTES
  Recommended to run in an elevated session to service machine-wide apps.
#>

# ===== Global non-interactive settings =====
$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'
$env:WINGET_DISABLE_INTERACTIVITY = '1'   # environment-based; no CLI side effects

# ===== Logging =====
$LogRoot = Join-Path $env:ProgramData 'Winget-StoreUpgrade'
if (-not (Test-Path $LogRoot)) { New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null }
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$LogFile   = Join-Path $LogRoot "upgrade-$Timestamp.log"

function Write-Info { param([string]$m) "[INFO ] $m"  | Tee-Object -FilePath $LogFile -Append }
function Write-Warn { param([string]$m) "[WARN ] $m"  | Tee-Object -FilePath $LogFile -Append }
function Write-Err  { param([string]$m) "[ERROR] $m" | Tee-Object -FilePath $LogFile -Append }

Write-Info "Log file: $LogFile"
Write-Info "Starting Microsoft Store updates..."

# ===== Robust winget resolution and invoker =====
function Resolve-WinGetExe {
    # Prefer packaged App Installer location (more stable than user alias)
    $pkg = Get-AppxPackage -Name Microsoft.DesktopAppInstaller -ErrorAction SilentlyContinue
    if ($pkg) {
        $candidate = Join-Path $pkg.InstallLocation 'winget.exe'
        if (Test-Path $candidate) { return $candidate }
    }
    # Fallback to whatever PowerShell resolves
    return (Get-Command winget.exe -ErrorAction Stop).Source
}

$script:WinGetExe = Resolve-WinGetExe

function Invoke-WinGet {
    param(
        [Parameter(Mandatory)][string[]]$Args,    # e.g. @('upgrade','--all',...)
        [switch]$RetryOnSelfUpdate                # retry once if winget self-updated
    )
    # Execute the EXE directly — do NOT call 'winget' then pass a path
    $output = & $script:WinGetExe @Args 2>&1
    $text   = $output | Out-String
    $text | Tee-Object -FilePath $LogFile -Append | Out-Null

    if ($RetryOnSelfUpdate -and $text -match 'Restart the application to complete the upgrade') {
        Write-Info "winget/App Installer updated itself; re-resolving path and retrying once..."
        Start-Sleep -Milliseconds 500
        $script:WinGetExe = Resolve-WinGetExe
        $output = & $script:WinGetExe @Args 2>&1
        $text   = $output | Out-String
        $text | Tee-Object -FilePath $LogFile -Append | Out-Null
    }
    return $text
}

# ===== Preflight: confirm winget exists =====
try {
    Invoke-WinGet -Args @('--version') | Out-Null
} catch {
    Write-Err "winget (App Installer) not found. Install/update 'App Installer' from Microsoft Store and re-run."
    exit 1
}

# ===== Ensure Microsoft Store Install Service is running (helps Store updates) =====
try {
    $svc = Get-Service -Name InstallService -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -ne 'Running') {
        Write-Info "Starting Microsoft Store Install Service (InstallService)..."
        Start-Service -Name InstallService -ErrorAction SilentlyContinue
    }
} catch { Write-Warn "Could not verify/start InstallService. Continuing..." }

# ===== Ensure msstore source exists and refresh (NO accept flags here) =====
try {
    $sources = Invoke-WinGet -Args @('source','list','--disable-interactivity')
    if ($sources -notmatch '(?im)^\s*msstore\b') {
        Write-Info "msstore source not found; resetting..."
        Invoke-WinGet -Args @('source','reset','--force','msstore','--disable-interactivity')
    }
    Invoke-WinGet -Args @('source','update','--disable-interactivity') | Out-Null
} catch {
    Write-Warn "Winget source operations reported issues; continuing..."
}

# ===== Optional: prevent winget self-upgrade during the session (pin App Installer) =====
# (Uncomment if you want to avoid mid-run self-update entirely)
# Invoke-WinGet -Args @('pin','add','--id','Microsoft.AppInstaller','--disable-interactivity') | Out-Null

# ===== PASS 1: Accept msstore terms & upgrade what winget can detect =====
Write-Info "Pass 1: upgrading Microsoft Store apps (include-unknown)..."
Invoke-WinGet -Args @(
    'upgrade','--all',
    '--source','msstore',
    '--include-unknown',
    '--silent',
    '--accept-source-agreements','--accept-package-agreements',
    '--disable-interactivity'
) -RetryOnSelfUpdate | Out-Null

# ===== PASS 2: Force re-install latest for stragglers where version compare is unknown =====
Write-Info "Pass 2: forced upgrade (msstore) for remaining/unknown version apps..."
Invoke-WinGet -Args @(
    'upgrade','--all',
    '--source','msstore',
    '--include-unknown',
    '--force',
    '--silent',
    '--accept-source-agreements','--accept-package-agreements',
    '--disable-interactivity'
) -RetryOnSelfUpdate | Out-Null

# ===== OPTIONAL Safety net pass: catch apps mapped under other sources =====
Write-Info "Safety net: unfiltered pass to catch any remaining packages..."
Invoke-WinGet -Args @(
    'upgrade','--all',
    '--include-unknown',
    '--silent',
    '--accept-source-agreements','--accept-package-agreements',
    '--disable-interactivity'
) -RetryOnSelfUpdate | Out-Null

# ===== Summary: show any remaining Store upgrades (no accept flags here) =====
Write-Info "Summary check for remaining Microsoft Store upgrades..."
Invoke-WinGet -Args @('upgrade','--source','msstore','--disable-interactivity') | Out-Null

# ===== Optional: unpin App Installer after run =====
# Invoke-WinGet -Args @('pin','remove','--id','Microsoft.AppInstaller','--disable-interactivity') | Out-Null

Write-Info "Completed. Full log: $LogFile"
