# AI Music Production — Session Context (Gemini)
> Load this at the start of every Gemini session: read this file first.
> Full reference (EQ maps, patches, retired tools): `docs/CLAUDE-reference.md`

---

## BEHAVIOR — READ FIRST

**Never say "I can't do that."** Research first, then execute.

### Research-First (mandatory before any instrument/production task)
1. IDENTIFY — what instrument or concept?
2. READ — find the source file below and read it
3. EXTRACT — pull exact numbers (velocity, timing, Hz)
4. EXECUTE — MCP calls with those exact values
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
→ /opt/homebrew/bin/ableton-live-mcp → Claude Code MCP (Gemini calls via execute())
+ AbletonOSC fallback (UDP 11000, Control Surface 2)
+ NotebookLM CLI  (/opt/homebrew/var/pipx/venvs/notebooklm-py/bin/notebooklm ask "...")
```

**Startup:** Prefs → Control Surface 1 = Ableton_Live_MCP | CS 2 = AbletonOSC (optional)
**Stale MCP:** `pkill -f ableton-live-mcp` → reconnect

---

## MCP TOOLS (5 total — call via execute bridge)

| Tool | What it does |
|---|---|
| `execute(code)` | Run Python in Ableton LOM |
| `api(class_name)` | Browse Live API reference |
| `search_api(query)` | Search API by keyword |
| `agent_audio_tap(cmd, path)` | Control AgentAudioTap M4L (open/start/stop/status) |
| `analyze_spectrum(file, bands=24)` | FFT on WAV → bands[], summary, peak, clashes |

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
| **VST3 = 1 param only** | Pro-Q 4, Serum 2 knobs unreachable. Use EQ Eight, Compressor for full control. |
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

**Race Condition Fix (2026-05-13):** Fixed 100ms polling lag where tap started before transport, causing silent captures and false EQ diagnoses. `capture_strings.sh` now verifies `song.is_playing` before triggering start.

```bash
# Capture N bars, auto-stops Ableton when done
"/Volumes/T7 Shield/Users/Aditya/Downloads/AI MUSIC PRODUCTION/tools/capture_strings.sh" 8
# → /tmp/strings_tap.wav ready for analyze_spectrum
```

Manual: `agent_audio_tap("open", "/tmp/tap.wav")` → play → `agent_audio_tap("stop")` → `analyze_spectrum("/tmp/tap.wav")`

---

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

## PENDING TASKS (from 2026-05-12)

1. **Fix Contrabass routing** — HPF at 100Hz on STRINGS BUS cuts C2/G2/D2 fundamentals. Route Contrabass directly to Master, give it own EQ Eight with HPF at 40Hz max.
2. **STRINGS BUS position** — stuck at track 32. Manual drag only in Ableton UI.
3. **M/S EQ on STRINGS BUS** — Pro-Q 4 mid cut 200–350Hz to carve vocal pocket. Manual only (VST3).

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
