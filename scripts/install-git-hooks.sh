#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     install-git-hooks.sh
# Purpose:    Write .git/hooks/pre-push to run quality-gate-quick.sh before push.
# Version:    1.0.0
# Requires:   bash 4+, git repository initialized
# Usage:      bash scripts/install-git-hooks.sh
# Exit codes: 0 hook installed, 1 not a git repo
# Related:    scripts/quality-gate-quick.sh, docs/REPO-GUARDRAILS.md
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$ROOT/.git/hooks/pre-push"

if [[ ! -d "$ROOT/.git" ]]; then
  echo "Not a git repository: $ROOT"
  exit 1
fi

cat > "$HOOK" <<'EOF'
#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     .git/hooks/pre-push (generated)
# Purpose:    Run quality-gate-quick.sh before git push.
# Version:    1.0.0
# Related:    scripts/install-git-hooks.sh
# ------------------------------------------------------------------------------
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
echo "pre-push: running quality gate..."
bash "$ROOT/scripts/quality-gate-quick.sh"
echo "pre-push: OK (CI still required on PR before merge)"
EOF

chmod +x "$HOOK"
echo "Installed $HOOK"
echo "Optional: pre-commit install (see docs/REPO-GUARDRAILS.md)"
