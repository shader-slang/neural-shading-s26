#!/bin/bash
# Build script for Neural Shading Hardware Acceleration

set -e  # Exit on any error

BUILD_DIR="build"
CMAKE_GENERATOR="Unix Makefiles"
BUILD_JOBS="${BUILD_JOBS:-8}"

if ! [[ "$BUILD_JOBS" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: BUILD_JOBS must be a positive integer"
    exit 1
fi
if (( BUILD_JOBS > 8 )); then
    echo "Error: BUILD_JOBS must be 8 or less"
    exit 1
fi

echo "Building Neural Shading Hardware Acceleration..."

# Check if external dependencies are available
if [ ! -f "external/slang-rhi/CMakeLists.txt" ]; then
    echo "Error: slang-rhi dependency not found"
    echo "Please run setup.sh first to fetch dependencies"
    exit 1
fi

if [ ! -f "external/lz4/build/cmake/CMakeLists.txt" ]; then
    echo "Error: lz4 dependency not found"
    echo "Please run setup.sh first to fetch dependencies"
    exit 1
fi

if [ ! -f "external/miniz/CMakeLists.txt" ]; then
    echo "Error: miniz dependency not found"
    echo "Please run setup.sh first to fetch dependencies"
    exit 1
fi

if [ ! -f "external/unordered_dense/CMakeLists.txt" ]; then
    echo "Error: unordered_dense dependency not found"
    echo "Please run setup.sh first to fetch dependencies"
    exit 1
fi

# Create build directory if it doesn't exist
if [ ! -d "$BUILD_DIR" ]; then
    mkdir "$BUILD_DIR"
fi

# Configure the project
echo "Configuring project..."
cmake -B "$BUILD_DIR" -G "$CMAKE_GENERATOR" -DCMAKE_BUILD_TYPE=Release -DSLANG_RHI_FETCH_SLANG_VERSION=2026.12

# Build the project
echo "Building project..."
cmake --build "$BUILD_DIR" --config Release --parallel "$BUILD_JOBS"

echo "Build completed successfully!"
echo "Executables can be found in: $BUILD_DIR/"
