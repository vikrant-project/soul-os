#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"
$InstallPath = "$env:USERPROFILE\SoulOS"

Clear-Host
Write-Host ""
Write-Host "  ========================================" -ForegroundColor Magenta
Write-Host "           S O U L   O S" -ForegroundColor Cyan  
Write-Host "      Windows Installer v1.0.0" -ForegroundColor Magenta
Write-Host "  ========================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Install path: $InstallPath" -ForegroundColor Gray
Write-Host ""

# Check Windows version
Write-Host "[*] Checking system requirements..." -ForegroundColor Cyan
$build = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild
if ([int]$build -lt 18362) {
    Write-Host "[X] Windows 10 1903+ required. Current build: $build" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "[+] Windows version OK (Build $build)" -ForegroundColor Green

# Check disk space
$drive = Split-Path $InstallPath -Qualifier
$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$drive'"
$freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
if ($freeGB -lt 15) {
    Write-Host "[X] Need 15GB free. Available: $freeGB GB" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "[+] Disk space OK ($freeGB GB free)" -ForegroundColor Green

# Check/Enable WSL
Write-Host "[*] Checking WSL..." -ForegroundColor Cyan
$wsl = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
$vm = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

if ($wsl.State -ne "Enabled" -or $vm.State -ne "Enabled") {
    Write-Host "[*] Enabling WSL components..." -ForegroundColor Yellow
    if ($wsl.State -ne "Enabled") {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart | Out-Null
    }
    if ($vm.State -ne "Enabled") {
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart | Out-Null
    }
    Write-Host "[!] WSL enabled. Please RESTART and run again." -ForegroundColor Yellow
    $r = Read-Host "Restart now? (Y/N)"
    if ($r -eq "Y") { Restart-Computer -Force }
    exit 1
}
Write-Host "[+] WSL enabled" -ForegroundColor Green
wsl --set-default-version 2 2>$null

# Remove existing
$existing = wsl --list --quiet 2>$null
if ($existing -match "SoulOS") {
    Write-Host "[*] Removing existing Soul OS..." -ForegroundColor Yellow
    wsl --unregister SoulOS 2>$null
}

# Create directories
New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
$distroPath = "$InstallPath\distro"
New-Item -ItemType Directory -Path $distroPath -Force | Out-Null
$rootfs = "$InstallPath\rootfs.tar.gz"

# Download
Write-Host "[*] Downloading Soul OS (1.1GB)..." -ForegroundColor Cyan
Write-Host "    Please wait, this may take several minutes..." -ForegroundColor Gray
$url = "https://github.com/vikrant-project/soul-os/raw/main/soul_os_rootfs.tar.gz"
try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $url -OutFile $rootfs -UseBasicParsing
    $ProgressPreference = 'Continue'
    Write-Host "[+] Download complete" -ForegroundColor Green
} catch {
    Write-Host "[X] Download failed: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Import
Write-Host "[*] Importing to WSL2 (takes a few minutes)..." -ForegroundColor Cyan
wsl --import SoulOS $distroPath $rootfs --version 2
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Import failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "[+] Soul OS installed" -ForegroundColor Green

# Set default
wsl --set-default SoulOS
Write-Host "[+] Set as default distribution" -ForegroundColor Green

# Create shortcut
$desktop = [Environment]::GetFolderPath("Desktop")
$shell = New-Object -ComObject WScript.Shell
$sc = $shell.CreateShortcut("$desktop\Soul OS.lnk")
$sc.TargetPath = "wsl.exe"
$sc.Arguments = "-d SoulOS"
$sc.Save()
Write-Host "[+] Desktop shortcut created" -ForegroundColor Green

# Cleanup
Remove-Item $rootfs -Force -ErrorAction SilentlyContinue

# Done
Write-Host ""
Write-Host "  ========================================" -ForegroundColor Green
Write-Host "     Installation Complete!" -ForegroundColor Green
Write-Host "  ========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Launch: wsl -d SoulOS" -ForegroundColor Cyan
Write-Host "  Or double-click 'Soul OS' on Desktop" -ForegroundColor White
Write-Host ""
Write-Host "  Login: soul / soul" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to exit"
