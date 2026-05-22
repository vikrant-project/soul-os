#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Soul OS Windows Installer - Complete Edition
.DESCRIPTION  
    Installs Soul OS as a WSL2 distribution on Windows.
    Downloads rootfs from multiple mirrors.
#>

$ErrorActionPreference = "Stop"

function Write-Banner {
    Write-Host @"

  ███████╗ ██████╗ ██╗   ██╗██╗          ██████╗ ███████╗
  ██╔════╝██╔═══██╗██║   ██║██║         ██╔═══██╗██╔════╝
  ███████╗██║   ██║██║   ██║██║         ██║   ██║███████╗
  ╚════██║██║   ██║██║   ██║██║         ██║   ██║╚════██║
  ███████║╚██████╔╝╚██████╔╝███████╗    ╚██████╔╝███████║
  ╚══════╝ ╚═════╝  ╚═════╝ ╚══════╝     ╚═════╝ ╚══════╝

         Soul OS Installer v1.0.0

"@ -ForegroundColor Magenta
}

Clear-Host
Write-Banner

$installPath = "$env:USERPROFILE\SoulOS"
$distroPath = "$installPath\distro"
$rootfsPath = "$installPath\soul_os_rootfs.tar.gz"

# Check if already installed
$existing = wsl --list --quiet 2>$null | Where-Object { $_ -match "SoulOS" }
if ($existing) {
    Write-Host "[!] Soul OS already installed. Uninstalling first..." -ForegroundColor Yellow
    wsl --unregister SoulOS 2>$null
}

# Enable WSL2
Write-Host "[*] Checking WSL status..." -ForegroundColor Cyan
$wslVersion = wsl --version 2>$null
if (-not $wslVersion) {
    Write-Host "[*] Installing WSL..." -ForegroundColor Yellow
    wsl --install --no-distribution
    Write-Host "[!] WSL installed. Please restart your computer and run this script again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

wsl --set-default-version 2 2>$null

# Create directories
Write-Host "[*] Creating directories..." -ForegroundColor Cyan  
New-Item -ItemType Directory -Path $installPath -Force | Out-Null
New-Item -ItemType Directory -Path $distroPath -Force | Out-Null

# Download options
Write-Host "[*] Soul OS rootfs needs to be downloaded (1.1GB)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Download options:" -ForegroundColor Cyan
Write-Host "  1. Download from GitHub Release (recommended)" -ForegroundColor White
Write-Host "  2. Browse for local file (if you already downloaded)" -ForegroundColor White
Write-Host ""
$choice = Read-Host "Enter choice (1 or 2)"

if ($choice -eq "2") {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "Gzip files (*.tar.gz)|*.tar.gz|All files (*.*)|*.*"
    $dialog.Title = "Select Soul OS rootfs file"
    if ($dialog.ShowDialog() -eq "OK") {
        Copy-Item $dialog.FileName $rootfsPath
    } else {
        Write-Host "[!] No file selected. Exiting." -ForegroundColor Red
        exit 1
    }
} else {
    # Download from GitHub release
    $releaseUrl = "https://github.com/vikrant-project/soul-os/releases/download/v22.04.1/soul_os_rootfs.tar.gz"
    
    Write-Host "[*] Downloading Soul OS..." -ForegroundColor Cyan
    Write-Host "    This may take several minutes depending on your connection." -ForegroundColor Gray
    
    try {
        Start-BitsTransfer -Source $releaseUrl -Destination $rootfsPath -DisplayName "Downloading Soul OS"
    }
    catch {
        Write-Host "[*] BITS transfer unavailable, using WebClient..." -ForegroundColor Yellow
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($releaseUrl, $rootfsPath)
    }
}

# Verify download
if (-not (Test-Path $rootfsPath)) {
    Write-Host "[!] Download failed. Please download manually from:" -ForegroundColor Red
    Write-Host "    https://github.com/vikrant-project/soul-os/releases" -ForegroundColor Yellow
    exit 1
}

$fileSize = (Get-Item $rootfsPath).Length / 1GB
Write-Host "[+] Downloaded $([math]::Round($fileSize, 2))GB" -ForegroundColor Green

# Import to WSL
Write-Host "[*] Importing Soul OS to WSL2..." -ForegroundColor Cyan
Write-Host "    This may take a few minutes..." -ForegroundColor Gray
wsl --import SoulOS $distroPath $rootfsPath --version 2

if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Import failed." -ForegroundColor Red
    exit 1
}

# Set as default
wsl --set-default SoulOS

# Create desktop shortcut
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$desktopPath\Soul OS.lnk")
$shortcut.TargetPath = "wsl.exe"
$shortcut.Arguments = "-d SoulOS"
$shortcut.Description = "Launch Soul OS"
$shortcut.Save()

# Cleanup rootfs
Remove-Item $rootfsPath -Force -ErrorAction SilentlyContinue

# Done!
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   Soul OS installed successfully!     " -ForegroundColor Green  
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Launch: Double-click 'Soul OS' on Desktop" -ForegroundColor Cyan
Write-Host "   Or:  wsl -d SoulOS" -ForegroundColor Cyan
Write-Host ""
Write-Host "Default login:" -ForegroundColor Yellow
Write-Host "  Username: soul" -ForegroundColor White
Write-Host "  Password: soul" -ForegroundColor White
Write-Host ""
Write-Host "Enjoy your lightweight Linux experience!" -ForegroundColor Magenta
Write-Host ""
Read-Host "Press Enter to exit"
