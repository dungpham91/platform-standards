# GitHub repository setup

Checklist for [dungpham91/platform-standards](https://github.com/dungpham91/platform-standards). These settings are **not** stored in git — apply once in GitHub **Settings** (repo admin required).

## Security

| Setting | Location | Purpose |
| --- | --- | --- |
| Secret scanning | Settings → Code security and analysis → **Enable** | Detect leaked tokens in commits (public repos: usually available) |
| Push protection | Same → **Enable** for secret scanning | Block pushes that contain secrets |
| Dependabot alerts | Same (enabled via [.github/dependabot.yml](../.github/dependabot.yml)) | Dependency CVE notifications |
| Private vulnerability reporting | Optional | Responsible disclosure |

## Branch protection (`main`)

| Rule | Value |
| --- | --- |
| Require pull request | On |
| Required status check | **`gate`** (job in [pr-quality-gate.yml](../.github/workflows/pr-quality-gate.yml)) |
| Require signed commits | Optional (author uses GPG locally) |
| Do not allow bypass | Recommended for production-style repos |

## Environments

| Name | When to create | Notes |
| --- | --- | --- |
| `production` | Before real P4 deploy | Optional required reviewers; secrets per [GITHUB-ACTIONS-SECRETS.md](GITHUB-ACTIONS-SECRETS.md) |
| `ci-alerts` | Before Slack CI alerts | `SLACK_WEBHOOK_URL` only |

Leave `vars.DEPLOY_ENABLED` unset or `false` until AWS OIDC and targets exist.

Navigation: [README.md](../README.md), [REPO-MAP.md](REPO-MAP.md).
