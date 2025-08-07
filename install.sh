#!/bin/bash

# SocialSleuth Linux Installation Script
# This script installs SocialSleuth as a proper Linux application

set -e

echo "🔧 Installing SocialSleuth on Linux..."
echo ""

# Check if running as root for system-wide installation
if [[ $EUID -eq 0 ]]; then
    INSTALL_DIR="/usr/local/bin"
    CONFIG_DIR="/etc/socialsleuth"
    DATA_DIR="/var/lib/socialsleuth"
    echo "📍 Installing system-wide (requires root)"
else
    INSTALL_DIR="$HOME/.local/bin"
    CONFIG_DIR="$HOME/.config/socialsleuth"
    DATA_DIR="$HOME/.local/share/socialsleuth"
    echo "📍 Installing for current user only"
fi

# Detect Linux distribution
if command -v apt-get &> /dev/null; then
    DISTRO="debian"
    PKG_MANAGER="apt-get"
    PKG_UPDATE="apt-get update"
    PKG_INSTALL="apt-get install -y"
elif command -v yum &> /dev/null; then
    DISTRO="rhel"
    PKG_MANAGER="yum"
    PKG_UPDATE="yum check-update || true"
    PKG_INSTALL="yum install -y"
elif command -v dnf &> /dev/null; then
    DISTRO="fedora"
    PKG_MANAGER="dnf"
    PKG_UPDATE="dnf check-update || true"
    PKG_INSTALL="dnf install -y"
elif command -v pacman &> /dev/null; then
    DISTRO="arch"
    PKG_MANAGER="pacman"
    PKG_UPDATE="pacman -Sy"
    PKG_INSTALL="pacman -S --noconfirm"
else
    echo "❌ Unsupported Linux distribution"
    echo "Please install curl and jq manually"
    exit 1
fi

echo "🔍 Detected distribution: $DISTRO"

# Install dependencies
echo ""
echo "📦 Installing dependencies..."

if [[ $EUID -eq 0 ]]; then
    $PKG_UPDATE
    case $DISTRO in
        "debian")
            $PKG_INSTALL curl jq
            ;;
        "rhel"|"fedora")
            $PKG_INSTALL curl jq
            ;;
        "arch")
            $PKG_INSTALL curl jq
            ;;
    esac
else
    echo "⚠️  Cannot install system packages as non-root user"
    echo "Please install curl and jq manually:"
    echo "  Debian/Ubuntu: sudo apt-get install curl jq"
    echo "  RHEL/CentOS:   sudo yum install curl jq"
    echo "  Fedora:        sudo dnf install curl jq"
    echo "  Arch:          sudo pacman -S curl jq"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create directories
echo ""
echo "📁 Creating directories..."
mkdir -p "$INSTALL_DIR" "$CONFIG_DIR" "$DATA_DIR"

# Copy files
echo "📋 Installing files..."
cp SocialSleuth.sh "$INSTALL_DIR/socialsleuth"
cp config.sh "$CONFIG_DIR/"
cp README.md "$DATA_DIR/"
cp LICENSE "$DATA_DIR/"

# Make executable
chmod +x "$INSTALL_DIR/socialsleuth"

# Create man page
echo "📖 Creating man page..."
mkdir -p "$DATA_DIR/man/man1"

cat > "$DATA_DIR/man/man1/socialsleuth.1" << 'EOF'
.TH SOCIALSLEUTH 1 "August 2025" "SocialSleuth v0.0.1" "User Commands"
.SH NAME
socialsleuth \- Enhanced Social Media Username Scanner
.SH SYNOPSIS
.B socialsleuth
[\fIOPTIONS\fR] \fIusername\fR
.SH DESCRIPTION
SocialSleuth is an advanced tool for discovering usernames across multiple social media platforms and data breach sources.
.SH OPTIONS
.TP
.BR \-h ", " \-\-help
Show help message and exit
.TP
.BR \-v ", " \-\-verbose
Show all not found platforms (default: shows first 10)
.TP
.BR \-o ", " \-\-output " \fIDIR\fR"
Specify output directory (default: results)
.TP
.BR \-j ", " \-\-jobs " \fINUM\fR"
Number of parallel jobs (default: 10)
.TP
.BR \-t ", " \-\-timeout " \fISEC\fR"
Request timeout in seconds (default: 10)
.TP
.BR \-f ", " \-\-format " \fIFORMAT\fR"
Output format: txt, json, csv (default: txt)
.TP
.BR \-l ", " \-\-list
List all supported platforms
.TP
.BR \-p ", " \-\-platforms " \fILIST\fR"
Check only specific platforms (comma-separated)
.SH EXAMPLES
.TP
socialsleuth johndoe
Basic username scan
.TP
socialsleuth \-v \-o /tmp/scans johndoe
Verbose scan with custom output directory
.TP
socialsleuth \-p Instagram,Twitter,GitHub johndoe
Check specific platforms only
.SH FILES
.TP
.I ~/.config/socialsleuth/config.sh
User configuration file
.TP
.I /etc/socialsleuth/config.sh
System-wide configuration file
.SH AUTHOR
Anis Afifi
.SH SEE ALSO
.BR curl (1),
.BR jq (1)
EOF

# Create desktop entry
echo "🖥️  Creating desktop entry..."
mkdir -p "$HOME/.local/share/applications"

cat > "$HOME/.local/share/applications/socialsleuth.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=SocialSleuth
Comment=Enhanced Social Media Username Scanner
Exec=gnome-terminal -- socialsleuth
Icon=utilities-system-monitor
Terminal=true
Categories=Network;Security;
Keywords=social;media;username;scanner;osint;
EOF

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

# Add to PATH if not already there
echo ""
echo "🔗 Updating PATH..."
SHELL_RC=""
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.profile"
fi

if [[ -n "$SHELL_RC" ]] && [[ $EUID -ne 0 ]]; then
    if ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
        echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
        echo "Added $INSTALL_DIR to PATH in $SHELL_RC"
    fi
fi

# Create systemd service (optional)
if [[ $EUID -eq 0 ]] && command -v systemctl &> /dev/null; then
    echo ""
    echo "🔧 Creating systemd service..."
    cat > /etc/systemd/system/socialsleuth-scan.service << EOF
[Unit]
Description=SocialSleuth Username Scanner
After=network.target

[Service]
Type=oneshot
User=nobody
ExecStart=$INSTALL_DIR/socialsleuth -o $DATA_DIR/scans %i
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    echo "Created systemd service: socialsleuth-scan@username.service"
fi

echo ""
echo "✅ Installation completed!"
echo ""
echo "📋 Installation Summary:"
echo "  Executable:     $INSTALL_DIR/socialsleuth"
echo "  Configuration:  $CONFIG_DIR/config.sh"
echo "  Data:          $DATA_DIR/"
echo "  Man page:      $DATA_DIR/man/man1/socialsleuth.1"
echo ""
echo "🚀 Usage:"
echo "  socialsleuth username"
echo "  socialsleuth --help"
echo "  man socialsleuth"
echo ""
if [[ $EUID -ne 0 ]]; then
    echo "💡 Note: Restart your terminal or run 'source $SHELL_RC' to use 'socialsleuth' command"
fi

echo "🔧 To uninstall, run: rm -rf $INSTALL_DIR/socialsleuth $CONFIG_DIR $DATA_DIR"
