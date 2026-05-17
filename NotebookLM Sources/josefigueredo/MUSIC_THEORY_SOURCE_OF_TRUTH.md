# Music Theory - Complete Source of Truth

## Table of Contents
1. [Fundamentals](#fundamentals)
2. [The Circle of Fifths](#the-circle-of-fifths)
3. [Scales and Modes](#scales-and-modes)
4. [Intervals](#intervals)
5. [Chord Theory](#chord-theory)
6. [Harmonic Progressions](#harmonic-progressions)
7. [Voice Leading](#voice-leading)
8. [Key Relationships](#key-relationships)
9. [Genre-Specific Applications](#genre-specific-applications)
10. [Practical Implementation](#practical-implementation)

---

## Fundamentals

### The Chromatic Scale
The foundation of Western music theory is the 12-tone chromatic scale:
```
C - C# - D - D# - E - F - F# - G - G# - A - A# - B
```

**Enharmonic Equivalents:**
- C# = Db
- D# = Eb  
- F# = Gb
- G# = Ab
- A# = Bb

### Semitones and Whole Tones
- **Semitone (Half Step)**: Smallest interval in Western music (1 fret on guitar)
- **Whole Tone (Whole Step)**: Two semitones (2 frets on guitar)

### MIDI Note Numbers
```python
MIDI_NOTES = {
    'C': 0, 'C#': 1, 'Db': 1,
    'D': 2, 'D#': 3, 'Eb': 3,
    'E': 4, 'F': 5, 'F#': 6,
    'Gb': 6, 'G': 7, 'G#': 8,
    'Ab': 8, 'A': 9, 'A#': 10,
    'Bb': 10, 'B': 11
}
# Middle C (C4) = 60
# Formula: MIDI = note_value + (octave * 12) + 12
```

---

## The Circle of Fifths

### Structure and Movement
The Circle of Fifths organizes the 12 chromatic tones by perfect fifth relationships:

**Clockwise (Sharps):**
```
C → G → D → A → E → B → F# → C# → G# → D# → A# → F → C
0   1   2   3   4   5    6     7     8     9    10   11  0
```

**Counterclockwise (Flats):**
```
C → F → Bb → Eb → Ab → Db → Gb → Cb → Fb → Bb → Eb → Ab → C
0   1    2     3     4     5     6     7     8     9    10   11  0
```

### Key Signatures
| Key | Sharps/Flats | Notes |
|-----|-------------|--------|
| C Major | None | C D E F G A B |
| G Major | 1# (F#) | G A B C D E F# |
| D Major | 2# (F#, C#) | D E F# G A B C# |
| A Major | 3# (F#, C#, G#) | A B C# D E F# G# |
| F Major | 1♭ (B♭) | F G A B♭ C D E |
| B♭ Major | 2♭ (B♭, E♭) | B♭ C D E♭ F G A |

### Relative Major/Minor Relationships
Each major key has a relative minor key 3 semitones below:
- **C Major** ↔ **A minor** (no sharps/flats)
- **G Major** ↔ **E minor** (1 sharp)
- **F Major** ↔ **D minor** (1 flat)

### Harmonic Distance
Keys closer on the circle share more notes:
- **Adjacent keys**: 6 shared notes (C Major & G Major)
- **Opposite keys**: 1 shared note (C Major & F# Major)
- **Same key**: 7 shared notes (perfect match)

---

## Scales and Modes

### Major Scale (Ionian Mode)
**Formula:** W-W-H-W-W-W-H (W=Whole step, H=Half step)
**Intervals:** 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8
**Semitones:** 0 - 2 - 4 - 5 - 7 - 9 - 11 - 12

```python
MAJOR_SCALE = [0, 2, 4, 5, 7, 9, 11]  # C Major
```

### Natural Minor Scale (Aeolian Mode)
**Formula:** W-H-W-W-H-W-W
**Intervals:** 1 - 2 - ♭3 - 4 - 5 - ♭6 - ♭7 - 8
**Semitones:** 0 - 2 - 3 - 5 - 7 - 8 - 10 - 12

```python
MINOR_SCALE = [0, 2, 3, 5, 7, 8, 10]  # A Minor
```

### Modal Scales
All modes derived from the major scale:

| Mode | Formula | Character | Use Cases |
|------|---------|-----------|-----------|
| **Ionian** (Major) | 1-2-3-4-5-6-7 | Happy, bright | Pop, classical |
| **Dorian** | 1-2-♭3-4-5-6-♭7 | Minor but brighter | Jazz, folk, rock |
| **Phrygian** | 1-♭2-♭3-4-5-♭6-♭7 | Dark, Spanish | Flamenco, metal |
| **Lydian** | 1-2-3-#4-5-6-7 | Dreamy, floating | Film scores, ambient |
| **Mixolydian** | 1-2-3-4-5-6-♭7 | Major but bluesy | Blues, rock, folk |
| **Aeolian** (Minor) | 1-2-♭3-4-5-♭6-♭7 | Sad, dark | Minor key music |
| **Locrian** | 1-♭2-♭3-4-♭5-♭6-♭7 | Unstable, diminished | Rarely used |

```python
MODES = {
    'ionian':     [0, 2, 4, 5, 7, 9, 11],   # Major
    'dorian':     [0, 2, 3, 5, 7, 9, 10],   # Minor with raised 6th
    'phrygian':   [0, 1, 3, 5, 7, 8, 10],   # Minor with lowered 2nd
    'lydian':     [0, 2, 4, 6, 7, 9, 11],   # Major with raised 4th
    'mixolydian': [0, 2, 4, 5, 7, 9, 10],   # Major with lowered 7th
    'aeolian':    [0, 2, 3, 5, 7, 8, 10],   # Natural minor
    'locrian':    [0, 1, 3, 5, 6, 8, 10]    # Diminished
}
```

### Pentatonic Scales

#### Major Pentatonic
**Formula:** 1-2-3-5-6 (removes 4th and 7th from major scale)
**Semitones:** 0-2-4-7-9
**Character:** Safe, consonant, no half-steps
**Uses:** Country, rock, pop, folk

#### Minor Pentatonic  
**Formula:** 1-♭3-4-5-♭7 (removes 2nd and 6th from minor scale)
**Semitones:** 0-3-5-7-10
**Character:** Bluesy, rock-oriented
**Uses:** Blues, rock, jazz improvisation

```python
PENTATONIC = {
    'major': [0, 2, 4, 7, 9],     # C-D-E-G-A
    'minor': [0, 3, 5, 7, 10]     # C-Eb-F-G-Bb
}
```

### Blues Scales

#### Minor Blues Scale
**Formula:** 1-♭3-4-♭5-5-♭7 (minor pentatonic + ♭5 "blue note")
**Semitones:** 0-3-5-6-7-10

#### Major Blues Scale
**Formula:** 1-2-♭3-3-5-6 (major pentatonic + ♭3 "blue note")
**Semitones:** 0-2-3-4-7-9

```python
BLUES_SCALES = {
    'minor_blues': [0, 3, 5, 6, 7, 10],    # With blue note (♭5)
    'major_blues': [0, 2, 3, 4, 7, 9]      # With blue note (♭3)
}
```

### Exotic Scales

#### Harmonic Minor
**Formula:** 1-2-♭3-4-5-♭6-7 (natural minor with raised 7th)
**Semitones:** 0-2-3-5-7-8-11
**Character:** Middle Eastern, dramatic

#### Melodic Minor (Ascending)
**Formula:** 1-2-♭3-4-5-6-7 (natural minor with raised 6th and 7th)
**Semitones:** 0-2-3-5-7-9-11

#### Whole Tone Scale
**Formula:** All whole steps
**Semitones:** 0-2-4-6-8-10
**Character:** Dreamy, impressionistic, no tonic

#### Chromatic Scale
**Formula:** All 12 semitones
**Uses:** Connecting passages, jazz improvisation

```python
EXOTIC_SCALES = {
    'harmonic_minor': [0, 2, 3, 5, 7, 8, 11],
    'melodic_minor':  [0, 2, 3, 5, 7, 9, 11],
    'whole_tone':     [0, 2, 4, 6, 8, 10],
    'chromatic':      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
}
```

---

## Intervals

### Interval Classification
Intervals measure the distance between two notes:

| Interval | Semitones | Example (from C) | Quality |
|----------|-----------|------------------|---------|
| Unison | 0 | C-C | Perfect |
| Minor 2nd | 1 | C-Db | Minor |
| Major 2nd | 2 | C-D | Major |
| Minor 3rd | 3 | C-Eb | Minor |
| Major 3rd | 4 | C-E | Major |
| Perfect 4th | 5 | C-F | Perfect |
| Tritone | 6 | C-F# | Diminished 5th/Augmented 4th |
| Perfect 5th | 7 | C-G | Perfect |
| Minor 6th | 8 | C-Ab | Minor |
| Major 6th | 9 | C-A | Major |
| Minor 7th | 10 | C-Bb | Minor |
| Major 7th | 11 | C-B | Major |
| Octave | 12 | C-C | Perfect |

### Interval Quality Rules
- **Perfect intervals:** 1st, 4th, 5th, 8th (stable, consonant)
- **Major intervals:** 2nd, 3rd, 6th, 7th (can be major or minor)
- **Tritone:** Most dissonant interval, creates tension

### Consonance vs Dissonance
**Consonant (stable):**
- Perfect unison, 4th, 5th, octave
- Major and minor 3rds, 6ths

**Dissonant (creates tension):**
- Major and minor 2nds, 7ths
- Tritone (♭5/♯4)
- Augmented and diminished intervals

---

## Chord Theory

### Triads (3-Note Chords)

#### Major Triad
**Formula:** 1-3-5 (Root + Major 3rd + Perfect 5th)
**Semitones:** 0-4-7
**Character:** Happy, stable, resolved

#### Minor Triad  
**Formula:** 1-♭3-5 (Root + Minor 3rd + Perfect 5th)
**Semitones:** 0-3-7
**Character:** Sad, introspective

#### Diminished Triad
**Formula:** 1-♭3-♭5 (Root + Minor 3rd + Diminished 5th)
**Semitones:** 0-3-6
**Character:** Tense, unstable, needs resolution

#### Augmented Triad
**Formula:** 1-3-♯5 (Root + Major 3rd + Augmented 5th)
**Semitones:** 0-4-8
**Character:** Mysterious, unsettled

```python
TRIADS = {
    'major':      [0, 4, 7],    # C-E-G
    'minor':      [0, 3, 7],    # C-Eb-G  
    'diminished': [0, 3, 6],    # C-Eb-Gb
    'augmented':  [0, 4, 8]     # C-E-G#
}
```

### Seventh Chords (4-Note Chords)

#### Major 7th (Maj7)
**Formula:** 1-3-5-7
**Semitones:** 0-4-7-11
**Character:** Sophisticated, jazzy, dreamy

#### Dominant 7th (7)
**Formula:** 1-3-5-♭7
**Semitones:** 0-4-7-10  
**Character:** Bluesy, wants to resolve, tension

#### Minor 7th (m7)
**Formula:** 1-♭3-5-♭7
**Semitones:** 0-3-7-10
**Character:** Smooth, jazzy, relaxed

#### Minor Major 7th (mMaj7)
**Formula:** 1-♭3-5-7
**Semitones:** 0-3-7-11
**Character:** Dark yet bright, mysterious

#### Half-Diminished 7th (m7♭5)
**Formula:** 1-♭3-♭5-♭7
**Semitones:** 0-3-6-10
**Character:** Jazzy, sophisticated tension

#### Diminished 7th (dim7)
**Formula:** 1-♭3-♭5-♭♭7
**Semitones:** 0-3-6-9
**Character:** Very tense, passing chord

```python
SEVENTH_CHORDS = {
    'maj7':     [0, 4, 7, 11],   # CMaj7
    '7':        [0, 4, 7, 10],   # C7 (dominant)
    'm7':       [0, 3, 7, 10],   # Cm7
    'mMaj7':    [0, 3, 7, 11],   # CmMaj7
    'm7b5':     [0, 3, 6, 10],   # Cm7♭5 (half-diminished)
    'dim7':     [0, 3, 6, 9]     # Cdim7
}
```

### Extended Chords (5+ Notes)

#### 9th Chords
Add the 9th (2nd octave higher):
- **Maj9:** 1-3-5-7-9
- **9:** 1-3-5-♭7-9 (dominant 9th)
- **m9:** 1-♭3-5-♭7-9

#### 11th Chords  
Add the 11th (4th octave higher):
- **Maj11:** 1-3-5-7-9-11
- **11:** 1-3-5-♭7-9-11
- **m11:** 1-♭3-5-♭7-9-11

#### 13th Chords
Add the 13th (6th octave higher):
- **Maj13:** 1-3-5-7-9-11-13
- **13:** 1-3-5-♭7-9-11-13
- **m13:** 1-♭3-5-♭7-9-11-13

### Chord Inversions

#### Root Position
Bass note = root of the chord
**C Major:** C-E-G (C in bass)

#### First Inversion
Bass note = 3rd of the chord  
**C Major/E:** E-G-C (E in bass)

#### Second Inversion
Bass note = 5th of the chord
**C Major/G:** G-C-E (G in bass)

#### Third Inversion (7th chords only)
Bass note = 7th of the chord
**C7/Bb:** Bb-C-E-G (Bb in bass)

```python
def get_chord_inversions(chord_notes):
    """Generate all inversions of a chord"""
    inversions = []
    for i in range(len(chord_notes)):
        # Rotate the chord
        inversion = chord_notes[i:] + [note + 12 for note in chord_notes[:i]]
        inversions.append(inversion)
    return inversions
```

---

## Harmonic Progressions

### Functional Harmony
Chords have three primary functions:

#### Tonic (I)
**Function:** Home, rest, stability
**Chords:** I, vi, iii
**Example in C:** C, Am, Em

#### Predominant (IV)
**Function:** Movement away from tonic, preparation
**Chords:** IV, ii, vi
**Example in C:** F, Dm, Am

#### Dominant (V)  
**Function:** Tension, wants to resolve to tonic
**Chords:** V, vii°, V7
**Example in C:** G, Bdim, G7

### Common Progressions

#### I-V-vi-IV (Pop Progression)
**Example in C:** C-G-Am-F
**Uses:** Pop, rock, country
**Character:** Catchy, familiar, satisfying

#### ii-V-I (Jazz Progression)
**Example in C:** Dm7-G7-CMaj7
**Uses:** Jazz standards, sophisticated pop
**Character:** Smooth, sophisticated resolution

#### vi-IV-I-V (Sad Pop)
**Example in C:** Am-F-C-G
**Uses:** Ballads, emotional songs
**Character:** Melancholy to hopeful

#### I-bVII-IV-I (Rock/Modal)
**Example in C:** C-Bb-F-C
**Uses:** Rock, blues, modal music
**Character:** Strong, anthemic

#### Circle of Fifths Progression
**Classical:** I-IV-vii°-iii-vi-ii-V-I
**Example in C:** C-F-Bdim-Em-Am-Dm-G-C
**Uses:** Baroque, classical music
**Character:** Sophisticated harmonic movement

```python
PROGRESSIONS = {
    'pop':        [1, 5, 6, 4],           # I-V-vi-IV
    'jazz':       [2, 5, 1],              # ii-V-I  
    'sad_pop':    [6, 4, 1, 5],           # vi-IV-I-V
    'rock':       [1, 7, 4, 1],           # I-bVII-IV-I
    'blues':      [1, 1, 4, 4, 1, 1, 5, 4, 1, 5],  # 12-bar blues
    'circle':     [1, 4, 7, 3, 6, 2, 5, 1] # Circle of fifths
}
```

### Modal Progressions

#### Dorian
**Characteristic:** i-IV (minor tonic, major IV)
**Example:** Am-D (A Dorian)

#### Mixolydian  
**Characteristic:** I-bVII (major tonic, major bVII)
**Example:** G-F (G Mixolydian)

#### Phrygian
**Characteristic:** i-bII (minor tonic, major bII)
**Example:** Em-F (E Phrygian)

### Secondary Dominants
Temporary tonicization of other keys:
- **V/V:** Dominant of the dominant (D7 in key of C)
- **V/vi:** Dominant of the vi chord (E7 in key of C)
- **V/IV:** Dominant of the IV chord (C7 in key of C)

---

## Voice Leading

### Principles of Good Voice Leading

#### Smooth Motion
- **Common Tones:** Keep notes that are shared between chords
- **Step-wise Motion:** Move by steps when possible
- **Avoid Large Leaps:** Especially in inner voices

#### Parallel Motion Rules
**Avoid:**
- Parallel 5ths and octaves (sounds hollow)
- Direct/hidden 5ths and octaves in outer voices

**Allow:**
- Parallel 3rds and 6ths (sounds rich)
- Parallel motion in similar direction

#### Voice Leading Examples
```
Good voice leading (C to F):
C Major: C-E-G
F Major: C-F-A (C stays, E→F, G→A)

Poor voice leading (C to F):
C Major: C-E-G  
F Major: F-A-C (all voices leap)
```

### Four-Part Harmony Rules
1. **Soprano:** Melody line, most freedom
2. **Alto:** Avoid crossing below tenor
3. **Tenor:** Avoid crossing above alto
4. **Bass:** Foundation, often chord roots

### Voice Leading in Different Styles

#### Classical Style
- Strict rules about parallels
- Smooth stepwise motion preferred
- Careful preparation and resolution of dissonance

#### Jazz Style
- More freedom with parallels
- Use of chord extensions and alterations
- Voice leading through chord tones

#### Pop/Rock Style
- Emphasis on melodic bass lines
- Guitar-friendly voicings
- Less concern with classical rules

---

## Key Relationships

### Closely Related Keys
Keys sharing 6 out of 7 notes:

**From C Major:**
- **G Major** (1 sharp): shares F# different
- **F Major** (1 flat): shares Bb different  
- **A minor** (relative): shares all notes
- **E minor** (relative of G): shares F# different
- **D minor** (relative of F): shares Bb different

### Modulation Techniques

#### Pivot Chord Modulation
Use a chord that exists in both keys:
```
C Major to G Major:
C - Am - F - G - D - G
      ↑
   Pivot (ii in G, vi in C)
```

#### Direct Modulation
Immediate key change without preparation:
```
C Major: C - F - G - C
G Major: G - C - D - G
```

#### Sequential Modulation
Gradual movement through related keys:
```
C → G → D → A (circle of fifths)
```

### Borrowed Chords (Modal Interchange)
Using chords from parallel modes:

**From C Major, borrow from C Minor:**
- **bVI:** Ab Major chord
- **bVII:** Bb Major chord  
- **iv:** F minor chord

**Common Borrowed Progressions:**
- I-bVI-bVII-I (C-Ab-Bb-C)
- I-iv-I (C-Fm-C)

---

## Genre-Specific Applications

### Classical Music
**Characteristics:**
- Functional harmony (I-IV-V relationships)
- Strict voice leading rules
- Complex modulations
- Use of secondary dominants

**Common Progressions:**
- I-vi-IV-V (classical sequence)
- ii-V-I (cadential progression)
- Circle of fifths progressions

### Jazz Music
**Characteristics:**
- Extended chords (7ths, 9ths, 11ths, 13ths)
- Modal harmony
- Complex reharmonization
- Tritone substitutions

**Common Progressions:**
- ii-V-I (fundamental jazz cadence)
- I-vi-ii-V (rhythm changes)
- Giant steps changes (major 3rd cycles)

**Chord Types:**
```python
JAZZ_CHORDS = {
    'maj7':    [0, 4, 7, 11],
    'm7':      [0, 3, 7, 10], 
    '7':       [0, 4, 7, 10],
    'm7b5':    [0, 3, 6, 10],
    'dim7':    [0, 3, 6, 9],
    'maj7#11': [0, 4, 7, 11, 6],  # Lydian chord
    '7alt':    [0, 4, 6, 10]      # Altered dominant
}
```

### Blues Music
**Characteristics:**
- 12-bar blues form
- Dominant 7th chords
- Blue notes (b3, b7, b5)
- Call and response patterns

**12-Bar Blues in C:**
```
| C7  | C7  | C7  | C7  |
| F7  | F7  | C7  | C7  |  
| G7  | F7  | C7  | G7  |
```

**Blue Notes:**
- b3rd: Creates major/minor ambiguity
- b7th: Adds bluesy character
- b5th: Creates tension and release

### Rock/Pop Music
**Characteristics:**
- Power chords (root + 5th)
- Simple progressions
- Modal influences
- Guitar-friendly keys

**Power Chord Formula:**
```python
POWER_CHORD = [0, 7]  # Root + Perfect 5th
```

**Common Rock Progressions:**
- I-bVII-IV-I (C-Bb-F-C)
- vi-IV-I-V (Am-F-C-G)
- I-V-vi-IV (C-G-Am-F)

### Electronic/EDM
**Characteristics:**
- Simple harmonic structures
- Emphasis on rhythm and timbre
- Use of modes (especially minor)
- Build-up and breakdown sections

**Typical EDM Progression:**
```
Am - F - C - G (vi-IV-I-V in C Major)
```

### Hip-Hop
**Characteristics:**
- Minor key emphasis
- Simple chord loops
- Jazz chord sampling
- Modal harmony

**Common Hip-Hop Progressions:**
- i-bVII-bVI-bVII (Am-G-F-G)
- i-iv-v-i (Am-Dm-Em-Am)
- i-bIII-bVII-IV (Am-C-G-F)

### Lo-Fi/Chill
**Characteristics:**
- Jazz-influenced harmony
- Extended chords (7ths, 9ths)
- Minor keys
- Slow tempos (70-90 BPM)

**Lo-Fi Chord Types:**
```python
LOFI_CHORDS = {
    'm7':     [0, 3, 7, 10],
    'maj7':   [0, 4, 7, 11],
    'm9':     [0, 3, 7, 10, 2],
    'maj9':   [0, 4, 7, 11, 2],
    'add9':   [0, 4, 7, 2]
}
```

---

## Practical Implementation

### Scale Generation Algorithm
```python
def generate_scale(root_note, scale_type='major', octave=4):
    """
    Generate scale notes for any root and scale type
    
    Args:
        root_note: String like 'C', 'F#', 'Bb'
        scale_type: String from SCALES dictionary
        octave: Integer octave number
    
    Returns:
        List of MIDI note numbers
    """
    # Convert root note to MIDI number
    note_map = {
        'C': 0, 'C#': 1, 'Db': 1,
        'D': 2, 'D#': 3, 'Eb': 3,
        'E': 4, 'F': 5, 'F#': 6,
        'Gb': 6, 'G': 7, 'G#': 8,
        'Ab': 8, 'A': 9, 'A#': 10,
        'Bb': 10, 'B': 11
    }
    
    # Scale interval patterns
    scales = {
        'major':          [0, 2, 4, 5, 7, 9, 11],
        'minor':          [0, 2, 3, 5, 7, 8, 10],
        'dorian':         [0, 2, 3, 5, 7, 9, 10],
        'phrygian':       [0, 1, 3, 5, 7, 8, 10],
        'lydian':         [0, 2, 4, 6, 7, 9, 11],
        'mixolydian':     [0, 2, 4, 5, 7, 9, 10],
        'aeolian':        [0, 2, 3, 5, 7, 8, 10],
        'locrian':        [0, 1, 3, 5, 6, 8, 10],
        'harmonic_minor': [0, 2, 3, 5, 7, 8, 11],
        'melodic_minor':  [0, 2, 3, 5, 7, 9, 11],
        'pentatonic_major': [0, 2, 4, 7, 9],
        'pentatonic_minor': [0, 3, 5, 7, 10],
        'blues_minor':    [0, 3, 5, 6, 7, 10],
        'whole_tone':     [0, 2, 4, 6, 8, 10]
    }
    
    root_midi = note_map[root_note] + (octave * 12) + 12
    intervals = scales[scale_type]
    
    return [root_midi + interval for interval in intervals]
```

### Chord Generation Algorithm
```python
def generate_chord(root_note, chord_type='major', octave=4):
    """
    Generate chord notes for any root and chord type
    """
    # Get scale for harmonization
    if 'major' in chord_type or chord_type in ['maj7', 'maj9']:
        scale = generate_scale(root_note, 'major', octave)
    else:
        scale = generate_scale(root_note, 'minor', octave)
    
    # Chord formulas (scale degrees)
    chord_formulas = {
        'major':      [0, 2, 4],           # 1-3-5
        'minor':      [0, 2, 4],           # 1-b3-5 (handled by minor scale)
        'diminished': [0, 2, 4],           # 1-b3-b5
        'augmented':  [0, 2, 4],           # 1-3-#5
        'maj7':       [0, 2, 4, 6],        # 1-3-5-7
        '7':          [0, 2, 4, 6],        # 1-3-5-b7
        'm7':         [0, 2, 4, 6],        # 1-b3-5-b7
        'dim7':       [0, 2, 4, 6],        # 1-b3-b5-bb7
        'maj9':       [0, 2, 4, 6, 1],     # 1-3-5-7-9
        'm9':         [0, 2, 4, 6, 1]      # 1-b3-5-b7-9
    }
    
    # Apply modifications for specific chord types
    notes = []
    formula = chord_formulas[chord_type]
    
    for degree in formula:
        if degree < len(scale):
            note = scale[degree]
            
            # Apply chord-specific alterations
            if chord_type == 'diminished' and degree == 4:  # b5
                note -= 1
            elif chord_type == 'augmented' and degree == 4:  # #5
                note += 1
            elif chord_type == '7' and degree == 6:  # b7
                note -= 1
                
            notes.append(note)
    
    return notes
```

### Progression Generator
```python
def generate_progression(key, progression_name='pop', scale_type='major', bars=4):
    """
    Generate chord progression with proper voice leading
    """
    # Progression patterns (scale degrees)
    progressions = {
        'pop':     [1, 5, 6, 4],           # I-V-vi-IV
        'jazz':    [2, 5, 1, 1],           # ii-V-I-I  
        'blues':   [1, 1, 4, 4, 1, 1, 5, 4, 1, 5], # 12-bar
        'sad':     [6, 4, 1, 5],           # vi-IV-I-V
        'rock':    [1, 7, 4, 1],           # I-bVII-IV-I
        'circle':  [1, 4, 7, 3, 6, 2, 5, 1] # Circle of fifths
    }
    
    pattern = progressions[progression_name]
    scale_notes = generate_scale(key, scale_type, 3)  # Lower octave for chords
    
    chords = []
    beats_per_chord = (bars * 4) / len(pattern)
    
    for i, degree in enumerate(pattern):
        start_time = i * beats_per_chord
        
        # Get chord root (scale degree)
        chord_root = scale_notes[degree - 1]
        
        # Determine chord quality from scale harmonization
        if scale_type == 'major':
            if degree in [1, 4, 5]:  # Major chords
                chord = generate_chord_from_midi(chord_root, 'major')
            elif degree in [2, 3, 6]:  # Minor chords  
                chord = generate_chord_from_midi(chord_root, 'minor')
            elif degree == 7:  # Diminished
                chord = generate_chord_from_midi(chord_root, 'diminished')
        else:  # Minor scale harmonization
            # Implementation for minor scale harmony
            pass
            
        chords.append((start_time, chord))
    
    return chords
```

### MIDI Note Conversion
```python
def notes_to_midi_data(notes, velocity=90):
    """
    Convert note data to MIDI format for DAW integration
    
    Args:
        notes: List of (pitch, start_time, duration, velocity) tuples
        velocity: Default velocity if not specified
    
    Returns:
        Flat list suitable for OSC transmission: [pitch1, start1, dur1, vel1, mute1, ...]
    """
    midi_data = []
    
    for note in notes:
        if len(note) == 3:
            pitch, start_time, duration = note
            note_velocity = velocity
        else:
            pitch, start_time, duration, note_velocity = note
            
        midi_data.extend([
            int(pitch),
            float(start_time),
            float(duration), 
            int(note_velocity),
            False  # muted flag
        ])
    
    return midi_data
```

### Key Detection Algorithm
```python
def detect_key(notes):
    """
    Detect the most likely key from a collection of notes
    using the Krumhansl-Schmuckler algorithm
    """
    # Major key profiles (Krumhansl-Schmuckler)
    major_profile = [6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88]
    minor_profile = [6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17]
    
    # Count note occurrences
    note_counts = [0] * 12
    for note in notes:
        note_counts[note % 12] += 1
    
    # Normalize counts
    total = sum(note_counts)
    if total == 0:
        return "C", "major"
        
    note_weights = [count / total for count in note_counts]
    
    # Calculate correlation with each key
    best_key = None
    best_score = -1
    best_mode = None
    
    note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    
    for root in range(12):
        # Test major key
        major_score = sum(note_weights[i] * major_profile[(i - root) % 12] for i in range(12))
        if major_score > best_score:
            best_score = major_score
            best_key = note_names[root]
            best_mode = "major"
            
        # Test minor key  
        minor_score = sum(note_weights[i] * minor_profile[(i - root) % 12] for i in range(12))
        if minor_score > best_score:
            best_score = minor_score
            best_key = note_names[root]
            best_mode = "minor"
    
    return best_key, best_mode
```

---

## Advanced Concepts

### Harmonic Rhythm
The rate at which chords change:
- **Fast harmonic rhythm:** Chords change frequently (every beat)
- **Slow harmonic rhythm:** Chords change infrequently (every bar or more)

### Non-Chord Tones
Notes that don't belong to the current chord:
- **Passing tones:** Connect chord tones by step
- **Neighbor tones:** Move away from and back to chord tone
- **Suspensions:** Delay resolution of chord tone
- **Appoggiaturas:** Accented non-chord tones

### Chromatic Harmony
Use of notes outside the key:
- **Secondary dominants:** V/x chords
- **Neapolitan sixth:** bII6 chord
- **Augmented sixth chords:** Italian, French, German
- **Borrowed chords:** From parallel modes

### Reharmonization Techniques
Substituting chords while maintaining the melody:
- **Tritone substitution:** Replace V7 with bII7
- **Related ii-V:** Add ii-V before target chord
- **Chromatic approach:** Use chromatic chords leading to target
- **Modal interchange:** Borrow from parallel modes

---

This music theory source of truth provides comprehensive coverage of fundamental concepts needed for intelligent music generation and analysis. Each section builds upon the previous ones, creating a complete framework for understanding and implementing music theory in algorithmic composition systems.