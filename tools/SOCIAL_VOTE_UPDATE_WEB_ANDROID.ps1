param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Web", "Android")]
    [string]$Target,

    [string]$ProjectDir = "C:\FLUTTER_PROJECTS\sociale_vote",

    [switch]$InstallApk
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-NativeCommandSucceeded {
    param([Parameter(Mandatory = $true)][string]$Step)

    if ($LASTEXITCODE -ne 0) {
        throw "$Step fallito. Exit code: $LASTEXITCODE"
    }
}

function Invoke-SocialVoteWebUpdate {
    $AssetLinksSource = Join-Path (Get-Location) "web\assetlinks.json"
    $GlobeSource = Join-Path (Get-Location) "web\social_vote_globe.js"

    if (-not (Test-Path $AssetLinksSource)) {
        throw "Manca web\assetlinks.json: deploy interrotto."
    }

    if (-not (Test-Path $GlobeSource)) {
        throw "Manca web\social_vote_globe.js: deploy interrotto."
    }

    $AssetLinksText = Get-Content $AssetLinksSource -Raw
    if ($AssetLinksText -notmatch '"package_name"\s*:\s*"com\.hematianapps\.socialvote"') {
        throw "web\assetlinks.json non contiene com.hematianapps.socialvote."
    }

    $GlobeText = Get-Content $GlobeSource -Raw
    $BuildMatch = [regex]::Match(
        $GlobeText,
        "SOCIAL_VOTE_GLOBE_BUILD\s*=\s*'([^']+)'"
    )

    if (-not $BuildMatch.Success) {
        throw "Build ID non trovato in web\social_vote_globe.js."
    }

    $BuildId = $BuildMatch.Groups[1].Value
    Write-Host "`nBuild Web rilevata: $BuildId" -ForegroundColor Cyan

    flutter build web --release
    Assert-NativeCommandSucceeded "flutter build web"

    $WellKnownDir = Join-Path (Get-Location) "build\web\.well-known"
    New-Item -ItemType Directory -Path $WellKnownDir -Force | Out-Null
    Copy-Item `
        $AssetLinksSource `
        (Join-Path $WellKnownDir "assetlinks.json") `
        -Force

    if (-not (Test-Path (Join-Path $WellKnownDir "assetlinks.json"))) {
        throw "assetlinks.json non preservato: deploy interrotto."
    }

    $FirebaseCommand = Get-Command firebase -ErrorAction SilentlyContinue
    if ($null -ne $FirebaseCommand) {
        & $FirebaseCommand.Source deploy --only hosting
    } else {
        $NpxCommand = Get-Command npx -ErrorAction SilentlyContinue
        if ($null -eq $NpxCommand) {
            throw "Firebase CLI e npx non trovati."
        }

        & $NpxCommand.Source firebase-tools deploy --only hosting
    }
    Assert-NativeCommandSucceeded "Firebase Hosting deploy"

    $CacheBust = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $Headers = @{ "Cache-Control" = "no-cache" }
    $DomainJsUrl = "https://socialevote.com/social_vote_globe.js?v=$BuildId&check=$CacheBust"
    $OriginJsUrl = "https://socialevote.web.app/social_vote_globe.js?v=$BuildId&check=$CacheBust"

    $DomainJs = (Invoke-WebRequest `
        -Uri $DomainJsUrl `
        -UseBasicParsing `
        -Headers $Headers).Content

    $OriginJs = (Invoke-WebRequest `
        -Uri $OriginJsUrl `
        -UseBasicParsing `
        -Headers $Headers).Content

    $DomainCurrent = $DomainJs -match [regex]::Escape($BuildId)
    $OriginCurrent = $OriginJs -match [regex]::Escape($BuildId)

    $PublicAssetLinks = (Invoke-WebRequest `
        -Uri "https://socialevote.com/.well-known/assetlinks.json?check=$CacheBust" `
        -UseBasicParsing `
        -Headers $Headers).Content

    if ($PublicAssetLinks -notmatch '"package_name"\s*:\s*"com\.hematianapps\.socialvote"') {
        throw "ERRORE: assetlinks pubblico non contiene il package Android corretto."
    }

    Write-Host "`n========================================"
    Write-Host "WEB UPDATE COMPLETATO"
    Write-Host "Build:" $BuildId
    Write-Host "Firebase origin aggiornato:" $OriginCurrent
    Write-Host "Dominio reale aggiornato:" $DomainCurrent
    Write-Host "Asset Links pubblico: OK"
    Write-Host "========================================"

    if ($OriginCurrent -and -not $DomainCurrent) {
        Write-Warning "web.app e aggiornato ma socialevote.com e vecchio: fare Cloudflare Purge mirato."
    } elseif (-not $OriginCurrent) {
        Write-Warning "La nuova build non risulta ancora sul Firebase origin."
    }
}

