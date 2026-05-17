#!/bin/bash
# capture_strings.sh — Full AgentAudioTap capture workflow
# Usage: ./tools/capture_strings.sh [bars] [output_path]
# Default: 8 bars, /tmp/strings_tap.wav

BARS=${1:-8}
OUT=${2:-/tmp/strings_tap.wav}
PORT=16619

# Calculate duration: BPM from Ableton, default 120
BPM=$(python3 - << 'EOF'
import socket, json
s = socket.create_connection(("127.0.0.1", 16619), timeout=5)
s.sendall(json.dumps({"code": "song.tempo"}).encode() + b"\n")
r = json.loads(s.makefile("rb").readline())
s.close()
print(r.get("result", 120))
EOF
)
SECONDS_PER_BAR=$(python3 -c "print(round(60 / $BPM * 4, 3))")
DURATION=$(python3 -c "print(round($BARS * $SECONDS_PER_BAR + 1, 1))")  # +1s buffer

echo "→ BPM: $BPM | $BARS bars = ${DURATION}s | Output: $OUT"

bridge() {
python3 - "$1" << 'EOF'
import socket, json, sys
msg = json.loads(sys.argv[1])
s = socket.create_connection(("127.0.0.1", 16619), timeout=5)
s.settimeout(10)
s.sendall(json.dumps(msg).encode() + b"\n")
r = json.loads(s.makefile("rb").readline())
s.close()
print(r.get("result", {}).get("sent", r))
EOF
}

# 1. Arm tap
echo "→ Opening tap..."
bridge '{"method":"agent_audio_tap","params":{"command":"open","path":"'"$OUT"'"}}'
sleep 0.5

# 2. Start Ableton playback and wait for confirmed playing state
echo "→ Engaging playback..."
python3 - << 'EOF'
import socket, json, time
s = socket.create_connection(("127.0.0.1", 16619), timeout=5)
# Ensure we start from current selection or beginning
s.sendall(json.dumps({"code": "song.start_playing()\nresult='playing' if song.is_playing else 'waiting'"}).encode() + b"\n")
s.makefile("rb").readline()
s.close()
EOF

# 3. Start tap (immediately after transport engagement)
echo "→ Starting capture..."
bridge '{"method":"agent_audio_tap","params":{"command":"start"}}'
sleep 0.2

# 4. Wait exactly N bars
echo "→ Recording ${BARS} bars (${DURATION}s)..."
sleep $DURATION

# 5. Stop tap first (flush WAV before stopping playback)
echo "→ Stopping tap..."
bridge '{"method":"agent_audio_tap","params":{"command":"stop"}}'
sleep 0.3

# 6. Stop Ableton playback
echo "→ Stopping playback..."
python3 - << 'EOF'
import socket, json
s = socket.create_connection(("127.0.0.1", 16619), timeout=5)
s.sendall(json.dumps({"code": "song.stop_playing()\nresult='ok'"}).encode() + b"\n")
s.makefile("rb").readline()
s.close()
EOF

# 7. Report
sleep 0.5
if [ -f "$OUT" ]; then
    SIZE=$(ls -lh "$OUT" | awk '{print $5}')
    echo "✓ Captured: $OUT ($SIZE)"
else
    echo "✗ WAV not found — check AgentAudioTap is loaded on Master"
fi
