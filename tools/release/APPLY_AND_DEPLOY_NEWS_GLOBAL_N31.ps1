[CmdletBinding()]
param(
    [string]$ProjectRoot = "C:\FLUTTER_PROJECTS\sociale_vote"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-Sha256 {
    param([Parameter(Mandatory = $true)][string]$Path)

    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-NormalizedTextSha256 {
    param([Parameter(Mandatory = $true)][string]$Path)

    $Text = [System.IO.File]::ReadAllText($Path)
    $NormalizedText = $Text.Replace("`r`n", "`n").Replace("`r", "`n")
    $Bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($NormalizedText)
    $Sha = [System.Security.Cryptography.SHA256]::Create()

    try {
        $HashBytes = $Sha.ComputeHash($Bytes)
        return (($HashBytes | ForEach-Object { $_.ToString("x2") }) -join "")
    } finally {
        $Sha.Dispose()
    }
}

if (-not (Test-Path -LiteralPath $ProjectRoot -PathType Container)) {
    throw "Progetto CURRENT non trovato: $ProjectRoot"
}

if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot "pubspec.yaml") -PathType Leaf)) {
    throw "pubspec.yaml non trovato: il percorso non sembra Social Vote."
}

$PayloadRoot = Join-Path $PSScriptRoot "payload"
$SourceFunction = Join-Path $PayloadRoot "supabase\functions\news-cache-refresh\index.ts"
$SourceVerify = Join-Path $PayloadRoot "tools\release\VERIFY_NEWS_GLOBAL_N31.sql"
$TargetFunction = Join-Path $ProjectRoot "supabase\functions\news-cache-refresh\index.ts"
$TargetVerify = Join-Path $ProjectRoot "tools\release\VERIFY_NEWS_GLOBAL_N31.sql"

$ExpectedFunctionSha = "2c8716cff66a38cdc4a8b284c38a6a2a689e796848fd52af16773e6406b1228f"
$ExpectedVerifySha = "5c8293e3234e616ffe71d4637ac00b44a55dd5e2ba28777282770945f9bb807e"
$AllowedPreviousFunctionNormalizedSha = @(
    "2c8716cff66a38cdc4a8b284c38a6a2a689e796848fd52af16773e6406b1228f",
    "d07786ffcc2fe216efbfe181f47199b520dd6debecfb5cc54dc2f38c2508d19f",
    "b89cc1a335a06a422cac312d1727e565357e6c985696230e1da72ab36d5f5a0f"
)

if ((Get-Sha256 $SourceFunction) -ne $ExpectedFunctionSha) {
    throw "Payload Edge Function non valido."
}

if ((Get-Sha256 $SourceVerify) -ne $ExpectedVerifySha) {
    throw "Payload SQL di verifica non valido."
}

if (-not (Test-Path -LiteralPath $TargetFunction -PathType Leaf)) {
    throw "Edge Function locale non trovata: $TargetFunction"
}

$TargetFunctionSha = Get-Sha256 $TargetFunction
$FunctionAlreadyApplied = $TargetFunctionSha -eq $ExpectedFunctionSha

if (-not $FunctionAlreadyApplied) {
    $CurrentNormalizedSha = Get-NormalizedTextSha256 $TargetFunction
    if ($AllowedPreviousFunctionNormalizedSha -notcontains $CurrentNormalizedSha) {
        throw "Edge Function CURRENT diversa dalle versioni N2/N3 verificate. Nessun file sovrascritto."
    }
}

if (Test-Path -LiteralPath $TargetVerify -PathType Leaf) {
    if ((Get-Sha256 $TargetVerify) -ne $ExpectedVerifySha) {
        throw "VERIFY_NEWS_GLOBAL_N31.sql esiste ma è diverso. Nessun file sovrascritto."
    }
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Desktop = [Environment]::GetFolderPath("Desktop")
$BackupRoot = Join-Path $Desktop "SocialVote_News_N31_Backup_$Timestamp"

if (-not $FunctionAlreadyApplied) {
    $BackupFunction = Join-Path $BackupRoot "supabase\functions\news-cache-refresh\index.ts"
    New-Item -ItemType Directory -Path (Split-Path $BackupFunction -Parent) -Force | Out-Null
    Copy-Item -LiteralPath $TargetFunction -Destination $BackupFunction -Force

    Copy-Item -LiteralPath $SourceFunction -Destination $TargetFunction -Force
    if ((Get-Sha256 $TargetFunction) -ne $ExpectedFunctionSha) {
        throw "Verifica SHA256 fallita dopo la copia della Edge Function."
    }
}

New-Item -ItemType Directory -Path (Split-Path $TargetVerify -Parent) -Force | Out-Null
Copy-Item -LiteralPath $SourceVerify -Destination $TargetVerify -Force

$SavedScriptPath = Join-Path $ProjectRoot "tools\release\APPLY_AND_DEPLOY_NEWS_GLOBAL_N31.ps1"
if ([System.IO.Path]::GetFullPath($PSCommandPath) -ne [System.IO.Path]::GetFullPath($SavedScriptPath)) {
    Copy-Item -LiteralPath $PSCommandPath -Destination $SavedScriptPath -Force
}

$NpxCommand = Get-Command npx -ErrorAction SilentlyContinue
if ($null -eq $NpxCommand) {
    throw "npx non trovato. File applicati, deploy non eseguito."
}

Push-Location $ProjectRoot
try {
    & $NpxCommand.Source --yes supabase@2.111.0 functions deploy news-cache-refresh --project-ref rbuzlrclwhxaigkgndrb
    if ($LASTEXITCODE -ne 0) {
        throw "Deploy news-cache-refresh fallito. Exit code: $LASTEXITCODE"
    }
} finally {
    Pop-Location
}

Write-Host "`n========================================"
Write-Host "NEWS GLOBAL N3.1 DISTRIBUITO" -ForegroundColor Green
Write-Host "Runtime atteso: news-global-n3.1"
Write-Host "Payload atteso: 4"
Write-Host "Verifica SQL:" $TargetVerify
if (-not $FunctionAlreadyApplied) {
    Write-Host "Backup:" $BackupRoot
}
Write-Host "Build Web/Android: NON eseguita"
Write-Host "========================================"
