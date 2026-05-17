# Phone UI/UX Brief — AI Music Production Assistant
> Paste this file at the start of any AI chat to get UI/UX help without prior context.

---

## WHO I AM

Adi — Stage 3 music production diploma student, Mumbai.
Primary DAW: Ableton Live 12.4 on MacBook M4 (24GB RAM).
Phone: Samsung Galaxy S23 (Android).

---

## THE SYSTEM (what already exists)

I have a custom AI co-producer that controls Ableton Live directly from the terminal.

```
Samsung S23 (Android)
  → Tailscale VPN (same network as Mac)
  → Termius SSH app → Mac terminal
  → Gemini CLI (loaded with project context)
  → Ableton Live MCP (TCP 16619)
  → Ableton responds: creates tracks, sets EQ, changes BPM, routes buses
```

**What the AI can do via terminal commands:**
- Set BPM, key, tempo
- Create/rename/route tracks
- Add and configure devices (EQ, compressor, reverb)
- Capture audio and run spectral analysis
- Query a 257-source music knowledge base (NotebookLM)
- Recall past mixing decisions (Mem0 memory)

**Current tools on S23:**
- Termius (SSH client) — text terminal, monospace, no UI
- Google Voice Typing — tap mic, speak, it types
- Tailscale — VPN, already configured

---

## THE PROBLEM

When I'm producing in Ableton (hands on piano or controller), I need to ask the AI questions or give it commands. Right now:

1. I pick up phone
2. Open Termius (SSH terminal)
3. Tap the keyboard mic
4. Speak my command
5. Wait for Gemini to respond in the terminal
6. Read a wall of terminal text
7. Put phone down and continue

**Pain points:**
- Terminal text is hard to read on phone (small, dense, monospace)
- No visual feedback that command was received
- Can't tell if Ableton executed it without looking at Mac screen
- Long AI responses are unreadable mid-session
- Voice input works but has no confirmation — did it hear me right?
- No way to quickly browse common commands without typing
- Context switching breaks creative flow

---

## WHAT I NEED HELP DESIGNING

A **phone UI/UX** that sits on top of the existing SSH + Gemini CLI setup. This could be:

### Option A — A custom Android app
- Connects via SSH to Mac (same Tailscale IP)
- Sends voice or quick-tap commands to Gemini CLI
- Shows Ableton state (BPM, current track, last AI action)
- Clean, dark, music-producer aesthetic

### Option B — A web UI hosted on Mac
- Simple local web server on Mac (Python/Node, ~50 lines)
- Phone accesses via Tailscale IP in browser
- Voice input via Web Speech API
- Shows command history + Ableton status
- Works in Chrome on S23 — no app install needed

### Option C — Improve Termius workflow
- Custom SSH snippet buttons in Termius (pre-programmed common commands)
- Colour-coded output parsing
- Minimal approach — no new software

---

## DESIGN CONSTRAINTS

- **One hand operation** — other hand often on piano or controller
- **Dark theme** — studio environment, dim lighting
- **Glanceable** — I look at phone for 2 seconds max mid-session
- **Voice-first** — typing should be optional, not required
- **No internet required** — everything runs locally on Mac via Tailscale
- **Android S23** — 6.1" screen, Samsung One UI
- **Low latency feel** — command should feel instant even if Gemini takes 3-5s
- **No login/auth friction** — I'm the only user

---

## COMMON COMMANDS (what I say most often)

These are the 80% use cases:

```
"Set BPM to [number]"
"What's the current BPM?"
"Add EQ Eight to [track name]"
"Capture 8 bars of strings and analyze"
"What's clashing in the low end?"
"Create a MIDI track called [name]"
"Load session [project name]"
"What velocity for legato strings?"
"Set up kick sidechain on the 808"
"What key is this recording in?"
```

---

## IDEAL EXPERIENCE (my vision)

1. Pick up phone — screen shows last AI action + current Ableton state at a glance
2. Tap big mic button — speak command naturally
3. Visual pulse/animation while Gemini processes (3–5 sec)
4. Response shown in **2–3 lines max** (key info only, not full terminal output)
5. Ableton confirmation: "✓ EQ Eight added to Strings Bus"
6. Put phone down — 10 seconds total interaction

**Secondary:** A row of 6–8 tap buttons for the most common commands (BPM read, spectrum capture, save session, etc.) so I don't even need to speak.

---

## TECHNICAL NOTES FOR THE DEVELOPER

- Mac runs Python 3.11+ and Node.js (via Homebrew)
- Gemini CLI is already installed: invoked as `gemini` in terminal
- Context file auto-loads: `GEMINI.md` in project folder
- Ableton MCP responds on TCP 16619 (localhost on Mac only — not exposed externally)
- All Ableton state is read/written via Python code passed to `execute()` MCP tool
- The AI (Gemini) is what parses natural language → generates Python → sends to Ableton
- Phone and Mac are on same Tailscale network (100.x.x.x range)
- Mac's Tailscale IP is static per device (doesn't change)

---

## WHAT I'M ASKING YOU (the AI reading this)

Help me design and/or build **Option B** (web UI on Mac) first — it's the fastest path with no app install.

Specifically:
1. Design the screen layout (wireframe or description)
2. Suggest the tech stack (Python FastAPI? Node? Plain HTML?)
3. Show me the UX flow for a voice command
4. Design how AI responses get summarized to 2–3 lines for the phone screen
5. Show me a basic working prototype I can run on my Mac today

If you think Option A (Android app) or Option C (Termius improvement) is better, argue for it — I'm open.

---

## FILES THAT EXIST (for reference if needed)

All in: `/Volumes/T7 Shield/Users/Aditya/Downloads/AI MUSIC PRODUCTION/`

| File | Purpose |
|---|---|
| `GEMINI.md` | Full Gemini context (pipeline, MCP tools, LOM rules) |
| `CLAUDE.md` | Full Claude context (same info, Claude-specific) |
| `ONBOARDING.md` | Complete system history and architecture |
| `tools/capture_strings.sh` | Example of how shell scripts interact with Ableton |
| `.mcp.json` | MCP server config |

---

*This brief is self-contained. The AI reading this does not need any prior conversation history.*
