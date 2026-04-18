---
name: skill-miner
version: 0.1.0
description: "Autonomous skill proposal system (OpenClaw runner edition). Scans memory for recurring work patterns and drafts skills into skills/_pending/ for human review. Uses openclaw agent --message as runner; falls back to claude --print via FORGE_RUNNER env. Schema 0.3 ledger with a human review gate. Triggers on \"skill forge\", \"propose a skill\", \"what skills should I have\", \"skill candidates\", \"what patterns have I been doing\", \"forge me a skill\"."
metadata:
  openclaw:
    requires:
      bins: ["jq", "bash", "date", "openclaw"]
      note: "Requires CLAWD_DIR env var and openclaw CLI in PATH. Set FORGE_RUNNER=claude to use Claude Code CLI instead. Never activates skills — always drafts to _pending/ for human promotion."
triggers:
  - "skill forge"
  - "propose a skill"
  - "what skills should I have"
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
  - "was hat skill-miner gefunden"
  - "annehmen als skill"
  - "ablehnen skill"
  - "letzten forge scan"
---

# Skill Miner ⚒️ (OpenClaw Edition)

Requires `CLAWD_DIR` and the `openclaw` CLI in `PATH`. Set `FORGE_RUNNER=claude` to use Claude Code CLI instead. Never activates skills, it only drafts to `_pending/` for human promotion.

> *Your AI notices what you keep doing. skill-miner turns it into skills.*

Nightly scan → pattern clustering → draft skill proposals. Human reviews, human approves, human promotes. Zero auto-activation.

**This is the OpenClaw runner edition.** Uses `openclaw agent --message` by default. Set `FORGE_RUNNER=claude` to use the Claude Code CLI path. Schema 0.3 unchanged. State dir: `state/`.

## Quick Setup

1. Set your workspace path if needed (defaults to `~/clawd` when `CLAWD_DIR` is unset):
   ```bash
   export CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}"
   ```

2. Bootstrap state:
   ```bash
   cp $CLAWD_DIR/skills/skill-miner/state-template.json \
      $CLAWD_DIR/skills/skill-miner/state/state.json
   ```

3. Configure notifications and runner (optional):
   Copy `config/skill-miner.config.json` to `config/skill-miner.config.local.json` and customize your channel, thread, and agent values there. The scripts prefer `config/skill-miner.config.local.json` when present, and fall back to the defaults.

4. Schedule two crons via the OpenClaw cron tool (ask your AI assistant):
   - **Nightly scan:** `0 4 * * *` → `export CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" && bash "$CLAWD_DIR/skills/skill-miner/scripts/run-nightly-scan.sh"`
   - **Morning write:** `0 10 * * *` → `export CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" && bash "$CLAWD_DIR/skills/skill-miner/scripts/run-morning-write.sh"`

5. Wake up to candidates in `state/review/YYYY-MM-DD.md`.

6. Accept / reject / defer / promote / silence via `scripts/manage-ledger.sh`.

7. Accepted candidates get auto-drafted to `skills/_pending/<slug>/SKILL.md` by the 10:00 writer run. Promote them manually from `_pending/` to live `skills/`.

## Runner Modes

| `FORGE_RUNNER` | Command used | Notes |
|---|---|---|
| `openclaw` (default) | `openclaw agent --message "$(cat prompt)"` | No Claude API key needed |
| `claude` | `claude --print --model sonnet ...` | Requires Claude Code CLI + Anthropic auth |

## State Files

- `state/state.json` — ledger (schema 0.3)
- `state/review/YYYY-MM-DD.md` — nightly scan review docs
- `state/write-log/YYYY-MM-DD.md` — morning write logs
- `state/logs/` — raw runner output logs
- `state/.last-success` — scan health sentinel
- `state/.last-write` — write health sentinel

## Ledger Operations

```bash
# View all candidates
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/manage-ledger.sh show

# Accept a candidate for the morning write
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/manage-ledger.sh accept <slug>

# Reject with reason (30-day cooldown)
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/manage-ledger.sh reject <slug> "reason"

# Defer (30-day cooldown, softer)
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/manage-ledger.sh defer <slug> "reason"

# Permanently silence a pattern
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/manage-ledger.sh silence <slug> "reason"
```

## Natural Language Commands

You can manage candidates conversationally. your AI assistant understands all of the following (German and English, fuzzy matching):

### Show & Explore
- **"forge show"** / **"skill candidates zeigen"** / **"was hat skill-miner gefunden"**
  → Runs `manage-ledger.sh show` and presents all current candidates, their confidence, trigger phrases, and status.

- **"forge show <slug>"** / **"zeig mir <slug> genauer"**
  → Shows full detail for one specific candidate (intent, occurrences, proposed steps, citations).

- **"forge review"** / **"letzten forge scan zeigen"**
  → Reads and displays the latest `state/review/YYYY-MM-DD.md`.

### Decisions
- **"forge accept <slug>"** / **"<slug> annehmen"** / **"ja, <slug> als skill"** / **"skill draus machen: <slug>"**
  → Marks the candidate as `accepted`. The morning writer (10:00) will draft a `SKILL.md` into `skills/_pending/<slug>/`.
  → your AI assistant confirms: "✅ `<slug>` accepted — skill draft arrives tomorrow morning."

- **"forge reject <slug>"** / **"<slug> ablehnen"** / **"<slug> nicht als skill"** (+ optional reason)
  → 30-day cooldown. Pattern won't re-surface until cooldown expires.
  → your AI assistant asks for a reason if none given, then runs `manage-ledger.sh reject <slug> "<reason>"`.

- **"forge defer <slug>"** / **"<slug> vertagen"** / **"<slug> nochmal beobachten"** (+ optional reason)
  → Softer than reject. Same 30-day cooldown, but signals "not now, check again later".
  → your AI assistant confirms with cooldown expiry date.

- **"forge silence <slug>"** / **"<slug> dauerhaft ignorieren"** / **"<slug> nie wieder vorschlagen"** (+ optional reason)
  → Permanent veto. No expiry. Use for patterns that are genuinely not skill-worthy.
  → your AI assistant asks for confirmation before silencing (irreversible without `unsilence`).

- **"forge unsilence <slug>"** / **"<slug> wieder erlauben"**
  → Lifts a permanent silence. Does NOT resurrect the candidate — it just allows future scans to re-detect it.

- **"forge promote <slug>"** / **"<slug> hochstufen"**
  → Promotes a sub-threshold observation to a full candidate (for manual override when you spotted a pattern the scanner underrated).

### How your AI assistant handles these

When you trigger any of the above:
1. your AI assistant reads the current `state/state.json` to verify the slug exists and its current status.
2. Runs `CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash "$CLAWD_DIR/skills/skill-miner/scripts/manage-ledger.sh" <command> <slug> ["<reason>"]`.
3. Confirms the outcome with the new status and any relevant next steps (e.g. "morning writer picks this up at 10:00").
4. If the slug is ambiguous or doesn't exist, your AI assistant lists current candidates and asks which one you meant.

**Slug matching is fuzzy:** "verify bindings", "verify-bindings", "bindings post patch" all resolve to `verify-bindings-post-patch` if it's the only close match.

---

## Dry-Run (Manual Trigger)

```bash
# Trigger a scan now (openclaw runner)
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/run-nightly-scan.sh

# Trigger a scan now (claude runner — for comparison)
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" FORGE_RUNNER=claude bash scripts/run-nightly-scan.sh

# Trigger morning write
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash scripts/run-morning-write.sh
```
