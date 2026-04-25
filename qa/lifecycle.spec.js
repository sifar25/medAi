const { test, expect } = require('@playwright/test');
const { execSync } = require('child_process');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const BASE_URL = 'http://127.0.0.1:5000';

function run(cmd) {
  execSync(cmd, { cwd: ROOT, stdio: 'pipe' });
}

function waitForHealthShell(attempts = 180) {
  for (let i = 0; i < attempts; i += 1) {
    try {
      execSync(`curl -sf ${BASE_URL}/health >/dev/null`, { cwd: ROOT, stdio: 'pipe' });
      return;
    } catch (_err) {
      execSync('sleep 1', { cwd: ROOT, stdio: 'pipe' });
    }
  }
  throw new Error('App did not become healthy in time');
}

test.describe('MedAgent browser lifecycle QA', () => {
  test.describe.configure({ mode: 'serial' });
  test.setTimeout(240000);

  test.beforeAll(() => {
    run('./down.sh');
    run('./up.sh --skip-install');
    waitForHealthShell();
  });

  test.afterAll(() => {
    run('./down.sh');
  });

  test('human-like UI flow: login, navigate, create, dedupe, logout', async ({ browser }) => {

    const context = await browser.newContext();
    const page = await context.newPage();

    // 1) Login page
    await page.goto(`${BASE_URL}/login`);
    await expect(page.getByText('Welcome back')).toBeVisible();
    await expect(page.getByText('clinician / medagent123')).toBeVisible();

    // 2) Invalid login
    await page.getByLabel('Username').fill('wrong-user');
    await page.getByLabel('Password').fill('wrong-pass');
    await page.getByRole('button', { name: 'Sign in' }).click();
    await expect(page.getByText('incorrect')).toBeVisible();

    // 3) Valid login and dashboard
    await page.getByLabel('Username').fill('clinician');
    await page.getByLabel('Password').fill('medagent123');
    await page.getByRole('button', { name: 'Sign in' }).click();
    await expect(page.getByRole('heading', { name: 'Patient list' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Apply filters' })).toBeVisible();
    await page.getByLabel('Search').fill('P001');
    await page.getByRole('button', { name: 'Apply filters' }).click();
    await expect(page.getByRole('cell', { name: 'P001' })).toBeVisible();
    await page.getByRole('link', { name: 'Clear' }).click();
    await expect(page.getByText('Page 1 of')).toBeVisible();
    await page.getByRole('link', { name: '2' }).click();
    await expect(page.getByText('Page 2 of')).toBeVisible();

    // 4) Existing patient details
    await page.getByRole('link', { name: 'View assessment' }).first().click();
    await expect(page.getByRole('heading', { name: 'Predicted non-adherence risk' })).toBeVisible();
    await expect(page.getByRole('heading', { name: 'Recommended support plan' })).toBeVisible();

    // 5) New assessment create and save
    await page.getByRole('link', { name: 'Back to dashboard' }).click();
    await page.getByRole('link', { name: 'Run new assessment' }).click();
    await expect(page.getByRole('heading', { name: 'Run a new patient assessment' })).toBeVisible();

    const uniqueName = `Playwright QA ${Date.now()}`;
    await page.getByLabel('Patient name').fill(uniqueName);
    await page.getByLabel('Age').fill('49');
    await page.getByLabel('Condition').selectOption('Diabetes');
    await page.getByLabel('Medication count').fill('4');
    await page.getByLabel('Missed doses in last 7 days').fill('3');
    await page.getByLabel('Missed doses in last 30 days').fill('8');
    await page.getByLabel('Side effects').selectOption('Mild nausea');
    await page.getByLabel('Previous adherence rate (0.00 to 1.00)').fill('0.72');
    await page.getByLabel('Appointment attendance').selectOption('Good');

    const saveCheckbox = page.getByRole('checkbox', { name: 'Save this assessment to the dataset (idempotent, no duplicates)' });
    await expect(saveCheckbox).toBeChecked();
    await page.getByRole('button', { name: 'Generate support summary' }).click();

    await expect(page.getByText('Saved:')).toBeVisible();
    await expect(page.getByRole('heading', { name: uniqueName })).toBeVisible();

    // 6) Re-submit same payload to verify dedupe
    await page.getByRole('link', { name: 'Back to dashboard' }).click();
    await page.getByRole('link', { name: 'Run new assessment' }).click();

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

    await expect(page.getByText('Already exists:')).toBeVisible();

    // 7) Logout and redirect back to login
    await page.getByRole('link', { name: 'Logout' }).click();
    await expect(page.getByText('Welcome back')).toBeVisible();

    await context.close();
  });

  test('fresh lifecycle reset restores default seed and login', async ({ browser }) => {
    run('./down.sh --fresh');
    run('./up.sh --fresh --skip-install');
    waitForHealthShell();

    const context = await browser.newContext();
    const page = await context.newPage();
    await page.goto(`${BASE_URL}/login`);
    await expect(page.getByText('clinician / medagent123')).toBeVisible();

    await page.getByLabel('Username').fill('clinician');
    await page.getByLabel('Password').fill('medagent123');
    await page.getByRole('button', { name: 'Sign in' }).click();
    await expect(page.getByRole('heading', { name: 'Patient list' })).toBeVisible();
    await expect(page.getByText('Showing 1-8 of 20 filtered records.')).toBeVisible();
    await expect(page.getByText('Page 1 of 3')).toBeVisible();

    await context.close();
  });
});
