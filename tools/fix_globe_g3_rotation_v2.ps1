$ErrorActionPreference = 'Stop'

$projectRoot = 'C:\FLUTTER_PROJECTS\sociale_vote'
$file = Join-Path $projectRoot 'third_party\flutter_earth_globe_social_vote\lib\rotating_globe.dart'

if (-not (Test-Path $file)) {
    throw "File non trovato: $file"
}

$text = [IO.File]::ReadAllText($file).Replace("`r`n", "`n")

# Preconditions: G3 public fields already exist.
$requiredFields = @(
    'final bool lockVerticalRotation;',
    'final double maxVerticalTiltDegrees;',
    'final Duration decelerationDuration;',
    'final double inertiaStrength;'
)

foreach ($field in $requiredFields) {
    if (-not $text.Contains($field)) {
        throw "Precondizione G3 mancante: '$field'. Nessuna modifica applicata."
    }
}

$backup = "$file.before_g3_rotation_fix_v2"
if (-not (Test-Path $backup)) {
    Copy-Item $file $backup -Force
}

function Replace-Once {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Old,
        [Parameter(Mandatory = $true)][string]$New
    )

    if ($script:text.Contains($New)) {
        Write-Host "Gia applicato: $Label"
        return
    }

    $count = ([regex]::Matches(
        $script:text,
        [regex]::Escape($Old)
    )).Count

    if ($count -ne 1) {
        throw "Patch '$Label' non sicura: atteso 1 match, trovati $count. Nessun file scritto."
    }

    $script:text = $script:text.Replace($Old, $New)
    Write-Host "Applicato: $Label"
}

# 1) Helper: match corretto per il file reale 2.2.1,
#    dove hoveringPoint ha un commento sulla stessa riga.
Replace-Once `
    -Label 'max vertical tilt helper' `
    -Old @'
    return radius;
  }
  Offset? hoveringPoint; // The current hovering point on the sphere.
'@ `
    -New @'
    return radius;
  }

  double get _maxInteractiveTiltRadians {
    final degrees =
        widget.maxVerticalTiltDegrees.clamp(0.0, 89.0).toDouble();
    return radians(degrees);
  }

  Offset? hoveringPoint; // The current hovering point on the sphere.
'@

