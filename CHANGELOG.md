# Changelog

## 0.1.6
- Rewrite SKILL.md body — benefit-focused, non-technical, quick start via ClawHub
- Update Quick Start to include both ClawHub and manual git clone install methods

## 0.1.5
- Auto-detect the installed skill directory in all wrapper scripts and `manage-ledger.sh` via `BASH_SOURCE`, so the skill works from local checkouts and ClawHub installs.
- Update prompts to treat `FORGE_DIR` as wrapper-injected instead of deriving it from `CLAWD_DIR`.
- Clarify in `SKILL.md` and `README.md` that `CLAWD_DIR` is only for workspace memory files and `_pending/` output, while cron must point to the actual installed script path.

## 0.1.4
- Fix FORGE_DIR path in run-nightly-scan.sh and run-morning-write.sh (skill-miner → skillminer)

## 0.1.3
- Fix path inconsistency: skill-miner → skillminer in all prompt and script references

## 0.1.2
- Remove FORGE_STATE env override — simplifies security surface

## 0.1.1
- Declare CLAWD_DIR as required env var in SKILL.md metadata
- Add warning on FORGE_STATE override in manage-ledger.sh

## 0.1.0 — Initial public release
- Nightly memory scan (04:00) — detects recurring patterns across conversation history
- Morning write (10:00) — drafts SKILL.md for accepted candidates into skills/_pending/
- Schema 0.3 ledger with sub-threshold observation tracking
- Natural language interface: accept, reject, defer, silence, promote, show
- Configurable scan window, thresholds, and cooldown via config
- Notifications support (configurable channel/thread)
- OpenClaw runner (default) + Claude CLI fallback via FORGE_RUNNER env
- .gitignore and .clawhubignore — state/ and local config excluded
