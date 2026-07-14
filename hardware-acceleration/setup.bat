@echo off
REM Setup script for Neural Shading Hardware Acceleration
REM This script initializes the required Git submodules

echo Setting up project dependencies...

REM Check if we're in a git repository
git status >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: This is not a Git repository
    echo Please make sure you're in the correct directory
    pause
    exit /b 1
)

REM Initialize and update all submodules
echo Initializing and updating submodules...
git submodule sync --recursive
git submodule update --init --recursive
if %ERRORLEVEL% neq 0 (
    echo Failed to update submodules
    pause
    exit /b %ERRORLEVEL%
)

echo Setup completed successfully!
echo You can now run build.bat to build the project.
