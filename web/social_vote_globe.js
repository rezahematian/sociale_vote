import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

const SOCIAL_VOTE_GLOBE_BUILD = 'WEB-WORLD-V10.6-ROUTE-LIFECYCLE-V1.0.2';

const DEG2RAD = Math.PI / 180;
const RAD2DEG = 180 / Math.PI;

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function normalizeLongitude(value) {
  let result = value;
  while (result > 180) result -= 360;
  while (result < -180) result += 360;
  return result;
}

function utcDayOfYear(date) {
  const start = Date.UTC(date.getUTCFullYear(), 0, 0);
  const current = Date.UTC(
    date.getUTCFullYear(),
    date.getUTCMonth(),
    date.getUTCDate(),
  );
  return Math.floor((current - start) / 86400000);
}

// Lightweight solar-position approximation for the visual day/night
// terminator. It is intentionally independent from app GeoScope state.
function subsolarPoint(date = new Date()) {
  const day = utcDayOfYear(date);
  const utcHour =
      date.getUTCHours() +
      date.getUTCMinutes() / 60 +
      date.getUTCSeconds() / 3600;

  const gamma =
      (2 * Math.PI / 365) *
      (day - 1 + (utcHour - 12) / 24);

  const equationOfTime = 229.18 * (
    0.000075 +
    0.001868 * Math.cos(gamma) -
    0.032077 * Math.sin(gamma) -
    0.014615 * Math.cos(2 * gamma) -
    0.040849 * Math.sin(2 * gamma)
  );

  const declination =
      0.006918 -
      0.399912 * Math.cos(gamma) +
      0.070257 * Math.sin(gamma) -
      0.006758 * Math.cos(2 * gamma) +
      0.000907 * Math.sin(2 * gamma) -
      0.002697 * Math.cos(3 * gamma) +
      0.00148 * Math.sin(3 * gamma);

  const utcMinutes = utcHour * 60;
  const longitude = normalizeLongitude(
    (720 - utcMinutes - equationOfTime) / 4,
  );

  return {
    latitude: declination * RAD2DEG,
    longitude,
  };
}

function latLngToVector(latitude, longitude, radius = 1) {
  const phi = (90 - latitude) * DEG2RAD;
  const theta = (longitude + 180) * DEG2RAD;

  return new THREE.Vector3(
    -(radius * Math.sin(phi) * Math.cos(theta)),
    radius * Math.cos(phi),
    radius * Math.sin(phi) * Math.sin(theta),
  );
}

function vectorToLatLng(vector) {
  const p = vector.clone().normalize();

  const latitude = Math.asin(clamp(p.y, -1, 1)) * RAD2DEG;
  const theta = Math.atan2(p.z, -p.x) * RAD2DEG;
  const longitude = normalizeLongitude(theta - 180);

  return { latitude, longitude };
}

function dispatch(element, name, detail = {}) {
  element.dispatchEvent(
    new CustomEvent(name, {
      detail,
      bubbles: false,
      composed: false,
    }),
  );
}

const NATURAL_HOME_LATITUDE = 18;

function browserSessionLooksAuthenticated() {
  try {
    for (let index = 0; index < localStorage.length; index += 1) {
      const key = localStorage.key(index);
      if (
        !key ||
        !key.startsWith('sb-') ||
        !key.endsWith('-auth-token')
      ) {
        continue;
      }

      const raw = localStorage.getItem(key);
      if (
        raw &&
        raw !== 'null' &&
        raw !== 'undefined' &&
        raw !== '[]' &&
        raw !== '{}'
      ) {
        return true;
      }
    }
  } catch (_) {
    // Storage can be unavailable in hardened/private browser modes.
  }

  return false;
}


function configAuthenticationState(config) {
  const raw = config?.isAuthenticated;

  if (typeof raw === 'boolean') {
    return raw;
  }

  if (raw === 1 || raw === '1' || raw === 'true') {
    return true;
  }

  if (raw === 0 || raw === '0' || raw === 'false') {
    return false;
  }

  // Compatibility fallback for older Flutter builds that do not yet pass
  // the explicit auth flag. The Flutter-provided value is authoritative.
  return browserSessionLooksAuthenticated();
}

function configAutoRotateState(config) {
  const raw = config?.autoRotateEnabled;

  if (typeof raw === 'boolean') {
    return raw;
  }

  if (raw === 0 || raw === '0' || raw === 'false') {
    return false;
  }

  return true;
}

function drawMarkerGlyph(ctx, kind, center) {
  ctx.save();
  ctx.strokeStyle = '#F7FAFF';
  ctx.fillStyle = '#F7FAFF';
  ctx.lineWidth = 6;
  ctx.lineCap = 'round';
  ctx.lineJoin = 'round';

  if (kind === 'vote') {
    ctx.strokeRect(center - 14, center - 10, 28, 24);
    ctx.beginPath();
    ctx.moveTo(center - 10, center - 13);
    ctx.lineTo(center - 2, center - 5);
    ctx.lineTo(center + 12, center - 20);
    ctx.stroke();
    ctx.restore();
    return;
  }

  if (kind === 'voce') {
    ctx.beginPath();
    ctx.moveTo(center - 15, center - 12);
    ctx.lineTo(center + 15, center - 12);
    ctx.quadraticCurveTo(center + 19, center - 12, center + 19, center - 8);
    ctx.lineTo(center + 19, center + 8);
    ctx.quadraticCurveTo(center + 19, center + 12, center + 15, center + 12);
    ctx.lineTo(center - 2, center + 12);
    ctx.lineTo(center - 12, center + 20);
    ctx.lineTo(center - 10, center + 12);
    ctx.lineTo(center - 15, center + 12);
    ctx.quadraticCurveTo(center - 19, center + 12, center - 19, center + 8);
    ctx.lineTo(center - 19, center - 8);
    ctx.quadraticCurveTo(center - 19, center - 12, center - 15, center - 12);
    ctx.closePath();
    ctx.stroke();
    ctx.restore();
    return;
  }

  if (kind === 'news') {
    ctx.strokeRect(center - 16, center - 18, 32, 36);
    ctx.fillRect(center - 10, center - 11, 9, 10);
    ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.moveTo(center + 4, center - 10);
    ctx.lineTo(center + 11, center - 10);
    ctx.moveTo(center + 4, center - 2);
    ctx.lineTo(center + 11, center - 2);
    ctx.moveTo(center - 10, center + 7);
    ctx.lineTo(center + 11, center + 7);
    ctx.moveTo(center - 10, center + 14);
    ctx.lineTo(center + 11, center + 14);
    ctx.stroke();
    ctx.restore();
    return;
  }

  ctx.beginPath();
  ctx.arc(center, center, 9, 0, Math.PI * 2);
  ctx.fill();
  ctx.restore();
}


