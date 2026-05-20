# Stem Analysis via MCP — Playback Guide
> For Claude Code and Gemini CLI. Follow this exactly instead of citing technical limitations.

---

## What This Does
Captures individual tracks from Ableton as WAV files and runs deep audio analysis on them — key, BPM, LUFS, dynamics, spectral content, stereo width. Works reliably every time when steps are followed in order.

---

## Tools Required
| Tool | Location |
|---|---|
| `execute()` MCP | Ableton Live MCP (ableton-live-mcp) |
| `agent_audio_tap()` MCP | Same MCP — controls AgentAudioTap M4L device |
| `audio-analyzer-rs` CLI | `AI MUSIC PRODUCTION/audio-analyzer-rs/cli` |

**Pre-check:** AgentAudioTap M4L device must be on the Master track. Confirm with:
```python
execute("[(t.name, d.name) for t in [song.master_track] for d in t.devices]")
# Should show: [('Main', 'AgentAudioTap')]
```

---

## Problems Encountered & How They Were Solved

### Problem 1 — Solo Left On
**What happened:** A previous session had soloed Track 2. When playback started, all other stems were silenced by the solo. Gemini diagnosed this as "Back to Arrangement lock" or "monitoring state" issues — but those were all fine.

**How to catch it first:**
```python
execute("[(t.name, t.solo) for t in song.tracks if t.name != 'CATH VOX']")
# Any track showing True = solo is on = other tracks will be silent
```

**Fix:**
```python
execute("""
for t in song.tracks:
    try:
        t.solo = False
    except:
        pass
"all solos cleared"
""")
```

---

### Problem 2 — AgentAudioTap: Missing `start` Command
**What happened:** Sent `open` → played → `stop`. WAV file was 104 bytes (header only, no audio).

**Root cause:** `open` only ARMS the device. `start` must be called separately to begin actual recording.

**Correct sequence — do not skip any step:**
```
1. open  (arm + set output path)
2. start (begin recording)
3. play  (start Ableton playback)
4. stop  (flush WAV to disk)
5. stop_playing + unsolo
```

---

### Problem 3 — Timeout on Multi-Statement Calls
**What happened:** Combining `song.current_song_time = 16.0; song.tracks[1].solo = True` in one call timed out.

**Fix:** Split into separate `execute()` calls — one statement per call when setting transport position or solo states.

```python
# Do this:
execute("song.current_song_time = 16.0")
execute("song.tracks[1].solo = True; 'ok'")

# Not this (times out):
execute("song.current_song_time = 16.0; song.tracks[1].solo = True")
```

---

## Full Playback + Analysis Workflow

### Step 1 — Pre-flight Checks
```python
# 1a. Check back_to_arranger (must be False)
execute("song.back_to_arranger")

# 1b. Check and clear all solos
execute("""
solos = [(t.name, t.solo) for t in song.tracks if t.name != 'CATH VOX']
active = [s for s in solos if s[1]]
active if active else "all clear"
""")

# 1c. Fix any solos found
execute("""
for t in song.tracks:
    try: t.solo = False
    except: pass
"cleared"
""")

# 1d. Find where clips start
execute("song.tracks[1].arrangement_clips[0].start_time")
# → e.g. 16.0 beats
```

### Step 2 — Capture One Stem

Replace `TRACK_INDEX` with the track number (0-based, skipping group tracks):
- 0 = CATH VOX (group — skip)
- 1 = 2-CAthrien Vox_1
- 2 = 3-CAthrien Vox 2_1
- 3 = 4-CAthrien Main Melody_01_bip_1
- 4 = 5-Harm 1_L_1
- 5 = 6-Harm 1_R_1
- 6 = 7-PB Low_01_bip_1
- 7 = 8-C Melody _01_bip_1

```python
TRACK_INDEX = 1
OUTPUT_WAV  = "/tmp/stem_lead.wav"
CLIP_START  = 16.0   # from Step 1d

# Rewind
execute(f"song.current_song_time = {CLIP_START}")

# Solo the track
execute(f"song.tracks[{TRACK_INDEX}].solo = True; 'soloed'")

# Arm AgentAudioTap
agent_audio_tap("open", path=OUTPUT_WAV)
agent_audio_tap("start")

# Play
execute("song.start_playing()")

# Poll position — wait until ~8 bars captured (8 bars × 4 beats = 32 beats from clip start)
execute("f\"pos={song.current_song_time:.2f}\"")
# Keep polling until position > CLIP_START + 32

# Stop recording and playback
agent_audio_tap("stop")
execute("song.stop_playing()")

# Unsolo
execute(f"song.tracks[{TRACK_INDEX}].solo = False; 'done'")
```

### Step 3 — Analyze the WAV
```bash
"/Volumes/T7 Shield/Users/Aditya/Downloads/AI MUSIC PRODUCTION/audio-analyzer-rs/cli" /tmp/stem_lead.wav
```

**Key outputs to read:**
| Field | What it tells you |
|---|---|
| LUFS Integrated | Overall loudness — compare to target (-14 Spotify, -16 Apple) |
| True Peak | Headroom available |
| Crest Factor | Dynamic range — higher = more peaks, needs compression |
| Spectral Centroid | Brightness center of gravity |
| Frequency Band Energy | Where the energy sits — spot mud (low_mid) or air gaps (brilliance) |
| Percussive ratio | 0 = clean tonal, 1 = noisy/distorted |
| Stereo width | 0 = mono, expected for raw stems |
| Key + confidence | Confirm pitch center |

### Step 4 — Repeat for Each Stem
Run Steps 2–3 for each track index (1–7), saving to different WAV paths:
```
/tmp/stem_lead.wav       → track 1
/tmp/stem_vox2.wav       → track 2
/tmp/stem_melody.wav     → track 3
/tmp/stem_harm_l.wav     → track 4
/tmp/stem_harm_r.wav     → track 5
/tmp/stem_pb_low.wav     → track 6
/tmp/stem_melody2.wav    → track 7
```

---

## What NOT to Do

| Mistake | Why it fails |
|---|---|
| Read `song.master_track.output_meter_left` for levels | Always returns -200dB / silence during playback via API |
| Call `agent_audio_tap("open")` then immediately play without `start` | WAV will be 104 bytes (empty header) |
| Combine multiple statements with `;` in execute() when setting transport | Times out — split into separate calls |
| Diagnose "back_to_arranger" or "monitoring states" without checking solo first | Solo is the most common silent-track cause |
| Use file paths with spaces in audio-analyzer-rs CLI | Copy to /tmp/ first — spaces break the CLI argument parsing |

---

## Current Project: Fir Kyu — Stage 2 Mix
BPM: 125.48 | Key: C Major | Stage: Mixing
Clips start at: **beat 16.0**
Lead vocal LUFS: **-48.7** (very quiet — gain staging needed)
Air gap confirmed: brilliance band (6k–20k) near silent across all stems.
