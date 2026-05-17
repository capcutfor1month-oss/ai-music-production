# Stage 2: Mixing Workflow
## Creative & Advanced Mixing (Production Already Solved the Frequency Problems)

Because Stage 1 production was frequency-aware, mixing is NOT about fixing clashes.
It's about: depth, emotion, excitement, polish, and making every element feel intentional.
This is where the track goes from "sounds good" to "sounds like a real release."

---

## MINDSET SHIFT: PRODUCTION VS MIXING

| Production (Stage 1) | Mixing (Stage 2) |
|---|---|
| "Do these instruments fit together?" | "Does this feel exciting and emotional?" |
| Frequency architecture | Depth and dimension |
| Voicing and arrangement | Movement and automation |
| Technical decisions | Creative decisions |
| Remove clashes | Add polish and character |

---

## STEP 1: GAIN STAGING AUDIT (Before touching a single plugin)

Before anything creative, verify the foundation:

- Every channel peaks between **-18 and -12dBFS** (pre-fader, pre-plugins)
- Master fader at 0dB, master output below -6dBFS
- Disable or bypass ALL plugins temporarily — listen to the raw fader balance
- The raw balance should already feel like a rough mix (because Stage 1 was done right)
- If the raw balance is chaos — go back to Stage 1, something went wrong

**Adi's gain staging check in Logic:**
Use the channel strip meter. Aim for signal hitting the yellow range (-18 to -12dBFS),
not pushing into orange/red. Adjust the clip gain (not fader) to correct input levels.

---

## STEP 2: BUS ARCHITECTURE

Group everything into buses before processing individual channels:

```
VOCALS BUS
├── Lead Vocal
├── Backing Vocals / Harmonies
└── Vocal FX (ad libs, pitched layers)

STRINGS BUS
├── Emotional Cello
├── Emotional Viola
└── Full Orchestral (CSS, Symphobia etc.)

ORCHESTRAL BUS
├── Brass (CineBrass)
├── Winds (CineWinds)
└── Full Ensemble

PERCUSSION BUS
├── Kick
├── Snare / Clap
├── Hi-Hats / Cymbals
└── Percussion (Tablas, Session Percussionist)

SYNTHS/PADS BUS
├── Lead Synth
├── Pad Layers
└── Textures / Atmospheres

BASS BUS
├── Bass instrument
└── 808 (if applicable)

MASTER BUS (last in chain)
```

**Bus processing logic:** Process the bus for glue first, then go back to individual channels
for detail. Not the other way around.

---

## STEP 3: VOCAL CHAIN (COMPLETE — ADI'S SETUP)

The vocal chain is the most important chain in the mix. Build it first.

```
CHANNEL INSERT CHAIN:
1. Pro-Q 4 (surgical cleanup)
   - HPF: 100–120Hz (remove low rumble, breath noise)
   - Dynamic cut: 300–400Hz if muddy (use dynamic EQ mode, not static)
   - Cut: any build-up resonance (use spectrum analyser to find it)
   - Air shelf: +1.5–2dB at 12kHz (subtle presence lift)

2. UAD Century Tube Channel Strip
   - Input drive: push until you see subtle harmonic colour
   - Use for warmth — not heavy processing

3. UAD 1176 FET (Transient control)
   - Attack: 3–5 (fast — catches consonants and peaks)
   - Release: 6–8 (medium-fast — musical release)
   - Ratio: 4:1 (transparent control, not crushing)
   - GR: 3–6dB on peaks only

4. UAD LA-2A (Levelling / Musical compression)
   - Peak Reduction: set for 3–5dB GR consistently
   - Gain: bring output back up to unity
   - This smooths what the 1176 caught — together they're undetectable

5. FabFilter Pro-DS (De-essing)
   - Frequency: 6–8kHz range
   - Threshold: set to ONLY trigger on harsh S/T moments (not every sibilant)
   - Reduction: -3 to -5dB max — de-essing should be invisible

6. UAD Pultec EQP-1A (Character EQ — last in chain)
   - 100Hz: Boost AND attenuate simultaneously (the Pultec trick) — adds body
   - 10kHz: Boost 1.5–2dB — adds air and shimmer without harshness
   - This is musical EQ, not corrective — it adds character

7. Soundtoys Little Microshift (optional width)
   - Mix: 15–25% max
   - Use only if vocal needs subtle width — not on every song
```

**VOCAL SEND BUSES:**
- Vocal Plate Reverb (Valhalla Plate or UAD Pure Plate):
  - Pre-delay: 18–25ms
  - Decay: 1.0–1.5s
  - Mix on bus: 25–35%
  - HPF return at 200Hz
- Vocal Hall Reverb (Valhalla VintageVerb — for cinematic/hybrid tracks):
  - Pre-delay: 25–35ms
  - Decay: 1.8–2.5s
  - Mix on bus: 15–25%
- Delay (EchoBoy Jr):
  - 1/8 or 1/4 note delay synced to BPM
  - Filtered (HPF 300Hz, LPF 8kHz) — sits behind vocal
  - Mix: 12–20%

