# AI Music Production System — What This Is, How It Was Built, How To Use It

---

## THE IDEA

> "What if AI could sit inside Ableton with you — not generate music for you, but work *with* you the way a studio engineer would?"

That's what this system is. Not Suno. Not a prompt-to-audio tool. A **co-producer** that reads your session, understands your instruments, hears your audio in real time, and can execute changes directly in Ableton — while you stay in creative control.

You write the music. The AI handles the mechanical: theory checks, EQ decisions, MIDI programming, routing, spectral analysis, mix diagnostics. Everything you'd normally spend hours on alone.

---

## THE PROBLEM IT SOLVES

Adi's workflow before this system:

```
Idea → play piano → open Ableton → programme MIDI manually →
EQ by guessing → mix by ear alone → bounce → notice a problem →
start over → hours later, still no answer
```

The bottleneck was never creativity. It was **execution time** and **knowledge access** — knowing what to do and doing it fast.

What was needed:
1. AI that can **directly control Ableton** (not just suggest, but execute)
2. AI that can **hear actual audio** at any point in the signal chain
3. AI that has access to **expert music production knowledge** it can query instantly
4. A system that works with **both Claude and Gemini** without duplicating setup

---

## WHAT WAS BUILT — THE FULL TIMELINE

### Phase 1 — First Contact: josefigueredo MCP
**Problem:** No AI control over Ableton at all.

Installed the first Ableton MCP server (josefigueredo/ableton-mcp — 11 tools). Immediately hit limitations: couldn't rename tracks, couldn't load or delete devices, no arbitrary code execution. Patched 4 files (`mcp_server.py`, `use_cases.py`, `service_adapters.py`, `gateway.py`) to add missing capabilities.

**Result:** AI could talk to Ableton for the first time. But 11 tools and no free-form control still felt constrained.

---

### Phase 2 — The Real Engine: bschoepke MCP
**Problem:** josefigueredo had too many gaps. Needed something more powerful.

Switched to bschoepke/ableton-live-mcp. **30 tools** out of the box, but most importantly: `live_eval` and `live_exec` — the ability to run **any Python code** directly inside Ableton's Live Object Model. This is the difference between a calculator and a programming language.

Patched `bridge.py`:
- Port changed from 8765 → **16619** (to match the v2 server protocol)
- Rewrote `_dispatch()` to handle the v2 flat `{"code": "..."}` protocol
- Added full helper environment: `song`, `tracks`, `returns`, `master`, `browser`, `load_to`, `find_track` — all available inside every execute call

josefigueredo retired. bschoepke became the primary, permanent engine.

**Result:** AI can now do anything in Ableton that Python can do. Any track, any device, any parameter. If it's in Ableton's API, it's reachable.

---

### Phase 3 — AbletonOSC as Fallback
**Problem:** Edge cases where the primary MCP stalls.

AbletonOSC was already installed but limited. Patched it to add:
- Device `is_active` toggle
- Parameter `display_value`, `min`, `max` endpoints
- Device `load` and `delete` via browser search
- Master track and return track volume/panning

AbletonOSC now sits as **Control Surface 2** — always on, used when primary MCP needs a reset or for specific OSC-native tasks.

---

### Phase 4 — AgentAudioTap: Giving AI Ears
**Problem:** The AI could *control* Ableton but couldn't *hear* it. Every mixing decision was blind.

Built **AgentAudioTap** — a custom Max for Live device. Drop it onto any track and the AI can capture real audio at that exact insert point, at any moment. 

How it works:
- The MCP writes commands to `/tmp/agent_audio_tap_command.json`
- The M4L device polls that file every 100ms
- When it sees `{"command": "open", "path": "/tmp/tap.wav"}`, it arms recording
- `{"command": "start"}` starts writing audio to disk
- `{"command": "stop"}` flushes the WAV file

