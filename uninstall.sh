#!/bin/bash

# SocialSleuth Linux Uninstall Script

set -e

echo "🗑️  Uninstalling SocialSleuth..."
echo ""

# Determine installation directories
if [[ $EUID -eq 0 ]]; then
    INSTALL_DIR="/usr/local/bin"
    CONFIG_DIR="/etc/socialsleuth"
    DATA_DIR="/var/lib/socialsleuth"
    echo "🔍 Removing system-wide installation"
else
    INSTALL_DIR="$HOME/.local/bin"
    CONFIG_DIR="$HOME/.config/socialsleuth"
    DATA_DIR="$HOME/.local/share/socialsleuth"
    echo "🔍 Removing user installation"
fi

# Remove files
echo "📋 Removing files..."
rm -f "$INSTALL_DIR/socialsleuth"
rm -rf "$CONFIG_DIR"
rm -rf "$DATA_DIR"

# Remove desktop entry
rm -f "$HOME/.local/share/applications/socialsleuth.desktop"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

# Remove systemd service
if [[ $EUID -eq 0 ]] && [[ -f "/etc/systemd/system/socialsleuth-scan.service" ]]; then
    echo "🔧 Removing systemd service..."
    systemctl stop socialsleuth-scan@* 2>/dev/null || true
    systemctl disable socialsleuth-scan.service 2>/dev/null || true
    rm -f /etc/systemd/system/socialsleuth-scan.service
    systemctl daemon-reload
fi

echo ""
echo "✅ SocialSleuth has been uninstalled"
echo ""
echo "💡 Note: You may need to remove the PATH entry from your shell configuration manually"
echo "  Check ~/.bashrc, ~/.zshrc, or ~/.profile for the line containing '$INSTALL_DIR'"
