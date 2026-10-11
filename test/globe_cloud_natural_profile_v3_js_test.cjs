const fs = require('node:fs');
const test = require('node:test');
const assert = require('node:assert/strict');

const source = fs.readFileSync('web/social_vote_globe.js', 'utf8');

test('Web clouds use the neutral Natural profile as the renderer fallback', () => {
  assert.match(source, /emissive:\s*0xf7fbff/);
  assert.match(source, /emissiveIntensity:\s*0\.18/);
  assert.match(source, /profileNumber\('opacityMin',\s*0\.42/);
  assert.match(source, /profileNumber\('opacityMax',\s*0\.82/);
  assert.match(source, /profileNumber\('thresholdSparse',\s*0\.82/);
  assert.match(source, /profileNumber\('thresholdDense',\s*0\.12/);
});

test('Cloud lifecycle restore remains present', () => {
  assert.match(
    source,
    /Apply the complete appearance snapshot[\s\S]*this\._applyAppearance\(\);/,
  );
});
