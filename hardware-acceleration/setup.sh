#!/bin/bash
# Setup script for Neural Shading Hardware Acceleration
# This script initializes the required Git submodules

set -e  # Exit on any error

echo "Setting up project dependencies..."

# Check if we're in a git repository
if ! git status &>/dev/null; then
    echo "Error: This is not a Git repository"
    echo "Please make sure you're in the correct directory"
    exit 1
fi

# Initialize and update all submodules
echo "Initializing and updating submodules..."
git submodule sync --recursive
git submodule update --init --recursive

echo "Setup completed successfully!"
echo "You can now run build.sh to build the project."
