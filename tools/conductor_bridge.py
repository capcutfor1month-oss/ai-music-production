#!/usr/bin/env python3
"""
Conductor Bridge v1.0
─────────────────────
Local HTTP server (localhost:4601) that bridges the Conductor web UI
to local tools: Ableton MCP (TCP 16619), NotebookLM CLI, audio-analyzer CLI.

Start:  python3 conductor_bridge.py
Stop:   Ctrl+C
"""

import json
import os
import socket
import subprocess
import sys
import threading
import time
import urllib.parse
from http.server import BaseHTTPRequestHandler, HTTPServer

# ── CONFIG ────────────────────────────────────────────────────────────────────

BRIDGE_PORT = 4601

# Ableton MCP — TCP connection (bschoepke remote script)
ABLETON_HOST = "localhost"
ABLETON_PORT = 16619

# NotebookLM CLI — third-party notebooklm-py
NOTEBOOKLM_CANDIDATES = [
    "/opt/homebrew/var/pipx/venvs/notebooklm-py/bin/notebooklm",
    "/usr/local/bin/notebooklm",
    os.path.expanduser("~/.local/bin/notebooklm"),
]

# Audio Analyzer CLI (Rust, compiled)
AUDIO_ANALYZER_CANDIDATES = [
    "/Volumes/T7 Shield/Users/Aditya/Downloads/AI MUSIC PRODUCTION/audio-analyzer-rs/cli",
    os.path.join(os.path.dirname(__file__), "../audio-analyzer-rs/cli"),
]

# Mem0 MCP — check if mcp-mem0 is listening (default 8123 or stdin/stdout, we just mark ready)
# PluginBridge — loaded inside Ableton; we detect via Ableton connectivity

CONFIG_FILE = os.path.join(os.path.dirname(__file__), "conductor_bridge_config.json")

# ── HELPERS ───────────────────────────────────────────────────────────────────

def load_config():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE) as f:
            return json.load(f)
    return {}

def save_config(cfg):
    with open(CONFIG_FILE, "w") as f:
        json.dump(cfg, f, indent=2)

def find_binary(candidates, config_key=None):
    """Return first existing binary from candidates, or saved config path."""
    cfg = load_config()
    if config_key and cfg.get(config_key):
        p = cfg[config_key]
        if os.path.exists(p):
            return p
    for c in candidates:
        if os.path.exists(c):
            return c
    return None

def ableton_connected():
    """Try TCP handshake with Ableton MCP on port 16619."""
    try:
        s = socket.create_connection((ABLETON_HOST, ABLETON_PORT), timeout=1.0)
        s.close()
        return True
    except Exception:
        return False

def notebooklm_path():
    return find_binary(NOTEBOOKLM_CANDIDATES, "notebooklm_bin")

def audio_analyzer_path():
    return find_binary(AUDIO_ANALYZER_CANDIDATES, "audio_analyzer_bin")

def cors_headers(handler):
    handler.send_header("Access-Control-Allow-Origin", "*")
    handler.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
    handler.send_header("Access-Control-Allow-Headers", "Content-Type")

# ── ABLETON MCP TCP CLIENT ────────────────────────────────────────────────────

def ableton_execute(code: str, timeout: float = 10.0):
    """
    Send a Python code string to Ableton MCP over TCP and return the response.
    Protocol: newline-delimited JSON  { "type": "execute", "code": "..." }
    Response: JSON line with result or error.
    """
    payload = json.dumps({"type": "execute", "code": code}) + "\n"
    try:
        with socket.create_connection((ABLETON_HOST, ABLETON_PORT), timeout=timeout) as s:
            s.sendall(payload.encode("utf-8"))
            s.settimeout(timeout)
            buf = b""
            while True:
                chunk = s.recv(4096)
                if not chunk:
                    break
                buf += chunk
                if b"\n" in buf:
                    break
            line = buf.split(b"\n")[0].decode("utf-8", errors="replace")
            return json.loads(line) if line.strip() else {"ok": True}
    except socket.timeout:
        return {"error": "Ableton MCP timeout"}
    except ConnectionRefusedError:
        return {"error": "Ableton MCP not reachable — is Ableton open with MCP loaded?"}
    except Exception as e:
        return {"error": str(e)}

# ── REQUEST HANDLER ───────────────────────────────────────────────────────────

