# Changelog

## 0.3.3 - 2026-04-19
- Fixed: removed literal injection-example phrase from nightly-scan.md prompt that triggered ClawHub static scanner false positive. Framing preserved, wording neutralized.

## 0.3.2 - 2026-04-19
- Add wrapper-level atomic tmp-write handling for `state.json`, review files, and write logs, including backup rotation and JSON validation rollback
- Add parent-aware `flock` locking across `skillminer`, `run-nightly-scan.sh`, and `run-morning-write.sh` with exit code `3` for lock contention
- Add conservative memory-as-data security framing in the nightly scan prompt plus oversized-memory warnings in the nightly wrapper
- Document production hardening, `flock` requirement, and the new non-zero exit codes

## 0.3.1 - 2026-04-19
- Fix ClawHub scanner issues by adding `git` to required binaries
- Mark `CLAWD_DIR` as optional in skill metadata and align docs around the `~/clawd` default
- Add explicit local-vs-external runner disclosure for the default `openclaw` runner and optional `FORGE_RUNNER=claude` fallback
- Align the ledger and prompts on schema `0.4`, including `manage-ledger.sh` acceptance

## 0.3.0 - 2026-04-19
- Add observation trend fields to the 0.4 ledger schema: `previousOccurrences` and `previousDays`, with prompt guidance to treat legacy missing values as `null`
- Expand nightly scan reporting with observation trend arrows, pending-candidate ledger aging, and a live portfolio snapshot section
- Add `scripts/skillminer` manual wrapper with `scan`, `write`, `full`, `status`, and `help` subcommands
- Update `setup.sh`, `SKILL.md`, and `USER_GUIDE.md` to document manual triggers and optional `/usr/local/bin/skillminer` symlink installation
- Keep the 0.2.1 scheduled-run notify fix intact: no prompt-level notifications, cron announce delivery only

## 0.2.1 - 2026-04-19
- Fix notify hang in scheduled runs by removing inner notification steps from `prompts/nightly-scan.md` and `prompts/skill-writer.md`
- Scheduled notifications now belong to cron `delivery.mode: announce`, not prompt-level `openclaw message send`
- Recommended cron integration now uses `payload.kind: agentTurn` with inline prompt content instead of `bash run-*.sh` wrappers
- Update README, USER_GUIDE, and setup output to document the supported cron pattern

## 0.2.0
- Rewrite intro — honest language: optional local scan, no auto-activate, no notifications by default, Claude fallback is external
- Unify naming — Scout/Scribe removed from all user-facing docs, skillminer is the product, `forge` is the command
- Add `setup.sh` — bootstraps state.json, copies config, prints scheduler commands. `bash setup.sh` just works
- Fix notifications mismatch — default is off everywhere, local review files still written regardless
- Wire thresholds — `config/skill-miner.config.json` → `run-nightly-scan.sh` → nightly prompt. Config now actually drives behavior
- Shorten prompts — more determinism in jq/shell, less LLM prose
- Resolve writer-prompt conflict — step-preservation is now explicit verbatim, no "clean up grammar" ambiguity
- Rework quickstart — manual test first, then enable cron. Testable before automated

## 0.1.7
- Normalize all skill-miner → skillminer references across scripts, prompts, docs
- Rename cron jobs to skillminer-nightly-scan / skillminer-morning-write

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
- Notifications support (configurable channel)
- OpenClaw runner (default) + Claude CLI fallback via FORGE_RUNNER env
- .gitignore and .clawhubignore — state/ and local config excluded
