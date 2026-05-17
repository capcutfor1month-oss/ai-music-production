# Mixing & Mastering Intelligence - Complete Source of Truth

## Table of Contents
1. [Gain Staging Fundamentals](#gain-staging-fundamentals)
2. [Frequency Management & EQ](#frequency-management--eq)
3. [Dynamic Processing & Compression](#dynamic-processing--compression)
4. [Spatial Processing & Stereo Imaging](#spatial-processing--stereo-imaging)
5. [Advanced Processing Techniques](#advanced-processing-techniques)
6. [Loudness Standards & Delivery](#loudness-standards--delivery)
7. [Genre-Specific Approaches](#genre-specific-approaches)
8. [Automation & Movement](#automation--movement)
9. [Monitoring & Metering](#monitoring--metering)
10. [Implementation Algorithms](#implementation-algorithms)

---

## Gain Staging Fundamentals

### Core Principles
```python
GAIN_STAGING_STANDARDS = {
    'recording_level': {
        'target_peak': -12,  # dBFS
        'average_level': -18,  # dBFS (0 VU)
        'maximum_peak': -6,  # dBFS
        'reason': 'Leaves headroom for processing and prevents clipping'
    },
    'mixing_levels': {
        'individual_tracks': -18,  # dBFS average
        'mix_bus': -6,  # dBFS peak headroom
        'plugin_input': 'Unity gain principle - what goes in equals what comes out'
    },
    'bit_depth_considerations': {
        '24_bit': {
            'noise_floor': -144,  # dBFS
            'dynamic_range': 144,  # dB
            'optimal_recording': -18  # dBFS average
        },
        '32_bit_float': {
            'noise_floor': 'Virtually unlimited',
            'clipping_point': 'Cannot clip internally',
            'use_case': 'DAW internal processing'
        }
    }
}
```

### Gain Structure Flow
```python
def optimize_gain_structure(track):
    """
    Systematic approach to gain staging
    """
    stages = {
        'input_gain': 'Adjust at preamp/interface',
        'clip_gain': 'Normalize to -18 dBFS average',
        'plugin_gains': 'Maintain unity through chain',
        'fader_position': 'Keep near 0 dB for resolution',
        'bus_sends': 'Compensate for summing',
        'master_bus': 'Target -6 dBFS peak headroom'
    }
    
    # VU Meter calibration
    vu_calibration = {
        'reference_level': -18,  # dBFS = 0 VU
        'k_system': {
            'K-20': 'Mixing - 20 dB headroom',
            'K-14': 'Mastering - 14 dB headroom',
            'K-12': 'Broadcast - 12 dB headroom'
        }
    }
    return stages

```

---

## Frequency Management & EQ

### Frequency Allocation Map
```python
FREQUENCY_RANGES = {
    'sub_bass': {
        'range': (20, 60),
        'instruments': ['808', 'sub_synth', 'kick_fundamental'],
        'character': 'Felt more than heard, foundation'
    },
    'bass': {
        'range': (60, 250),
        'instruments': ['bass_guitar', 'kick_body', 'low_synths'],
        'character': 'Weight and power'
    },
    'low_mids': {
        'range': (250, 500),
        'instruments': ['snare_body', 'guitar_body', 'male_vocal_fundamental'],
        'character': 'Fullness, can cause muddiness'
    },
    'mids': {
        'range': (500, 2000),
        'instruments': ['vocals', 'guitars', 'keys', 'snare_crack'],
        'character': 'Presence, intelligibility'
    },
    'upper_mids': {
        'range': (2000, 4000),
        'instruments': ['vocal_presence', 'guitar_attack', 'percussion'],
        'character': 'Edge, can be harsh'
    },
    'presence': {
        'range': (4000, 6000),
        'instruments': ['vocal_sibilance', 'cymbals', 'string_brightness'],
        'character': 'Clarity, definition'
    },
    'brilliance': {
        'range': (6000, 20000),
        'instruments': ['air', 'cymbal_shimmer', 'harmonic_overtones'],
        'character': 'Sparkle, openness'
    }
}
```

### Frequency Masking Solutions
```python
class FrequencyMaskingResolver:
    """
    Intelligent frequency conflict detection and resolution
    """
    
    def detect_masking(self, track1_spectrum, track2_spectrum):
        """
        Identify overlapping frequency content
        """
        masking_zones = []
        for freq in range(20, 20000):
            track1_energy = track1_spectrum[freq]
            track2_energy = track2_spectrum[freq]
            
            if track1_energy > -20 and track2_energy > -20:
                overlap_db = min(track1_energy, track2_energy)
                if overlap_db > -15:  # Significant overlap
                    masking_zones.append({
                        'frequency': freq,
                        'severity': overlap_db,
                        'tracks': [track1, track2]
                    })
        return masking_zones
    
    def resolve_conflicts(self, masking_zones):
        """
        Apply strategic EQ cuts to create space
        """
        resolutions = []
        for zone in masking_zones:
            # Determine priority instrument
            if 'vocal' in zone['tracks']:
                cut_track = [t for t in zone['tracks'] if 'vocal' not in t][0]
                boost_track = 'vocal'
            elif 'kick' in zone['tracks'] and zone['frequency'] < 100:
                cut_track = 'bass'
                boost_track = 'kick'
            
            resolution = {
                'cut': {
                    'track': cut_track,
                    'frequency': zone['frequency'],
                    'q': 2.0,  # Narrow cut
                    'gain': -3.0  # dB
                },
                'boost': {
                    'track': boost_track,
                    'frequency': zone['frequency'],
                    'q': 0.7,  # Wide boost
                    'gain': 1.5  # dB
                }
            }
            resolutions.append(resolution)
        return resolutions
```

### EQ Techniques
```python
EQ_STRATEGIES = {
    'subtractive_first': {
        'principle': 'Remove problems before enhancing',
        'workflow': [
            'High-pass unnecessary low frequencies',
            'Notch out resonances',
            'Reduce masking frequencies',
            'Then boost character frequencies'
        ]
    },
    'surgical_eq': {
        'q_value': 'Greater than 5',
        'gain_range': (-6, -12),
        'use_cases': ['Remove resonances', 'Fix room modes', 'Eliminate feedback']
    },
    'musical_eq': {
        'q_value': '0.5 to 2',
        'gain_range': (-3, 3),
        'use_cases': ['Tonal shaping', 'Character enhancement', 'Mix balancing']
    },
    'dynamic_eq': {
        'advantage': 'Frequency-specific compression',
        'applications': [
            'Control sibilance without dulling',
            'Tame resonances only when they occur',
            'Duck bass for kick without constant cut'
        ]
    }
}
```

---

## Dynamic Processing & Compression

### Compression Parameters Deep Dive
```python
COMPRESSION_SETTINGS = {
    'vocals': {
        'lead': {
            'ratio': (3, 8),
            'attack': (5, 15),  # ms
            'release': (40, 100),  # ms
            'threshold': 'Set for 3-7 dB reduction on peaks',
            'knee': 'Soft (2-4 dB)',
            'makeup_gain': 'Match RMS level'
        },
        'backing': {
            'ratio': (4, 10),
            'attack': (0.5, 5),
            'release': (30, 60),
            'reduction': '5-10 dB for consistency'
        }
    },
    'drums': {
        'kick': {
            'ratio': (4, 8),
            'attack': (1, 10),  # Let transient through
            'release': (50, 200),
            'sidechain_hpf': 60  # Hz - ignore sub frequencies
        },
        'snare': {
            'ratio': (3, 6),
            'attack': (5, 15),
            'release': (80, 150),
            'parallel_blend': 0.5  # 50% wet/dry
        },
        'overheads': {
            'ratio': (2, 4),
            'attack': (10, 30),
            'release': (100, 'auto'),
            'type': 'VCA or Opto emulation'
        }
    },
    'bass': {
        'electric': {
            'ratio': (4, 8),
            'attack': (10, 30),
            'release': (50, 200),
            'reduction': '3-5 dB average'
        },
        'synth': {
            'ratio': (6, 'inf'),
            'attack': (0.1, 5),
            'release': (30, 100),
            'purpose': 'Limiting for consistency'
        }
    },
    'mix_bus': {
        'ratio': (1.5, 3),
        'attack': (10, 30),
        'release': (100, 'auto'),
        'reduction': '1-3 dB max',
        'knee': 'Soft',
        'purpose': 'Glue compression'
    },
    'mastering': {
        'ratio': (1.2, 2),
        'attack': (20, 50),
        'release': (100, 200),
        'reduction': '1-2 dB max',
        'knee': 'Soft',
        'threshold': 'High - only catch peaks'
    }
}
```

### Advanced Compression Techniques
```python
class AdvancedCompression:
    """
    Sophisticated compression strategies
    """
    
    def parallel_compression(self, signal, settings):
        """
        New York compression for punch and weight
        """
        # Heavy compression settings
        compressed = self.compress(signal, {
            'ratio': 10,
            'attack': 0.1,
            'release': 100,
            'threshold': -30,  # Heavy compression
            'makeup': 10
        })
        
        # Blend with dry signal
        blend_ratio = settings.get('blend', 0.5)
        return (signal * (1 - blend_ratio)) + (compressed * blend_ratio)
    
    def sidechain_compression(self, signal, trigger, settings):
        """
        Duck signal based on trigger input
        """
        compression_params = {
            'ratio': settings.get('ratio', 8),
            'attack': settings.get('attack', 0.1),  # Fast
            'release': settings.get('release', 100),
            'threshold': self.analyze_trigger_level(trigger)
        }
        
        # Apply compression when trigger exceeds threshold
        for sample in range(len(signal)):
            if trigger[sample] > compression_params['threshold']:
                signal[sample] = self.apply_gain_reduction(
                    signal[sample], 
                    compression_params
                )
        return signal
    
    def multiband_compression(self, signal, bands=4):
        """
        Frequency-selective dynamics control
        """
        band_settings = {
            'low': {
                'range': (20, 250),
                'ratio': 3,
                'attack': 10,
                'release': 100
            },
            'low_mid': {
                'range': (250, 1000),
                'ratio': 2.5,
                'attack': 5,
                'release': 80
            },
            'high_mid': {
                'range': (1000, 4000),
                'ratio': 2,
                'attack': 3,
                'release': 60
            },
            'high': {
                'range': (4000, 20000),
                'ratio': 1.8,
                'attack': 1,
                'release': 40
            }
        }
        
        # Split signal into bands
        bands = self.crossover_split(signal, band_settings)
        
        # Compress each band independently
        for band_name, band_signal in bands.items():
            bands[band_name] = self.compress(
                band_signal, 
                band_settings[band_name]
            )
        
        # Recombine bands
        return self.sum_bands(bands)
```

### Serial Compression Chain
```python
SERIAL_COMPRESSION_STRATEGY = {
    'stage_1': {
        'purpose': 'Gentle leveling',
        'ratio': 2,
        'reduction': '2-3 dB',
        'character': 'Transparent'
    },
    'stage_2': {
        'purpose': 'Character compression',
        'ratio': 4,
        'reduction': '3-5 dB',
        'character': 'Color/vibe (1176, LA-2A style)'
    },
    'stage_3': {
        'purpose': 'Peak limiting',
        'ratio': 'inf',
        'reduction': 'Catch occasional peaks only',
        'character': 'Clean limiting'
    }
}
```

---

## Spatial Processing & Stereo Imaging

### Stereo Field Management
```python
class StereoImaging:
    """
    Advanced stereo width and depth processing
    """
    
    def mid_side_processing(self, left, right):
        """
        Convert L/R to M/S for independent processing
        """
        mid = (left + right) / 2  # Mono content
        side = (left - right) / 2  # Stereo content
        
        return {
            'mid': mid,
            'side': side,
            'decode': lambda m, s: {
                'left': m + s,
                'right': m - s
            }
        }
    
    def width_control(self, signal, width_percentage):
        """
        Adjust stereo width (0% = mono, 100% = original, 200% = extra wide)
        """
        ms = self.mid_side_processing(signal['left'], signal['right'])
        
        # Adjust side level for width
        width_factor = width_percentage / 100
        ms['side'] *= width_factor
        
        # Decode back to L/R
        return ms['decode'](ms['mid'], ms['side'])
    
    def haas_effect(self, signal, delay_ms=10):
        """
        Create width through micro-delays
        """
        delay_samples = int((delay_ms / 1000) * self.sample_rate)
        
        # Delay one channel slightly
        left = signal['left']
        right = np.concatenate([
            np.zeros(delay_samples),
            signal['right'][:-delay_samples]
        ])
        
        return {'left': left, 'right': right}
    
    def frequency_dependent_panning(self, signal):
        """
        Keep low frequencies centered, spread highs
        """
        # Split into frequency bands
        low = self.lowpass(signal, 250)
        mid = self.bandpass(signal, 250, 4000)
        high = self.highpass(signal, 4000)
        
        # Apply different stereo processing to each band
        processed = {
            'low': self.width_control(low, 30),  # Narrow
            'mid': self.width_control(mid, 100),  # Natural
            'high': self.width_control(high, 130)  # Wide
        }
        
        return self.sum_bands(processed)
```

### 3D Spatial Positioning
```python
SPATIAL_MIXING_PRINCIPLES = {
    'horizontal_plane': {
        'left_right': 'Standard panning',
        'techniques': ['Pan pots', 'Balance control', 'Haas effect']
    },
    'depth_plane': {
        'front_back': 'Perceived distance',
        'techniques': [
            'Volume (6 dB = doubling distance)',
            'High frequency damping (air absorption)',
            'Reverb (more = further)',
            'Pre-delay (less = further)',
            'Compression (more = closer)'
        ]
    },
    'vertical_plane': {
        'up_down': 'Frequency-based perception',
        'techniques': [
            'High frequencies perceived as "up"',
            'Low frequencies perceived as "down"',
            'Psychoacoustic elevation'
        ]
    }
}
```

---

## Advanced Processing Techniques

### Saturation and Harmonics
```python
class SaturationProcessor:
    """
    Add warmth and harmonic richness
    """
    
    def tape_saturation(self, signal, drive=0.5):
        """
        Emulate analog tape compression and harmonic generation
        """
        # Soft-knee compression characteristic
        threshold = 1.0 - (drive * 0.8)
        
        # Generate harmonics
        harmonics = {
            '2nd': signal ** 2 * 0.05 * drive,  # Even harmonics (warmth)
            '3rd': signal ** 3 * 0.02 * drive,  # Odd harmonics (edge)
        }
        
        # Apply soft clipping
        output = np.tanh(signal * (1 + drive))
        
        # Add harmonics
        for harmonic in harmonics.values():
            output += harmonic
            
        return output
    
    def tube_warmth(self, signal, warmth=0.5):
        """
        Tube-style even harmonic emphasis
        """
        # Generate primarily 2nd harmonic
        second_harmonic = np.abs(signal) * signal * warmth * 0.1
        
        # Soft compression
        compressed = signal / (1 + np.abs(signal) * warmth)
        
        return compressed + second_harmonic
```

### Transient Design
```python
class TransientShaper:
    """
    Enhance or suppress attack and sustain
    """
    
    def detect_transients(self, signal, window=256):
        """
        Identify transient locations and strength
        """
        # Calculate energy difference
        energy = signal ** 2
        smoothed = self.moving_average(energy, window)
        transients = energy - smoothed
        
        return transients > np.percentile(transients, 90)
    
    def shape_attack(self, signal, amount):
        """
        Enhance (+) or soften (-) transients
        """
        transients = self.detect_transients(signal)
        
        for i, is_transient in enumerate(transients):
            if is_transient:
                # Apply gain to transient
                gain = 1 + (amount / 100)
                signal[i:i+100] *= gain  # 100 samples attack time
                
        return signal
    
    def shape_sustain(self, signal, amount):
        """
        Control body and decay of sounds
        """
        envelope = self.extract_envelope(signal)
        
        # Modify sustain portion
        sustain_gain = 1 + (amount / 100)
        
        for i in range(len(signal)):
            if not self.is_transient(i):
                signal[i] *= sustain_gain
                
        return signal
```

---

## Loudness Standards & Delivery

### Platform-Specific Mastering
```python
STREAMING_PLATFORMS_2024 = {
    'spotify': {
        'target_lufs': -14,
        'true_peak': -1,
        'normalization': 'User selectable: -11, -14, -19',
        'codec': 'OGG Vorbis 320kbps (premium)',
        'recommendation': 'Master to -9 LUFS for genre competitiveness'
    },
    'apple_music': {
        'target_lufs': -16,
        'true_peak': -1,
        'normalization': 'Sound Check (can be disabled)',
        'codec': 'AAC 256kbps',
        'recommendation': 'Use Apple Digital Masters guidelines'
    },
    'youtube': {
        'target_lufs': -14,
        'true_peak': -1,
        'normalization': 'Only turns down, never up',
        'codec': 'Opus/AAC',
        'recommendation': 'Account for lossy codec artifacts'
    },
    'tidal': {
        'target_lufs': -14,
        'true_peak': -1,
        'normalization': 'Album normalization available',
        'codec': 'FLAC (HiFi), MQA (Masters)',
        'recommendation': 'Preserve dynamics for audiophile audience'
    },
    'soundcloud': {
        'target_lufs': 'No normalization',
        'true_peak': -0.5,
        'codec': 'MP3 128kbps (free), 256kbps (Go+)',
        'recommendation': 'Master competitively loud but clean'
    }
}

def master_for_streaming(audio, target_platform='spotify'):
    """
    Optimize master for specific streaming platform
    """
    platform = STREAMING_PLATFORMS_2024[target_platform]
    
    # Analyze current loudness
    current_lufs = measure_integrated_loudness(audio)
    
    # Determine target based on genre and platform
    if platform['normalization']:
        # Can be louder than platform target
        genre_target = get_genre_loudness_target()
        target_lufs = max(platform['target_lufs'], genre_target)
    else:
        # No normalization, master competitively
        target_lufs = -9  # Modern commercial loudness
    
    # Apply limiting
    limited = true_peak_limit(audio, platform['true_peak'])
    
    # Adjust integrated loudness
    gain = target_lufs - current_lufs
    return apply_gain(limited, gain)
```

### LUFS Measurement Implementation
```python
class LoudnessMeter:
    """
    ITU-R BS.1770-4 compliant loudness measurement
    """
    
    def k_weighting_filter(self, signal, sample_rate):
        """
        Apply K-weighting for perceptual loudness
        """
        # High shelf filter (1681 Hz, +4 dB)
        # High-pass filter (60 Hz, 12 dB/octave)
        return self.apply_filters(signal, sample_rate)
    
    def measure_lufs(self, audio, gate=True):
        """
        Calculate integrated LUFS
        """
        # Apply K-weighting
        weighted = self.k_weighting_filter(audio)
        
        # Calculate mean square
        ms = np.mean(weighted ** 2)
        
        # Convert to LUFS
        lufs = -0.691 + 10 * np.log10(ms)
        
        if gate:
            # Apply -70 LUFS absolute gate
            # Apply -10 LU relative gate
            lufs = self.apply_gating(lufs, weighted)
            
        return lufs
```

---

## Genre-Specific Approaches

### Electronic Dance Music (EDM)
```python
EDM_MIXING_STANDARDS = {
    'frequency_balance': {
        'sub_bass': {'range': (20, 60), 'level': 'Dominant'},
        'kick': {'range': (60, 100), 'level': 'Punchy, clear'},
        'bass': {'range': (100, 250), 'level': 'Supporting kick'},
        'mids': {'range': (250, 4000), 'level': 'Carved for space'},
        'highs': {'range': (4000, 20000), 'level': 'Bright, exciting'}
    },
    'dynamics': {
        'kick_sidechain': {
            'ratio': 8,
            'attack': 0.1,
            'release': 100,
            'reduction': '3-6 dB on bass/pads'
        },
        'drop_impact': {
            'buildup_hpf': 'Sweep from 200 Hz to 1 kHz',
            'silence_before': '1/8 to 1/4 bar',
            'sub_drop': 'Full frequency explosion'
        }
    },
    'master_loudness': {
        'integrated_lufs': -8 to -6,
        'peak_lufs': -4 to -3,
        'dynamic_range': '4-6 LU'
    }
}
```

### Rock/Alternative
```python
ROCK_MIXING_APPROACH = {
    'drums': {
        'room_mics': 'Compressed heavily for power',
        'parallel_compression': 'New York style on drum bus',
        'gate_toms': True,
        'sample_reinforcement': 'Blend with original'
    },
    'guitars': {
        'double_tracking': 'Hard pan L/R',
        'eq_approach': 'Cut 200-400 Hz mud',
        'amp_saturation': 'Preserve natural distortion',
        'solo_boost': '+3 dB at 2-3 kHz'
    },
    'bass': {
        'di_amp_blend': '50/50 for clarity and warmth',
        'compression': 'Heavy (6:1) for consistency',
        'eq': 'Boost 700-900 Hz for pick attack'
    },
    'vocals': {
        'compression': 'Medium-heavy for presence',
        'saturation': 'Tape/tube for aggression',
        'doubling': 'Chorus and harmonies wide'
    }
}
```

### Hip-Hop/Trap
```python
HIPHOP_PRODUCTION_SPECS = {
    'drums': {
        '808': {
            'tuning': 'Key of song',
            'saturation': 'Heavy for harmonics',
            'sidechain': 'To kick if overlapping'
        },
        'hi_hats': {
            'patterns': 'Triplet rolls, pitch bends',
            'panning': 'Subtle movement',
            'velocity': 'Humanized variation'
        },
        'snare': {
            'layer_clap': True,
            'reverb': 'Short room',
            'eq': 'Boost 200 Hz body'
        }
    },
    'vocals': {
        'auto_tune': 'Retune speed 0-20',
        'ad_libs': 'Panned wide, filtered',
        'compression': 'Heavy for in-your-face',
        'delay_throws': '1/8 and 1/4 note'
    },
    'master': {
        'loudness': -7 to -9 'LUFS',
        'bass_emphasis': '+2-3 dB at 60 Hz',
        'crispy_highs': 'Slight shelf at 10 kHz'
    }
}
```

---

## Automation & Movement

### Dynamic Automation Strategies
```python
class AutomationEngine:
    """
    Create movement and interest through automation
    """
    
    def create_filter_sweep(self, duration_bars=8, start_freq=200, end_freq=5000):
        """
        Classic EDM buildup filter automation
        """
        samples = duration_bars * self.samples_per_bar
        curve = np.logspace(
            np.log10(start_freq),
            np.log10(end_freq),
            samples
        )
        return curve
    
    def vocal_ride(self, vocal_track, reference_level=-18):
        """
        Automated fader riding for consistent vocals
        """
        window_size = int(0.1 * self.sample_rate)  # 100ms windows
        
        automation = []
        for i in range(0, len(vocal_track), window_size):
            window = vocal_track[i:i+window_size]
            current_level = 20 * np.log10(np.mean(np.abs(window)))
            
            # Calculate required gain
            gain_needed = reference_level - current_level
            
            # Smooth transitions
            if automation:
                gain_needed = 0.7 * automation[-1] + 0.3 * gain_needed
                
            automation.append(gain_needed)
            
        return self.interpolate_automation(automation, len(vocal_track))
    
    def create_pumping_effect(self, tempo_bpm=128):
        """
        Volume pumping synced to tempo
        """
        beat_samples = 60 / tempo_bpm * self.sample_rate
        
        # Create pump curve
        pump = []
        for beat in range(4):  # 4/4 pattern
            # Duck on beat
            attack = np.linspace(1, 0.5, int(beat_samples * 0.1))
            hold = np.ones(int(beat_samples * 0.2)) * 0.5
            release = np.linspace(0.5, 1, int(beat_samples * 0.7))
            pump.extend(attack)
            pump.extend(hold)
            pump.extend(release)
            
        return pump
```

### Creative Automation Ideas
```python
AUTOMATION_COOKBOOK = {
    'energy_builders': {
        'hpf_sweep': 'Low cut from 20 Hz to 500 Hz over 8 bars',
        'reverb_increase': 'Dry to 50% wet before drop',
        'stereo_width': 'Narrow to wide for impact'
    },
    'transitions': {
        'crossfade_eq': 'Swap frequency emphasis between sections',
        'delay_throw': 'Automate send on last vocal word',
        'reverse_reverb': 'Pre-fade reversed tail'
    },
    'rhythmic': {
        'tremolo': 'Volume modulation at 1/8 or 1/16',
        'auto_pan': 'Circular or ping-pong movement',
        'gate_patterns': 'Rhythmic muting patterns'
    },
    'subtle_movement': {
        'micro_pitch': '±5 cents variation for life',
        'saturation_rides': 'Increase on choruses',
        'compression_ratio': 'Heavier in dense sections'
    }
}
```

---

## Monitoring & Metering

### Professional Monitoring Setup
```python
MONITORING_STANDARDS = {
    'calibration': {
        'spl_level': 83,  # dB SPL at mix position
        'pink_noise': -20,  # dBFS per speaker
        'distance': 'Equilateral triangle with speakers',
        'angle': '30 degrees from center'
    },
    'room_treatment': {
        'first_reflections': 'Absorbers at mirror points',
        'bass_traps': 'Corners for low frequency control',
        'diffusion': 'Rear wall to prevent flutter echo',
        'rt60_target': 0.2 - 0.3  # seconds
    },
    'reference_tracks': {
        'purpose': 'A/B comparison for translation',
        'selection': 'Similar genre, well-mixed, commercial',
        'level_matching': 'Equal loudness for fair comparison'
    }
}
```

### Metering Tools
```python
class MeteringSystem:
    """
    Comprehensive metering for mixing and mastering
    """
    
    def __init__(self):
        self.meters = {
            'peak': self.peak_meter,
            'rms': self.rms_meter,
            'lufs': self.lufs_meter,
            'spectrum': self.spectrum_analyzer,
            'phase': self.phase_correlation_meter,
            'stereo': self.stereo_field_analyzer
        }
    
    def peak_meter(self, signal):
        """
        True peak measurement with oversampling
        """
        # 4x oversampling for true peak detection
        oversampled = self.oversample(signal, 4)
        return 20 * np.log10(np.max(np.abs(oversampled)))
    
    def rms_meter(self, signal, window_ms=300):
        """
        RMS level over time window
        """
        window_samples = int(window_ms / 1000 * self.sample_rate)
        rms = np.sqrt(np.mean(signal[-window_samples:] ** 2))
        return 20 * np.log10(rms)
    
    def phase_correlation_meter(self, left, right):
        """
        Measure stereo phase relationship
        """
        correlation = np.corrcoef(left, right)[0, 1]
        # +1 = mono, 0 = wide stereo, -1 = out of phase
        return correlation
    
    def spectrum_analyzer(self, signal, resolution=2048):
        """
        Real-time frequency analysis
        """
        spectrum = np.abs(np.fft.rfft(signal, resolution))
        frequencies = np.fft.rfftfreq(resolution, 1/self.sample_rate)
        return frequencies, 20 * np.log10(spectrum)
```

---

## Implementation Algorithms

### Automatic Mixing Algorithm
```python
class IntelligentMixer:
    """
    AI-assisted mixing decisions
    """
    
    def __init__(self):
        self.target_curves = self.load_genre_references()
        self.frequency_allocations = self.define_frequency_slots()
    
    def analyze_mix(self, tracks):
        """
        Comprehensive mix analysis
        """
        analysis = {
            'frequency_balance': self.analyze_spectrum_balance(tracks),
            'dynamic_range': self.measure_dynamics(tracks),
            'stereo_width': self.analyze_stereo_field(tracks),
            'masking_issues': self.detect_frequency_conflicts(tracks),
            'level_balance': self.analyze_relative_levels(tracks)
        }
        return analysis
    
    def suggest_improvements(self, analysis):
        """
        Generate mixing suggestions based on analysis
        """
        suggestions = []
        
        # Frequency balance corrections
        if analysis['frequency_balance']['low_mid_buildup'] > 3:
            suggestions.append({
                'type': 'eq',
                'tracks': analysis['problem_tracks'],
                'action': 'Cut 200-500 Hz by 3 dB with Q=1.5'
            })
        
        # Dynamic range optimization
        if analysis['dynamic_range'] < 6:
            suggestions.append({
                'type': 'compression',
                'track': 'master_bus',
                'action': 'Reduce ratio or increase threshold'
            })
        
        # Stereo width adjustment
        if analysis['stereo_width']['correlation'] > 0.8:
            suggestions.append({
                'type': 'stereo_imaging',
                'action': 'Increase width on pads/strings, pan percussions'
            })
        
        return suggestions
    
    def auto_mix(self, tracks, target_sound='professional'):
        """
        Automated mixing with target aesthetic
        """
        # Initial gain staging
        tracks = self.auto_gain_stage(tracks)
        
        # EQ for separation
        tracks = self.auto_eq_separation(tracks)
        
        # Compression for dynamics
        tracks = self.auto_compress(tracks)
        
        # Spatial positioning
        tracks = self.auto_pan_and_depth(tracks)
        
        # Bus processing
        mix = self.apply_bus_processing(tracks)
        
        # Final mastering
        master = self.auto_master(mix, target_sound)
        
        return master
```

### Mastering Chain Template
```python
MASTERING_SIGNAL_FLOW = [
    {
        'stage': 1,
        'process': 'Linear Phase EQ',
        'purpose': 'Corrective/tonal balance',
        'settings': 'Subtle broad strokes, ±2 dB max'
    },
    {
        'stage': 2,
        'process': 'Multiband Compression',
        'purpose': 'Frequency-specific dynamics',
        'settings': 'Gentle ratios, 1-2 dB reduction'
    },
    {
        'stage': 3,
        'process': 'Stereo Enhancement',
        'purpose': 'Width and depth',
        'settings': 'M/S EQ, slight side boost >8kHz'
    },
    {
        'stage': 4,
        'process': 'Harmonic Excitation',
        'purpose': 'Warmth and presence',
        'settings': 'Tape/tube saturation, subtle'
    },
    {
        'stage': 5,
        'process': 'Bus Compression',
        'purpose': 'Glue and cohesion',
        'settings': 'Ratio 1.5:1, slow attack, auto-release'
    },
    {
        'stage': 6,
        'process': 'Final EQ',
        'purpose': 'Last tonal adjustments',
        'settings': 'Reference matching, A/B testing'
    },
    {
        'stage': 7,
        'process': 'True Peak Limiting',
        'purpose': 'Loudness and peak control',
        'settings': 'Transparent limiting, -0.3 dB ceiling'
    },
    {
        'stage': 8,
        'process': 'Dithering',
        'purpose': 'Bit depth reduction',
        'settings': 'POW-r 3 for 24->16 bit conversion'
    }
]
```

### Quality Control Checklist
```python
MIX_MASTER_QC = {
    'technical_checks': [
        'No clipping or digital distortion',
        'Phase correlation > -1 (no cancellation)',
        'True peaks < -0.3 dBFS',
        'No DC offset',
        'Appropriate loudness for genre/platform'
    ],
    'musical_checks': [
        'Vocal intelligibility and presence',
        'Kick and bass relationship clear',
        'No frequency masking issues',
        'Appropriate dynamics preserved',
        'Stereo image balanced and wide'
    ],
    'translation_checks': [
        'Sounds good on phone speaker (mono)',
        'Translates to car stereo',
        'Works on earbuds',
        'Professional monitors reveal no issues',
        'Laptop speakers acceptable'
    ],
    'delivery_requirements': [
        'Correct file format (WAV/FLAC)',
        'Proper sample rate (44.1/48 kHz)',
        'Appropriate bit depth (16/24 bit)',
        'Metadata embedded',
        'Multiple versions if needed (radio, instrumental, etc.)'
    ]
}
```

---

## Reference Materials & Best Practices

### Industry Standard References
```python
REFERENCE_STANDARDS = {
    'loudness_targets': {
        'classical': -23 to -18,  # LUFS
        'jazz': -20 to -16,
        'rock': -12 to -9,
        'pop': -11 to -8,
        'edm': -8 to -6,
        'hip_hop': -9 to -7
    },
    'dynamic_range': {
        'classical': '20+ LU',
        'jazz': '15-20 LU',
        'rock': '8-12 LU',
        'pop': '6-10 LU',
        'edm': '4-8 LU',
        'hip_hop': '5-9 LU'
    },
    'frequency_response': {
        'flat_reference': '20 Hz - 20 kHz ±0.5 dB',
        'bass_boost': '+2-3 dB at 60-100 Hz',
        'presence_lift': '+1-2 dB at 3-5 kHz',
        'air_shelf': '+1 dB above 10 kHz'
    }
}
```

### Common Problems and Solutions
```python
TROUBLESHOOTING_GUIDE = {
    'muddy_mix': {
        'causes': ['Low-mid buildup', 'Too much reverb', 'Phase issues'],
        'solutions': [
            'High-pass filter non-bass elements',
            'Cut 200-500 Hz on multiple sources',
            'Check phase relationships',
            'Reduce reverb on low instruments'
        ]
    },
    'harsh_mix': {
        'causes': ['2-5 kHz buildup', 'Over-compression', 'Distortion'],
        'solutions': [
            'Gentle cuts around 2.5-3.5 kHz',
            'Use multiband compression on harsh frequencies',
            'Check for clipping in signal chain',
            'Add tape saturation for smoothing'
        ]
    },
    'lack_of_punch': {
        'causes': ['Over-compression', 'Poor transients', 'Wrong attack times'],
        'solutions': [
            'Slower attack on compressors',
            'Parallel compression for dynamics',
            'Transient shaping tools',
            'Check phase on multi-mic sources'
        ]
    },
    'poor_stereo_image': {
        'causes': ['Everything centered', 'Phase issues', 'Mono sources'],
        'solutions': [
            'Strategic panning decisions',
            'Haas effect for width',
            'M/S processing for enhancement',
            'Stereo delays and reverbs'
        ]
    }
}
```

---

**Document Version:** 2.0  
**Last Updated:** February 2024  
**Application:** Ableton MCP Phase 2 - Intelligence Layer  
**Next Document:** GENRE_ANALYSIS_SOURCE_OF_TRUTH.md