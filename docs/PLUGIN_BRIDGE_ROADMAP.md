# PluginBridge — Build Roadmap & Reference
> Last updated: May 2026
> Purpose: AI-controllable VST3/AU plugin that hosts third-party plugins, exposes their parameters via MCP, and provides real-time audio analysis.
> Rule: Feature-rich but EXTREMELY token efficient. Never return more than needed.
> Technical deep-dive: see `docs/PLUGINBRIDGE_REFINED_ROADMAP.md` (architecture, code, CMakeLists, risk register)

---

## What We're Building

A JUCE-based VST3/AU plugin called **PluginBridge** that:
1. Loads inside ANY DAW (Ableton, Logic, FL Studio, Reaper, etc.)
2. Hosts any third-party VST3/AU plugin inside itself (audio routed through)
3. Exposes ALL plugin parameters to Claude via a local MCP server
4. Analyzes live audio in real-time (LUFS, stereo width, frequency bands)
5. Works with Claude, Codex CLI, Gemini CLI — any AI that speaks MCP
6. Supports multiple instances simultaneously (one per track/bus) — zero config for producer

**What stays unchanged:** Ableton MCP, NotebookLM, Mem0, audio-analyzer, Gemini CLI, Basic Pitch — zero changes to existing system.

---

## Design Laws (Non-Negotiable)

| Law | Rule |
|---|---|
| No full dumps | Never return all parameters. Search → get IDs → fetch only those |
| Delta only | After param change, return only what shifted |
| Single line responses | Numbers only. No verbose JSON |
| Batch operations | Set 10 params in one call, not 10 calls |
| Threshold alerts | Only flag if value crosses a problem zone |
| Silence detection | No analysis returned if transport is stopped / RMS below threshold |
| Zero producer config | Ports auto-assigned. Track names from dropdown. No manual setup ever |

**Target:** <2,000 tokens per full mixing session (vs ~15,000 tokens with current approach)

---

## How It Fits Into Existing System

```
Claude Code
  │
  ├── ableton-live-mcp        (port 16619)  ← UNCHANGED
  │     └── Tracks, clips, tempo, routing via Ableton LOM
  │
  └── plugin-bridge-mcp       (port 16620)  ← NEW — one permanent entry in .mcp.json
        └── Meta-MCP server (reads registry, routes to all instances)
              ├── PluginBridge on "Vocal Bus"    → auto-port e.g. 16631
              ├── PluginBridge on "Drum Bus"     → auto-port e.g. 16644
              ├── PluginBridge on "Strings"      → auto-port e.g. 16652
              └── PluginBridge on "Mix Bus"      → auto-port e.g. 16628
```

`.mcp.json` addition — **one line, forever, no matter how many instances:**
```json
"plugin-bridge": { "url": "http://localhost:16620" }
```

---

## Multi-Instance Auto-Discovery

Producers load PluginBridge on any track. Zero port config. It just works.

### How It Works

```
Each PluginBridge instance on startup:
  1. Ask OS for a free port → bind to port 0 → OS assigns (e.g. 16631)
  2. Write to /tmp/pluginbridge-registry.json:
     { "Vocal Bus": 16631, "Drum Bus": 16644, "Strings": 16652 }
  3. On plugin close → remove self from registry automatically
```

Meta-MCP server at fixed port 16620 reads that file and routes all calls.

### Producer Workflow (30 seconds total setup)

```
1. Load PluginBridge on Vocal Bus
   → Select "Vocal Bus" from dropdown (one click)
   → Port: auto-assigned, invisible to producer

2. Load PluginBridge on Drum Bus
   → Select "Drum Bus" from dropdown (one click)
   → Port: auto-assigned, invisible to producer

3. Claude calls list_instances() → ["Vocal Bus", "Drum Bus"] → ready instantly
```

---

## Plugin UI — Channel Selector

Producer sees a simple UI. One dropdown, one status indicator. That's it.

```
┌─────────────────────────────────┐
│  PluginBridge                   │
│                                 │
│  Channel: [Vocal Bus       ▼]  │  ← pick once, done
│  Plugin:  [Pro-Q 4         ▼]  │  ← loaded child plugin
│  Status:  ● Active  port:auto  │  ← port invisible to producer
└─────────────────────────────────┘
```

### Standard Channel List (baked into dropdown)

Matches the real production template used in sessions:

