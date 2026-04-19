---
name: skillminer
version: 0.3.0
description: "Suggest reusable skills from recurring local memory patterns. Keeps a human review gate, drafts only to skills/_pending/, defaults to the local OpenClaw runner, supports an optional Claude fallback, and now adds richer scan summaries plus manual trigger commands. Triggers on \"skill forge\", \"propose a skill\", \"what skills should I have\", \"skill candidates\", \"what patterns have I been doing\", \"forge me a skill\"."
metadata:
  openclaw:
    requires:
      bins: ["jq", "bash", "date", "openclaw"]
      env: ["CLAWD_DIR"]
    note: "The skill auto-detects its install location. CLAWD_DIR defaults to ~/clawd if unset and is used only for workspace memory files plus skills/_pending/ output. Set FORGE_RUNNER=claude to use Claude Code CLI with external execution. Never activates skills automatically."
triggers:
  - "skill forge"
  - "skill candidates"
  - "what patterns have I been doing"
  - "forge me a skill"
  - "forge show"
  - "forge accept"
  - "forge reject"
  - "forge defer"
  - "forge silence"
  - "forge unsilence"
  - "forge promote"
  - "forge review"
  - "skill candidates zeigen"
  - "was hat skillminer gefunden"
  - "annehmen als skill"
  - "ablehnen skill"
  - "letzen skillminer scan"
  - "letzten skillminer scan"
---

# skillminer ⚒️

skillminer suggests reusable skills from recurring work in your local memory files.

## What makes it trustworthy

- Human gate first, always
- Drafts go to `skills/_pending/`, never live skills
- Local OpenClaw runner by default
- Claude fallback is optional and external
- Notifications are off by default
- Review files are written locally even when notifications stay off
- Nightly scan summaries now include trend arrows, pending-age hints, and a live portfolio snapshot

## Quick start

```bash
openclaw skills install skillminer
cd "${CLAWD_DIR:-$HOME/clawd}/skills/skillminer"
bash setup.sh
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/run-nightly-scan.sh
```

If the manual scan looks good, add the printed scheduler jobs.

## Commands

skillminer is the product. `forge` is the command prefix.

- `forge show`
- `forge review`
- `forge accept <slug>`
- `forge reject <slug> "reason"`
- `forge defer <slug> "reason"`
- `forge silence <slug> "reason"`
- `forge unsilence <slug>`
- `forge promote <slug>`

## Manual triggers

Use the new wrapper when you want to kick the scan or writer manually without remembering full paths.

```bash
skillminer scan
skillminer write
skillminer full
skillminer status
skillminer help
```

Typical use cases:
- You just received a fresh memory file and do not want to wait for the nightly run.
- Cami wants to trigger a scan or write through delegated exec.
- Andy is on SSH and wants a short command instead of the full wrapper path.
- You want a quick status check before deciding whether to review pending candidates.

Who can use it:
- You directly over SSH
- Cami via delegated exec
- Andy via SSH

When to use it:
- Right after important memory landed
- Before a manual review session
- For debugging scheduler drift
- When you want a one-shot `scan` or `full` run today

## Flow

```
nightly scan  -> review file, cron announce delivery
human decision -> accept / reject / defer / silence
morning write -> draft into skills/_pending/, cron announce delivery
human promote -> move draft into live skills/
```

See [USER_GUIDE.md](USER_GUIDE.md) for full usage.
