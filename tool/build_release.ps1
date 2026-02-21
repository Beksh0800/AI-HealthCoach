param(
    [string]$BuildName = "1.0.1",
    [int]$BuildNumber = 2,
    [switch]$SkipPubGet
)

$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $projectRoot

$symbolsDir = Join-Path $projectRoot "build/symbols"
New-Item -ItemType Directory -Force -Path $symbolsDir | Out-Null

if (-not $SkipPubGet) {
    flutter pub get
}

$commonArgs = @(
    "--release",
    "--obfuscate",
    "--split-debug-info=$symbolsDir",
    "--build-name=$BuildName",
    "--build-number=$BuildNumber"
)

flutter build appbundle @commonArgs
flutter build apk @commonArgs --split-per-abi

$apkDir = Join-Path $projectRoot "build/app/outputs/flutter-apk"
if (Test-Path $apkDir) {
    Get-ChildItem -Path $apkDir -File -Filter "app-*-release.apk" | ForEach-Object {
        $arch = $_.BaseName.Replace("app-", "").Replace("-release", "")
        $newName = "ai-health-coach-$BuildName+$BuildNumber-$arch.apk"
        Rename-Item -Path $_.FullName -NewName $newName -Force
    }
}

Write-Host "Release build completed."
Write-Host "AAB: build/app/outputs/bundle/release/app-release.aab"
Write-Host "APK dir: build/app/outputs/flutter-apk"
Write-Host "Symbols: build/symbols"
