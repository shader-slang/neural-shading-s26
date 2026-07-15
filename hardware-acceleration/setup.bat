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

call :fetch_dep slang-rhi https://github.com/shader-slang/slang-rhi.git 0a7d257546ecb7b874367544b2e06b776dc714a8 || exit /b %ERRORLEVEL%
call :fetch_dep lz4 https://github.com/lz4/lz4.git 0774d05537f9762f838f7ab541b7765f1a729cb5 || exit /b %ERRORLEVEL%
call :fetch_dep miniz https://github.com/richgel999/miniz.git 77d0dce8627735138c51770d1799a1ef48f2117d || exit /b %ERRORLEVEL%
call :fetch_dep unordered_dense https://github.com/martinus/unordered_dense.git e5b9441ecf193f3e1e8f954527fc76edee20d7eb || exit /b %ERRORLEVEL%

echo Setup completed successfully!
echo You can now run build.bat to build the project.
exit /b 0

:fetch_dep
set DEP_NAME=%~1
set DEP_URL=%~2
set DEP_REV=%~3
set DEP_PATH=external\%DEP_NAME%

if not exist %DEP_PATH%\.git (
    echo Cloning %DEP_NAME%...
    git clone %DEP_URL% %DEP_PATH%
    if %ERRORLEVEL% neq 0 (
        echo Failed to clone %DEP_NAME%
        pause
        exit /b %ERRORLEVEL%
    )
)

echo Checking out %DEP_NAME%...
git -C %DEP_PATH% fetch origin
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
