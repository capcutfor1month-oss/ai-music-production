---
name: produce-while-mix
description: User expects frequency clash and mix-aware checks during composition, not after
type: feedback
---

**Rule:** When composing or arranging, always run a frequency clash check against existing and expected tracks. Treat production and mixing as one continuous step.

**Why:** User explicitly said "you know the philosophy produce while mix." They expect orchestration decisions to be validated against the frequency spectrum before notes are finalized.

**How to apply:**
- After programming any section, cross-check note fundamentals and prominent harmonics against the frequency allocation map (bass 60-250 Hz, low-mids 250-500 Hz, mids 500-2000 Hz, etc.)
- Identify stacking at specific Hz (e.g., cello 2nd harmonic = violin II fundamental)
- Flag clashes to the user immediately with specific Hz values and severity ratings
- Offer two paths: (A) rewrite voicing to avoid overlap, or (B) keep arrangement and prescribe exact mix fixes (EQ cuts, high-passes, bus notches)
- Reference `MIX_MASTERING_SOURCE_OF_TRUTH.md` and `INSTRUMENT_TECHNIQUES_SOURCE_OF_TRUTH.md` for frequency ranges and instrument roles
- Do NOT wait for the user to ask "does this clash?" — proactively diagnose and present solutions
