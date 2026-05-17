# AI Music Production — Reference Doc
> Read this file only when you need the specific section. Not auto-loaded.
> This keeps CLAUDE.md lean. Load it on demand: Read("...docs/CLAUDE-reference.md")

---

## EQ EIGHT — COMPLETE PARAMETER MAP

```
param 0  → Device On         (0=off, 1=on)
param 1  → Output            (normalized 0–1 = -15 to +15 dB)
param 2  → Scale             (1.0 = 100%)
param 3  → Adaptive Q        (0=off, 1=on)

Per band (Band N starts at param 4 + (N-1)*10):
param +0 → Band N On         (0=off, 1=on)
param +1 → Band N Type       (0=HP48, 1=HP12, 2=LoShelf, 3=Bell, 4=Notch, 5=HiShelf, 6=LP12, 7=LP48)
param +2 → Band N Frequency  (normalized — see table below)
param +3 → Band N Gain       (direct dB — e.g. +4dB = 4.0)
param +4 → Band N Q          (0.377 = Q 0.71)
```

**Frequency normalization:** `normalized = (log10(Hz) - 1) / (log10(22050) - 1)`  → divisor = 3.34361
**Gain is always direct dB** — pass as-is: +4dB → 4.0, -6dB → -6.0

| Hz | Normalized | Hz | Normalized |
|---|---|---|---|
| 30 | 0.143 | 500 | 0.480 |
| 40 | 0.180 | 1kHz | 0.598 |
| 70 | 0.253 | 2kHz | 0.689 |
| 80 | 0.270 | 5kHz | 0.782 |
| 100 | 0.300 | 8kHz | 0.834 |
| 200 | 0.387 | 10kHz | 0.855 |
| 300 | 0.428 | 16kHz | 0.906 |

### Common EQ patterns

```python
import math
def nf(hz): return (math.log10(hz)-1)/(math.log10(22050)-1)

eq = song.tracks[0].devices[0]

# HPF at 80Hz (Band 1, HP12)
eq.parameters[4].value = 1.0   # Band 1 On
eq.parameters[5].value = 1.0   # Type: HP12
eq.parameters[6].value = nf(80)
result = "HPF 80Hz set"

# Bell cut at 300Hz, -2.5dB (Band 2)
eq.parameters[14].value = 1.0   # Band 2 On
eq.parameters[15].value = 3.0   # Type: Bell
eq.parameters[16].value = nf(300)
eq.parameters[17].value = -2.5  # Gain
result = "Bell cut set"
```

---

## execute — FULL PATTERNS

```python
# Check session state
[(i, t.name, "MIDI" if t.has_midi_input else "Audio") for i, t in enumerate(song.tracks)]

# Set BPM and key
song.tempo = 110.0; song.root_note = 9; song.scale_name = "Major"
# Root notes: C=0, C#=1, D=2, D#=3, E=4, F=5, F#=6, G=7, G#=8, A=9, A#=10, B=11

# Create and name track
song.create_midi_track(-1); song.tracks[-1].name = "Tumbi"

# Load EQ Eight
load_to(song.tracks[2], browser.audio_effects, "EQ Eight"); result = "done"

# Read device parameters (compact)
[(i, p.name, round(p.value,3)) for i,p in enumerate(song.tracks[0].devices[0].parameters)]

# Delete track (from end to avoid index shift)
song.delete_track(len(song.tracks)-1)

# Clear all MIDI notes from clip
song.tracks[0].clip_slots[0].clip.remove_notes(0, 0, 999, 128)
```

### Reload bridge after editing bridge.py

```bash
# Delete pyc cache then fully restart Ableton
find "/Volumes/T7 Shield/Users/Aditya/Music/Ableton/User Library/Remote Scripts/Ableton_Live_MCP" \
  -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
```
Confirm in log: `(AbletonLiveMCP) Ableton_Live_MCP listening on 127.0.0.1:16619`

