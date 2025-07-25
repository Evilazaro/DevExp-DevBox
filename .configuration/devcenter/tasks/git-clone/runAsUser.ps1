$CustomizationScriptsDir = "C:\DevBoxCustomizations"
$LockFile = "lockfile"
$RunAsUserScript = "runAsUser.ps1"
$CleanupScript = "cleanup.ps1"
$RunAsUserTask = "DevBoxCustomizations"
$CleanupTask = "DevBoxCustomizationsCleanup"

# Set the progress preference to silently continue
# in order to avoid progress bars in the output
# as this makes web requests very slow
# Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables
$ProgressPreference = 'SilentlyContinue'

Start-Transcript -Path $env:TEMP\scheduled-task-customization.log -Append -IncludeInvocationHeader

Write-Host "Microsoft Dev Box - Customizations"
Write-Host "----------------------------------"
Write-Host "Setting up scheduled tasks..."

Remove-Item -Path "$($CustomizationScriptsDir)\$($LockFile)"

Write-Host "Updating WinGet"
# ensure NuGet provider is installed
if (!(Get-PackageProvider | Where-Object { $_.Name -eq "NuGet" -and $_.Version -gt "2.8.5.201" })) {
    Write-Host "Installing NuGet provider"
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser
    Write-Host "Done Installing NuGet provider"
}
else {
    Write-Host "NuGet provider is already installed"
}

# Set PSGallery installation policy to trusted
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# check if the Microsoft.Winget.Client module is installed
if (!(Get-Module -ListAvailable -Name Microsoft.Winget.Client)) {
    Write-Host "Installing Microsoft.Winget.Client"
    Install-Module Microsoft.WinGet.Client -Scope CurrentUser
    Write-Host "Done Installing Microsoft.Winget.Client"
}
else {
    Write-Host "Microsoft.Winget.Client is already installed"
}

# check if the Microsoft.WinGet.Configuration module is installed
if (!(Get-Module -ListAvailable -Name Microsoft.WinGet.Configuration)) {
    Write-Host "Installing Microsoft.WinGet.Configuration"
    pwsh.exe -MTA -Command "Install-Module Microsoft.WinGet.Configuration -AllowPrerelease -Scope CurrentUser"
    Write-Host "Done Installing Microsoft.WinGet.Configuration"
}
else {
    Write-Host "Microsoft.WinGet.Configuration is already installed"
}

$msUiXamlPackage = Get-AppxPackage -Name "Microsoft.UI.Xaml.2.8" | Where-Object { $_.Version -ge "8.2310.30001.0" }
if (!($msUiXamlPackage)) {
    # install Microsoft.UI.Xaml
    try{
        Write-Host "Installing Microsoft.UI.Xaml"
        $architecture = "x64"
        if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
            $architecture = "arm64"
        }
        $MsUiXaml = "$env:TEMP\$([System.IO.Path]::GetRandomFileName())-Microsoft.UI.Xaml.2.8.7"
        $MsUiXamlZip = "$($MsUiXaml).zip"
        Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.8.7" -OutFile $MsUiXamlZip
        Expand-Archive $MsUiXamlZip -DestinationPath $MsUiXaml
        Add-AppxPackage -Path "$($MsUiXaml)\tools\AppX\$($architecture)\Release\Microsoft.UI.Xaml.2.8.appx" -ForceApplicationShutdown
        Write-Host "Done Installing Microsoft.UI.Xaml"
    } catch {
        Write-Host "Failed to install Microsoft.UI.Xaml"
        Write-Error $_
    }
}

$desktopAppInstallerPackage = Get-AppxPackage -Name "Microsoft.DesktopAppInstaller"
if (!($desktopAppInstallerPackage) ) {
    # install Microsoft.DesktopAppInstaller
    try {
        Write-Host "Installing Microsoft.DesktopAppInstaller"
        $DesktopAppInstallerAppx = "$env:TEMP\$([System.IO.Path]::GetRandomFileName())-DesktopAppInstaller.appx"
        Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile $DesktopAppInstallerAppx

        # install the DesktopAppInstaller appx package
        Add-AppxPackage -Path $DesktopAppInstallerAppx -ForceApplicationShutdown

        Write-Host "Done Installing Microsoft.DesktopAppInstaller"
    }
    catch {
        Write-Host "Failed to install DesktopAppInstaller appx package"
        Write-Error $_
    }
}

Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
Write-Host "WinGet version: $(winget -v)"

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
Write-Host "Done Updating WinGet"

# Revert PSGallery installation policy to untrusted
Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted