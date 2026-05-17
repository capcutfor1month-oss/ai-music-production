
import socket
import struct
import time
import sys
import os

# Add the bundled pythonosc to sys.path, relative to this folder.
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(SCRIPT_DIR)
sys.path.append(os.path.join(ROOT_DIR, "machine-assets", "ableton-remote-scripts", "AbletonOSC"))

from pythonosc import osc_message_builder
from pythonosc import udp_client

def get_tempo():
    # Send to AbletonOSC
    client = udp_client.SimpleUDPClient("127.0.0.1", 11000)
    
    # We need to listen for the response. 
    # AbletonOSC sends responses back to the source port.
    # So we should use a fixed port for our socket if we want to be sure,
    # or just listen on the port we sent from.
    
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind(("127.0.0.1", 11001)) 
    sock.settimeout(2.0)
    
    # Manually build and send OSC message
    def build_osc_message(path, args):
        builder = osc_message_builder.OscMessageBuilder(address=path)
        for arg in args:
            builder.add_arg(arg)
        return builder.build().dgram

    msg = build_osc_message("/live/song/get/tempo", [])
    # Send to 11000
    temp_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    temp_sock.sendto(msg, ("127.0.0.1", 11000))
    temp_sock.close()
    
    try:
        data, addr = sock.recvfrom(1024)
        # Parse the response. It should be /live/song/get/tempo <float>
        # Very simple parsing for this specific case:
        # OSC message: [address][0][tags][0][data]
        # /live/song/get/tempo is 20 chars -> padded to 24
        # tags: ,f -> padded to 4
        # data: 4 bytes float
        if data.startswith(b"/live/song/get/tempo"):
            # The float is at the end
            tempo_bytes = data[-4:]
            tempo = struct.unpack(">f", tempo_bytes)[0]
            print(f"BPM: {tempo}")
        else:
            print(f"Unexpected response: {data}")
    except socket.timeout:
        print("Timeout waiting for AbletonOSC response")
    finally:
        sock.close()

if __name__ == "__main__":
    get_tempo()
