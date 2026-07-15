@echo off
REM Setup script for Neural Shading Hardware Acceleration
REM This script fetches the dependencies required by the C++ hardware examples.

echo Setting up project dependencies...

REM Check if we're in a git repository
git status >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: This is not a Git repository
    echo Please make sure you're in the correct directory
    pause
    exit /b 1
)

if not exist external mkdir external

call :sync_dep slang-rhi https://github.com/shader-slang/slang-rhi.git 0a7d257546ecb7b874367544b2e06b776dc714a8
call :sync_dep lz4 https://github.com/lz4/lz4.git 0774d05537f9762f838f7ab541b7765f1a729cb5
call :sync_dep miniz https://github.com/richgel999/miniz.git 77d0dce8627735138c51770d1799a1ef48f2117d
call :sync_dep unordered_dense https://github.com/martinus/unordered_dense.git e5b9441ecf193f3e1e8f954527fc76edee20d7eb

echo Setup completed successfully!
echo You can now run build.bat to build the project.
exit /b 0

:sync_dep
set DEP_NAME=%~1
set DEP_URL=%~2
set DEP_REV=%~3
set DEP_PATH=external\%DEP_NAME%

if not exist %DEP_PATH% (
    echo Cloning %DEP_NAME%...
    git clone --filter=blob:none --no-checkout %DEP_URL% %DEP_PATH%
) else (
    git -C %DEP_PATH% rev-parse --is-inside-work-tree >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo Error: %DEP_PATH% exists but is not a Git checkout
        echo Please move it aside or remove it, then rerun setup.bat
        pause
        exit /b 1
    )
    echo Updating %DEP_NAME%...
    git -C %DEP_PATH% fetch --filter=blob:none origin
)
if %ERRORLEVEL% neq 0 (
    echo Failed to fetch %DEP_NAME%
    pause
    exit /b %ERRORLEVEL%
)

git -C %DEP_PATH% checkout %DEP_REV%
if %ERRORLEVEL% neq 0 (
    echo Failed to checkout %DEP_NAME%
    pause
    exit /b %ERRORLEVEL%
)
exit /b 0
