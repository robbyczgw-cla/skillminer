# skillminer — User Guide

> Optional local memory scan that suggests reusable skills.

## What it is

skillminer scans recent local memory files, spots recurring work patterns, and suggests skills you may want to keep. It is local by default, does not auto-activate anything, and does not notify you unless you enable notifications. If you switch to the Claude fallback runner, that runner is external.

## Daily cycle

```
04:00  Scan runs
       → reads recent memory files
       → finds recurring patterns
       → writes a local review file
       → optionally notifies you if enabled

       YOU decide:
       → accept, reject, defer, or silence each candidate

10:00  Write runs
       → for each accepted candidate:
         drafts a SKILL.md into skills/_pending/<slug>/
       → you promote it manually to live skills/
```

## Commands

skillminer is the product. `forge` is the command prefix.

**See what it found**
```bash
forge show
```

**Read the latest review file**
```bash
forge review
```

**Accept a candidate**
```bash
forge accept verify-bindings-post-patch
```

**Reject with cooldown**
```bash
forge reject verify-bindings-post-patch "not worth a skill"
```

**Defer for later**
```bash
forge defer verify-bindings-post-patch "maybe later"
```

**Permanently silence**
```bash
forge silence verify-bindings-post-patch "too specific to my setup"
```

**Lift a silence**
```bash
forge unsilence verify-bindings-post-patch
```

**Promote a sub-threshold observation into candidates**
```bash
forge promote verify-bindings-post-patch
```

Slug matching is fuzzy, so `verify bindings`, `verify-bindings`, and similar variants usually resolve.

Natural language examples:
```text
what skills should I have?
what patterns have I been doing?
was hat skillminer gefunden?
zeig mir skill kandidaten
ja, verify-bindings als skill
verify-bindings ablehnen
verify-bindings nochmal beobachten
verify-bindings nie wieder vorschlagen
letzten skillminer scan zeigen
```

## Installation and setup

**1. Install the skill**
```bash
git clone https://github.com/robbyczgw-cla/skillminer.git \
  "${CLAWD_DIR:-$HOME/clawd}/skills/skillminer"
```

Or:
```bash
openclaw skills install skillminer
```

**2. Bootstrap everything**
```bash
cd "${CLAWD_DIR:-$HOME/clawd}/skills/skillminer"
bash setup.sh
```

This creates the local state file if missing, copies the editable local config if missing, and prints the exact scheduler commands for your install path.

**3. Run one manual scan first**
```bash
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/run-nightly-scan.sh
```

Check the result locally:
```bash
ls state/review/
cat state/logs/scan-*.log | tail -n 40
```

**4. Only then add the two scheduler jobs**

Use your local timezone in the scheduler configuration, for example `<Your/Timezone>`.

Nightly scan, `0 4 * * *` `<Your/Timezone>`:
```bash
export CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" && bash "${CLAWD_DIR:-$HOME/clawd}/skills/skillminer/scripts/run-nightly-scan.sh"
```

Morning write, `0 10 * * *` `<Your/Timezone>`:
```bash
export CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" && bash "${CLAWD_DIR:-$HOME/clawd}/skills/skillminer/scripts/run-morning-write.sh"
```

## Configuration

Edit `config/skill-miner.config.local.json`:

| Key | Default | Description |
|---|---|---|
| `scan.windowDays` | `10` | Days of memory to scan each night |
| `scan.minOccurrences` | `3` | Minimum occurrences before proposing a candidate |
| `scan.minDistinctDays` | `2` | Candidate must span at least this many days |
| `scan.cooldownDays` | `30` | Rejection/defer cooldown |
| `thresholds.low` | `3` | Low-confidence candidate band starts here |
| `thresholds.medium` | `4` | Medium-confidence candidate band starts here |
| `thresholds.high` | `6` | High-confidence candidate band starts here |
| `notifications.enabled` | `false` | Notifications are off by default. Review files still get written locally. |
| `notifications.channel` | `null` | Channel for optional notifications |
| `notifications.threadId` | `null` | Optional thread/topic ID |
| `runner.default` | `openclaw` | `openclaw` or `claude` |
| `runner.openclaw_agent` | `main` | OpenClaw agent ID for the local runner |

## Manual runs

Run a scan manually:
```bash
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/run-nightly-scan.sh
```

Run the writer manually:
```bash
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/run-morning-write.sh
```

## Notifications

No notification is sent by default. If notifications are disabled, skillminer still works, it just writes files locally.

Look here first:
```bash
ls state/review/
ls state/write-log/
```

## Promoting a drafted skill

After the morning write:
```bash
ls "${CLAWD_DIR:-$HOME/clawd}/skills/_pending/"
```

Review the draft, then promote manually:
```bash
mv "${CLAWD_DIR:-$HOME/clawd}/skills/_pending/my-skill" "${CLAWD_DIR:-$HOME/clawd}/skills/"
```

## Troubleshooting

**No chat notification received**
- Expected if `notifications.enabled=false`
- Check local review and log files first

**Nothing was drafted at 10:00**
- Check that you accepted at least one candidate before 10:00
- Check `cat state/state.json | jq '.candidates'`

**Reset state**
```bash
cp state-template.json state/state.json
```
