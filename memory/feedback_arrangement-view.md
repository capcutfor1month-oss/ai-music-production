---
name: arrangement-view-composition
description: User wants all composed MIDI to end up in Arrangement View, not Session View
metadata:
  type: feedback
---

**Rule:** When composing or programming MIDI for the user, the final result must be usable in **Arrangement View**.

**Why:** The user explicitly requested this. Ableton's LOM only supports clip creation in Session View (`ClipSlot.create_clip`). There is no API method to create or place clips directly in Arrangement View.

**How to apply:**
- Create clips in Session View as the only programmable path
- Immediately explain to the user which bar to drag the clips to in Arrangement
- Do NOT leave the user to discover the drag step themselves — state it clearly every time
- If the user says "place at bar X," create the clip in Session View and say: "Drag this clip to Arrangement bar X"
- Never claim I can place clips directly in Arrangement View