---

## SETTING SESSION KEY VIA OSC (AbletonOSC fallback)

```python
import socket, struct
def send_osc_int(path, value):
    def pad(s):
        s = s.encode() + b'\x00'
        while len(s) % 4: s += b'\x00'
        return s
    msg = pad(path) + pad(',i') + struct.pack('>i', value)
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(msg, ('127.0.0.1', 11000))
    sock.close()

send_osc_int('/live/song/set/root_note', 9)   # A Major
send_osc_int('/live/song/set/scale_mode', 0)  # Major
```

### Reload AbletonOSC without restarting Ableton
```bash
python3 -c "
import socket
def send_osc(path):
    def pad(s):
        s = s.encode() + b'\x00'
        while len(s) % 4: s += b'\x00'
        return s
    msg = pad(path) + pad(',')
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(msg, ('127.0.0.1', 11000))
    sock.close()
send_osc('/live/api/reload')
"
```

---

## ABLETONOSC — PATCHES APPLIED

Installed at: `User Library/Remote Scripts/AbletonOSC/`
Backups: `AI MUSIC PRODUCTION/archive/abletonosc-versions/`

**abletonosc/device.py patches:**
- `"is_active"` added to `properties_rw`
- `/live/device/get/parameter/display_value` handler added
- `/live/device/get/parameter/min` and `max` handlers added
- `/live/device/load` — browser search (audio_effects/instruments/midi_effects/plugins)
- `/live/device/delete` — `track.delete_device(device_id)`

**abletonosc/song.py patches:**
- `/live/master_track/get|set/volume`, `panning`
- `/live/return_track/get|set/volume`, `panning`, `name`, `mute`
- `/live/song/get/num_return_tracks`

---

## BSCHOEPKE BRIDGE — PATCHES APPLIED (2026-05-12)

File: `User Library/Remote Scripts/Ableton_Live_MCP/bridge.py`
- `PORT = 8765` → `PORT = 16619`
- `_dispatch()` rewritten — v2 flat `{"code":"..."}` protocol detected before JSON-RPC fallback
- `_run_on_main_v2()` + `_exec_code_v2()` added
- Helper env: `song`, `tracks`, `returns`, `master`, `browser`, `find_track`, `find_item`, `find_items`, `load_to`, `log`, `json`, `time`

---

## 30 BRIDGE TOOLS (accessible via execute)

| Tool | What It Does |
|---|---|
| `get_session_info` | BPM, time sig, tracks, scenes |
| `get_track_info` | Track details, devices, clips |
| `create_midi_track` | Add MIDI track at index |
| `create_audio_track` | Add audio track at index |
| `set_track_name` | Rename any track |
| `set_track_volume` | Volume in dB |
| `set_track_pan` | Panning (-1 to +1) |
| `mute_track` / `unmute_track` | Toggle mute |
| `solo_track` / `unsolo_track` | Toggle solo |
| `arm_track` / `disarm_track` | Toggle record arm |
| `delete_track` | Remove track |
| `add_device` | Load device by name |
| `remove_device` | Remove device from track |
| `set_device_parameter` | Set any parameter by name/index |
| `get_device_parameters` | List all params with values |
| `create_clip` | Create clip in slot |
| `add_notes_to_clip` | Add MIDI notes |
| `set_clip_name` | Rename clip |
| `get_clip_notes` | Read MIDI notes from clip |
| `set_tempo` | Change BPM |
| `start_playback` / `stop_playback` | Transport control |
| `create_scene` | Add new scene |
| `set_scene_name` | Rename scene |
| `fire_scene` | Launch scene |
| `live_eval` | Evaluate Python expression |
| `live_exec` | Execute Python statements |
| `live_agent_audio_tap` | AgentAudioTap control |

---

## JOSEFIGUEREDO ABLETON-MCP — RETIRED

