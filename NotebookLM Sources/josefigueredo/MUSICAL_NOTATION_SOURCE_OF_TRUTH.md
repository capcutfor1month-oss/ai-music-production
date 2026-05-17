# Musical Notation - Complete Source of Truth

## Table of Contents
1. [Fundamentals of Staff Notation](#fundamentals-of-staff-notation)
2. [Clefs and Pitch Notation](#clefs-and-pitch-notation)
3. [Note Values and Duration](#note-values-and-duration)
4. [Rest Symbols](#rest-symbols)
5. [Time Signatures](#time-signatures)
6. [Key Signatures and Accidentals](#key-signatures-and-accidentals)
7. [Rhythmic Notation](#rhythmic-notation)
8. [Dynamics](#dynamics)
9. [Articulation](#articulation)
10. [Expression Markings](#expression-markings)
11. [Advanced Notation](#advanced-notation)
12. [Digital Implementation](#digital-implementation)

---

## Fundamentals of Staff Notation

### The Musical Staff
The staff (plural: staves) is the foundation of Western musical notation, consisting of:
- **5 horizontal lines** numbered from bottom (1) to top (5)
- **4 spaces** numbered from bottom (1) to top (4)
- Vertical axis represents **pitch** (higher = higher pitch)
- Horizontal axis represents **time** (left to right)

```
Staff Structure:
Line 5  ___________________
Space 4
Line 4  ___________________
Space 3  
Line 3  ___________________
Space 2
Line 2  ___________________
Space 1
Line 1  ___________________
```

### Ledger Lines
**Purpose:** Extend the staff for notes above or below the standard range
**Usage:** Short horizontal lines drawn above or below the staff
**Example:** High C above treble staff requires one ledger line

### Bar Lines and Measures
- **Bar line:** Vertical line dividing music into measures
- **Measure (Bar):** Space between bar lines containing beats
- **Double bar line:** Indicates end of section
- **Final bar line:** Thick double line indicating end of piece

```
Measure Structure:
| ♩ ♩ ♩ ♩ | ♩ ♩ ♩ ♩ | ♩ ♩ ♩ ♩ ||
  Beat1234   Beat1234   Beat1234   End
```

---

## Clefs and Pitch Notation

### Treble Clef (G Clef)
**Symbol:** 𝄞
**Reference:** Second line = G4 (G above middle C)
**Range:** Best for higher pitches
**Instruments:** Piano right hand, violin, flute, voice (soprano, alto)

**Line Notes (bottom to top):** E - G - B - D - F
**Space Notes (bottom to top):** F - A - C - E

**Memory aids:**
- Lines: "Every Good Boy Does Fine"
- Spaces: "FACE"

```python
TREBLE_CLEF_LINES = [52, 55, 59, 62, 65]  # E4, G4, B4, D5, F5 (MIDI)
TREBLE_CLEF_SPACES = [53, 57, 60, 64]     # F4, A4, C5, E5 (MIDI)
```

### Bass Clef (F Clef)
**Symbol:** 𝄢
**Reference:** Fourth line = F3 (F below middle C)
**Range:** Best for lower pitches
**Instruments:** Piano left hand, cello, bass, trombone

**Line Notes (bottom to top):** G - B - D - F - A
**Space Notes (bottom to top):** A - C - E - G

**Memory aids:**
- Lines: "Good Boys Do Fine Always"
- Spaces: "All Cows Eat Grass"

```python
BASS_CLEF_LINES = [43, 47, 50, 53, 57]   # G3, B3, D4, F4, A4 (MIDI)
BASS_CLEF_SPACES = [45, 48, 52, 55]      # A3, C4, E4, G4 (MIDI)
```

### Alto Clef (C Clef)
**Symbol:** 𝄡
**Reference:** Middle line = C4 (middle C)
**Range:** Bridge between treble and bass
**Instruments:** Viola, alto trombone

### MIDI Note Mapping
```python
def note_to_midi(note_name, octave):
    """Convert note name and octave to MIDI number"""
    note_values = {
        'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3,
        'E': 4, 'F': 5, 'F#': 6, 'Gb': 6, 'G': 7, 'G#': 8,
        'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11
    }
    return note_values[note_name] + (octave + 1) * 12

# Middle C = C4 = MIDI 60
# A4 (440 Hz) = MIDI 69
```

---

## Note Values and Duration

### Basic Note Values
Each note value represents a fraction of a whole note:

| Note Type | Symbol | Duration | Beats (4/4) | MIDI Ticks (480ppq) |
|-----------|---------|----------|-------------|---------------------|
| **Whole Note** (Semibreve) | 𝅝 | 4/4 | 4 beats | 1920 |
| **Half Note** (Minim) | 𝅗𝅥 | 2/4 | 2 beats | 960 |
| **Quarter Note** (Crotchet) | ♩ | 1/4 | 1 beat | 480 |
| **Eighth Note** (Quaver) | ♪ | 1/8 | 1/2 beat | 240 |
| **Sixteenth Note** (Semiquaver) | ♬ | 1/16 | 1/4 beat | 120 |
| **Thirty-second Note** | ♬ | 1/32 | 1/8 beat | 60 |

```python
NOTE_DURATIONS = {
    'whole': 4.0,
    'half': 2.0,
    'quarter': 1.0,
    'eighth': 0.5,
    'sixteenth': 0.25,
    'thirty_second': 0.125
}
```

### Dotted Notes
**Rule:** A dot after a note increases its duration by half

**Examples:**
- Dotted half note (𝅗𝅥.) = 2 + 1 = 3 beats
- Dotted quarter note (♩.) = 1 + 0.5 = 1.5 beats  
- Dotted eighth note (♪.) = 0.5 + 0.25 = 0.75 beats

**Multiple Dots:**
- First dot: +50% of original value
- Second dot: +25% of original value (50% of first dot)
- Third dot: +12.5% of original value (50% of second dot)

```python
def calculate_dotted_duration(base_duration, num_dots):
    """Calculate duration of dotted note"""
    duration = base_duration
    dot_value = base_duration * 0.5
    
    for i in range(num_dots):
        duration += dot_value
        dot_value *= 0.5
    
    return duration
```

### Ties
**Purpose:** Connect notes of the same pitch to create longer durations
**Symbol:** Curved line connecting note heads
**Rule:** Add durations together, play as one continuous note

**Examples:**
- Half note tied to quarter note = 3 beats total
- Quarter note tied to eighth note = 1.5 beats total

### Note Stems and Flags
**Stem Rules:**
- **Stem up:** Note head below middle line of staff
- **Stem down:** Note head above middle line of staff
- **Middle line:** Either direction acceptable

**Flag Rules:**
- Eighth notes: 1 flag
- Sixteenth notes: 2 flags
- Thirty-second notes: 3 flags

---

## Rest Symbols

### Rest Values
Each rest corresponds to a note value duration:

| Rest Type | Symbol | Duration | MIDI Ticks (480ppq) |
|-----------|---------|----------|---------------------|
| **Whole Rest** | ■ | 4 beats | 1920 |
| **Half Rest** | ▬ | 2 beats | 960 |
| **Quarter Rest** | 𝄽 | 1 beat | 480 |
| **Eighth Rest** | 𝄾 | 0.5 beats | 240 |
| **Sixteenth Rest** | 𝄿 | 0.25 beats | 120 |

### Rest Positioning Rules
- **Whole rest:** Hangs below 4th line (looks like a "hole")
- **Half rest:** Sits on 3rd line (looks like a "hat")
- **Quarter rest:** Complex symbol, position varies
- **Smaller rests:** Follow stem direction rules

### Multi-Measure Rests
**Symbol:** Number above a whole rest in a box
**Usage:** Indicates multiple measures of silence
**Example:** [4] above whole rest = 4 measures of silence

```python
REST_SYMBOLS = {
    'whole': '■',
    'half': '▬', 
    'quarter': '𝄽',
    'eighth': '𝄾',
    'sixteenth': '𝄿',
    'thirty_second': '𝅀'
}
```

---

## Time Signatures

### Structure and Meaning
**Format:** Two numbers stacked vertically
- **Top number:** Beats per measure
- **Bottom number:** Note value that gets one beat

### Common Time Signatures

#### 4/4 (Common Time)
**Symbol:** C or 4/4
**Meaning:** 4 quarter-note beats per measure
**Feel:** Strong-weak-medium-weak
**Genres:** Most pop, rock, classical

#### 3/4 (Waltz Time)
**Meaning:** 3 quarter-note beats per measure
**Feel:** Strong-weak-weak
**Genres:** Waltzes, ballads, folk

#### 2/4 (March Time)
**Meaning:** 2 quarter-note beats per measure
**Feel:** Strong-weak
**Genres:** Marches, polkas

#### 6/8 (Compound Duple)
**Meaning:** 6 eighth-note beats, felt in 2 groups of 3
**Feel:** Strong-weak-weak-medium-weak-weak
**Genres:** Ballads, folk, some rock

#### Complex Time Signatures
- **5/4:** 5 quarter beats (asymmetrical)
- **7/8:** 7 eighth beats (often grouped 3+2+2 or 2+3+2)
- **9/8:** 9 eighth beats (often felt in 3 groups of 3)

```python
TIME_SIGNATURES = {
    'common_time': {'numerator': 4, 'denominator': 4, 'symbol': 'C'},
    'cut_time': {'numerator': 2, 'denominator': 2, 'symbol': '¢'},
    'waltz': {'numerator': 3, 'denominator': 4},
    'march': {'numerator': 2, 'denominator': 4},
    'compound_duple': {'numerator': 6, 'denominator': 8}
}
```

### Meter Types
- **Simple meters:** Beat divides into 2 (2/4, 3/4, 4/4)
- **Compound meters:** Beat divides into 3 (6/8, 9/8, 12/8)
- **Mixed meters:** Changing time signatures within piece
- **Asymmetrical meters:** Irregular groupings (5/4, 7/8)

---

## Key Signatures and Accidentals

### Key Signature Order
**Sharp Order:** F# - C# - G# - D# - A# - E# - B#
**Flat Order:** B♭ - E♭ - A♭ - D♭ - G♭ - C♭ - F♭

### Major Key Signatures

| Key | Sharps/Flats | Accidentals |
|-----|-------------|-------------|
| C Major | None | - |
| G Major | 1♯ | F♯ |
| D Major | 2♯ | F♯, C♯ |
| A Major | 3♯ | F♯, C♯, G♯ |
| E Major | 4♯ | F♯, C♯, G♯, D♯ |
| B Major | 5♯ | F♯, C♯, G♯, D♯, A♯ |
| F♯ Major | 6♯ | F♯, C♯, G♯, D♯, A♯, E♯ |
| F Major | 1♭ | B♭ |
| B♭ Major | 2♭ | B♭, E♭ |
| E♭ Major | 3♭ | B♭, E♭, A♭ |
| A♭ Major | 4♭ | B♭, E♭, A♭, D♭ |
| D♭ Major | 5♭ | B♭, E♭, A♭, D♭, G♭ |

### Accidentals
**Sharp (♯):** Raises note by semitone
**Flat (♭):** Lowers note by semitone  
**Natural (♮):** Cancels previous accidental
**Double Sharp (𝄪):** Raises note by whole tone
**Double Flat (𝄫):** Lowers note by whole tone

### Accidental Rules
1. **Duration:** Accidentals last until end of measure
2. **Pitch Specific:** Only affect the exact pitch/octave
3. **Ties:** Accidental carries over tied notes
4. **New Measure:** Accidentals reset (unless in key signature)

```python
ACCIDENTALS = {
    'sharp': '♯',
    'flat': '♭', 
    'natural': '♮',
    'double_sharp': '𝄪',
    'double_flat': '𝄫'
}

def apply_accidental(midi_note, accidental):
    """Apply accidental to MIDI note number"""
    adjustments = {
        'sharp': 1,
        'flat': -1,
        'natural': 0,  # Context dependent
        'double_sharp': 2,
        'double_flat': -2
    }
    return midi_note + adjustments.get(accidental, 0)
```

---

## Rhythmic Notation

### Beaming Rules
**Purpose:** Group eighth notes and smaller for visual clarity
**Basic Rule:** Beam notes within one beat

#### Beaming in 4/4 Time
- **Beat 1:** ♪♪ (beam together)
- **Beat 2:** ♪♪ (beam together)
- **Across beats:** ♪ ♪ (don't beam)

#### Complex Beaming
- **Sixteenth notes:** Double beams
- **Mixed values:** Partial beams
- **Vocal music:** Beam syllables separately

```python
def should_beam(note1_start, note2_start, time_signature):
    """Determine if two notes should be beamed"""
    # Basic rule: beam within same beat
    beat_duration = 4.0 / time_signature['denominator']
    beat1 = int(note1_start / beat_duration)
    beat2 = int(note2_start / beat_duration) 
    return beat1 == beat2
```

### Tuplets
**Definition:** Irregular division of regular time values

#### Common Tuplets
- **Triplet (3:2):** 3 notes in space of 2
- **Quintuplet (5:4):** 5 notes in space of 4
- **Sextuplet (6:4):** 6 notes in space of 4
- **Duplet (2:3):** 2 notes in space of 3 (in compound time)

#### Tuplet Notation
- **Bracket:** Connects grouped notes
- **Number:** Shows irregular division
- **Ratio:** Sometimes shown as "3:2"

```python
def calculate_tuplet_duration(base_duration, tuplet_notes, tuplet_base):
    """Calculate individual note duration in tuplet"""
    total_tuplet_duration = base_duration * tuplet_base
    return total_tuplet_duration / tuplet_notes

# Example: Eighth note triplet in quarter note space
# calculate_tuplet_duration(0.25, 3, 2) = 0.167 beats per note
```

### Syncopation
**Definition:** Emphasis on weak beats or off-beats
**Notation Techniques:**
- Ties across beat boundaries
- Rests on strong beats
- Accents on weak beats

### Polyrhythms
**Definition:** Multiple rhythmic patterns simultaneously
**Common Examples:**
- 3 against 2
- 4 against 3
- Cross-rhythms in different voices

---

## Dynamics

### Dynamic Levels (Italian Terms)
| Symbol | Italian | Meaning | Relative Volume |
|--------|---------|---------|----------------|
| **ppp** | pianississimo | extremely soft | ~10% |
| **pp** | pianissimo | very soft | ~20% |
| **p** | piano | soft | ~30% |
| **mp** | mezzo-piano | moderately soft | ~45% |
| **mf** | mezzo-forte | moderately loud | ~60% |
| **f** | forte | loud | ~75% |
| **ff** | fortissimo | very loud | ~90% |
| **fff** | fortississimo | extremely loud | ~100% |

### Dynamic Changes
**Crescendo (cresc.):** Gradually getting louder
- **Symbol:** < (hairpin opening)
- **Duration:** Can span multiple measures

**Diminuendo/Decrescendo (dim./decresc.):** Gradually getting softer
- **Symbol:** > (hairpin closing)
- **Usage:** Return to softer dynamic

**Subito (sub.):** Suddenly
- **Example:** sub. p = suddenly soft
- **Usage:** Immediate dynamic change

### Accent Markings
- **> (Accent):** Emphasize note (louder, sharper attack)
- **^ (Marcato):** Strong accent, separated
- **- (Tenuto):** Hold full value, slight emphasis
- **. (Staccato):** Short, detached
- **sf/sfz (Sforzando):** Sudden strong accent

```python
DYNAMICS = {
    'ppp': {'volume': 0.1, 'midi_velocity': 8},
    'pp': {'volume': 0.2, 'midi_velocity': 16},
    'p': {'volume': 0.3, 'midi_velocity': 32},
    'mp': {'volume': 0.45, 'midi_velocity': 48},
    'mf': {'volume': 0.6, 'midi_velocity': 64},
    'f': {'volume': 0.75, 'midi_velocity': 80},
    'ff': {'volume': 0.9, 'midi_velocity': 96},
    'fff': {'volume': 1.0, 'midi_velocity': 127}
}
```

---

## Articulation

### Basic Articulation Marks

#### Staccato (.)
**Effect:** Short, detached
**Duration:** ~50% of written value
**Sound:** Crisp, separated

#### Legato (slur)
**Effect:** Smooth, connected
**Symbol:** Curved line over notes
**Sound:** No separation between pitches

#### Tenuto (-)
**Effect:** Hold full value
**Emphasis:** Slight stress, connected
**Duration:** Full written value or slightly longer

#### Accent (>)
**Effect:** Emphasized attack
**Volume:** Louder than surrounding notes
**Duration:** Normal note length

#### Marcato (^)
**Effect:** Strong accent with separation
**Attack:** Forceful, detached
**Character:** Aggressive, punctuated

### Advanced Articulations

#### Slur vs. Tie
- **Slur:** Connects different pitches (legato)
- **Tie:** Connects same pitch (duration extension)

#### Phrase Marks
**Purpose:** Show musical phrases (longer than slurs)
**Symbol:** Long curved line over phrase
**Interpretation:** Musical sentence structure

### String Techniques
- **Pizzicato (pizz.):** Pluck strings instead of bow
- **Arco:** Return to bowing (after pizzicato)
- **Sul ponticello:** Bow near bridge (metallic sound)
- **Sul tasto:** Bow over fingerboard (soft sound)

### Wind Techniques
- **Tonguing:** Standard attack with tongue
- **Slur:** No tonguing between notes
- **Flutter tonguing:** Rapid tongue roll
- **Double tonguing:** Rapid alternating tongue positions

```python
ARTICULATIONS = {
    'staccato': {'symbol': '.', 'duration_multiplier': 0.5},
    'tenuto': {'symbol': '-', 'duration_multiplier': 1.0},
    'accent': {'symbol': '>', 'velocity_multiplier': 1.3},
    'marcato': {'symbol': '^', 'velocity_multiplier': 1.5, 'duration_multiplier': 0.8},
    'legato': {'symbol': 'slur', 'connection': True}
}
```

---

## Expression Markings

### Tempo Markings (Italian)

#### Basic Tempos
| Marking | BPM Range | Character |
|---------|-----------|-----------|
| **Largo** | 40-60 | Very slow, broad |
| **Adagio** | 66-76 | Slow, leisurely |
| **Andante** | 76-108 | Walking pace |
| **Moderato** | 108-120 | Moderate |
| **Allegro** | 120-168 | Fast, lively |
| **Presto** | 168-200 | Very fast |
| **Prestissimo** | >200 | Extremely fast |

#### Tempo Modifiers
- **Molto:** Much (molto allegro = very fast)
- **Poco:** A little (poco più mosso = a little faster)
- **Assai:** Very (allegro assai = very fast)
- **Con:** With (con brio = with spirit)

#### Tempo Changes
- **Accelerando (accel.):** Gradually faster
- **Rallentando (rall.):** Gradually slower  
- **Ritardando (rit.):** Gradually slower
- **Rubato:** Flexible tempo
- **A tempo:** Return to original tempo

### Character Markings
- **Espressivo (espr.):** Expressively
- **Dolce:** Sweetly, gently
- **Cantabile:** In a singing style
- **Giocoso:** Playfully
- **Maestoso:** Majestically
- **Misterioso:** Mysteriously

### Performance Instructions
- **Da capo (D.C.):** Return to beginning
- **Dal segno (D.S.):** Return to sign
- **Fine:** End
- **Coda:** Concluding section
- **Fermata (𝄐):** Hold note longer than written value

```python
TEMPO_MARKINGS = {
    'largo': {'bpm_min': 40, 'bpm_max': 60, 'character': 'very slow'},
    'adagio': {'bpm_min': 66, 'bpm_max': 76, 'character': 'slow'},
    'andante': {'bpm_min': 76, 'bpm_max': 108, 'character': 'walking'},
    'moderato': {'bpm_min': 108, 'bpm_max': 120, 'character': 'moderate'},
    'allegro': {'bpm_min': 120, 'bpm_max': 168, 'character': 'fast'},
    'presto': {'bpm_min': 168, 'bpm_max': 200, 'character': 'very fast'}
}
```

---

## Advanced Notation

### Ornaments
**Trill (tr):** Rapid alternation between main note and note above
**Mordent (𝄽):** Quick alternation: main-upper-main
**Turn (𝄾):** Four-note figure around main note
**Appoggiatura:** Accented grace note resolving stepwise
**Acciaccatura:** Quick grace note (crushed)

### Grace Notes
**Appearance:** Small notes before main note
**Types:**
- **Short grace note:** Quick ornament
- **Long grace note:** Takes time from main note

### Glissando
**Symbol:** Wavy line between notes
**Effect:** Slide smoothly between pitches
**Instruments:** Piano, harp, strings, trombone

### Tremolo
**String tremolo:** Rapid bow changes on same note
**Keyboard tremolo:** Rapid alternation between notes
**Notation:** Slashes through stem

### Special Techniques

#### Harmonics
**Natural harmonics:** Light finger touch at specific points
**Artificial harmonics:** Finger and thumb technique
**Notation:** Diamond-shaped note heads

#### Microtones
**Quarter tones:** Intervals smaller than semitone
**Notation:** Special accidental symbols
**Usage:** Contemporary classical, world music

### Extended Techniques
**Prepared piano:** Objects placed on strings
**Extended bowing:** Non-traditional bow techniques
**Multiphonics:** Multiple pitches simultaneously on wind instruments

---

## Digital Implementation

### MIDI Representation
```python
class MIDINote:
    def __init__(self, pitch, start_time, duration, velocity, channel=1):
        self.pitch = pitch          # MIDI note number (0-127)
        self.start_time = start_time # Start time in beats
        self.duration = duration     # Duration in beats
        self.velocity = velocity     # Attack velocity (0-127)
        self.channel = channel       # MIDI channel (1-16)
        
    def to_midi_events(self, ticks_per_beat=480):
        """Convert to MIDI note on/off events"""
        start_tick = int(self.start_time * ticks_per_beat)
        end_tick = int((self.start_time + self.duration) * ticks_per_beat)
        
        note_on = {
            'type': 'note_on',
            'tick': start_tick,
            'pitch': self.pitch,
            'velocity': self.velocity,
            'channel': self.channel
        }
        
        note_off = {
            'type': 'note_off', 
            'tick': end_tick,
            'pitch': self.pitch,
            'velocity': 0,
            'channel': self.channel
        }
        
        return [note_on, note_off]
```

### Notation Rendering
```python
class NotationRenderer:
    def __init__(self, time_signature, key_signature, clef='treble'):
        self.time_signature = time_signature
        self.key_signature = key_signature
        self.clef = clef
        
    def render_note(self, midi_pitch, start_beat, duration):
        """Convert MIDI note to staff notation"""
        # Calculate staff position
        staff_position = self.midi_to_staff_position(midi_pitch)
        
        # Determine note value
        note_type = self.duration_to_note_type(duration)
        
        # Check for accidentals
        accidental = self.check_accidental(midi_pitch)
        
        return {
            'staff_position': staff_position,
            'note_type': note_type,
            'accidental': accidental,
            'start_beat': start_beat,
            'duration': duration
        }
        
    def midi_to_staff_position(self, midi_pitch):
        """Convert MIDI pitch to staff line/space"""
        if self.clef == 'treble':
            # Middle C (60) = ledger line below staff
            return (midi_pitch - 60) * 0.5
        elif self.clef == 'bass':
            # Middle C (60) = ledger line above staff  
            return (midi_pitch - 48) * 0.5
            
    def duration_to_note_type(self, duration):
        """Convert duration to note type"""
        if duration >= 4.0:
            return 'whole'
        elif duration >= 2.0:
            return 'half'
        elif duration >= 1.0:
            return 'quarter'
        elif duration >= 0.5:
            return 'eighth'
        elif duration >= 0.25:
            return 'sixteenth'
        else:
            return 'thirty_second'
```

### Automatic Beaming
```python
def auto_beam_notes(notes, time_signature):
    """Automatically beam eighth notes and smaller"""
    beamed_groups = []
    current_group = []
    beat_duration = 4.0 / time_signature['denominator']
    
    for note in notes:
        # Only beam eighth notes and smaller
        if note.duration <= 0.5:
            current_beat = int(note.start_time / beat_duration)
            
            if current_group and current_beat != current_group[-1]['beat']:
                # New beat - finish current group
                if len(current_group) > 1:
                    beamed_groups.append(current_group)
                current_group = []
            
            current_group.append({
                'note': note,
                'beat': current_beat
            })
        else:
            # Note too long to beam - finish current group
            if len(current_group) > 1:
                beamed_groups.append(current_group)
            current_group = []
    
    # Finish last group
    if len(current_group) > 1:
        beamed_groups.append(current_group)
        
    return beamed_groups
```

### Score Layout
```python
class ScoreLayout:
    def __init__(self, page_width=210, page_height=297):  # A4 in mm
        self.page_width = page_width
        self.page_height = page_height
        self.staff_height = 6  # mm between staff lines
        self.systems_per_page = 8
        self.measures_per_system = 4
        
    def layout_score(self, measures):
        """Layout measures into systems and pages"""
        systems = []
        current_system = []
        
        for i, measure in enumerate(measures):
            current_system.append(measure)
            
            if len(current_system) >= self.measures_per_system:
                systems.append(current_system)
                current_system = []
        
        # Add remaining measures
        if current_system:
            systems.append(current_system)
            
        return self.systems_to_pages(systems)
    
    def systems_to_pages(self, systems):
        """Group systems into pages"""
        pages = []
        current_page = []
        
        for system in systems:
            current_page.append(system)
            
            if len(current_page) >= self.systems_per_page:
                pages.append(current_page)
                current_page = []
                
        if current_page:
            pages.append(current_page)
            
        return pages
```

### Export Formats
```python
class NotationExporter:
    def export_musicxml(self, score):
        """Export to MusicXML format"""
        # MusicXML is standard for notation interchange
        pass
        
    def export_midi(self, score):
        """Export to MIDI format"""
        # Standard for digital audio workstations
        pass
        
    def export_ly(self, score):
        """Export to LilyPond format"""
        # High-quality notation rendering
        pass
        
    def export_mei(self, score):
        """Export to MEI (Music Encoding Initiative)"""
        # Academic standard for music encoding
        pass
```

---

## Summary and Best Practices

### Core Principles
1. **Clarity:** Notation should be easily readable
2. **Consistency:** Use standard conventions
3. **Context:** Consider the performer and instrument
4. **Efficiency:** Minimize visual clutter

### Digital Workflow
1. **Input:** MIDI or digital notation software
2. **Processing:** Apply notation rules automatically
3. **Review:** Manual cleanup for complex cases
4. **Export:** Multiple formats for different uses

### Common Mistakes to Avoid
- Incorrect beaming across beats
- Missing accidentals or naturals
- Poor stem direction choices
- Inconsistent articulation markings
- Unclear tuplet notation

### Performance Considerations
- **Sight-reading:** Clear, standard notation
- **Practice:** Helpful fingerings and bowings
- **Expression:** Appropriate dynamics and articulation
- **Technical:** Feasible for intended skill level

This comprehensive guide provides the foundation for understanding and implementing musical notation in both traditional and digital contexts, enabling accurate communication of musical ideas across different media and applications.