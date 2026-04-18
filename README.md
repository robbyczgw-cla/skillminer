# skillminer ⚒️

> Optional local memory scan that suggests reusable skills.

**Version:** 0.1.7 | **Runner:** OpenClaw-native by default, Claude CLI fallback optional | **Schema:** 0.3

skillminer scans your local conversation memory for recurring task patterns and suggests skills you may want to keep. It is local by default, does not auto-activate skills, and does not send notifications unless you enable them. If you switch to the Claude fallback runner, that path is external.

---

## What it does

skillminer reads recent `memory/YYYY-MM-DD.md` files, looks for work you keep doing, and opens a review step for you. If you accept a candidate, the morning writer drafts a skill into `skills/_pending/<slug>/`. You review it and decide whether to promote it.

Nothing goes live automatically.

---

## Pipeline

```
04:00 — nightly scan   reads recent memory files
                       detects recurring patterns
                       writes state/review/YYYY-MM-DD.md
                       optional notification if enabled
                       ↓
        YOU DECIDE     accept / reject / defer / silence
                       ↓
10:00 — morning write  for each accepted candidate:
                       drafts SKILL.md → skills/_pending/<slug>/
                       you manually promote from _pending/ to live skills/
```

---

## Requirements

- OpenClaw (recent version)
- `bash`, `jq` on PATH
- Claude CLI (`claude`) only if you explicitly choose `FORGE_RUNNER=claude`

---

## Quickstart

> `CLAWD_DIR` is your OpenClaw workspace, default `~/clawd`.

**Install**
```bash
git clone https://github.com/robbyczgw-cla/skillminer.git \
  "${CLAWD_DIR:-$HOME/clawd}/skills/skillminer"
```

Or via ClawHub:
```bash
openclaw skills install skillminer
```

**Bootstrap in one step**
```bash
cd "${CLAWD_DIR:-$HOME/clawd}/skills/skillminer"
bash setup.sh
```

`setup.sh` will:
- create `state/state.json` from `state-template.json` if needed
- create `config/skill-miner.config.local.json` from the default config if needed
- print the exact nightly-scan and morning-write scheduler commands for your install path

**Run a manual test before scheduling anything**
```bash
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/run-nightly-scan.sh
```

Then inspect:
```bash
ls state/review/
cat state/logs/scan-*.log | tail -n 40
```

**Only after the manual test looks good, register the two scheduler jobs**

Use your local timezone in the scheduler configuration, for example `<Your/Timezone>`.

Nightly scan, `0 4 * * *` `<Your/Timezone>`:
```bash
export CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" && bash "${CLAWD_DIR:-$HOME/clawd}/skills/skillminer/scripts/run-nightly-scan.sh"
```

Morning write, `0 10 * * *` `<Your/Timezone>`:
```bash
export CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" && bash "${CLAWD_DIR:-$HOME/clawd}/skills/skillminer/scripts/run-morning-write.sh"
```

If you installed the skill elsewhere, use the real script paths that `setup.sh` prints.

---

## Commands

skillminer is the product. `forge ...` is the command prefix it listens for.

- `forge show`
- `forge review`
- `forge accept <slug>`
- `forge reject <slug> "reason"`
- `forge defer <slug> "reason"`
- `forge silence <slug> "reason"`
- `forge unsilence <slug>`
- `forge promote <slug>`

---

## Configuration

Edit `config/skill-miner.config.local.json`:

| Key | Default | Description |
|---|---|---|
| `notifications.enabled` | `false` | Notifications are off by default. Review files are still written locally. |
| `notifications.channel` | `null` | Channel for optional notifications. `null` keeps skillminer quiet. |
| `notifications.threadId` | `null` | Optional thread/topic ID. |
| `runner.default` | `"openclaw"` | `"openclaw"` or `"claude"`. |
| `runner.openclaw_agent` | `"main"` | OpenClaw agent ID used for the local runner. |
| `scan.windowDays` | `10` | Days of memory to scan each night. |
| `scan.minOccurrences` | `3` | Minimum occurrences before a pattern can become a candidate. |
| `scan.minDistinctDays` | `2` | Pattern must span at least this many distinct days. |
| `scan.cooldownDays` | `30` | Days before rejected or deferred patterns may resurface. |
| `thresholds.low` | `3` | Minimum count for a low-confidence candidate band. |
| `thresholds.medium` | `4` | Minimum count for a medium-confidence band. |
| `thresholds.high` | `6` | Minimum count for a high-confidence band. |

Confidence labels now use the configured `thresholds.*` values instead of hardcoded prompt bands.

---

## Notification behavior

By default, skillminer does **not** notify you. It still writes review output locally:

- scan review: `state/review/YYYY-MM-DD.md`
- scan logs: `state/logs/scan-*.log`
- write logs: `state/write-log/YYYY-MM-DD.md`

Enable notifications only if you want chat delivery.

---

## Troubleshooting

**Scan ran but I got no message:**
- This is expected unless `notifications.enabled=true` and a channel is configured.
- Check the local outputs first:
```bash
ls state/review/
cat state/logs/scan-*.log | tail -n 60
```

**Nothing drafted at 10:00:**
Make sure you accepted at least one candidate before 10:00, then check:
```bash
cat state/state.json | jq '.candidates'
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

## Full guide

See [USER_GUIDE.md](USER_GUIDE.md) for the full walkthrough.

---

## License

MIT
