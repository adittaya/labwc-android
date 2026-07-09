#!/bin/bash
# desktop.sh - Main desktop launcher for labwc-android
# Usage: desktop.sh {start|stop|restart|status}

set -e

PROJECT_DIR="$HOME/project"
LABWC_DIR="$PROJECT_DIR/labwc-android"
CONFIGS_DIR="$PROJECT_DIR/configs"
WAYLAND_DISPLAY="wayland-0"
XDG_RUNTIME_DIR="/tmp/wayland-0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_labwc_installed() {
    if [ ! -d "$LABWC_DIR" ]; then
        log_error "labwc-android not found at $LABWC_DIR"
        log_info "Run: git clone https://github.com/Xtr126/labwc-android.git $LABWC_DIR"
        exit 1
    fi
}

check_wayland_socket() {
    if [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
        return 0
    else
        return 1
    fi
}

setup_environment() {
    log_info "Setting up Wayland environment..."
    
    # Create runtime directory if it doesn't exist
    mkdir -p "$XDG_RUNTIME_DIR"
    
    # Set environment variables
    export WAYLAND_DISPLAY
    export XDG_RUNTIME_DIR
    export XDG_SESSION_TYPE=wayland
    export MOZ_ENABLE_WAYLAND=1
    export QT_QPA_PLATFORM=wayland
    export SDL_VIDEODRIVER=wayland
    export ELM_ENGINE=wayland_egl
    export ECORE_EVAS_ENGINE=wayland_egl
    export ELM_ACCEL=opengl
    
    log_info "Environment variables set"
}

start_labwc() {
    log_info "Starting labwc-android compositor..."
    
    # Check if already running
    if check_wayland_socket; then
        log_warn "Wayland socket already exists at $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
        log_info "Compositor may already be running"
        return 0
    fi
    
    # Start labwc-android (this would be the actual app launch)
    # For now, we'll create a placeholder
    log_info "To start labwc-android:"
    log_info "1. Open the labwc-android app on your Android device"
    log_info "2. The Wayland socket will be created at $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
    
    # Wait for socket to appear
    local timeout=30
    local count=0
    while ! check_wayland_socket && [ $count -lt $timeout ]; do
        sleep 1
        count=$((count + 1))
        echo -n "."
    done
    echo
    
    if check_wayland_socket; then
        log_info "Wayland socket is ready"
    else
        log_error "Timeout waiting for Wayland socket"
        return 1
    fi
}

start_components() {
    log_info "Starting desktop components..."
    
    if ! check_wayland_socket; then
        log_error "Wayland socket not found. Start labwc-android first."
        return 1
    fi
    
    # Start window manager (labwc)
    if command -v labwc &> /dev/null; then
        log_info "Starting labwc window manager..."
        labwc &
        sleep 2
    else
        log_warn "labwc not found, skipping window manager"
    fi
    
    # Start panel (tint2 via XWayland)
    if command -v tint2 &> /dev/null; then
        log_info "Starting tint2 panel..."
        # tint2 needs XWayland, so we start it via X11
        DISPLAY=:0 tint2 &
        sleep 1
    else
        log_warn "tint2 not found, skipping panel"
    fi
    
    # Start application launcher (rofi)
    if command -v rofi &> /dev/null; then
        log_info "Rofi launcher available"
        # Rofi is started on-demand, not at startup
    else
        log_warn "rofi not found, skipping launcher"
    fi
    
    # Start notification daemon (dunst)
    if command -v dunst &> /dev/null; then
        log_info "Starting dunst notification daemon..."
        dunst &
        sleep 1
    else
        log_warn "dunst not found, skipping notifications"
    fi
    
    # Start wallpaper (feh)
    if command -v feh &> /dev/null; then
        log_info "Starting wallpaper..."
        # feh needs X11, so we start it via XWayland
        DISPLAY=:0 feh --bg-scale ~/Pictures/Wallpaper.jpg 2>/dev/null || true
    else
        log_warn "feh not found, skipping wallpaper"
    fi
    
    log_info "Desktop components started"
}

stop_components() {
    log_info "Stopping desktop components..."
    
    # Kill tint2
    if pgrep -x tint2 > /dev/null; then
        killall tint2 2>/dev/null || true
        log_info "Stopped tint2"
    fi
    
    # Kill dunst
    if pgrep -x dunst > /dev/null; then
        killall dunst 2>/dev/null || true
        log_info "Stopped dunst"
    fi
    
    # Kill labwc
    if pgrep -x labwc > /dev/null; then
        killall labwc 2>/dev/null || true
        log_info "Stopped labwc"
    fi
    
    # Remove wayland socket
    if [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
        rm -f "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
        log_info "Removed Wayland socket"
    fi
    
    log_info "Desktop components stopped"
}

show_status() {
    log_info "Desktop Status:"
    echo "  Wayland Display: $WAYLAND_DISPLAY"
    echo "  XDG Runtime Dir: $XDG_RUNTIME_DIR"
    
    if check_wayland_socket; then
        echo "  Wayland Socket: ${GREEN}ACTIVE${NC}"
    else
        echo "  Wayland Socket: ${RED}INACTIVE${NC}"
    fi
    
    if pgrep -x labwc > /dev/null; then
        echo "  labwc: ${GREEN}RUNNING${NC}"
    else
        echo "  labwc: ${RED}STOPPED${NC}"
    fi
    
    if pgrep -x tint2 > /dev/null; then
        echo "  tint2: ${GREEN}RUNNING${NC}"
    else
        echo "  tint2: ${RED}STOPPED${NC}"
    fi
    
    if pgrep -x dunst > /dev/null; then
        echo "  dunst: ${GREEN}RUNNING${NC}"
    else
        echo "  dunst: ${RED}STOPPED${NC}"
    fi
}

usage() {
    echo "Usage: $0 {start|stop|restart|status}"
    echo
    echo "Commands:"
    echo "  start     Start the desktop environment"
    echo "  stop      Stop all desktop components"
    echo "  restart   Restart the desktop environment"
    echo "  status    Show current status"
}

case "$1" in
    start)
        check_labwc_installed
        setup_environment
        start_labwc
        start_components
        log_info "Desktop started successfully!"
        ;;
    stop)
        stop_components
        ;;
    restart)
        stop_components
        sleep 2
        check_labwc_installed
        setup_environment
        start_labwc
        start_components
        log_info "Desktop restarted successfully!"
        ;;
    status)
        show_status
        ;;
    *)
        usage
        exit 1
        ;;
esac

exit 0
