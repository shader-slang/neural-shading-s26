@echo off
REM Build script for Neural Shading Hardware Acceleration

set BUILD_DIR=build
set CMAKE_GENERATOR="Visual Studio 17 2022"
if not defined BUILD_JOBS set BUILD_JOBS=8
echo(%BUILD_JOBS%| findstr /r "^[1-9][0-9]*$" >nul
if %ERRORLEVEL% neq 0 (
    echo Error: BUILD_JOBS must be a positive integer
    pause
    exit /b 1
)
if %BUILD_JOBS% GTR 8 (
    echo Error: BUILD_JOBS must be 8 or less
    pause
    exit /b 1
)

REM Check if external dependencies are available
if not exist external\slang-rhi\CMakeLists.txt (
    echo Error: slang-rhi dependency not found
    echo Please run setup.bat first to fetch dependencies
    pause
    exit /b 1
)

if not exist external\lz4\build\cmake\CMakeLists.txt (
    echo Error: lz4 dependency not found
    echo Please run setup.bat first to fetch dependencies
    pause
    exit /b 1
)

if not exist external\miniz\CMakeLists.txt (
    echo Error: miniz dependency not found
    echo Please run setup.bat first to fetch dependencies
    pause
    exit /b 1
)

if not exist external\unordered_dense\CMakeLists.txt (
    echo Error: unordered_dense dependency not found
    echo Please run setup.bat first to fetch dependencies
    pause
    exit /b 1
)

REM Create build directory if it doesn't exist
if not exist %BUILD_DIR% (
    mkdir %BUILD_DIR%
)

REM Configure the project
echo Configuring project...
cmake -B %BUILD_DIR% -G %CMAKE_GENERATOR% -A x64 -DSLANG_RHI_FETCH_SLANG_VERSION=2026.12

if %ERRORLEVEL% neq 0 (
    echo CMake configuration failed!
    pause
    exit /b %ERRORLEVEL%
)

REM Build the project
echo Building project...
cmake --build %BUILD_DIR% --config Release --parallel %BUILD_JOBS%

if %ERRORLEVEL% neq 0 (
    echo Build failed!
    pause
    exit /b %ERRORLEVEL%
)

echo Build completed successfully!
echo Executables can be found in: %BUILD_DIR%\Release\
