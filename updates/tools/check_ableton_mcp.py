import socket
import time

ABLETON_HOST = "127.0.0.1"
ABLETON_PORT = 16619

def check_ableton_connection():
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(3)
        sock.connect((ABLETON_HOST, ABLETON_PORT))
        sock.send(b"PING\n")
        resp = sock.recv(1024).decode().strip()
        sock.close()
        if "PONG" in resp:
            print("✅ Ableton Live MCP (TCP 16619) is online