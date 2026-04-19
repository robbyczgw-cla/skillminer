#!/usr/bin/env bash
set -euo pipefail

export CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_TEMPLATE="$SKILL_DIR/state-template.json"
STATE_DIR="$SKILL_DIR/state"
STATE_FILE="$STATE_DIR/state.json"
CONFIG_DEFAULT="$SKILL_DIR/config/skill-miner.config.json"
CONFIG_LOCAL="$SKILL_DIR/config/skill-miner.config.local.json"

mkdir -p "$STATE_DIR" "$SKILL_DIR/state/logs" "$SKILL_DIR/state/review" "$SKILL_DIR/state/write-log"

if [ ! -f "$STATE_FILE" ]; then
  cp "$STATE_TEMPLATE" "$STATE_FILE"
  echo "Created $STATE_FILE"
else
  echo "Kept existing $STATE_FILE"
fi

if [ ! -f "$CONFIG_LOCAL" ]; then
  cp "$CONFIG_DEFAULT" "$CONFIG_LOCAL"
  echo "Created $CONFIG_LOCAL"
else
  echo "Kept existing $CONFIG_LOCAL"
fi

NIGHTLY_CMD="export CLAWD_DIR=\"$CLAWD_DIR\" && bash \"$SKILL_DIR/scripts/run-nightly-scan.sh\""
WRITE_CMD="export CLAWD_DIR=\"$CLAWD_DIR\" && bash \"$SKILL_DIR/scripts/run-morning-write.sh\""

cat <<EOF

skillminer setup complete.

Run one manual scan before adding any scheduler jobs:
  $NIGHTLY_CMD

Manual wrappers:
  Nightly: $NIGHTLY_CMD
  Morning: $WRITE_CMD

Recommended scheduler pattern with your local timezone:
  - payload.kind: agentTurn
  - payload.message: inline contents of prompts/nightly-scan.md or prompts/skill-writer.md
  - delivery.mode: announce
  - delivery target: your channel/topic

Do not schedule the bash wrappers for routine cron runs.
Notifications are handled by cron announce delivery.
Review output is always written locally under:
  $SKILL_DIR/state/review/
  $SKILL_DIR/state/write-log/
EOF
