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

sync_dep() {
    local name="$1"
    local url="$2"
    local rev="$3"
    local path="external/$name"

    if [ ! -e "$path" ]; then
        echo "Cloning $name..."
        git clone --filter=blob:none --no-checkout "$url" "$path"
    elif git -C "$path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Updating $name..."
        git -C "$path" fetch --filter=blob:none origin
    else
        echo "Error: $path exists but is not a Git checkout"
        echo "Please move it aside or remove it, then rerun setup.sh"
        exit 1
    fi

    git -C "$path" checkout "$rev"
}

mkdir -p external

sync_dep slang-rhi https://github.com/shader-slang/slang-rhi.git 0a7d257546ecb7b874367544b2e06b776dc714a8
sync_dep lz4 https://github.com/lz4/lz4.git 0774d05537f9762f838f7ab541b7765f1a729cb5
sync_dep miniz https://github.com/richgel999/miniz.git 77d0dce8627735138c51770d1799a1ef48f2117d
sync_dep unordered_dense https://github.com/martinus/unordered_dense.git e5b9441ecf193f3e1e8f954527fc76edee20d7eb

echo "Setup completed successfully!"
echo "You can now run build.sh to build the project."
