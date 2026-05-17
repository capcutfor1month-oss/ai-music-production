# AI Music Production — Session Context (Gemini)
> Load this at the start of every Gemini session: read this file first.
> Full reference (EQ maps, patches, retired tools): `docs/CLAUDE-reference.md`

---

## BEHAVIOR — READ FIRST

**Never say "I can't do that."** Research first, then execute.

### Session Start — Mandatory Check

At the start of every session:
1. Read `CURRENT PROJECT STATE.md`
2. Check if `Current Stage:` has a value and `Project Name:` is filled

**If empty / no stage set → ask Stage 0 questions before any production work:**
> - What's the emotion / mood of this song?
> - Tempo and key (or leave open for now)?
> - Any reference artists or songs?
> - What stage are we at? (Vision / Production / Mixing / Master)

**If stage is already saved → resume from that state. Do not re-ask questions already answered.**

Do NOT compose, program MIDI, load instruments, or touch Ableton until Stage 0 is confirmed.

---

### Research-First (mandatory before any instrument/production task)
1. IDENTIFY — what instrument or concept?
2. READ — find the source file below and read it directly
3. EXTRACT — pull exact numbers (velocity, timing, Hz)
4. EXECUTE — MCP calls / bash commands with those exact values
5. VERIFY

### Source File Map
| Task | File |
|---|---|
| Strings, brass, woodwinds, any orchestral | `INSTRUMENT_TECHNIQUES_SOURCE_OF_TRUTH.md` |
| Drums, dhol, tabla, any rhythm | `INSTRUMENT_TECHNIQUES_SOURCE_OF_TRUTH.md` + `RHYTHMS_SOURCE_OF_TRUTH.md` |
| Piano, pads, guitar, bass, vocal | `INSTRUMENT_TECHNIQUES_SOURCE_OF_TRUTH.md` |
| EQ, compression, mixing | `MIX_MASTERING_SOURCE_OF_TRUTH.md` |
| Song structure, arrangement | `SONG_STRUCTURE_ARRANGEMENT_SOURCE_OF_TRUTH.md` |
| Emotion, micro-timing, feel | `MUSICAL_EXPRESSION_SOURCE_OF_TRUTH.md` |
| Theory, scales, chords | `MUSIC_THEORY_SOURCE_OF_TRUTH.md` |
| Rhythms, Indian talas | `RHYTHMS_SOURCE_OF_TRUTH.md` |
| Genre matching | `GENRE_ANALYSIS_SOURCE_OF_TRUTH.md` |

All files: `/Volumes/T7 Shield/Users/Aditya/Downloads/AI MUSIC PRODUCTION/NotebookLM Sources/josefigueredo/`
Indian instruments: also read `NotebookLM Sources/Indian Music/` PDFs.

---

## WHO ADI IS

Stage 3 diploma student, Mumbai. MacBook M4, 24GB RAM.
Default current Mac path: `/Volumes/T7 Shield/Users/Aditya/`
If this folder has moved, treat the folder containing `GEMINI.md` as `AI_MUSIC_ROOT` and resolve local files relative to it. See `PORTABILITY.md`.
Primary DAW: Logic Pro 12.2. AI control: Ableton Live 12.4.
References: Diljit Dosanjh, A.R. Rahman, Arijit Singh, Hans Zimmer.

---

## PIPELINE & STARTUP

```
Ableton Live 12.4 → TCP 16619 → Ableton_Live_MCP (bschoepke, patched)
→ /opt/homebrew/bin/ableton-live-mcp
+ AbletonOSC fallback    (UDP 11000, Control Surface 2)
+ NotebookLM CLI         (/opt/homebrew/var/pipx/venvs/notebooklm-py/bin/notebooklm ask "...")
+ audio-analyzer MCP     (Rust binary, .mcp.json — key/BPM/LUFS/stereo)
+ agent-memory MCP       (Mem0, .mcp.json — Gemini-powered cross-session memory)
+ Basic Pitch CLI        (basic-pitch — audio→MIDI transcription, onnx backend)
+ PluginBridge MCP       (VST3/AU plugin host, port 16620 — third-party plugin param control)
```

**Startup:** Prefs → Control Surface 1 = Ableton_Live_MCP | CS 2 = AbletonOSC (optional)
**Stale MCP:** `pkill -f ableton-live-mcp` → reconnect
**PluginBridge:** Load the VST3 on any track in Ableton → select channel name → pick plugin → MCP auto-connects on port 16620

---

## MCP TOOLS (14 total)

| Tool | What it does |
|---|---|
| `execute(code)` | Run Python in Ableton LOM |
| `api(class_name)` | Browse Live API reference |
| `search_api(query)` | Search API by keyword |
| `agent_audio_tap(cmd, path)` | Control AgentAudioTap M4L (open/start/stop/status) |
| `analyze_spectrum(file, bands=24)` | FFT on WAV → bands[], summary, peak, clashes |
| `audio_analyzer` (MCP) | Rust: key, BPM, LUFS, stereo width, dynamics, section boundaries — 1.4s on 48s WAV |
| `memory_search(query)` | Search Adi's past production decisions via Mem0 |
| `memory_add(text)` | Save a production decision to Mem0 for future sessions |
| **PluginBridge tools** | **Load PluginBridge VST3 on a track first — then these work:** |
| `list_instances()` | List all PluginBridge instances by channel name → `["Vocal Bus", "Drum Bus"]` |
| `list_plugins(track)` | List plugins loaded on a PluginBridge instance |
| `search_param(track, plugin, keyword)` | Find plugin params by name → returns index + current value |
| `get_params(track, plugin, [ids])` | Get current values for specific param IDs |
| `set_params(track, plugin, {id: val})` | Set params by ID — batch, normalized 0.0–1.0 |
| `get_analysis(track)` | Real-time per-track: LUFS, true peak, 7-band EQ, stereo width, brightness |

**When to use PluginBridge vs audio-analyzer:**
- `audio_analyzer` MCP → file-based, full song analysis, key/BPM detection
- PluginBridge `get_analysis` → live per-track, no file needed, use during mixing
- PluginBridge `set_params` → the ONLY way to control Pro-Q 4, Serum 2, and other third-party plugins

---

## execute — RULES

- **Reads:** `song.tempo` / `len(song.tracks)` / `song.tracks[0].name`
- **Writes:** `song.tempo = 110.0` / `song.tracks[0].name = "Kick"`
- **Multi-step:** use semicolons or `result =` to return data
- **BrowserItem:** always end `load_to(...)` calls with `result = "done"`
- **10s timeout:** one track at a time — no bulk for-loops
- **Keep results small:** return only what you need, not full device dumps

```python
# Good — compact
[(t.name, t.output_routing_type.display_name) for t in song.tracks]

# Bad — bloated
[(p.name, p.value, p.min, p.max) for p in song.tracks[0].devices[0].parameters]
```

---

## LOM HARD LIMITS

| Limit | Detail |
|---|---|
| **No GROUP TRACKS via LOM** | `song.create_group_track()` doesn't exist. UI only: Cmd+G. Use Audio bus + routing. |
| **BUS = AUDIO track only** | MIDI bus has `has_audio_input: False` → captures silence |
| **VST3 = 1 param only (LOM)** | Pro-Q 4, Serum 2 knobs unreachable via Ableton LOM. **Use PluginBridge instead — gives full access to all params.** |
| **No `delete_selected_notes()`** | Use `clip.remove_notes(0, 0, clip.length, 128)` |
| **`create_audio_track()` serialization error** | Track IS created. Check `len(song.tracks)` to confirm. |

---

## BUS ROUTING (confirmed patterns)

```python
# Route tracks to a bus
for t in song.tracks:
    if t.name in ["Violin I", "Viola", "Cello"]:
        for rt in t.available_output_routing_types:
            if rt.display_name == "STRINGS BUS":
                t.output_routing_type = rt; break

# Bus monitoring — NO INPUT first, then Monitor:In
# ⚠️ Reverse order = Focusrite feedback loop
for t in song.tracks:
    if t.name in ["DRUM BUS","STRINGS BUS","GUITAR BUS","LEAD VOX BUS","BV BUS"]:
        for rt in t.available_input_routing_types:
            if rt.display_name == "No Input":
                t.input_routing_type = rt; break
        t.current_monitoring_state = 0  # 0=In, 1=Auto, 2=Off
```

