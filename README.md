# LabWC Android

> Native Wayland Desktop Environment for Android — GPU-accelerated Linux desktop via Termux + Arch Linux ARM

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Arch Linux ARM](https://img.shields.io/badge/Arch%20Linux-ARM-blue)](https://archlinuxarm.org)
[![Wayland](https://img.shields.io/badge/Wayland-labwc-green)](https://labwc.org)
[![Termux](https://img.shields.io/badge/Termux-X11-orange)](https://termux.dev)

## What is LabWC Android?

LabWC Android brings a **native Wayland desktop environment** to Android devices. Unlike X11-based solutions that suffer from latency and overhead, LabWC Android uses a native Wayland pipeline with GPU acceleration for a true desktop experience on your phone or tablet.

### Key Features

- **Zero-Copy GPU Rendering** — AHardwareBuffer integration for direct display output
- **Native Wayland Compositor** — labwc provides modern desktop features
- **Arch Linux ARM** — Full access to thousands of packages via pacman
- **LXQt Desktop** — Complete desktop with panel, app launcher, and notifications
- **Audio Support** — PulseAudio integration for seamless audio
- **One-Click Setup** — Single command installation

## Quick Start

### Prerequisites

- Android device with ARM64 processor (4GB+ RAM recommended)
- [Termux](https://f-droid.org/en/packages/com.termux/) app (v0.118.0+)
- [Termux-X11](https://github.com/termux/termux-x11) app
- 3GB+ free storage space
- Internet connection

### Installation

```bash
# Clone the repository
git clone https://github.com/adittaya/labwc-android.git
cd labwc-android

# Run the setup script
bash setup.sh
```

### Usage

```bash
# 1. Start all host services
start-all

# 2. Enter the Arch Linux container
proot-distro login archlinuxarm --shared-tmp

# 3. Start the desktop (inside the container)
desktop start

# 4. Open Termux-X11 app on Android
```

## Commands

### Host Commands (Termux)

| Command | Description |
|---------|-------------|
| `start-all` | Start all host services |
| `start-audio` | Start PulseAudio |
| `start-display` | Start X11 display |
| `start-graphics` | Start VirGL GPU |
| `start-wayland` | Start Wayland bridge |
| `fix-desktop` | Full environment recovery |

### Container Commands (Arch Linux)

| Command | Description |
|---------|-------------|
| `desktop start` | Start desktop |
| `desktop stop` | Stop desktop |
| `desktop restart` | Restart desktop |
| `desktop status` | Check status |

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  Android Device                  │
├─────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐               │
│  │ Termux-X11  │  │ PulseAudio  │               │
│  │   (Display) │  │   (Audio)   │               │
│  └──────┬──────┘  └──────┬──────┘               │
│         │                 │                      │
│  ┌──────┴─────────────────┴──────┐               │
│  │     VirGL (GPU Bridge)        │               │
│  └──────────────┬────────────────┘               │
│                 │                                │
│  ┌──────────────┴────────────────┐               │
│  │    Proot Arch Linux ARM       │               │
│  │  ┌────────────────────────┐   │               │
│  │  │   wlroots-android      │   │               │
│  │  │   bridge               │   │               │
│  │  └───────────┬────────────┘   │               │
│  │              │                │               │
│  │  ┌───────────┴────────────┐   │               │
│  │  │      labwc             │   │               │
│  │  │   (Wayland WM)        │   │               │
│  │  └───────────┬────────────┘   │               │
│  │              │                │               │
│  │  ┌───────────┴────────────┐   │               │
│  │  │  LXQt Desktop          │   │               │
│  │  │  tint2 | rofi | dunst  │   │               │
│  │  └────────────────────────┘   │               │
│  └───────────────────────────────┘               │
└─────────────────────────────────────────────────┘
```

## Troubleshooting

### Desktop doesn't start

```bash
# On Termux host
fix-desktop

# Re-enter container
proot-distro login archlinuxarm --shared-tmp
desktop start
```

### No audio

```bash
# Restart PulseAudio
pkill -9 -f pulseaudio
pulseaudio --start --exit-idle-time=-1 --system=false \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
    --disable-shm=yes
```

### GPU not working

```bash
# Check VirGL is running
ps aux | grep virgl

# Inside container, check environment
echo $GALLIUM_DRIVER  # Should show: virpipe
echo $MESA_GL_VERSION_OVERRIDE  # Should show: 4.0
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m "Add my feature"`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- [labwc](https://labwc.org) — Wayland compositor
- [Arch Linux ARM](https://archlinuxarm.org) — Linux distribution
- [Termux](https://termux.dev) — Android terminal emulator
- [wlroots-android-bridge](https://github.com/Xtr126/wlroots-android-bridge) — Wayland bridge
- [VirGL](https://github.com/nicknumb/virglrenderer-android) — GPU virtualization
