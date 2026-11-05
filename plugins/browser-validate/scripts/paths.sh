#!/usr/bin/env bash
# Sourced by browser.sh and devtools-mcp.sh: the one place that computes where a ticket's browser lives.
#
#   BROWSER_DIR  $OTAQ_RESOURCE_DIR/browser, or ~/.cache/validate-in-browser/<KEY> outside Otaq
#   PROFILE      $BROWSER_DIR/profile: Chrome's --user-data-dir; Chrome writes DevToolsActivePort there
#
# <KEY> is $OTAQ_TICKET, or "default" when no ticket is set.

if [ -n "${OTAQ_RESOURCE_DIR:-}" ]; then
  BROWSER_DIR="$OTAQ_RESOURCE_DIR/browser"
else
  BROWSER_DIR="$HOME/.cache/validate-in-browser/${OTAQ_TICKET:-default}"
fi
PROFILE="$BROWSER_DIR/profile"
export BROWSER_DIR PROFILE
