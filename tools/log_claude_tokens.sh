#!/bin/bash
# Log estimated Claude token usage for a Q&A turn.
# Called by Claude after each response via Bash tool.
#
# Usage:
#   log_claude_tokens.sh "<question text>" "<response text>"
#
# Token estimate: character_count / 4  (within ~10% of actual for English + code)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG="$ROOT/tools/token_log.jsonl"

if [ $# -lt 2 ]; then
  echo "Usage: log_claude_tokens.sh \"<question>\" \"<response>\"" >&2
  exit 1
fi

python3 - "$1" "$2" "$LOG" <<'PYEOF'
import sys, json
from datetime import datetime

question = sys.argv[1]
response = sys.argv[2]
log_path = sys.argv[3]

# ~4 chars per token is a good approximation for mixed prose + code
input_est  = len(question)  // 4
output_est = len(response)  // 4
total_est  = input_est + output_est

entry = {
    "ts":       datetime.now().isoformat(timespec="seconds"),
    "source":   "claude",
    "model":    "claude-sonnet-4-6",
    "query":    question[:120],
    "input":    input_est,
    "output":   output_est,
    "total":    total_est,
    "note":     "estimated (~4 chars/token)",
}

with open(log_path, "a") as f:
    f.write(json.dumps(entry) + "\n")

print(f"── Claude tokens (est): {input_est} in / {output_est} out / {total_est} total", file=sys.stderr)
PYEOF
