# Soul OS Installation Guide

## Windows Installation (WSL2)

### Prerequisites
- Windows 10 version 1903 or higher (Build 18362+)
- Windows 11 (any version)
- Administrator privileges
- 20GB free disk space
- 4GB RAM (2GB minimum for Soul OS)

### Method 1: One-Line Install

1. Open **PowerShell as Administrator**
2. Copy and paste:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/vikrant-project/soul-os/main/windows_launcher/Install-SoulOS.ps1'))
```

3. Wait for installation to complete
4. Launch from Desktop shortcut or run `wsl -d SoulOS`

### Method 2: Manual Download

1. Download `Install-SoulOS.bat` from Releases
2. Right-click → Run as Administrator
3. Follow on-screen instructions

### Uninstallation

Run `Uninstall-SoulOS.bat` as Administrator, or:

```powershell
wsl --unregister SoulOS
Remove-Item -Recurse "$env:USERPROFILE\SoulOS"
```

---

## Bare Metal Installation

### Create Bootable USB

#### On Linux:
```bash
sudo dd if=soul_os_22.04_amd64.iso of=/dev/sdX bs=4M status=progress sync
```

#### On Windows:
1. Download [Rufus](https://rufus.ie)
2. Select `soul_os_22.04_amd64.iso`
3. Select USB drive
4. Click Start

### Installation Steps

1. Boot from USB (F12/F2/Del during startup)
2. Select "Install Soul OS" from boot menu
3. Choose language and keyboard
4. Select installation disk
5. Create user account
6. Wait for installation
7. Reboot and remove USB

---

## Virtual Machine Installation

### VirtualBox
1. Create new VM: Linux, Ubuntu 64-bit
2. RAM: 2048MB minimum
3. Disk: 20GB minimum (VDI, dynamic)
4. Mount ISO and boot
5. Install as normal

### VMware
1. Create new VM: Linux, Ubuntu 64-bit
2. RAM: 2048MB
3. Disk: 20GB
4. Mount ISO and install

---

## Post-Installation

### First Login
- Username: `soul`
- Password: `soul`

**Change your password immediately:**
```bash
passwd
```

### Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### Install Additional Software
```bash
# Flatpak apps
flatpak install flathub com.spotify.Client

# APT packages
sudo apt install neovim
```
