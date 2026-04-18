# skillminer ⚒️

> *Your AI notices what you keep doing. skillminer turns it into skills.*

**Version:** 0.1.3 | **Runner:** OpenClaw-native (Claude CLI fallback) | **Schema:** 0.3

*Your AI watches. Every night, without asking. It reads what you built, what you fixed, what you asked three times without noticing. Then, one morning, it says: "You keep doing this. Want it as a skill?"*

---

## What it does

skillminer scans your daily conversation memory and detects **recurring task patterns** — things you ask your AI assistant to do 3+ times across 2+ different days. When a pattern crosses that threshold, it proposes a new skill for your review. You decide what gets drafted. You decide what goes live. Nothing happens without your say.

Runs every night at 04:00. Zero auto-activation. You stay in control.

---

## Why would I want this?

- You keep checking config bindings manually after every patch — skill-miner notices and proposes a `verify-bindings` skill to automate it.
- Every few days you ask your agent to clean up stale memory files — it flags that as a candidate and drafts a `weekly-memory-cleanup` skill.
- You habitually verify cron job health after infrastructure changes — skill-miner surfaces that pattern and offers to codify it as a reusable check.

---

## Pipeline

```
04:00 — nightly-scan   reads 10 days of memory/YYYY-MM-DD.md
                       clusters patterns, scores confidence
                       writes state/review/YYYY-MM-DD.md
                       sends you a notification
                       ↓
        YOU DECIDE     accept / reject / defer / silence
                       ↓
10:00 — morning-write  for each accepted candidate:
                       drafts SKILL.md → skills/_pending/<slug>/
                       you manually promote from _pending/ to live skills/
```

---

## Requirements

- OpenClaw (any recent version)
- `bash`, `jq` on PATH
- Claude CLI (`claude`) — optional, only needed for `FORGE_RUNNER=claude` fallback

---

## Installation

> **`CLAWD_DIR`** is where OpenClaw keeps your workspace. Defaults to `~/clawd`. Set it in your shell env if your workspace is elsewhere.

**Clone into your workspace:**
```bash
git clone https://github.com/robbyczgw-cla/skillminer.git \
  "${CLAWD_DIR:-$HOME/clawd}/skills/skill-miner"
```

> ClawHub install coming soon: `openclaw skills install skillminer`

**Bootstrap state:**
```bash
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}"
cp "$CLAWD_DIR/skills/skill-miner/state-template.json" \
   "$CLAWD_DIR/skills/skill-miner/state/state.json"
```

**Configure (optional but recommended):**
```bash
cp "$CLAWD_DIR/skills/skill-miner/config/skill-miner.config.json" \
   "$CLAWD_DIR/skills/skill-miner/config/skill-miner.config.local.json"
```
Edit `skill-miner.config.local.json` with your values. This file is git-ignored and won't be overwritten on updates.

**Register two cron jobs in OpenClaw:**

Use your local timezone in the cron configuration, for example `<Your/Timezone>`.

Nightly scan — `0 4 * * *` `<Your/Timezone>`:
```
export CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" && bash "$CLAWD_DIR/skills/skill-miner/scripts/run-nightly-scan.sh"
```

Morning write — `0 10 * * *` `<Your/Timezone>`:
```
export CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" && bash "$CLAWD_DIR/skills/skill-miner/scripts/run-morning-write.sh"
```

---

## Configuration

Edit `config/skill-miner.config.local.json`:

| Key | Default | Description |
|---|---|---|
| `notifications.enabled` | `false` | Enable/disable notifications. |
| `notifications.channel` | `null` | Channel for review notifications (`null` = disable) |
| `notifications.threadId` | `null` | Thread/topic ID. `null` = main chat. |
| `runner.default` | `"openclaw"` | `"openclaw"` or `"claude"`. Override with `FORGE_RUNNER` env var. |
| `runner.openclaw_agent` | `"main"` | OC agent ID used for the openclaw runner. |
| `scan.windowDays` | `10` | Days of memory to scan each night. |
| `scan.minOccurrences` | `3` | Minimum occurrences to become a candidate. |
| `scan.minDistinctDays` | `2` | Pattern must span at least this many distinct days. |
| `scan.cooldownDays` | `30` | Days before rejected/deferred patterns resurface. |
| `thresholds.low` | `2` | Occurrences to reach low confidence. |
| `thresholds.medium` | `4` | Occurrences to reach medium confidence. |
| `thresholds.high` | `6` | Occurrences to reach high confidence. |

---

## → Full usage guide

Commands, fuzzy matching, natural language interface, runner modes, manual dry-runs, state files, schema — it's all in **[USER_GUIDE.md](USER_GUIDE.md)**.

---

## Troubleshooting

**Scan didn't run / no notification:**
```bash
cat "${CLAWD_DIR:-$HOME/clawd}/skills/skill-miner/state/logs/scan-YYYY-MM-DD.log"
cat "${CLAWD_DIR:-$HOME/clawd}/skills/skill-miner/state/review/YYYY-MM-DD.md"
```

**Nothing drafted at 10:00:**
Make sure you accepted at least one candidate before 10:00, then check:
```bash
cat "${CLAWD_DIR:-$HOME/clawd}/skills/skill-miner/state/state.json" | jq '.candidates'
```

**State file corrupted:**
```bash
cp state-template.json state/state.json
```

**Switch runner:**
```bash
FORGE_RUNNER=claude CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/run-nightly-scan.sh
```

---

## License

MIT
