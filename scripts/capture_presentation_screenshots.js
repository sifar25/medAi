const { chromium } = require('@playwright/test');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const BASE_URL = 'http://127.0.0.1:5000';
const OUT_DIR = path.join(ROOT, 'presentations', 'screenshots');

function run(command) {
  execSync(command, { cwd: ROOT, stdio: 'pipe' });
}

function waitForHealth(attempts = 180) {
  for (let attempt = 0; attempt < attempts; attempt += 1) {
    try {
      execSync(`curl -sf ${BASE_URL}/health >/dev/null`, { cwd: ROOT, stdio: 'pipe' });
      return;
    } catch (_error) {
      execSync('sleep 1', { cwd: ROOT, stdio: 'pipe' });
    }
  }
  throw new Error('Application did not become healthy in time');
}

async function login(page) {
  await page.goto(`${BASE_URL}/login`);
  await page.getByLabel('Username').fill('clinician');
  await page.getByLabel('Password').fill('medagent123');
  await page.getByRole('button', { name: 'Sign in' }).click();
}

async function prepareForCapture(page) {
  await page.emulateMedia({ reducedMotion: 'reduce' });
  await page.addStyleTag({
    content: `
      *, *::before, *::after {
        animation: none !important;
        transition: none !important;
      }
    `,
  });
}

async function settlePage(page) {
  await page.waitForLoadState('networkidle');
  await page.evaluate(async () => {
    if (document.fonts && document.fonts.ready) {
      await document.fonts.ready;
    }
  });
  await page.locator('body').waitFor();
}

async function main() {
  fs.rmSync(OUT_DIR, { recursive: true, force: true });
  fs.mkdirSync(OUT_DIR, { recursive: true });

  run('./down.sh');
  run('./up.sh --fresh --skip-install');
  waitForHealth();

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1440, height: 1024 } });
  await prepareForCapture(page);

  await page.goto(`${BASE_URL}/login`);
  await settlePage(page);
  await page.screenshot({ path: path.join(OUT_DIR, 'login.png') });

  await login(page);
  await settlePage(page);
  await page.screenshot({ path: path.join(OUT_DIR, 'dashboard.png') });

  await page.getByLabel('Search').fill('P001');
  await page.getByLabel('Risk').selectOption('High');
  await page.getByRole('button', { name: 'Apply filters' }).click();
  await settlePage(page);
  await page.screenshot({ path: path.join(OUT_DIR, 'dashboard_filtered.png') });

  await page.getByRole('link', { name: 'Clear' }).click();
  await page.getByRole('link', { name: 'View assessment' }).first().click();
  await settlePage(page);
  await page.screenshot({ path: path.join(OUT_DIR, 'patient_result.png') });

  await page.getByRole('link', { name: 'Back to dashboard' }).click();
  await page.getByRole('link', { name: 'Run new assessment' }).click();
  await settlePage(page);
  await page.screenshot({ path: path.join(OUT_DIR, 'new_assessment_form.png') });

  const uniqueName = `Presentation User ${Date.now()}`;
  await page.getByLabel('Patient name').fill(uniqueName);
  await page.getByLabel('Age').fill('49');
  await page.getByLabel('Condition').selectOption('Diabetes');
  await page.getByLabel('Medication count').fill('4');
  await page.getByLabel('Missed doses in last 7 days').fill('3');
  await page.getByLabel('Missed doses in last 30 days').fill('8');
  await page.getByLabel('Side effects').selectOption('Mild nausea');
  await page.getByLabel('Previous adherence rate (0.00 to 1.00)').fill('0.72');
  await page.getByLabel('Appointment attendance').selectOption('Good');
  await page.getByRole('button', { name: 'Generate support summary' }).click();
  await settlePage(page);
  await page.screenshot({ path: path.join(OUT_DIR, 'new_assessment_result.png') });

  await page.getByRole('link', { name: 'Back to dashboard' }).click();
  await page.getByRole('link', { name: 'Retrain model' }).click();
  await settlePage(page);
  await page.screenshot({ path: path.join(OUT_DIR, 'train_page.png') });

  await browser.close();
  run('./status.sh > presentations/screenshots/status_output.txt');
  run('./down.sh');

  console.log(`Captured screenshots in ${OUT_DIR}`);
}

main().catch((error) => {
  try {
    run('./down.sh');
  } catch (_cleanupError) {
    // no-op
  }
  console.error(error);
  process.exit(1);
});