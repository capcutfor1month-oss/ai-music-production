# Portability Guide

This folder can be moved to another Mac or drive, but the full pipeline has two parts:

1. **Portable project folder** - this `AI MUSIC PRODUCTION` folder.
2. **Machine-specific installs** - Ableton Remote Scripts, MCP binaries, NotebookLM login, Max for Live devices.

The folder moves easily. The machine-specific installs must be recreated or relinked on the new computer.

---

## Recommended Move Method

### 1. Copy the whole folder

Copy the complete `AI MUSIC PRODUCTION` folder, including:

- `CLAUDE.md`
- `GEMINI.md`
- `CURRENT PROJECT STATE.md`
- `NotebookLM Sources/`
- `adi-mixing-production-mentor/`
- `mpro-ableton-skills/`
- `archive/abletonosc-versions/`
- `sessions/`
- `sketches/`
- helper scripts

Do not copy only the markdown files. The source folders are part of the brain.

### 2. Open the new folder as the project root

For any AI agent, the project root is:

```bash
pwd
```

from inside the moved `AI MUSIC PRODUCTION` folder.

Agents should resolve local files relative to this folder instead of assuming:

```text
/Volumes/T7 Shield/Users/Aditya/Downloads/AI MUSIC PRODUCTION
```

### 3. Reinstall or relink machine-specific tools

On the new computer, verify these separately:

| Component | Move behavior |
|---|---|
| Ableton Live | Must be installed on the new computer |
| Ableton_Live_MCP Remote Script | Must exist in Ableton User Library Remote Scripts |
| AbletonOSC Remote Script | Must exist in Ableton User Library Remote Scripts if used |
| AgentAudioTap Max for Live device | Must exist in Ableton User Library Presets |
| `ableton-live-mcp` binary | Must be installed with `pipx` or equivalent |
| NotebookLM CLI/auth | Must be installed and logged in |

This project now includes bundled Ableton assets under:

```text
machine-assets/
```

Use the installer script to copy them into Ableton's required folders:

```bash
./tools/install_machine_assets.sh
```

Ableton still needs those assets in its User Library to load them. The root folder can hold the source copies, but Ableton does not scan arbitrary project folders for Control Surface scripts.

---

## Portable Environment Variables

These are optional, but useful on a different computer:

```bash
export AI_MUSIC_ROOT="/path/to/AI MUSIC PRODUCTION"
export NOTEBOOKLM_BIN="/opt/homebrew/var/pipx/venvs/notebooklm-py/bin/notebooklm"
export ABLETON_MCP_BIN="/opt/homebrew/bin/ableton-live-mcp"
```

If `AI_MUSIC_ROOT` is not set, helper scripts should use their own file location as the project root.

---

## What Must Stay Machine-Specific

Do not expect these paths to move automatically:

- Ableton User Library location
- Ableton Remote Scripts location
- Claude/Gemini MCP registration
- NotebookLM authentication profile
- Homebrew and `pipx` binary paths
- Audio interface device names

Those are part of the new computer setup, not the portable project folder.

---

## New Computer Installation Process

Use this order on a new Mac.

For the automated CLI-side setup, run:

```bash
./tools/bootstrap_new_machine.sh
```

This script checks/installs Homebrew, Python, `pipx`, `ableton-live-mcp`, and `notebooklm-py`; copies bundled Ableton assets; writes portable environment variables; registers MCP with Claude Code if `claude` is installed; prompts NotebookLM login; and runs health checks.

It intentionally does **not** install Ableton Live 12 or select Ableton Control Surfaces.

### 1. Copy the project folder

Copy the entire `AI MUSIC PRODUCTION` folder to the new computer.

Do not copy only the markdown files. Keep the source folders, skills, sessions, scripts, and AbletonOSC backup together.

### 2. Install base tools

Install Homebrew, Python, and pipx:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install python pipx
pipx ensurepath
```

Restart Terminal after `pipx ensurepath`.

### 3. Install Ableton Live

Install Ableton Live 12 Suite on the new computer.

Then install the bundled Ableton assets from this project:

```bash
./tools/install_machine_assets.sh
```

This copies:

- `machine-assets/ableton-remote-scripts/Ableton_Live_MCP`
- `machine-assets/ableton-remote-scripts/AbletonOSC`
- `machine-assets/max-for-live/AgentAudioTap.amxd`
- `machine-assets/max-for-live/agent_audio_tap.js`

In Ableton:

```text
Preferences -> Link/Tempo/MIDI
Control Surface 1 = Ableton_Live_MCP
Control Surface 2 = AbletonOSC
```

### 4. Install the Ableton MCP server

```bash
pipx install ableton-live-mcp
which ableton-live-mcp
```

From inside the moved `AI MUSIC PRODUCTION` folder, register it with Claude Code:

```bash
claude mcp add ableton-live-mcp "$(which ableton-live-mcp)"
```

If the bridge does not connect, apply the bridge patches described in `ONBOARDING.md` and `docs/CLAUDE-reference.md`.

### 5. Install NotebookLM CLI

```bash
pipx install notebooklm-py
notebooklm login
notebooklm list
notebooklm use be8353eb-3d3e-447f-b3ce-4b09f0e1df07
```

If that notebook is not available on the new Google account, create or select a new notebook and upload the files from:

```text
NotebookLM Sources/
```

### 6. Set portable environment variables

From inside the moved `AI MUSIC PRODUCTION` folder:

```bash
export AI_MUSIC_ROOT="$(pwd)"
export NOTEBOOKLM_BIN="$(which notebooklm)"
export ABLETON_MCP_BIN="$(which ableton-live-mcp)"
```

To make these permanent, add them to `~/.zshrc` on the new computer.

### 7. Run a health check

From inside `AI MUSIC PRODUCTION`:

```bash
pwd
python3 tools/get_tempo.py
./tools/capture_strings.sh 1 /tmp/test_tap.wav
```

Expected behavior:

- `pwd` shows the new project location.
- `tools/get_tempo.py` works only if AbletonOSC is active.
- `tools/capture_strings.sh` works only if Ableton Live, Ableton_Live_MCP, and AgentAudioTap are active.

---

## What Can Live Inside This Folder?

| Item | Can be bundled in root? | Still needs install/link? | Notes |
|---|---:|---:|---|
| `CLAUDE.md`, `GEMINI.md`, source docs, skills | Yes | No | Fully portable |
| Ableton Remote Scripts | Yes | Yes | Bundled in `machine-assets/`, copied into Ableton User Library |
| AgentAudioTap Max for Live files | Yes | Yes | Bundled in `machine-assets/`, copied into Ableton User Library |
| `ableton-live-mcp` server binary | Not reliably | Yes | Install with `pipx`; console scripts/venvs are machine-specific |
| NotebookLM auth | No | Yes | Login is tied to the new machine/profile |

---

## Agent Rule

When this folder is moved:

1. Determine the project root from the current working directory or `AI_MUSIC_ROOT`.
2. Read `CLAUDE.md` / `GEMINI.md`.
3. Read `CURRENT PROJECT STATE.md` if it contains saved state.
4. Verify external tools before using them.
5. Do not rewrite saved project state unless Adi says "save session".

---

## Quick Health Check On A New Computer

From inside the moved folder:

```bash
pwd
python3 tools/get_tempo.py
"/path/to/AI MUSIC PRODUCTION/tools/capture_strings.sh" 1 /tmp/test_tap.wav
```

Expected:

- `pwd` shows the new project location.
- `tools/get_tempo.py` works only if AbletonOSC is active.
- `tools/capture_strings.sh` works only if Ableton Live, Ableton_Live_MCP, and AgentAudioTap are active.
