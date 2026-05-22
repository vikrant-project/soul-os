#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Soul OS Windows Installer - Installs Soul OS via WSL2
.DESCRIPTION
    This script downloads and installs Soul OS as a WSL2 distribution
    on Windows 10/11 systems.
.NOTES
    Version:        1.0.0
    Author:         Soul OS Team
    Requires:       Windows 10 version 1903+ or Windows 11
                    Administrator privileges
#>

param(
    [string]$InstallPath = "$env:USERPROFILE\SoulOS",
    [switch]$Uninstall,
    [switch]$NoGUI
)

# Colors and styling
$Host.UI.RawUI.WindowTitle = "Soul OS Installer"
$colors = @{
    Primary   = "Magenta"
    Secondary = "Cyan"
    Success   = "Green"
    Warning   = "Yellow"
    Error     = "Red"
    Info      = "White"
}

function Write-Banner {
    $banner = @"

  ███████╗ ██████╗ ██╗   ██╗██╗          ██████╗ ███████╗
  ██╔════╝██╔═══██╗██║   ██║██║         ██╔═══██╗██╔════╝
  ███████╗██║   ██║██║   ██║██║         ██║   ██║███████╗
  ╚════██║██║   ██║██║   ██║██║         ██║   ██║╚════██║
  ███████║╚██████╔╝╚██████╔╝███████╗    ╚██████╔╝███████║
  ╚══════╝ ╚═════╝  ╚═════╝ ╚══════╝     ╚═════╝ ╚══════╝

       W I N D O W S   I N S T A L L E R   v 1.0.0

         Lightweight • Fast • Beautiful

"@
    Write-Host $banner -ForegroundColor $colors.Secondary
}

function Write-Step {
    param([string]$Message, [string]$Status = "INFO")
    $icon = switch ($Status) {
        "INFO"    { "[*]" }
        "SUCCESS" { "[✓]" }
        "WARNING" { "[!]" }
        "ERROR"   { "[✗]" }
        "WAIT"    { "[~]" }
    }
    $color = switch ($Status) {
        "INFO"    { $colors.Info }
        "SUCCESS" { $colors.Success }
        "WARNING" { $colors.Warning }
        "ERROR"   { $colors.Error }
        "WAIT"    { $colors.Secondary }
    }
    Write-Host "$icon " -ForegroundColor $color -NoNewline
    Write-Host $Message
}

function Test-SystemRequirements {
    Write-Step "Checking system requirements..." "WAIT"
    
    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    $buildNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild
    
    if ($buildNumber -lt 18362) {
        Write-Step "Windows 10 version 1903 or higher required (Build 18362+)" "ERROR"
        Write-Step "Current build: $buildNumber" "INFO"
        return $false
    }
    Write-Step "Windows version: OK (Build $buildNumber)" "SUCCESS"
    
    # Check available disk space (minimum 20GB)
    $drive = (Split-Path $InstallPath -Qualifier)
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$drive'"
    $freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    
    if ($freeSpaceGB -lt 20) {
        Write-Step "Insufficient disk space. Need 20GB, have ${freeSpaceGB}GB" "ERROR"
        return $false
    }
    Write-Step "Disk space: OK (${freeSpaceGB}GB available)" "SUCCESS"
    
    # Check RAM (minimum 4GB, recommended 8GB)
    $ram = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    if ($ram -lt 4) {
        Write-Step "Minimum 4GB RAM required. You have ${ram}GB" "WARNING"
    } else {
        Write-Step "RAM: OK (${ram}GB)" "SUCCESS"
    }
    
    return $true
}

function Enable-WSL {
    Write-Step "Checking WSL status..." "WAIT"
    
    # Check if WSL is installed
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    $vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
    
    $restartRequired = $false
    
    if ($wslFeature.State -ne "Enabled") {
        Write-Step "Enabling Windows Subsystem for Linux..." "WAIT"
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart | Out-Null
        $restartRequired = $true
    }
    
    if ($vmFeature.State -ne "Enabled") {
        Write-Step "Enabling Virtual Machine Platform..." "WAIT"
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart | Out-Null
        $restartRequired = $true
    }
    
    if ($restartRequired) {
        Write-Step "WSL components enabled. System restart required." "WARNING"
        Write-Step "After restart, run this installer again." "INFO"
        $restart = Read-Host "Restart now? (Y/N)"
        if ($restart -eq "Y" -or $restart -eq "y") {
            Restart-Computer -Force
        }
        exit 1
    }
    
    Write-Step "WSL: Enabled" "SUCCESS"
    
    # Set WSL2 as default
    Write-Step "Setting WSL2 as default version..." "WAIT"
    wsl --set-default-version 2 2>$null
    Write-Step "WSL2 set as default" "SUCCESS"
}

function Get-SoulOS {
    Write-Step "Downloading Soul OS..." "WAIT"
    
    # Create install directory
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    }
    
    $rootfsUrl = "https://github.com/vikrant-project/soul-os/releases/latest/download/soul_os_rootfs.tar.gz"
    $rootfsPath = Join-Path $InstallPath "soul_os_rootfs.tar.gz"
    
    try {
        # Use BITS for better download handling
        Start-BitsTransfer -Source $rootfsUrl -Destination $rootfsPath -DisplayName "Downloading Soul OS"
        Write-Step "Download complete" "SUCCESS"
    }
    catch {
        Write-Step "BITS transfer failed, trying WebClient..." "WARNING"
        try {
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($rootfsUrl, $rootfsPath)
            Write-Step "Download complete" "SUCCESS"
        }
        catch {
            Write-Step "Download failed: $_" "ERROR"
            return $false
        }
    }
    
    return $rootfsPath
}

