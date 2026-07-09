# AGENTS.md - labwc-android Desktop Project

## Project Overview

**Goal:** Build a native Wayland desktop environment on Android using labwc-android, providing GPU-accelerated Linux desktop rendering similar to Termux-X11 but for Wayland protocol.

**Architecture:**
```
Android Device
├── labwc-android App (Native Wayland Compositor)
│   └── SurfaceView (GPU-accelerated via AHB+SC)
├── Termux (Wayland clients connect here)
│   └── labwc (Wayland compositor)
│       ├── foot (terminal)
│       ├── rofi (launcher)
│       ├── dunst (notifications)
│       └── tint2 (panel via XWayland)
└── Arch Linux ARM (proot-distro)
    └── Desktop applications
```

## Environment Details

**Host Layer:**
- Android (ARM64/AArch64)
- Termux terminal
- proot-distro v5.4.0

**Container Layer:**
- Arch Linux ARM (ALARM)
- proot with --shared-tmp

**Display Layer:**
- Termux-X11 (display :0)
- picom compositor (host)

**Graphics:**
- virgl_test_server_android (--angle-gl)
- Mesa GPU drivers

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

### Phase 7: Testing & Deployment ⏳
- [ ] Push to GitHub remote
- [ ] Trigger GitHub Actions build
- [ ] Download APK and install on Android
- [ ] Test Wayland compositor startup
- [ ] Test proot connection
- [ ] Verify GPU acceleration

## Known Issues

1. **Pacman Sandbox:** Landlock not supported in proot - fixed with DisableSandbox flags
2. **Hyprland Compatibility:** caelestia-shell requires Hyprland which needs real GPU access - NOT compatible with proot
3. **labwc-android Maturity:** Experimental project, may have bugs

## Architecture Decisions

1. **labwc over Hyprland:** labwc works in proot with software rendering; Hyprland's aquamarine backend requires real GPU
2. **Native Wayland over X11:** Better performance, no X11 translation layer
3. **GitHub Actions for Build:** Avoids need for Android SDK/NDK in Termux

## Commands Reference

```bash
# Enter project directory
cd ~/project

# Build labwc-android locally (if Android SDK available)
cd labwc-android && ./gradlew assembleDebug

# Start desktop (once scripts are created)
~/project/scripts/desktop.sh start

# Stop desktop
~/project/scripts/desktop.sh stop

# Check status
~/project/scripts/desktop.sh status
```

## Next Steps

1. Push to GitHub remote repository
2. Trigger GitHub Actions build
3. Download APK and install on Android device
4. Test Wayland compositor startup
5. Test proot connection
6. Verify GPU acceleration

---

**Last Updated:** 2026-07-09
**Status:** Complete - Ready for GitHub Push