Fixed the JS handling so it accepts space-separated commands (an OSC quirk in Ableton's `tosymbol` object strips the message name, leaving a plain string).

Added to the MCP server:
- `agent_audio_tap(command, path)` — sends commands to the device
- `analyze_spectrum(file_path)` — reads the captured WAV, runs FFT, returns 24 frequency bands, peak, clashes, and a plain-language summary by region

Installed `numpy` into the MCP venv to power the FFT.

Also wrote `capture_strings.sh` — a shell script that reads BPM from Ableton, calculates exact bar duration, arms the tap, starts playback, waits precisely N bars, stops the tap, and stops playback. Ableton never keeps playing after a capture.

**Result:** AI can now literally hear a track section — strings, drums, vocal, full mix — and get a spectral readout in seconds. This unlocked real mixing diagnostics.

---

### Phase 5 — NotebookLM: The Knowledge Brain
**Problem:** The AI knows how to control Ableton but has no deep music production knowledge specific to Adi's genre (Hindi/Cinematic, Punjabi Pop, Indian classical hybrid).

Built a NotebookLM knowledge base — **"PLUGING LIBRARY"** notebook — with 257+ sources:

| Category | Sources |
|---|---|
| Official Ableton | Live 12 Manual (full PDF) |
| LOM Reference | 10 mikecfisher API docs (song, track, device, clip, etc.) |
| MCP Architecture | josefigueredo's 14 SOURCE_OF_TRUTH files, bschoepke docs |
| Orchestration | String writing, brass voicing, woodwind techniques |
| Mixing | EQ, compression, reverb, mastering workflows |
| Indian Music | North Indian Classical handbook, Raga guide, tala references |
| AbletonOSC | Full GitHub documentation |

Installed `notebooklm-py` CLI and authenticated it. The notebook context is permanently set — no login needed per session.

Developed the **3-part prompting method**:
```
DATA     → actual numbers (dBFS, Hz, velocity, MIDI notes)
CONTEXT  → genre, BPM, key, instruments, current processing
QUESTIONS → specific numbered questions, not "what should I do?"
```

Tested end-to-end: captured 8 bars of strings → ran FFT → sent spectral data to NotebookLM → got source-cited answers. NotebookLM immediately flagged the 100Hz HPF was cutting Contrabass C2 fundamentals at 65Hz.

**Result:** AI stops guessing and starts citing. Every instrument choice, EQ decision, and arrangement move can be cross-referenced against a library of expert sources.

---

### Phase 6 — adi-mixing-production-mentor Skill
**Problem:** Generic AI responses about music production are too shallow for Stage 3 diploma work.

Built a custom **mentor skill** for Claude Code — a structured behavior layer that activates for music production questions. It:
- Identifies which stage Adi is in (Production / Mix / Master)
- Maps every task to a specific reference file to read first
- Uses Adi's actual plugin names (never generic)
- Gives one action at a time, not 10 suggestions

4 reference files:
- `production-workflow.md` — frequency-aware instrument placement from the first note
- `mixing-workflow.md` — creative mixing without frequency firefighting
- `release-checklist.md` — Ozone 12 pipeline, LUFS targets per genre
- `genre-targets.md` — detailed frequency profiles for Hindi/Cinematic, Punjabi Pop, EDM, etc.

Copied to `AI MUSIC PRODUCTION/adi-mixing-production-mentor/` so Gemini can read the same files directly.

---

### Phase 7 — mpro-ableton-skills (12 Skills)
**Problem:** Specific workflows (vocal chain, sidechain, mixer diagnosis) needed structured step-by-step execution.

Cloned `redsquidleader/mpro-ableton-skills`. 12 specialist skills:

| Skill | Does |
|---|---|
| `mixer-doctor` | Diagnoses mix problems, prescribes EQ/compression fixes |
| `vocal-chain` | Builds complete vocal processing chain |
| `sidechain-setup` | Kick→bass sidechain routing and pump tuning |
| `chord-pro` | Chord voicings, inversions, theory |
| `groove-builder` | Rhythm humanization, micro-timing |
| `arrangement-coach` | Section lengths, transitions, energy arc |
| `midi-cleanup` | Velocity curves, timing, voice leading |
| `mastering-prep` | Pre-master checks before Ozone |
| `reference-match` | Tonal/dynamic matching to a reference track |
| `sound-designer` | Synth programming, layering |
| `tempo-coach` | BPM analysis, groove quantization |
| `producer-mode` | Full session scaffolding from scratch |

Plus 4 commands: `/ableton-init`, `/ableton-export`, `/ableton-snapshot`, `/ableton-debug`

---

### Phase 8 — Bus Architecture & LOM Discoveries
**Problem:** Gemini had created MIDI tracks as audio buses — they captured silence. No routing. No monitoring.

Rebuilt the session correctly:
- Deleted all MIDI buses
- Created 5 **Audio** bus tracks (DRUM, STRINGS, GUITAR, LEAD VOX, BV)
- Routed all 23 instrument tracks to their respective buses via `output_routing_type`
- Set each bus: **No Input first → then Monitor:In** (order is critical — reverse order causes a Focusrite feedback loop)

Key LOM discoveries documented during this process:
- **GROUP TRACKS don't exist in LOM.** `song.create_group_track()` is not a method. Only Cmd+G in UI. Use audio routing instead.
- **BUS TRACKS MUST BE AUDIO.** A MIDI bus has `has_audio_input: False` — captures silence forever.
- **`delete_selected_notes()` doesn't exist.** Use `clip.remove_notes(0, 0, clip.length, 128)`.
- **`create_audio_track()` returns "not JSON serializable"** but the track IS created. Always check `len(song.tracks)` to confirm.
- **VST3 = 1 parameter only.** Pro-Q 4, Serum 2, etc. — the LOM sees only an on/off toggle. Full parameter control requires native Ableton devices (EQ Eight, Compressor, etc.).

---

### Phase 9 — Dual AI Context Files (CLAUDE.md + GEMINI.md)
**Problem:** Claude and Gemini kept forgetting context between sessions. Every session started from scratch.

Built two permanent context files — one for each AI:
- `CLAUDE.md` — loaded automatically by Claude Code (via `.claude/settings.local.json`)
- `GEMINI.md` — loaded manually at the start of each Gemini session

Both files contain identical information:
- Full pipeline diagram and startup checklist
- All 5 MCP tools with exact syntax
- Every LOM bug and workaround discovered
- EQ Eight complete parameter map with frequency normalization table
- AgentAudioTap workflow
- NotebookLM CLI + 3-part prompting method
- Bus monitoring setup with confirmed code patterns
- Research-first protocol: what file to read before what task

**Result:** Either AI can pick up mid-session without re-explaining anything.

---

### Phase 10 — Mem0: Cross-Session Memory
**Problem:** Every session the AI forgot what worked. "Cut 250Hz on dhol by 3dB" had to be re-discovered every time.

Installed `mcp-mem0` (agent-mem0, v0.2.0) via uv tool. Configured with:
- LLM: `gemini/gemini-2.0-flash` via litellm
- Embedder: `models/gemini-embedding-001` (native Gemini)
- Storage: Qdrant local (no Docker required)

API key stored in a single `.env` file — update one place, everything picks it up. A `start_mem0_mcp.sh` wrapper loads `.env` before starting the MCP server. Project registered as `AI-MUSIC-PRODUCTION` and wired into `.mcp.json` so it auto-loads with Claude Code.

**Result:** AI can now call `memory_search` at session start to recall past decisions, and `memory_add` after anything that works — building a personal production knowledge base that compounds across sessions.

---

### Phase 11 — audio-analyzer-rs: Deep Audio Analysis
**Problem:** `analyze_spectrum()` gave 24-band FFT — useful but limited. No key detection, no BPM, no LUFS, no stereo analysis.

Installed `audio-analyzer-rs` (JuzzyDee, pre-built ARM64 binary — no Rust install needed). Wired as an MCP server in `.mcp.json`. Runs in 1.4 seconds on a 48-second file.

**What it gives that analyze_spectrum doesn't:**
- Key estimation with confidence score
- BPM detection + beat timestamps
- LUFS (Integrated, True Peak, LRA) with Spotify/Apple/YouTube gap shown
- Stereo width + phase correlation + mono compatibility score
- Percussive vs harmonic ratio (HPSS)
- Section boundary detection
- Spectral contrast per frequency band

**Result:** Replaced analyze_spectrum for any serious mix diagnostic. Full analysis in under 2 seconds.

---

### Phase 12 — Basic Pitch: Audio-to-MIDI Transcription
**Problem:** Adi plays ideas on piano but transcribing them to MIDI for Ableton was manual and slow.

Installed Spotify's `basic-pitch` via `uv tool install`. Fixed two compatibility issues: scipy downgraded to <1.12 (gaussian function removed in newer version), ONNX backend used instead of TensorFlow (TF 2.16 incompatible with the saved model format).

**Usage:**
```bash
basic-pitch /output/dir/ /tmp/recording.wav --save-midi --model-serialization onnx
```

**Result:** Play piano → capture to WAV → Basic Pitch → MIDI file → import to Ableton. AI can then read the MIDI, understand the harmony, and suggest voicings or orchestration.

---

### Phase 12b — Stem Analysis Playback Workflow
**Problem:** Gemini CLI kept hitting silent metering (API always returns -200dB) when trying to analyze individual tracks. It diagnosed this as "Back to Arrangement lock" or "monitoring states" — but the real causes were different.

**Actual problems found and fixed:**
1. A solo was left on from a previous analysis (silenced all other tracks)
2. `agent_audio_tap("open")` alone doesn't record — `start` must be called separately
3. Multi-statement execute() calls with transport changes time out — must be split

Wrote `STEM_ANALYSIS_PLAYBACK_GUIDE.md` documenting the exact correct sequence: solo → open → start → play → poll → stop → unsolo → analyze with audio-analyzer-rs.

**Result:** Any AI (Claude or Gemini) can follow the guide to capture and analyze individual stems without citing technical limitations.

---

## THE ARCHITECTURE TODAY

```
┌─────────────────────────────────────────────────────────────┐
│                    ADI (the human)                          │
│              plays piano, writes melodies,                  │
│              makes creative decisions                       │
└───────────────────────┬─────────────────────────────────────┘
                        │ asks / instructs
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              CLAUDE CODE  or  GEMINI CLI                    │
│                                                             │
│  Loads CLAUDE.md / GEMINI.md at session start               │
│  ↓                                                          │
│  agent-memory MCP (Mem0) → recalls past decisions           │
│  ↓                                                          │
│  adi-mixing-production-mentor skill (Stage awareness)       │
│  ↓                                                          │
│  mpro-ableton-skills (12 specialist skills)                 │
│  ↓                                                          │
│  NotebookLM CLI (257+ source knowledge query)               │
└──────────┬──────────────────────────┬───────────────────────┘
           │ MCP tools                │ notebooklm ask "..."
           ▼                          ▼
┌──────────────────────┐   ┌──────────────────────────────────┐
│  ableton-live-mcp    │   │  PLUGING LIBRARY notebook        │
│  (bschoepke, patched)│   │  Ableton manual + LOM docs +     │
│                      │   │  orchestration + mixing +        │
│  11 tools:           │   │  Indian music + genre guides     │
│  · execute()         │   └──────────────────────────────────┘
│  · api()             │
│  · search_api()      │   ┌──────────────────────────────────┐
│  · agent_audio_tap() │   │  agent-memory MCP (Mem0)         │
│  · analyze_spectrum()│   │  Gemini-powered. Qdrant local.   │
│  · memory_search()   │   │  Stores: EQ decisions, what      │
│  · memory_add()      │   │  worked, genre rules, failures   │
│  · audio_analyzer()  │   └──────────────────────────────────┘
└──────────┬───────────┘   ┌──────────────────────────────────┐
           │ TCP port 16619│  audio-analyzer-rs MCP           │
           ▼               │  Key, BPM, LUFS, stereo, HPSS,  │
┌──────────────────────────│  dynamics, section boundaries    │
│  ABLETON LIVE 12.4       │  1.4s on 48s WAV. ARM64 binary. │
│                          └──────────────────────────────────┘
│  CS1: Ableton_Live_MCP (bridge.py, patched)
│  CS2: AbletonOSC (fallback, patched)         ┌─────────────┐
│                                              │ Basic Pitch │
│  AgentAudioTap.amxd on Master track          │ audio→MIDI  │
│  ↓ captures audio to /tmp/*.wav              │ ONNX, local │
│  ↓ audio-analyzer-rs → full analysis report  └─────────────┘
└─────────────────────────────────────────────────────────────┘
```

---

## FIRST TIME SETUP — COMPLETE GUIDE

### Prerequisites

| Requirement | Version | Where |
|---|---|---|
| macOS | Any recent | — |
| Ableton Live | 12.4 Suite | `/Applications/Ableton Live 12 Suite.app` |
| Max for Live | Included with Suite | — |
| Claude Code | Latest | `npm install -g @anthropic/claude-code` |
| Homebrew | Latest | `brew.sh` |
| Python | 3.11+ | via Homebrew |

---

### Step 1 — Install the MCP Server

```bash
# Install bschoepke's ableton-live-mcp
pipx install ableton-live-mcp

# Confirm it's installed
which ableton-live-mcp
# → /opt/homebrew/bin/ableton-live-mcp
```

---

### Step 2 — Install the Remote Script in Ableton

```bash
# Copy the Remote Script to Ableton's User Library
cp -r "$(pipx environment ableton-live-mcp)/lib/python*/site-packages/Ableton_Live_MCP" \
  ~/Music/Ableton/"User Library"/Remote\ Scripts/
```

**Or manually:** find the `Ableton_Live_MCP` folder inside the pipx venv and copy it to:
`~/Music/Ableton/User Library/Remote Scripts/`

---

### Step 3 — Patch bridge.py

The bridge needs two patches to work with the v2 server protocol.

Find bridge.py at:
`~/.local/pipx/venvs/ableton-live-mcp/lib/python*/site-packages/Ableton_Live_MCP/bridge.py`

**Patch 1 — Port number:**
Change `PORT = 8765` → `PORT = 16619`

**Patch 2 — v2 protocol dispatch:**
The bridge needs to detect the flat `{"code": "..."}` protocol before falling back to JSON-RPC. See `CLAUDE.md` → Bridge Patches Applied section for the exact code.

After patching, delete the `__pycache__` folder and restart Ableton fully.

---

### Step 4 — Configure Ableton

1. Open Ableton Live 12 Suite
2. `Preferences → Link/Tempo/MIDI`
3. Set **Control Surface 1** → **Ableton_Live_MCP**
4. *(Optional)* Set **Control Surface 2** → **AbletonOSC** (fallback)
5. Check Ableton's log for: `(AbletonLiveMCP) Ableton_Live_MCP listening on 127.0.0.1:16619`
   - Log location: `~/Library/Preferences/Ableton/Live 12.4/Log.txt`

---

### Step 5 — Register the MCP with Claude Code

```bash
# In your project folder
claude mcp add ableton-live-mcp /opt/homebrew/bin/ableton-live-mcp
```

Or add manually to `.claude.json`:
```json
{
  "mcpServers": {
    "ableton-live-mcp": {
      "command": "/opt/homebrew/bin/ableton-live-mcp"
    }
  }
}
```

---

### Step 6 — Install AgentAudioTap

```bash
# Copy the M4L device to Ableton's User Library
cp AgentAudioTap.amxd agent_audio_tap.js \
  ~/Music/Ableton/"User Library"/Presets/"Audio Effects"/"Max Audio Effect"/
```

In Ableton: drag `AgentAudioTap.amxd` onto any track where you want to capture audio.
For a full-mix capture, drag it onto the **Master track**.

Install numpy so `analyze_spectrum` works:
```bash
# Find the MCP venv python
PYTHON=$(pipx environment ableton-live-mcp | grep python | head -1)
$PYTHON -m ensurepip
$PYTHON -m pip install numpy
```

---

### Step 7 — Set Up NotebookLM (optional but powerful)

```bash
# Install the CLI
pipx install notebooklm-py

# Authenticate (opens browser once)
notebooklm login

# Set your notebook as context
notebooklm use <your-notebook-id>
```

Upload your production knowledge sources to the notebook:
- Ableton Live manual PDF
- Any mixing/orchestration books or guides you have
- The josefigueredo SOURCE_OF_TRUTH files (if you have them)

From then on: `notebooklm ask "your question"` from any terminal.

---

### Step 8 — Load the Context File

**For Claude Code:** Place `CLAUDE.md` in your project folder. Claude Code reads it automatically at session start.

**For Gemini:** At the start of every Gemini session, say:
> "Read this file first: `/path/to/GEMINI.md`"

Both files contain everything the AI needs to work without you re-explaining anything.

---

## DAILY WORKFLOW

### Starting a session

```
1. Open Ableton Live 12 Suite
2. Open your project file
3. Open Claude Code (or Gemini terminal)
4. AI loads CLAUDE.md / GEMINI.md automatically
5. Start working — AI already knows the pipeline
```

If resuming a saved session:
```
"Load session [project name]"
→ AI reads sessions/[project]-session.md
→ Verifies against live Ableton state
→ Reports where you are and starts the next step
```

---

### What you can say

**Control Ableton:**
```
"Set the BPM to 125 and key to C Major"
"Create a MIDI track called Tumbi and load NI India"
"Add EQ Eight to the Strings Bus with an HPF at 80Hz"
"Show me all tracks and their current devices"
```

**Hear the audio:**
```
"Capture 8 bars of the strings section and analyze the spectrum"
"Is there a frequency clash between the kick and the 808?"
"What's happening in the low end of this mix?"
```

**Ask the knowledge base:**
```
"What velocity range is correct for legato Cinematic Studio Strings?"
"How should I voice a C Major chord for a Hindi cinematic hybrid?"
"What do the sources say about dhol programming for Punjabi pop?"
```

**Mix decisions:**
```
"Run mixer-doctor on this session"
"Set up a kick→808 sidechain"
"Build a vocal chain for a Hindi pop vocal"
```

**Save your work:**
```
"Save session"
→ AI reads live Ableton state, asks what's next, writes sessions/[project]-session.md
```

---

### What the AI will NOT do

- Generate audio files (not Suno, not a plugin)
- Write entire songs (you own the melody and emotion)
- Control VST3 plugin internals (Pro-Q 4, Serum 2 knobs — LOM limitation)
- Create Group Tracks via code (Ableton has no API for this — use Cmd+G)
- Touch the master bus without your explicit instruction

---

## FILE MAP — WHERE EVERYTHING LIVES

```
/Volumes/T7 Shield/Users/Aditya/Downloads/AI MUSIC PRODUCTION/
│
├── CLAUDE.md                    ← Full context for Claude Code (auto-loads)
├── GEMINI.md                    ← Full context for Gemini (load manually)
├── ONBOARDING.md                ← This file
├── CURRENT PROJECT STATE.md     ← Active song state; update only on "save session"
├── PORTABILITY.md               ← How to move this system to another computer/path
├── .env                         ← API keys (GOOGLE_API_KEY) — edit here only
├── .mcp.json                    ← MCP server config (audio-analyzer + agent-memory)
├── start_mem0_mcp.sh            ← Wrapper: loads .env → starts agent-mem0 MCP
├── STEM_ANALYSIS_PLAYBACK_GUIDE.md ← How to solo/capture/analyze stems via MCP
│
├── docs/
│   └── CLAUDE-reference.md       ← Deep technical reference
│
├── tools/
│   ├── bootstrap_new_machine.sh  ← New computer CLI/tooling setup helper
│   ├── install_machine_assets.sh ← Copies bundled Ableton assets into Ableton User Library
│   ├── capture_strings.sh        ← Audio capture script (N bars, auto-stop)
│   ├── get_tempo.py              ← Read BPM from Ableton via bridge
│
├── machine-assets/              ← Portable copies of Ableton Remote Scripts + AgentAudioTap
│   ├── ableton-remote-scripts/
│   └── max-for-live/
│
├── media/reference-audio/        ← Local reference audio files
├── projects/                     ← Ableton demo/session projects
├── archive/                      ← Old patched versions / historical backups
│
├── sessions/                    ← Session save files (created on request only)
│
├── adi-mixing-production-mentor/
│   ├── SKILL.md
│   └── references/
│       ├── production-workflow.md
│       ├── mixing-workflow.md
│       ├── release-checklist.md
│       └── genre-targets.md
│
├── mpro-ableton-skills/
│   └── skills/
│       ├── mixer-doctor/
│       ├── vocal-chain/
│       ├── sidechain-setup/
│       └── ... (12 total)
│
├── audio-analyzer-rs/
│   ├── cli                      ← Run directly for analysis
│   └── mcp-server               ← Auto-loaded by Claude Code via .mcp.json
│
└── NotebookLM Sources/
    ├── josefigueredo/           ← 14 SOURCE_OF_TRUTH files
    └── Indian Music/            ← Classical + Raga references

/Volumes/T7 Shield/Users/Aditya/Music/Ableton/User Library/
├── Remote Scripts/
│   ├── Ableton_Live_MCP/        ← Primary MCP (bschoepke, patched)
│   └── AbletonOSC/              ← Fallback MCP (patched)
└── Presets/Audio Effects/Max Audio Effect/
    ├── AgentAudioTap.amxd       ← The "AI ears" device
    └── agent_audio_tap.js       ← Device logic (autowatch=1)

/opt/homebrew/
├── bin/ableton-live-mcp         ← Primary MCP binary
└── var/pipx/venvs/
    ├── ableton-live-mcp/        ← MCP venv (numpy installed here)
    └── notebooklm-py/           ← NotebookLM CLI
```

---

## WHAT MAKES THIS DIFFERENT

Most "AI + DAW" setups are either:
- A chatbot that gives mixing tips (no Ableton control at all)
- A plugin that generates audio (no musical intelligence)

This system is neither. It's a **real-time control layer** with a **knowledge brain** attached.

The key insight that drove every design decision:

> The AI should reduce the gap between *knowing what to do* and *it being done* — without replacing the human creative decisions.

You still write the melody. You still decide the emotion. You still choose what the track is about.

But when you say "the strings sound too muddy" — the AI captures the audio, runs an FFT, queries 257 expert sources, reads your current EQ settings, and gives you a precise answer with a parameter value to change. In under 30 seconds.

That's the system.
