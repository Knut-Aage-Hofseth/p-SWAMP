#!/usr/bin/env bash
# Playwright end-to-end browser tests — the layer on top of e2e-smoke-test.sh
# that drives a real browser against the built client, per
# e2e/reference-subapp.spec.ts. Not part of error_check.sh or any CI gate
# (see .github/workflows/ci-pipeline.yml's playwright-e2e job for that path);
# this is the local equivalent, run by hand.
#
#   scripts/run-playwright-tests.sh    run the suite (starts docker compose)
set -euo pipefail

# Run from e2e/ regardless of invocation dir — playwright.config.ts lives
# there and both npm and playwright resolve relative to cwd.
cd "$(dirname "$0")/../e2e" || exit 1

# --- Preflight ---------------------------------------------------------------
missing=()
for tool in npm npx docker; do
  command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
done
if [ "${#missing[@]}" -ne 0 ]; then
  printf '\033[31mrun-playwright-tests: required tool(s) not found on PATH: %s\033[0m\n' "${missing[*]}"
  exit 1
fi

# Fresh checkout has no node_modules — install from the lockfile first.
if [ ! -d node_modules ]; then
  echo "Installing Playwright dependencies (first run)…"
  npm ci
fi

# Browsers are cached under ~/.cache/ms-playwright, not node_modules — a fresh
# checkout needs this even with node_modules already present. Idempotent: skips
# whatever is already installed, safe to run every time.
npx playwright install --with-deps chromium

npx playwright test