```
── Vocals ──              ── Buses ──
  Lead Vocal                Vocal Bus
  Backing Vocal             Drum Bus
  Adlibs                    Guitar Bus
                            Synth Bus
── Drums ──                 Strings & Brass Bus
  Kick                      Music Bus / Instrument Bus
  Snare                     Master Bus / Mix Bus
  Hi-Hat
  Overheads               ── FX ──
  Percussion                Reverb
                            Delay
── Bass ──                  FX
  Bass / 808                Foley / Ambient
  Bass Guitar
  Sub Bass                ─────────────
  Synth Bass              Custom...   ← type any name
── Keys & Guitar ──
  Piano / Keys
  Acoustic Guitar
  Electric Guitar

── Synths ──
  Synth Lead
  Synth Pad
  Synth Pluck

── Strings & Brass ──
  Strings
  Brass
  Woodwind
  Orchestral
```

### Channel Validation (stolen from EchoJay — good idea)

Plugin cross-checks the audio signal against the selected channel type.
If mismatch detected → flag it in `get_analysis()` output:

```
get_analysis("Vocal Bus") → "WARN: full-mix signal detected on Vocal Bus | -14.2 LUFS | ..."
```

Saves the AI from giving wrong advice based on incorrect routing.

---

## Knowledge Pipeline Integration

```
get_analysis("Strings") → "-18 LUFS | bass +4dB hot | highs weak 8kHz"  [~50 tokens]
      ↓
Gemini CLI → NotebookLM → "Cut 200Hz -3dB, boost 8kHz +2dB"             [~200 tokens]
      ↓
set_params("Strings", "Pro-Q 4", {band1: -3, band2: +2})                 [~20 tokens]
      ↓
get_analysis("Strings") → "-14.1 LUFS | balanced"                        [~30 tokens]
```

Total: ~300 tokens per full EQ correction loop.

Multi-bus session example:
```
get_analysis("Vocal Bus")  → "-16.2 LUFS | 3kHz harsh | wide 0.9"   ~50 tokens
get_analysis("Drum Bus")   → "-12.0 LUFS | bass +5dB | TP:-0.3"     ~50 tokens
get_analysis("Strings")    → "-18.1 LUFS | 200Hz mud | stereo 0.6"  ~50 tokens
```
~150 tokens to diagnose 3 entire buses simultaneously.

---

## MCP API — 6 Tools

| Tool | Input | Returns | Max Tokens |
|---|---|---|---|
| `list_instances()` | — | `["Vocal Bus", "Drum Bus", "Strings"]` | ~30 |
| `list_plugins(track)` | `"Vocal Bus"` | `["Pro-Q 4", "De-esser"]` | ~20 |
| `search_param(track, plugin, keyword)` | `"Vocal Bus", "Pro-Q 4", "band 1"` | `[{id:12, name:"Band 1 Gain", value:0.0}]` | ~100 |
| `get_params(track, plugin, [ids])` | `"Vocal Bus", "Pro-Q 4", [12,13]` | `{12: 0.7, 13: 0.5}` | ~30 |
| `set_params(track, plugin, {id: val})` | `"Vocal Bus", "Pro-Q 4", {12: 0.7}` | `"ok"` | ~5 |
| `get_analysis(track)` | `"Vocal Bus"` | `"-14.2 LUFS \| bass +3dB \| stereo 0.8"` | ~50 |

### Usage Pattern (always follow this order)
```
1. list_instances()   → see what's loaded
2. search_param       → find param ID by keyword
3. set_params         → apply using ID (not name)
4. get_analysis       → verify result
```

---

## Real-Time Analysis Output

`get_analysis(track)` returns one compact line:
```
"-14.2 LUFS | TP:-1.1 | bass:+3dB hot | highs:-2dB weak | stereo:0.8 | key:C maj"
```

With channel validation flag when routing is wrong:
```
"WARN:signal-mismatch | -14.2 LUFS | TP:-1.1 | bass:+3dB | stereo:0.8"
```

**What it measures (inside processBlock — no file, no polling):**
- LUFS Integrated + True Peak + LRA
- Frequency band energy: sub_bass, bass, low_mid, mid, high_mid, highs, brilliance
- Stereo width (M/S) + phase correlation
- Spectral centroid (bright vs dark)
- Key estimation (pitch class accumulation)
- RMS per band
- Channel type validation (signal mismatch detection)

**Advantage over current audio-analyzer:**
- No WAV capture needed
- No AgentAudioTap polling (ghost audio bug eliminated)
- Per-track analysis (not full mix)
- Before/after comparison in one session
- Multiple buses analyzed in one shot

---

## GitHub Sources — Research Verdicts (Post Deep-Dive)

