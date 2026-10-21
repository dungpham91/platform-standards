#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     terraform-io-sort.sh
# Purpose:    Sort variable/output blocks in module variables.tf and outputs.tf A-Z by name.
# Version:    1.0.0
# Requires:   bash 4+, awk (gawk)
# Usage:      bash scripts/terraform-io-sort.sh [--check|--fix] [path ...]
# Exit codes: 0 OK, 1 blocks out of order (check) or parse error
# Related:    .pre-commit-config.yaml, scripts/quality-gate-quick.sh
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="fix"
PATHS=()

usage() {
  echo "Usage: bash scripts/terraform-io-sort.sh [--check|--fix] [file-or-dir ...]" >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check) MODE="check"; shift ;;
    --fix) MODE="fix"; shift ;;
    -h | --help) usage ;;
    *) PATHS+=("$1"); shift ;;
  esac
done

if [[ ${#PATHS[@]} -eq 0 ]]; then
  PATHS=("$ROOT/src/problem1/terraform/modules")
fi

collect_files() {
  local target=$1
  if [[ -f "$target" ]]; then
    case "$target" in
      */variables.tf | */outputs.tf) printf '%s\n' "$target" ;;
    esac
    return
  fi
  if [[ -d "$target" ]]; then
    find "$target" -type f \( -name variables.tf -o -name outputs.tf \) \
      ! -path '*/.terraform/*' | sort
  fi
}

sort_one_file() {
  local file=$1
  local mode=$2
  local meta
  meta="$(mktemp)"
  sorted="$(mktemp)"

  awk -v FILENAME="$file" '
    function block_name_from_header(line,   t) {
      if (line !~ /^[ \t]*(variable|output)[ \t]+"/) return ""
      t = line
      sub(/^[ \t]*(variable|output)[ \t]+"/, "", t)
      sub(/".*$/, "", t)
      return t
    }
    function flush_block(   i, n, lines) {
      if (current_name == "") return
      n = split(current_body, lines, "\n")
      current_body = lines[1]
      for (i = 2; i <= n; i++) current_body = current_body "\n" lines[i]
      count++
      names[count] = current_name
      bodies[count] = current_body
      current_name = ""
      current_body = ""
    }
    BEGIN {
      count = 0
      depth = 0
      in_block = 0
      current_name = ""
      current_body = ""
    }
    {
      line = $0
      if (!in_block) {
        if (line ~ /^[ \t]*(variable|output)[ \t]+"/) {
          flush_block()
          current_name = block_name_from_header(line)
          current_body = line
          depth = gsub(/{/, "&", line) - gsub(/}/, "&", line)
          in_block = 1
          if (depth <= 0) {
            in_block = 0
            flush_block()
          }
          next
        }
        if (line ~ /^[ \t]*$/) next
        print "terraform-io-sort: unexpected content in " FILENAME ": " line > "/dev/stderr"
        exit 1
      }
      current_body = current_body "\n" line
      depth += gsub(/{/, "&", line) - gsub(/}/, "&", line)
      if (depth <= 0) {
        in_block = 0
        flush_block()
      }
    }
    END {
      if (in_block) {
        print "terraform-io-sort: unclosed block in " FILENAME > "/dev/stderr"
        exit 1
      }
      flush_block()
      if (count == 0) exit 0
      for (i = 1; i <= count; i++) order[i] = i
      for (i = 1; i <= count; i++) {
        for (j = i + 1; j <= count; j++) {
          if (names[order[i]] > names[order[j]]) {
            t = order[i]
            order[i] = order[j]
            order[j] = t
          }
        }
      }
      changed = 0
      for (i = 1; i <= count; i++) {
        if (order[i] != i) changed = 1
      }
      for (i = 1; i <= count; i++) {
        if (i > 1) print ""
        print bodies[order[i]]
      }
      print changed > "/dev/stderr"
    }
  ' "$file" 2>"$meta" >"$sorted" || return 1

  local changed
  changed="$(tail -n1 "$meta")"
  if [[ "$changed" == "1" ]]; then
    if [[ "$mode" == "check" ]]; then
      echo "terraform-io-sort: not A-Z sorted: $file" >&2
      rm -f "$meta" "$sorted"
      return 1
    fi
    mv "$sorted" "$file"
    echo "terraform-io-sort: sorted $file"
  else
    rm -f "$sorted"
  fi
  rm -f "$meta"
  return 0
}

FAILED=0
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  sort_one_file "$file" "$MODE" || FAILED=1
done < <(
  for target in "${PATHS[@]}"; do
    collect_files "$target"
  done | sort -u
)

if [[ "$FAILED" -ne 0 ]]; then
  exit 1
fi

echo "terraform-io-sort: OK ($MODE)"
