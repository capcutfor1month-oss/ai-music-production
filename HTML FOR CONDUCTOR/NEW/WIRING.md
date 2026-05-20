# Conductor — Wiring Reference
> Single source of truth for what's built, what's wired, and what changes at each stage.
> Update this whenever something is added or deferred.

---

## Current Stage: Browser Prototype

Working file: `HTML FOR CONDUCTOR/NEW/Claude version phase 2.html`
Bridge file:  `tools/conductor_bridge.py` (port 4601)
Start script: `tools/start_bridge.sh`

---

## Architecture

```
Chrome (HTML file)
  └── fetch() → conductor_bridge.py (localhost:4601)
                    ├── Ableton MCP (TCP 16619)
                    ├── notebooklm CLI (/opt/homebrew/.../notebooklm)
                    ├── audio-analyzer CLI (audio-analyzer-rs/cli)
                    └── /config → conductor_bridge_config.json
```

---

## What's Wired (Browser Stage)

### Settings Panels
| Panel | Wired To | Storage |
|---|---|---|
| Voice | Web Speech API (SpeechRecognition), TTS toggle, speed row | localStorage |
| Microphone | navigator.mediaDevices.enumerateDevices(), Web Audio AnalyserNode (live meter) | localStorage |
| Agent Folder | showDirectoryPicker() File System Access API | localStorage |
| Agent Permissions | 7 toggles (read, write, ableton, autoexec, terminal, confirm_delete, confirm_irrev) | localStorage |

### Integrations Page
| Row | Status | Notes |
|---|---|---|
| Conductor Bridge | Real — polls /ping every 8s | **Remove in Mac app** |
| Ableton MCP | Real — bridge checks TCP 16619 | Stays |
| NotebookLM | Real — bridge checks CLI path | Stays |
| Mem0 Memory | Assumed ready if bridge is up | Stays |
| Plugin Bridge | Ready if Ableton connected | Stays |

### Connection Setup Page
| Step | What it does |
|---|---|
| 1 — Conductor Bridge | Copy-able terminal command, auto-detects when bridge starts |
| 2 — Ableton MCP | Prefs instructions + MCP restart command |
| 3 — NotebookLM | Install command, auto-detect binary, custom path input → POST /config |
| 4 — Plugin Bridge | In-Ableton load instructions |

### Chat Toolbar
| Button | Wired To |
|---|---|
| Voice | Web Speech API — continuous + interimResults, fills input in real time |
| Analyze | `<input type="file" accept="audio/*">` picker (real file pick) |
| Auto Exec | Syncs with `permAutoExecToggle` + localStorage |

### Chat Messages
| Feature | Wired To |
|---|---|
| History | sessionStorage — survives panel close/reopen, clears on new tab |
| Copy button | navigator.clipboard.writeText() |
| Execute in Ableton | POST /ableton → bridge → Ableton TCP 16619 |

### Global APIs
```js
window.conductorPerms.get(key)   // read any permission live
window.conductorPerms.all()      // get all permissions as object
bridgeExecuteInAbleton(code)     // send Python to Ableton via bridge
bridgeQueryNotebookLM(question)  // query NotebookLM via bridge
```

---

## Context Window Strategy (Mac App Stage)

### How Clicky Does It (from actual source code — CompanionManager.swift)
- **Hard limit**: last 10 exchanges, oldest simply dropped (`removeFirst`) — no summarization
- **Old messages**: text only (transcript + response) — screenshots NOT re-sent for history
- **Current message**: always includes fresh screenshot of all monitors
- **max_tokens**: 1024 per response
- **Voice + chat**: same pipeline — voice is just transcribed to text first, then identical API call
- **No token counter shown to user**

```
Per message token cost (Clicky, after 10-exchange warmup — flat):
  System prompt:            ~300 tokens
  10 history entries (txt): ~2,000 tokens  ← text only, no old screenshots
  Current screenshot(s):    ~1,500–2,500 tokens  ← vision, expensive
  User transcript:          ~100 tokens
  ─────────────────────────────────────────
  Total input:              ~4,000–5,000 tokens/msg  (flat after msg 10)
  Max output:               1,024 tokens
```

### Our Strategy (Conductor — implement at Mac app stage)
No screenshots = no vision tokens. Replace with structured Ableton MCP data (text, cheap).

```
Per message token cost (Conductor, target):
  System prompt:            ~300 tokens  (fixed)
  Session summary:          ~300 tokens  (compressed old context — updated every 10 msgs)
  Last 8 exchanges (txt):   ~2,400 tokens
  Ableton state (on demand):~600 tokens  (only fetched when user asks about session)
  User message:             ~100 tokens
  ─────────────────────────────────────────
  Total input:              ~3,700 tokens/msg  (flat always)
  Max output:               1,500 tokens  (we can afford more — no vision cost)
```

