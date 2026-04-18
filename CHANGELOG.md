# Changelog

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
