const { spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const GENERATOR = path.join(__dirname, 'generate_presentation.py');
const CANDIDATES = [
  path.join(ROOT, '.venv', 'bin', 'python'),
  path.join(ROOT, '.venv', 'Scripts', 'python.exe'),
  'python3',
  'python',
];

for (const candidate of CANDIDATES) {
  const isAbsoluteCandidate = candidate.includes(path.sep);
  if (isAbsoluteCandidate && !fs.existsSync(candidate)) {
    continue;
  }

  const result = spawnSync(candidate, [GENERATOR], {
    cwd: ROOT,
    stdio: 'inherit',
    shell: process.platform === 'win32' && !isAbsoluteCandidate,
  });

  if (!result.error && result.status === 0) {
    process.exit(0);
  }
}

console.error('Unable to run scripts/generate_presentation.py with a local or system Python interpreter.');
process.exit(1);