# AGENTS.md - labwc-android Desktop Project

## Project Overview

**Goal:** Build a native Wayland desktop environment on Android using labwc-android, providing GPU-accelerated Linux desktop rendering similar to Termux-X11 but for Wayland protocol.

**Architecture:**
```
Android Device
├── Termux (Host Layer)
│   ├── start-audio (PulseAudio)
│   ├── start-display (Termux-X11 + picom)
│   ├── start-graphics (VirGL GPU)
│   └── start-wayland (wlroots-android-bridge)
├── Proot Container (Arch Linux ARM)
│   ├── labwc (Wayland Compositor)
│   ├── LXQt Desktop
│   │   ├── tint2 (Panel)
│   │   ├── rofi (Launcher)
│   │   ├── dunst (Notifications)
│   │   └── pcmanfm (File Manager)
│   └── desktop command (Container-level control)
└── Termux-X11 App (Android Display)
```

## Environment Details

**Host Layer:**
- Android (ARM64/AArch64)
- Termux terminal (v0.118.0+)
- proot-distro v5.4.0

**Container Layer:**
- Arch Linux ARM (ALARM)
- proot with --shared-tmp
- LXQt + Openbox desktop

**Display Layer:**
- Termux-X11 (display :0)
- picom compositor (host)
- wlroots-android-bridge (Wayland bridge)

**Graphics:**
- virgl_test_server_android (--angle-gl)
- Mesa GPU drivers (virpipe)

**Audio:**
- PulseAudio (TCP on 127.0.0.1)

## Progress Log

### Phase 1: Project Setup ✅
- [x] Created project directory structure at ~/project/
- [x] Created configs/ directory for labwc, tint2, rofi, dunst
- [x] Created scripts/ directory for launcher scripts
- [x] Created .github/workflows/ for CI/CD

### Phase 2: Repository Setup ✅
- [x] Installed git in Arch Linux ARM container
- [x] Fixed pacman sandbox issues (DisableSandboxFilesystem/DisableSandboxSyscalls)
- [x] Cloned Xtr126/labwc-android repository

### Phase 3: GitHub Actions ✅
- [x] Created build.yml workflow
- [x] Configured JDK 17 + Android SDK
- [x] Added NDK installation step
- [x] Configured APK artifact upload
- [x] Added release publishing on main branch pushes

### Phase 4: Desktop Launcher Scripts ✅
- [x] Create desktop.sh main launcher
- [x] Create setup-termux.sh for package installation
- [x] Create setup-proot.sh for proot configuration
- [x] Create global 'desktop' command in /usr/local/bin/

### Phase 5: Configuration Files ✅
- [x] labwc/ - Window manager config (rc.xml, themerc)
- [x] tint2/ - Panel configuration (tint2rc)
- [x] rofi/ - Application launcher (config.rasi)
- [x] dunst/ - Notification daemon (dunstrc)

### Phase 6: Git Repository ✅
- [x] Initialize git repository
- [x] Add labwc-android as submodule
- [x] Create initial commit
- [x] Create README.md and .gitignore

### Phase 7: Complete Setup Script ✅
- [x] Created setup.sh - One-click installer
- [x] Integrated Termux host setup
- [x] Created host-side commands (start-audio, start-display, etc.)
- [x] Automated proot container installation
- [x] Automated container desktop configuration
- [x] Created 'desktop' command inside proot container

### Phase 8: Documentation Website ✅
- [x] Created SEO-optimized website (docs/index.html)
- [x] Added Quick Start Guide
- [x] Added Architecture diagrams
- [x] Added Command Reference tables
- [x] Added Troubleshooting section
- [x] Added FAQ section
- [x] Enabled GitHub Pages

### Phase 9: GitHub Deployment ✅
- [x] Created GitHub repository: adittaya/labwc-android
- [x] Pushed all code to master branch
- [x] Enabled GitHub Pages
- [x] Website live at: https://adittaya.github.io/labwc-android/

## Files Structure

```
labwc-android/
├── AGENTS.md              # This file - project tracker
├── README.md              # Comprehensive documentation
├── setup.sh               # One-click installer script
├── docs/
│   └── index.html         # SEO website with guides
├── configs/
│   ├── labwc/
│   │   ├── rc.xml         # Window manager config
│   │   └── themerc        # Theme configuration
│   ├── tint2/
│   │   └── tint2rc        # Panel configuration
│   ├── rofi/
│   │   └── config.rasi    # App launcher config
│   └── dunst/
│       └── dunstrc        # Notification config
├── scripts/
│   ├── desktop.sh         # Main launcher
│   ├── setup-termux.sh    # Termux installer
│   └── setup-proot.sh     # Proot configurator
├── labwc-android/         # Git submodule (Xtr126/labwc-android)
└── .github/
    └── workflows/
        └── build.yml      # GitHub Actions workflow
```

## Commands Reference

### Host Commands (Termux)
```bash
start-all        # Start all host services
start-audio      # Start PulseAudio
start-display    # Start X11 display + picom
start-graphics   # Start VirGL GPU
start-wayland    # Start Wayland bridge
fix-desktop      # Full environment recovery
```

### Container Commands (Arch Linux)
```bash
desktop start    # Start desktop environment
desktop stop     # Stop desktop environment
desktop restart  # Restart desktop environment
desktop status   # Check desktop status
```

### Usage Flow
```bash
# 1. Run setup (first time only)
git clone https://github.com/adittaya/labwc-android.git
cd labwc-android
bash setup.sh

# 2. Start host services
start-all

# 3. Enter container
proot-distro login archlinuxarm --shared-tmp

# 4. Start desktop
desktop start

# 5. Open Termux-X11 app on Android
```

## Known Issues

1. **Pacman Sandbox:** Landlock not supported in proot - fixed with DisableSandbox flags
2. **Hyprland Compatibility:** caelestia-shell requires Hyprland which needs real GPU access - NOT compatible with proot
3. **labwc-android Maturity:** Experimental project, may have bugs
4. **wlroots-android-bridge:** May need custom build from Xtr126/termux-packages

## Architecture Decisions

1. **labwc over Hyprland:** labwc works in proot with software rendering; Hyprland's aquamarine backend requires real GPU
2. **Native Wayland over X11:** Better performance, no X11 translation layer
3. **GitHub Actions for Build:** Avoids need for Android SDK/NDK in Termux
4. **One-Click Setup:** Single script handles all installation and configuration
5. **Container-Level Desktop:** 'desktop' command runs inside proot for proper environment

## Next Steps

1. [ ] Test setup.sh on real Android device
2. [ ] Verify wlroots-android-bridge availability in Termux repos
3. [ ] Test Wayland compositor startup
4. [ ] Verify GPU acceleration with VirGL
5. [ ] Add more desktop customization options
6. [ ] Create video tutorial
7. [ ] Submit to F-Droid or Termux repos

---

**Last Updated:** 2026-07-09
**Status:** Complete - Deployed to GitHub
**Repository:** https://github.com/adittaya/labwc-android
**Website:** https://adittaya.github.io/labwc-android/
