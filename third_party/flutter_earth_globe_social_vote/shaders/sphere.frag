#version 460 core

#include <flutter/runtime_effect.glsl>

// Output color
out vec4 fragColor;

// Uniforms - sphere parameters (float uniforms must come before samplers)
uniform float uResolutionX;    // Canvas width
uniform float uResolutionY;    // Canvas height
uniform float uCenterX;        // Sphere center X on screen
uniform float uCenterY;        // Sphere center Y on screen
uniform float uRadius;         // Sphere radius in pixels
uniform float uRotationX;      // X rotation in radians
uniform float uRotationZ;      // Z rotation in radians

// Uniforms - day/night cycle
uniform float uSunLongitude;   // Sun longitude in radians
uniform float uSunLatitude;    // Sun latitude in radians
uniform float uBlendFactor;    // Day/night transition sharpness
uniform float uDayNightEnabled; // 1.0 if day/night cycle enabled, 0.0 otherwise
uniform float uDayNightMode;   // 0.0 = textureSwap, 1.0 = simulated
uniform float uNightColorR;    // Simulated night tint color - Red component (0-1)
uniform float uNightColorG;    // Simulated night tint color - Green component (0-1)
uniform float uNightColorB;    // Simulated night tint color - Blue component (0-1)
uniform float uNightIntensity; // Simulated night brightness (0 = dark, 1 = bright)

// Uniforms - 3D surface lighting
uniform float uLightEnabled;   // 1.0 if 3D lighting enabled, 0.0 otherwise
uniform float uLightAngle;     // Light source angle in radians (0 = from right)
uniform float uLightIntensity; // Light intensity (0.0 - 1.0)
uniform float uAmbientLight;   // Ambient light level (0.0 - 1.0), prevents total darkness

// Uniforms - independent cloud layer
uniform float uCloudEnabled;        // 1.0 when cloud layer is enabled
uniform float uCloudDensity;        // 0.0 - 1.0 coverage control
uniform float uCloudRotationOffset; // longitude offset in radians

// Samplers for textures (must come after float uniforms)
uniform sampler2D uDaySurface;
uniform sampler2D uNightSurface;
uniform sampler2D uCloudSurface;

// Constants
const float PI = 3.14159265359;
const float TWO_PI = 6.28318530718;
const float HALF_PI = 1.57079632679;

// Rotation matrix around X axis
mat3 rotationMatrixX(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        1.0, 0.0, 0.0,
        0.0, c, -s,
        0.0, s, c
    );
}

// Rotation matrix around Z axis
mat3 rotationMatrixZ(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        c, -s, 0.0,
        s, c, 0.0,
        0.0, 0.0, 1.0
    );
}

// Calculate day/night blend factor
float calculateDayNightFactor(float lat, float lon) {
    // Calculate the angle between the point and the sun
    float cosAngle = sin(lat) * sin(uSunLatitude) + 
                     cos(lat) * cos(uSunLatitude) * cos(lon - uSunLongitude);
    
    // Map to 0-1 with smooth transition based on blend factor
    return clamp(cosAngle / uBlendFactor + 0.5, 0.0, 1.0);
}