| Repo | Verdict | Use As |
|---|---|---|
| [getdunne/juce-plugin-wrapper](https://github.com/getdunne/juce-plugin-wrapper) | ❌ Dead (2021), JUCE 6, GPL-3, hardcoded plugin | **Reference only** — copy bus-sync pattern (~30 lines) |
| [JUCE AudioPluginHost](https://github.com/juce-framework/JUCE/blob/master/extras/AudioPluginHost/AudioPluginHost.jucer) | ✅ Gold standard | **Primary reference** — all hosting patterns extracted |
| [juce-framework/JUCE](https://github.com/juce-framework/JUCE) | ✅ Core framework | **JUCE 8 + CMake** — build fresh, don't fork wrapper |
| [cpp-httplib](https://github.com/yhirose/cpp-httplib) | ✅ Perfect fit | **Use directly** — header-only, MIT, background thread |
| [nlohmann/json](https://github.com/nlohmann/json) | ✅ Standard | **Use directly** — header-only, MIT, JSON-RPC parsing |
| [klangfreund/LUFSMeter](https://github.com/klangfreund/LUFSMeter) | ✅ Drop-in | **Embed directly** — MIT, 4 files, clean API |
| [adamstark/Sound-Analyser](https://github.com/adamstark/Sound-Analyser) | ⚠️ GPL | **Reference only** — reimplement spectral math with JUCE `dsp::FFT` |
| [blubass/FunkyMooseViz](https://github.com/blubass/FunkyMooseViz) | ⚠️ GPL | **Reference only** — stereo width math only |
| [josmithiii/mcp-servers-jos](https://github.com/josmithiii/mcp-servers-jos) | ✅ Shows structure | **Reference** — TypeScript/stdio, we implement JSON-RPC in C++ |

---

## Phase Roadmap

### Phase 1 — Core Plugin (Foundation) — 4 Sprints
**Goal:** Claude can read/write any third-party plugin parameter in any DAW

**Sprint 1 — Minimal Viable Plugin (Week 1)**
- [ ] Create JUCE 8 CMake project (VST3 + AU targets) — build fresh, do NOT fork juce-plugin-wrapper
- [ ] `PluginBridgeProcessor` — empty shell, audio passthrough only
- [ ] Load in Ableton — verify audio passthrough works
- [ ] Add `httplib.h` + `json.hpp` (both single-header, MIT)
- [ ] Start background HTTP server thread
- [ ] Verify `curl http://localhost:16620/mcp` responds from inside Ableton

**Sprint 2 — Plugin Hosting (Week 2)**
- [ ] `HostedPluginManager` — load VST3/AU by file path via native file picker
- [ ] GUI: channel selector dropdown (standard track list baked in + Custom) + Load Plugin button
- [ ] Audio routing through hosted plugin (copy bus-sync pattern from juce-plugin-wrapper — ~30 lines only)
- [ ] Parameter enumeration via `getParameters()` + `HostedAudioProcessorParameter`
- [ ] Instance auto-registers to `/tmp/pluginbridge-registry.json` on load (name + OS-assigned port)
- [ ] Instance removes itself from registry on close

**Sprint 3 — MCP Tools (Week 3)**
- [ ] Meta-MCP server at fixed port 16620 — reads registry, proxies to correct instance
- [ ] Implement JSON-RPC 2.0: `initialize` → `notifications/initialized` → `tools/list` → `tools/call`
- [ ] 6 tools: `list_instances`, `list_plugins`, `search_param`, `get_params`, `set_params`, `get_analysis` (stub)
- [ ] `set_params` uses `beginChangeGesture`/`endChangeGesture` for proper DAW automation
- [ ] Single `.mcp.json` entry — test from Claude Code
- [ ] Test multi-instance: 2× PluginBridge → `list_instances()` returns both
- [ ] Token test: full Pro-Q 4 session < 500 tokens

**Done when:** Claude sets Pro-Q 4 Band 1 Gain on "Vocal Bus" via `set_params()` in Ableton. Full loop < 500 tokens.

---

### Phase 2 — Real-Time Analysis — Sprint 4 (Week 4)
**Goal:** Replace AgentAudioTap + audio-analyzer for per-track analysis

- [ ] Embed `Ebu128LoudnessMeter` from klangfreund (MIT, 4 files) — LUFS Integrated + LRA
- [ ] Add True Peak via `juce::dsp::Oversampling<float>` (4× oversample → peak detect → dBTP)
- [ ] Add JUCE `dsp::FFT` (1024-point, Hann window) + ring buffer accumulator in `processBlock()`
- [ ] Implement 7-band energy: sub_bass / bass / low_mid / mid / high_mid / highs / brilliance
- [ ] Add M/S stereo width + phase correlation
- [ ] Add spectral centroid (bright / dark / balanced)
- [ ] Silence gate: return `"silent"` if RMS < -60dB
- [ ] Channel validation: flag signal mismatch vs selected channel type in output
- [ ] All analyser values use `std::atomic<float>` — safe across audio + HTTP threads
- [ ] Token test: full analysis call < 60 tokens

**Done when:** Claude calls `get_analysis("Strings")` and gets LUFS + EQ problem in one compact line.

---

### Phase 3 — Pipeline Integration
**Goal:** Full loop working: analyze → knowledge → fix → verify

- [ ] Test full loop: `get_analysis()` → Gemini → NotebookLM → `set_params()` → verify
- [ ] Test with Pro-Q 4 (EQ), Serum 2 (synthesis), Diva (synthesis)
- [ ] Test in Logic Pro (AU build) + Ableton (VST3 build)
- [ ] Test multi-bus session: analyze Vocal Bus + Drum Bus + Strings in one Claude turn
- [ ] Before/after comparison (captures analysis pre/post param change)
- [ ] Token budget test: full multi-bus session < 2,000 tokens

**Done when:** Claude fixes a muddy strings mix using only PluginBridge + NotebookLM, no manual EQ.

---

### Phase 4 — Multi-AI Support
**Goal:** Any AI CLI can use PluginBridge

- [ ] Test Codex CLI → PluginBridge connection
- [ ] Test Gemini CLI → PluginBridge connection
- [ ] Document HTTP API (tool names, input/output format)
- [ ] Make MCP server auth-free on localhost (safe, local only)

**Done when:** Gemini CLI sets a Serum 2 filter cutoff via PluginBridge.

---

### Phase 5 — Polish + Release
**Goal:** Stable, documented, open source

- [ ] Full error handling (plugin not found, param out of range, DAW not playing, port collision)
- [ ] Registry cleanup on crash (stale entries auto-expire after 30s heartbeat timeout)
- [ ] cpp-httplib thread pool capped at 2-4 threads (reduce OS thread pressure inside DAW)
- [ ] Code-sign for Mac (Gatekeeper)
- [ ] Build AU (Logic) + VST3 (Ableton/others) from same CMake codebase
- [ ] Channel dropdown: make list user-editable (Phase 1 = hardcoded, Phase 5 = editable)
- [ ] Write README with setup instructions
- [ ] Open source on GitHub

---

## What PluginBridge Unlocks

| Plugin | Before | After |
|---|---|---|
| Pro-Q 4 | ❌ 1 param (VST3 sandbox) | ✅ All 200+ bands fully controlled |
| Serum 2 | ❌ Locked | ✅ Oscillators, filter, LFOs, effects |
| Diva, Omnisphere | ❌ Locked | ✅ Full control |
| Ableton native (EQ Eight) | ✅ Works | ✅ Still works via existing MCP |

---

## Competitive Advantage vs EchoJay

EchoJay researched May 2026 — [echojay.ai](https://www.echojay.ai)

EchoJay does: real-time metering (LUFS, stereo, EQ curve), AI mix feedback via their own web app, 60+ channel types in dropdown, A/B reference playback. Useful tool. Locked to their ecosystem.

**What EchoJay cannot do — PluginBridge's entire advantage:**

| Feature | EchoJay | PluginBridge |
|---|---|---|
| Control plugin parameters | ❌ analysis only | ✅ full read/write |
| Any AI CLI (Claude, Codex, Gemini) | ❌ locked to their app | ✅ standard MCP/HTTP |
| NotebookLM knowledge pipeline | ❌ | ✅ |
| Any DAW | ✅ VST3/AU/AAX | ✅ VST3/AU |
| Multi-instance per bus | ✅ | ✅ + auto-discovery |
| Channel type dropdown | ✅ 60+ types | ✅ same concept |
| Channel signal validation | ✅ | ✅ (Phase 2) |
| Token efficient by design | ❌ their own chat UI | ✅ |
| Open source | ❌ | ✅ planned |
| Works with your source-of-truth files | ❌ | ✅ via Gemini → NotebookLM |

**The gap:** EchoJay tells you what's wrong. PluginBridge fixes it.

---

## Build Notes

- Start Phase 1 only. Each phase ships working. Never skip.
- **Do NOT fork juce-plugin-wrapper** — dead, GPL, JUCE 6. Build fresh with JUCE 8 + CMake.
- **Do NOT use Sound-Analyser or Gist for FFT** — GPL. Use JUCE `dsp::FFT` built-in.
- MCP transport: JSON-RPC 2.0 over HTTP POST — not stdio. Plugin can't be a subprocess.
- Registry file: `/tmp/pluginbridge-registry.json` — written by each instance, read by meta-MCP.
- Port range: OS auto-assigns from ephemeral range. Meta-MCP always stays at 16620.
- Channel dropdown list is hardcoded in Phase 1. User-editable in Phase 5.
- Thread safety: analyser values must be `std::atomic<float>` — never call `getValue()` from HTTP thread.
- If a better GitHub project is found, update the "GitHub Sources" section before using it.
- Full technical spec, code skeletons, CMakeLists.txt: `docs/PLUGINBRIDGE_REFINED_ROADMAP.md`
