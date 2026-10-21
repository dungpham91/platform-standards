# Local security scan (developer workstation)

CI uses Linux runners; on Windows use the commands below before push.

## Always available (Node)

```bash
cd src/problem4/apps/backend && npm ci && npm test
cd src/problem4/apps/frontend && npm ci && npm test
cd src/problem3/api && npm ci && npm test
bash scripts/lint-shell.sh   # requires shellcheck + shfmt (Git Bash / WSL apt)
bash tests/problem3_smoke.sh # Docker required — same as CI problem3-compose-smoke
```

## Gitleaks

Download [Gitleaks release](https://github.com/gitleaks/gitleaks/releases), then:

```bash
gitleaks detect --source . --no-banner --config .gitleaks.toml
```

## Trivy (IaC)

Download [Trivy Windows binary](https://github.com/aquasecurity/trivy/releases), then:

```bash
mapfile -t IAC_DIRS < <(bash scripts/iac-scan-paths.sh --relative)
trivy config --severity CRITICAL,HIGH,MEDIUM,LOW --exit-code 1 "${IAC_DIRS[@]}"
```

## Checkov

```bash
pip install checkov==3.3.30
bash scripts/checkov-iac-gate.sh
```

## Full wrapper

```bash
bash scripts/security-scan.sh
```

Requires Trivy on `PATH`, optional Checkov/Gitleaks/Docker.
