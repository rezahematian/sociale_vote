'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const test = require('node:test');
const source = fs.readFileSync('web/social_vote_globe.js', 'utf8');
const start = source.indexOf('  _applyAppearanceMaterial() {');
const end = source.indexOf('\n  _applyConfig() {', start);
assert.ok(start >= 0 && end > start, 'Actual material method must exist');
const method = source.slice(start, end).trim();
const body = method.slice(method.indexOf('{') + 1, method.lastIndexOf('}'));
const apply = new Function('clamp', `return function () {${body}\n};`)(
  (value, min, max) => Math.max(min, Math.min(max, value)),
);
function surface(material) {
  const hex = () => ({ value: null, setHex(value) { this.value = value; } });
  return {
    _appearance: { material },
    _earth: { material: { color: hex(), emissive: hex(), specular: hex() } },
    _atmosphere: { material: { uniforms: {
      glowColor: { value: hex() }, glowStrength: { value: 0 },
    } } },
    _nightLights: { visible: true },
  };
}
test('Elena keeps neutral surface emission and limits violet to the atmosphere', () => {
  const globe = surface({ color: 0xffffff, emissive: 0xffffff,
    emissiveIntensity: 0.50, atmosphereColor: 0xa78cff,
    atmosphereStrength: 0.24, toneMapped: true });
  apply.call(globe);
  assert.equal(globe._earth.material.color.value, 0xffffff);
  assert.equal(globe._earth.material.emissive.value, 0xffffff);
  assert.equal(globe._earth.material.emissiveIntensity, 0.50);
  assert.equal(globe._atmosphere.material.uniforms.glowColor.value.value, 0xa78cff);
  assert.equal(globe._atmosphere.material.uniforms.glowStrength.value, 0.24);
  assert.equal(globe._nightLights.visible, false);
});
test('Elias displays its night texture without directional recolouring or tone mapping', () => {
  const globe = surface({ color: 0, emissive: 0xffffff,
    emissiveIntensity: 1, shininess: 0, specular: 0,
    atmosphereColor: 0x4d7ec8, atmosphereStrength: 0.15, toneMapped: false });
  apply.call(globe);
  assert.equal(globe._earth.material.color.value, 0);
  assert.equal(globe._earth.material.emissiveIntensity, 1);
  assert.equal(globe._earth.material.specular.value, 0);
  assert.equal(globe._earth.material.toneMapped, false);
  assert.equal(globe._nightLights.visible, false);
});
test('switching from Elias to daylight restores tone mapping and the supplied palette', () => {
  const globe = surface({ toneMapped: false });
  apply.call(globe);
  globe._appearance.material = { toneMapped: true, atmosphereColor: 0x55c8ff,
    atmosphereStrength: 0.24, emissiveIntensity: 0.48 };
  apply.call(globe);
  assert.equal(globe._earth.material.toneMapped, true);
  assert.equal(globe._earth.material.emissiveIntensity, 0.48);
  assert.equal(globe._atmosphere.material.uniforms.glowColor.value.value, 0x55c8ff);
});
test('missing or malformed presentation parameters have finite restrained defaults', () => {
  for (const input of [undefined, {}, { emissiveIntensity: NaN, atmosphereStrength: Infinity },
    { emissiveIntensity: 99, atmosphereStrength: 99 }]) {
    const globe = surface(input);
    apply.call(globe);
    assert.ok(Number.isFinite(globe._earth.material.emissiveIntensity));
    assert.ok(globe._earth.material.emissiveIntensity <= 1);
    assert.ok(globe._atmosphere.material.uniforms.glowStrength.value <= 0.35);
  }
  apply.call({ _earth: null });
});
