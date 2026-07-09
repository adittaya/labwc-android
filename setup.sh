#!/usr/bin/env bash
# =============================================================================
# labwc-android Desktop - Complete Setup Script
# For: Termux on Android (ARM64/AArch64)
# =============================================================================
set -euo pipefail

# Colors
C_BLUE="\033[1;34m"
C_GREEN="\033[1;32m"
C_GOLD="\033[1;33m"
C_RED="\033[1;31m"
C_CYAN="\033[1;36m"
C_RESET="\033[0m"

banner() {
    clear
    echo -e "${C_BLUE}╔══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_GREEN}║       labwc-android Desktop - Complete Setup                ║${C_RESET}"
    echo -e "${C_GREEN}║       Native Wayland Desktop on Android                     ║${C_RESET}"
    echo -e "${C_BLUE}╚══════════════════════════════════════════════════════════════╝${C_RESET}"
    echo
}

log_info()  { echo -e "${C_GREEN}[*]${C_RESET} $1"; }
log_warn()  { echo -e "${C_GOLD}[!]${C_RESET} $1"; }
log_error() { echo -e "${C_RED}[✗]${C_RESET} $1"; }
log_done()  { echo -e "${C_GREEN}[✓]${C_RESET} $1"; }

# =============================================================================
# PHASE 1: Termux Host Setup
# =============================================================================
phase1_termux() {
    echo -e "\n${C_CYAN}═══ PHASE 1: Termux Host Setup ═══${C_RESET}\n"

    log_info "Updating Termux packages..."
    pkg update -y -qq && pkg upgrade -y -qq

    log_info "Installing repositories..."
    pkg install -y -qq x11-repo tur-repo

    log_info "Installing host-side packages..."
    pkg install -y -qq \
        proot-distro \
        termux-x11-nightly \
        virglrenderer-android \
        pulseaudio \
        picom \
        wget \
        curl \
        git \
        tar \
        xz-utils \
        sed \
        gawk \
        grep \
        coreutils \
        util-linux \
        ncurses-utils \
        findutils

    log_done "Termux host packages installed"
}

# =============================================================================
# PHASE 2: Create Host-Side Shortcut Commands
# =============================================================================
phase2_host_commands() {
    echo -e "\n${C_CYAN}═══ PHASE 2: Host-Side Commands ═══${C_RESET}\n"

    log_info "Generating host-side shortcut commands..."

    # --- start-audio ---
    cat > "$PREFIX/bin/start-audio" << 'AUDIO'
#!/usr/bin/env bash
echo "[*] Starting PulseAudio engine..."
pkill -9 -f pulseaudio 2>/dev/null
sleep 1
pulseaudio --start --exit-idle-time=-1 --system=false \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
    --disable-shm=yes 2>/dev/null
echo "[+] PulseAudio running on 127.0.0.1"
AUDIO
    chmod +x "$PREFIX/bin/start-audio"

    # --- start-display ---
    cat > "$PREFIX/bin/start-display" << 'DISPLAY'
#!/usr/bin/env bash
echo "[*] Starting X11 display..."
pkill -9 -f termux-x11 2>/dev/null
pkill -9 -f picom 2>/dev/null
rm -f /tmp/.X0-lock /tmp/.X11-unix/X0 2>/dev/null
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
sleep 5
export XDG_RUNTIME_DIR="${TMPDIR}"
termux-x11 :0 -ac &
sleep 2
picom --backend xrender --vsync &
echo "[+] X11 display active on :0"
DISPLAY
    chmod +x "$PREFIX/bin/start-display"

    # --- start-graphics ---
    cat > "$PREFIX/bin/start-graphics" << 'GRAPHICS'
#!/usr/bin/env bash
echo "[*] Starting VirGL GPU acceleration..."
pkill -9 -f virgl_test_server 2>/dev/null
sleep 1
export XDG_RUNTIME_DIR="${TMPDIR}"
virgl_test_server_android --angle-gl &
sleep 1
echo "[+] VirGL GPU engine active"
GRAPHICS
    chmod +x "$PREFIX/bin/start-graphics"

    # --- start-wayland ---
    cat > "$PREFIX/bin/start-wayland" << 'WAYLAND'
#!/usr/bin/env bash
echo "[*] Starting Wayland compositor..."
pkill -9 -f wlroots-android-bridge 2>/dev/null
pkill -9 -f labwc 2>/dev/null
sleep 1
wlroots-android-bridge &
sleep 2
labwc &
echo "[+] Wayland compositor active (WAYLAND_DISPLAY=wayland-0)"
WAYLAND
    chmod +x "$PREFIX/bin/start-wayland"

    # --- fix-desktop ---
    cat > "$PREFIX/bin/fix-desktop" << 'FIXER'
#!/usr/bin/env bash
echo "[!] Full environment recovery..."
pkill -9 -f termux-x11 2>/dev/null
pkill -9 -f virgl_test_server 2>/dev/null
pkill -9 -f pulseaudio 2>/dev/null
pkill -9 -f picom 2>/dev/null
pkill -9 -f wlroots-android-bridge 2>/dev/null
pkill -9 -f labwc 2>/dev/null
rm -f /tmp/.X0-lock /tmp/.X11-unix/X0 2>/dev/null
sleep 2
pulseaudio --start --exit-idle-time=-1 --system=false \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
    --disable-shm=yes 2>/dev/null
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
sleep 3
export XDG_RUNTIME_DIR="${TMPDIR}"
termux-x11 :0 -ac &
sleep 2
virgl_test_server_android --angle-gl &
picom --backend xrender --vsync &
echo "[+] All services recovered!"
FIXER
    chmod +x "$PREFIX/bin/fix-desktop"

    # --- start-all ---
    cat > "$PREFIX/bin/start-all" << 'STARTALL'
#!/usr/bin/env bash
echo "[*] Starting all host services..."
start-audio
sleep 1
start-display
sleep 1
start-graphics
echo "[+] All host services started!"
echo "    Run: proot-distro login archlinuxarm --shared-tmp"
STARTALL
    chmod +x "$PREFIX/bin/start-all"

    log_done "Host-side commands created"
    log_info "Commands: start-audio | start-display | start-graphics | start-wayland | start-all | fix-desktop"
}

