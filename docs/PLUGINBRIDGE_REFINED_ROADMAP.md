# PluginBridge — Refined Roadmap (Post-Research)
> Updated after deep-diving all referenced GitHub repos + MCP spec
> Status: Research complete. Ready to build.

---

## Research Verdicts

| Repo | Verdict | Use As |
|---|---|---|
| `getdunne/juce-plugin-wrapper` | ❌ Don't fork — dead (2021), JUCE 6, GPL-3, hardcoded plugin, no param exposure | **Reference only** — copy bus-sync pattern |
| JUCE AudioPluginHost | ✅ Gold standard | **Primary reference** — all hosting patterns extracted |
| `cpp-httplib` | ✅ Perfect fit | **Use directly** — header-only, background thread, MIT |
| `klangfreund/LUFSMeter` | ✅ Drop-in | **Embed directly** — MIT, 4 files, clean API |
| `adamstark/Sound-Analyser` / Gist | ⚠️ GPL — can't use code directly | **Reference only** — reimplement spectral math with JUCE FFT |
| `josmithiii/mcp-servers-jos` | ✅ Shows MCP structure | **Reference** — but uses stdio/TypeScript, we need HTTP/C++ |

---

## Critical Architecture Decisions (Changed From Original Plan)

### 1. Don't Fork juce-plugin-wrapper → Build Fresh with CMake

**Why:** The wrapper is JUCE 6, Projucer-only, GPL-3, and missing everything we need (parameter enumeration, runtime plugin selection, FX mode). Starting fresh with JUCE 8 + CMake is faster than upgrading a 4-year-old skeleton.

**What to copy from it:** The `getBusesPropertiesFromProcessor()` + `prepareToPlay()` bus-sync pattern (~30 lines). That's it.

### 2. Plugin Architecture: NOT a Graph — Single Hosted Instance

The original plan says "host any plugin." The AudioPluginHost uses `AudioProcessorGraph` for routing multiple plugins. **PluginBridge doesn't need this.** We host ONE plugin at a time (the one on the track). Architecture:

```
PluginBridgeProcessor (our AudioProcessor — the outer shell)
  ├── hostedPlugin: AudioPluginInstance*  (the inner VST3/AU)
  ├── httpServer: httplib::Server         (background thread, port 16620)
  ├── analyser: AudioAnalyser             (LUFS + FFT in processBlock)
  └── processBlock():
        buffer → analyser.process(buffer)
               → hostedPlugin->processBlock(buffer, midi)
               → output
```

No graph. No AudioProcessorPlayer. No AudioDeviceManager. The DAW drives our `processBlock` — we just intercept + forward.

### 3. MCP Transport: Streamable HTTP (Not stdio)

**Why:** Plugin runs inside a DAW process — can't spawn as a subprocess. Must expose HTTP endpoint.

**Protocol:** JSON-RPC 2.0 over HTTP POST to `http://127.0.0.1:16620/mcp`

**Required handshake:** `initialize` → `notifications/initialized` before any tool calls.

### 4. Plugin Discovery: File Path Based (Not System Scan)

Don't scan the entire system on load. Instead:
- User loads PluginBridge on a track
- PluginBridge GUI has a "Load Plugin" button → native file picker
- User selects a `.vst3` or `.component` file
- We call `formatManager.createPluginInstanceAsync(desc, sr, bs, callback)`
- Plugin state (which inner plugin to load) persists via `getStateInformation()`

This avoids the AudioPluginHost's `KnownPluginList` dependency entirely.

### 5. Spectral Analysis: Use JUCE DSP FFT (Not Gist/KissFFT)

**Why:** Gist is GPL. JUCE has `juce::dsp::FFT` built-in (optimized, uses vDSP on macOS). Spectral features (centroid, crest, band energy) are each 5-10 lines of math.

### 6. True Peak: Add via 4× Oversampling

LUFSMeter doesn't include True Peak. Add it using `juce::dsp::Oversampling<float>` (4× oversample → peak detect → report in dBTP).

---

## Revised Phase 1 — Core Plugin + MCP Server

### File Structure
```
PluginBridge/
├── CMakeLists.txt                    (JUCE 8 CMake)
├── libs/
│   ├── httplib.h                     (cpp-httplib, single header)
│   └── json.hpp                      (nlohmann/json, single header)
├── Source/
│   ├── PluginBridgeProcessor.h/.cpp  (main AudioProcessor)
│   ├── PluginBridgeEditor.h/.cpp     (GUI — load button, channel dropdown, param list)
│   ├── HostedPluginManager.h/.cpp    (load/unload inner plugin, param enumeration)
│   ├── McpServer.h/.cpp              (HTTP server + JSON-RPC + tool dispatch)
│   └── AudioAnalyser.h/.cpp          (Phase 2 — LUFS + FFT)
└── Resources/
    └── (icons, etc.)
```