---

## AGENT AUDIO TAP

Device: `User Library/Presets/Audio Effects/Max Audio Effect/AgentAudioTap.amxd`
"no function /agent_audio_tap" in Max = cosmetic OSC error. File polling still works — ignore it.

```bash
# Capture N bars, auto-stops Ableton when done
"/Volumes/T7 Shield/Users/Aditya/Downloads/AI MUSIC PRODUCTION/tools/capture_strings.sh" 8
# → /tmp/strings_tap.wav ready for analyze_spectrum or audio_analyzer
```

Manual: `agent_audio_tap("open", "/tmp/tap.wav")` → play → `agent_audio_tap("stop")` → analyze

---

## AUDIO ANALYZER (Phase 11 — ACTIVE)

Binary: `AI MUSIC PRODUCTION/audio-analyzer-rs/cli` and `mcp-server`

```bash
# Direct CLI use
"/Volumes/T7 Shield/Users/Aditya/Downloads/AI MUSIC PRODUCTION/audio-analyzer-rs/cli" /path/to/file.wav
```

**Outputs in ~1.4s on a 48s file:**
- Key estimation with confidence (e.g., "C major 0.755")
- BPM + beat timestamps
- LUFS (Integrated, True Peak, LRA) + Spotify/Apple/YouTube targets
- Stereo width + phase correlation + mono compatibility
- Spectral centroid/bandwidth/rolloff/flatness + 7 frequency bands
- Percussive vs harmonic ratio (HPSS)
- Section boundary detection

**Use instead of analyze_spectrum when you need:** key, BPM, LUFS, stereo, dynamics, or section analysis.

---

## PLUGINBRIDGE (Phase 13 — ACTIVE)

Third-party plugin parameter control + real-time per-track audio analysis.
**Source:** `AI MUSIC PRODUCTION/pluginbridge/` | GitHub: `github.com/capcutfor1month-oss/pluginbridge`
**Version:** v0.8.0

**Setup (per session):**
1. Load `PluginBridge.vst3` on the track you want to control
2. Select channel name from dropdown (e.g. "Vocal Bus")
3. Pick the plugin from the TreeView browser (e.g. Pro-Q 4)
4. MCP tools are live on port 16620 — no other config

**Mixing workflow:**
```
list_instances()                                             → ["Vocal Bus", "Drum Bus"]
get_analysis("Vocal Bus")                                    → "[Vocal Bus] -16.2 LUFS | TP:-1.1 | low:+7 | bright"
search_param("Vocal Bus","Pro-Q 4","band 2")                → [{i:24, name:"Band 2 Used"}, {i:26, name:"Band 2 Freq"}, ...]
set_params("Vocal Bus","Pro-Q 4",{24:1.0, 26:0.748, 27:0.75}) → "ok"  (band appears in Pro-Q 4 GUI instantly)
get_analysis("Vocal Bus")                                    → "[Vocal Bus] -16.2 LUFS | balanced"
```

**What it unlocks:**

| Plugin | Before | After |
|---|---|---|
| Pro-Q 4 | 1 param via LOM | All 737 params |
| Serum 2, Diva, Omnisphere | locked | full control |
| Any third-party VST3/AU | locked | full control |

**Key gotcha:** Pro-Q 4 bands have `Band X Used` (in the chain = visible) **separate from** `Band X Enabled` (toggled on/off). Must set `Used=1.0` for a band to appear. Use `search_param` to find all parameter names first.

**Safe plugins** (full GUI in Ableton): Pro-Q 4, The God Particle, Little MicroShift, LIMITER
**Unsafe plugins** (audio-only, MCP still works): iZotope Ozone 12, Neutron 5

---

## BASIC PITCH (Phase 12 — ACTIVE)

Audio-to-MIDI transcription. Polyphonic. Any instrument.

