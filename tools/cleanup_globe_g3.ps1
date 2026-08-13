$ErrorActionPreference = 'Stop'

$projectRoot = 'C:\FLUTTER_PROJECTS\sociale_vote'
$target = Join-Path $projectRoot 'third_party\flutter_earth_globe_social_vote'

if (-not (Test-Path $target)) {
    throw "Cartella G3 non trovata: $target"
}

Write-Host "Pulizia package locale G3..."
Write-Host "Target: $target"
Write-Host ""

$removeDirectories = @(
    '.dart_tool',
    'doc',
    'example',
    'test',
    'android',
    'ios',
    'linux',
    'macos',
    'web',
    'windows'
)

foreach ($name in $removeDirectories) {
    $path = Join-Path $target $name
    if (Test-Path $path) {
        Write-Host "Rimuovo: $name"
        Remove-Item $path -Recurse -Force
    }
}

$removeFiles = @(
    '.gitignore',
    '.metadata',
    'analysis_options.yaml',
    'CHANGELOG.md',
    'README.md'
)

foreach ($name in $removeFiles) {
    $path = Join-Path $target $name
    if (Test-Path $path) {
        Write-Host "Rimuovo: $name"
        Remove-Item $path -Force
    }
}

$required = @(
    'lib',
    'shaders',
    'pubspec.yaml',
    'LICENSE'
)

foreach ($name in $required) {
    $path = Join-Path $target $name
    if (-not (Test-Path $path)) {
        throw "ERRORE: file/cartella necessaria mancante dopo la pulizia: $name"
    }
}

Write-Host ""
Write-Host "Contenuto finale:"
Get-ChildItem $target | Select-Object Name, Mode

Write-Host ""
Write-Host "Controllo Git:"
Push-Location $projectRoot
git status --short
Pop-Location

Write-Host ""
Write-Host "Pulizia G3 completata."
Write-Host "Non eseguire flutter clean."
Write-Host "Il package locale resta collegato tramite pubspec.yaml."
