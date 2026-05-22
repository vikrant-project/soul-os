#Requires -RunAsAdministrator
# Soul OS Direct Installer - Downloads from VPS

$downloadUrl = "http://13.62.57.154/soul-os/soul_os_rootfs.tar.gz"
$installPath = "$env:USERPROFILE\SoulOS"
$rootfsPath = "$installPath\soul_os_rootfs.tar.gz"

Write-Host @"

  ███████╗ ██████╗ ██╗   ██╗██╗          ██████╗ ███████╗
  ██╔════╝██╔═══██╗██║   ██║██║         ██╔═══██╗██╔════╝
  ███████╗██║   ██║██║   ██║██║         ██║   ██║███████╗
  ╚════██║██║   ██║██║   ██║██║         ██║   ██║╚════██║
  ███████║╚██████╔╝╚██████╔╝███████╗    ╚██████╔╝███████║
  ╚══════╝ ╚═════╝  ╚═════╝ ╚══════╝     ╚═════╝ ╚══════╝

       Soul OS Windows Installer v1.0.0

"@ -ForegroundColor Cyan

# Create directory
New-Item -ItemType Directory -Path $installPath -Force | Out-Null

Write-Host "[*] Downloading Soul OS (1.1GB)..." -ForegroundColor Yellow
Start-BitsTransfer -Source $downloadUrl -Destination $rootfsPath -DisplayName "Downloading Soul OS"

Write-Host "[*] Enabling WSL..." -ForegroundColor Yellow
wsl --set-default-version 2 2>$null

Write-Host "[*] Importing Soul OS..." -ForegroundColor Yellow
wsl --import SoulOS "$installPath\distro" $rootfsPath --version 2

Write-Host "[*] Setting as default..." -ForegroundColor Yellow
wsl --set-default SoulOS

Write-Host ""
Write-Host "[✓] Soul OS installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Launch with: wsl -d SoulOS" -ForegroundColor Cyan
Write-Host "Credentials: soul / soul" -ForegroundColor Cyan
Write-Host ""