### Why We're Cheaper

| | Clicky | Conductor |
|---|---|---|
| Context method | Screenshot every msg | MCP structured JSON (text) |
| Vision tokens | ~1,500–2,500/msg | 0 |
| History management | Drop oldest, no summary | Drop + compress into summary |
| Old message storage | Full text | Full text |
| Max output | 1,024 tokens | 1,500 tokens |
| **Cost per 100 messages** | **~$2.00–2.50** | **~$1.10–1.40** |

### Implementation Plan (Mac App Stage)

**1. Sliding window — last 8 exchanges**
```js
// Keep only last 8 user+assistant pairs before sending to Claude
const window = chatHistory.slice(-8);
```

**2. Session summary — compress every 10 messages**
```
After every 10 messages, ask Claude:
  "Summarise this conversation in 3 sentences,
   keeping all EQ values, track names, and decisions."
Store as sessionSummary (~300 tokens).
Include in every subsequent API call.
Old messages beyond window are dropped.
```

**3. Ableton state — on demand only**
```
Only include Ableton session JSON when:
  - User message contains: "track", "plugin", "session", "ableton", "bpm", "key"
  - fLive button is ON
  - Execute in Ableton was just used
Otherwise: skip it (saves ~600 tokens/msg on general questions)
```

**4. Token counter in UI**
- Show live token count in chat footer
- Warn at 80% of context window
- Offer "Summarise & clear" button

### Cost for a 6-Hour Mix Session

| | No management | With our strategy |
|---|---|---|
| Messages in 6hrs (~80) | ~800,000 tokens | ~296,000 tokens |
| Claude Sonnet cost | ~$3.00–4.00 | **~$1.10–1.50** |
| Per month (4 sessions) | ~$12–16 | **~$4.50–6.00** |

---

## What's Deferred

| Feature | Reason | When |
|---|---|---|
| Claude API chat | Can't use Claude API in browser stage | Mac app stage |
| Real chat responses | Placeholder 1.8s fake response right now | Mac app stage |
| Sliding window + session summary | Needs real Claude API | Mac app stage |
| Ableton state on demand | Needs bridge + real API wired together | Mac app stage |
| Token counter in UI | Needs real API to count | Mac app stage |
| Agent Permissions enforcement | Toggles save but don't gate agent actions yet | Mac app stage |
| Ableton Live context button | "fLive" button toggles but doesn't pull real state | Mac app stage |
| Audio file analysis result in chat | File picker works but doesn't send to analyzer yet | Next sprint |
| Mem0 memory_search on session start | Currently skipped in browser | Mac app stage |

---

## Mac App Stage — What Changes

### Remove
- Conductor Bridge row from Integrations page
- Step 1 ("Start Bridge") from Connection Setup page
- Manual bridge start instructions

### Auto-start
- `conductor_bridge.py` compiled to binary (PyInstaller)
- Launched automatically when app opens
- User never sees a terminal

### Replace
- Chrome WebView → Swift WKWebView (same HTML, no code changes)
- Claude API wired directly to chat input/output
- `fLive` button pulls real Ableton session state via bridge

### Mac App Shell (Swift — ~50 lines)
1. On launch: start bundled bridge binary
2. Open WKWebView → load HTML
3. Add menu bar icon

---

## Business & Pricing Strategy

### Competitive Landscape
| App | Price | What they give | Their API cost | Margin |
|---|---|---|---|---|
| Cluely | $19.99/month | Unlimited (OCR+audio, meetings) | ~$1.50–2.50/user | ~$17+ |
| Clicky | ~$24/month | 150 agent messages | ~$5/user | ~$19 |
| **Conductor** | **TBD** | **Music-specific + Ableton control** | **~$1.30–3.50/user** | **TBD** |

### Our Infrastructure Advantage
**Architecture is 100% local today.** No servers = no hosting cost = no data breach risk.
When we go server-based (see below), fixed costs stay tiny:
- VPS (DigitalOcean): $6–12/month
- Database (Supabase): free → $25/month at scale
- Stripe: 2.9% + ₹9 per transaction
- **Total fixed cost at <500 users: ~$20–30/month**

### Recommended Launch Phases

**Phase 1 — Beta (now)**
Free for testers. Collect real usage data. Learn actual msgs/session.

