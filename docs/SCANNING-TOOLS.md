# Trivy and Checkov — why both?

| Tool | Maintainer | Strength | Used for |
| --- | --- | --- | --- |
| [Trivy](https://github.com/aquasecurity/trivy) | Aqua (CNCF) | Fast, unified scanner: IaC misconfig, containers, secrets, SARIF | Primary SARIF upload to GitHub Advanced Security |
| [Checkov](https://github.com/bridgecrewio/checkov) | Prisma (Bridgecrew) | Deep Terraform/CloudFormation policy library, compliance frameworks (CIS, SOC2 mappings) | Second opinion + compliance IDs in CI |

**Neither replaces the other.** Trivy is optimized for pipeline speed and container/image coverage; Checkov excels at Terraform-specific policy breadth and audit-style rule IDs.

CI runs **both** on the paths from [`scripts/iac-scan-paths.sh`](../scripts/iac-scan-paths.sh) (`--terraform` for modules + live, `--compose` for Problem 3). Severities **CRITICAL through LOW**. SARIF categories: `trivy-terraform`, `checkov-terraform`, `checkov-docker-compose`.

Official / well-maintained runners only — see [REPO-GUARDRAILS.md](REPO-GUARDRAILS.md).