function Install-SoulOSDistro {
    param([string]$RootfsPath)
    
    Write-Step "Installing Soul OS WSL distribution..." "WAIT"
    
    # Check if already registered
    $existingDistros = wsl --list --quiet 2>$null
    if ($existingDistros -match "SoulOS") {
        Write-Step "Soul OS already installed. Removing old installation..." "WARNING"
        wsl --unregister SoulOS 2>$null
    }
    
    # Import the distribution
    $distroPath = Join-Path $InstallPath "distro"
    if (-not (Test-Path $distroPath)) {
        New-Item -ItemType Directory -Path $distroPath -Force | Out-Null
    }
    
    Write-Step "Importing rootfs (this may take a few minutes)..." "WAIT"
    wsl --import SoulOS $distroPath $RootfsPath --version 2
    
    if ($LASTEXITCODE -ne 0) {
        Write-Step "Failed to import WSL distribution" "ERROR"
        return $false
    }
    
    Write-Step "Soul OS installed successfully!" "SUCCESS"
    
    # Set as default distro
    wsl --set-default SoulOS
    Write-Step "Soul OS set as default WSL distribution" "SUCCESS"
    
    # Clean up rootfs
    Remove-Item $RootfsPath -Force -ErrorAction SilentlyContinue
    
    return $true
}

function Create-Shortcuts {
    Write-Step "Creating shortcuts..." "WAIT"
    
    # Desktop shortcut
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "Soul OS.lnk"
    
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "wsl.exe"
    $shortcut.Arguments = "-d SoulOS"
    $shortcut.Description = "Launch Soul OS"
    $shortcut.WorkingDirectory = "%USERPROFILE%"
    $shortcut.Save()
    
    Write-Step "Desktop shortcut created" "SUCCESS"
    
    # Start menu shortcut
    $startMenuPath = [Environment]::GetFolderPath("Programs")
    $soulMenuPath = Join-Path $startMenuPath "Soul OS"
    if (-not (Test-Path $soulMenuPath)) {
        New-Item -ItemType Directory -Path $soulMenuPath -Force | Out-Null
    }
    
    $startShortcut = $shell.CreateShortcut((Join-Path $soulMenuPath "Soul OS.lnk"))
    $startShortcut.TargetPath = "wsl.exe"
    $startShortcut.Arguments = "-d SoulOS"
    $startShortcut.Description = "Launch Soul OS"
    $startShortcut.Save()
    
    Write-Step "Start menu shortcuts created" "SUCCESS"
}

function Show-CompletionMessage {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $colors.Success
    Write-Host "║                                                              ║" -ForegroundColor $colors.Success
    Write-Host "║          Soul OS Installation Complete!                      ║" -ForegroundColor $colors.Success
    Write-Host "║                                                              ║" -ForegroundColor $colors.Success
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $colors.Success
    Write-Host ""
    Write-Host "  Quick Start:" -ForegroundColor $colors.Secondary
    Write-Host "  • Launch from Desktop shortcut 'Soul OS'" -ForegroundColor $colors.Info
    Write-Host "  • Or run: " -ForegroundColor $colors.Info -NoNewline
    Write-Host "wsl -d SoulOS" -ForegroundColor $colors.Primary
    Write-Host ""
    Write-Host "  Default Credentials:" -ForegroundColor $colors.Secondary
    Write-Host "  • Username: soul" -ForegroundColor $colors.Info
    Write-Host "  • Password: soul" -ForegroundColor $colors.Info
    Write-Host ""
    Write-Host "  For GUI apps, install WSLg or VcXsrv." -ForegroundColor $colors.Warning
    Write-Host ""
}

function Uninstall-SoulOS {
    Write-Banner
    Write-Step "Uninstalling Soul OS..." "WAIT"
    
    # Unregister WSL distribution
    wsl --unregister SoulOS 2>$null
    
    # Remove install directory
    if (Test-Path $InstallPath) {
        Remove-Item $InstallPath -Recurse -Force
    }
    
    # Remove shortcuts
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    Remove-Item (Join-Path $desktopPath "Soul OS.lnk") -Force -ErrorAction SilentlyContinue
    
    $startMenuPath = [Environment]::GetFolderPath("Programs")
    Remove-Item (Join-Path $startMenuPath "Soul OS") -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Step "Soul OS uninstalled successfully" "SUCCESS"
}

# Main execution
Clear-Host
Write-Banner

if ($Uninstall) {
    Uninstall-SoulOS
    exit 0
}

Write-Host "  Installation Path: $InstallPath" -ForegroundColor $colors.Info
Write-Host ""

# Check requirements
if (-not (Test-SystemRequirements)) {
    Write-Step "System requirements not met" "ERROR"
    exit 1
}

# Enable WSL
Enable-WSL

# Download Soul OS
$rootfsPath = Get-SoulOS
if (-not $rootfsPath) {
    Write-Step "Failed to download Soul OS" "ERROR"
    exit 1
}

# Install distribution
if (-not (Install-SoulOSDistro -RootfsPath $rootfsPath)) {
    Write-Step "Installation failed" "ERROR"
    exit 1
}

# Create shortcuts
Create-Shortcuts

# Show completion
Show-CompletionMessage

Write-Host "Press any key to exit..." -ForegroundColor $colors.Info
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
