const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const source = fs.readFileSync(
  path.join(__dirname, '..', 'web', 'social_vote_globe.js'),
  'utf8',
);

function methodBody(name, nextName) {
  const start = source.indexOf(`  ${name}(`);
  assert.notEqual(start, -1, `${name} must exist`);
  const end = source.indexOf(`\n  ${nextName}(`, start + 1);
  assert.notEqual(end, -1, `${nextName} must follow ${name}`);
  return source.slice(start, end);
}

test('renderer initialization restores the complete appearance including clouds', () => {
  const body = methodBody('_initialize', '_createEarth');
  assert.match(body, /this\._applyAppearance\(\);/);
  assert.doesNotMatch(
    body,
    /\n\s*this\._loadEarthTexture\(\);\s*\n\s*this\._startLoop\(\);/,
  );
});

test('complete appearance owns both earth and cloud restoration', () => {
  const body = methodBody('_applyAppearance', '_applyAppearanceMaterial');
  assert.match(body, /this\._loadEarthTexture\(\);/);
  assert.match(body, /this\._loadCloudTexture\(\);/);
  assert.match(body, /this\._applyCloudAppearance\(\);/);
});

test('cloud visibility remains driven by enabled state plus loaded texture', () => {
  const body = methodBody('_applyCloudAppearance', '_prepareColorTexture');
  assert.match(
    body,
    /this\._cloudLayer\.visible\s*=\s*enabled\s*&&\s*this\._cloudTexture\s*!=\s*null;/,
  );
});