# =============================================================================
# PHASE 3: Proot Arch Linux Container Setup
# =============================================================================
phase3_proot_container() {
    echo -e "\n${C_CYAN}═══ PHASE 3: Proot Arch Linux Container ═══${C_RESET}\n"

    log_info "Cleaning previous installations..."
    pkill -9 -f proot 2>/dev/null || true
    proot-distro remove archlinuxarm 2>/dev/null || true
    proot-distro remove archlinux 2>/dev/null || true

    log_info "Installing Arch Linux ARM container..."
    proot-distro install archlinuxarm

    log_done "Arch Linux ARM container installed"
}

# =============================================================================
# PHASE 4: Configure Container Desktop Environment
# =============================================================================
phase4_configure_container() {
    echo -e "\n${C_CYAN}═══ PHASE 4: Container Desktop Configuration ═══${C_RESET}\n"

    log_info "Configuring Arch Linux container..."

    proot-distro login archlinuxarm --shared-tmp -- bash -c '
set -e

# Fix pacman sandbox
sed -i "s/NoSandbox/DisableSandboxFilesystem\nDisableSandboxSyscalls/" /etc/pacman.conf 2>/dev/null || true
grep -q "DisableSandboxFilesystem" /etc/pacman.conf || echo "DisableSandboxFilesystem" >> /etc/pacman.conf
grep -q "DisableSandboxSyscalls" /etc/pacman.conf || echo "DisableSandboxSyscalls" >> /etc/pacman.conf
sed -i "s/^NoSandbox/#NoSandbox/" /etc/pacman.conf 2>/dev/null || true

# Initialize package manager
pacman-key --init
pacman-key --populate archlinuxarm

# Update system
pacman -Syu --noconfirm

# Install desktop environment packages
pacman -S --noconfirm \
    openbox \
    tint2 \
    rofi \
    dunst \
    picom \
    feh \
    nitrogen \
    lxappearance \
    lxqt \
    qterminal \
    pcmanfm \
    dbus \
    xorg-server-xwayland \
    xorg-xrdb \
    xorg-xset \
    hicolor-icon-theme \
    papirus-icon-theme \
    ttf-font \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-cjk \
    ttf-cascadia-code-nerd \
    base-devel \
    cmake \
    ninja \
    meson \
    gcc \
    make \
    pkg-config \
    git \
    wget \
    curl \
    vim \
    nano \
    sudo

# Create non-root user
if ! id -u user &>/dev/null; then
    useradd -m -G wheel -s /bin/bash user
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# Create desktop command inside container
cat > /usr/local/bin/desktop << '\''DESKTOPCMD'\''
#!/usr/bin/env bash
# desktop - Wayland Desktop Launcher (runs inside proot)
set -e

C_BLUE="\033[1;34m"
C_GREEN="\033[1;32m"
C_GOLD="\033[1;33m"
C_RED="\033[1;31m"
C_RESET="\033[0m"

WAYLAND_DISPLAY="wayland-0"
XDG_RUNTIME_DIR="/tmp/wayland-0"

case "${1:-start}" in
    start)
        echo -e "${C_GREEN}[*]${C_RESET} Starting desktop environment..."

        # Create runtime dir
        mkdir -p "$XDG_RUNTIME_DIR"
        chmod 700 "$XDG_RUNTIME_DIR"

        # Set environment
        export WAYLAND_DISPLAY
        export XDG_RUNTIME_DIR
        export XDG_SESSION_TYPE=wayland
        export MOZ_ENABLE_WAYLAND=1
        export QT_QPA_PLATFORM=wayland
        export SDL_VIDEODRIVER=wayland

        # Start labwc
        if command -v labwc &>/dev/null; then
            echo -e "${C_GREEN}[*]${C_RESET} Starting labwc window manager..."
            labwc &
            sleep 2
        fi

        # Start tint2 panel (via XWayland)
        if command -v tint2 &>/dev/null; then
            echo -e "${C_GREEN}[*]${C_RESET} Starting tint2 panel..."
            DISPLAY=:0 tint2 &
            sleep 1
        fi

        # Start dunst notifications
        if command -v dunst &>/dev/null; then
            echo -e "${C_GREEN}[*]${C_RESET} Starting dunst notifications..."
            dunst &
            sleep 1
        fi

        echo -e "${C_GREEN}[✓]${C_RESET} Desktop environment started!"
        echo -e "  Wayland Display: $WAYLAND_DISPLAY"
        echo -e "  Runtime Dir: $XDG_RUNTIME_DIR"
        ;;

    stop)
        echo -e "${C_GOLD}[*]${C_RESET} Stopping desktop environment..."
        killall labwc 2>/dev/null || true
        killall tint2 2>/dev/null || true
        killall dunst 2>/dev/null || true
        rm -f "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" 2>/dev/null || true
        echo -e "${C_GREEN}[✓]${C_RESET} Desktop stopped"
        ;;

    status)
        echo -e "${C_GREEN}[*]${C_RESET} Desktop Status:"
        echo "  Wayland: ${WAYLAND_DISPLAY}"
        echo "  Runtime: ${XDG_RUNTIME_DIR}"
        pgrep -x labwc >/dev/null && echo "  labwc:   RUNNING" || echo "  labwc:   STOPPED"
        pgrep -x tint2 >/dev/null  && echo "  tint2:   RUNNING" || echo "  tint2:   STOPPED"
        pgrep -x dunst >/dev/null  && echo "  dunst:   RUNNING" || echo "  dunst:   STOPPED"
        ;;

    restart)
        $0 stop
        sleep 2
        $0 start
        ;;

    *)
        echo "Usage: desktop {start|stop|restart|status}"
        exit 1
        ;;
