$ErrorActionPreference = 'Stop'

$projectRoot = 'C:\FLUTTER_PROJECTS\sociale_vote'
$file = Join-Path $projectRoot 'third_party\flutter_earth_globe_social_vote\lib\rotating_globe.dart'

if (-not (Test-Path $file)) {
    throw "File non trovato: $file"
}

$text = [IO.File]::ReadAllText($file).Replace("`r`n", "`n")

if (-not $text.Contains('final bool lockVerticalRotation;')) {
    throw "Manca lockVerticalRotation nel package locale. Nessuna modifica eseguita."
}

$backup = "$file.before_g3_home_lock_v3"
if (-not (Test-Path $backup)) {
    Copy-Item $file $backup -Force
}

function Replace-RegexOnce {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Pattern,
        [Parameter(Mandatory = $true)][string]$Replacement
    )

    $matches = [regex]::Matches(
        $script:text,
        $Pattern,
        [Text.RegularExpressions.RegexOptions]::Multiline
    )

    if ($matches.Count -ne 1) {
        throw "Patch '$Label' non sicura: atteso 1 match, trovati $($matches.Count). Nessun file scritto."
    }

    $script:text = [regex]::Replace(
        $script:text,
        $Pattern,
        $Replacement,
        [Text.RegularExpressions.RegexOptions]::Multiline
    )

    Write-Host "OK: $Label"
}

# 1) All'inizio di ogni gesto Home azzera qualunque tilt X/Y residuo.
Replace-RegexOnce `
    -Label 'interaction start Home lock' `
    -Pattern '(?m)^(\s*)_lastRotationX\s*=\s*rotationX;\s*\n\s*_lastRotationZ\s*=\s*rotationZ;\s*\n\s*_lastRotationY\s*=\s*rotationY;' `
    -Replacement @'
$1_lastRotationX = rotationX;
$1_lastRotationZ = rotationZ;
$1_lastRotationY = rotationY;
$1if (widget.lockVerticalRotation) {
$1  rotationX = 0.0;
$1  rotationY = 0.0;
$1  _lastRotationX = 0.0;
$1  _lastRotationY = 0.0;
$1}
'@

# 2) Durante il drag Home gira solo Z (Est/Ovest).
Replace-RegexOnce `
    -Label 'drag Home horizontal only' `
    -Pattern '(?ms)^(\s*)rotationX\s*=\s*adjustModRotation\(_lastRotationX\s*\+\s*\(offset\.dy\s*/\s*convertedRadius\(\)\)\s*\*\s*panFactor\);\s*\n\s*rotationZ\s*=\s*adjustModRotation\(_lastRotationZ\s*-\s*\(offset\.dx\s*/\s*convertedRadius\(\)\)\s*\*\s*panFactor\);\s*\n\s*rotationY\s*=\s*adjustModRotation\(_lastRotationY\s*-\s*\(offset\.dy\s*/\s*convertedRadius\(\)\)\s*\*\s*panFactor\);' `
    -Replacement @'
$1if (widget.lockVerticalRotation) {
$1  rotationX = 0.0;
$1  rotationY = 0.0;
$1} else {
$1  rotationX = adjustModRotation(_lastRotationX +
$1      (offset.dy / convertedRadius()) * panFactor);
$1  rotationY = adjustModRotation(_lastRotationY -
$1      (offset.dy / convertedRadius()) * panFactor);
$1}
$1rotationZ = adjustModRotation(_lastRotationZ -
$1    (offset.dx / convertedRadius()) * panFactor);
'@

# 3) In Home nessuna velocita inerziale su X/Y.
Replace-RegexOnce `
    -Label 'Home vertical inertia velocity off' `
    -Pattern '(?ms)^(\s*)_angularVelocityX\s*=\s*\(velocity\.dy\s*/\s*convertedRadius\(\)\)\s*\*\s*panFactor;\s*\n\s*_angularVelocityY\s*=\s*\(-velocity\.dy\s*/\s*convertedRadius\(\)\)\s*\*\s*panFactor;\s*\n\s*_angularVelocityZ\s*=\s*\(-velocity\.dx\s*/\s*convertedRadius\(\)\)\s*\*\s*panFactor;' `
    -Replacement @'
$1if (widget.lockVerticalRotation) {
$1  _angularVelocityX = 0.0;
$1  _angularVelocityY = 0.0;
$1} else {
$1  _angularVelocityX =
$1      (velocity.dy / convertedRadius()) * panFactor;
$1  _angularVelocityY =
$1      (-velocity.dy / convertedRadius()) * panFactor;
$1}
$1_angularVelocityZ =
$1    (-velocity.dx / convertedRadius()) * panFactor;
'@

# 4) Anche il target dell'inerzia Home resta X/Y = 0.
Replace-RegexOnce `
    -Label 'Home inertia target lock' `
    -Pattern '(?ms)^(\s*)_targetRotationX\s*=\s*rotationX\s*\+\s*_angularVelocityX\s*\*\s*velocityFactor;\s*\n\s*_targetRotationY\s*=\s*rotationY\s*\+\s*_angularVelocityY\s*\*\s*velocityFactor;\s*\n\s*_targetRotationZ\s*=\s*rotationZ\s*\+\s*_angularVelocityZ\s*\*\s*velocityFactor;' `
    -Replacement @'
$1if (widget.lockVerticalRotation) {
$1  _targetRotationX = 0.0;
$1  _targetRotationY = 0.0;
$1} else {
$1  _targetRotationX =
$1      rotationX + _angularVelocityX * velocityFactor;
$1  _targetRotationY =
$1      rotationY + _angularVelocityY * velocityFactor;
$1}
$1_targetRotationZ =
$1    rotationZ + _angularVelocityZ * velocityFactor;
'@

# Solo adesso, dopo che tutti e 4 i match sono stati validati in memoria,
# scriviamo il file.
[IO.File]::WriteAllText(
    $file,
    $text,
    [Text.UTF8Encoding]::new($false)
)

Write-Host ""
Write-Host "=== VERIFICA HOME LOCK ==="
$lockCount = (Select-String -Path $file -SimpleMatch -Pattern 'if (widget.lockVerticalRotation)').Count
Write-Host "lockVerticalRotation runtime blocks: $lockCount"

if ($lockCount -lt 4) {
    throw "Verifica finale fallita: trovati solo $lockCount blocchi runtime."
}

Write-Host ""
Write-Host "PATCH G3 HOME LOCK V3 APPLICATA"
Write-Host "Backup: $backup"
