# plumber-example-critical — target Plumber score: **E** 🔴

A deliberately dangerous repository for the [Plumber](https://github.com/getplumber/plumber)
scanner. It uses the **same** [`.plumber.yaml`](./.plumber.yaml) policy as the clean and
moderate siblings, but the workflows violate almost everything.

Expected result: **E**. Any single Critical finding caps the score at 30 points (`scoring-v3`
malus), and this repo trips many of them — so the grade floors at E regardless of the long tail
of high/medium/low issues.

> ⚠️ Every credential-looking value here is fake and harmless. The workflows are syntactically
> valid (so Plumber fully parses them) but must never run.

## Critical findings (each one alone forces E)

| Code | Issue | Where |
| --- | --- | --- |
| ISSUE-203 | Debug trace re-enabled (`ACTIONS_STEP_DEBUG: true`) | `ci.yml` env |
| ISSUE-207 | Untrusted PR title interpolated into a shell | `ci.yml` greet |
| ISSUE-209 | Untrusted input written to `$GITHUB_ENV` | `ci.yml` export title |
| ISSUE-309 | Entire `toJson(secrets)` exported | `ci.yml` export secrets |
| ISSUE-704 | Hardcoded container-registry password | `ci.yml` container |
| ISSUE-802 | Dangerous `workflow_run` trigger + head checkout | `dangerous.yml` |
| ISSUE-804 | `pull_request_target` + PR head checkout | `pr-preview.yml` |
| ISSUE-901 | Dependabot `insecure-external-code-execution: allow` | `dependabot.yml` |
| ISSUE-703 | Action with a known advisory (`tj-actions/changed-files@v45.0.0`) | `ci.yml` *(API)* |
| ISSUE-707 | Impostor commit SHA on a third-party action | `ci.yml` *(API)* |

The last two are API-backed — they fire when `plumber analyze` runs with a `gh` token, and
abstain otherwise. The eight static ones fire unconditionally.

## The high / medium / low tail (for realism)

`write-all` permissions (803), insecure commands (208), full `toJson(github)` dump (213),
spoofable `github.actor` check (210), `secrets: inherit` (302), `curl | bash` (411), unpinned
third-party action (701), persisted checkout credentials (307), static-token publish (421),
cross-branch cache restore (705) · forbidden image tag (102/103), unpinned package install
(214), `upload-artifact: path: .` (419), no environment gate (305), unsigned release (712),
unpinned Dockerfile base (706) · no workflow `name:` (601), missing `concurrency:` (418),
missing Dependabot cooldown (902), no SAST workflow (904), missing required CodeQL action
(417), no `SECURITY.md` (905).

## A note on ISSUE-301 (leaked secrets)

The `pipelineMustNotLeakSecretsInConfig` control (gitleaks) is enabled in the policy, but this
repo intentionally contains **no** real-format secret. Planting an `AKIA…`/token-shaped string
would cause **GitHub push protection to reject the push** of this very repo. To demo ISSUE-301
locally, add a fake secret and run `gitleaks detect` before pushing, then remove it.

## Run it

```bash
plumber analyze
```
