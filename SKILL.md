---
name: skill-miner
version: 0.1.6
description: "Autonomous skill proposal system (OpenClaw runner edition). Scans memory for recurring work patterns and drafts skills into skills/_pending/ for human review. Uses openclaw agent --message as runner; falls back to claude --print via FORGE_RUNNER env. Schema 0.3 ledger with a human review gate. Triggers on \"skill forge\", \"propose a skill\", \"what skills should I have\", \"skill candidates\", \"what patterns have I been doing\", \"forge me a skill\"."
metadata:
  openclaw:
    requires:
      bins: ["jq", "bash", "date", "openclaw"]
      env: ["CLAWD_DIR"]
    note: "The skill auto-detects its install location. CLAWD_DIR defaults to ~/clawd if unset and is used only for workspace memory files plus skills/_pending/ output. Set FORGE_RUNNER=claude to use Claude Code CLI (requires Anthropic credentials). Never activates skills — always drafts to _pending/ for human promotion."
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

# skillminer ⚒️

Stop doing the same thing three times. Let the skill notice — and propose a fix.

skillminer watches your daily conversation memory and detects recurring task patterns — things you ask your AI assistant to do again and again. When a pattern crosses the threshold, it drafts a new skill proposal for your review. You decide what becomes real.

✨ What Makes This Different?
- **Zero auto-activation** — nothing happens without your explicit OK
- **Pattern detection, not guesswork** — needs 3+ occurrences across 2+ days before proposing
- **Drafts real SKILL.md files** — ready to promote directly to your live skills/
- **Runs while you sleep** — nightly scan at 04:00, draft ready by 10:00
- **Fully configurable** — scan window, thresholds, notifications, runner

🚀 Quick Start
```bash
# Via ClawHub (recommended)
openclaw skills install skillminer

# Or manually
git clone https://github.com/robbyczgw-cla/skillminer.git \
  "${CLAWD_DIR:-$HOME/clawd}/skills/skillminer"
```
Then bootstrap state and register two cron jobs — full instructions in [USER_GUIDE.md](USER_GUIDE.md).

Once running:
- Say **"forge show"** to see current candidates
- Say **"forge accept \<slug\>"** — skill draft arrives at 10:00
- Say **"forge reject \<slug\>"** to dismiss with 30-day cooldown

💬 Natural Language Commands
Talk to your assistant — all commands work in English and German:
- `forge show` / `skill candidates zeigen`
- `forge accept verify-bindings-post-patch`
- `forge reject <slug> "reason"`
- `forge defer <slug>` — check again later
- `forge silence <slug>` — permanent veto
- `forge review` — read the latest scan report

📋 How It Works
```
04:00  Nightly scan runs
       → reads last 10 days of conversation memory
       → clusters recurring patterns
       → sends you a review notification

       YOU DECIDE: accept / reject / defer / silence

10:00  Morning write runs
       → drafts SKILL.md → skills/_pending/<slug>/
       → you promote manually to live skills/
```

Zero auto-activation. You stay in control.

