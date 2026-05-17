#!/bin/bash
# Send a music production question to Gemini CLI.
# Runs from /tmp so GEMINI.md is NOT auto-loaded — no 30K token overhead.
# Uses your Google account OAuth (same auth as Gemini CLI normally).
#
# Usage:
#   tools/ask_gemini.sh "what reverb for strings in bollywood?"

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG="$ROOT/tools/token_log.jsonl"

if [ $# -eq 0 ] || [ -z "${1:-}" ]; then
  echo "Usage: ask_gemini.sh \"<question>\"" >&2
  exit 1
fi

SYSTEM="You are an expert music producer specialising in Bollywood, Punjabi pop, and cinematic orchestral production. Reference artists: A.R. Rahman, Arijit Singh, Diljit Dosanjh, Hans Zimmer. Always answer with exact Hz, dB, ms, ratio, and velocity values. Always use this output format — no exceptions:

## Signal Chain
## EQ (Hz and dB values only)
## Compression / Sidechain Settings
## [most relevant section — e.g. Reverb Settings / Velocity Map / Tuning Approach]
## What to Avoid
## Reference Tracks

Do not add follow-up questions or offers. Stop after Reference Tracks."

QUERY="$SYSTEM

Question: $1"

# Run from /tmp so Gemini does NOT find or load GEMINI.md
RAW="$(cd /tmp && gemini --approval-mode plan --output-format json -p "$QUERY" 2>/dev/null)"

# Print the response
RESPONSE="$(echo "$RAW" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('response',''))")"
echo "$RESPONSE"

# Log token stats
python3 - "$RAW" "$1" "$LOG" <<'PYEOF'
import sys, json
from datetime import datetime

raw_str  = sys.argv[1]
question = sys.argv[2][:120]
log_path = sys.argv[3]

try:
    d = json.loads(raw_str)
    models = d.get("stats", {}).get("models", {})
    model_name = next(iter(models), "unknown")
    tok = models.get(model_name, {}).get("tokens", {})

    entry = {
        "ts":     datetime.now().isoformat(timespec="seconds"),
        "source": "gemini",
        "model":  model_name,
        "query":  question,
        "input":  tok.get("input", 0),
        "output": tok.get("candidates", 0),
        "total":  tok.get("total", 0),
    }
    with open(log_path, "a") as f:
        f.write(json.dumps(entry) + "\n")

    print(f"\n── Gemini tokens: {entry['input']} in / {entry['output']} out / {entry['total']} total ({model_name})", file=sys.stderr)
except Exception as e:
    print(f"\n── Token logging failed: {e}", file=sys.stderr)
PYEOF
