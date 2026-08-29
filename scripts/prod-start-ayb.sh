#!/usr/bin/env bash
# scripts/prod-start-ayb.sh — production launcher for the AYB (ayb.ca) account.
#
# Reads the combined easyDNS credential from $EASYDNS_TOKEN_AYB in the form
# "token:key" (e.g. "mcp:xxxxxxxx"), splits it, and starts the MCP server
# scoped to ayb.ca in production with writes enabled.
#
# The KiroCrew gateway does not necessarily inherit an interactive shell's
# exports, so if $EASYDNS_TOKEN_AYB is not already in the environment we source
# the user's env.zsh (which defines it) as a fallback. No secret is stored in
# any MCP config file this way.
set -euo pipefail
umask 077

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Fallback: pull the var from the user's shell env file if not already exported.
if [[ -z "${EASYDNS_TOKEN_AYB:-}" && -f "$HOME/.config/zsh/env.zsh" ]]; then
  EASYDNS_TOKEN_AYB="$(grep -E '^export EASYDNS_TOKEN_AYB=' "$HOME/.config/zsh/env.zsh" \
    | head -1 | sed 's/^export EASYDNS_TOKEN_AYB=//' | tr -d '"'"'"'"')"
fi

if [[ -z "${EASYDNS_TOKEN_AYB:-}" ]]; then
  echo "ERROR: EASYDNS_TOKEN_AYB is not set (expected token:key)" >&2
  exit 1
fi
if [[ "$EASYDNS_TOKEN_AYB" != *:* ]]; then
  echo "ERROR: EASYDNS_TOKEN_AYB must be in 'token:key' form" >&2
  exit 1
fi

export EASYDNS_TOKEN="${EASYDNS_TOKEN_AYB%%:*}"
export EASYDNS_API_KEY="${EASYDNS_TOKEN_AYB#*:}"
export EASYDNS_SANDBOX=false
export EASYDNS_ALLOW_PRODUCTION=true
export EASYDNS_ENABLE_WRITES=true
export EASYDNS_ALLOWED_DOMAINS=ayb.ca
# Never touch these through the MCP server even if allowed above.
export EASYDNS_PROTECTED_DOMAINS=quantumcondo.ca

exec node "${SCRIPT_DIR}/../dist/index.js"
