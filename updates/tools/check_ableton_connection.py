import socket
import sys

HOST = "127.0.0.1"  # Localhost for MCP bridge
PORT = 16619        # Ableton Live MCP default port

def test_connection():
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(3)  # 3-second