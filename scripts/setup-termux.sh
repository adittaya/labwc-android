#!/bin/bash
# setup-termux.sh - Install required packages in Termux
# This script installs packages from Xtr126/termux-packages

set -e

echo "=========================================="
echo "  labwc-android Termux Setup"
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

log_info "Installing X11 repository..."
pkg install -y x11-repo 2>/dev/null || true

log_info "Installing required packages..."
pkg install -y \
    pulseaudio \
    proot-distro \
    wget \
    git \
    python \
    curl \
    build-essential \
    cmake \
    ninja \
    meson \
    2>/dev/null || true

log_info "Installing X11/Wayland packages..."
pkg install -y \
    termux-x11-nightly \
    xwayland \
    2>/dev/null || true

echo
log_info "=========================================="
log_info "  Manual Package Installation Required"
log_info "=========================================="
echo
log_info "The following packages must be installed from Xtr126/termux-packages:"
echo
echo "  1. Download mesa packages from:"
echo "     https://github.com/Xtr126/termux-packages/releases"
echo
echo "  2. Download wlroots packages from:"
echo "     https://github.com/Xtr126/termux-packages/releases/tag/wlroots-0.18"
echo
echo "  3. Install the downloaded .deb packages:"
echo "     dpkg -i *.deb"
echo
log_info "=========================================="
echo

log_info "Setting up PulseAudio..."
# Create PulseAudio config if it doesn't exist
mkdir -p ~/.config/pulse
cat > ~/.config/pulse/client.conf << 'EOF'
default-server = 127.0.0.1
autospawn = no
EOF

log_info "Termux setup complete!"
echo
log_info "Next steps:"
echo "  1. Install mesa/wlroots packages manually (see above)"
echo "  2. Run: ~/project/scripts/setup-proot.sh"
echo "  3. Run: ~/project/scripts/desktop.sh start"
