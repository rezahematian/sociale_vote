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

$worldBackup = "$worldFile.before_g3_home_tilt_v4"
$globeBackup = "$globeFile.before_g3_home_tilt_v4"

if (-not (Test-Path $worldBackup)) {
    Copy-Item $worldFile $worldBackup -Force
}
if (-not (Test-Path $globeBackup)) {
    Copy-Item $globeFile $globeBackup -Force
}

function Replace-OnceInMemory {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Old,
        [Parameter(Mandatory = $true)][string]$New
    )

    $count = ([regex]::Matches(
        $Text,
        [regex]::Escape($Old)
    )).Count

    if ($count -ne 1) {
        throw "Patch '$Label' non sicura: atteso 1 match, trovati $count. Nessun file scritto."
    }

    return $Text.Replace($Old, $New)
}

# ------------------------------------------------------------------
# 1) Home limit: 0° -> 22°
# Explore remains 55°.
# ------------------------------------------------------------------
$world = Replace-OnceInMemory `
    -Label 'Home vertical limit 22 degrees' `
    -Text $world `
    -Old '          maxVerticalTiltDegrees: _isHomeProfile ? 0.0 : 55.0,' `
    -New '          maxVerticalTiltDegrees: _isHomeProfile ? 22.0 : 55.0,'

# ------------------------------------------------------------------
# 2) Gesture start:
# keep current Home tilt instead of resetting X/Y to zero.
# Clamp it inside ±22°.
# ------------------------------------------------------------------
$globe = Replace-OnceInMemory `
    -Label 'Home preserve limited tilt on gesture start' `
    -Text $globe `
    -Old @'
if (widget.lockVerticalRotation) {
  rotationX = 0.0;
  rotationY = 0.0;
  _lastRotationX = 0.0;
  _lastRotationY = 0.0;
}
'@ `
    -New @'
if (widget.lockVerticalRotation) {
  final maxHomeTilt = radians(
    widget.maxVerticalTiltDegrees.clamp(0.0, 45.0).toDouble(),
  );

  rotationX = rotationX.clamp(-maxHomeTilt, maxHomeTilt).toDouble();
  rotationY = -rotationX;
  _lastRotationX = rotationX;
  _lastRotationY = rotationY;
}
'@

# ------------------------------------------------------------------
# 3) Drag:
# Home gets restrained vertical movement:
# - ±22°
# - vertical sensitivity = 35% of the normal pan factor
# Horizontal Z rotation is unchanged.
# ------------------------------------------------------------------
$globe = Replace-OnceInMemory `
    -Label 'Home restrained vertical drag' `
    -Text $globe `
    -Old @'
if (widget.lockVerticalRotation) {
  rotationX = 0.0;
  rotationY = 0.0;
} else {
  rotationX = adjustModRotation(_lastRotationX +
      (offset.dy / convertedRadius()) * panFactor);
  rotationY = adjustModRotation(_lastRotationY -
      (offset.dy / convertedRadius()) * panFactor);
}
'@ `
    -New @'
if (widget.lockVerticalRotation) {
  final maxHomeTilt = radians(
    widget.maxVerticalTiltDegrees.clamp(0.0, 45.0).toDouble(),
  );
  final requestedHomeTilt = _lastRotationX +
      (offset.dy / convertedRadius()) * panFactor * 0.35;

  rotationX =
      requestedHomeTilt.clamp(-maxHomeTilt, maxHomeTilt).toDouble();
  rotationY = -rotationX;
} else {
  rotationX = adjustModRotation(_lastRotationX +
      (offset.dy / convertedRadius()) * panFactor);
  rotationY = adjustModRotation(_lastRotationY -
      (offset.dy / convertedRadius()) * panFactor);
}
'@

# ------------------------------------------------------------------
# 4) Inertia target:
# keep the chosen Home tilt instead of forcing it back to 0.
# Vertical inertia itself remains disabled by V3.
# ------------------------------------------------------------------
$globe = Replace-OnceInMemory `
    -Label 'Home retain tilt during horizontal inertia' `
    -Text $globe `
    -Old @'
if (widget.lockVerticalRotation) {
  _targetRotationX = 0.0;
  _targetRotationY = 0.0;
} else {
  _targetRotationX =
      rotationX + _angularVelocityX * velocityFactor;
  _targetRotationY =
      rotationY + _angularVelocityY * velocityFactor;
}
'@ `
    -New @'
if (widget.lockVerticalRotation) {
  _targetRotationX = rotationX;
  _targetRotationY = rotationY;
} else {
  _targetRotationX =
      rotationX + _angularVelocityX * velocityFactor;
  _targetRotationY =
      rotationY + _angularVelocityY * velocityFactor;
}
'@

# Write only after all replacements validated.
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
Write-Host "=== G3 HOME VERTICAL V4 ==="
Write-Host "Home max vertical tilt : +/-22 degrees"
Write-Host "Home vertical speed    : 35%"
Write-Host "Home vertical inertia  : OFF"
Write-Host "Explore vertical limit : unchanged (55 degrees)"
Write-Host ""
Write-Host "PATCH G3 HOME VERTICAL V4 APPLICATA"
Write-Host "Backup world: $worldBackup"
Write-Host "Backup globe: $globeBackup"
