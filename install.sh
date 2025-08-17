#!/usr/bin/env bash
# Universal installer for uu tool
# Usage: curl -sSL https://raw.githubusercontent.com/amitskidrow/uu-tool/main/install.sh | bash

set -euo pipefail

REPO_URL="https://github.com/amitskidrow/uu-tool.git"
INSTALL_DIR="${HOME}/.local/bin"
UU_LIB_DIR="${HOME}/.local/lib/uu"
TEMP_DIR=$(mktemp -d)

echo "🚀 Installing uu from $REPO_URL..."

# Ensure directories exist
mkdir -p "$INSTALL_DIR" "$UU_LIB_DIR"

# Clone repository to temp location
echo "📦 Downloading latest version..."
git clone --depth 1 "$REPO_URL" "$TEMP_DIR/uu-tool" 2>/dev/null || {
    echo "❌ Failed to clone repository. Check your internet connection."
    exit 1
}

# Install main script
echo "📋 Installing uu script..."
cp "$TEMP_DIR/uu-tool/uu" "$INSTALL_DIR/uu"
chmod +x "$INSTALL_DIR/uu"

# Install library modules
echo "📚 Installing library modules..."
cp -r "$TEMP_DIR/uu-tool/lib/uu/"* "$UU_LIB_DIR/"

# Cleanup
rm -rf "$TEMP_DIR"

# Verify installation
if command -v uu >/dev/null 2>&1; then
    echo "✅ uu installed successfully!"
    echo "📍 Location: $INSTALL_DIR/uu"
    echo "📁 Library: $UU_LIB_DIR"
    echo ""
    echo "🎯 Test it: uu --help"
else
    echo "⚠️  uu installed but not in PATH"
    echo "Add this to your shell profile (~/.bashrc, ~/.zshrc):"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\""
    echo ""
    echo "Then reload: source ~/.bashrc"
fi

echo ""
echo "🌟 Ready to bootstrap Python projects with: uu /path/to/project"