**Phase 2 — BYOK Launch (Mac app ready)**
User provides their own Anthropic API key. We charge for the app.
- India: ₹499/month or ₹3,999/year
- Global: $7.99/month or $59.99/year
- Our cost per user: **$0**
- Margin: **97%**
- Pitch: *"2x cheaper than Cluely. Actually controls Ableton."*

**Phase 3 — Managed Subscription (after 200+ users, once usage patterns known)**
We proxy API calls. User never touches Anthropic.

| Tier | India | Global | Msgs included | Our API cost | Margin |
|---|---|---|---|---|---|
| Starter | ₹399/mo | $4.99/mo | 150 msgs | ~₹110 | ~72% |
| Producer Pro | ₹999/mo | $11.99/mo | Unlimited (fair use ~400) | ~₹290 | ~71% |
| Studio | ₹2,499/mo | $29.99/mo | Unlimited + 2 seats | ~₹580 | ~77% |

**Fair use clause on "unlimited"**: >800 msgs/month throttled to 10 msgs/hour.
This protects margin — 99% of users never hit it.

---

## Server Architecture (Production Stage)

### Why Go Server-Based
Right now data stays local — we learn nothing about usage.
Server-based gives us:
- Usage patterns (which features, which genres, error rates)
- Ability to enforce subscriptions remotely
- Our Claude API key never touches user's device (uncrackable)
- A/B test system prompt improvements
- Push updates to AI behaviour without app update

### Architecture: Local → Server

**Current (browser prototype):**
```
Mac App (WebView)
  └── conductor_bridge.py (local)
        └── Claude API (user's own key)
```

**Production (server-based):**
```
Mac App (WebView + Swift shell)
  │
  └── HTTPS + JWT token
        │
        ▼
   conductor-api.yourdomain.com  (our VPS — FastAPI/Python)
        ├── /auth      → validate license, issue 2hr JWT
        ├── /chat      → proxy to Claude API (our key, never exposed)
        ├── /ableton   → forward to local bridge (still runs locally)
        ├── /analytics → log usage events (anonymized)
        └── /notebooklm → forward to local bridge
              │
              ▼
         Anthropic Claude API  (our master key, server-side only)
```

**Key point:** Ableton bridge STAYS LOCAL (TCP 16619 is localhost only).
Only the Claude API call goes through our server. Everything else is still local.

### What We Collect (Analytics — anonymized, GDPR-safe)
```json
{
  "event": "message_sent",
  "user_id": "hashed_device_id",       // never raw email
  "tier": "producer_pro",
  "session_length_mins": 42,
  "msg_category": "eq_question",       // classified server-side, not raw text
  "feature_used": ["voice", "analyze"],
  "ableton_connected": true,
  "token_count": 3720,
  "response_ms": 1840
}
```

**Categories we auto-classify (server-side, no raw messages stored):**
- EQ / compression / mixing
- Arrangement / structure
- Instrument programming (strings, tabla, etc.)
- Ableton execution (ran a command)
- NotebookLM query
- General question

This tells us which features users actually use — without storing what they said.

### Server Stack (keep it simple and cheap)
```
Language:   Python (FastAPI) — same as bridge, consistent codebase
Hosting:    DigitalOcean Droplet $6/month (scales to $12 at 1K users)
Database:   Supabase (Postgres) — free tier until 500 users
Auth:       JWT (PyJWT) — 2hr expiry, refresh token 30 days
Payments:   Stripe — handles INR + USD, subscriptions, webhooks
SSL:        Let's Encrypt (free, auto-renew)
```

---

## Security & Anti-Crack Strategy

### The Core Principle
> **The final authority must always be server-side.**
> Even if someone fully reverse-engineers the app, they hit a wall at our server.
> The app is just a UI — all real decisions happen where they can't reach.

### Layer 1 — API Key Never Leaves Our Server ✦ MOST IMPORTANT
```
Current (breakable):
  App stores user's API key in keychain → extractable

Production (unbreakable):
  Our Claude API key exists ONLY on our server
  App sends: { jwt_token, message }  → our server
  Our server adds API key → Anthropic
  App never sees our API key. Ever.
```
Even with full decompilation: no key to steal. The key lives in an environment variable on our VPS, never in any binary.

### Layer 2 — JWT Token with Short Expiry
```
On app launch:
  App sends: { license_key, device_fingerprint } → /auth
  Server returns: { access_token (2hr), refresh_token (30 days) }

Every message:
  App sends: { Authorization: "Bearer <access_token>", message }
  If token expired → auto-refresh using refresh_token
  If refresh_token expired → must re-login / re-verify subscription

If subscription cancelled:
  Server stops issuing refresh tokens
  After 30 days: app stops working. No grace. No crack.
```

