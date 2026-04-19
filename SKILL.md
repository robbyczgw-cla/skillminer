---
name: skillminer
version: 0.3.2
description: "Suggest reusable skills from recurring local memory patterns. Keeps a human review gate, drafts only to skills/_pending/, defaults to the local OpenClaw runner, supports an optional external Claude fallback, and now adds richer scan summaries, manual trigger commands, atomic state writes, flock locking, and memory-as-data framing. Triggers on \"skill forge\", \"propose a skill\", \"what skills should I have\", \"skill candidates\", \"what patterns have I been doing\", \"forge me a skill\"."
metadata:
  openclaw:
    requires:
      bins: ["jq", "bash", "date", "git", "openclaw", "flock"]
      env:
        CLAWD_DIR: optional
    note: "The skill auto-detects its install location. CLAWD_DIR defaults to ~/clawd if unset and is used only for workspace memory files plus skills/_pending/ output. The default runner is openclaw (local only, no data leaves the host). FORGE_RUNNER=claude is an optional external fallback that uses Claude CLI and sends data to Anthropic's API. Only enable it if you understand that data leaves the host. Never activates skills automatically."
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
- Local OpenClaw runner by default, local only, no data leaves the host
- Claude fallback is optional, external, and sends data to Anthropic's API
- Notifications are off by default
- Review files are written locally even when notifications stay off
- Nightly scan summaries now include trend arrows, pending-age hints, and a live portfolio snapshot

## Production hardening (0.3.2)

- Atomic tmp-write plus wrapper validation for `state.json`
- Atomic promotion for review and write-log files
- Parent/child `flock` locking to prevent overlapping runs
- Conservative memory-as-data framing against prompt injection attempts
- Exit code `2` for validation or atomic-write failures, `3` for lock contention

## Quick start

```bash
openclaw skills install skillminer
cd "${CLAWD_DIR:-$HOME/clawd}/skills/skillminer"
bash setup.sh
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/run-nightly-scan.sh
```

If the manual scan looks good, add the printed scheduler jobs.

## Environment

- `CLAWD_DIR` is optional. If unset, skillminer defaults to `~/clawd`.
- `FORGE_RUNNER` defaults to `openclaw`, which stays local to the host.
- `FORGE_RUNNER=claude` is an optional fallback that uses Claude CLI and sends prompt data to Anthropic's API. Only enable it if you understand that data leaves the host.

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
