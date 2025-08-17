#!/usr/bin/env bash
# Convert uu to a proper Python package

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

echo "Setting up uu as a Python package..."

# Create package structure
mkdir -p uu_package/uu_tool/{lib,bin}

# Copy files
cp uu uu_package/uu_tool/bin/
cp -r lib/uu/* uu_package/uu_tool/lib/

# Create package files
cat > uu_package/setup.py << 'EOF'
from setuptools import setup, find_packages

setup(
    name="uu-tool",
    version="0.3.3",
    packages=find_packages(),
    scripts=['uu_tool/bin/uu'],
    data_files=[
        ('lib/uu', ['uu_tool/lib/common.sh', 'uu_tool/lib/fs.sh', 
                   'uu_tool/lib/project.sh', 'uu_tool/lib/args.sh'])
    ],
    author="Your Name",
    description="Make-only bootstrap for uv-based Python modules",
    python_requires=">=3.6",
)
EOF

cat > uu_package/uu_tool/__init__.py << 'EOF'
# uu-tool package
EOF

echo "✓ Package structure created in uu_package/"
echo "To install: cd uu_package && pip install -e ."