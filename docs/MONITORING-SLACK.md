# Monitoring and Slack alerts

Two channels: **CI/repo health** (GitHub → Slack) and **runtime platform** (AWS → SNS → Slack).

## 1 — CI / code quality → Slack

| Component | Purpose |
| --- | --- |
| [pr-quality-gate.yml](../.github/workflows/pr-quality-gate.yml) | Block bad PRs before merge (secrets, Trivy, Checkov, tests, shell lint) |
| [slack-ci-alerts.yml](../.github/workflows/slack-ci-alerts.yml) | Notify when required workflows **fail** |

### Setup (GitHub)

1. Create a Slack **Incoming Webhook** for channel `#platform-ops-alerts` (or your ops channel).
2. Environment **`ci-alerts`**: secret `SLACK_WEBHOOK_URL` (see [GITHUB-ACTIONS-SECRETS.md](GITHUB-ACTIONS-SECRETS.md)).
3. Repository variable: `SLACK_ALERTS_ENABLED` = `true` when webhook is configured.
4. Enable branch protection requiring `pr-quality-gate` — [REPO-GUARDRAILS.md](REPO-GUARDRAILS.md).

Message example:

```text
CI failed: pr-quality-gate on org/platform-standards branch feat/p1 — https://github.com/...
```

## 2 — Trading platform runtime → Slack

Terraform module: [modules/observability](../src/problem1/terraform/modules/observability/).

| Alarm | Metric | Default threshold |
| --- | --- | --- |
| ALB 5xx | `HTTPCode_Target_5XX_Count` | Sum &gt; 10 / 2 min |
| RDS CPU | `CPUUtilization` | Avg &gt; 80% / 15 min |

Flow:

```text
CloudWatch Alarm → SNS topic → Lambda (slack_notify.py) → Slack webhook
```

### Enable in dev/staging/prod

```hcl
# terraform.tfvars (do not commit webhook)
enable_slack_notifications = true
# export TF_VAR_slack_webhook_url='https://hooks.slack.com/services/...'
```

Apply after edge module creates ALB (for 5xx alarm dimensions).

### Extend (production)

- Route critical alarms to PagerDuty **and** Slack.
- SLO burn alerts from Amazon Managed Grafana or Datadog.
- Log-based metrics for order placement latency p99.
- AWS Chatbot (alternative to Lambda) for read-only runbook links in Slack.

## 3 — Application-level (Problem 4 API)

Add to backend later:

- Prometheus `/metrics` or CloudWatch embedded metric format.
- Alert on error rate and latency histogram — subscribe same SNS topic or dedicated `#platform-app` webhook.

## Verification

- [ ] PR with fake secret fails `pr-quality-gate` before merge.
- [ ] Break unit test → `slack-ci-alerts` posts to Slack (`SLACK_ALERTS_ENABLED` + `ci-alerts` secret).
- [ ] Manually set ALB alarm in test → message in Slack when Lambda enabled.