function markerVisualCenter(markers, markerIndex) {
  const marker = markers[markerIndex];
  const latitude = Number(marker?.latitude);
  const longitude = Number(marker?.longitude);
  const kind = typeof marker?.kind === 'string' ? marker.kind : '';

  if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
    return { x: 0.5, y: 0.5 };
  }

  let hasDifferentTypeAtSameAnchor = false;

  for (let index = 0; index < markers.length; index += 1) {
    if (index === markerIndex) {
      continue;
    }

    const other = markers[index];
    const otherLatitude = Number(other?.latitude);
    const otherLongitude = Number(other?.longitude);
    const otherKind =
        typeof other?.kind === 'string'
          ? other.kind
          : '';

    if (
      !Number.isFinite(otherLatitude) ||
      !Number.isFinite(otherLongitude) ||
      otherKind === kind
    ) {
      continue;
    }

    const latitudeDelta = Math.abs(latitude - otherLatitude);
    const longitudeDelta =
        Math.abs(normalizeLongitude(longitude - otherLongitude));

    // This is NOT a geographic move. The immutable world position remains the
    // real content coordinate. We only detect near-identical anchors so
    // different content types do not paint over one another on screen.
    if (latitudeDelta <= 0.12 && longitudeDelta <= 0.12) {
      hasDifferentTypeAtSameAnchor = true;
      break;
    }
  }

  if (!hasDifferentTypeAtSameAnchor) {
    return { x: 0.5, y: 0.5 };
  }

  // THREE.Sprite.center offsets the billboard in its camera-facing plane while
  // sprite.position remains the exact geographic anchor. Values stay bounded
  // and are applied ONLY to cross-type collisions:
  //   Vote = left/down, Voce = right/down, News = above.
  if (kind === 'vote') {
    return { x: 0.88, y: 0.72 };
  }

  if (kind === 'voce') {
    return { x: 0.12, y: 0.72 };
  }

  if (kind === 'news') {
    return { x: 0.5, y: 0.10 };
  }

  return { x: 0.5, y: 0.5 };
}

function createMarkerTexture(color, count, kind) {
  const size = 128;
  const canvas = document.createElement('canvas');
  canvas.width = size;
  canvas.height = size;

  const ctx = canvas.getContext('2d');
  if (!ctx) {
    console.warn('[SocialVoteWebGlobe] marker canvas context unavailable');
    return null;
  }
  const center = size / 2;

  const gradient = ctx.createRadialGradient(
    center,
    center,
    6,
    center,
    center,
    54,
  );
  gradient.addColorStop(0, `${color}55`);
  gradient.addColorStop(0.55, `${color}25`);
  gradient.addColorStop(1, `${color}00`);

  ctx.fillStyle = gradient;
  ctx.beginPath();
  ctx.arc(center, center, 54, 0, Math.PI * 2);
  ctx.fill();

  ctx.lineWidth = 10;
  ctx.strokeStyle = color;
  ctx.fillStyle = '#0A1020';
  ctx.beginPath();
  ctx.arc(center, center, 28, 0, Math.PI * 2);
  ctx.fill();
  ctx.stroke();

  if (count > 1) {
    ctx.font = '700 28px system-ui, sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillStyle = '#FFFFFF';
    ctx.strokeStyle = '#050814';
    ctx.lineWidth = 8;

    const label = count > 99 ? '99+' : String(count);
    ctx.strokeText(label, center, center);
    ctx.fillText(label, center, center);
  } else {
    drawMarkerGlyph(ctx, kind, center);
  }

  const texture = new THREE.CanvasTexture(canvas);
  texture.colorSpace = THREE.SRGBColorSpace;
  texture.needsUpdate = true;
  return texture;
}

class SocialVoteGlobeElement extends HTMLElement {
  static get observedAttributes() {
    return [
      'data-config',
      'data-appearance',
      'data-focus',
      'data-route-active',
    ];
  }

  constructor() {
    super();

    this._initialized = false;
    this._disposed = false;

    this._config = {};
    this._appearance = {};
    this._renderer = null;
    this._scene = null;
    this._camera = null;
    this._controls = null;
    this._earth = null;
    this._earthTexture = null;
    this._nightTexture = null;
    this._nightLights = null;
    this._atmosphere = null;
    this._sunLight = null;
    this._sunDirection = new THREE.Vector3(1, 0, 0);
    this._lastSunUpdateAt = 0;

    this._isAuthenticated = false;
    this._routeActive = true;
    this._autoRotateEnabled = false;
    this._autoRotatePreference = false;
    this._resumeAutoRotateAfterInteraction = false;
    this._autoRotateButton = null;
    this._naturalSettleToken = 0;
    this._naturalSettling = false;
    this._authRefreshAt = 0;
    this._initialPositionApplied = false;

    this._markerSprites = [];
    this._markerResources = [];
    this._lastMarkersSignature = null;
    this._lastEarthTextureUrl = null;

    this._raycaster = new THREE.Raycaster();
    this._pointer = new THREE.Vector2();
    this._pointerDown = null;

    this._resizeObserver = null;
    this._animationFrame = null;
    this._disposeTimer = null;
    this._lastOrientationDispatch = 0;
    this._deepZoomSent = false;
    this._lastDiagnosticSignature = '';

    this._onPointerDown = this._onPointerDown.bind(this);
    this._onPointerUp = this._onPointerUp.bind(this);
    this._onPointerCancel = this._onPointerCancel.bind(this);
    this._onControlsStart = this._onControlsStart.bind(this);
    this._onControlsEnd = this._onControlsEnd.bind(this);
    this._onContextLost = this._onContextLost.bind(this);
    this._onContextRestored = this._onContextRestored.bind(this);
    this._onVisibilityChange = this._onVisibilityChange.bind(this);
  }

  connectedCallback() {
    if (this._disposeTimer != null) {
      clearTimeout(this._disposeTimer);
      this._disposeTimer = null;
    }

    this.style.display = 'block';
    this.style.width = '100%';
    this.style.height = '100%';
    this.style.minWidth = '0';
    this.style.minHeight = '0';
    this.style.overflow = 'hidden';
    this.style.borderRadius = '50%';
    this.style.clipPath = 'circle(50%)';
    this.style.background = 'transparent';
    this.style.position = 'relative';
    this.style.isolation = 'isolate';
    this.style.contain = 'layout paint';

    if (!this._initialized) {
      this._initialize();
    }
  }

  disconnectedCallback() {
    if (this._disposeTimer != null) {
      clearTimeout(this._disposeTimer);
    }

    // Flutter may temporarily detach the platform view while switching
    // responsive layouts/routes. Keep the WebGL context alive for that short
    // transition instead of destroying and recreating it immediately.
    this._disposeTimer = setTimeout(() => {
      this._disposeTimer = null;
      if (!this.isConnected) {
        this._dispose();
      }
    }, 400);
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue === newValue) {
      return;
    }

    if (name === 'data-config') {
      this._readConfig();
      if (this._initialized) {
        this._applyConfig();
      }
    }

    if (name === 'data-appearance') {
      this._readAppearance();
      if (this._initialized) {
        this._applyAppearance();
      }
    }

    if (name === 'data-focus' && this._initialized) {
      this._applyFocusAttribute();
    }

