# 👻 Soul OS

> **Revolutionary lightweight Ubuntu-based operating system — Beautiful, Fast, Efficient. Zero bloat, maximum performance.**

![License](https://img.shields.io/badge/license-GPL--3.0-6B46C1)
![Ubuntu](https://img.shields.io/badge/base-Ubuntu%2022.04-00D9FF)
![Size](https://img.shields.io/badge/rootfs-1.1GB-FF0080)
![RAM](https://img.shields.io/badge/min%20RAM-2GB-00FF87)
![Status](https://img.shields.io/badge/status-stable-6B46C1)
![Platform](https://img.shields.io/badge/platform-WSL2%20%7C%20Bare%20Metal-00D9FF)

A blazing-fast, beautifully designed Linux distribution built from Ubuntu 22.04 LTS with extreme optimizations for performance and aesthetics. Soul OS delivers a premium desktop experience on hardware that other operating systems consider obsolete.

```
  ███████╗ ██████╗ ██╗   ██╗██╗          ██████╗ ███████╗
  ██╔════╝██╔═══██╗██║   ██║██║         ██╔═══██╗██╔════╝
  ███████╗██║   ██║██║   ██║██║         ██║   ██║███████╗
  ╚════██║██║   ██║██║   ██║██║         ██║   ██║╚════██║
  ███████║╚██████╔╝╚██████╔╝███████╗    ╚██████╔╝███████║
  ╚══════╝ ╚═════╝  ╚═════╝ ╚══════╝     ╚═════╝ ╚══════╝

               :: L u m i n o u s   2 2 . 0 4 ::
```

---

## ⚡ Demo & Highlights

🎯 **Soul OS runs butter-smooth on a 10-year-old laptop with 2GB RAM** — while Ubuntu Desktop struggles to open a browser.

✨ Experience a **glassmorphism desktop with smooth 60fps animations**, blur effects, rounded corners, and a cohesive dark theme — all running on integrated graphics.

| Metric | Soul OS 🚀 | Ubuntu Desktop 🐌 | Windows 11 💀 |
|--------|:---------:|:-----------------:|:------------:|
| Rootfs Size | **1.1 GB** | 4.7 GB | 15+ GB |
| Installed Size | **~3 GB** | 15 GB | 30+ GB |
| Idle RAM | **~300 MB** | 1.5 GB | 3+ GB |
| Boot Time | **8-12 sec** | 45+ sec | 60+ sec |
| Min RAM Required | **2 GB** | 4 GB | 4 GB |
| Min Storage | **10 GB** | 25 GB | 64 GB |

---

## 🚀 Quick Start - Windows Installation

### One-Line Install (PowerShell as Admin)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/vikrant-project/soul-os/main/windows_launcher/Install-SoulOS.ps1'))
```

### Manual Installation

1. **Download** `Install-SoulOS.bat` from [Releases](https://github.com/vikrant-project/soul-os/releases)
2. **Right-click** → **Run as Administrator**
3. **Wait** for installation to complete (~5 minutes)
4. **Launch** Soul OS from Desktop shortcut or run `wsl -d SoulOS`

### Default Credentials
- **Username:** `soul`
- **Password:** `soul`

---

## 🖥️ Bare Metal / USB Boot Installation

### Create Bootable USB

```bash
# On Linux
sudo dd if=soul_os_22.04_amd64.iso of=/dev/sdX bs=4M status=progress

# On Windows (using Rufus)
# 1. Download Rufus from https://rufus.ie
# 2. Select soul_os_22.04_amd64.iso
# 3. Select your USB drive
# 4. Click Start
```

### Boot and Install
1. Boot from USB (F12/F2/Del during startup)
2. Select "Install Soul OS"
3. Follow the graphical installer
4. Reboot and enjoy!

---

## 🧠 Features

### 🎨 Beautiful Desktop Environment

- **Window Manager:** Openbox with custom Soul OS theme
- **Compositor:** Picom with blur, shadows, rounded corners, fade animations
- **Panel:** Polybar with system stats, workspaces, date/time, volume, network
- **App Launcher:** Rofi with fuzzy search and glassmorphism theme
- **Notifications:** Dunst with slide-in animations and Soul OS styling
- **File Manager:** Thunar with custom icons and archive support

### 🎭 Smooth Animations

| Animation | Target FPS |
|-----------|:----------:|
| Window open/close | 60 fps |
| Window fade | 60 fps |
| Blur behind windows | Real-time |
| Rounded corners | Always |
| Shadow casting | Dynamic |
| Notification slide | 60 fps |
| Menu fade | 60 fps |

### 🎨 Color Palette

```
Primary    ████  #6B46C1  Deep Purple
Secondary  ████  #00D9FF  Cyan Blue
Accent     ████  #FF0080  Neon Pink
Background ████  #1A1A2E  Dark Charcoal
Surface    ████  #252538  Elevated Surface
Text       ████  #FFFFFF  Pure White
Success    ████  #00FF87  Emerald Green
Warning    ████  #FFB800  Amber
Error      ████  #FF3B3B  Red
```

### ⚡ Performance Optimizations

- **zRAM:** Compressed swap in RAM for low-memory systems
- **Swappiness:** Set to 10 (aggressive RAM preference)
- **I/O Scheduler:** Optimized for both SSD and HDD
- **Preload:** Frequently used apps preloaded into memory
- **Systemd:** Minimal services (~15 vs Ubuntu's ~80)
- **Kernel:** Stripped of unnecessary modules

### 🛡️ Security

- **UFW Firewall:** Enabled by default
- **Automatic Updates:** Security patches auto-applied
- **Minimal Attack Surface:** Only essential services running
- **No Telemetry:** Zero data collection, full privacy

### 📦 Pre-installed Applications

| Category | Applications |
|----------|-------------|
| **Web** | Firefox |
| **Files** | Thunar, File-Roller |
| **Media** | VLC, EOG (images), Evince (PDF) |
| **Office** | gedit (text editor), Calculator |
| **System** | GNOME System Monitor, Disks, Screenshot |
| **Terminal** | LXTerminal |
| **Settings** | LXAppearance, Openbox Config |

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Super + Return` | Open Terminal |
| `Super + E` | Open File Manager |
| `Super + D` | App Launcher (Rofi) |
| `Super + R` | Run Command |
| `Super + Tab` | Window Switcher |
| `Super + 1-4` | Switch Workspace |
| `Super + ↑` | Maximize Window |
| `Super + ←/→` | Tile Left/Right |
| `Alt + F4` | Close Window |
| `Super + L` | Lock Screen |
| `Print` | Screenshot Tool |
| `Alt + Drag` | Move Window |
| `Alt + Right Drag` | Resize Window |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Soul OS Desktop                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Polybar (Panel)       [Workspaces] [Date] [System]  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌─────────────────────────┐ ┌─────────────────────────┐   │
│  │                         │ │                         │   │
│  │   Application Window    │ │   Application Window    │   │
│  │   (with blur + shadow)  │ │   (with blur + shadow)  │   │
│  │                         │ │                         │   │
│  └─────────────────────────┘ └─────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Picom (Compositor)                       │   │
│  │    Blur • Shadows • Rounded Corners • Animations     │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Openbox (Window Manager)                 │   │
│  │         Window positioning • Keyboard bindings        │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              X.Org Display Server                     │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Linux Kernel 5.15+ (HWE)                      │   │
│  │    Optimized • Low-latency • Minimal modules          │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 System Requirements

### Minimum
- **CPU:** 1 GHz dual-core (x86_64)
- **RAM:** 2 GB
- **Storage:** 10 GB
- **Graphics:** Any with X.org support

### Recommended
- **CPU:** 2 GHz quad-core
- **RAM:** 4 GB
- **Storage:** 20 GB
- **Graphics:** Intel HD 4000+ / AMD / NVIDIA with open drivers

### For WSL2
- **Windows:** 10 version 1903+ or Windows 11
- **WSL2:** Enabled (installer handles this)
- **RAM:** 4 GB total (WSL gets 50%)

---

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `~/.config/openbox/rc.xml` | Window manager settings |
| `~/.config/openbox/autostart` | Startup applications |
| `~/.config/openbox/menu.xml` | Right-click menu |
| `~/.config/picom/picom.conf` | Compositor effects |
| `~/.config/polybar/config.ini` | Panel configuration |
| `~/.config/rofi/soul.rasi` | App launcher theme |
| `~/.config/dunst/dunstrc` | Notification settings |
| `~/.config/gtk-3.0/settings.ini` | GTK theme settings |

---

## 🛠️ Customization

### Change Wallpaper
```bash
feh --bg-fill /path/to/your/wallpaper.jpg
```

### Change Theme
```bash
lxappearance  # GUI theme switcher
```

### Edit Polybar
```bash
nano ~/.config/polybar/config.ini
# Then restart: killall polybar && polybar soul &
```

### Modify Animations
```bash
nano ~/.config/picom/picom.conf
# Change fade-in-step, fade-out-step, shadow-radius, blur-strength
```

---

## 🤝 Contributing

Contributions welcome! Areas where help is appreciated:

- 🎨 Additional themes and icon packs
- 📦 Application optimization scripts
- 🌍 Translations and localization
- 📖 Documentation improvements
- 🐛 Bug fixes and testing

### Building from Source

```bash
git clone https://github.com/vikrant-project/soul-os.git
cd soul-os
./scripts/build.sh
```

---

## 📜 License

Soul OS is released under the **GNU General Public License v3.0**.

Based on Ubuntu 22.04 LTS by Canonical Ltd.

---

## 🌟 Star History

If Soul OS made your old hardware useful again, give it a ⭐!

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/vikrant-project/soul-os/issues)
- **Discussions:** [GitHub Discussions](https://github.com/vikrant-project/soul-os/discussions)

---

<p align="center">
  <i>Built with 💜 for the minimalist computing experience.</i><br>
  <b>Soul OS — Give your hardware a second life.</b>
</p>