# 2) Decelerazione configurabile.
Replace-Once `
    -Label 'deceleration duration' `
    -Old @'
    _decelerationController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 1200), // Longer for smoother deceleration
    )..addListener(() {
'@ `
    -New @'
    _decelerationController = AnimationController(
      vsync: this,
      duration: widget.decelerationDuration,
    )..addListener(() {
'@

# 3) Blocco/clamp durante decelerazione.
Replace-Once `
    -Label 'deceleration vertical lock/clamp' `
    -Old @'
          rotationX =
              _initialRotationX + (_targetRotationX - _initialRotationX) * t;
          rotationY =
              _initialRotationY + (_targetRotationY - _initialRotationY) * t;
          rotationZ =
              _initialRotationZ + (_targetRotationZ - _initialRotationZ) * t;
'@ `
    -New @'
          final animatedRotationX =
              _initialRotationX + (_targetRotationX - _initialRotationX) * t;

          if (widget.lockVerticalRotation) {
            rotationX = 0.0;
            rotationY = 0.0;
          } else {
            rotationX = animatedRotationX
                .clamp(
                  -_maxInteractiveTiltRadians,
                  _maxInteractiveTiltRadians,
                )
                .toDouble();
            rotationY = -rotationX;
          }

          rotationZ =
              _initialRotationZ + (_targetRotationZ - _initialRotationZ) * t;
'@

# 4) Focus programmatico non puo capovolgere il globo.
Replace-Once `
    -Label 'programmatic focus vertical limit' `
    -Old @'
    final targetRotationZ = -lonRad;
    final targetRotationY = -latRad;
    final targetRotationX = latRad;
'@ `
    -New @'
    final targetRotationZ = -lonRad;
    final requestedTilt = latRad
        .clamp(
          -_maxInteractiveTiltRadians,
          _maxInteractiveTiltRadians,
        )
        .toDouble();
    final targetRotationX =
        widget.lockVerticalRotation ? 0.0 : requestedTilt;
    final targetRotationY =
        widget.lockVerticalRotation ? 0.0 : -requestedTilt;
'@

# 5) FIX PRINCIPALE: drag verticale.
Replace-Once `
    -Label 'gesture vertical lock/clamp' `
    -Old @'
                rotationX = adjustModRotation(_lastRotationX +
                    (offset.dy / convertedRadius()) * panFactor);
                rotationZ = adjustModRotation(_lastRotationZ -
                    (offset.dx / convertedRadius()) * panFactor);
                rotationY = adjustModRotation(_lastRotationY -
                    (offset.dy / convertedRadius()) * panFactor);
'@ `
    -New @'
                if (widget.lockVerticalRotation) {
                  rotationX = 0.0;
                  rotationY = 0.0;
                } else {
                  final requestedTilt = _lastRotationX +
                      (offset.dy / convertedRadius()) * panFactor;

                  rotationX = requestedTilt
                      .clamp(
                        -_maxInteractiveTiltRadians,
                        _maxInteractiveTiltRadians,
                      )
                      .toDouble();
                  rotationY = -rotationX;
                }

                rotationZ = adjustModRotation(_lastRotationZ -
                    (offset.dx / convertedRadius()) * panFactor);
'@

# 6) Intensita inerzia configurabile.
Replace-Once `
    -Label 'inertia strength' `
    -Old @'
                  final velocityFactor =
                      (velocityMagnitude / 4000.0) * zoomFactor;
'@ `
    -New @'
                  final inertiaStrength =
                      widget.inertiaStrength.clamp(0.0, 1.5).toDouble();
                  final velocityFactor =
                      (velocityMagnitude / 4000.0) *
                          zoomFactor *
                          inertiaStrength;
'@

# 7) Home: nessuna velocita verticale residua.
Replace-Once `
    -Label 'vertical angular velocity lock' `
    -Old @'
                  _angularVelocityX =
                      (velocity.dy / convertedRadius()) * panFactor;
                  _angularVelocityY =
                      (-velocity.dy / convertedRadius()) * panFactor;
                  _angularVelocityZ =
                      (-velocity.dx / convertedRadius()) * panFactor;
'@ `
    -New @'
                  if (widget.lockVerticalRotation) {
                    _angularVelocityX = 0.0;
                    _angularVelocityY = 0.0;
                  } else {
                    _angularVelocityX =
                        (velocity.dy / convertedRadius()) * panFactor;
                    _angularVelocityY = -_angularVelocityX;
                  }

                  _angularVelocityZ =
                      (-velocity.dx / convertedRadius()) * panFactor;
'@

# 8) Target finale inerzia limitato.
Replace-Once `
    -Label 'inertia target vertical clamp' `
    -Old @'
                  _targetRotationX =
                      rotationX + _angularVelocityX * velocityFactor;
                  _targetRotationY =
                      rotationY + _angularVelocityY * velocityFactor;
                  _targetRotationZ =
                      rotationZ + _angularVelocityZ * velocityFactor;
'@ `
    -New @'
                  if (widget.lockVerticalRotation) {
                    _targetRotationX = 0.0;
                    _targetRotationY = 0.0;
                  } else {
                    _targetRotationX =
                        (rotationX + _angularVelocityX * velocityFactor)
                            .clamp(
                              -_maxInteractiveTiltRadians,
                              _maxInteractiveTiltRadians,
                            )
                            .toDouble();
                    _targetRotationY = -_targetRotationX;
                  }

                  _targetRotationZ =
                      rotationZ + _angularVelocityZ * velocityFactor;
'@

# Write only after all 8 patches have been validated in memory.
[IO.File]::WriteAllText(
    $file,
    $text,
    [Text.UTF8Encoding]::new($false)
)

Write-Host ""
Write-Host "=== VERIFICA G3 V2 ==="

$checks = @(
    '_maxInteractiveTiltRadians',
    'if (widget.lockVerticalRotation)',
    'duration: widget.decelerationDuration',
    'widget.inertiaStrength.clamp'
)

foreach ($check in $checks) {
    $matches = Select-String -Path $file -SimpleMatch -Pattern $check
    Write-Host "$check -> $($matches.Count)"
}

Write-Host ""
Write-Host "PATCH G3 V2 APPLICATA COMPLETAMENTE"
Write-Host "Backup: $backup"