    if (name === 'data-route-active') {
      this._routeActive = newValue !== 'false';
    }
  }

  _readConfig() {
    try {
      const raw = this.getAttribute('data-config');
      this._config = raw ? JSON.parse(raw) : {};
    } catch (error) {
      console.error('[SocialVoteWebGlobe] invalid config', error);
      this._config = {};
    }
  }

  _readAppearance() {
    try {
      const raw = this.getAttribute('data-appearance');
      this._appearance = raw ? JSON.parse(raw) : {};
    } catch (error) {
      console.error('[SocialVoteWebGlobe] invalid appearance', error);
      this._appearance = {};
    }
  }

  _initialize() {
    this._readConfig();
    this._readAppearance();
    this._routeActive = this.getAttribute('data-route-active') !== 'false';
    this.removeAttribute('data-runtime-ready');

    try {
      this._disposed = false;

      this._scene = new THREE.Scene();

      this._camera = new THREE.PerspectiveCamera(
        38,
        1,
        0.1,
        100,
      );

      this._renderer = new THREE.WebGLRenderer({
        alpha: true,
        antialias: true,
        powerPreference: 'default',
      });

      this._renderer.setClearColor(0x000000, 0);
      this._renderer.setPixelRatio(
        Math.min(window.devicePixelRatio || 1, 2.0),
      );
      this._renderer.outputColorSpace = THREE.SRGBColorSpace;
      this._renderer.toneMapping = THREE.ACESFilmicToneMapping;
      this._renderer.toneMappingExposure = 1.32;

      const canvas = this._renderer.domElement;
      canvas.style.display = 'block';
      canvas.style.width = '100%';
      canvas.style.height = '100%';
      canvas.style.background = 'transparent';
      canvas.style.touchAction = 'none';
      canvas.style.outline = 'none';

      this.replaceChildren(canvas);

      this._controls = new OrbitControls(
        this._camera,
        canvas,
      );
      this._controls.enablePan = false;
      this._controls.enableDamping = true;
      this._controls.dampingFactor = 0.13;
      this._controls.rotateSpeed = 0.38;
      this._controls.zoomSpeed = 0.52;
      this._controls.autoRotate = false;
      this._controls.autoRotateSpeed = 0.32;
      this._controls.target.set(0, 0, 0);
      this._controls.addEventListener('start', this._onControlsStart);
      this._controls.addEventListener('end', this._onControlsEnd);

      this._createEarth();
      this._createLights();
      this._createAtmosphere();
      this._applyConfig();
      this._updateSun(true);
      this._initializeAutoRotateState();

      canvas.addEventListener(
        'pointerdown',
        this._onPointerDown,
        { passive: true },
      );
      canvas.addEventListener(
        'pointerup',
        this._onPointerUp,
        { passive: true },
      );
      canvas.addEventListener(
        'pointercancel',
        this._onPointerCancel,
        { passive: true },
      );
      canvas.addEventListener(
        'webglcontextlost',
        this._onContextLost,
        false,
      );
      canvas.addEventListener(
        'webglcontextrestored',
        this._onContextRestored,
        false,
      );

      document.addEventListener(
        'visibilitychange',
        this._onVisibilityChange,
      );

      this._resizeObserver = new ResizeObserver(() => {
        this._resize();
      });
      this._resizeObserver.observe(this);

      this._initialized = true;
      this.setAttribute('data-runtime-ready', 'true');
      this._resize();

      this._loadEarthTexture();
      this._startLoop();

      // Renderer readiness is independent from texture download timing.
      // Texture failures degrade to a local fallback and never invalidate an
      // already-live WebGL renderer.
      setTimeout(() => {
        if (!this._disposed && this.isConnected) {
          dispatch(this, 'socialvote-globe-ready', {
            build: SOCIAL_VOTE_GLOBE_BUILD,
            stage: 'renderer',
          });
          this._emitDiagnostics('renderer-ready');
        }
      }, 0);
    } catch (error) {
      this.removeAttribute('data-runtime-ready');
      console.error('[SocialVoteWebGlobe] init failed', error);
      dispatch(this, 'socialvote-globe-error', {
        fatal: true,
        stage: 'renderer-init',
        message: String(error),
      });
    }
  }

  _createEarth() {
    const geometry = new THREE.SphereGeometry(
      1,
      160,
      112,
    );

    const material = new THREE.MeshPhongMaterial({
      color: 0xffffff,
      emissive: 0xffffff,
      emissiveIntensity: 0.34,
      shininess: 1.0,
      specular: 0x020408,
    });

    this._earth = new THREE.Mesh(
      geometry,
      material,
    );

    this._scene.add(this._earth);
  }

  _createLights() {
    // Daylight is driven by the current subsolar point. A tiny cool ambient
    // component keeps the night hemisphere readable without washing it out.
    const ambient = new THREE.AmbientLight(
      0xc8daf5,
      0.34,
    );
    this._scene.add(ambient);

    const hemisphere = new THREE.HemisphereLight(
      0xb9d6ff,
      0x223247,
      0.36,
    );
    this._scene.add(hemisphere);

    this._sunLight = new THREE.DirectionalLight(
      0xfff1dc,
      0.98,
    );
    this._scene.add(this._sunLight);
  }

  _createAtmosphere() {
    const geometry = new THREE.SphereGeometry(
      1.016,
      128,
      88,
    );

    const material = new THREE.ShaderMaterial({
      transparent: true,
      depthWrite: false,
      blending: THREE.AdditiveBlending,
      side: THREE.BackSide,
      uniforms: {
        glowColor: {
          value: new THREE.Color(0x5e9dff),
        },
        sunDirection: {
          value: this._sunDirection.clone(),
        },
        glowStrength: {
          value: 0.16,
        },
      },
      vertexShader: `
        varying vec3 vWorldNormal;
        varying vec3 vWorldPosition;

        void main() {
          vec4 worldPosition = modelMatrix * vec4(position, 1.0);
          vWorldPosition = worldPosition.xyz;
          vWorldNormal = normalize(mat3(modelMatrix) * normal);

          gl_Position =
              projectionMatrix *
              viewMatrix *
              worldPosition;
        }
      `,
      fragmentShader: `
        uniform vec3 glowColor;
        uniform vec3 sunDirection;
        uniform float glowStrength;

        varying vec3 vWorldNormal;
        varying vec3 vWorldPosition;

        void main() {
          vec3 normal = normalize(vWorldNormal);
          vec3 viewDirection =
              normalize(cameraPosition - vWorldPosition);

          float rim = pow(
            1.0 - max(dot(normal, viewDirection), 0.0),
            7.0
          );

          float sunAmount = smoothstep(
            -0.04,
            0.62,
            dot(normal, normalize(sunDirection))
          );

          float alpha =
              rim *
              glowStrength *
              mix(0.06, 0.52, sunAmount);

          vec3 color = mix(
            glowColor * 0.46,
            glowColor * 0.98,
            sunAmount
          );

          gl_FragColor = vec4(color, alpha);
        }
      `,
    });

    this._atmosphere = new THREE.Mesh(
      geometry,
      material,
    );
    this._scene.add(this._atmosphere);
  }

  _createNightLights(texture) {
    this._nightLights?.geometry?.dispose?.();
    this._nightLights?.material?.dispose?.();

    if (this._nightLights) {
      this._scene.remove(this._nightLights);
    }

    const geometry = new THREE.SphereGeometry(
      1.002,
      160,
      112,
    );

    const material = new THREE.ShaderMaterial({
      transparent: true,
      depthWrite: false,
      depthTest: true,
      blending: THREE.AdditiveBlending,
      uniforms: {
        nightMap: { value: texture },
        sunDirection: { value: this._sunDirection.clone() },
        cityIntensity: { value: 0.70 },
      },
      vertexShader: `
        varying vec2 vUv;
        varying vec3 vWorldNormal;

        void main() {
          vUv = uv;
          vWorldNormal = normalize(mat3(modelMatrix) * normal);

          gl_Position =
              projectionMatrix *
              modelViewMatrix *
              vec4(position, 1.0);
        }
      `,
      fragmentShader: `
        uniform sampler2D nightMap;
        uniform vec3 sunDirection;
        uniform float cityIntensity;

        varying vec2 vUv;
        varying vec3 vWorldNormal;

        void main() {
          vec3 rawNight = texture2D(nightMap, vUv).rgb;
          float luminance = dot(
            rawNight,
            vec3(0.2126, 0.7152, 0.0722)
          );

          float sunDot = dot(
            normalize(vWorldNormal),
            normalize(sunDirection)
          );

          float nightAmount =
              1.0 - smoothstep(-0.20, 0.10, sunDot);

          float visibleLights = smoothstep(
            0.018,
            0.32,
            luminance
          );

          vec3 warmNight = rawNight * vec3(
            1.12,
            1.02,
            0.86
          );

          float alpha =
              nightAmount *
              mix(0.06, 0.68, visibleLights);

          vec3 color =
              warmNight *
              cityIntensity *
              mix(0.20, 1.08, visibleLights);

          gl_FragColor = vec4(color, alpha);
        }
      `,
    });

    this._nightLights = new THREE.Mesh(
      geometry,
      material,
    );

    this._scene.add(this._nightLights);
  }

  _initializeAutoRotateState() {
    this._refreshAuthenticationState(true);
  }

  _guestHomeIsReadOnly() {
    return (
      !this._isAuthenticated &&
      this._config.profile === 'home'
    );
  }

  _refreshAuthenticationState(force = false) {
    const authenticated = configAuthenticationState(this._config);
    const autoRotatePreference = configAutoRotateState(this._config);

    if (
      !force &&
      authenticated === this._isAuthenticated &&
      autoRotatePreference === this._autoRotatePreference
    ) {
      if (this._autoRotateButton) {
        this._autoRotateButton.remove();
        this._autoRotateButton = null;
      }

      this._applyInteractionPolicy();
      this._applyAutoRotatePreference();
      return;
    }

    this._isAuthenticated = authenticated;
    this._naturalSettleToken += 1;

    // Flutter owns the authenticated rotation control. Guest Home remains
    // read-only while keeping the approved passive rotation baseline.
    this._autoRotatePreference = autoRotatePreference;
    this._autoRotateButton?.remove?.();
    this._autoRotateButton = null;

    this._applyInteractionPolicy();
    this._applyAutoRotatePreference();

    if (this._autoRotatePreference && this._config.profile === 'home') {
      this._settleToNaturalRotation();
    }
  }

  _applyInteractionPolicy() {
    if (!this._controls) {
      return;
    }

    this._controls.enabled = !this._guestHomeIsReadOnly();

    const canvas = this._renderer?.domElement;
    if (canvas) {
      const guestHome = this._guestHomeIsReadOnly();
      canvas.style.cursor = guestHome ? 'default' : 'grab';
      canvas.style.touchAction = guestHome ? 'pan-y' : 'none';
    }
  }

  _applyAutoRotatePreference() {
    this._autoRotateEnabled = Boolean(this._autoRotatePreference);

    if (this._controls) {
      if (!this._autoRotateEnabled) {
        this._controls.autoRotate = false;
      } else if (!this._naturalSettling) {
        this._controls.autoRotate = true;
      }
      this._controls.autoRotateSpeed = 0.30;
    }

    this._applyInteractionPolicy();
  }

  _onControlsStart() {
    this._naturalSettleToken += 1;
    this._naturalSettling = false;

    if (this._autoRotateEnabled && this._controls) {
      // When auto-rotation is active, manual movement is temporary. Pause the
      // spin while dragging; release will gently return to the natural viewing
      // latitude before rotation resumes.
      this._resumeAutoRotateAfterInteraction = true;
      this._controls.autoRotate = false;
    }
  }

  _onControlsEnd() {
    if (
      this._resumeAutoRotateAfterInteraction &&
      this._autoRotatePreference &&
      this._controls
    ) {
      // Match the native renderer: manual movement is temporary on both
      // Home and Civic Map while auto-rotation is enabled. Restore the natural
      // viewing latitude first, preserving longitude, then resume rotation.
      this._settleToNaturalRotation();
    }

    this._resumeAutoRotateAfterInteraction = false;
  }

  _settleToNaturalRotation() {
    if (
      !this._camera ||
      !this._controls ||
      !this._autoRotatePreference
    ) {
      return;
    }

    const token = ++this._naturalSettleToken;
    const startDirection = this._camera.position.clone().normalize();
    const startDistance = this._camera.position.length();
    const current = vectorToLatLng(startDirection);
    const targetDirection = latLngToVector(
      NATURAL_HOME_LATITUDE,
      current.longitude,
      1,
    ).normalize();

    const startedAt = performance.now();
    const duration = 820;

    this._naturalSettling = true;
    this._controls.autoRotate = false;

    const step = (now) => {
      if (
        this._disposed ||
        token !== this._naturalSettleToken ||
        !this._autoRotatePreference
      ) {
        if (token === this._naturalSettleToken) {
          this._naturalSettling = false;
        }
        return;
      }

      const rawT = clamp((now - startedAt) / duration, 0, 1);
      const t = 1 - Math.pow(1 - rawT, 3);

      const direction = startDirection
        .clone()
        .lerp(targetDirection, t)
        .normalize();

      this._camera.position.copy(
        direction.multiplyScalar(startDistance),
      );
      this._camera.lookAt(0, 0, 0);
      this._controls.update();

      if (rawT < 1) {
        requestAnimationFrame(step);
        return;
      }

      if (
        token === this._naturalSettleToken &&
        this._autoRotatePreference
      ) {
        this._naturalSettling = false;
        this._controls.autoRotate = true;
        this._controls.autoRotateSpeed = 0.30;
      }
    };

    requestAnimationFrame(step);
  }

  _updateSun(force = false) {
    const now = Date.now();

    if (!force && now - this._lastSunUpdateAt < 60000) {
      return;
    }

    this._lastSunUpdateAt = now;

    const point = subsolarPoint(new Date(now));
    this._sunDirection.copy(
      latLngToVector(
        point.latitude,
        point.longitude,
        1,
      ).normalize(),
    );

    if (this._sunLight) {
      this._sunLight.position.copy(
        this._sunDirection.clone().multiplyScalar(5),
      );
    }

    const atmosphereSun =
        this._atmosphere?.material?.uniforms?.sunDirection;
    if (atmosphereSun) {
      atmosphereSun.value.copy(this._sunDirection);
    }

    const nightSun =
        this._nightLights?.material?.uniforms?.sunDirection;
    if (nightSun) {
      nightSun.value.copy(this._sunDirection);
    }
  }

  _loadEarthTexture() {
    const configuredDay = this._appearance.textureUrl;
    const dayRelativeUrl =
        configuredDay ||
        'assets/assets/globe/earth_day_nasa_blue_marble_2048.png';
    const fallbackDayRelativeUrl =
        'assets/assets/globe/earth_day_nasa_blue_marble_2048.png';

    const configuredNight = this._appearance.nightTextureUrl;
    const nightRelativeUrl =
        configuredNight ||
        'assets/assets/globe/earth_night_nasa_black_marble_2016_3600.jpg';

    const dayUrl = new URL(
      dayRelativeUrl,
      document.baseURI,
    ).href;
    const fallbackDayUrl = new URL(
      fallbackDayRelativeUrl,
      document.baseURI,
    ).href;

    const nightUrl = new URL(
      nightRelativeUrl,
      document.baseURI,
    ).href;

    const textureSignature = `${dayUrl}|${nightUrl}`;
    if (this._lastEarthTextureUrl === textureSignature && this._earthTexture) {
      this._applyAppearanceMaterial();
      return;
    }
    this._lastEarthTextureUrl = textureSignature;

    const loader = new THREE.TextureLoader();

    const applyDayTexture = (texture, stage = 'texture') => {
      if (this._disposed) {
        texture.dispose();
        return;
      }

      this._prepareColorTexture(texture);

      this._earthTexture?.dispose();
      this._earthTexture = texture;

      this._earth.material.map = texture;
      // Keep geographical detail readable on the night hemisphere while
      // preserving the real-time solar terminator and city-light overlay.
      this._earth.material.emissiveMap = texture;
      this._earth.material.emissive.setHex(0xffffff);
      this._earth.material.emissiveIntensity = 0.34;
      this._earth.material.needsUpdate = true;
      this._applyAppearanceMaterial();

      this.setAttribute('data-runtime-ready', 'true');
      dispatch(
        this,
        'socialvote-globe-ready',
        {
          build: SOCIAL_VOTE_GLOBE_BUILD,
          stage,
        },
      );

      requestAnimationFrame(() => {
        if (!this._disposed) {
          this._emitDiagnostics(stage);
        }
      });
    };

    const keepRendererAliveWithoutNewDayTexture = (error) => {
      if (this._disposed) {
        return;
      }

      // A failed image must never destroy a renderer that is already alive.
      // Preserve the previous valid texture when available; otherwise the
      // neutral material still leaves the sphere/markers interactive.
      this._lastEarthTextureUrl = this._earthTexture
        ? textureSignature
        : null;
      this.setAttribute('data-runtime-ready', 'true');
      this._applyAppearanceMaterial();

      console.warn(
        '[SocialVoteWebGlobe] day texture unavailable; renderer kept alive',
        error,
      );
      dispatch(this, 'socialvote-globe-warning', {
        fatal: false,
        stage: 'day-texture',
        message: 'Earth day texture unavailable',
      });
      dispatch(this, 'socialvote-globe-ready', {
        build: SOCIAL_VOTE_GLOBE_BUILD,
        stage: 'renderer-without-new-texture',
      });
    };

    const loadFallbackDayTexture = (primaryError) => {
      if (dayUrl === fallbackDayUrl) {
        keepRendererAliveWithoutNewDayTexture(primaryError);
        return;
      }

      console.warn(
        '[SocialVoteWebGlobe] primary day texture failed; trying local fallback',
        primaryError,
      );

      loader.load(
        fallbackDayUrl,
        (texture) => applyDayTexture(texture, 'fallback-texture'),
        undefined,
        keepRendererAliveWithoutNewDayTexture,
      );
    };

    loader.load(
      dayUrl,
      (texture) => applyDayTexture(texture, 'texture'),
      undefined,
      loadFallbackDayTexture,
    );

    // Night lights are progressive enhancement. If this secondary texture
    // fails, the globe remains usable instead of triggering the 2D fallback.
    loader.load(
      nightUrl,
      (texture) => {
        if (this._disposed) {
          texture.dispose();
          return;
        }

        this._prepareColorTexture(texture);

        this._nightTexture?.dispose();
        this._nightTexture = texture;
        this._createNightLights(texture);
        this._applyAppearanceMaterial();
        this._updateSun(true);
      },
      undefined,
      (error) => {
        console.warn(
          '[SocialVoteWebGlobe] night texture unavailable; continuing day-only',
          error,
        );
      },
    );
  }

  _prepareColorTexture(texture) {
    texture.colorSpace = THREE.SRGBColorSpace;

    const maxAnisotropy =
        this._renderer.capabilities.getMaxAnisotropy();
    texture.anisotropy = Math.min(
      16,
      maxAnisotropy,
    );
    texture.minFilter = THREE.LinearMipmapLinearFilter;
    texture.magFilter = THREE.LinearFilter;
    texture.generateMipmaps = true;
    texture.needsUpdate = true;
  }

  _applyAppearance() {
    if (!this._earth) {
      return;
    }

    this._loadEarthTexture();
    this._applyAppearanceMaterial();
  }

  _applyAppearanceMaterial() {
    if (!this._earth?.material) {
      return;
    }

    const style = typeof this._appearance.visualStyle === 'string'
      ? this._appearance.visualStyle
      : 'bright';

    const material = this._earth.material;
    const atmosphereUniforms = this._atmosphere?.material?.uniforms;

    let color = 0xffffff;
    let emissive = 0xffffff;
    let emissiveIntensity = 0.34;
    let shininess = 1.0;
    let specular = 0x020408;
    let atmosphereColor = 0x5e9dff;
    let atmosphereStrength = 0.16;
    let showNightLights = true;

    if (style === 'realistic') {
      emissiveIntensity = 0.24;
      shininess = 1.8;
      atmosphereColor = 0x6faeff;
      atmosphereStrength = 0.13;
    } else if (style === 'bright') {
      color = 0xffffff;
      emissiveIntensity = 0.48;
      shininess = 0.6;
      atmosphereColor = 0x55c8ff;
      atmosphereStrength = 0.24;
    } else if (style === 'nightLights') {
      color = 0xd6e2ff;
      emissive = 0xffffff;
      emissiveIntensity = 0.72;
      shininess = 0.0;
      specular = 0x000000;
      atmosphereColor = 0x4d7ec8;
      atmosphereStrength = 0.12;
      showNightLights = false;
    } else if (style === 'techNeon') {
      // Keep the tech identity without turning the whole Earth into a dark
      // purple silhouette. Geography remains readable and distinct from the
      // dedicated Night Lights preset.
      color = 0xd9deff;
      emissive = 0x6258b8;
      emissiveIntensity = 0.50;
      shininess = 1.35;
      specular = 0x806dff;
      atmosphereColor = 0x9b7cff;
      atmosphereStrength = 0.22;
    } else if (style === 'minimalDay') {
      color = 0xf2f5e8;
      emissive = 0xffffff;
      emissiveIntensity = 0.56;
      shininess = 0.0;
      specular = 0x000000;
      atmosphereColor = 0x8fd0e5;
      atmosphereStrength = 0.04;
      showNightLights = false;
    }

    material.color.setHex(color);
    material.emissive.setHex(emissive);
    material.emissiveIntensity = emissiveIntensity;
    material.shininess = shininess;
    material.specular.setHex(specular);
    material.needsUpdate = true;

    if (atmosphereUniforms?.glowColor) {
      atmosphereUniforms.glowColor.value.setHex(atmosphereColor);
    }
    if (atmosphereUniforms?.glowStrength) {
      atmosphereUniforms.glowStrength.value = atmosphereStrength;
    }
    if (this._atmosphere) {
      this._atmosphere.visible = atmosphereStrength > 0.001;
    }
    if (this._nightLights) {
      this._nightLights.visible = showNightLights;
    }
  }

  _applyConfig() {
    if (!this._controls || !this._camera) {
      return;
    }

    const profile =
        this._config.profile === 'home'
          ? 'home'
          : 'explore';

    const maxTiltDegrees =
        Number.isFinite(
          Number(this._config.maxTiltDegrees),
        )
          ? Number(this._config.maxTiltDegrees)
          : profile === 'home'
            ? 22
            : 55;

    this._controls.minPolarAngle =
        (90 - maxTiltDegrees) * DEG2RAD;
    this._controls.maxPolarAngle =
        (90 + maxTiltDegrees) * DEG2RAD;

    if (profile === 'home') {
      // Home is a visual/navigation hero, not an exploration viewport.
      // Keep one stable globe size so it can never expose the square canvas.
      this._controls.enableZoom = false;
      this._controls.minDistance = 3.50;
      this._controls.maxDistance = 3.50;
      this._controls.dampingFactor = 0.12;
    } else {
      this._controls.enableZoom = true;
      this._controls.minDistance = 2.96;
      this._controls.maxDistance = 4.10;
      this._controls.dampingFactor = 0.11;
    }

    if (Array.isArray(this._config.markers)) {
      const markerSignature = JSON.stringify(this._config.markers);
      const expectedMarkerCount = this._config.markers.length;
      if (
        markerSignature !== this._lastMarkersSignature ||
        (expectedMarkerCount > 0 && this._markerSprites.length === 0)
      ) {
        this._lastMarkersSignature = markerSignature;
        this._rebuildMarkers(this._config.markers);
      }
    }

    const rawInitialLat =
        this._config.initialFocusLatitude;
    const rawInitialLng =
        this._config.initialFocusLongitude;
    const rawInitialZoom =
        this._config.initialFocusZoom;

    const hasInitialLat =
        rawInitialLat !== null &&
        rawInitialLat !== undefined &&
        rawInitialLat !== '' &&
        Number.isFinite(Number(rawInitialLat));

    const hasInitialLng =
        rawInitialLng !== null &&
        rawInitialLng !== undefined &&
        rawInitialLng !== '' &&
        Number.isFinite(Number(rawInitialLng));

    if (hasInitialLat && hasInitialLng && !this._initialPositionApplied) {
      this._initialPositionApplied = true;
      const initialLat = Number(rawInitialLat);
      const initialLng = Number(rawInitialLng);

      const hasInitialZoom =
          rawInitialZoom !== null &&
          rawInitialZoom !== undefined &&
          rawInitialZoom !== '' &&
          Number.isFinite(Number(rawInitialZoom));

      const zoom = hasInitialZoom
          ? Number(rawInitialZoom)
          : null;

      const distance = zoom !== null
        ? clamp(
            3.20 - zoom * 0.68,
            1.90,
            3.45,
          )
        : 3.20;

      this._setCameraForLatLng(
        initialLat,
        initialLng,
        distance,
        false,
      );
    } else if (!this._initialPositionApplied) {
      this._initialPositionApplied = true;
      this._setCameraForLatLng(
        profile === 'home' ? NATURAL_HOME_LATITUDE : 18,
        15,
        profile === 'home' ? 3.50 : 3.38,
        false,
      );
    }

    this._controls.update();

    if (this._initialized) {
      this._refreshAuthenticationState();
    } else {
      this._applyInteractionPolicy();
    }

    // Authentication changes gesture ownership, never the approved rotation.
    // Guest Home is read-only; Guest Civic Map remains interactive.
  }

  _rebuildMarkers(markers) {
    for (const sprite of this._markerSprites) {
      this._scene.remove(sprite);
    }

    for (const resource of this._markerResources) {
      resource.material?.dispose?.();
      resource.texture?.dispose?.();
    }

    this._markerSprites = [];
    this._markerResources = [];

    for (let markerIndex = 0; markerIndex < markers.length; markerIndex += 1) {
      const marker = markers[markerIndex];
      const latitude = Number(marker.latitude);
      const longitude = Number(marker.longitude);

      if (
        !Number.isFinite(latitude) ||
        !Number.isFinite(longitude)
      ) {
        continue;
      }

      const color =
          typeof marker.color === 'string'
            ? marker.color
            : '#6CCBFF';

      const count = Math.max(
        1,
        Math.round(Number(marker.count) || 1),
      );

      const kind =
          typeof marker.kind === 'string'
            ? marker.kind
            : '';

      const sizeFactor = clamp(
        Number(marker.size) || 1,
        0.75,
        1.45,
      );

      let texture = null;

      try {
        texture = createMarkerTexture(
          color,
          count,
          kind,
        );
      } catch (error) {
        console.error(
          '[SocialVoteWebGlobe] marker texture failed',
          {
            markerId: String(marker.id || ''),
            kind,
            error,
          },
        );
        continue;
      }

      // Marker drawing is a progressive layer: one malformed/unsupported
      // glyph/canvas must never take the whole Globe renderer down.
      if (!texture) {
        continue;
      }

      const material = new THREE.SpriteMaterial({
        map: texture,
        transparent: true,
        // The front/back hemisphere test below is authoritative. Disabling
        // depth testing prevents a camera-facing billboard from intersecting
        // the sphere and appearing to sink into the Earth or disappear.
        depthTest: false,
        depthWrite: false,
        sizeAttenuation: true,
      });

      const sprite = new THREE.Sprite(material);
      sprite.renderOrder = 50;
      sprite.frustumCulled = false;
      // Geographic position remains immutable. When Vote/Voce/News share the
      // same real anchor, fan only their billboards in camera/screen space so
      // no type visually absorbs another.
      const visualCenter = markerVisualCenter(markers, markerIndex);
      sprite.center.set(visualCenter.x, visualCenter.y);

      sprite.position.copy(
        latLngToVector(
          latitude,
          longitude,
          1.036,
        ),
      );

      const scale = 0.118 * sizeFactor;
      sprite.scale.set(scale, scale, 1);

      sprite.userData.markerId =
          String(marker.id || '');
      sprite.userData.latitude = latitude;
      sprite.userData.longitude = longitude;

      this._scene.add(sprite);
      this._markerSprites.push(sprite);
      this._markerResources.push({
        material,
        texture,
      });
    }

    this._updateMarkerVisibility();
    if (this._initialized) {
      this._emitDiagnostics('markers-rebuilt');
    }
  }

  _applyFocusAttribute() {
    let focus;

    try {
      const raw = this.getAttribute('data-focus');
      focus = raw ? JSON.parse(raw) : null;
    } catch (_) {
      focus = null;
    }

    if (!focus) {
      return;
    }

    const latitude = Number(focus.latitude);
    const longitude = Number(focus.longitude);
    const distance = clamp(
      Number(focus.distance) || 2.28,
      1.65,
      3.10,
    );

    if (
      !Number.isFinite(latitude) ||
      !Number.isFinite(longitude)
    ) {
      return;
    }

    this._setCameraForLatLng(
      latitude,
      longitude,
      distance,
      true,
    );
  }

  _setCameraForLatLng(
    latitude,
    longitude,
    distance,
    animate,
  ) {
    const desiredDirection = latLngToVector(
      latitude,
      longitude,
      1,
    ).normalize();

    if (!animate) {
      this._camera.position.copy(
        desiredDirection.multiplyScalar(distance),
      );
      this._camera.lookAt(0, 0, 0);
      this._controls.update();
      return;
    }

    const startDirection =
        this._camera.position
          .clone()
          .normalize();
    const startDistance =
        this._camera.position.length();

    const startedAt = performance.now();
    const duration = 480;

    const step = (now) => {
      if (this._disposed) {
        return;
      }

      const rawT = clamp(
        (now - startedAt) / duration,
        0,
        1,
      );
      const t =
          rawT < 0.5
            ? 4 * rawT * rawT * rawT
            : 1 - Math.pow(-2 * rawT + 2, 3) / 2;

      const direction =
          startDirection
            .clone()
            .lerp(desiredDirection, t)
            .normalize();

      const currentDistance =
          THREE.MathUtils.lerp(
            startDistance,
            distance,
            t,
          );

      this._camera.position.copy(
        direction.multiplyScalar(
          currentDistance,
        ),
      );

      this._camera.lookAt(0, 0, 0);
      this._controls.update();

      if (rawT < 1) {
        requestAnimationFrame(step);
      }
    };

    requestAnimationFrame(step);
  }

  _emitDiagnostics(reason) {
    if (!this._renderer || !this._camera) {
      return;
    }

    const hostRect = this.getBoundingClientRect();
    const canvas = this._renderer.domElement;
    const canvasRect = canvas.getBoundingClientRect();

    const detail = {
      build: SOCIAL_VOTE_GLOBE_BUILD,
      reason,
      hostWidth: Number(hostRect.width.toFixed(2)),
      hostHeight: Number(hostRect.height.toFixed(2)),
      canvasCssWidth: Number(canvasRect.width.toFixed(2)),
      canvasCssHeight: Number(canvasRect.height.toFixed(2)),
      canvasBufferWidth: canvas.width,
      canvasBufferHeight: canvas.height,
      cameraAspect: Number(this._camera.aspect.toFixed(4)),
      cameraFov: Number(this._camera.fov.toFixed(2)),
      cameraDistance: Number(this._camera.position.length().toFixed(4)),
      pixelRatio: Number(this._renderer.getPixelRatio().toFixed(2)),
      configuredMarkerCount: Array.isArray(this._config.markers)
        ? this._config.markers.length
        : 0,
      configuredMarkerKinds: Array.isArray(this._config.markers)
        ? this._config.markers.reduce((counts, marker) => {
            const kind = typeof marker?.kind === 'string' ? marker.kind : 'unknown';
            counts[kind] = (counts[kind] || 0) + 1;
            return counts;
          }, {})
        : {},
      renderedMarkerCount: this._markerSprites.length,
      visibleMarkerCount: this._markerSprites.filter((sprite) => sprite.visible).length,
      hostOverflow: getComputedStyle(this).overflow,
      canvasOverflow:
          getComputedStyle(canvas).overflow || 'visible',
    };

    const signature = JSON.stringify(detail);
    if (signature === this._lastDiagnosticSignature) {
      return;
    }

    this._lastDiagnosticSignature = signature;

    console.info(
      '[SV-WEB-G3D]',
      detail,
    );

    dispatch(
      this,
      'socialvote-globe-diagnostics',
      detail,
    );
  }

  _resize() {
    if (
      !this._renderer ||
      !this._camera
    ) {
      return;
    }

    const rect = this.getBoundingClientRect();

    // Platform views can be attached while an AnimatedSwitcher/route is still
    // measuring them. Do not lock the renderer to a synthetic 1x1 viewport;
    // ResizeObserver will call us again as soon as real dimensions exist.
    if (rect.width < 2 || rect.height < 2) {
      return;
    }

    const width = Math.floor(rect.width);
    const height = Math.floor(rect.height);

    this._renderer.setSize(
      width,
      height,
      false,
    );

    this._camera.aspect = width / height;
    this._camera.updateProjectionMatrix();

    requestAnimationFrame(() => {
      if (!this._disposed) {
        this._emitDiagnostics('resize');
      }
    });
  }

  _updateMarkerVisibility() {
    if (!this._camera || this._markerSprites.length === 0) {
      return;
    }

    const cameraDirection = this._camera.position.clone().normalize();

    for (const sprite of this._markerSprites) {
      const markerDirection = sprite.position.clone().normalize();
      const facing = markerDirection.dot(cameraDirection);

      // Do not render markers through the Earth or exactly on the limb. This
      // prevents the lower half of a billboard from being depth-clipped by
      // the sphere and looking as if it falls into a hole.
      const visible = facing > 0.055;
      sprite.visible = visible;

      if (visible) {
        sprite.material.opacity = clamp((facing - 0.055) / 0.12, 0.18, 1.0);
      }
    }
  }

  _startLoop() {
    const renderFrame = () => {
      if (this._disposed) {
        return;
      }

      this._animationFrame =
          requestAnimationFrame(
            renderFrame,
          );

      if (document.hidden || !this.isConnected || !this._routeActive) {
        return;
      }

      this._updateSun();

      const authNow = performance.now();
      if (authNow - this._authRefreshAt >= 1000) {
        this._authRefreshAt = authNow;
        this._refreshAuthenticationState();
      }

      this._controls.update();
      this._updateMarkerVisibility();
      this._renderer.render(
        this._scene,
        this._camera,
      );

      this._dispatchOrientation();
      this._checkDeepZoom();
    };

    renderFrame();
  }

  _dispatchOrientation() {
    const now = performance.now();

    if (
      now - this._lastOrientationDispatch <
      50
    ) {
      return;
    }

    this._lastOrientationDispatch = now;

    const position =
        this._camera.position
          .clone()
          .normalize();

    const yaw = Math.atan2(
      position.x,
      position.z,
    );

    const pitch = Math.asin(
      clamp(position.y, -1, 1),
    );

    dispatch(
      this,
      'socialvote-globe-orientation',
      { yaw, pitch },
    );
  }

  _checkDeepZoom() {
    if (
      this._config.profile === 'home'
    ) {
      return;
    }

    const distance =
        this._camera.position.length();

    if (distance > 3.08) {
      this._deepZoomSent = false;
      return;
    }

    if (
      distance > 2.98 ||
      this._deepZoomSent
    ) {
      return;
    }

    this._deepZoomSent = true;

    const center = this._visibleCenterCoordinates();

    if (!center) {
      this._deepZoomSent = false;
      return;
    }

    dispatch(
      this,
      'socialvote-globe-deep-zoom',
      center,
    );
  }

  _visibleCenterCoordinates() {
    this._pointer.set(0, 0);
    this._raycaster.setFromCamera(
      this._pointer,
      this._camera,
    );

    const hits = this._raycaster.intersectObject(
      this._earth,
      false,
    );

    if (hits.length === 0) {
      return null;
    }

    return vectorToLatLng(hits[0].point);
  }

  _onPointerDown(event) {
    if (this._guestHomeIsReadOnly()) {
      // Guest Home remains non-draggable because OrbitControls is disabled,
      // but a short tap must still reach Flutter and open Civic Map.
      this._pointerDown = {
        x: event.clientX,
        y: event.clientY,
        time: performance.now(),
      };
      return;
    }

    if (this._controls) {
      const isTouch = event.pointerType === 'touch';
      this._controls.rotateSpeed = isTouch ? 0.27 : 0.38;
      this._controls.zoomSpeed = isTouch ? 0.42 : 0.52;
    }

    this._pointerDown = {
      x: event.clientX,
      y: event.clientY,
      time: performance.now(),
    };
  }

  _onPointerUp(event) {
    const down = this._pointerDown;
    this._pointerDown = null;

    if (!this._guestHomeIsReadOnly() && this._controls) {
      this._controls.rotateSpeed = 0.38;
      this._controls.zoomSpeed = 0.52;
    }

    if (!down) {
      return;
    }

    const movement = Math.hypot(
      event.clientX - down.x,
      event.clientY - down.y,
    );

    const elapsed =
        performance.now() - down.time;

    if (
      movement > 6 ||
      elapsed > 550
    ) {
      return;
    }

    this._handleTap(event);
  }

  _onPointerCancel() {
    if (this._guestHomeIsReadOnly()) {
      this._pointerDown = null;
      return;
    }

    this._pointerDown = null;

    if (this._controls) {
      this._controls.rotateSpeed = 0.38;
      this._controls.zoomSpeed = 0.52;
    }
  }

  _handleTap(event) {
    const rect =
        this._renderer.domElement
          .getBoundingClientRect();

    this._pointer.x =
        ((event.clientX - rect.left) /
          rect.width) *
          2 -
        1;

    this._pointer.y =
        -(
          (event.clientY - rect.top) /
          rect.height
        ) *
          2 +
        1;

    this._raycaster.setFromCamera(
      this._pointer,
      this._camera,
    );

    const earthHits =
        this._raycaster.intersectObject(
          this._earth,
          false,
        );

    const markerHits =
        this._raycaster.intersectObjects(
          this._markerSprites,
          false,
        );

    const earthDistance =
        earthHits.length > 0
          ? earthHits[0].distance
          : Number.POSITIVE_INFINITY;

    if (
      markerHits.length > 0 &&
      markerHits[0].distance <=
        earthDistance + 0.10
    ) {
      const marker =
          markerHits[0].object;

      const markerId =
          marker.userData.markerId;

      if (markerId) {
        dispatch(
          this,
          'socialvote-marker-tap',
          {
            markerId,
          },
        );
        return;
      }
    }

    if (earthHits.length === 0) {
      return;
    }

    const coordinates =
        vectorToLatLng(
          earthHits[0].point,
        );

    dispatch(
      this,
      'socialvote-surface-tap',
      coordinates,
    );
  }

  _onContextLost(event) {
    event.preventDefault();
    console.warn('[SocialVoteWebGlobe] WebGL context temporarily lost');
  }

  _onContextRestored() {
    console.info('[SocialVoteWebGlobe] WebGL context restored');

    if (this._disposed) {
      return;
    }

    this._resize();
    this._updateSun(true);

    requestAnimationFrame(() => {
      if (
        !this._disposed &&
        this.isConnected &&
        this._routeActive &&
        !document.hidden &&
        this._renderer &&
        this._scene &&
        this._camera
      ) {
        this._renderer.render(this._scene, this._camera);
        this._emitDiagnostics('context-restored');
      }
    });
  }

  _onVisibilityChange() {
    if (
      !document.hidden &&
      this.isConnected &&
      this._routeActive &&
      this._renderer &&
      this._camera
    ) {
      this._renderer.render(
        this._scene,
        this._camera,
      );
    }
  }

  _dispose() {
    if (this._disposed) {
      return;
    }

    this._disposed = true;
    this.removeAttribute('data-runtime-ready');

    if (this._disposeTimer != null) {
      clearTimeout(this._disposeTimer);
      this._disposeTimer = null;
    }

    if (this._animationFrame != null) {
      cancelAnimationFrame(
        this._animationFrame,
      );
      this._animationFrame = null;
    }

    this._resizeObserver?.disconnect();
    this._resizeObserver = null;

    document.removeEventListener(
      'visibilitychange',
      this._onVisibilityChange,
    );

    const canvas =
        this._renderer?.domElement;

    canvas?.removeEventListener(
      'pointerdown',
      this._onPointerDown,
    );
    canvas?.removeEventListener(
      'pointerup',
      this._onPointerUp,
    );
    canvas?.removeEventListener(
      'pointercancel',
      this._onPointerCancel,
    );
    canvas?.removeEventListener(
      'webglcontextlost',
      this._onContextLost,
    );
    canvas?.removeEventListener(
      'webglcontextrestored',
      this._onContextRestored,
    );

    this._controls?.removeEventListener(
      'start',
      this._onControlsStart,
    );
    this._controls?.removeEventListener(
      'end',
      this._onControlsEnd,
    );
    this._controls?.dispose();

    for (const sprite of this._markerSprites) {
      this._scene?.remove(sprite);
    }

    for (const resource of this._markerResources) {
      resource.material?.dispose?.();
      resource.texture?.dispose?.();
    }

    this._markerSprites = [];
    this._markerResources = [];
    this._lastMarkersSignature = null;
    this._lastEarthTextureUrl = null;

    this._earth?.geometry?.dispose?.();
    this._earth?.material?.dispose?.();

    this._nightLights?.geometry?.dispose?.();
    this._nightLights?.material?.dispose?.();

    this._atmosphere?.geometry?.dispose?.();
    this._atmosphere?.material?.dispose?.();

    this._earthTexture?.dispose?.();
    this._nightTexture?.dispose?.();

    this._autoRotateButton?.remove?.();
    this._autoRotateButton = null;

    this._renderer?.dispose();

    this.replaceChildren();

    this._initialized = false;
  }
}

if (
  !customElements.get(
    'social-vote-globe',
  )
) {
  customElements.define(
    'social-vote-globe',
    SocialVoteGlobeElement,
  );
}
