#!/bin/bash
# Bootstrap AI MUSIC PRODUCTION on a new Mac.
#
# This installs/checks CLI-side dependencies and copies bundled Ableton assets.
# It does NOT install Ableton Live and cannot select Ableton Control Surfaces.

set -euo pipefail

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$TOOL_DIR/.." && pwd)"
ZSHRC="$HOME/.zshrc"
ENV_MARKER_BEGIN="# >>> AI MUSIC PRODUCTION >>>"
ENV_MARKER_END="# <<< AI MUSIC PRODUCTION <<<"

log() {
  echo
  echo "==> $1"
}

warn() {
  echo "WARN: $1" >&2
}

have() {
  command -v "$1" >/dev/null 2>&1
}

append_env_block() {
  log "Writing portable environment variables to ~/.zshrc"

  if [ -f "$ZSHRC" ] && grep -q "$ENV_MARKER_BEGIN" "$ZSHRC"; then
    warn "AI MUSIC PRODUCTION env block already exists in ~/.zshrc; leaving it unchanged."
    return
  fi

  {
    echo
    echo "$ENV_MARKER_BEGIN"
    echo "export AI_MUSIC_ROOT=\"$ROOT\""
    echo "export NOTEBOOKLM_BIN=\"\$(command -v notebooklm 2>/dev/null || true)\""
    echo "export ABLETON_MCP_BIN=\"\$(command -v ableton-live-mcp 2>/dev/null || true)\""
    echo "$ENV_MARKER_END"
  } >> "$ZSHRC"
}

run_health_checks() {
  log "Running health checks"

  echo "Project root: $ROOT"

  if have ableton-live-mcp; then
    echo "ableton-live-mcp: $(command -v ableton-live-mcp)"
  else
    warn "ableton-live-mcp not found"
  fi

  if have notebooklm; then
    echo "notebooklm: $(command -v notebooklm)"
    notebooklm status || warn "NotebookLM status failed. Run: notebooklm login"
  else
    warn "notebooklm not found"
  fi

  echo
  echo "Ableton-dependent checks are not run automatically here."
  echo "After Ableton is installed/open and Control Surfaces are selected, test:"
  echo "  python3 \"$ROOT/tools/get_tempo.py\""
  echo "  \"$ROOT/tools/capture_strings.sh\" 1 /tmp/test_tap.wav"
}

log "Bootstrapping AI MUSIC PRODUCTION"
echo "Root: $ROOT"

log "Checking Homebrew"
if ! have brew; then
  echo "Homebrew is not installed. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "Homebrew found: $(command -v brew)"
fi

if ! have brew; then
  echo "ERROR: Homebrew is still not available in PATH. Restart Terminal and re-run this script."
  exit 1
fi

log "Checking Python and pipx"
if ! have python3; then
  brew install python
else
  echo "python3 found: $(command -v python3)"
fi

if ! have pipx; then
  brew install pipx
else
  echo "pipx found: $(command -v pipx)"
fi

pipx ensurepath || true

log "Installing Ableton MCP server"
if have ableton-live-mcp; then
  echo "ableton-live-mcp already found: $(command -v ableton-live-mcp)"
else
  pipx install ableton-live-mcp
fi

log "Installing NotebookLM CLI"
if have notebooklm; then
  echo "notebooklm already found: $(command -v notebooklm)"
else
  pipx install notebooklm-py
fi

log "Installing bundled Ableton assets"
"$ROOT/tools/install_machine_assets.sh"

append_env_block

log "Registering MCP with Claude Code if available"
if have claude; then
  if claude mcp list 2>/dev/null | grep -q "ableton-live-mcp"; then
    echo "Claude MCP entry already exists for ableton-live-mcp."
  else
    claude mcp add ableton-live-mcp "$(command -v ableton-live-mcp)" || warn "Claude MCP registration failed."
  fi
else
  warn "Claude Code CLI not found. Install Claude Code, then run:"
  echo "  claude mcp add ableton-live-mcp \"\$(command -v ableton-live-mcp)\""
fi

log "NotebookLM login"
if have notebooklm; then
  notebooklm status || notebooklm login || warn "NotebookLM login did not complete."
  notebooklm list || warn "NotebookLM list failed."
  notebooklm use be8353eb-3d3e-447f-b3ce-4b09f0e1df07 || warn "Could not select PLUGING LIBRARY notebook. If unavailable, create/select a notebook and upload NotebookLM Sources/."
fi

run_health_checks

log "Manual steps left"
cat <<EOF
1. Install/open Ableton Live 12 Suite.
2. In Ableton: Preferences -> Link/Tempo/MIDI.
3. Select:
   Control Surface 1 = Ableton_Live_MCP
   Control Surface 2 = AbletonOSC
4. Restart Terminal or run:
   source "$ZSHRC"
EOF

echo
echo "Bootstrap complete."
