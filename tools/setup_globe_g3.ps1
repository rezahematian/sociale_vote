$ErrorActionPreference = 'Stop'

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$target = Join-Path $projectRoot 'third_party\flutter_earth_globe_social_vote'

$cacheCandidates = @()

if ($env:PUB_CACHE) {
    $cacheCandidates += (Join-Path $env:PUB_CACHE 'hosted\pub.dev\flutter_earth_globe-2.2.1')
}

if ($env:LOCALAPPDATA) {
    $cacheCandidates += (Join-Path $env:LOCALAPPDATA 'Pub\Cache\hosted\pub.dev\flutter_earth_globe-2.2.1')
}

if ($env:USERPROFILE) {
    $cacheCandidates += (Join-Path $env:USERPROFILE '.pub-cache\hosted\pub.dev\flutter_earth_globe-2.2.1')
    $cacheCandidates += (Join-Path $env:USERPROFILE 'AppData\Local\Pub\Cache\hosted\pub.dev\flutter_earth_globe-2.2.1')
}

$source = $cacheCandidates |
    Where-Object { $_ -and (Test-Path $_) } |
    Select-Object -First 1

if (-not $source) {
    throw @"
flutter_earth_globe 2.2.1 non trovato nella Pub cache.

Prima esegui, con il pubspec precedente oppure da una copia del progetto:
flutter pub get

Poi rilancia questo script.
"@
}

$sourcePubspec = Join-Path $source 'pubspec.yaml'
$sourcePubspecText = [IO.File]::ReadAllText($sourcePubspec)

if ($sourcePubspecText -notmatch '(?m)^version:\s*2\.2\.1\s*$') {
    throw "La sorgente trovata non e flutter_earth_globe 2.2.1: $source"
}

Write-Host "Source package: $source"
Write-Host "Target package: $target"

if (Test-Path $target) {
    Remove-Item $target -Recurse -Force
}

New-Item -ItemType Directory -Path (Split-Path $target -Parent) -Force | Out-Null
Copy-Item $source $target -Recurse -Force

$flutterEarthGlobePath = Join-Path $target 'lib\flutter_earth_globe.dart'
$rotatingGlobePath = Join-Path $target 'lib\rotating_globe.dart'

function Replace-Exact {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Old,
        [Parameter(Mandatory = $true)][string]$New,
        [Parameter(Mandatory = $true)][string]$Label
    )

    $text = [IO.File]::ReadAllText($Path).Replace("`r`n", "`n")
    $oldNormalized = $Old.Replace("`r`n", "`n")
    $newNormalized = $New.Replace("`r`n", "`n")

    $count = ([regex]::Matches(
        $text,
        [regex]::Escape($oldNormalized)
    )).Count

    if ($count -ne 1) {
        throw "Patch '$Label' non applicabile in modo sicuro. Match trovati: $count. File: $Path"
    }

    $text = $text.Replace($oldNormalized, $newNormalized)

    [IO.File]::WriteAllText(
        $Path,
        $text,
        [Text.UTF8Encoding]::new($false)
    )
}

# ---------------------------------------------------------------------------
# flutter_earth_globe.dart
# Espone quattro parametri di interazione senza cambiare renderer/shader/API
# esistenti.
# ---------------------------------------------------------------------------

Replace-Exact `
    -Path $flutterEarthGlobePath `
    -Label 'public interaction fields' `
    -Old @'
  final void Function(GlobeCoordinates? coordinates)? onTap;
'@ `
    -New @'
  final void Function(GlobeCoordinates? coordinates)? onTap;

  /// Social Vote interaction controls.
  ///
  /// These are additive and default to the original package behaviour.
  final bool lockVerticalRotation;
  final double maxVerticalTiltDegrees;
  final Duration decelerationDuration;
  final double inertiaStrength;
'@

Replace-Exact `
    -Path $flutterEarthGlobePath `
    -Label 'public constructor parameters' `
    -Old @'
    this.onHover,
    this.onTap,
  });
'@ `
    -New @'
    this.onHover,
    this.onTap,
    this.lockVerticalRotation = false,
    this.maxVerticalTiltDegrees = 55.0,
    this.decelerationDuration = const Duration(milliseconds: 1200),
    this.inertiaStrength = 1.0,
  });
'@