function Invoke-SocialVoteAndroidCandidate {
    $ManifestPath = Join-Path `
        (Get-Location) `
        "android\app\src\main\AndroidManifest.xml"

    if (-not (Test-Path $ManifestPath)) {
        throw "AndroidManifest.xml non trovato."
    }

    $ManifestText = Get-Content $ManifestPath -Raw
    if ($ManifestText -notmatch 'android:pathPrefix\s*=\s*"/join') {
        throw "Prima della candidata Android devi aggiungere /join agli Android App Links. Build interrotta."
    }

    $PubspecText = Get-Content "pubspec.yaml" -Raw
    if ($PubspecText -notmatch '(?m)^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$') {
        throw "Versione pubspec non riconosciuta."
    }

    $CurrentVersionName = $Matches[1]
    $CurrentBuildNumber = [int]$Matches[2]

    $RawPlayVersionCode = Read-Host `
        "Ultimo versionCode realmente presente su Google Play"
    $PlayVersionCode = 0

    if (-not [int]::TryParse(
        $RawPlayVersionCode,
        [ref]$PlayVersionCode
    )) {
        throw "versionCode Play non valido."
    }

    $BuildNumber = [Math]::Max(
        $PlayVersionCode,
        $CurrentBuildNumber
    ) + 1

    $RequestedVersionName = Read-Host `
        "versionName candidato [Invio = $CurrentVersionName]"

    $VersionName = if ([string]::IsNullOrWhiteSpace($RequestedVersionName)) {
        $CurrentVersionName
    } else {
        $RequestedVersionName.Trim()
    }

    Write-Host "`nCandidata Android:" -ForegroundColor Cyan
    Write-Host "versionName:" $VersionName
    Write-Host "versionCode:" $BuildNumber
    Write-Host "Verranno creati AAB e APK con la stessa versione."

    $Confirmation = (Read-Host "Scrivi SI per creare la candidata finale").Trim()
    if ($Confirmation -notin @("SI", "S", "YES", "Y")) {
        throw "Build Android annullata."
    }

    flutter pub get
    Assert-NativeCommandSucceeded "flutter pub get"

    flutter build appbundle `
        --release `
        --build-name=$VersionName `
        --build-number=$BuildNumber
    Assert-NativeCommandSucceeded "flutter build appbundle"

    flutter build apk `
        --release `
        --build-name=$VersionName `
        --build-number=$BuildNumber
    Assert-NativeCommandSucceeded "flutter build apk"

    $AabPath = (Resolve-Path `
        "build\app\outputs\bundle\release\app-release.aab").Path
    $ApkPath = (Resolve-Path `
        "build\app\outputs\flutter-apk\app-release.apk").Path

    $Desktop = [Environment]::GetFolderPath("Desktop")
    $SafeVersionName = $VersionName -replace '[^0-9A-Za-z._-]', '_'
    $ReleaseDir = Join-Path `
        $Desktop `
        "SocialVote_Android_${SafeVersionName}_${BuildNumber}"

    New-Item -ItemType Directory -Path $ReleaseDir -Force | Out-Null
    Copy-Item $AabPath $ReleaseDir -Force
    Copy-Item $ApkPath $ReleaseDir -Force

    $HashFile = Join-Path $ReleaseDir "SHA256.csv"
    Get-FileHash $AabPath, $ApkPath -Algorithm SHA256 |
        Select-Object Path, Hash |
        Export-Csv $HashFile -NoTypeInformation -Encoding UTF8 -Force

    if ($InstallApk) {
        $AdbCommand = Get-Command adb -ErrorAction SilentlyContinue
        if ($null -eq $AdbCommand) {
            throw "APK creato, ma adb non e stato trovato per installarlo."
        }

        & $AdbCommand.Source install -r $ApkPath
        Assert-NativeCommandSucceeded "adb install -r"

        & $AdbCommand.Source shell dumpsys package com.hematianapps.socialvote |
            Select-String "versionCode=|versionName=" |
            Select-Object -First 2
    }

    Write-Host "`n========================================"
    Write-Host "CANDIDATA ANDROID COMPLETATA"
    Write-Host "versionName:" $VersionName
    Write-Host "versionCode:" $BuildNumber
    Write-Host "AAB:" $AabPath
    Write-Host "APK:" $ApkPath
    Write-Host "Copia finale:" $ReleaseDir
    Write-Host "Hash:" $HashFile
    Write-Host "========================================"
}

if (-not (Test-Path $ProjectDir)) {
    throw "Progetto non trovato: $ProjectDir"
}

if (-not (Test-Path (Join-Path $ProjectDir "pubspec.yaml"))) {
    throw "pubspec.yaml non trovato in: $ProjectDir"
}

Push-Location $ProjectDir

try {
    switch ($Target) {
        "Web" {
            Invoke-SocialVoteWebUpdate
        }
        "Android" {
            Invoke-SocialVoteAndroidCandidate
        }
    }
} finally {
    Pop-Location
}
