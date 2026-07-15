#!/bin/bash
# Setup script for Neural Shading Hardware Acceleration
# This script fetches the dependencies required by the C++ hardware examples.

set -e  # Exit on any error

echo "Setting up project dependencies..."

# Check if we're in a git repository
if ! git status &>/dev/null; then
    echo "Error: This is not a Git repository"
    echo "Please make sure you're in the correct directory"
    exit 1
fi

fetch_dep() {
    local name="$1"
    local url="$2"
    local rev="$3"
    local path="external/$name"

    if [ ! -d "$path/.git" ]; then
        echo "Cloning $name..."
        git clone "$url" "$path"
    fi

    echo "Checking out $name..."
    git -C "$path" fetch origin
    git -C "$path" checkout "$rev"
}

mkdir -p external

fetch_dep slang-rhi https://github.com/shader-slang/slang-rhi.git 0a7d257546ecb7b874367544b2e06b776dc714a8
fetch_dep lz4 https://github.com/lz4/lz4.git 0774d05537f9762f838f7ab541b7765f1a729cb5
fetch_dep miniz https://github.com/richgel999/miniz.git 77d0dce8627735138c51770d1799a1ef48f2117d
fetch_dep unordered_dense https://github.com/martinus/unordered_dense.git e5b9441ecf193f3e1e8f954527fc76edee20d7eb

echo "Setup completed successfully!"
echo "You can now run build.sh to build the project."