esac
DESKTOPCMD
    chmod +x /usr/local/bin/desktop

    # Set environment variables in bashrc
    touch ~/.bashrc
    grep -q "WAYLAND_DISPLAY" ~/.bashrc 2>/dev/null || echo "export WAYLAND_DISPLAY=wayland-0" >> ~/.bashrc
    grep -q "XDG_RUNTIME_DIR" ~/.bashrc 2>/dev/null || echo "export XDG_RUNTIME_DIR=/tmp/wayland-0" >> ~/.bashrc
    grep -q "XDG_SESSION_TYPE" ~/.bashrc 2>/dev/null || echo "export XDG_SESSION_TYPE=wayland" >> ~/.bashrc
    grep -q "PULSE_SERVER" ~/.bashrc 2>/dev/null || echo "export PULSE_SERVER=127.0.0.1" >> ~/.bashrc
    grep -q "DISPLAY" ~/.bashrc 2>/dev/null || echo "export DISPLAY=:0" >> ~/.bashrc
    grep -q "GALLIUM_DRIVER" ~/.bashrc 2>/dev/null || echo "export GALLIUM_DRIVER=virpipe" >> ~/.bashrc
    grep -q "MESA_GL_VERSION_OVERRIDE" ~/.bashrc 2>/dev/null || echo "export MESA_GL_VERSION_OVERRIDE=4.0" >> ~/.bashrc

    # Configure foot terminal
    mkdir -p ~/.config/foot
    cat > ~/.config/foot/foot.ini << '\''FOOT'\''