void main() {
    // Get fragment position relative to center
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 center = vec2(uCenterX, uCenterY);
    vec2 pos = fragCoord - center;
    
    // Calculate distance from center
    float dist = length(pos);
    float radiusSquared = uRadius * uRadius;
    
    // Anti-aliasing with fixed edge width for smooth edges
    // Use 1.5 pixels of smoothing at the edge
    float edgeWidth = 1.5;
    
    // Smooth transition at the edge
    float edgeAlpha = 1.0 - smoothstep(uRadius - edgeWidth, uRadius + edgeWidth * 0.5, dist);
    
    // If completely outside the AA band, output transparent
    if (edgeAlpha <= 0.001) {
        fragColor = vec4(0.0);
        return;
    }
    
    // For pixels at the edge, we need to calculate z carefully
    // Clamp distance to just inside the sphere for stable z calculation
    float effectiveDist = min(dist, uRadius - 0.5);
    float distSquared = effectiveDist * effectiveDist;
    
    // Calculate z coordinate on sphere surface
    float z = sqrt(radiusSquared - distSquared);
    
    // For edge pixels, scale pos to stay on sphere surface
    // This ensures proper texture sampling at the edge
    vec2 effectivePos = pos;
    if (dist > effectiveDist) {
        effectivePos = pos * (effectiveDist / dist);
    }
    
    // Create 3D point on sphere
    vec3 spherePoint = vec3(effectivePos.x, effectivePos.y, z);
    
    // Apply combined rotation (Z then X, matching the Dart code)
    mat3 rotX = rotationMatrixX(HALF_PI - uRotationX);
    mat3 rotZ = rotationMatrixZ(uRotationZ + HALF_PI);
    mat3 combinedRot = rotZ * rotX;
    
    vec3 rotatedPoint = combinedRot * spherePoint;
    
    // Convert to spherical coordinates (lat/lon)
    float invRadius = 1.0 / uRadius;
    float lat = asin(rotatedPoint.z * invRadius);
    float lon = atan(rotatedPoint.y, rotatedPoint.x);
    
    // Convert to UV coordinates for texture sampling
    // lon is in [-PI, PI], map to [0, 1]
    // lat is in [-PI/2, PI/2], map to [0, 1]
    // Note: We invert the U coordinate (1.0 - ...) to fix horizontal mirroring
    // This ensures the texture maps correctly (west on left, east on right)
    vec2 uv;
    uv.x = 1.0 - (lon + PI) / TWO_PI;
    uv.y = (HALF_PI - lat) / PI;
    
    // Sample day texture
    vec4 dayColor = texture(uDaySurface, uv);
    
    // Apply day/night cycle if enabled
    if (uDayNightEnabled > 0.5) {
        float dayFactor = calculateDayNightFactor(lat, lon);
        
        if (uDayNightMode > 0.5) {
            // Simulated mode: darken the day texture for night
            // Use customizable night tint color and intensity
            vec3 nightTint = vec3(uNightColorR, uNightColorG, uNightColorB);
            float nightBrightness = uNightIntensity;
            vec3 simulatedNight = dayColor.rgb * nightBrightness + nightTint * (1.0 - nightBrightness) * 0.5;
            fragColor = vec4(mix(simulatedNight, dayColor.rgb, dayFactor), dayColor.a);
        } else {
            // Texture swap mode: blend between day and night textures
            vec4 nightColor = texture(uNightSurface, uv);
            fragColor = mix(nightColor, dayColor, dayFactor);
        }
    } else {
        fragColor = dayColor;
    }
    
    // Independent Natural cloud layer. Coverage is calculated before surface
    // lighting but composited afterwards, so 25/50/100% means the same visible
    // amount on every Globe preset instead of disappearing on darker styles.
    float cloudAlpha = 0.0;
    if (uCloudEnabled > 0.5 && uCloudDensity > 0.001) {
        vec2 cloudUv = uv;
        // Texture sampling runs opposite to the visible surface motion.
        // Subtract offset so Admin West (-1) moves clouds west visually.
        cloudUv.x = fract(uv.x - (uCloudRotationOffset / TWO_PI) + 1.0);
        vec3 cloudSample = texture(uCloudSurface, cloudUv).rgb;
        float coverage = clamp(uCloudDensity, 0.0, 1.0);
        // Match the existing Web Three.js cloud alphaMap pipeline:
        // alphaMap uses the GREEN texture channel, multiplies material opacity,
        // and applies alphaTest to the resulting alpha (not to raw luminance).
        float threshold = mix(0.82, 0.12, clamp(uCloudDensity, 0.0, 1.0));
        float cloudOpacity = mix(0.42, 0.82, clamp(uCloudDensity, 0.0, 1.0));
        float cloudRawAlpha = cloudSample.g * cloudOpacity;
        // Retain V5's edge-softness profile, but use only a narrow feather at
        // alphaTest's boundary to avoid hard aliasing on Android GLES/Vulkan.
        float softness = mix(0.075, 0.115, coverage);
        // Wider transition recovers wispy cloud details clipped by the narrow
        // V5 R3 alphaTest approximation, while keeping the Web green-channel
        // alpha pipeline, opacity and coverage thresholds identical.
        float feather = softness * 0.30;
        float cloudVisibility = smoothstep(
            threshold - feather,
            threshold + feather,
            cloudRawAlpha
        );
        cloudAlpha = cloudRawAlpha * cloudVisibility;
    }

    // Apply 3D surface lighting if enabled
    // This creates the appearance of a light source illuminating the sphere
    if (uLightEnabled > 0.5) {
        // Calculate surface normal (normalized position on sphere, pointing outward toward viewer)
        vec3 normal = normalize(spherePoint);
        
        // Light direction coming FROM the light (pointing toward sphere center)
        // Light angle is in screen space: 0 = from right, PI/2 = from top, PI = from left, etc.
        vec3 lightDir = normalize(vec3(cos(uLightAngle), sin(uLightAngle), 0.5));
        
        // Calculate diffuse lighting (how much the surface faces the light)
        float diffuse = max(dot(normal, lightDir), 0.0);
        
        // Apply intensity and ambient
        float lighting = uAmbientLight + diffuse * uLightIntensity * (1.0 - uAmbientLight);
        
        // Apply lighting to the Earth surface only. Clouds are composited
        // afterwards so their coverage is not accidentally reduced by the
        // selected Globe's directional-light preset.
        fragColor.rgb *= lighting;
    }

    if (cloudAlpha > 0.0) {
        float surfaceLuma = dot(fragColor.rgb, vec3(0.2126, 0.7152, 0.0722));
        float cloudBrightness = mix(
            0.82,
            1.0,
            clamp(surfaceLuma * 1.8, 0.0, 1.0)
        );
        vec3 naturalCloudColor = vec3(0.97, 0.98, 1.0) * cloudBrightness;
        fragColor.rgb = mix(fragColor.rgb, naturalCloudColor, cloudAlpha);
    }
    
    // Apply anti-aliasing edge smoothing with premultiplied alpha
    // This ensures proper blending with the background
    fragColor.rgb *= edgeAlpha;
    fragColor.a *= edgeAlpha;
}