### Key Classes

#### `HostedPluginManager`
```cpp
class HostedPluginManager {
public:
    void loadPlugin(const File& pluginFile, double sampleRate, int blockSize);
    void unloadPlugin();
    
    AudioPluginInstance* getPlugin() const;
    bool isLoaded() const;
    
    // Parameter surface for MCP
    struct ParamInfo {
        int index;
        String id;          // stable HostedAudioProcessorParameter ID
        String name;
        float value;        // 0.0–1.0 normalized
        String displayText; // formatted value string
        bool automatable;
    };
    
    std::vector<ParamInfo> searchParams(const String& keyword) const;
    std::vector<std::pair<int, float>> getParams(const std::vector<int>& indices) const;
    bool setParams(const std::map<int, float>& values); // batch set
    StringArray getLoadedPluginNames() const;

private:
    AudioPluginFormatManager formatManager;
    std::unique_ptr<AudioPluginInstance> hostedPlugin;
    CriticalSection pluginLock; // protects hot-swap
};
```

#### `McpServer`
```cpp
class McpServer {
public:
    McpServer(HostedPluginManager& mgr, AudioAnalyser& analyser);
    ~McpServer();
    
    void start(int port = 16620);
    void stop();
    bool isRunning() const;

private:
    void handleInitialize(const nlohmann::json& req, nlohmann::json& res);
    void handleToolsList(const nlohmann::json& req, nlohmann::json& res);
    void handleToolsCall(const nlohmann::json& req, nlohmann::json& res);
    
    // Tool implementations
    nlohmann::json toolListPlugins();
    nlohmann::json toolSearchParam(const std::string& plugin, const std::string& keyword);
    nlohmann::json toolGetParams(const std::string& plugin, const std::vector<int>& ids);
    nlohmann::json toolSetParams(const std::string& plugin, const std::map<int, float>& values);
    nlohmann::json toolGetAnalysis();
    
    httplib::Server server;
    std::thread serverThread;
    HostedPluginManager& pluginManager;
    AudioAnalyser& analyser;
    String sessionId;
    bool initialized = false;
};
```

#### `PluginBridgeProcessor::processBlock`
```cpp
void PluginBridgeProcessor::processBlock(AudioBuffer<float>& buffer, MidiBuffer& midi)
{
    // 1. Pre-analysis (before processing — captures input signal)
    // analyser.captureInput(buffer);  // Phase 2
    
    // 2. Forward to hosted plugin
    if (auto* plugin = hostManager.getPlugin())
    {
        ScopedLock sl(hostManager.getPluginLock());
        plugin->processBlock(buffer, midi);
    }
    
    // 3. Post-analysis (after processing — captures output signal)
    // analyser.captureOutput(buffer);  // Phase 2
}
```

### MCP Protocol Implementation

Single endpoint: `POST http://127.0.0.1:16620/mcp`

```cpp
// In McpServer::start()
server.Post("/mcp", [this](const httplib::Request& req, httplib::Response& res) {
    auto body = nlohmann::json::parse(req.body);
    nlohmann::json response;
    
    std::string method = body["method"];
    
    if (method == "initialize")
        handleInitialize(body, response);
    else if (method == "notifications/initialized")
        return; // notification — no response
    else if (method == "tools/list")
        handleToolsList(body, response);
    else if (method == "tools/call")
        handleToolsCall(body, response);
    else {
        response = {
            {"jsonrpc", "2.0"},
            {"id", body["id"]},
            {"error", {{"code", -32601}, {"message", "Method not found"}}}
        };
    }
    
    res.set_content(response.dump(), "application/json");
});
```

### Tool Definitions (returned by `tools/list`)
```json
{
  "tools": [
    {
      "name": "list_plugins",
      "description": "List all loaded plugin instances",
      "inputSchema": { "type": "object", "properties": {} }
    },
    {
      "name": "search_param",
      "description": "Search plugin parameters by keyword. Returns matching param IDs and current values.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "plugin": { "type": "string", "description": "Plugin name from list_plugins" },
          "keyword": { "type": "string", "description": "Search term (e.g. 'band 1', 'cutoff', 'gain')" }
        },
        "required": ["plugin", "keyword"]
      }
    },
    {
      "name": "get_params",
      "description": "Get current values for specific parameter IDs",
      "inputSchema": {
        "type": "object",
        "properties": {
          "plugin": { "type": "string" },
          "ids": { "type": "array", "items": { "type": "integer" } }
        },
        "required": ["plugin", "ids"]
      }
    },
    {
      "name": "set_params",
      "description": "Set parameter values by ID. Batch operation.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "plugin": { "type": "string" },
          "values": { "type": "object", "description": "Map of param_id (int) → value (0.0–1.0)" }
        },
        "required": ["plugin", "values"]
      }
    },
    {
      "name": "get_analysis",
      "description": "Get real-time audio analysis. Returns LUFS, frequency balance, stereo width.",
      "inputSchema": { "type": "object", "properties": {} }
    }
  ]
}
```

