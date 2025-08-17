#!/usr/bin/env bash
# Global installer for modularized uu

set -euo pipefail

INSTALL_DIR="${HOME}/.local/bin"
UU_LIB_DIR="${HOME}/.local/lib/uu"

echo "Installing uu globally..."

# Create directories
mkdir -p "$INSTALL_DIR" "$UU_LIB_DIR"

# Copy library modules
echo "Installing library modules to $UU_LIB_DIR"
cp -r lib/uu/* "$UU_LIB_DIR/"

# Copy main script
echo "Installing uu script to $INSTALL_DIR"
cp uu "$INSTALL_DIR/uu"
chmod +x "$INSTALL_DIR/uu"

# Verify installation
if command -v uu >/dev/null 2>&1; then
    echo "✓ uu installed successfully!"
    echo "Version: $(uu --help | head -1)"
    echo "Location: $(which uu)"
    echo "Library: $UU_LIB_DIR"
else
    echo "⚠ uu installed but not in PATH. Add $INSTALL_DIR to your PATH:"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\""
fi