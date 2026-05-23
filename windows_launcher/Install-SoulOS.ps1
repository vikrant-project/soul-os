#Requires -RunAsAdministrator
param(
    [string]$InstallPath = "$env:USERPROFILE\SoulOS",
    [switch]$Uninstall
)

$Host.UI.RawUI.WindowTitle = "Soul OS Installer"

function Write-Banner {
    Write-Host ""
    Write-Host "  ========================================" -ForegroundColor Magenta
    Write-Host "           S O U L   O S" -ForegroundColor Cyan
    Write-Host "      Windows Installer v1.0.0" -ForegroundColor Magenta
    Write-Host "  ========================================" -ForegroundColor Magenta
    Write-Host ""
}

function Write-Step {
    param([string]$Message, [string]$Status = "INFO")
    switch ($Status) {
        "INFO"    { Write-Host "[*] $Message" -ForegroundColor White }
        "SUCCESS" { Write-Host "[+] $Message" -ForegroundColor Green }
        "WARNING" { Write-Host "[!] $Message" -ForegroundColor Yellow }
        "ERROR"   { Write-Host "[X] $Message" -ForegroundColor Red }
        "WAIT"    { Write-Host "[~] $Message" -ForegroundColor Cyan }
    }
}

function Test-Requirements {
    Write-Step "Checking system requirements..." "WAIT"
    
    $buildNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild
    if ([int]$buildNumber -lt 18362) {
        Write-Step "Windows 10 version 1903+ required (Build 18362+). Current: $buildNumber" "ERROR"
        return $false
    }
    Write-Step "Windows version OK (Build $buildNumber)" "SUCCESS"
    
    $drive = Split-Path $InstallPath -Qualifier
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$drive'"
    $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    if ($freeGB -lt 15) {
        Write-Step "Need 15GB free space. Available: $freeGB GB" "ERROR"
        return $false
    }
    Write-Step "Disk space OK ($freeGB GB available)" "SUCCESS"
    
    $ramGB = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    Write-Step "RAM OK ($ramGB GB)" "SUCCESS"
    
    return $true
}

function Enable-WSL {
    Write-Step "Checking WSL status..." "WAIT"
    
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    $vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
    
    $needRestart = $false
    
    if ($wslFeature.State -ne "Enabled") {
        Write-Step "Enabling WSL..." "WAIT"
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart | Out-Null
        $needRestart = $true
    }
    
    if ($vmFeature.State -ne "Enabled") {
        Write-Step "Enabling Virtual Machine Platform..." "WAIT"
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart | Out-Null
        $needRestart = $true
    }
    
    if ($needRestart) {
        Write-Step "WSL components enabled. RESTART REQUIRED." "WARNING"
        Write-Step "After restart, run this installer again." "INFO"
        $answer = Read-Host "Restart now? (Y/N)"
        if ($answer -eq "Y" -or $answer -eq "y") {
            Restart-Computer -Force
        }
        exit 1
    }
    
    Write-Step "WSL enabled" "SUCCESS"
    wsl --set-default-version 2 2>$null
    Write-Step "WSL2 set as default" "SUCCESS"
}

function Download-SoulOS {
    Write-Step "Preparing download..." "WAIT"
    
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    }
    
    $rootfsUrl = "https://github.com/vikrant-project/soul-os/raw/main/soul_os_rootfs.tar.gz"
    $rootfsPath = Join-Path $InstallPath "soul_os_rootfs.tar.gz"
    
    Write-Step "Downloading Soul OS (1.1GB)..." "WAIT"
    Write-Host "    This may take several minutes..." -ForegroundColor Gray
    
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $rootfsUrl -OutFile $rootfsPath -UseBasicParsing
        $ProgressPreference = 'Continue'
        Write-Step "Download complete" "SUCCESS"
    }
    catch {
        Write-Step "Download failed: $_" "ERROR"
        return $null
    }
    
    return $rootfsPath
}

function Install-Distro {
    param([string]$RootfsPath)
    
    Write-Step "Installing Soul OS distribution..." "WAIT"
    
    $existing = wsl --list --quiet 2>$null
    if ($existing -match "SoulOS") {
        Write-Step "Removing existing installation..." "WARNING"
        wsl --unregister SoulOS 2>$null
    }
    
    $distroPath = Join-Path $InstallPath "distro"
    if (-not (Test-Path $distroPath)) {
        New-Item -ItemType Directory -Path $distroPath -Force | Out-Null
    }
    
    Write-Step "Importing rootfs (this takes a few minutes)..." "WAIT"
    wsl --import SoulOS $distroPath $RootfsPath --version 2
    
    if ($LASTEXITCODE -ne 0) {
        Write-Step "Import failed" "ERROR"
        return $false
    }
    
    Write-Step "Soul OS installed" "SUCCESS"
    wsl --set-default SoulOS
    Write-Step "Set as default WSL distribution" "SUCCESS"
    
    Remove-Item $RootfsPath -Force -ErrorAction SilentlyContinue
    return $true
}

function Create-Shortcuts {
    Write-Step "Creating shortcuts..." "WAIT"
    
    $desktop = [Environment]::GetFolderPath("Desktop")
    $shell = New-Object -ComObject WScript.Shell
    
    $shortcut = $shell.CreateShortcut("$desktop\Soul OS.lnk")
    $shortcut.TargetPath = "wsl.exe"
    $shortcut.Arguments = "-d SoulOS"
    $shortcut.Description = "Launch Soul OS"
    $shortcut.Save()
    
    Write-Step "Desktop shortcut created" "SUCCESS"
}

function Show-Complete {
    Write-Host ""
    Write-Host "  ========================================" -ForegroundColor Green
    Write-Host "     Soul OS Installed Successfully!" -ForegroundColor Green
    Write-Host "  ========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Launch: " -NoNewline -ForegroundColor White
    Write-Host "wsl -d SoulOS" -ForegroundColor Cyan
    Write-Host "  Or double-click 'Soul OS' on Desktop" -ForegroundColor White
    Write-Host ""
    Write-Host "  Default credentials:" -ForegroundColor Yellow
    Write-Host "    Username: soul" -ForegroundColor White
    Write-Host "    Password: soul" -ForegroundColor White
    Write-Host ""
}

# Main
Clear-Host
Write-Banner

if ($Uninstall) {
    Write-Step "Uninstalling Soul OS..." "WAIT"
    wsl --unregister SoulOS 2>$null
    Remove-Item $InstallPath -Recurse -Force -ErrorAction SilentlyContinue
    $desktop = [Environment]::GetFolderPath("Desktop")
    Remove-Item "$desktop\Soul OS.lnk" -Force -ErrorAction SilentlyContinue
    Write-Step "Soul OS uninstalled" "SUCCESS"
    exit 0
}

Write-Host "  Install path: $InstallPath" -ForegroundColor Gray
Write-Host ""

if (-not (Test-Requirements)) {
    Write-Step "Requirements not met" "ERROR"
    Read-Host "Press Enter to exit"
    exit 1
}

Enable-WSL

$rootfs = Download-SoulOS
if (-not $rootfs) {
    Write-Step "Download failed" "ERROR"
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not (Install-Distro -RootfsPath $rootfs)) {
    Write-Step "Installation failed" "ERROR"
    Read-Host "Press Enter to exit"
    exit 1
}

Create-Shortcuts
Show-Complete

Read-Host "Press Enter to exit"