---

## Revised Phase 2 — Audio Analysis

### Architecture
```cpp
class AudioAnalyser {
public:
    void prepareToPlay(double sampleRate, int blockSize);
    void processBlock(const AudioBuffer<float>& buffer); // called from audio thread
    
    // Thread-safe queries (called from HTTP thread)
    String getCompactAnalysis() const; // → "-14.2 LUFS | bass:+3dB | stereo:0.8"
    
private:
    // LUFS (from LUFSMeter — MIT, embed directly)
    Ebu128LoudnessMeter lufsMeter;
    
    // True Peak (JUCE oversampling)
    juce::dsp::Oversampling<float> oversampler{2, 2, juce::dsp::Oversampling<float>::filterHalfBandPolyphaseIIR};
    std::atomic<float> truePeak{0.0f};
    
    // FFT (JUCE built-in)
    juce::dsp::FFT fft{10}; // 1024-point
    juce::dsp::WindowingFunction<float> window{1024, juce::dsp::WindowingFunction<float>::hann};
    
    // Ring buffer (host blocks → analysis frames)
    std::array<float, 2048> ringBuffer{};
    int writePos = 0;
    
    // Band energy (7 bands)
    struct BandEnergy {
        std::atomic<float> sub_bass;   // 20-60 Hz
        std::atomic<float> bass;       // 60-250 Hz
        std::atomic<float> low_mid;    // 250-500 Hz
        std::atomic<float> mid;        // 500-2k Hz
        std::atomic<float> high_mid;   // 2k-4k Hz
        std::atomic<float> highs;      // 4k-8k Hz
        std::atomic<float> brilliance; // 8k-20k Hz
    } bands;
    
    // Stereo
    std::atomic<float> stereoWidth{0.0f};
    std::atomic<float> correlation{0.0f};
    
    // Spectral centroid
    std::atomic<float> centroid{0.0f};
    
    // Silence gate
    std::atomic<bool> isSilent{true};
    static constexpr float silenceThresholdDb = -60.0f;
};
```

### `getCompactAnalysis()` output format
```
"-14.2 LUFS | TP:-1.1 | bass:+3dB | mids:ok | highs:-2dB | stereo:0.8 | bright"
```

Rules:
- Only report bands that deviate >±2dB from flat reference
- "ok" for bands within ±2dB
- Stereo width as 0.0 (mono) to 1.0 (wide)
- "bright"/"dark"/"balanced" from spectral centroid
- Returns `"silent"` if RMS < -60dB (silence gate)
- Max ~60 tokens per call

---

## Implementation Order (What to Build First)

### Sprint 1 (Week 1): Minimal Viable Plugin
1. Create JUCE 8 CMake project (VST3 + AU targets)
2. `PluginBridgeProcessor` — empty shell that passes audio through
3. Build & load in Ableton — verify audio passthrough works
4. Add `httplib.h` + background server thread
5. Verify `curl http://localhost:16620/mcp` returns a response from inside Ableton

**Done when:** Plugin loads in Ableton, passes audio, responds to HTTP.

### Sprint 2 (Week 2): Plugin Hosting
6. `HostedPluginManager` — load a VST3 by file path
7. GUI: channel selector dropdown + file picker button
8. Audio routing through hosted plugin (copy bus-sync from juce-plugin-wrapper)
9. Parameter enumeration via `getParameters()` + `HostedAudioProcessorParameter`
10. Verify all Pro-Q 4 params visible in debug log

**Done when:** Pro-Q 4 loads inside PluginBridge, processes audio, params enumerated.

### Sprint 3 (Week 3): MCP Tools
11. Implement JSON-RPC dispatch (initialize → tools/list → tools/call)
12. `list_plugins` tool
13. `search_param` tool (fuzzy keyword match on param names)
14. `get_params` tool
15. `set_params` tool (with `beginChangeGesture`/`endChangeGesture`)
16. Add to `.mcp.json`, test from Claude Code
17. Token test: set a Pro-Q 4 band from Claude

**Done when:** Claude sets Pro-Q 4 Band 1 Gain via MCP. Full loop < 500 tokens.

### Sprint 4 (Week 4): Audio Analysis
18. Embed `Ebu128LoudnessMeter` (4 files, MIT)
19. Add JUCE FFT + Hann window + ring buffer accumulator
20. Implement 7-band energy calculation
21. Add M/S stereo width
22. Add True Peak via 4× oversampling
23. Implement `get_analysis` tool
24. Silence gate
25. Token test: full analysis < 60 tokens

