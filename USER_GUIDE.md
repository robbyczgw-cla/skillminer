# skillminer — User Guide

> Your AI watches what you keep doing. skillminer turns it into skills.

## How it works

Every night at 04:00, skillminer scans your last 10 days of conversation memory and looks for patterns — things you asked your AI assistant to do 3 or more times across multiple days. When a pattern is strong enough, it proposes a new skill for your review.

You decide what becomes a real skill. Nothing is auto-activated.

---

## The daily cycle

```
04:00  Scan runs
       → reads 10 days of memory
       → finds recurring patterns
       → sends you a review notification

       YOU decide (anytime after the notification):
       → accept, reject, defer, or silence each candidate

10:00  Write runs
       → for each candidate you accepted:
         drafts a SKILL.md into skills/_pending/<slug>/
       → you promote it manually to live skills/
```

---

## Making decisions

Talk to your AI assistant naturally. All commands work in English and German.

**See what was found:**
```
forge show
```

**Accept a candidate** (queues it for skill drafting at 10:00):
```
forge accept verify-bindings-post-patch
```

**Reject** (30-day cooldown):
```
forge reject verify-bindings-post-patch "not worth a skill"
```

**Defer** (softer reject, check again later):
```
forge defer verify-bindings-post-patch
```

**Permanently silence** (never suggest again):
```
forge silence verify-bindings-post-patch "too specific to my setup"
```

**Read the latest scan report:**
```
forge review
```

Slug matching is fuzzy — "verify bindings", "verify-bindings", "bindings post patch" all resolve to the same candidate.

**Natural language also works:**
```
what skills should I have?
what patterns have I been doing?
was hat skillminer gefunden?
zeig mir skill kandidaten
ja, verify-bindings als skill
verify-bindings ablehnen
verify-bindings nochmal beobachten
verify-bindings nie wieder vorschlagen
letzten forge scan zeigen
```

---

## Installation

**1. Copy the skill into your OpenClaw workspace:**
```bash
cp -r skillminer "$CLAWD_DIR/skills/"
```

**2. Bootstrap state:**
```bash
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}"
cp "$CLAWD_DIR/skills/skillminer/state-template.json" \
   "$CLAWD_DIR/skills/skillminer/state/state.json"
```

**3. Configure (optional):**
```bash
cp "$CLAWD_DIR/skills/skillminer/config/skill-miner.config.json" \
   "$CLAWD_DIR/skills/skillminer/config/skill-miner.config.local.json"
```
Edit `skill-miner.config.local.json` with your values (Telegram channel, agent, etc.). This file is git-ignored and won't be overwritten on updates.

**4. Set up two cron jobs in OpenClaw:**
- Use your local timezone in the cron configuration, for example `<Your/Timezone>`.
- **Nightly scan:** `0 4 * * *` `<Your/Timezone>`
  ```
  export CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" && bash "$CLAWD_DIR/skills/skillminer/scripts/run-nightly-scan.sh"
  ```
- **Morning write:** `0 10 * * *` `<Your/Timezone>`
  ```
  export CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" && bash "$CLAWD_DIR/skills/skillminer/scripts/run-morning-write.sh"
  ```

---

## Configuration

Edit `config/skill-miner.config.local.json`:

| Key | Default | Description |
|---|---|---|
| `scan.windowDays` | `10` | Days of memory to scan each night |
| `notifications.enabled` | `false` | Send scan results to a chat channel |
| `notifications.channel` | `null` | Channel name (e.g. `telegram`) |
| `notifications.threadId` | `null` | Thread/topic ID for notifications |
| `runner.default` | `openclaw` | `openclaw` or `claude` |
| `runner.openclaw_agent` | `main` | OpenClaw agent ID for the runner |

---

## Triggering a scan manually

```bash
CLAWD_DIR="${CLAWD_DIR:-$HOME/clawd}" bash skills/skillminer/scripts/run-nightly-scan.sh
```

---

## Promoting a drafted skill

After the morning write, check `skills/_pending/`:
```bash
ls "$CLAWD_DIR/skills/_pending/"
```

Review the draft, then promote manually:
```bash
mv "$CLAWD_DIR/skills/_pending/my-skill" "$CLAWD_DIR/skills/"
```

---

## Troubleshooting

**No notification received:**
```bash
cat "$CLAWD_DIR/skills/skillminer/state/logs/scan-YYYY-MM-DD.log"
```

**Nothing was drafted at 10:00:**
- Check that you accepted at least one candidate before 10:00
- Check: `cat "$CLAWD_DIR/skills/skillminer/state/state.json" | jq '.candidates'`

**Reset state (loses history):**
```bash
cp "$CLAWD_DIR/skills/skillminer/state-template.json" \
   "$CLAWD_DIR/skills/skillminer/state/state.json"
```
