# plumber-example-critical — target Plumber score: **E** 🔴

[![Plumber Score](https://score.getplumber.io/github.com/getplumber-examples/plumber-example-critical.svg)](https://score.getplumber.io/github.com/getplumber-examples/plumber-example-critical)

A deliberately dangerous repository for the [Plumber](https://github.com/getplumber/plumber)
scanner. It uses the **same** [`.plumber.yaml`](./.plumber.yaml) policy as the clean and
moderate siblings, but the workflows violate almost everything.

Scanned with Plumber **v0.4.3**. Expected result: **E** — 10 Critical, 14 High, 2 Medium.
Any single Critical finding caps the score at 30 points (`scoring-v3` malus), and this repo
trips ten of them, so the grade floors at **E** (0 final points) regardless of the long tail.

> ⚠️ Every credential-looking value here is fake and harmless. The workflows are syntactically
> valid (so Plumber fully parses them) but must never run.

## Critical findings (each one alone forces E)

| Code | Issue | Where |
| --- | --- | --- |
| ISSUE-203 | Debug trace re-enabled (`ACTIONS_STEP_DEBUG: true`) — fires twice | `ci.yml` env + `auto-approve` |
| ISSUE-207 | Untrusted PR title interpolated into a shell | `ci.yml` greet |
| ISSUE-309 | Entire `toJson(secrets)` exported into an `env:` binding | `ci.yml` export secrets |
| ISSUE-410 | A security-scan job neutered with `continue-on-error: true` | `build.yml` security-scan |
| ISSUE-501 | Default branch is not protected | repo settings *(API)* |
| ISSUE-703 | Action with a known advisory (`tj-actions/changed-files@v45.0.0`) | `ci.yml` *(API)* |
| ISSUE-707 | Impostor commit: `dorny/paths-filter` pinned to a SHA absent upstream | `ci.yml` *(API)* |
| ISSUE-802 | Dangerous `workflow_run` trigger + head checkout | `dangerous.yml` |
| ISSUE-804 | `pull_request_target` + PR head checkout | `pr-preview.yml` |

The three API-backed ones (501, 703, 707) fire when `plumber analyze` runs with a `gh` token and
abstain otherwise. The rest fire unconditionally.

## The high / medium tail (for realism)

**High (14):** forbidden image not pinned by digest (`103`, `node:latest`), untrusted input
written to `$GITHUB_ENV` (`209`), `secrets: inherit` on a reusable workflow (`302`), `curl | bash`
(`411`), an action from an **archived** upstream repo (`702`, `actions/create-release`), unpinned
third-party actions (`701` ×2 — `tj-actions/changed-files@v45.0.0` and the `acme/shared-workflows@main`
reusable call), a release job restoring an unscoped cross-branch cache (`705`), actions from
unauthorized owners (`713` ×3 — `tj-actions`, `dorny/paths-filter`, `acme/shared-workflows`), and
`permissions: write-all` (`803` ×3 — `ci.yml` propagated to both jobs + `release.yml`).

**Medium (2):** forbidden mutable image tag (`102`, `node:latest`) and an ambiguous tag/branch
ref (`402`, `github/codeql-action/upload-sarif@v2` resolves as both).

## A note on ISSUE-301 (leaked secrets)

The `pipelineMustNotLeakSecretsInConfig` control (gitleaks) is enabled in the policy, but this
repo intentionally contains **no** real-format secret. Planting an `AKIA…`/token-shaped string
would cause **GitHub push protection to reject the push** of this very repo. To demo ISSUE-301
locally, add a fake secret and run `gitleaks detect` before pushing, then remove it.

## Patterns waiting on future releases

The workflows also contain a hardcoded container-registry password (`ci.yml`) and a Dependabot
config with `insecure-external-code-execution: allow`. The controls for those are still on
Plumber's dev-side bench in v0.4.3, so they don't score yet — they'll light up automatically as
those controls ship.

## Run it

```bash
plumber analyze
```
