# Changelog

All notable changes to Soul OS will be documented in this file.

## [22.04.1] - 2026-05-22

### Added
- Initial release based on Ubuntu 22.04 LTS
- Custom Openbox desktop environment
- Picom compositor with blur, shadows, animations
- Polybar panel with Soul OS theme
- Rofi app launcher with glassmorphism
- Dunst notification daemon
- Plymouth boot splash
- LightDM greeter customization
- WSL2 support with Windows installer
- Performance optimizations (zRAM, swappiness, etc.)
- Custom color scheme (purple, cyan, pink palette)
- Keyboard shortcuts configuration
- Pre-installed essential applications

### Optimizations
- Reduced rootfs from 4.7GB to 1.1GB
- Idle RAM usage ~300MB vs ~1.5GB
- Boot time 8-12 seconds vs 45+ seconds
- Minimal systemd services

### Known Issues
- GUI apps in WSL2 require WSLg or X server
- Some theme elements may not apply to all GTK apps

## Roadmap

### [22.04.2] - Planned
- Custom ISO bootable image
- More theme variants
- Additional wallpapers
- Performance mode switching
