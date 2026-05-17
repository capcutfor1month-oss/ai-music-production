# Release Checklist — Adi's Studio

## PRE-MIX CHECKLIST

### Gain Staging (Before touching plugins)
- [ ] All audio regions normalised or gain-staged to peak around -18 to -12dBFS
- [ ] No channel clipping in the red before any processing
- [ ] Input gain set on UAD plugins (not just output) — drive the saturation character
- [ ] Master fader at unity (0dB) throughout mixing

### Organisation
- [ ] All tracks named and colour-coded
- [ ] Tracks grouped into buses: Vocals, Strings, Drums, Bass, Synths, FX
- [ ] Send/return reverb buses set up (Vocal Reverb, String Reverb, Room Bus)

---

## MIX CHECKLIST

### Low End
- [ ] Bass and kick/808 not clashing — check with Pro-Q 4 spectrum analyser
- [ ] Everything below 80Hz in MONO (check with Pro-Q 4 mid-side or a mono tool)
- [ ] Sub rumble removed from non-bass elements (HPF all tracks that don't need sub)
- [ ] 808 tuned to song key in Melodyne 5 (if hip-hop/trap)

### Vocals
- [ ] Vocal sits at -6 to -9dBFS RMS in the mix
- [ ] No harsh sibilance (check 6–8kHz on Pro-Q 4)
- [ ] Tuning done naturally in Melodyne 5 (not robotic unless stylistic)
- [ ] Reverb pre-delay set (18–28ms for Bollywood, 25–35ms for cinematic)
- [ ] De-esser not over-triggering — only catching the harsh moments
- [ ] Vocal automation rides on chorus vs. verse

### Stereo Field
- [ ] No important elements panned hard — keep leads/vocals centred
- [ ] Width check: mono collapse test (nothing important disappears)
- [ ] Strings: slight L/R spread but not hard-panned
- [ ] Sub bass: mono below 80Hz confirmed

### Dynamics
- [ ] No over-compression — vocals should breathe, not pump unnaturally
- [ ] Parallel compression bus if needed (Devil-Loc at 5–10% mix for grit)
- [ ] Drum bus glue compression (Waves SSL Bus Comp or FabFilter Pro-C 2)
- [ ] Sidechain on synth pads/bass if EDM (Kickstart 2)

### Automation
- [ ] Vocal fader rides on key phrases
- [ ] Build-up filtered/stripped before drop (if EDM)
- [ ] Reverb tail automation on final notes/endings

---

## MASTER BUS CHECKLIST

### Plugin Chain on Master (recommended order)
```
Gullfoss (intelligent tonal balance — subtle, 20–40% strength)
→ Ozone 12 Equalizer (tonal matching to reference)
→ Ozone 12 Imager (subtle width, only above 150Hz)
→ Ozone 12 Maximizer / Pro-L 2 (final limiting)
```

### Loudness Targets by Genre
| Genre | Integrated LUFS | True Peak |
|---|---|---|
| Hindi/Bollywood | -9 to -11 | -1.0 dBTP |
| Hindi+Cinematic hybrid | -12 to -14 | -1.0 dBTP |
| Cinematic/Film Score | -18 to -23 | -3.0 dBTP |
| EDM | -7 to -9 | -0.3 dBTP |
| Hip-Hop/Trap | -8 to -10 | -0.3 dBTP |
| Ambient | -16 to -20 | -3.0 dBTP |

---

## FINAL CHECKS BEFORE EXPORT

### Technical
- [ ] Sample rate: 48kHz (matches Scarlett 2i2 recording chain)
- [ ] Bit depth: 24-bit for master file, 16-bit for streaming delivery
- [ ] Export format: WAV 48kHz/24-bit (master), MP3 320kbps (distribution preview)
- [ ] True peak confirmed below ceiling (check Ozone 12 or Pro-L 2 meter)
- [ ] Integrated LUFS measured and confirmed (Ozone 12 meter or Youlean Loudness Meter)

### Listening Tests
- [ ] Full listen on DT-770 Pro with Beyerdynamic headphone plugin engaged
- [ ] Full listen on Apple AirPods Pro 2 (consumer translation)
- [ ] Mono check: collapse to mono, verify nothing important disappears
- [ ] Low volume check: does the mix still make sense at low volume?
- [ ] Check on phone speaker if possible (ultimate consumer test)

### Streaming Platform Normalisation Awareness
| Platform | Normalisation Target | What happens to your master |
|---|---|---|
| Spotify | -14 LUFS | Loud masters (-9 LUFS) get turned DOWN |
| Apple Music | -16 LUFS | Loud masters get turned down significantly |
| JioSaavn | ~-12 LUFS | Close to Bollywood master target |
| YouTube | -14 LUFS | Loud masters get turned down |

**Key insight:** Mastering to -14 LUFS gives you the best of both worlds — it plays
at full volume on Spotify without being turned down, and doesn't sacrifice dynamics
for no reason. For Bollywood commercial releases, -10 to -11 LUFS is still standard.

---

## "FIR KYU" SPECIFIC CHECKLIST
- [ ] Strings bus reverb decay: 2.0–2.5s (cinematic length, not short Bollywood)
- [ ] Vocal reverb: separate from strings — plate, not hall
- [ ] Emotional Cello/Viola: check for low-mid mud at 200–300Hz (HPF at 80Hz)
- [ ] Target LUFS: -12 to -14 (Hindi+Cinematic hybrid)
- [ ] Pre-delay on vocal reverb: 22–28ms (creates space before reverb blooms)
- [ ] Melodyne tuning: natural, preserve vibrato, keep breaths
