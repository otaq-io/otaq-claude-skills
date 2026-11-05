#!/usr/bin/env bash
# One Chrome per ticket, shared over CDP by playwright-cli (drives) and the browser-watch MCP (watches).
#
#   browser.sh start [--headed] [--allow-third-party-cookies]   launch Chrome, print its debugging port
#   browser.sh attach <session>                                  attach a playwright-cli session to it
#   browser.sh stop                                              detach the sessions, quit Chrome
#   browser.sh port                                              print the debugging port of the running Chrome
#
# The profile and every file the browser writes live in $BROWSER_DIR (see paths.sh), never in the worktree.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=paths.sh
. "$SCRIPT_DIR/paths.sh"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
PID_FILE="$BROWSER_DIR/chrome.pid"
SESSIONS_FILE="$BROWSER_DIR/sessions"
PORT_FILE="$PROFILE/DevToolsActivePort"

# This profile's Chrome processes only: the main binary and its helpers all run from inside Chrome's .app. Other
# processes carry the same --user-data-dir (the browser-watch MCP server does) and must survive `stop`.
regex_escape() { printf '%s' "$1" | sed -e 's/[][\.^$*+?(){}|]/\\&/g'; }
CHROME_APP="${CHROME%%.app/*}.app"
CHROME_PROCS="^$(regex_escape "$CHROME_APP")/.* --user-data-dir=$(regex_escape "$PROFILE")( |\$)"

die() {
  echo "vib-browser: $*" >&2
  exit 1
}

running_pid() {
  local pid
  [ -f "$PID_FILE" ] || return 1
  pid="$(cat "$PID_FILE")"
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null || return 1
  echo "$pid"
}

port() {
  running_pid >/dev/null || die "no browser running for $PROFILE; run: vib-browser start"
  [ -s "$PORT_FILE" ] || die "Chrome is running but $PORT_FILE is missing"
  head -n 1 "$PORT_FILE"
}

# Allow third-party cookies in the profile (merged into Default/Preferences before Chrome starts).
allow_third_party_cookies() {
  local prefs="$PROFILE/Default/Preferences"
  mkdir -p "$PROFILE/Default"
  node -e '
    const fs = require("fs");
    const file = process.argv[1];
    let prefs = {};
    try { prefs = JSON.parse(fs.readFileSync(file, "utf8")); } catch (e) {}
    prefs.profile = prefs.profile || {};
    prefs.profile.cookie_controls_mode = 0;
    prefs.profile.block_third_party_cookies = false;
    fs.writeFileSync(file, JSON.stringify(prefs));
  ' "$prefs"
}

# Never save passwords or form data in the profile: a login typed into this browser must not land on disk.
# Merged into Default/Preferences before every start.
disable_password_saving() {
  local prefs="$PROFILE/Default/Preferences"
  mkdir -p "$PROFILE/Default"
  node -e '
    const fs = require("fs");
    const file = process.argv[1];
    let prefs = {};
    try { prefs = JSON.parse(fs.readFileSync(file, "utf8")); } catch (e) {}
    prefs.credentials_enable_service = false;
    prefs.credentials_enable_autosignin = false;
    prefs.profile = prefs.profile || {};
    prefs.profile.password_manager_enabled = false;
    prefs.autofill = prefs.autofill || {};
    prefs.autofill.profile_enabled = false;
    prefs.autofill.credit_card_enabled = false;
    fs.writeFileSync(file, JSON.stringify(prefs));
  ' "$prefs"
}

start() {
  local headless="--headless=new" pid i
  while [ $# -gt 0 ]; do
    case "$1" in
      --headed) headless="" ;;
      --allow-third-party-cookies) ALLOW_3PC=1 ;;
      *) die "unknown option for start: $1" ;;
    esac
    shift
  done
  [ -x "$CHROME" ] || die "Google Chrome not found at $CHROME"

  if pid="$(running_pid)"; then
    echo "browser already running (pid $pid) on port $(port)"
    return 0
  fi

  mkdir -p "$PROFILE"
  rm -f "$PORT_FILE" "$SESSIONS_FILE"
  disable_password_saving
  if [ "${ALLOW_3PC:-0}" = 1 ]; then
    allow_third_party_cookies
  fi

  # shellcheck disable=SC2086 # $headless is empty or one flag
  nohup "$CHROME" $headless --remote-debugging-port=0 --user-data-dir="$PROFILE" \
    --no-first-run --no-default-browser-check \
    --disable-features=PasswordManagerOnboarding,AutofillServerCommunication about:blank >"$BROWSER_DIR/chrome.log" 2>&1 &
  pid=$!
  echo "$pid" >"$PID_FILE"

  for i in $(seq 1 150); do
    if [ -s "$PORT_FILE" ]; then
      echo "browser started (pid $pid) on port $(head -n 1 "$PORT_FILE")"
      return 0
    fi
    kill -0 "$pid" 2>/dev/null || die "Chrome exited at start; see $BROWSER_DIR/chrome.log"
    sleep 0.2
  done
  stop >/dev/null 2>&1 || true
  die "Chrome did not write $PORT_FILE within 30s (checked $i times); see $BROWSER_DIR/chrome.log"
}

attach() {
  local session="${1:-}" p
  [ -n "$session" ] || die "usage: vib-browser attach <session>"
  p="$(port)"
  grep -qxF "$session" "$SESSIONS_FILE" 2>/dev/null || echo "$session" >>"$SESSIONS_FILE"
  # playwright-cli writes .playwright-cli/ into its working directory: keep it out of the worktree.
  cd "$BROWSER_DIR"
  playwright-cli -s="$session" attach --cdp "http://127.0.0.1:$p"
}

stop() {
  local pid session i
  if [ -f "$SESSIONS_FILE" ]; then
    while IFS= read -r session; do
      [ -n "$session" ] || continue
      (cd "$BROWSER_DIR" && playwright-cli -s="$session" detach >/dev/null 2>&1) || true
    done <"$SESSIONS_FILE"
    rm -f "$SESSIONS_FILE"
  fi

  if pid="$(running_pid)"; then
    kill "$pid" 2>/dev/null || true
    for i in $(seq 1 50); do
      kill -0 "$pid" 2>/dev/null || break
      sleep 0.2
    done
    kill -0 "$pid" 2>/dev/null && kill -9 "$pid" 2>/dev/null || true
  fi
  # Helpers (renderer, GPU, network) of this profile's Chrome, if any outlived the main process.
  pkill -f -- "$CHROME_PROCS" 2>/dev/null || true
  for i in $(seq 1 25); do
    pgrep -f -- "$CHROME_PROCS" >/dev/null 2>&1 || break
    sleep 0.2
  done
  pkill -9 -f -- "$CHROME_PROCS" 2>/dev/null || true
  rm -f "$PID_FILE" "$PORT_FILE"
  echo "browser stopped"
}

cmd="${1:-}"
[ $# -gt 0 ] && shift
case "$cmd" in
  start) start "$@" ;;
  attach) attach "$@" ;;
  stop) stop ;;
  port) port ;;
  *) die "usage: vib-browser start [--headed] [--allow-third-party-cookies] | attach <session> | stop | port" ;;
esac
