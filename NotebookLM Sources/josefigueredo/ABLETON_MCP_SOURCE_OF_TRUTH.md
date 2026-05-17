# Ableton Live MCP Server - Complete Source of Truth

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Current Implementation Analysis](#current-implementation-analysis)
3. [Core Technologies](#core-technologies)
4. [Architecture Overview](#architecture-overview)
5. [Lessons Learned from Current Implementation](#lessons-learned-from-current-implementation)
6. [Building an MCP Server from Scratch](#building-an-mcp-server-from-scratch)
7. [API Reference](#api-reference)
8. [Best Practices](#best-practices)
9. [Common Pitfalls and Solutions](#common-pitfalls-and-solutions)
10. [Future Enhancements](#future-enhancements)

---

## Executive Summary

### What This Project Achieves
An MCP (Model Context Protocol) server that enables AI agents (like Claude) to control Ableton Live through natural language, transforming music production from manual clicking to conversational creation.

### Key Innovation
Instead of traditional DAW interaction:
```
User → Ableton (manual clicking)
```

This creates an AI-mediated workflow:
```
User → Claude/AI → MCP Server → OSC Protocol → Ableton Live
```

### Current Status
- **Phase 1 Complete**: Working CLI with 12 functional commands
- **Phase 2 In Progress**: MCP server implemented but not fully tested
- **Success Rate**: OSC communication proven, music theory engine working
- **Main Challenge**: No automatic instrument loading (tracks created without sound)

---

## Current Implementation Analysis

### What Works ✅
1. **OSC Communication**: Bidirectional messaging with Ableton Live
2. **Track Management**: Create/delete MIDI tracks programmatically
3. **Clip Creation**: Generate clips with specified length
4. **MIDI Generation**: Add notes to clips with precise timing
5. **Music Theory Engine**: Chord progressions, scales, mathematical melodies
6. **Transport Control**: Play/stop, tempo adjustment

### Known Issues 🔍
1. **No Sound by Default**: MIDI tracks created without instruments
2. **Global Play vs Clip Trigger**: Play command affects transport, not individual clips
3. **Limited Context Awareness**: Server doesn't fully read project state
4. **No Device Management**: Can't load instruments or effects automatically

### Architecture Decisions
- **Language**: Python (better music libraries, simpler OSC integration)
- **Protocol**: OSC over UDP (low latency, standard for music software)
- **MCP Framework**: FastMCP (async support, clean tool definition)
- **Music Theory**: Custom engine (flexibility, no external dependencies)

---

## Core Technologies

### 1. OSC (Open Sound Control)

#### What is OSC?
- Network protocol for real-time musical control
- Successor to MIDI with modern capabilities
- URI-style addressing: `/live/track/set/volume`
- Supports multiple data types (int, float, string, blob)

#### OSC vs MIDI
| Feature | OSC | MIDI |
|---------|-----|------|
| Resolution | 32-bit float | 7-bit (0-127) |
| Addressing | Hierarchical paths | Channel + CC |
| Network | Native UDP/TCP | Requires translation |
| Extensibility | User-defined | Fixed spec |
| Latency | ~1-10ms (network) | <1ms (hardware) |

#### OSC Message Structure
```python
# Basic OSC message
address = "/live/track/set/volume"
args = [track_id, volume_value]  # [0, 0.75]

# Bundle (multiple messages with timestamp)
bundle = OSCBundle()
bundle.add(OSCMessage("/live/clip/fire", [0, 0]))
bundle.add(OSCMessage("/live/song/set/tempo", [120.0]))
```

### 2. AbletonOSC

#### Overview
- MIDI Remote Script for Ableton Live
- Exposes Live's entire Object Model via OSC
- Listens on port 11000, responds on 11001
- Installed in Ableton's Remote Scripts folder

#### Installation Process
```bash
# Windows
%PROGRAMDATA%\Ableton\Live {version}\Resources\MIDI Remote Scripts\

# macOS
/Applications/Ableton Live {version}/Contents/App-Resources/MIDI Remote Scripts/

# Copy AbletonOSC folder to above location
# Restart Ableton
# Enable in Preferences > Link/Tempo/MIDI > Control Surface
```

#### Key Capabilities
- **Read**: Get tempo, track count, clip info, device parameters
- **Write**: Create tracks/clips, set parameters, add MIDI notes
- **Listen**: Subscribe to beat events, parameter changes
- **Control**: Fire clips, control transport, manipulate view

### 3. Ableton Live Object Model

#### Hierarchy
```
Application
└── Song
    ├── Tracks[]
    │   ├── ClipSlots[]
    │   │   └── Clip
    │   │       ├── Notes (MIDI)
    │   │       └── Parameters
    │   ├── Devices[]
    │   │   └── Parameters[]
    │   └── Mixer
    │       ├── Volume
    │       ├── Pan
    │       └── Sends[]
    ├── Scenes[]
    ├── Master Track
    └── Return Tracks[]
```

#### Key Classes

**Song**
- Global project container
- Properties: tempo, time_signature, is_playing
- Methods: create_midi_track(), create_scene(), start_playing()

**Track**
- Audio or MIDI track
- Properties: name, color, volume, mute, solo, arm
- Methods: stop_all_clips(), delete_device()

**Clip**
- Audio or MIDI clip
- Properties: name, length, loop_start, loop_end, pitch
- Methods: fire(), stop(), set_notes(), quantize()

**Device**
- Instrument or effect
- Properties: name, parameters, is_active
- Methods: set_parameter_value()

### 4. MCP (Model Context Protocol)

#### What is MCP?
- Protocol for AI agents to interact with external systems
- Provides tool discovery and execution framework
- Handles the "agentic loop" automatically
- Supports async operations

#### MCP Server Structure
```python
from mcp.server import FastMCP

app = FastMCP("server-name")

@app.tool()
async def tool_name(param: type) -> result_type:
    """Tool description for AI"""
    return result
```

#### The Agentic Loop
```python
# What MCP handles automatically:
while True:
    user_input = get_user_input()
    ai_response = llm.process(user_input)
    
    if ai_response.needs_tool:
        tool_result = execute_tool(ai_response.tool_call)
        ai_response = llm.process_result(tool_result)
    
    return ai_response
```

---

## Architecture Overview

### System Architecture
```
┌─────────────────┐
│   User Input    │
│  (Natural Lang) │
└────────┬────────┘
         │
┌────────▼────────┐
│   Claude/AI     │
│   (Reasoning)   │
└────────┬────────┘
         │
┌────────▼────────┐
│   MCP Server    │
│    (Python)     │
└────────┬────────┘
         │
┌────────▼────────┐
│  OSC Protocol   │
│  (UDP:11000)    │
└────────┬────────┘
         │
┌────────▼────────┐
│   AbletonOSC    │
│ (Remote Script) │
└────────┬────────┘
         │
┌────────▼────────┐
│  Ableton Live   │
│   (DAW Core)    │
└─────────────────┘
```

### Data Flow Example
```python
# User: "Create a lo-fi beat in C minor"

# 1. Claude interprets intent
intent = {
    "genre": "lo-fi",
    "key": "C",
    "scale": "minor",
    "tempo": 85,  # lo-fi convention
    "elements": ["chords", "melody", "drums"]
}

# 2. Claude calls MCP tools
await set_tempo(85)
await chord_progression("C", "pop", "minor", 4)
await phi_melody("C", "pentatonic_minor", 4, 6)
await add_hihats(0, 0, 4)

# 3. MCP Server sends OSC messages
osc_client.send("/live/song/set/tempo", [85])
osc_client.send("/live/song/create_midi_track", [-1])
osc_client.send("/live/clip/add/notes", [track_id, scene_id] + notes)

# 4. AbletonOSC executes in Live
song.tempo = 85
track = song.create_midi_track(-1)
clip.set_notes(notes)
```

---

## Lessons Learned from Current Implementation

### 1. Successes ✅

#### OSC Communication Works Reliably
```python
# Simple and effective pattern
def send_and_wait(address, args=[], wait_time=0.3):
    osc_client.send_message(address, args)
    time.sleep(wait_time)  # Give Ableton time to process
    return responses.get(address)
```

#### Music Theory Engine is Solid
```python
# Reusable scale/chord generation
SCALES = {
    'major': [0, 2, 4, 5, 7, 9, 11],
    'minor': [0, 2, 3, 5, 7, 8, 10],
    'dorian': [0, 2, 3, 5, 7, 9, 10],
    # ... more scales
}

def get_chord_from_degree(degree, root_note, scale_type, octave):
    # Automatic harmonization based on scale
    scale = get_scale(root_note, scale_type, octave)
    # Build chord from scale degrees
```

#### Mathematical Melodies Create Interest
```python
# Golden ratio melody generation
phi = (1 + math.sqrt(5)) / 2  # 1.618...
# Use phi digits to select scale degrees
# Creates naturally pleasing patterns
```

### 2. Failures and Solutions 🔧

#### Problem: No Sound from Created Tracks
**Issue**: MIDI tracks created without instruments
```python
# Current: Creates empty MIDI track
osc_client.send_message("/live/song/create_midi_track", [-1])
# Result: Silent track (no instrument)
```

**Solution**: Auto-load default instrument
```python
# Future implementation
async def create_midi_track_with_instrument(instrument="Operator"):
    # Create track
    track_id = await create_midi_track()
    # Load instrument
    await load_device(track_id, instrument)
    return track_id
```

#### Problem: Can't Trigger Individual Clips
**Issue**: Play command starts global transport
```python
# Current: Starts entire song
osc_client.send_message("/live/song/start_playing", [])
```

**Solution**: Use clip firing
```python
# Better: Fire specific clip
osc_client.send_message("/live/clip/fire", [track_id, scene_id])
```

#### Problem: Limited Context Awareness
**Issue**: Server doesn't know project state
```python
# Current: Blind creation
await create_midi_track()  # Don't know if tracks exist
```

**Solution**: Read state before acting
```python
# Better: Check first
state = await get_project_state()
if state["num_tracks"] == 0:
    await create_midi_track()
```

### 3. Critical Insights 💡

#### Timing Matters
```python
# Bad: No delay between operations
osc_client.send_message("/live/song/create_midi_track", [-1])
osc_client.send_message("/live/clip_slot/create_clip", [0, 0, 4])
# Clip creation fails - track doesn't exist yet

# Good: Allow processing time
osc_client.send_message("/live/song/create_midi_track", [-1])
time.sleep(0.3)  # Critical delay
osc_client.send_message("/live/clip_slot/create_clip", [0, 0, 4])
```

#### MIDI Note Format is Specific
```python
# OSC note format: [pitch, start, duration, velocity, muted]
# Must be flat list, not nested
notes = []
for pitch, start, dur, vel in melody:
    notes.extend([pitch, start, dur, vel, False])
# Send as: [track, scene] + notes
```

#### Index Management is Crucial
```python
# Deleting tracks changes indices
tracks_to_delete = [1, 3, 5]
# Must delete from highest to lowest
for track_id in sorted(tracks_to_delete, reverse=True):
    delete_track(track_id)
```

---

## Building an MCP Server from Scratch

### Step 1: Environment Setup

```bash
# Create project directory
mkdir ableton-mcp-server
cd ableton-mcp-server

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install mcp python-osc asyncio
```

### Step 2: Basic MCP Server Structure

```python
# server.py
import asyncio
from mcp.server import FastMCP
from pythonosc import udp_client
import time

# Configuration
OSC_IP = "127.0.0.1"
SEND_PORT = 11000
RECEIVE_PORT = 11001

# Initialize
app = FastMCP("ableton-mcp")
osc_client = udp_client.SimpleUDPClient(OSC_IP, SEND_PORT)

# Global response storage
responses = {}

def send_osc(address, args=[]):
    """Send OSC message to Ableton"""
    osc_client.send_message(address, args)
    time.sleep(0.1)  # Allow processing time

@app.tool()
async def test_connection() -> str:
    """Test connection to Ableton Live"""
    send_osc("/live/test")
    return "Connection test sent"

async def main():
    await app.run_stdio_async()

if __name__ == "__main__":
    asyncio.run(main())
```

### Step 3: Core Tools Implementation

```python
# Core transport controls
@app.tool()
async def set_tempo(bpm: float) -> str:
    """
    Set project tempo in BPM
    
    Musical conventions:
    - Lo-fi: 70-90 BPM
    - Hip-hop: 85-95 BPM  
    - House: 120-130 BPM
    - DnB: 160-180 BPM
    """
    send_osc("/live/song/set/tempo", [bpm])
    return f"Set tempo to {bpm} BPM"

@app.tool()
async def play() -> str:
    """Start playback"""
    send_osc("/live/song/start_playing")
    return "Started playback"

@app.tool()
async def stop() -> str:
    """Stop playback"""
    send_osc("/live/song/stop_playing")
    return "Stopped playback"

# Track management
@app.tool()
async def create_midi_track(name: str = None) -> dict:
    """
    Create a new MIDI track
    
    Args:
        name: Optional track name
    
    Returns:
        Dictionary with track_id and status
    """
    # Get current track count for ID
    send_osc("/live/song/get/num_tracks")
    time.sleep(0.2)
    
    # Create track
    send_osc("/live/song/create_midi_track", [-1])
    time.sleep(0.3)
    
    # Set name if provided
    if name:
        # Assumes track was created at end
        send_osc("/live/track/set/name", [track_id, name])
    
    return {"track_id": track_id, "status": "created"}
```

### Step 4: MIDI Note Generation

```python
@app.tool()
async def add_notes(
    track_id: int,
    scene_id: int,
    notes: list,
    clip_length: float = 4.0
) -> str:
    """
    Add MIDI notes to a clip
    
    Args:
        track_id: Track index (0-based)
        scene_id: Scene/slot index (0-based)
        notes: List of note dicts with:
            - pitch: MIDI number (60=middle C)
            - start: Start time in beats
            - duration: Length in beats
            - velocity: 0-127
        clip_length: Clip length in bars
    
    Example:
        notes = [
            {"pitch": 60, "start": 0, "duration": 1, "velocity": 90},
            {"pitch": 64, "start": 1, "duration": 1, "velocity": 90}
        ]
    """
    # Create clip if needed
    send_osc("/live/clip_slot/create_clip", 
             [track_id, scene_id, clip_length])
    time.sleep(0.3)
    
    # Convert notes to OSC format
    osc_notes = []
    for note in notes:
        osc_notes.extend([
            note["pitch"],
            note["start"], 
            note["duration"],
            note.get("velocity", 90),
            False  # muted
        ])
    
    # Send notes
    send_osc("/live/clip/add/notes", 
             [track_id, scene_id] + osc_notes)
    
    return f"Added {len(notes)} notes to track {track_id}"
```

### Step 5: Context Awareness Tools

```python
@app.tool()
async def get_project_state() -> dict:
    """
    Get current Ableton project state
    
    Returns complete project overview including:
    - Tempo and time signature
    - All tracks with names and types
    - Clip information per track
    - Device information
    """
    state = {
        "tempo": None,
        "tracks": [],
        "scenes": []
    }
    
    # Get tempo
    send_osc("/live/song/get/tempo")
    # Wait and collect response
    
    # Get tracks
    send_osc("/live/song/get/num_tracks")
    # Process each track
    
    return state

@app.tool()
async def analyze_track(track_id: int) -> dict:
    """
    Analyze a specific track
    
    Returns:
        - Track name and type
        - Clips with their content
        - Devices loaded
        - Current settings (volume, pan, etc)
    """
    analysis = {}
    
    # Get track info
    send_osc(f"/live/track/get/name", [track_id])
    send_osc(f"/live/track/get/has_midi_input", [track_id])
    
    # Check for clips
    for scene_id in range(8):  # Check first 8 scenes
        send_osc("/live/clip_slot/get/has_clip", 
                [track_id, scene_id])
    
    return analysis
```

### Step 6: Music Theory Integration

```python
# music_theory.py
class MusicTheory:
    """Music theory engine for intelligent generation"""
    
    NOTES = {
        'C': 0, 'C#': 1, 'Db': 1,
        'D': 2, 'D#': 3, 'Eb': 3,
        'E': 4, 'F': 5, 'F#': 6,
        'Gb': 6, 'G': 7, 'G#': 8,
        'Ab': 8, 'A': 9, 'A#': 10,
        'Bb': 10, 'B': 11
    }
    
    SCALES = {
        'major': [0, 2, 4, 5, 7, 9, 11],
        'minor': [0, 2, 3, 5, 7, 8, 10],
        'dorian': [0, 2, 3, 5, 7, 9, 10],
        'phrygian': [0, 1, 3, 5, 7, 8, 10],
        'lydian': [0, 2, 4, 6, 7, 9, 11],
        'mixolydian': [0, 2, 4, 5, 7, 9, 10],
        'pentatonic_major': [0, 2, 4, 7, 9],
        'pentatonic_minor': [0, 3, 5, 7, 10]
    }
    
    @classmethod
    def note_to_midi(cls, note_name, octave=4):
        """Convert note name to MIDI number"""
        return cls.NOTES[note_name] + (octave * 12) + 12
    
    @classmethod
    def get_scale(cls, root, scale_type='major', octave=4):
        """Get MIDI notes for a scale"""
        root_midi = cls.note_to_midi(root, octave)
        intervals = cls.SCALES[scale_type]
        return [root_midi + i for i in intervals]
    
    @classmethod
    def generate_chord_progression(cls, key, progression_type, bars=4):
        """Generate chord progression"""
        progressions = {
            'pop': [1, 5, 6, 4],  # I-V-vi-IV
            'jazz': [2, 5, 1, 1],  # ii-V-I-I
            'blues': [1, 1, 4, 4, 1, 1, 5, 4, 1, 5]
        }
        # Implementation here
        return chord_notes
```

### Step 7: Advanced Generation Tools

```python
@app.tool()
async def create_chord_progression(
    key: str,
    style: str = "pop",
    scale: str = "major",
    bars: int = 4
) -> dict:
    """
    Generate a complete chord progression
    
    Styles:
    - pop: I-V-vi-IV (catchy, mainstream)
    - jazz: ii-V-I (sophisticated)
    - blues: 12-bar blues
    - lofi: Minor with 7ths
    
    Returns:
        Track ID and clip information
    """
    # Create track
    track_info = await create_midi_track("Chords")
    track_id = track_info["track_id"]
    
    # Generate chords using music theory
    chords = MusicTheory.generate_chord_progression(
        key, style, scale, bars
    )
    
    # Convert to notes
    notes = []
    for chord_time, chord_pitches in chords:
        for pitch in chord_pitches:
            notes.append({
                "pitch": pitch,
                "start": chord_time,
                "duration": 2.0,  # Half note
                "velocity": 80
            })
    
    # Add to track
    await add_notes(track_id, 0, notes, bars)
    
    return {
        "track_id": track_id,
        "style": style,
        "key": key,
        "bars": bars
    }

@app.tool()
async def create_drum_pattern(
    style: str = "basic",
    bars: int = 4
) -> dict:
    """
    Create drum pattern
    
    Styles:
    - basic: Four on floor
    - hiphop: Boom bap
    - trap: Hi-hat rolls
    - dnb: Breakbeat
    """
    patterns = {
        "basic": {
            "kick": [0, 1, 2, 3],  # Every beat
            "snare": [1, 3],       # Beats 2 and 4
            "hihat": list(range(0, 16, 1))  # 16ths
        },
        "hiphop": {
            "kick": [0, 2.5],
            "snare": [1, 3],
            "hihat": [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5]
        }
    }
    
    # Create drum track
    track_info = await create_midi_track("Drums")
    
    # Generate pattern
    pattern = patterns.get(style, patterns["basic"])
    notes = []
    
    # Convert pattern to notes
    for instrument, beats in pattern.items():
        pitch = {"kick": 36, "snare": 38, "hihat": 42}[instrument]
        for beat in beats:
            for bar in range(bars):
                notes.append({
                    "pitch": pitch,
                    "start": beat + (bar * 4),
                    "duration": 0.25,
                    "velocity": 90
                })
    
    await add_notes(track_info["track_id"], 0, notes, bars)
    
    return {
        "track_id": track_info["track_id"],
        "style": style,
        "bars": bars
    }
```

### Step 8: MCP Configuration

```json
// Claude Desktop config
// ~/.config/claude/claude_desktop_config.json
{
  "mcpServers": {
    "ableton": {
      "command": "python",
      "args": ["C:/path/to/ableton-mcp/server.py"],
      "env": {
        "PYTHONPATH": "C:/path/to/ableton-mcp"
      }
    }
  }
}
```

---

## API Reference

### OSC Commands Reference

#### Song/Transport
```python
# Playback control
/live/song/start_playing        []
/live/song/stop_playing         []
/live/song/continue_playing     []

# Tempo and time
/live/song/set/tempo           [float: bpm]
/live/song/get/tempo           [] -> [float: bpm]
/live/song/set/time_signature  [int: numerator, int: denominator]

# Track creation
/live/song/create_midi_track   [int: index]  # -1 for end
/live/song/create_audio_track  [int: index]
/live/song/delete_track        [int: track_id]

# Scene control
/live/song/create_scene        [int: index]
/live/song/delete_scene        [int: scene_id]
```

#### Track Control
```python
# Properties
/live/track/get/name           [int: track_id] -> [str: name]
/live/track/set/name           [int: track_id, str: name]
/live/track/get/color          [int: track_id] -> [int: color]
/live/track/set/color          [int: track_id, int: color]

# Mixer
/live/track/get/volume         [int: track_id] -> [float: 0-1]
/live/track/set/volume         [int: track_id, float: 0-1]
/live/track/get/panning        [int: track_id] -> [float: -1 to 1]
/live/track/set/panning        [int: track_id, float: -1 to 1]

# States
/live/track/get/mute           [int: track_id] -> [bool]
/live/track/set/mute           [int: track_id, bool]
/live/track/get/solo           [int: track_id] -> [bool]
/live/track/set/solo           [int: track_id, bool]
/live/track/get/arm            [int: track_id] -> [bool]
/live/track/set/arm            [int: track_id, bool]
```

#### Clip Control
```python
# Clip management
/live/clip_slot/create_clip    [int: track, int: scene, float: length]
/live/clip_slot/delete_clip    [int: track, int: scene]
/live/clip_slot/get/has_clip   [int: track, int: scene] -> [bool]

# Playback
/live/clip/fire                [int: track, int: scene]
/live/clip/stop                [int: track, int: scene]

# Properties
/live/clip/get/name            [int: track, int: scene] -> [str]
/live/clip/set/name            [int: track, int: scene, str: name]
/live/clip/get/length          [int: track, int: scene] -> [float: bars]
/live/clip/set/loop_start      [int: track, int: scene, float: beats]
/live/clip/set/loop_end        [int: track, int: scene, float: beats]

# MIDI notes
/live/clip/add/notes           [int: track, int: scene, ...notes]
# Note format: [pitch, start, duration, velocity, muted] * n
/live/clip/get/notes           [int: track, int: scene] -> [notes]
/live/clip/remove/notes        [int: track, int: scene, ...notes]
```

#### Device Control
```python
# Device management  
/live/track/get/num_devices    [int: track] -> [int: count]
/live/device/get/name          [int: track, int: device] -> [str]
/live/device/get/parameters    [int: track, int: device] -> [list]

# Parameter control
/live/device/get/parameter     [int: track, int: device, int: param]
/live/device/set/parameter     [int: track, int: device, int: param, float: value]
```

---

## Best Practices

### 1. Timing and Synchronization

#### Always Add Delays
```python
# Bad: Race condition
osc_client.send_message("/live/song/create_midi_track", [-1])
osc_client.send_message("/live/clip_slot/create_clip", [0, 0, 4])

# Good: Allow processing time
osc_client.send_message("/live/song/create_midi_track", [-1])
time.sleep(0.3)  # Critical!
osc_client.send_message("/live/clip_slot/create_clip", [0, 0, 4])
```

#### Use Confirmation Patterns
```python
async def create_track_confirmed():
    """Create track and verify it exists"""
    # Get initial count
    initial_count = await get_track_count()
    
    # Create track
    send_osc("/live/song/create_midi_track", [-1])
    time.sleep(0.3)
    
    # Verify creation
    new_count = await get_track_count()
    if new_count > initial_count:
        return new_count - 1  # Return new track ID
    else:
        raise Exception("Track creation failed")
```

### 2. Error Handling

#### Implement Retries
```python
async def robust_send(address, args, max_retries=3):
    """Send with retry logic"""
    for attempt in range(max_retries):
        try:
            send_osc(address, args)
            # Check for response if applicable
            return True
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            await asyncio.sleep(0.5 * (attempt + 1))
```

#### Validate Input
```python
@app.tool()
async def set_tempo(bpm: float) -> str:
    """Set tempo with validation"""
    # Validate range
    if not 20 <= bpm <= 999:
        return f"Invalid BPM {bpm}, must be 20-999"
    
    # Validate type
    if not isinstance(bpm, (int, float)):
        return "BPM must be a number"
    
    send_osc("/live/song/set/tempo", [float(bpm)])
    return f"Set tempo to {bpm} BPM"
```

### 3. State Management

#### Track Project State
```python
class ProjectState:
    """Maintain project state cache"""
    def __init__(self):
        self.tracks = []
        self.tempo = 120
        self.last_update = None
    
    async def refresh(self):
        """Update state from Ableton"""
        self.tempo = await get_tempo()
        self.tracks = await get_all_tracks()
        self.last_update = time.time()
    
    def needs_refresh(self, max_age=5):
        """Check if state is stale"""
        if not self.last_update:
            return True
        return time.time() - self.last_update > max_age
```

### 4. Musical Intelligence

#### Use Genre Conventions
```python
GENRE_DEFAULTS = {
    "lofi": {
        "tempo": 75,
        "scale": "minor",
        "progression": "pop",
        "swing": 0.15
    },
    "house": {
        "tempo": 128,
        "scale": "major",
        "progression": "basic",
        "swing": 0.0
    },
    "jazz": {
        "tempo": 120,
        "scale": "dorian",
        "progression": "jazz",
        "swing": 0.33
    }
}

async def create_genre_beat(genre: str):
    """Create beat with genre-appropriate settings"""
    defaults = GENRE_DEFAULTS.get(genre, {})
    await set_tempo(defaults.get("tempo", 120))
    # Apply other conventions
```

### 5. Tool Documentation

#### Write Clear Descriptions
```python
@app.tool()
async def create_chord_progression(
    key: str,
    style: str = "pop",
    bars: int = 4
) -> dict:
    """
    Generate chord progression in specified key and style.
    
    Creates a new MIDI track with chord progression based on
    music theory. Automatically harmonizes based on scale.
    
    Args:
        key: Root note (C, D, E, F, G, A, B, with # or b)
        style: Progression style
            - pop: I-V-vi-IV (catchy, mainstream)
            - jazz: ii-V-I (sophisticated, complex)
            - blues: 12-bar blues pattern
            - minor: i-iv-V-i (dark, emotional)
        bars: Number of bars to generate (default 4)
    
    Returns:
        Dictionary with track_id and clip details
    
    Examples:
        >>> create_chord_progression("C", "pop", 4)
        {"track_id": 0, "clip_id": 0, "bars": 4}
    """
    # Implementation
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Silent Tracks
**Problem**: Created MIDI tracks have no sound
```python
# Creates track without instrument
await create_midi_track()
# Result: Silent even with MIDI notes
```

**Solution**: Load default instrument
```python
async def create_track_with_instrument(name="New Track"):
    track_id = await create_midi_track(name)
    # Load a default instrument
    await load_device(track_id, "Operator")  # Or any default
    return track_id
```

### Pitfall 2: Index Confusion
**Problem**: Track indices change when deleting
```python
# Have tracks [0, 1, 2, 3]
delete_track(1)
# Now track 2 becomes track 1, track 3 becomes track 2
```

**Solution**: Delete in reverse order
```python
tracks_to_delete = [1, 2, 3]
for track_id in sorted(tracks_to_delete, reverse=True):
    await delete_track(track_id)
```

### Pitfall 3: Clip Creation Failures
**Problem**: Clip creation on non-existent track
```python
# Track 5 doesn't exist
await create_clip(5, 0, 4)  # Fails silently
```

**Solution**: Verify track exists
```python
async def safe_create_clip(track_id, scene_id, length):
    track_count = await get_track_count()
    if track_id >= track_count:
        raise ValueError(f"Track {track_id} doesn't exist")
    return await create_clip(track_id, scene_id, length)
```

### Pitfall 4: OSC Message Format
**Problem**: Wrong note format
```python
# Wrong: Nested lists
notes = [[60, 0, 1, 90, False], [64, 1, 1, 90, False]]
send_osc("/live/clip/add/notes", [0, 0, notes])  # Fails
```

**Solution**: Flatten note list
```python
# Correct: Flat list
notes = []
for pitch, start, duration, velocity in melody:
    notes.extend([pitch, start, duration, velocity, False])
send_osc("/live/clip/add/notes", [0, 0] + notes)
```

### Pitfall 5: No Response Handling
**Problem**: Sending without checking response
```python
send_osc("/live/song/get/tempo")
# No way to get the result
```

**Solution**: Implement response listener
```python
class OSCHandler:
    def __init__(self):
        self.responses = {}
        self.setup_listener()
    
    def handle_response(self, address, *args):
        self.responses[address] = args
    
    async def query(self, address, args=[]):
        self.responses[address] = None
        send_osc(address, args)
        
        # Wait for response
        for _ in range(10):  # 1 second timeout
            if self.responses[address] is not None:
                return self.responses[address]
            await asyncio.sleep(0.1)
        
        raise TimeoutError(f"No response for {address}")
```

---

## Future Enhancements

### 1. Advanced Music Generation

#### AI-Powered Composition
```python
@app.tool()
async def generate_melody_from_chords(track_id: int) -> dict:
    """
    Analyze existing chord progression and generate
    matching melody using AI/ML models
    """
    # Get chord notes from track
    chords = await get_clip_notes(track_id, 0)
    
    # Use ML model to generate melody
    # Could integrate with music transformers
    melody = ml_model.generate_melody(chords)
    
    # Create melody track
    return await create_track_with_notes("Melody", melody)
```

#### Style Transfer
```python
@app.tool()
async def apply_style(source_track: int, style: str) -> dict:
    """
    Transform existing music to different style
    Examples: jazz → lofi, pop → classical
    """
    # Analyze source
    notes = await get_clip_notes(source_track, 0)
    
    # Apply style transformation
    transformed = style_engine.transform(notes, style)
    
    return await create_track_with_notes(f"{style} version", transformed)
```

### 2. Intelligent Mixing

#### Auto-Mixing
```python
@app.tool()
async def auto_mix() -> dict:
    """
    Automatically mix all tracks using:
    - EQ curves for frequency separation
    - Compression for dynamics
    - Spatial positioning
    """
    tracks = await get_all_tracks()
    
    for track in tracks:
        # Analyze frequency content
        # Apply EQ to carve space
        # Set appropriate levels
        # Position in stereo field
        pass
    
    return {"status": "mixed", "tracks": len(tracks)}
```

### 3. Project Templates

#### Template System
```python
@app.tool()
async def create_from_template(template: str) -> dict:
    """
    Create complete project from template
    
    Templates:
    - lofi_beat: Drums, bass, chords, melody, effects
    - edm_drop: Buildup, drop, bass, leads
    - jazz_quartet: Piano, bass, drums, sax
    """
    templates = {
        "lofi_beat": {
            "tempo": 75,
            "tracks": [
                {"name": "Drums", "type": "drums", "pattern": "lofi"},
                {"name": "Bass", "type": "bass", "follow": "chords"},
                {"name": "Chords", "type": "chords", "style": "jazz"},
                {"name": "Melody", "type": "melody", "scale": "pentatonic"}
            ],
            "effects": {
                "master": ["Vinyl Distortion", "Reverb"]
            }
        }
    }
    
    # Build from template
    config = templates[template]
    await set_tempo(config["tempo"])
    
    for track_config in config["tracks"]:
        # Create each track with appropriate content
        pass
    
    return {"template": template, "created": True}
```

### 4. Live Performance Features

#### Clip Launching System
```python
@app.tool()
async def create_launch_sequence(
    sequence: list[dict]
) -> dict:
    """
    Create timed clip launching sequence
    
    Example:
        sequence = [
            {"time": 0, "track": 0, "clip": 0},
            {"time": 4, "track": 1, "clip": 0},
            {"time": 8, "track": 2, "clip": 1}
        ]
    """
    # Schedule clip launches
    for event in sequence:
        asyncio.create_task(
            launch_at_time(event["time"], 
                          event["track"], 
                          event["clip"])
        )
    
    return {"sequence": len(sequence), "status": "scheduled"}
```

### 5. Integration Enhancements

#### Sample Management
```python
@app.tool()
async def import_and_slice_sample(
    file_path: str,
    slicing: str = "transient"
) -> dict:
    """
    Import audio sample and slice to MIDI track
    
    Slicing modes:
    - transient: Detect transients
    - bpm: Slice by tempo
    - manual: Specific slice points
    """
    # Would require additional Ableton API access
    pass
```

#### External Plugin Control
```python
@app.tool()
async def control_vst_parameter(
    track: int,
    device: int,
    parameter: str,
    value: float
) -> dict:
    """
    Control VST/AU plugin parameters
    Example: Filter cutoff on Serum
    """
    # Map parameter name to index
    # Send parameter change
    pass
```

---

## Conclusion

### What We've Learned

1. **OSC Works Well**: Reliable, low-latency control of Ableton
2. **Timing is Critical**: Must allow processing time between operations
3. **State Management Matters**: Need to track what exists in project
4. **Music Theory Engine is Valuable**: Enables intelligent generation
5. **MCP Simplifies Agent Creation**: Handles the complex parts automatically

### Key Success Factors

1. **Start Simple**: Basic transport control first, then build up
2. **Test Everything**: Each OSC command needs verification
3. **Document Thoroughly**: AI agents need clear tool descriptions
4. **Handle Errors**: Robust error handling prevents frustration
5. **Think Musically**: Understand conventions for different genres

### Next Steps for a Production System

1. **Implement Device Loading**: Auto-load instruments on track creation
2. **Add Response Handling**: Proper OSC response listener
3. **Build State Cache**: Track project state to avoid redundant queries
4. **Create Test Suite**: Automated testing for all operations
5. **Add Musical Intelligence**: Genre templates, style understanding
6. **Implement Safety**: Undo system, project backup before operations

### Final Architecture Recommendation

```python
# Recommended structure for production
ableton-mcp/
├── server.py           # MCP server entry point
├── osc_handler.py      # OSC communication layer
├── music_theory.py     # Music generation engine
├── project_state.py    # State management
├── tools/
│   ├── transport.py   # Play, stop, tempo
│   ├── tracks.py      # Track management
│   ├── clips.py       # Clip operations
│   ├── devices.py     # Device/plugin control
│   ├── generation.py  # Music generation tools
│   └── mixing.py      # Mix automation
├── templates/          # Project templates
├── tests/             # Test suite
└── config.json        # Configuration
```

This architecture provides:
- **Separation of Concerns**: Each module handles specific functionality
- **Testability**: Easy to test individual components
- **Extensibility**: Simple to add new tools
- **Maintainability**: Clear structure for long-term development

---

**Document Version**: 1.0
**Last Updated**: February 2026
**Status**: Complete Source of Truth for Ableton MCP Development