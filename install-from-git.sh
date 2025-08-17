#!/usr/bin/env bash
# Install uu directly from git repository

set -euo pipefail

REPO_URL="${1:-https://github.com/amitskidrow/uu-tool.git}"
INSTALL_DIR="${HOME}/.local/bin"
UU_CLONE_DIR="${HOME}/.local/share/uu-tool"

echo "Installing uu from git: $REPO_URL"

# Clone or update repository
if [[ -d "$UU_CLONE_DIR" ]]; then
    echo "Updating existing repository..."
    cd "$UU_CLONE_DIR"
    git pull
else
    echo "Cloning repository..."
    git clone "$REPO_URL" "$UU_CLONE_DIR"
fi

# Create wrapper script that calls the git version
mkdir -p "$INSTALL_DIR"
cat > "$INSTALL_DIR/uu" << EOF
#!/usr/bin/env bash
# uu wrapper - calls git version
exec "$UU_CLONE_DIR/uu" "\$@"
EOF

chmod +x "$INSTALL_DIR/uu"

echo "✓ uu installed from git!"
echo "Repository: $UU_CLONE_DIR"
echo "Wrapper: $INSTALL_DIR/uu"
echo "To update: cd $UU_CLONE_DIR && git pull"