#!/bin/bash
# skillminer nightly scan wrapper — invoked by cron at 04:00
# OpenClaw edition: uses `openclaw agent --message` (or claude as fallback via FORGE_RUNNER).
# No su - forge: OC isolated session provides sandboxing.

set -euo pipefail

export CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORGE_DIR="$SKILL_DIR"
LOG_DIR="$FORGE_DIR/state/logs"
mkdir -p "$LOG_DIR"

STAMP="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
LOG="$LOG_DIR/scan-$STAMP.log"

FORGE_RUNNER="${FORGE_RUNNER:-openclaw}"

# Read config (prefer local override when present)
CONFIG_FILE="$FORGE_DIR/config/skill-miner.config.local.json"
if [ ! -f "$CONFIG_FILE" ]; then
  CONFIG_FILE="$FORGE_DIR/config/skill-miner.config.json"
fi
OC_AGENT="$(jq -r '.runner.openclaw_agent // "main"' "$CONFIG_FILE" 2>/dev/null || echo 'main')"
SCAN_WINDOW_DAYS="$(jq -r '.scan.windowDays // 10' "$CONFIG_FILE" 2>/dev/null || echo '10')"
SCAN_MIN_OCCURRENCES="$(jq -r '.scan.minOccurrences // 3' "$CONFIG_FILE" 2>/dev/null || echo '3')"
SCAN_MIN_DISTINCT_DAYS="$(jq -r '.scan.minDistinctDays // 2' "$CONFIG_FILE" 2>/dev/null || echo '2')"
SCAN_COOLDOWN_DAYS="$(jq -r '.scan.cooldownDays // 30' "$CONFIG_FILE" 2>/dev/null || echo '30')"

# Write temp prompt file — inject runtime values (OC agent doesn't inherit env vars)
PROMPT_FILE="$(mktemp /tmp/forge-scan-prompt.XXXXXX.md)"
{
  printf '> **Runtime preamble (injected by run-nightly-scan.sh):**\n'
  printf '> `CLAWD_DIR=%s` — use this as the authoritative CLAWD_DIR value throughout; skip Step 0 MISSING check (env var is not available in the agent session, but this path is confirmed valid).\n' "$CLAWD_DIR"
  printf '> `FORGE_DIR=%s` — use this as the authoritative installed skill path throughout; do not derive it from `CLAWD_DIR`.\n' "$FORGE_DIR"
  printf '> `scan.windowDays=%s`, `scan.minOccurrences=%s`, `scan.minDistinctDays=%s`, `scan.cooldownDays=%s` — these are the active scan settings from `%s`; use them instead of prompt defaults wherever referenced below.\n\n' \
    "$SCAN_WINDOW_DAYS" "$SCAN_MIN_OCCURRENCES" "$SCAN_MIN_DISTINCT_DAYS" "$SCAN_COOLDOWN_DAYS" "$CONFIG_FILE"
  cat "$FORGE_DIR/prompts/nightly-scan.md"
} > "$PROMPT_FILE"

cd "$CLAWD_DIR"
{
  echo "=== skillminer nightly-scan ==="
  echo "started: $(date -u --iso-8601=seconds)"
  echo "CLAWD_DIR=$CLAWD_DIR"
  echo "FORGE_RUNNER=$FORGE_RUNNER"
  echo "user: $(id -un)"
  echo "---"
} > "$LOG"

if [ "$FORGE_RUNNER" = "openclaw" ]; then
  openclaw agent --agent "$OC_AGENT" --message "$(cat "$PROMPT_FILE")" >> "$LOG" 2>&1
elif [ "$FORGE_RUNNER" = "claude" ]; then
  # Note: Claude Code blocks file-read permission bypass as root (security policy).
  # The claude runner requires running as a non-root user. As root, use FORGE_RUNNER=openclaw.
  if [ "$(id -u)" = "0" ]; then
    echo "WARNING: claude runner cannot bypass file permissions as root (Claude Code security policy)." >> "$LOG"
    echo "Use FORGE_RUNNER=openclaw (default) or run as a non-root user for the claude runner." >> "$LOG"
    rm -f "$PROMPT_FILE"
    exit 1
  fi
  claude --print \
    --model sonnet \
    --effort high \
    --permission-mode auto \
    --max-budget-usd 3 \
    < "$PROMPT_FILE" >> "$LOG" 2>&1
else
  echo "ERROR: unknown FORGE_RUNNER=$FORGE_RUNNER (expected: openclaw | claude)" >> "$LOG"
  rm -f "$PROMPT_FILE"
  exit 1
fi

EXIT=$?
rm -f "$PROMPT_FILE"
{
  echo "---"
  echo "exit: $EXIT"
  echo "finished: $(date -u --iso-8601=seconds)"
} >> "$LOG"

# rotate logs — keep last 30
find "$LOG_DIR" -name 'scan-*.log' -type f -printf '%T@ %p\n' | \
  sort -n | head -n -30 | cut -d' ' -f2- | xargs -r rm -f

exit $EXIT