[main]
term=xterm-256color
font=CaskaydiaCove Nerd Font:size=12

[scrollback]
lines=10000

[cursor]
style=beam
blink=yes
FOOT

    # Configure tint2
    mkdir -p ~/.config/tint2
    cat > ~/.config/tint2/tint2rc << '\''TINT2'\''
panel_monitor = all
panel_position = bottom center horizontal
panel_layer = top
panel_size = 100% 32
panel_margin = 0 0
panel_padding = 8 0 8
taskbar_mode = single_desktop
task_text = 1
task_icon = 1
task_centered = 1
task_font = CaskaydiaCove Nerd Font
task_font_size = 12
clock_font_color = #cdd6f4
clock_padding = 8 4
systray_padding = 8 4 8
launcher_padding = 8 4 8
launcher_icon_size = 20
TINT2

    # Configure dunst
    mkdir -p ~/.config/dunst
    cat > ~/.config/dunst/dunstrc << '\''DUNST'\''
[global]
    width = 300
    height = (0,300)
    origin = top-right
    offset = 16x16
    notification_limit = 5
    frame_width = 2
    frame_color = #89b4fa
    corner_radius = 8
    padding = 16
    horizontal_padding = 16
    separator_height = 2
    gap_size = 8

[urgency_low]
    background = #1e1e2e
    foreground = #cdd6f4
    timeout = 5

[urgency_normal]
    background = #1e1e2e
    foreground = #cdd6f4
    frame_color = #89b4fa
    timeout = 10

[urgency_critical]
    background = #1e1e2e
    foreground = #cdd6f4
    frame_color = #f38ba8
    timeout = 0
DUNST

    # Configure rofi
    mkdir -p ~/.config/rofi
    cat > ~/.config/rofi/config.rasi << '\''ROFI'\''
configuration {
    modi: "drun,run,window";
    show-icons: true;
    icon-theme: "Papirus";
    font: "CaskaydiaCove Nerd Font 14";
}

* {
    bg:     #1e1e2e;
    fg:     #cdd6f4;
    accent: #89b4fa;
}

window {
    width: 600px;
    background-color: @bg;
    border: 2px;
    border-color: @accent;
    border-radius: 12px;
    padding: 20px;
    location: center;
    anchor: center;
}
ROFI

    echo "Container configuration complete!"
'

    log_done "Container desktop environment configured"
}

# =============================================================================
# PHASE 5: Final Instructions
# =============================================================================
phase5_instructions() {
    echo -e "\n${C_CYAN}═══ SETUP COMPLETE ═══${C_RESET}\n"

    echo -e "${C_GREEN}╔══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_GREEN}║                  SETUP COMPLETE!                            ║${C_RESET}"
    echo -e "${C_GREEN}╚══════════════════════════════════════════════════════════════╝${C_RESET}"
    echo
    echo -e "${C_GOLD}Step 1: Start all host services:${C_RESET}"
    echo -e "  ${C_GREEN}start-all${C_RESET}"
    echo
    echo -e "${C_GOLD}Step 2: Enter the container:${C_RESET}"
    echo -e "  ${C_GREEN}proot-distro login archlinuxarm --shared-tmp${C_RESET}"
    echo
    echo -e "${C_GOLD}Step 3: Start the desktop (inside container):${C_RESET}"
    echo -e "  ${C_GREEN}desktop start${C_RESET}"
    echo
    echo -e "${C_GOLD}Step 4: Open Termux-X11 app on Android${C_RESET}"
    echo
    echo -e "${C_GOLD}Other commands:${C_RESET}"
    echo -e "  ${C_GREEN}desktop stop${C_RESET}      - Stop desktop"
    echo -e "  ${C_GREEN}desktop status${C_RESET}    - Check status"
    echo -e "  ${C_GREEN}desktop restart${C_RESET}   - Restart desktop"
    echo -e "  ${C_GREEN}fix-desktop${C_RESET}       - Full environment recovery"
    echo
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    banner
    phase1_termux
    phase2_host_commands
    phase3_proot_container
    phase4_configure_container
    phase5_instructions
}

main "$@"
