# Audio Processing & DSP - Complete Source of Truth

## Table of Contents
1. [Digital Signal Processing Fundamentals](#digital-signal-processing-fundamentals)
2. [Audio Effects Processing](#audio-effects-processing)
3. [Synthesis Methods](#synthesis-methods)
4. [Mixing and Signal Flow](#mixing-and-signal-flow)
5. [Audio Analysis Techniques](#audio-analysis-techniques)
6. [Implementation Algorithms](#implementation-algorithms)
7. [Professional Audio Standards](#professional-audio-standards)

---

## Digital Signal Processing Fundamentals

### Core Concepts

#### The Nyquist-Shannon Sampling Theorem
**Definition:** A continuous signal can be accurately reconstructed from discrete samples if the sampling rate is at least twice the highest frequency present in the signal.

**Mathematical Formula:**
```
Nyquist Frequency = Sampling Rate / 2
Minimum Sampling Rate = 2 × Highest Frequency
```

**Practical Implications:**
- **CD Audio (44.1 kHz):** Can capture up to 22.05 kHz (just above human hearing limit of ~20 kHz)
- **Professional Audio (48 kHz):** Nyquist frequency of 24 kHz, preferred for video production
- **High-Resolution (96 kHz):** Nyquist frequency of 48 kHz, used for critical recording

```python
SAMPLE_RATES = {
    '44100': {
        'nyquist_freq': 22050,
        'use_cases': ['CD production', 'consumer audio', 'final masters'],
        'bit_combinations': [16, 24, 32]
    },
    '48000': {
        'nyquist_freq': 24000,
        'use_cases': ['video production', 'professional recording', 'broadcast'],
        'bit_combinations': [16, 24, 32]
    },
    '96000': {
        'nyquist_freq': 48000,
        'use_cases': ['critical recording', 'mastering', 'high-end production'],
        'bit_combinations': [24, 32]
    },
    '192000': {
        'nyquist_freq': 96000,
        'use_cases': ['archival recording', 'specialized applications'],
        'bit_combinations': [24, 32]
    }
}
```

### Bit Depth and Dynamic Range

#### Bit Depth Specifications
```python
BIT_DEPTHS = {
    '16_bit': {
        'levels': 65536,  # 2^16
        'dynamic_range_db': 96.3,
        'noise_floor_db': -96.3,
        'use_cases': ['CD audio', 'consumer playback', 'final distribution']
    },
    '24_bit': {
        'levels': 16777216,  # 2^24
        'dynamic_range_db': 144.5,
        'noise_floor_db': -144.5,
        'use_cases': ['professional recording', 'mixing', 'mastering']
    },
    '32_bit_float': {
        'levels': 'virtually_unlimited',
        'dynamic_range_db': 1680,  # Theoretical
        'noise_floor_db': 'negligible',
        'use_cases': ['DAW internal processing', 'plugin chains', 'intermediate files'],
        'advantages': ['no_clipping', 'no_dithering_needed', 'accumulated_precision']
    }
}
```

#### Dynamic Range Calculation
```python
def calculate_dynamic_range(bit_depth):
    """Calculate theoretical dynamic range in dB"""
    if bit_depth == 32:  # Floating point
        return float('inf')  # Practically unlimited
    else:
        return bit_depth * 6.02 + 1.76  # Each bit = ~6.02dB

def db_to_linear(db_value):
    """Convert dB to linear scale"""
    return 10 ** (db_value / 20)

def linear_to_db(linear_value):
    """Convert linear scale to dB"""
    import math
    return 20 * math.log10(abs(linear_value))
```

### Aliasing and Anti-Aliasing

#### Aliasing Prevention
```python
class AntiAliasingFilter:
    def __init__(self, sample_rate, cutoff_ratio=0.9):
        self.sample_rate = sample_rate
        self.nyquist = sample_rate / 2
        self.cutoff = self.nyquist * cutoff_ratio  # 90% of Nyquist
        
    def design_lowpass_filter(self, order=8):
        """Design Butterworth lowpass filter for anti-aliasing"""
        from scipy import signal
        
        # Normalized cutoff frequency
        normalized_cutoff = self.cutoff / self.nyquist
        
        # Design filter
        b, a = signal.butter(order, normalized_cutoff, btype='low')
        
        return b, a
    
    def apply_oversampling(self, audio_data, oversample_factor=2):
        """Apply oversampling to reduce aliasing in nonlinear processing"""
        # Upsample
        upsampled = self.upsample(audio_data, oversample_factor)
        
        # Process at higher sample rate
        processed = self.nonlinear_process(upsampled)
        
        # Downsample with anti-aliasing
        return self.downsample_with_filtering(processed, oversample_factor)
```

---

## Audio Effects Processing

### Equalization (EQ)

#### Filter Types and Characteristics
```python
EQ_FILTER_TYPES = {
    'highpass': {
        'function': 'removes_frequencies_below_cutoff',
        'slope_options': ['6dB/octave', '12dB/octave', '18dB/octave', '24dB/octave'],
        'use_cases': ['remove_rumble', 'tighten_bass', 'vocal_cleanup'],
        'typical_frequencies': [20, 40, 80, 120]
    },
    'lowpass': {
        'function': 'removes_frequencies_above_cutoff',
        'slope_options': ['6dB/octave', '12dB/octave', '18dB/octave', '24dB/octave'],
        'use_cases': ['remove_harshness', 'warm_sound', 'anti_aliasing'],
        'typical_frequencies': [8000, 10000, 15000, 20000]
    },
    'bell': {
        'function': 'boost_or_cut_around_center_frequency',
        'parameters': ['frequency', 'gain', 'Q_factor'],
        'Q_ranges': {'narrow': 5.0, 'medium': 1.4, 'wide': 0.7},
        'use_cases': ['corrective_eq', 'tonal_shaping', 'problem_frequency_removal']
    },
    'shelf': {
        'types': ['low_shelf', 'high_shelf'],
        'function': 'gradual_boost_cut_above_below_frequency',
        'use_cases': ['bass_enhancement', 'brightness_control', 'mastering_eq']
    }
}
```

#### EQ Implementation
```python
class ParametricEQ:
    def __init__(self, sample_rate):
        self.sample_rate = sample_rate
        self.bands = []
    
    def add_bell_filter(self, frequency, gain_db, q_factor):
        """Add parametric bell filter band"""
        band = {
            'type': 'bell',
            'frequency': frequency,
            'gain': gain_db,
            'q': q_factor,
            'coefficients': self.calculate_bell_coefficients(frequency, gain_db, q_factor)
        }
        self.bands.append(band)
    
    def calculate_bell_coefficients(self, freq, gain_db, q):
        """Calculate biquad coefficients for bell filter"""
        import math
        
        A = 10 ** (gain_db / 40)
        omega = 2 * math.pi * freq / self.sample_rate
        sin_omega = math.sin(omega)
        cos_omega = math.cos(omega)
        alpha = sin_omega / (2 * q)
        
        # Biquad coefficients
        b0 = 1 + alpha * A
        b1 = -2 * cos_omega
        b2 = 1 - alpha * A
        a0 = 1 + alpha / A
        a1 = -2 * cos_omega
        a2 = 1 - alpha / A
        
        # Normalize
        return {
            'b0': b0/a0, 'b1': b1/a0, 'b2': b2/a0,
            'a1': a1/a0, 'a2': a2/a0
        }
```

### Compression and Dynamics Processing

#### Compressor Types and Parameters
```python
COMPRESSOR_TYPES = {
    'vca': {
        'character': 'clean, precise, punchy',
        'attack_range': (0.01, 100),  # ms
        'release_range': (1, 1000),   # ms
        'use_cases': ['drums', 'bass', 'vocals', 'mix_bus'],
        'famous_models': ['SSL Bus Compressor', 'API 2500']
    },
    'optical': {
        'character': 'smooth, musical, slow',
        'attack_range': (0.1, 100),
        'release_range': (50, 5000),
        'use_cases': ['vocals', 'bass', 'mix_glue'],
        'famous_models': ['LA-2A', 'LA-3A']
    },
    'fet': {
        'character': 'aggressive, colored, fast',
        'attack_range': (0.02, 50),
        'release_range': (5, 1000),
        'use_cases': ['drums', 'guitars', 'attitude'],
        'famous_models': ['1176', 'Distressor']
    },
    'tube': {
        'character': 'warm, harmonically_rich, slow',
        'attack_range': (0.1, 200),
        'release_range': (100, 10000),
        'use_cases': ['vocals', 'mix_bus', 'mastering'],
        'famous_models': ['Fairchild 660/670', 'Manley Variable Mu']
    }
}
```

#### Compression Algorithm
```python
class DynamicRangeCompressor:
    def __init__(self, sample_rate):
        self.sample_rate = sample_rate
        self.threshold_db = -20
        self.ratio = 4.0
        self.attack_ms = 10
        self.release_ms = 100
        self.makeup_gain_db = 0
        self.knee_width_db = 2
        
        # Internal state
        self.envelope = 0.0
        self.gain_reduction = 0.0
        
    def set_attack_release(self, attack_ms, release_ms):
        """Convert time constants to exponential coefficients"""
        self.attack_coeff = math.exp(-1.0 / (attack_ms * 0.001 * self.sample_rate))
        self.release_coeff = math.exp(-1.0 / (release_ms * 0.001 * self.sample_rate))
    
    def process_sample(self, input_sample):
        """Process single audio sample through compressor"""
        # Convert to dB
        input_level_db = linear_to_db(abs(input_sample))
        
        # Calculate gain reduction
        if input_level_db > self.threshold_db:
            # Above threshold - apply compression
            excess_db = input_level_db - self.threshold_db
            
            # Soft knee processing
            if excess_db < self.knee_width_db:
                # Soft knee region
                compressed_excess = excess_db * (1.0 + (self.ratio - 1.0) * 
                                               (excess_db / self.knee_width_db) ** 2) / 2.0
            else:
                # Hard compression region
                compressed_excess = self.knee_width_db / 2.0 + (excess_db - self.knee_width_db) / self.ratio
            
            target_gain_reduction = excess_db - compressed_excess
        else:
            target_gain_reduction = 0.0
        
        # Smooth gain reduction with attack/release
        if target_gain_reduction > self.gain_reduction:
            # Attack phase
            self.gain_reduction = target_gain_reduction * (1 - self.attack_coeff) + \
                                 self.gain_reduction * self.attack_coeff
        else:
            # Release phase  
            self.gain_reduction = target_gain_reduction * (1 - self.release_coeff) + \
                                 self.gain_reduction * self.release_coeff
        
        # Apply gain reduction and makeup gain
        output_gain_db = -self.gain_reduction + self.makeup_gain_db
        output_gain_linear = db_to_linear(output_gain_db)
        
        return input_sample * output_gain_linear
```

### Reverb and Spatial Effects

#### Reverb Types and Characteristics
```python
REVERB_TYPES = {
    'plate': {
        'character': 'bright, metallic, vintage',
        'decay_range': (0.5, 8.0),  # seconds
        'frequency_response': 'bright_high_end',
        'use_cases': ['vocals', 'snare', 'vintage_sound'],
        'parameters': ['decay_time', 'damping', 'predelay']
    },
    'hall': {
        'character': 'spacious, natural, classical',
        'decay_range': (1.0, 12.0),
        'frequency_response': 'natural_rolloff',
        'use_cases': ['orchestral', 'classical', 'ambient'],
        'parameters': ['room_size', 'decay_time', 'early_reflections']
    },
    'room': {
        'character': 'intimate, dry, realistic',
        'decay_range': (0.2, 3.0),
        'frequency_response': 'controlled_high_end',
        'use_cases': ['drums', 'intimate_vocals', 'natural_ambience'],
        'parameters': ['room_size', 'absorption', 'diffusion']
    },
    'spring': {
        'character': 'bouncy, lo_fi, surf',
        'decay_range': (0.1, 4.0),
        'frequency_response': 'colored_midrange',
        'use_cases': ['guitar_amps', 'vintage_effects', 'creative'],
        'parameters': ['spring_length', 'tension', 'resonance']
    }
}
```

#### Algorithmic Reverb Implementation
```python
class AlgorithmicReverb:
    def __init__(self, sample_rate):
        self.sample_rate = sample_rate
        self.room_size = 0.5
        self.decay_time = 2.0
        self.damping = 0.5
        self.predelay_ms = 20
        
        # Initialize delay lines and filters
        self.setup_delay_network()
        
    def setup_delay_network(self):
        """Set up Schroeder reverb network"""
        # Comb filter delays (in samples)
        comb_delays = [
            int(0.0297 * self.sample_rate),  # ~30ms
            int(0.0371 * self.sample_rate),  # ~37ms  
            int(0.0411 * self.sample_rate),  # ~41ms
            int(0.0437 * self.sample_rate)   # ~44ms
        ]
        
        # Allpass filter delays
        allpass_delays = [
            int(0.0050 * self.sample_rate),  # ~5ms
            int(0.0017 * self.sample_rate)   # ~1.7ms
        ]
        
        self.comb_filters = [CombFilter(delay, self.decay_time) for delay in comb_delays]
        self.allpass_filters = [AllpassFilter(delay, 0.7) for delay in allpass_delays]
        self.predelay = DelayLine(int(self.predelay_ms * self.sample_rate / 1000))
    
    def process(self, input_sample):
        """Process audio through reverb algorithm"""
        # Apply predelay
        delayed = self.predelay.process(input_sample)
        
        # Sum comb filter outputs
        comb_sum = sum(comb.process(delayed) for comb in self.comb_filters)
        
        # Process through allpass filters
        output = comb_sum
        for allpass in self.allpass_filters:
            output = allpass.process(output)
        
        return output

class CombFilter:
    def __init__(self, delay_samples, feedback_gain):
        self.delay_line = [0.0] * delay_samples
        self.write_index = 0
        self.feedback = feedback_gain
        
    def process(self, input_sample):
        read_index = self.write_index
        delayed_sample = self.delay_line[read_index]
        
        # Feedback
        self.delay_line[self.write_index] = input_sample + delayed_sample * self.feedback
        
        # Advance write pointer
        self.write_index = (self.write_index + 1) % len(self.delay_line)
        
        return delayed_sample
```

---

## Synthesis Methods

### Subtractive Synthesis

#### Signal Chain and Components
```python
SUBTRACTIVE_SYNTHESIS = {
    'signal_chain': ['oscillator', 'filter', 'amplifier', 'envelope'],
    
    'oscillator_types': {
        'sine': {
            'harmonics': 'fundamental_only',
            'character': 'pure, flute-like',
            'use_cases': ['bass', 'pads', 'fm_modulation']
        },
        'sawtooth': {
            'harmonics': 'all_harmonics_declining',
            'character': 'bright, buzzy, rich',
            'use_cases': ['leads', 'basses', 'brass']
        },
        'square': {
            'harmonics': 'odd_harmonics_only',
            'character': 'hollow, woody, clarinet-like',
            'use_cases': ['leads', 'retro_sounds', 'bass']
        },
        'triangle': {
            'harmonics': 'odd_harmonics_fast_decline',
            'character': 'mellow, flute-like',
            'use_cases': ['soft_leads', 'pads', 'bass']
        },
        'noise': {
            'harmonics': 'random_spectrum',
            'character': 'textural, percussive',
            'use_cases': ['percussion', 'wind_sounds', 'texture']
        }
    },
    
    'filter_types': {
        'lowpass': {
            'effect': 'removes_high_frequencies',
            'character': 'warm, dark, smooth',
            'resonance_effect': 'peak_at_cutoff'
        },
        'highpass': {
            'effect': 'removes_low_frequencies',
            'character': 'thin, bright, airy',
            'resonance_effect': 'peak_at_cutoff'
        },
        'bandpass': {
            'effect': 'passes_middle_frequencies',
            'character': 'nasal, telephone-like',
            'resonance_effect': 'narrow_peak'
        },
        'notch': {
            'effect': 'removes_middle_frequencies',
            'character': 'scooped, hollow',
            'resonance_effect': 'sharp_notch'
        }
    }
}
```

#### Subtractive Synth Implementation
```python
class SubtractiveSynthesizer:
    def __init__(self, sample_rate):
        self.sample_rate = sample_rate
        self.oscillator = Oscillator(sample_rate)
        self.filter = MoogLadderFilter(sample_rate)
        self.amplifier = Amplifier()
        self.envelope = ADSR_Envelope(sample_rate)
        
    def note_on(self, frequency, velocity):
        """Trigger note with given frequency and velocity"""
        self.oscillator.set_frequency(frequency)
        self.amplifier.set_velocity(velocity)
        self.envelope.note_on()
        
    def note_off(self):
        """Release note"""
        self.envelope.note_off()
        
    def process_sample(self):
        """Generate one audio sample"""
        # Generate oscillator output
        osc_output = self.oscillator.process()
        
        # Apply filter
        filtered = self.filter.process(osc_output)
        
        # Apply envelope and amplifier
        envelope_level = self.envelope.process()
        output = self.amplifier.process(filtered * envelope_level)
        
        return output

class MoogLadderFilter:
    def __init__(self, sample_rate):
        self.sample_rate = sample_rate
        self.cutoff = 1000  # Hz
        self.resonance = 0.0  # 0-1
        
        # Four one-pole filters
        self.stage1 = self.stage2 = self.stage3 = self.stage4 = 0.0
        self.feedback = 0.0
        
    def set_parameters(self, cutoff_hz, resonance):
        self.cutoff = cutoff_hz
        self.resonance = resonance
        
        # Calculate filter coefficient
        self.g = math.tan(math.pi * cutoff_hz / self.sample_rate)
        self.G = self.g / (1 + self.g)
        
    def process(self, input_sample):
        # Input with feedback
        input_with_fb = input_sample - self.feedback * self.resonance * 4
        
        # Four cascade one-pole filters
        self.stage1 = self.G * input_with_fb + (1 - self.G) * self.stage1
        self.stage2 = self.G * self.stage1 + (1 - self.G) * self.stage2
        self.stage3 = self.G * self.stage2 + (1 - self.G) * self.stage3
        self.stage4 = self.G * self.stage3 + (1 - self.G) * self.stage4
        
        # Update feedback
        self.feedback = self.stage4
        
        return self.stage4
```

### FM (Frequency Modulation) Synthesis

#### FM Theory and Implementation
```python
FM_SYNTHESIS = {
    'core_concept': 'modulate_frequency_of_carrier_with_modulator',
    'mathematical_formula': 'output = sin(2π * (fc + Im * sin(2π * fm * t)) * t)',
    
    'parameters': {
        'carrier_frequency': 'main_pitch_of_sound',
        'modulator_frequency': 'frequency_of_modulating_oscillator',
        'modulation_index': 'depth_of_frequency_modulation',
        'feedback': 'modulator_modulates_itself'
    },
    
    'harmonic_generation': {
        'simple_ratios': 'harmonic_sidebands',
        'complex_ratios': 'inharmonic_sidebands',
        'high_modulation_index': 'complex_timbres'
    }
}

class FM_Operator:
    def __init__(self, sample_rate):
        self.sample_rate = sample_rate
        self.frequency = 440.0
        self.phase = 0.0
        self.modulation_input = 0.0
        self.envelope = ADSR_Envelope(sample_rate)
        self.feedback = 0.0
        self.output_level = 1.0
        
    def set_frequency(self, freq):
        self.frequency = freq
        
    def process(self, fm_input=0.0):
        """Process FM operator with modulation input"""
        # Calculate instantaneous frequency
        instantaneous_freq = self.frequency + fm_input + self.feedback * self.previous_output
        
        # Generate phase
        self.phase += 2 * math.pi * instantaneous_freq / self.sample_rate
        if self.phase > 2 * math.pi:
            self.phase -= 2 * math.pi
            
        # Generate sine wave
        output = math.sin(self.phase) * self.envelope.process() * self.output_level
        
        # Store for feedback
        self.previous_output = output
        
        return output

class DX7_Algorithm:
    """Implementation of DX7-style FM algorithm"""
    def __init__(self, sample_rate, algorithm_number=1):
        self.operators = [FM_Operator(sample_rate) for _ in range(6)]
        self.algorithm = algorithm_number
        self.setup_algorithm_routing()
        
    def setup_algorithm_routing(self):
        """Set up operator routing based on algorithm"""
        # Algorithm 1: 6→5→4→3→2→1
        if self.algorithm == 1:
            self.routing = {
                'op6': [],           # Modulator (no input)
                'op5': ['op6'],      # Modulated by op6
                'op4': ['op5'],      # Modulated by op5
                'op3': ['op4'],      # Modulated by op4
                'op2': ['op3'],      # Modulated by op3
                'op1': ['op2']       # Carrier (modulated by op2)
            }
        # Add more algorithms as needed
        
    def process_sample(self):
        """Process all operators according to algorithm"""
        op_outputs = [0.0] * 6
        
        # Process in dependency order (6→5→4→3→2→1)
        for i in range(5, -1, -1):  # Process operators 6 to 1
            fm_input = 0.0
            
            # Sum modulation inputs
            for modulator_idx in self.routing.get(f'op{i+1}', []):
                mod_idx = int(modulator_idx[2:]) - 1  # Extract operator number
                fm_input += op_outputs[mod_idx]
            
            # Process operator
            op_outputs[i] = self.operators[i].process(fm_input)
        
        # Output is from carrier operator(s)
        return op_outputs[0]  # Operator 1 is typically the carrier
```

### Wavetable Synthesis

#### Wavetable Structure and Interpolation
```python
class WavetableSynthesizer:
    def __init__(self, sample_rate):
        self.sample_rate = sample_rate
        self.wavetables = {}  # Dictionary of wavetable collections
        self.current_table = 'basic'
        self.wave_position = 0.0  # Position in wavetable (0-1)
        self.frequency = 440.0
        self.phase = 0.0
        
    def load_wavetable(self, name, wavetable_data):
        """Load wavetable collection"""
        # wavetable_data should be list of single-cycle waveforms
        self.wavetables[name] = wavetable_data
        
    def set_wave_position(self, position):
        """Set position in wavetable (0.0 = first wave, 1.0 = last wave)"""
        self.wave_position = max(0.0, min(1.0, position))
        
    def process_sample(self):
        """Generate audio sample with wavetable interpolation"""
        wavetable = self.wavetables[self.current_table]
        num_waves = len(wavetable)
        
        # Calculate which waves to interpolate between
        wave_index_float = self.wave_position * (num_waves - 1)
        wave_index_int = int(wave_index_float)
        wave_blend = wave_index_float - wave_index_int
        
        # Get current and next wave
        current_wave = wavetable[wave_index_int]
        next_wave = wavetable[min(wave_index_int + 1, num_waves - 1)]
        
        # Calculate table lookup indices
        table_size = len(current_wave)
        table_index_float = (self.phase / (2 * math.pi)) * table_size
        table_index_int = int(table_index_float) % table_size
        table_blend = table_index_float - table_index_int
        
        # Bilinear interpolation
        # Interpolate current wave
        sample1_curr = current_wave[table_index_int]
        sample2_curr = current_wave[(table_index_int + 1) % table_size]
        interp_curr = sample1_curr + (sample2_curr - sample1_curr) * table_blend
        
        # Interpolate next wave
        sample1_next = next_wave[table_index_int]
        sample2_next = next_wave[(table_index_int + 1) % table_size]
        interp_next = sample1_next + (sample2_next - sample1_next) * table_blend
        
        # Final interpolation between waves
        output = interp_curr + (interp_next - interp_curr) * wave_blend
        
        # Update phase
        self.phase += 2 * math.pi * self.frequency / self.sample_rate
        if self.phase > 2 * math.pi:
            self.phase -= 2 * math.pi
            
        return output
```

---

## Mixing and Signal Flow

### Frequency Spectrum Management
```python
FREQUENCY_ALLOCATION = {
    'sub_bass': {
        'range': (20, 60),  # Hz
        'instruments': ['kick_drum_fundamental', '808_bass', 'synth_bass_sub'],
        'mixing_tips': ['mono', 'high_pass_other_elements', 'careful_eq']
    },
    'bass': {
        'range': (60, 250),
        'instruments': ['bass_guitar', 'kick_drum_thump', 'bass_synth'],
        'mixing_tips': ['controlled_dynamics', 'clear_fundamental', 'avoid_mud']
    },
    'low_midrange': {
        'range': (250, 500),
        'instruments': ['guitar_body', 'snare_body', 'vocal_chest', 'piano_low'],
        'mixing_tips': ['avoid_buildup', 'clarity', 'warmth_control']
    },
    'midrange': {
        'range': (500, 2000),
        'instruments': ['vocal_presence', 'guitar_mids', 'snare_crack', 'piano_mid'],
        'mixing_tips': ['vocal_clarity', 'definition', 'avoid_harshness']
    },
    'upper_midrange': {
        'range': (2000, 4000),
        'instruments': ['vocal_intelligibility', 'guitar_bite', 'brass', 'percussion'],
        'mixing_tips': ['speech_clarity', 'presence', 'can_be_harsh']
    },
    'presence': {
        'range': (4000, 8000),
        'instruments': ['vocal_sibilance', 'cymbal_crash', 'guitar_sparkle'],
        'mixing_tips': ['definition', 'clarity', 'de-essing_needed']
    },
    'brilliance': {
        'range': (8000, 20000),
        'instruments': ['cymbals', 'acoustic_guitar_sparkle', 'vocal_air'],
        'mixing_tips': ['sparkle', 'air', 'avoid_fatigue']
    }
}
```

### Gain Staging and Signal Flow
```python
class MixingConsole:
    def __init__(self):
        self.tracks = {}
        self.buses = {}
        self.master_bus = MasterBus()
        
    def add_track(self, name, track_type='audio'):
        """Add track to mixing console"""
        self.tracks[name] = Track(name, track_type)
        
    def route_track_to_bus(self, track_name, bus_name, send_level=0.0):
        """Route track to auxiliary bus"""
        if bus_name not in self.buses:
            self.buses[bus_name] = AuxiliaryBus(bus_name)
        
        self.tracks[track_name].add_send(bus_name, send_level)
        
    def process_mix(self, input_buffers):
        """Process entire mix"""
        # Process individual tracks
        track_outputs = {}
        for name, track in self.tracks.items():
            track_outputs[name] = track.process(input_buffers[name])
        
        # Process auxiliary buses
        bus_outputs = {}
        for name, bus in self.buses.items():
            bus_input = sum(track.get_send_output(name) for track in self.tracks.values())
            bus_outputs[name] = bus.process(bus_input)
        
        # Sum to master bus
        master_input = sum(track_outputs.values()) + sum(bus_outputs.values())
        return self.master_bus.process(master_input)

class Track:
    def __init__(self, name, track_type):
        self.name = name
        self.track_type = track_type
        self.gain = 1.0
        self.pan = 0.0  # -1 to 1
        self.mute = False
        self.solo = False
        self.effects_chain = []
        self.sends = {}
        
    def add_effect(self, effect):
        """Add effect to track's processing chain"""
        self.effects_chain.append(effect)
        
    def process(self, input_buffer):
        """Process track with effects chain"""
        if self.mute:
            return [0.0] * len(input_buffer)
        
        # Apply gain
        signal = [sample * self.gain for sample in input_buffer]
        
        # Process through effects chain
        for effect in self.effects_chain:
            signal = effect.process(signal)
        
        return signal
```

---

## Audio Analysis Techniques

### Spectral Analysis
```python
class SpectralAnalyzer:
    def __init__(self, sample_rate, fft_size=2048):
        self.sample_rate = sample_rate
        self.fft_size = fft_size
        self.hop_size = fft_size // 4
        self.window = self.create_window('hann')
        
    def create_window(self, window_type):
        """Create windowing function"""
        if window_type == 'hann':
            return [0.5 * (1 - math.cos(2 * math.pi * i / (self.fft_size - 1))) 
                   for i in range(self.fft_size)]
        elif window_type == 'hamming':
            return [0.54 - 0.46 * math.cos(2 * math.pi * i / (self.fft_size - 1))
                   for i in range(self.fft_size)]
        
    def analyze_spectrum(self, audio_buffer):
        """Perform FFT analysis on audio buffer"""
        import numpy as np
        
        # Apply window
        windowed = [audio_buffer[i] * self.window[i] for i in range(self.fft_size)]
        
        # Perform FFT
        spectrum = np.fft.fft(windowed)
        magnitude = np.abs(spectrum)
        phase = np.angle(spectrum)
        
        # Convert to dB
        magnitude_db = 20 * np.log10(magnitude + 1e-10)  # Avoid log(0)
        
        return {
            'magnitude': magnitude,
            'magnitude_db': magnitude_db,
            'phase': phase,
            'frequencies': np.fft.fftfreq(self.fft_size, 1/self.sample_rate)
        }
        
    def peak_detection(self, spectrum, threshold_db=-60):
        """Detect spectral peaks"""
        magnitude_db = spectrum['magnitude_db']
        frequencies = spectrum['frequencies']
        
        peaks = []
        for i in range(1, len(magnitude_db) - 1):
            if (magnitude_db[i] > magnitude_db[i-1] and 
                magnitude_db[i] > magnitude_db[i+1] and
                magnitude_db[i] > threshold_db):
                peaks.append({
                    'frequency': frequencies[i],
                    'magnitude_db': magnitude_db[i],
                    'bin': i
                })
        
        return peaks
```

### Onset Detection
```python
class OnsetDetector:
    def __init__(self, sample_rate, frame_size=1024):
        self.sample_rate = sample_rate
        self.frame_size = frame_size
        self.hop_size = frame_size // 4
        self.spectral_analyzer = SpectralAnalyzer(sample_rate, frame_size)
        
        # Previous frame for difference calculations
        self.prev_spectrum = None
        
    def spectral_flux(self, current_spectrum, previous_spectrum):
        """Calculate spectral flux between frames"""
        if previous_spectrum is None:
            return 0.0
            
        flux = 0.0
        for i in range(len(current_spectrum['magnitude'])):
            diff = current_spectrum['magnitude'][i] - previous_spectrum['magnitude'][i]
            if diff > 0:  # Only positive differences
                flux += diff
                
        return flux
    
    def detect_onsets(self, audio_buffer, threshold=0.1):
        """Detect onset positions in audio buffer"""
        onsets = []
        
        # Process in overlapping frames
        for i in range(0, len(audio_buffer) - self.frame_size, self.hop_size):
            frame = audio_buffer[i:i + self.frame_size]
            
            # Analyze spectrum
            spectrum = self.spectral_analyzer.analyze_spectrum(frame)
            
            # Calculate onset strength
            flux = self.spectral_flux(spectrum, self.prev_spectrum)
            
            # Check for onset
            if flux > threshold:
                onset_time = i / self.sample_rate
                onsets.append({
                    'time': onset_time,
                    'strength': flux,
                    'sample': i
                })
            
            # Store for next iteration
            self.prev_spectrum = spectrum
            
        return onsets
```

---

## Professional Audio Standards

### Loudness Standards and Metering
```python
LOUDNESS_STANDARDS = {
    'streaming_platforms': {
        'spotify': {'lufs': -14, 'peak_limit': -2, 'normalization': True},
        'apple_music': {'lufs': -16, 'peak_limit': -1, 'normalization': True},
        'youtube': {'lufs': -14, 'peak_limit': -1, 'normalization': True},
        'soundcloud': {'lufs': -14, 'peak_limit': -2, 'normalization': False},
        'tidal': {'lufs': -14, 'peak_limit': -1, 'normalization': True}
    },
    
    'broadcast_standards': {
        'ebu_r128': {'lufs': -23, 'peak_limit': -3, 'region': 'Europe'},
        'atsc_a85': {'lufs': -24, 'peak_limit': -3, 'region': 'USA'},
        'arib_tr_b32': {'lufs': -24, 'peak_limit': -3, 'region': 'Japan'}
    },
    
    'mastering_targets': {
        'dynamic_music': {'lufs': -16, 'peak_limit': -3, 'character': 'preserves_dynamics'},
        'competitive_loud': {'lufs': -8, 'peak_limit': -0.1, 'character': 'maximum_loudness'},
        'balanced_commercial': {'lufs': -12, 'peak_limit': -1, 'character': 'commercial_ready'}
    }
}
```

### Professional File Formats
```python
AUDIO_FILE_FORMATS = {
    'wav': {
        'compression': None,
        'bit_depths': [16, 24, 32],
        'sample_rates': [44100, 48000, 96000, 192000],
        'use_cases': ['professional_recording', 'mastering', 'archival'],
        'compatibility': 'universal'
    },
    'aiff': {
        'compression': None,
        'bit_depths': [16, 24, 32],
        'sample_rates': [44100, 48000, 96000, 192000],
        'use_cases': ['professional_recording', 'mac_compatibility'],
        'metadata_support': 'extensive'
    },
    'flac': {
        'compression': 'lossless',
        'bit_depths': [16, 24],
        'sample_rates': [44100, 48000, 96000, 192000],
        'use_cases': ['archival', 'high_quality_distribution'],
        'file_size_reduction': '30-60%'
    }
}
```

This comprehensive guide provides the technical foundation needed to build intelligent audio processing capabilities into the Ableton MCP system, enabling sophisticated manipulation and analysis of audio signals at the lowest level.

---

**Document Status:** Phase 1.2 Complete  
**Next Steps:** Complete Song Structure & Arrangement Intelligence document  
**Integration Ready:** ✅ Full DSP understanding for intelligent parameter control