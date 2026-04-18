# skillminer ⚒️

> Your AI assistant keeps solving the same problems. skillminer notices — and suggests turning them into reusable skills.

**Version:** 0.2.0 | **Runner:** OpenClaw-native | **Schema:** 0.3

You build patterns. Every day, in every conversation. skillminer watches your local memory files, spots recurring work, and surfaces the ones worth keeping. No auto-activation, no cloud sync, no noise by default. Just a morning suggestion waiting in your inbox when something actually deserves to become a skill.

---

## How it works

```
04:00 — nightly scan   reads recent memory/YYYY-MM-DD.md files
                       detects recurring task patterns
                       writes a review file to state/review/
                       (optional: notifies you if enabled)
                       ↓
        YOU DECIDE     forge accept / reject / defer / silence
                       ↓
10:00 — morning write  drafts a SKILL.md into skills/_pending/<slug>/
                       you review it, promote it, ship it
```

Nothing goes live automatically. You stay in control at every step.

---

## Requirements

- OpenClaw (recent version)
- `bash`, `jq` on PATH
- Claude CLI (`claude`) — only if you explicitly switch to `FORGE_RUNNER=claude`

---

## Quickstart

> `CLAWD_DIR` is your OpenClaw workspace — default `~/clawd`.

**1. Install**

Via ClawHub:
```bash
openclaw skills install skillminer
```

Or manual:
```bash
git clone https://github.com/robbyczgw-cla/skillminer.git \
  "${CLAWD_DIR:-$HOME/clawd}/skills/skillminer"
```

**2. Bootstrap**

```bash
cd "${CLAWD_DIR:-$HOME/clawd}/skills/skillminer"
bash setup.sh
```

This creates your state file, copies the default config, and prints the exact scheduler commands for your install path.

**3. Test it first**

```bash
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/run-nightly-scan.sh
```

Then look at what it found:
```bash
ls state/review/
cat state/logs/scan-*.log | tail -n 40
```

**4. Schedule it**

Only after the manual run looks good — `setup.sh` prints the exact commands. Nightly scan at 04:00, morning write at 10:00, your local timezone.

---

## Commands

`forge` is the command prefix. `skillminer` is the product.

```
forge show                       — what's in the ledger?
forge review                     — open pending candidates
forge accept <slug>              — queue for morning draft
forge reject <slug> "reason"     — dismiss it
forge defer <slug> "reason"      — maybe later
forge silence <slug> "reason"    — stop surfacing this one
forge unsilence <slug>           — undo silence
forge promote <slug>             — move _pending draft to live skills/
```

---

## Configuration

Edit `config/skill-miner.config.local.json` (git-ignored, your personal values):

| Key | Default | Description |
|---|---|---|
| `notifications.enabled` | `false` | Off by default — review files are still written locally |
| `notifications.channel` | `null` | Channel for optional push notifications |
| `notifications.threadId` | `null` | Optional thread/topic ID |
| `runner.default` | `"openclaw"` | `"openclaw"` or `"claude"` |
| `runner.openclaw_agent` | `"main"` | OpenClaw agent used for the local runner |
| `scan.windowDays` | `10` | Days of memory to scan each night |
| `scan.minOccurrences` | `3` | Minimum occurrences before a pattern is a candidate |
| `scan.minDistinctDays` | `2` | Pattern must span at least this many distinct days |
| `scan.cooldownDays` | `30` | Days before rejected/deferred patterns can resurface |
| `thresholds.low` | `3` | Low-confidence band minimum |
| `thresholds.medium` | `4` | Medium-confidence band minimum |
| `thresholds.high` | `6` | High-confidence band minimum |

---

## Output

By default, skillminer is silent. It still writes everything locally:

- Scan review: `state/review/YYYY-MM-DD.md`
- Scan logs: `state/logs/scan-*.log`
- Write logs: `state/write-log/YYYY-MM-DD.md`

Enable `notifications.enabled` only if you want chat delivery on top of that.

---

## Troubleshooting

**No notification after the scan?**
Expected — `notifications.enabled` is `false` by default. Check the local files first.

**Nothing drafted at 10:00?**
You need to accept at least one candidate before the morning write runs:
```bash
cat state/state.json | jq '.candidates'
```

**State file corrupted?**
```bash
cp state-template.json state/state.json
```

**Want to try the Claude runner?**
```bash
FORGE_RUNNER=claude CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/run-nightly-scan.sh
```

---

## Full guide

See [USER_GUIDE.md](USER_GUIDE.md) for the complete walkthrough.

---

## License

MIT
