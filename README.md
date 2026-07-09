# labwc-android Desktop Project

A native Wayland desktop environment for Android using labwc-android, providing GPU-accelerated Linux desktop rendering.

## Features

- **Native Wayland compositor** - No X11 translation layer
- **GPU acceleration** - Zero-copy rendering via AHardwareBuffer + SurfaceControl
- **caelestia-inspired theme** - Dark theme with blue accents
- **Complete desktop** - Panel, launcher, notifications, wallpaper
- **GitHub Actions** - Automatic APK builds

## Architecture

```
Android Device
├── labwc-android App (Native Wayland Compositor)
│   └── SurfaceView (GPU-accelerated)
├── Termux (Wayland clients)
│   ├── foot (terminal)
│   ├── rofi (launcher)
│   ├── dunst (notifications)
│   └── tint2 (panel)
└── Arch Linux ARM (proot-distro)
    └── Desktop applications
```

## Quick Start

### 1. Setup Termux
```bash
~/project/scripts/setup-termux.sh
```

### 2. Setup Proot
```bash
~/project/scripts/setup-proot.sh
```

### 3. Start Desktop
```bash
desktop start
```

### 4. Stop Desktop
```bash
desktop stop
```

## Building labwc-android

### Option A: GitHub Actions (Recommended)
1. Fork this repository
2. Enable GitHub Actions
3. The APK will be built automatically
4. Download from Actions → Artifacts

### Option B: Local Build
```bash
cd labwc-android
./gradlew assembleDebug
```

## Configuration

Configuration files are in `configs/`:
- `labwc/` - Window manager theme and shortcuts
- `tint2/` - Panel configuration
- `rofi/` - Application launcher
- `dunst/` - Notification daemon

## Keybinds

| Key | Action |
|-----|--------|
| `Super + Enter` | Open terminal |
| `Alt + F2` | Open launcher |
| `Alt + F4` | Close window |
| `Super + 1-5` | Switch workspace |
| `Super + F` | Maximize |
| `Super + F11` | Fullscreen |

## Requirements

- Android 8.0+
- Termux
- labwc-android app (build from source or download APK)
- Arch Linux ARM (proot-distro)

## License

GPL-3.0

## Credits

- [labwc-android](https://github.com/Xtr126/labwc-android) - Wayland compositor
- [wlroots-android-bridge](https://github.com/Xtr126/wlroots-android-bridge) - GPU acceleration
- [caelestia-dots](https://github.com/caelestia-dots) - Theme inspiration
