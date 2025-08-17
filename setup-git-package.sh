#!/usr/bin/env bash
# Setup for pip install directly from git

set -euo pipefail

echo "Setting up uu for git-based pip installation..."

# Create proper Python package structure
mkdir -p uu_package/uu_tool

# Create setup.py for git installation
cat > setup.py << 'EOF'
from setuptools import setup, find_packages
import os

# Read version from uu script
version = "0.3.3"
try:
    with open('uu', 'r') as f:
        for line in f:
            if line.startswith('VERSION='):
                version = line.split('"')[1]
                break
except:
    pass

setup(
    name="uu-tool",
    version=version,
    py_modules=[],
    scripts=['uu'],
    data_files=[
        ('lib/uu', ['lib/uu/common.sh', 'lib/uu/fs.sh', 
                   'lib/uu/project.sh', 'lib/uu/args.sh'])
    ],
    author="Your Name",
    description="Make-only bootstrap for uv-based Python modules",
    long_description="Bootstrap tool for uv-based Python development with Make integration",
    url="https://github.com/amitskidrow/uu-tool",
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.6",
)
EOF

echo "✓ setup.py created!"
echo ""
echo "Now you can install from git on any system:"
echo "  pip install git+https://github.com/amitskidrow/uu-tool.git"
echo ""
echo "Or install in development mode:"
echo "  pip install -e git+https://github.com/amitskidrow/uu-tool.git#egg=uu-tool"