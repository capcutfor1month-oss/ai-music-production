#!/bin/bash
# Install machine-specific Ableton assets from this portable project folder.
# Usage:
#   ./tools/install_machine_assets.sh
#
# Optional:
#   ABLETON_USER_LIBRARY="/path/to/User Library" ./tools/install_machine_assets.sh

set -euo pipefail

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$TOOL_DIR/.." && pwd)"
ABLETON_USER_LIBRARY="${ABLETON_USER_LIBRARY:-$HOME/Music/Ableton/User Library}"
REMOTE_SCRIPTS_DIR="$ABLETON_USER_LIBRARY/Remote Scripts"
M4L_DIR="$ABLETON_USER_LIBRARY/Presets/Audio Effects/Max Audio Effect"
STAMP="$(date +%Y%m%d-%H%M%S)"

echo "AI MUSIC root: $ROOT"
echo "Ableton User Library: $ABLETON_USER_LIBRARY"

install_dir() {
  local src="$1"
  local dest_parent="$2"
  local name
  name="$(basename "$src")"

  mkdir -p "$dest_parent"

  if [ -e "$dest_parent/$name" ]; then
    echo "Backing up existing $name -> $name.backup-$STAMP"
    mv "$dest_parent/$name" "$dest_parent/$name.backup-$STAMP"
  fi

  echo "Installing $name"
  cp -R "$src" "$dest_parent/"
}

install_file() {
  local src="$1"
  local dest_parent="$2"
  local name
  name="$(basename "$src")"

  mkdir -p "$dest_parent"

  if [ -e "$dest_parent/$name" ]; then
    echo "Backing up existing $name -> $name.backup-$STAMP"
    mv "$dest_parent/$name" "$dest_parent/$name.backup-$STAMP"
  fi

  echo "Installing $name"
  cp "$src" "$dest_parent/"
}

install_dir "$ROOT/machine-assets/ableton-remote-scripts/Ableton_Live_MCP" "$REMOTE_SCRIPTS_DIR"
install_dir "$ROOT/machine-assets/ableton-remote-scripts/AbletonOSC" "$REMOTE_SCRIPTS_DIR"
install_file "$ROOT/machine-assets/max-for-live/AgentAudioTap.amxd" "$M4L_DIR"
install_file "$ROOT/machine-assets/max-for-live/agent_audio_tap.js" "$M4L_DIR"

echo
echo "Done."
echo "Next:"
echo "1. Restart Ableton Live."
echo "2. Preferences -> Link/Tempo/MIDI:"
echo "   Control Surface 1 = Ableton_Live_MCP"
echo "   Control Surface 2 = AbletonOSC"
echo "3. Register MCP separately if needed:"
echo "   pipx install ableton-live-mcp"
echo "   claude mcp add ableton-live-mcp \"\$(which ableton-live-mcp)\""