### Layer 3 — Hardware Fingerprinting
```swift
// Bind license to device
let fingerprint = [
    SystemProfiler.serialNumber(),   // Mac serial number
    SystemProfiler.hardwareUUID(),   // Hardware UUID
    Host.current().name              // Hostname
].joined(separator: "|").sha256()

// Server allows max 2 devices per subscription
// Third device triggers: deactivate one first
```
Prevents license sharing. If someone posts their license key online, it breaks for them the moment a second person uses it.

### Layer 4 — Certificate Pinning
```swift
// App only trusts OUR SSL certificate, not just any valid HTTPS cert
// Blocks: proxies, MitM attacks, Burp Suite interception
// If attacker replaces our cert → URLSession throws, app stops

let pinnedPublicKey = "sha256/YOUR_CERT_PUBLIC_KEY_HASH"
// Uses URLSessionDelegate to validate on every request
```
Without this, attackers can intercept traffic with a proxy tool and reverse-engineer the API protocol. With this, they can't read a single packet even on their own machine.

### Layer 5 — Debugger Blocking (Swift)
```swift
// Called at app startup, before any business logic
import Darwin
func denyDebugger() {
    ptrace(PT_DENY_ATTACH, 0, nil, 0)
}
// If someone tries to attach LLDB/Instruments → process exits immediately
```

### Layer 6 — Binary Integrity Check
```swift
// App verifies its own binary hasn't been tampered with
func checkIntegrity() -> Bool {
    let bundleURL = Bundle.main.bundleURL
    let expectedHash = "SHA256_OF_RELEASE_BINARY" // baked in at build time
    let actualHash   = SHA256.hash(of: try! Data(contentsOf: bundleURL))
    return actualHash == expectedHash
}
// If patched binary → integrity fails → app exits
```

### Layer 7 — Code Obfuscation (SwiftShield)
All internal Swift class/method names get randomized at build time:
```
Before:  class LicenseValidator { func checkSubscription() }
After:   class Xk2mP9qRt7 { func vB4nL8wQs2() }
```
Makes decompiled code unreadable. Hoppper/IDA output becomes noise.

### Layer 8 — Server-Side Rate Limiting (Final Kill Switch)
```python
# On our server — no client-side code can bypass this
if user.messages_today > tier_limits[user.tier]:
    return 429  # Too Many Requests

if user.subscription_status != "active":
    return 403  # Forbidden — no crack can bypass a server 403
```

### What a Cracker Faces
```
Step 1: Decompile app         → obfuscated symbols, unreadable
Step 2: Patch integrity check → app detects tampered binary, exits
Step 3: Attach debugger       → PT_DENY_ATTACH, process killed
Step 4: Intercept traffic     → cert pinning blocks proxy
Step 5: Steal API key         → doesn't exist in binary
Step 6: Use stolen JWT        → expires in 2hrs, server rate-limits
Step 7: Share license key     → hardware fingerprint blocks 3rd device
```
**Every layer fails independently. All 7 must be broken simultaneously.**
That's not impossible, but it's a full-time job for a professional reverse engineer — not worth it for a music production tool.

### What We Can Never Fully Stop
Be honest: a determined, nation-state-level attacker can break anything.
But our threat model is:
- Piracy by regular users → Layers 1–3 stop 99% of this
- Script kiddies sharing cracks → Layers 4–5 stop this
- Professional crackers making a keygen → Layers 6–7 slow this massively

When a crack does appear (it will eventually), Layer 8 lets us push a server-side fix instantly — no app update needed.

---

## Key File Locations

| What | Path |
|---|---|
| HTML prototype | `HTML FOR CONDUCTOR/NEW/Claude version phase 2.html` |
| GPT reference | `HTML FOR CONDUCTOR/NEW/Gpt version phase 2.html` |
| Bridge server | `tools/conductor_bridge.py` |
| Bridge launcher | `tools/start_bridge.sh` |
| Bridge config | `tools/conductor_bridge_config.json` (auto-created on first save) |
| This doc | `HTML FOR CONDUCTOR/NEW/WIRING.md` |

---

## localStorage Keys

| Key | What |
|---|---|
| `conductor_voice_tts` | TTS enabled (bool) |
| `conductor_voice_lang` | Speech recognition language |
| `conductor_mic_device` | Selected mic deviceId |
| `conductor_mic_noise_sup` | Noise suppression toggle |
| `conductor_agent_folder_name` | Agent folder name |
| `conductor_perm_*` | All 7 permission toggles |
| `conductor_nlm_path` | NotebookLM binary path (local fallback) |

## sessionStorage Keys

| Key | What |
|---|---|
| `conductor_chat` | Full chat history array (JSON) |
