#!/bin/bash

# Create Debian package structure for SocialSleuth

set -e

PACKAGE_NAME="socialsleuth"
# Allow overriding via environment (e.g., from CI), with sensible defaults
VERSION="${VERSION:-0.0.1}"
ARCH="${ARCH:-all}"
MAINTAINER="${MAINTAINER:-Anis Afifi <anis@webxbeyond.com>}"

echo "📦 Creating Debian package structure..."

# Create package directory
PACKAGE_DIR="${PACKAGE_NAME}_${VERSION}_${ARCH}"
mkdir -p "$PACKAGE_DIR"

# Create directory structure
mkdir -p "$PACKAGE_DIR/usr/local/bin"
mkdir -p "$PACKAGE_DIR/etc/socialsleuth"
mkdir -p "$PACKAGE_DIR/usr/share/doc/$PACKAGE_NAME"
mkdir -p "$PACKAGE_DIR/usr/share/man/man1"
mkdir -p "$PACKAGE_DIR/DEBIAN"

# Copy files
cp SocialSleuth.sh "$PACKAGE_DIR/usr/local/bin/socialsleuth"
cp config.sh "$PACKAGE_DIR/etc/socialsleuth/"
cp README.md "$PACKAGE_DIR/usr/share/doc/$PACKAGE_NAME/"
cp LICENSE "$PACKAGE_DIR/usr/share/doc/$PACKAGE_NAME/"

# Make executable
chmod +x "$PACKAGE_DIR/usr/local/bin/socialsleuth"

# Create man page (use dynamic version and current date)
DATE_STR=$(date +"%B %Y")
cat > "$PACKAGE_DIR/usr/share/man/man1/socialsleuth.1" << EOF
.TH SOCIALSLEUTH 1 "$DATE_STR" "SocialSleuth v$VERSION" "User Commands"
.SH NAME
socialsleuth \- Enhanced Social Media Username Scanner
.SH SYNOPSIS
.B socialsleuth
[\fIOPTIONS\fR] \fIusername\fR
.SH DESCRIPTION
SocialSleuth is an advanced tool for discovering usernames across multiple social media platforms and data breach sources.
EOF

gzip "$PACKAGE_DIR/usr/share/man/man1/socialsleuth.1"

# Create control file
cat > "$PACKAGE_DIR/DEBIAN/control" << EOF
Package: $PACKAGE_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Depends: curl, jq
Maintainer: $MAINTAINER
Description: Enhanced Social Media Username Scanner
 SocialSleuth is an advanced tool for discovering usernames across
 multiple social media platforms and data breach sources. It supports
 80+ platforms and provides comprehensive scanning capabilities.
Homepage: https://github.com/webxbeyond/SocialSleuth
EOF

# Create postinst script
cat > "$PACKAGE_DIR/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e

# Add to PATH if not already there
if ! echo "$PATH" | grep -q "/usr/local/bin"; then
    echo "Adding /usr/local/bin to PATH"
fi

echo "SocialSleuth installed successfully!"
echo "Run 'socialsleuth --help' to get started"
EOF

chmod +x "$PACKAGE_DIR/DEBIAN/postinst"

# Create prerm script
cat > "$PACKAGE_DIR/DEBIAN/prerm" << 'EOF'
#!/bin/bash
set -e

echo "Removing SocialSleuth..."
EOF

chmod +x "$PACKAGE_DIR/DEBIAN/prerm"

# Build package
if command -v dpkg-deb &> /dev/null; then
    echo "🔨 Building Debian package..."
    dpkg-deb --build "$PACKAGE_DIR"
    echo "✅ Package created: ${PACKAGE_DIR}.deb"
else
    echo "⚠️  dpkg-deb not found. Package structure created but not built."
    echo "To build: dpkg-deb --build $PACKAGE_DIR"
fi

echo ""
echo "📋 Package structure created in: $PACKAGE_DIR"
echo "📦 To install: sudo dpkg -i ${PACKAGE_DIR}.deb"
