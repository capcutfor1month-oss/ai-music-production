#!/bin/bash
# ─────────────────────────────────────────────────────────
#  Conductor Bridge — Start Script
#  Double-click this file (or run in Terminal) to start
#  the local server that connects Conductor UI to Ableton,
#  NotebookLM, and the audio analyzer.
# ─────────────────────────────────────────────────────────

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ""
echo "  Starting Conductor Bridge..."
echo "  Keep this window open while using Conductor."
echo ""

python3 "$SCRIPT_DIR/conductor_bridge.py"
