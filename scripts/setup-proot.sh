#!/bin/bash
# setup-proot.sh - Configure Arch Linux ARM proot for Wayland desktop
# This script sets up the proot environment for labwc-android

set -e

echo "=========================================="
echo "  labwc-android Proot Setup"
echo "=========================================="
echo

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    log_error "This script must be run in Termux"
    exit 1
fi

# Check if proot-distro is installed
if ! command -v proot-distro &> /dev/null; then
    log_error "proot-distro not found. Run: pkg install proot-distro"
    exit 1
fi

log_info "Checking Arch Linux installation..."
if ! proot-distro list | grep -q "archlinux"; then
    log_info "Installing Arch Linux ARM..."
    proot-distro install archlinux
fi

log_info "Setting up Arch Linux for Wayland desktop..."

# Create setup script to run inside proot
cat > /tmp/arch-setup.sh << 'PROOT_EOF'
#!/bin/bash
set -e

echo "Setting up Arch Linux for Wayland desktop..."

# Update system
pacman -Syu --noconfirm

# Install base packages
pacman -S --noconfirm \
    base-devel \
    git \
    wget \
    curl \
    sudo \
    nano \
    vim

# Create non-root user (optional, for development)
if ! id -u user &>/dev/null; then
    useradd -m -G wheel -s /bin/bash user
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# Install Wayland desktop packages
pacman -S --noconfirm \
    foot \
    rofi \
    dunst \
    feh \
    nitrogen \
    lxappearance \
    papirus-icon-theme \
    ttf-font \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-cjk

# Install XWayland support (for tint2 and other X11 apps)
pacman -S --noconfirm \
    xorg-server-xwayland \
    xorg-xrdb \
    xorg-xset

# Install development tools (optional)
pacman -S --noconfirm \
    cmake \
    ninja \
    meson \
    gcc \
    make \
    pkg-config

# Install Mesa for GPU support
pacman -S --noconfirm \
    mesa \
    libglvnd \
    libegl \
    libgles

# Configure environment variables
cat > /etc/profile.d/wayland.sh << 'ENV_EOF'
# Wayland environment variables
export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR=/tmp/wayland-0
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export ELM_ENGINE=wayland_egl
export ECORE_EVAS_ENGINE=wayland_egl
export ELM_ACCEL=opengl
ENV_EOF

# Create runtime directory
mkdir -p /tmp/wayland-0
chmod 700 /tmp/wayland-0

# Configure foot terminal
mkdir -p ~/.config/foot
cat > ~/.config/foot/foot.ini << 'FOOT_EOF'
[main]
term=xterm-256color
font=CaskaydiaCove Nerd Font:size=12

[scrollback]
lines=10000

[cursor]
style=beam
blink=yes

[mouse]
hide-when-typing=yes
FOOT_EOF

# Configure rofi
mkdir -p ~/.config/rofi
cat > ~/.config/rofi/config.rasi << 'ROFI_EOF'
configuration {
    modi: "drun,run,window";
    show-icons: true;
    icon-theme: "Papirus";
    font: "CaskaydiaCove Nerd Font 12";
}

* {
    bg:     #1e1e2e;
    fg:     #cdd6f4;
    accent: #89b4fa;
}

window {
    background-color: @bg;
    border: 2px;
    border-color: @accent;
    border-radius: 8px;
    padding: 20px;
}
ROFI_EOF

# Configure dunst
mkdir -p ~/.config/dunst
cat > ~/.config/dunst/dunstrc << 'DUNST_EOF'
[global]
    monitor = 0
    follow = mouse
    width = 300
    height = 100
    origin = top-right
    offset = 10x10
    scale = 0
    notification_limit = 5
    progress_bar = true
    progress_bar_height = 10
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 300

    indicate_hidden = yes
    transparency = 0
    separator_height = 2
    padding = 12
    horizontal_padding = 12
    text_icon_padding = 0
    frame_width = 2
    frame_color = "#89b4fa"
    gap_size = 4
    separator_color = auto
    sort = yes
    idle_threshold = 120

[urgency_low]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    timeout = 5

[urgency_normal]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    timeout = 10

[urgency_critical]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    frame_color = "#f38ba8"
    timeout = 0
DUNST_EOF

echo "Arch Linux setup complete!"
PROOT_EOF

log_info "Running setup script in proot..."
proot-distro login archlinux --shared-tmp bash /tmp/arch-setup.sh

log_info "=========================================="
log_info "  Setup Complete!"
log_info "=========================================="
echo
log_info "To start the desktop:"
echo "  1. Open labwc-android app on Android"
echo "  2. Run in Termux: proot-distro login archlinux --shared-tmp"
echo "  3. Run inside proot: export WAYLAND_DISPLAY=wayland-0"
echo "  4. Run inside proot: export XDG_RUNTIME_DIR=/tmp/wayland-0"
echo "  5. Run inside proot: ~/project/scripts/desktop.sh start"
echo
log_info "Or use the main launcher script:"
echo "  ~/project/scripts/desktop.sh start"
