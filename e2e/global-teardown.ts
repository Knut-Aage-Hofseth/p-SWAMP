import { execSync } from 'node:child_process'

/**
 * Always runs once after the whole test run, regardless of pass/fail —
 * to ensure that the docker compose environment is torn down and cleaned up.
 */
export default function globalTeardown() {
  execSync('docker compose down --remove-orphans', { stdio: 'inherit' })
}
