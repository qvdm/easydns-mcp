#!/usr/bin/env bash
# scripts/prod-start.sh — production launcher
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

get_env
check_credentials

exec node "$(dirname "$0")/../dist/index.js"