**PARALLEL VOCAL BUS (optional, for Hindi songs):**
- Devil-Loc: medium drive setting
- Blend parallel at 5–10% — adds grit and presence without over-compressing the main chain

---

## STEP 4: STRINGS MIXING

Strings in Adi's context (Bollywood/Cinematic hybrid) need:
- **Warmth** not brightness — avoid harsh 3–5kHz peaks
- **Space** — heavy reverb is appropriate here (longer decay than vocals)
- **Depth** — different strings at different reverb lengths creates front-to-back space

```
INDIVIDUAL STRING CHANNELS:
- Emotional Cello: HPF at 60Hz | Light compression (FabFilter Pro-C 2, 2:1, soft knee)
- Emotional Viola: HPF at 100Hz | Slight cut at 400Hz if boxy
- CSS/Full Strings: HPF at 80Hz | Group compression on strings bus

STRINGS BUS:
- Gullfoss: 20–30% strength — intelligent tonal balance across the full range
- Valhalla VintageVerb (send): Hall algorithm
  - Pre-delay: 30–45ms (longer than vocal reverb — pushes strings back in space)
  - Decay: 2.5–3.5s
  - HPF on return at 150Hz
```

---

## STEP 5: CREATIVE MOVES (What makes a mix sound like a release)

These are the moves that separate "sounds fine" from "sounds like a record":

### Automation (Non-negotiable)
- **Vocal rides:** Manual fader automation on every important phrase. Verses quieter, choruses forward.
- **Build-ups:** Automate a high-pass filter rising through the last 4 bars before a chorus drop
- **Reverb throws:** Automate a long reverb send on the last word before a section change
- **Pad swells:** Automate pad volume to rise into chorus, fall in verse

### Depth & Space
- **Pre-delay difference:** Vocal reverb pre-delay (20ms) vs. string reverb pre-delay (35ms)
  — this alone separates them front-to-back without EQ
- **Reverb HPF:** Always HPF reverb returns — keeps the mix clear even with long tails
- **Dry/Wet balance:** Close elements (vocal, kick, snare) — mostly dry. Background elements — wetter.

### Width
- **Low end: always mono** — everything below 80Hz in mono (use Pro-Q 4 mid/side)
- **Mid range:** Subtle width — Little Microshift on vocal or strings bus
- **High end:** Natural width from room/reverb tails
- **Check mono** — collapse to mono regularly. If something disappears, it has a phase problem.

### Saturation & Harmonic Interest
- **Soundtoys Radiator** on piano bus or acoustic guitars — adds valve warmth
- **FabFilter Saturn 2** on synth pads — subtle harmonic excitement, 2–5% drive
- **UAD Pultec** in the vocal chain already adds harmonic content from the transformer

### Sidechain
- **Kickstart 2:** Pads/bass duck on kick hit — even subtle amounts (2–3dB) clean up low end
- **FabFilter Pro-C 2 sidechain mode:** For more precise sidechaining if Kickstart isn't enough

---

## STEP 6: MIXING BUS PROCESSING

### Vocals Bus
- FabFilter Pro-C 2: Very light glue compression (1.5:1, slow attack, soft knee)
- Output at unity

### Strings Bus
- Gullfoss: 25–35% strength — let it breathe the tonal balance
- Optional: Light saturation (Saturn 2, very gentle)

### Master Bus (mixing stage — NOT mastering)
- Gullfoss: 15–20% strength only — don't over-process
- Keep -6dBFS headroom minimum on master output
- NO limiting yet — that's Stage 3

---

## STEP 7: MIXING CHECKS

### A/B Reference Check (every 30 minutes)
- Switch between your mix and reference track
- Match loudness first (reference will be louder — compensate)
- Ask: Does the vocal sit the same way? Is the low end similar weight? Is the space similar?

### Mono Check
- Collapse to mono in Logic (use a Utility plugin or the Mono button)
- Vocal must still be clear. Bass still present. Nothing should disappear.
- If the mix falls apart in mono — there's a phase problem to fix

### Headphone Check Workflow (DT-770 Pro)
1. Engage Beyerdynamic headphone correction plugin on monitor output
2. This gives you flat response — mix to what you hear with it ON
3. Then bypass it — hear what untreated DT-770 adds (extra bass, extra treble)
4. Cross-reference on AirPods — this is the consumer reality check

### Low-Volume Check
- Turn down to very low volume (background music level)
- Can you still hear the vocal melody? The kick? The main hook?
- If not — those elements need more presence, not more volume

---

## COMMON CREATIVE MIX MOVES FOR HINDI/CINEMATIC

| Moment | Creative move | Plugins |
|---|---|---|
| Pre-chorus build | HPF automation rising, remove low end | Pro-Q 4 automation |
| Chorus hit | Release a filtered pad suddenly, full frequency | Shaperbox 3 volume automation |
| Emotional peak | Long reverb throw on final vocal word | VintageVerb send automated up |
| Breakdown | Everything stripped back, only vocal + one instrument | Fader automation |
| Final chorus | Add subtle chorus/width to strings | Valhalla Chorus send |
| Ending | Reverb tail fades naturally — don't cut the reverb bus | Let tails ring out |