Replace-Exact `
    -Path $flutterEarthGlobePath `
    -Label 'forward interaction parameters' `
    -Old @'
      onHover: widget.onHover,
      onTap: widget.onTap,
    );
'@ `
    -New @'
      onHover: widget.onHover,
      onTap: widget.onTap,
      lockVerticalRotation: widget.lockVerticalRotation,
      maxVerticalTiltDegrees: widget.maxVerticalTiltDegrees,
      decelerationDuration: widget.decelerationDuration,
      inertiaStrength: widget.inertiaStrength,
    );
'@

# ---------------------------------------------------------------------------
# rotating_globe.dart
# Patch locale G3:
# - Home: niente tilt verticale
# - Explore: tilt limitato
# - inerzia configurabile e piu corta
# - renderer, shader, texture, punti e zoom originali restano intatti
# ---------------------------------------------------------------------------

Replace-Exact `
    -Path $rotatingGlobePath `
    -Label 'rotating globe constructor parameters' `
    -Old @'
    this.onZoomChanged,
    this.onHover,
    this.onTap,
  });
'@ `
    -New @'
    this.onZoomChanged,
    this.onHover,
    this.onTap,
    this.lockVerticalRotation = false,
    this.maxVerticalTiltDegrees = 55.0,
    this.decelerationDuration = const Duration(milliseconds: 1200),
    this.inertiaStrength = 1.0,
  });
'@

Replace-Exact `
    -Path $rotatingGlobePath `
    -Label 'rotating globe fields' `
    -Old @'
  final void Function(GlobeCoordinates? coordinates)? onTap;

'@ `
    -New @'
  final void Function(GlobeCoordinates? coordinates)? onTap;

  /// Additive Social Vote interaction controls.
  ///
  /// Defaults preserve the original package behaviour.
  final bool lockVerticalRotation;
  final double maxVerticalTiltDegrees;
  final Duration decelerationDuration;
  final double inertiaStrength;

'@

Replace-Exact `
    -Path $rotatingGlobePath `
    -Label 'max tilt helper' `
    -Old @'
    return radius;
  }
  Offset? hoveringPoint;
'@ `
    -New @'
    return radius;
  }

  double get _maxInteractiveTiltRadians {
    final degrees =
        widget.maxVerticalTiltDegrees.clamp(0.0, 89.0).toDouble();
    return radians(degrees);
  }

  Offset? hoveringPoint;
'@

Replace-Exact `
    -Path $rotatingGlobePath `
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

Replace-Exact `
    -Path $rotatingGlobePath `
    -Label 'deceleration vertical clamp' `
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

Replace-Exact `
    -Path $rotatingGlobePath `
    -Label 'programmatic focus respects Home axis lock' `
    -Old @'
    final targetRotationZ = -lonRad;
    final targetRotationY = -latRad;
    final targetRotationX = latRad;
'@ `
    -New @'
    final targetRotationZ = -lonRad;
    final targetRotationY = widget.lockVerticalRotation ? 0.0 : -latRad;
    final targetRotationX = widget.lockVerticalRotation ? 0.0 : latRad;
'@

Replace-Exact `
    -Path $rotatingGlobePath `
    -Label 'gesture vertical clamp' `
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
                  final nextTilt = _lastRotationX +
                      (offset.dy / convertedRadius()) * panFactor;

                  rotationX = nextTilt
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

Replace-Exact `
    -Path $rotatingGlobePath `
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

Replace-Exact `
    -Path $rotatingGlobePath `
    -Label 'inertia vertical velocity' `
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

Replace-Exact `
    -Path $rotatingGlobePath `
    -Label 'inertia target clamp' `
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

$marker = @'
SOCIAL VOTE - flutter_earth_globe 2.2.1 local G3 patch

Purpose:
- preserve upstream renderer/shaders/textures
- Home: vertical rotation locked, North stays up
- Explore: vertical tilt limited
- shorter configurable deceleration
- configurable inertia strength

Generated from the exact flutter_earth_globe 2.2.1 package already present
in the local Pub cache. The original cache is never modified.
'@

[IO.File]::WriteAllText(
    (Join-Path $target 'SOCIAL_VOTE_G3_PATCH.txt'),
    $marker,
    [Text.UTF8Encoding]::new($false)
)

Write-Host ''
Write-Host 'G3 local globe package prepared successfully.'
Write-Host 'Pub cache was NOT modified.'
Write-Host ''
Write-Host 'Next: flutter pub get'
