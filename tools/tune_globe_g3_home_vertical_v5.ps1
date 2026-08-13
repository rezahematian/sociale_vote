$ErrorActionPreference = 'Stop'

$projectRoot = 'C:\FLUTTER_PROJECTS\sociale_vote'
$worldFile = Join-Path $projectRoot 'lib\features\map\presentation\widgets\world_globe_widget.dart'
$globeFile = Join-Path $projectRoot 'third_party\flutter_earth_globe_social_vote\lib\rotating_globe.dart'

foreach ($file in @($worldFile, $globeFile)) {
    if (-not (Test-Path $file)) {
        throw "File non trovato: $file"
    }
}

$world = [IO.File]::ReadAllText($worldFile).Replace("`r`n", "`n")
$globe = [IO.File]::ReadAllText($globeFile).Replace("`r`n", "`n")

$worldBackup = "$worldFile.before_g3_home_vertical_v5"
$globeBackup = "$globeFile.before_g3_home_vertical_v5"

if (-not (Test-Path $worldBackup)) {
    Copy-Item $worldFile $worldBackup -Force
}
if (-not (Test-Path $globeBackup)) {
    Copy-Item $globeFile $globeBackup -Force
}

function Replace-RegexOnce {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Pattern,
        [Parameter(Mandatory = $true)][string]$Replacement
    )

    $matches = [regex]::Matches(
        $Text,
        $Pattern,
        [Text.RegularExpressions.RegexOptions]::Multiline
    )

    if ($matches.Count -ne 1) {
        throw "Patch '$Label' non sicura: atteso 1 match, trovati $($matches.Count). Nessun file scritto."
    }

    Write-Host "OK: $Label"

    return [regex]::Replace(
        $Text,
        $Pattern,
        $Replacement,
        [Text.RegularExpressions.RegexOptions]::Multiline
    )
}

# 1) Home max tilt: 0 -> 22 degrees. Explore remains 55.
$world = Replace-RegexOnce `
    -Label 'Home max tilt +/-22 degrees' `
    -Text $world `
    -Pattern 'maxVerticalTiltDegrees:\s*_isHomeProfile\s*\?\s*0\.0\s*:\s*55\.0,' `
    -Replacement 'maxVerticalTiltDegrees: _isHomeProfile ? 22.0 : 55.0,'

# 2) At gesture start, V3 currently resets Home X/Y to zero.
#    V5 preserves the current tilt but clamps it inside +/-22 degrees.
$globe = Replace-RegexOnce `
    -Label 'preserve limited Home tilt at gesture start' `
    -Text $globe `
    -Pattern '(?ms)(?<i>^[ \t]*)if\s*\(widget\.lockVerticalRotation\)\s*\{\s*rotationX\s*=\s*0\.0;\s*rotationY\s*=\s*0\.0;\s*_lastRotationX\s*=\s*0\.0;\s*_lastRotationY\s*=\s*0\.0;\s*\}' `
    -Replacement @'
${i}if (widget.lockVerticalRotation) {
${i}  final maxHomeTilt = radians(
${i}    widget.maxVerticalTiltDegrees.clamp(0.0, 45.0).toDouble(),
${i}  );
${i}  rotationX = rotationX.clamp(-maxHomeTilt, maxHomeTilt).toDouble();
${i}  rotationY = -rotationX;
${i}  _lastRotationX = rotationX;
${i}  _lastRotationY = rotationY;
${i}}
'@

# 3) During drag, Home receives a restrained vertical tilt.
#    Horizontal rotation remains exactly as V3.
$globe = Replace-RegexOnce `
    -Label 'Home vertical drag 35 percent' `
    -Text $globe `
    -Pattern '(?ms)(?<i>^[ \t]*)if\s*\(widget\.lockVerticalRotation\)\s*\{\s*rotationX\s*=\s*0\.0;\s*rotationY\s*=\s*0\.0;\s*\}\s*else\s*\{\s*rotationX\s*=\s*adjustModRotation\(_lastRotationX\s*\+\s*\(offset\.dy\s*/\s*convertedRadius\(\)\)\s*\*\s*panFactor\);\s*rotationY\s*=\s*adjustModRotation\(_lastRotationY\s*-\s*\(offset\.dy\s*/\s*convertedRadius\(\)\)\s*\*\s*panFactor\);\s*\}' `
    -Replacement @'
${i}if (widget.lockVerticalRotation) {
${i}  final maxHomeTilt = radians(
${i}    widget.maxVerticalTiltDegrees.clamp(0.0, 45.0).toDouble(),
${i}  );
${i}  final requestedHomeTilt = _lastRotationX +
${i}      (offset.dy / convertedRadius()) * panFactor * 0.35;
${i}  rotationX =
${i}      requestedHomeTilt.clamp(-maxHomeTilt, maxHomeTilt).toDouble();
${i}  rotationY = -rotationX;
${i}} else {
${i}  rotationX = adjustModRotation(_lastRotationX +
${i}      (offset.dy / convertedRadius()) * panFactor);
${i}  rotationY = adjustModRotation(_lastRotationY -
${i}      (offset.dy / convertedRadius()) * panFactor);
${i}}
'@

# 4) V3 disables vertical angular velocity. Keep that.
#    But do not snap X/Y back to zero when horizontal inertia starts.
$globe = Replace-RegexOnce `
    -Label 'retain Home tilt during horizontal inertia' `
    -Text $globe `
    -Pattern '(?ms)(?<i>^[ \t]*)if\s*\(widget\.lockVerticalRotation\)\s*\{\s*_targetRotationX\s*=\s*0\.0;\s*_targetRotationY\s*=\s*0\.0;\s*\}\s*else\s*\{' `
    -Replacement @'
${i}if (widget.lockVerticalRotation) {
${i}  _targetRotationX = rotationX;
${i}  _targetRotationY = rotationY;
${i}} else {
'@

# Write only after all matches were validated in memory.
[IO.File]::WriteAllText(
    $worldFile,
    $world,
    [Text.UTF8Encoding]::new($false)
)

[IO.File]::WriteAllText(
    $globeFile,
    $globe,
    [Text.UTF8Encoding]::new($false)
)

Write-Host ""
Write-Host "=== G3 HOME VERTICAL V5 ==="
Write-Host "Home max tilt        : +/-22 degrees"
Write-Host "Vertical sensitivity : 35%"
Write-Host "Vertical inertia     : OFF"
Write-Host "Horizontal rotation  : unchanged"
Write-Host "Explore limit        : unchanged (55 degrees)"
Write-Host ""
Write-Host "PATCH G3 HOME VERTICAL V5 APPLICATA"
Write-Host "Backup world: $worldBackup"
Write-Host "Backup globe: $globeBackup"
