#!/usr/bin/env bash
# The browser-watch MCP server: Chrome DevTools MCP attached to the browser browser.sh started.
# Started by the browser-validate plugin (.mcp.json at the plugin root); never register it by hand.
# It connects lazily on its first tool call, so run `browser.sh start` before calling it.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=paths.sh
. "$SCRIPT_DIR/paths.sh"

export CHROME_DEVTOOLS_MCP_NO_USAGE_STATISTICS=1
exec npx --yes chrome-devtools-mcp@1.12.0 --autoConnect --user-data-dir="$PROFILE" --no-performance-crux
