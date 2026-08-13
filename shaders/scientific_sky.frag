#version 460 core

#include <flutter/runtime_effect.glsl>

out vec4 fragColor;

uniform float uResolutionX;
uniform float uResolutionY;
uniform float uYaw;
uniform float uPitch;
uniform float uFovY;
uniform float uExposure;
uniform sampler2D uSkyTexture;

const float PI = 3.14159265358979323846;
const float TWO_PI = 6.28318530717958647692;

mat3 rotationX(float angle) {
  float c = cos(angle);
  float s = sin(angle);

  return mat3(
    1.0, 0.0, 0.0,
    0.0, c,   -s,
    0.0, s,    c
  );
}

mat3 rotationY(float angle) {
  float c = cos(angle);
  float s = sin(angle);

  return mat3(
     c,   0.0, s,
     0.0, 1.0, 0.0,
    -s,   0.0, c
  );
}

void main() {
  vec2 resolution = vec2(
    max(uResolutionX, 1.0),
    max(uResolutionY, 1.0)
  );

  vec2 pixel = FlutterFragCoord().xy;
  vec2 ndc = (pixel / resolution) * 2.0 - 1.0;

  // Flutter local coordinates grow downward; camera-space +Y grows upward.
  ndc.y = -ndc.y;

  float aspect = resolution.x / resolution.y;
  float halfHeight = tan(uFovY * 0.5);

  // Camera ray looking into an effectively infinite celestial sphere.
  vec3 ray = normalize(
    vec3(
      ndc.x * aspect * halfHeight,
      ndc.y * halfHeight,
      1.0
    )
  );

  // The Earth renderer rotates the globe to simulate changing viewpoint.
  // The celestial sphere therefore moves with the inverse yaw/pitch camera
  // attitude. Stars have no translational parallax at this scale.
  vec3 celestialRay =
      rotationY(-uYaw) *
      rotationX(uPitch) *
      ray;

  float longitude = atan(celestialRay.x, celestialRay.z);
  float latitude = asin(clamp(celestialRay.y, -1.0, 1.0));

  vec2 uv = vec2(
    fract(0.5 + longitude / TWO_PI),
    clamp(0.5 - latitude / PI, 0.0, 1.0)
  );

  // Dark, restrained presentation grade for Social Vote Space.
  // The Gaia texture remains the astronomical source; this only changes
  // display tone-mapping so the Home reads as deep space instead of grey fog.
  vec3 sourceColour = texture(uSkyTexture, uv).rgb;

  // Pull the diffuse grey floor down while preserving bright stellar regions.
  sourceColour = max(sourceColour - vec3(0.035), vec3(0.0));
  sourceColour = pow(sourceColour, vec3(1.24));

  // Slightly reduce chroma for a cleaner, premium dark-space appearance.
  float luminance = dot(
    sourceColour,
    vec3(0.2126, 0.7152, 0.0722)
  );
  sourceColour = mix(
    vec3(luminance),
    sourceColour,
    0.84
  );

  // Deep blue-black floor prevents the all-sky map from looking like a
  // flat grey photograph in low-density regions.
  vec3 deepSpace = vec3(0.0025, 0.0055, 0.0140);
  vec3 colour = deepSpace + sourceColour * uExposure;

  // Very subtle optical vignette: enough to focus the Earth without
  // creating a visible frame or "square renderer" effect.
  float radial = length(ndc);
  float vignette = smoothstep(0.38, 1.36, radial);
  colour *= mix(1.0, 0.78, vignette);

  fragColor = vec4(colour, 1.0);
}
