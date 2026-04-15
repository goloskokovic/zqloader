# PowerShell build script for zqloader Android libraries
# Usage: .\build_android.ps1 -NdkPath "C:\Android\ndk\r25"

param(
    [string]$NdkPath = $env:ANDROID_NDK,
    [string]$BuildType = "Release",
    [int]$MinApiLevel = 21,
    [switch]$Help
)

# Configuration
$FlutterProject = "flutter\zqloader_ffi"
$ABIs = @("arm64-v8a", "armeabi-v7a", "x86_64", "x86")
$ABINames = @("arm64", "arm32", "x86_64", "x86")

# Color codes
function Write-Error-Color([string]$message) {
    Write-Host $message -ForegroundColor Red
}

function Write-Success-Color([string]$message) {
    Write-Host $message -ForegroundColor Green
}

function Write-Info-Color([string]$message) {
    Write-Host $message -ForegroundColor Yellow
}

# Display help
if ($Help) {
    Write-Host @"
Build zqloader for Android

Usage: .\build_android.ps1 [options]

Options:
    -NdkPath <path>      Path to Android NDK (default: `$env:ANDROID_NDK)
    -BuildType <type>    Build type: Release or Debug (default: Release)
    -MinApiLevel <level> Minimum API level (default: 21)
    -Help               Show this message

Example:
    .\build_android.ps1 -NdkPath "C:\Android\ndk\r25"

"@
    exit 0
}

# Validate NDK path
if ([string]::IsNullOrEmpty($NdkPath)) {
    Write-Error-Color "Error: Android NDK path not provided"
    Write-Host "Set ANDROID_NDK environment variable or use -NdkPath parameter"
    exit 1
}

if (-not (Test-Path $NdkPath)) {
    Write-Error-Color "Error: NDK path does not exist: $NdkPath"
    exit 1
}

$Toolchain = Join-Path $NdkPath "build\cmake\android.toolchain.cmake"
if (-not (Test-Path $Toolchain)) {
    Write-Error-Color "Error: Android toolchain not found at: $Toolchain"
    exit 1
}

# Display configuration
Write-Success-Color "========================================"
Write-Success-Color "Building zqloader for Android"
Write-Success-Color "========================================"
Write-Host "NDK: $NdkPath"
Write-Host "Toolchain: $Toolchain"
Write-Host "Min API Level: $MinApiLevel"
Write-Host "Build Type: $BuildType"
Write-Host ""

# Build for each ABI
for ($i = 0; $i -lt $ABIs.Count; $i++) {
    $ABI = $ABIs[$i]
    $ABIName = $ABINames[$i]
    $BuildDir = "build_android_$ABIName"
    
    Write-Info-Color "Building for $ABI..."
    
    # Configure
    $ConfigCmd = @(
        "-B", $BuildDir,
        "-DCMAKE_TOOLCHAIN_FILE=$Toolchain",
        "-DCMAKE_BUILD_TYPE=$BuildType",
        "-DANDROID_PLATFORM=android-$MinApiLevel",
        "-DANDROID_ABI=$ABI",
        "-DANDROID_STL=c++_static",
        "-GNinja"
    )
    
    Write-Host "Configuring CMake..."
    & cmake $ConfigCmd
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Color "CMake configuration failed for $ABI"
        exit 1
    }
    
    # Build
    Write-Host "Building..."
    & cmake --build $BuildDir --config $BuildType
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Color "CMake build failed for $ABI"
        exit 1
    }
    
    Write-Success-Color "✓ Build complete for $ABI"
    Write-Host ""
}

Write-Info-Color "Copying libraries to Flutter project..."

if (-not (Test-Path $FlutterProject)) {
    Write-Error-Color "Error: Flutter project not found at: $FlutterProject"
    exit 1
}

# Copy built libraries
for ($i = 0; $i -lt $ABIs.Count; $i++) {
    $ABI = $ABIs[$i]
    $ABIName = $ABINames[$i]
    $BuildDir = "build_android_$ABIName"
    $LibPath = Join-Path $BuildDir "libzqloaderlib.so"
    
    if (-not (Test-Path $LibPath)) {
        Write-Error-Color "Error: Library not found: $LibPath"
        exit 1
    }
    
    # Create target directory
    $TargetDir = Join-Path $FlutterProject "android\app\src\main\jniLibs\$ABI"
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    
    # Copy library
    Copy-Item $LibPath -Destination $TargetDir -Force
    Write-Success-Color "✓ Copied to $TargetDir"
}

Write-Host ""
Write-Success-Color "========================================"
Write-Success-Color "Build Complete!"
Write-Success-Color "========================================"
Write-Host ""
Write-Host "Libraries are ready in:"
Write-Host "  $FlutterProject\android\app\src\main\jniLibs\"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  cd $FlutterProject\example"
Write-Host "  flutter pub get"
Write-Host "  flutter build apk --release"
Write-Host ""
