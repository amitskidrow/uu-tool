#!/usr/bin/env bash
# Universal installer for uu tool

set -euo pipefail

REPO_URL="https://github.com/YOURUSERNAME/uu-tool.git"
INSTALL_DIR="${HOME}/.local/bin"
UU_LIB_DIR="${HOME}/.local/lib/uu"
TEMP_DIR=$(mktemp -d)

echo "Installing uu from $REPO_URL..."

# Clone to temp directory
git clone "$REPO_URL" "$TEMP_DIR/uu-tool"

# Create directories
mkdir -p "$INSTALL_DIR" "$UU_LIB_DIR"

# Install files
cp "$TEMP_DIR/uu-tool/uu" "$INSTALL_DIR/uu"
cp -r "$TEMP_DIR/uu-tool/lib/uu/"* "$UU_LIB_DIR/"
chmod +x "$INSTALL_DIR/uu"

# Cleanup
rm -rf "$TEMP_DIR"

echo "✓ uu installed successfully!"
echo "Location: $INSTALL_DIR/uu"
echo "Library: $UU_LIB_DIR"

if ! command -v uu >/dev/null 2>&1; then
    echo "⚠ Add to PATH: export PATH=\"$INSTALL_DIR:\$PATH\""
fi
