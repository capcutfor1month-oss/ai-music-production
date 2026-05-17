#!/bin/bash
# Show token usage log for both Claude and Gemini calls.
# Usage:
#   tools/show_tokens.sh          → last 10 calls + totals by model
#   tools/show_tokens.sh --all    → full history

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG="$ROOT/tools/token_log.jsonl"

if [ ! -f "$LOG" ] || [ ! -s "$LOG" ]; then
  echo "No token log yet. Run ask_gemini.sh or answer a question first."
  exit 0
fi

ALL=false
[ "${1:-}" = "--all" ] && ALL=true

python3 - "$LOG" "$ALL" <<'PYEOF'
import sys, json

log_path = sys.argv[1]
show_all = sys.argv[2] == "True"

entries = []
with open(log_path) as f:
    for line in f:
        line = line.strip()
        if line:
            try:
                entries.append(json.loads(line))
            except:
                pass

display = entries if show_all else entries[-10:]

print(f"\n{'Source':<8} {'Timestamp':<22} {'In':>7} {'Out':>6} {'Total':>7}  Query")
print("─" * 95)
for e in display:
    src   = e.get("source", "gemini")
    q     = e.get("query", "")[:48]
    note  = " *est*" if e.get("note") else ""
    print(f"{src:<8} {e.get('ts',''):<22} {e.get('input',0):>7,} {e.get('output',0):>6,} {e.get('total',0):>7,}{note}  {q}")

print("─" * 95)

# Totals by source
sources = {}
for e in display:
    s = e.get("source", "gemini")
    sources.setdefault(s, {"input": 0, "output": 0, "total": 0})
    sources[s]["input"]  += e.get("input", 0)
    sources[s]["output"] += e.get("output", 0)
    sources[s]["total"]  += e.get("total", 0)

for src, t in sources.items():
    est = " (estimated)" if src == "claude" else ""
    print(f"{src.upper():<8} {'TOTAL':<22} {t['input']:>7,} {t['output']:>6,} {t['total']:>7,}{est}")

grand_total = sum(e.get("total", 0) for e in display)
print(f"\n  Grand total ({len(display)} calls): {grand_total:,} tokens")
print(f"  Use --all for full history.  * = estimated")
PYEOF
