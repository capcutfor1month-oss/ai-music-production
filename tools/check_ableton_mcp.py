import socket
import time

ABLETON_HOST = "127.0.0.1"
ABLETON_PORT = 16619

def check_ableton_connection():
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(3)
        sock.connect((ABLETON_HOST, ABLETON_PORT))
        # The bridge expects JSON-RPC, but some bridges have a PING/PONG fallback
        # Let's try a simple JSON-RPC call instead if PING doesn't work
        # But for connection check, connect() is often enough
        print("✅ Ableton Live MCP (TCP 16619) is online (Socket Connected)")
        sock.close()
    except Exception as e:
        print(f"❌ Ableton Live MCP (TCP 16619) is offline or unreachable: {e}")

if __name__ == "__main__":
    check_ableton_connection()
