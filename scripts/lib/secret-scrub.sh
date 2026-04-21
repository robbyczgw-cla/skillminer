#!/usr/bin/env bash
# secret-scrub.sh — regex-based redaction of common secret patterns

# Patterns to redact. Extend conservatively — false positives are preferable to leaks.
SKILLMINER_SECRET_PATTERNS=(
  '(sk-[a-zA-Z0-9]{20,})'                    # OpenAI-style
  '(ghp_[a-zA-Z0-9]{36,})'                   # GitHub personal access
  '(gho_[a-zA-Z0-9]{36,})'                   # GitHub OAuth
  '(AKIA[0-9A-Z]{16})'                       # AWS access key ID
  '(eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+)'  # JWT
  '(xoxb-[0-9]+-[0-9]+-[a-zA-Z0-9]+)'        # Slack bot
  '(-----BEGIN [A-Z ]+PRIVATE KEY-----)'     # PEM
)

# Usage: scrub_stream < input > output   (stdin → stdout)
# Replaces each match with [REDACTED:pattern-index]
scrub_stream() {
  local input
  input="$(cat)"
  local i=0
  for pattern in "${SKILLMINER_SECRET_PATTERNS[@]}"; do
    input="$(printf '%s' "$input" | sed -E "s#$pattern#[REDACTED:$i]#g")"
    i=$((i + 1))
  done
  printf '%s' "$input"
}

# Usage: scrub_file_in_place <file>
# Scrubs file content, writes back atomically (via mv).
scrub_file_in_place() {
  local file="$1"
  [ -f "$file" ] || return 0
  local tmp
  tmp="$(mktemp "${file}.scrub.XXXXXX")"
  scrub_stream < "$file" > "$tmp"
  mv "$tmp" "$file"
}