```bash
# Transcribe any WAV or MP3 to MIDI
basic-pitch /output/dir/ /path/to/audio.wav --save-midi --model-serialization onnx
# → output/audio_basic_pitch.mid
```

**Known limitation:** File path must not contain spaces — copy to /tmp/ first if needed.

---

## MEM0 MEMORY (Phase 10 — ACTIVE)

Cross-session memory. Project: `AI-MUSIC-PRODUCTION`.
LLM: `gemini/gemini-2.0-flash`. Storage: Qdrant local.
API key: `AI MUSIC PRODUCTION/.env` → `GOOGLE_API_KEY=...`

Use `memory_search` at session start to recall past decisions.
Use `memory_add` after any decision that worked — builds a personal mixing knowledge base.

---

## NOTEBOOKLM

```bash
/opt/homebrew/var/pipx/venvs/notebooklm-py/bin/notebooklm ask "question"
```

Notebook: **PLUGING LIBRARY** (be8353eb-3d3e-447f-b3ce-4b09f0e1df07). 257+ sources.
Includes: Ableton Live 12 manual, LOM reference, orchestration, mixing, Indian music. Already authenticated.

### Structured Query Template (always use — never vague questions)

Always inject this full template when querying NotebookLM. Format does NOT persist across turns — include it every time.

```
DATA: [actual numbers — dBFS, Hz, MIDI notes, velocity values, BPM, key]
CONTEXT: [genre, reference artists, instruments, current processing chain]
QUESTIONS:
1. [specific question with numbers]
2. [specific question]
3. [specific question — option A vs option B]

OUTPUT FORMAT — follow exactly:
## Signal Chain
## EQ (Hz and dB values only)
## Compression / Sidechain Settings
## [Topic-specific section — e.g. Reverb Settings / Tuning Approach / Velocity Map]
## What to Avoid
## Reference Tracks

Do not add follow-up questions or offers at the end. Stop after Reference Tracks.
```

---

## ACTIVE PROJECTS

Sessions saved **only when Adi says "save session"** → `sessions/[project]-session.md`
To resume: read session file first, then verify vs live Ableton state.

`CURRENT PROJECT STATE.md` is the live stage/context file for the active song.
- Read it before major production, mix, or master decisions if it contains saved state.
- Update it **only** when Adi explicitly says "save session".
- Do not modify it during normal advice, exploration, troubleshooting, or execution.
- If a later-stage issue requires changing production, mark it as `Needs Reopen` instead of silently rewriting locked decisions.

---

## KEY FILE LOCATIONS

| What | Path |
|---|---|
| MCP Remote Script | `User Library/Remote Scripts/Ableton_Live_MCP/` |
| MCP binary | `/opt/homebrew/bin/ableton-live-mcp` |
| AgentAudioTap | `User Library/Presets/Audio Effects/Max Audio Effect/` |
| Ableton log | `~/Library/Preferences/Ableton/Live 12.4/Log.txt` |
| Sessions | `AI MUSIC PRODUCTION/sessions/` |
| Current project state | `AI MUSIC PRODUCTION/CURRENT PROJECT STATE.md` |
| Sketches | `AI MUSIC PRODUCTION/sketches/` |
| Full reference doc | `AI MUSIC PRODUCTION/docs/CLAUDE-reference.md` |
| PluginBridge source | `AI MUSIC PRODUCTION/pluginbridge/` |
| audio-analyzer binary | `AI MUSIC PRODUCTION/audio-analyzer-rs/cli` |
| API keys | `AI MUSIC PRODUCTION/.env` |

All paths prefixed with `/Volumes/T7 Shield/Users/Aditya/` unless shown as `~/`
If working from a moved copy, use `AI_MUSIC_ROOT` / current project root instead of the old absolute path.

---

## MENTOR SKILL

Files at: `/Volumes/T7 Shield/Users/Aditya/Downloads/AI MUSIC PRODUCTION/adi-mixing-production-mentor/`
Read directly — full copies of the Claude mentor skill references.
- Stage 1: `references/production-workflow.md`
- Stage 2: `references/mixing-workflow.md`
- Stage 3: `references/release-checklist.md`
- Genres:  `references/genre-targets.md`