Binary: `/opt/homebrew/bin/ableton-mcp`
To re-enable: `claude mcp add ableton-mcp /opt/homebrew/bin/ableton-mcp`
Patched files were in: `/opt/homebrew/var/pipx/venvs/ableton-mcp/lib/python3.14/site-packages/ableton_mcp/`

---

## NOTEBOOKLM — SOURCE INVENTORY (verified 2026-05-12)

**Ableton / Technical**
- `live12-manual-en.pdf` — Official Ableton Live 12 Manual
- AbletonOSC GitHub docs
- bschoepke MCP: `bridge.py`, `CLAUDE.md`, `server.py`, `README.md`
- josefigueredo: 14 SOURCE_OF_TRUTH files + 4 architecture docs
- mikecfisher LOM: `song.md`, `track.md`, `device.md`, `clip.md`, `rack.md`, `session.md`, `specialized-devices.md`, `views.md`, `browser.md`, `grooves-tuning.md`

**Music Production**
- 257+ docs: orchestration, mixing, Indian music, arrangement, mastering

---

## ADI'S PLUGIN INVENTORY

**Synths:** Omnisphere 3, Serum 2, The Legend HZ, Korg Triton/ARP 2600/MS-20, UHE Zebra 3
**Sampler:** Kontakt 8

**UAD:** 1176 FET, LA-2A, Pultec EQP-1A, HLF-3C, MEQ-5, Pure Plate Reverb, Showtime 64, Century Tube Channel Strip
**FabFilter:** Pro-Q 4, Pro-C 2, Pro-L 2, Pro-R 2, Pro-DS, Saturn 2, Timeless 3
**Waves Ultimate v16:** SSL, API, CLA, H-series, Renaissance + full bundle
**Soundtoys:** Devil-Loc, EchoBoy Jr, Little Microshift, Plate, Radiator
**Valhalla:** VintageVerb, Room, Plate, Shimmer, Delay, Chorus
**iZotope:** Ozone 12
**Other:** Gullfoss, God Particle, Kickstart 2, Shaperbox 3, Sonible Smart:Comp 3, Output Portal, Melodyne 5, Beyerdynamic headphone correction

**Kontakt Libraries:**
- Drums/Perc: Damage 2, Epic Percussion 2 & 3, Session Percussionist, Studio Drummer
- World/Ethnic: NI India, Ethno World 6, Soundiron Tablas
- Strings: Emotional Cello, Emotional Viola, Cinematic Studio Strings, Symphobia 2, Ólafur Arnalds Chamber Evolutions
- Pianos: Alicia's Keys, Claire, Noire
- Bass/Guitar: Session Bassist (Icon/Jam), Session Guitarist (full range)
- Pads/Texture: Omnisphere 3, Frames, Folds, Strands, Void & Vista, Heavyocity Convergence

---

## GENRE LUFS TARGETS

| Genre | LUFS | True Peak | DR |
|---|---|---|---|
| Hindi/Bollywood | -9 to -11 | -1.0 dBTP | 6–8 LU |
| Hindi + Cinematic hybrid | -12 to -14 | -1.0 dBTP | 10–14 LU |
| Cinematic/Film Score | -18 to -23 | -3.0 dBTP | 10–20 LU |
| EDM/Electronic | -7 to -9 | -0.3 dBTP | 4–6 LU |
| Punjabi Pop (commercial) | -9 to -11 | -1.0 dBTP | 6–8 LU |

---

## ADI'S COMPOSITION METHOD

1. **Piano first** — melody at Casio/Yamaha, no structure label yet
2. **Reference study** — 3–5 tight refs, Catalog of Attributes + Avoidance List, then put away
3. **8 Mutation method** — duplicate melody 8×, change ONE parameter each: instrument swap / rhythm shift / one chord / register transposition
4. **3D Depth chart** — Foreground (hook) / Midground (support) / Background (texture)
5. **Sculpt don't build** — stack all mutations, mute/carve to reveal sections