class ConductorHandler(BaseHTTPRequestHandler):

    def _send_json(self, data, code=200):
        body = json.dumps(data).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        cors_headers(self)
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self.send_response(204)
        cors_headers(self)
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        params = dict(urllib.parse.parse_qsl(parsed.query))

        # ── GET /ping ────────────────────────────────────────────────────────
        if path == "/ping":
            self._send_json({"ok": True, "version": "1.0", "port": BRIDGE_PORT})

        # ── GET /status ──────────────────────────────────────────────────────
        elif path == "/status":
            nlm = notebooklm_path()
            aa = audio_analyzer_path()
            status = {
                "bridge":         "connected",
                "ableton":        "connected" if ableton_connected() else "disconnected",
                "notebooklm":     "ready" if nlm else "not_installed",
                "notebooklm_bin": nlm or "",
                "audio_analyzer": "ready" if aa else "not_installed",
                "audio_analyzer_bin": aa or "",
                "mem0":           "ready",        # bridge can't easily check mem0 MCP
                "pluginbridge":   "check_ableton", # only valid if Ableton connected
            }
            self._send_json(status)

        # ── GET /notebooklm?q=... ────────────────────────────────────────────
        elif path == "/notebooklm":
            q = params.get("q", "").strip()
            if not q:
                return self._send_json({"error": "no query — use ?q=your+question"}, 400)
            nlm = notebooklm_path()
            if not nlm:
                return self._send_json({"error": "NotebookLM CLI not found. Install notebooklm-py or set path in setup."}, 503)
            try:
                result = subprocess.run(
                    [nlm, "ask", q],
                    capture_output=True, text=True, timeout=60
                )
                self._send_json({
                    "ok": True,
                    "result": result.stdout.strip(),
                    "stderr": result.stderr.strip(),
                })
            except subprocess.TimeoutExpired:
                self._send_json({"error": "NotebookLM query timed out (60s)"}, 504)
            except Exception as e:
                self._send_json({"error": str(e)}, 500)

        # ── GET /analyze?path=/tmp/file.wav ──────────────────────────────────
        elif path == "/analyze":
            file_path = params.get("path", "")
            if not file_path:
                return self._send_json({"error": "no path — use ?path=/absolute/path.wav"}, 400)
            if not os.path.exists(file_path):
                return self._send_json({"error": f"file not found: {file_path}"}, 404)
            aa = audio_analyzer_path()
            if not aa:
                return self._send_json({"error": "audio-analyzer CLI not found"}, 503)
            try:
                result = subprocess.run(
                    [aa, file_path],
                    capture_output=True, text=True, timeout=30
                )
                self._send_json({"ok": True, "result": result.stdout.strip()})
            except subprocess.TimeoutExpired:
                self._send_json({"error": "audio-analyzer timed out (30s)"}, 504)
            except Exception as e:
                self._send_json({"error": str(e)}, 500)

        # ── GET /config ──────────────────────────────────────────────────────
        elif path == "/config":
            self._send_json(load_config())

        else:
            self._send_json({"error": f"unknown endpoint: {path}"}, 404)

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        content_len = int(self.headers.get("Content-Length", 0))
        try:
            body = json.loads(self.rfile.read(content_len)) if content_len else {}
        except json.JSONDecodeError:
            body = {}

        # ── POST /ableton ─────────────────────────────────────────────────────
        if path == "/ableton":
            code = body.get("code", "").strip()
            if not code:
                return self._send_json({"error": "no code — send { \"code\": \"song.tempo\" }"}, 400)
            if not ableton_connected():
                return self._send_json({"error": "Ableton MCP not reachable — open Ableton with MCP loaded"}, 503)
            result = ableton_execute(code)
            self._send_json(result)

        # ── POST /config ──────────────────────────────────────────────────────
        elif path == "/config":
            cfg = load_config()
            cfg.update(body)
            save_config(cfg)
            self._send_json({"ok": True, "saved": body})

        else:
            self._send_json({"error": f"unknown endpoint: {path}"}, 404)

    def log_message(self, fmt, *args):
        # Compact log: timestamp + route only
        msg = fmt % args
        print(f"  [{time.strftime('%H:%M:%S')}] {msg}", flush=True)

# ── MAIN ──────────────────────────────────────────────────────────────────────

def main():
    print(f"""
╔══════════════════════════════════════════════╗
║          Conductor Bridge v1.0               ║
║  http://localhost:{BRIDGE_PORT}  ·  Ctrl+C to stop   ║
╠══════════════════════════════════════════════╣
║  /ping        → health check                 ║
║  /status      → all services                 ║
║  /ableton     → execute in Ableton Live      ║
║  /notebooklm  → query NotebookLM             ║
║  /analyze     → audio-analyzer CLI           ║
╚══════════════════════════════════════════════╝
""", flush=True)

    # Check what's available on startup
    ableton_ok = ableton_connected()
    nlm = notebooklm_path()
    aa = audio_analyzer_path()
    print(f"  Ableton MCP (:{ABLETON_PORT}) : {'✅ Connected' if ableton_ok else '⚠️  Not connected — open Ableton'}")
    print(f"  NotebookLM CLI         : {'✅ ' + nlm if nlm else '⚠️  Not found'}")
    print(f"  Audio Analyzer CLI     : {'✅ Found' if aa else '⚠️  Not found'}")
    print()

    server = HTTPServer(("localhost", BRIDGE_PORT), ConductorHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n  Bridge stopped.")
        server.server_close()

if __name__ == "__main__":
    main()