**Done when:** `get_analysis()` returns meaningful data on a playing track.

---

## Build Requirements

| Dependency | Source | License | Size |
|---|---|---|---|
| JUCE 8 | git submodule | dual GPL/commercial | ~200MB |
| cpp-httplib | `httplib.h` drop-in | MIT | 1 file, 800KB |
| nlohmann/json | `json.hpp` drop-in | MIT | 1 file, 850KB |
| LUFSMeter core | 4 files copied | MIT | ~20KB |
| CMake 3.22+ | system | — | — |

### CMakeLists.txt skeleton
```cmake
cmake_minimum_required(VERSION 3.22)
project(PluginBridge VERSION 0.1.0)

add_subdirectory(JUCE)

juce_add_plugin(PluginBridge
    COMPANY_NAME "PluginBridge"
    PLUGIN_MANUFACTURER_CODE Plbr
    PLUGIN_CODE Plbr
    FORMATS VST3 AU
    PRODUCT_NAME "PluginBridge"
    IS_SYNTH FALSE
    NEEDS_MIDI_INPUT TRUE
    NEEDS_MIDI_OUTPUT TRUE
    IS_MIDI_EFFECT FALSE
    EDITOR_WANTS_KEYBOARD_FOCUS FALSE
    COPY_PLUGIN_AFTER_BUILD TRUE
)

target_sources(PluginBridge PRIVATE
    Source/PluginBridgeProcessor.cpp
    Source/PluginBridgeEditor.cpp
    Source/HostedPluginManager.cpp
    Source/McpServer.cpp
    Source/AudioAnalyser.cpp
    Source/LufsMeter/Ebu128LoudnessMeter.cpp
    Source/LufsMeter/SecondOrderIIRFilter.cpp
)

target_include_directories(PluginBridge PRIVATE
    libs/          # httplib.h, json.hpp
    Source/LufsMeter/
)

target_compile_definitions(PluginBridge PUBLIC
    JUCE_PLUGINHOST_VST3=1
    JUCE_PLUGINHOST_AU=1
    JUCE_WEB_BROWSER=0
    JUCE_USE_CURL=0
    DONT_SET_USING_JUCE_NAMESPACE=1
)

target_link_libraries(PluginBridge PRIVATE
    juce::juce_audio_utils
    juce::juce_audio_processors
    juce::juce_dsp
    juce::juce_gui_basics
    juce::juce_recommended_config_flags
    juce::juce_recommended_lto_flags
    juce::juce_recommended_warning_flags
)
```

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| VST3 hosting crashes on some plugins | Medium | High | Crash isolation: catch exceptions in processBlock, unload plugin on repeated crashes |
| Port 16620 conflict (multiple instances) | Certain | Medium | OS auto-assigns port; each instance registers in `/tmp/pluginbridge-registry.json`; meta-MCP at 16620 routes all |
| `createPluginInstanceAsync` fails for some AU | Medium | Medium | Fall back to sync `createPluginInstance()` with timeout |
| DAW sandbox blocks localhost HTTP | Low | High | Test in Ableton/Logic/Reaper early — if blocked, fall back to Unix domain socket |
| Parameter IDs not stable across plugin versions | Medium | Low | Always use `search_param` by name first, not cached IDs |
| Thread safety: HTTP handler reads param while audio writes | Certain | High | Use `std::atomic<float>` for param cache, never call `getValue()` from HTTP thread directly |

---

## What Changed From Original Roadmap

| Original Plan | Revised | Why |
|---|---|---|
| Fork juce-plugin-wrapper | Build fresh (CMake, JUCE 8) | Dead repo, GPL, JUCE 6, missing everything |
| Borrow AudioPluginHost settings file | Runtime file picker | Simpler, no dependency on external app |
| Use Gist/Sound-Analyser for FFT | Use JUCE `dsp::FFT` | GPL license conflict |
| Single port 16620 for all instances | OS auto-assigns port per instance + meta-MCP at 16620 routes all | Multiple tracks need independent access, zero producer config |
| cpp-httplib default thread pool | Cap at 2-4 threads | Reduce OS thread pressure in plugin host |
| Phase 3 "MCP + JUCE already exists" | Implement JSON-RPC from scratch in C++ | josmithiii repo is TypeScript/stdio — not usable |
| 5 tools | 6 tools (added `list_instances`) | Multi-instance support requires instance discovery |
| Manual port config | Auto-discovery via registry file | Producer-friendly: load and go |

---

## Next Step

Say "build" and the complete JUCE CMake project will be scaffolded with all source files ready for compilation.
