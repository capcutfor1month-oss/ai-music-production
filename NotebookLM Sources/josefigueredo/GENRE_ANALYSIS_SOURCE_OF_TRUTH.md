# Genre Analysis & Classification Intelligence - Complete Source of Truth

## Table of Contents
1. [Genre Classification Framework](#genre-classification-framework)
2. [Electronic Music Genres](#electronic-music-genres)
3. [Rock & Alternative Analysis](#rock--alternative-analysis)
4. [Urban & Hip-Hop Genres](#urban--hip-hop-genres)
5. [Pop & Commercial Music](#pop--commercial-music)
6. [World & Regional Styles](#world--regional-styles)
7. [Hybrid & Emerging Genres](#hybrid--emerging-genres)
8. [Genre Detection Algorithms](#genre-detection-algorithms)
9. [Cultural Context Analysis](#cultural-context-analysis)
10. [Implementation Systems](#implementation-systems)

---

## Genre Classification Framework

### Core Musical Elements
```python
GENRE_ANALYSIS_PARAMETERS = {
    'rhythmic_elements': {
        'tempo': {'range': (60, 200), 'stability': 'consistent vs variable'},
        'time_signature': ['4/4', '3/4', '6/8', '7/8', '5/4', 'mixed'],
        'groove': ['straight', 'swing', 'shuffle', 'latin_clave', 'polyrhythmic'],
        'kick_pattern': ['four_on_floor', 'backbeat', 'breakbeat', 'half_time']
    },
    'harmonic_elements': {
        'key_center': ['major', 'minor', 'modal', 'atonal'],
        'chord_complexity': ['triads', 'seventh_chords', 'extensions', 'jazz_harmony'],
        'progression_patterns': ['I-V-vi-IV', 'ii-V-I', 'circle_of_fifths', 'modal'],
        'tonality': ['diatonic', 'chromatic', 'pentatonic', 'blues_scale']
    },
    'textural_elements': {
        'arrangement': ['minimal', 'dense', 'layered', 'sparse'],
        'instrumentation': 'genre_specific_instruments',
        'production_style': ['organic', 'programmed', 'hybrid'],
        'dynamics': ['compressed', 'dynamic', 'pumping', 'consistent']
    },
    'spectral_characteristics': {
        'frequency_emphasis': ['bass_heavy', 'mid_focused', 'bright'],
        'stereo_width': ['mono', 'wide', 'selective'],
        'saturation': ['clean', 'warm', 'distorted'],
        'reverb_character': ['dry', 'room', 'hall', 'plate', 'digital']
    }
}
```

### Genre Identification Matrix
```python
class GenreClassifier:
    """
    Multi-dimensional genre analysis system
    """
    
    def __init__(self):
        self.genre_signatures = self.load_genre_templates()
        self.feature_weights = {
            'tempo': 0.15,
            'rhythm_pattern': 0.20,
            'harmonic_content': 0.15,
            'instrumentation': 0.20,
            'production_style': 0.15,
            'cultural_markers': 0.15
        }
    
    def analyze_track(self, audio_file):
        """
        Comprehensive genre analysis
        """
        features = {
            'tempo': self.detect_tempo(audio_file),
            'rhythm': self.analyze_rhythm_pattern(audio_file),
            'harmony': self.extract_harmonic_features(audio_file),
            'timbre': self.analyze_spectral_content(audio_file),
            'structure': self.analyze_song_structure(audio_file),
            'production': self.analyze_production_markers(audio_file)
        }
        
        return self.classify_genre(features)
    
    def classify_genre(self, features):
        """
        Multi-class genre prediction with confidence
        """
        genre_scores = {}
        
        for genre, template in self.genre_signatures.items():
            score = 0
            for feature, weight in self.feature_weights.items():
                similarity = self.calculate_similarity(
                    features[feature], 
                    template[feature]
                )
                score += similarity * weight
            
            genre_scores[genre] = score
        
        # Sort by confidence
        sorted_genres = sorted(
            genre_scores.items(), 
            key=lambda x: x[1], 
            reverse=True
        )
        
        return {
            'primary_genre': sorted_genres[0][0],
            'confidence': sorted_genres[0][1],
            'secondary_genres': sorted_genres[1:3],
            'hybrid_indicators': self.detect_hybrid_elements(features)
        }
```

---

## Electronic Music Genres

### House Music Family
```python
HOUSE_GENRES = {
    'deep_house': {
        'tempo_range': (120, 125),
        'characteristics': {
            'kick': 'Four-on-floor, deep and punchy',
            'bass': 'Sub-heavy, often analog warmth',
            'hi_hats': 'Shuffled, syncopated patterns',
            'chords': 'Warm pads, jazz-influenced progressions',
            'vocals': 'Soulful, often sampled from classic tracks'
        },
        'production_markers': {
            'sidechain': 'Subtle, musical pumping',
            'reverb': 'Warm, spacious tails',
            'saturation': 'Analog-style warmth',
            'dynamics': 'Breathing, organic feel'
        },
        'mix_approach': {
            'low_end': 'Mono below 120Hz, sub-heavy',
            'midrange': 'Warm, not too aggressive',
            'highs': 'Smooth, not harsh',
            'stereo': 'Wide pads, centered rhythm section'
        }
    },
    'tech_house': {
        'tempo_range': (125, 130),
        'characteristics': {
            'kick': 'Tight, punchy, minimal decay',
            'percussion': 'Crisp, minimal, precise timing',
            'bass': 'Driving, repetitive, hypnotic',
            'elements': 'Stripped down, functional',
            'builds': 'Subtle filter automation'
        },
        'production_style': {
            'arrangement': 'Minimal, repetitive structure',
            'effects': 'Functional rather than decorative',
            'mixing': 'Clean, precise, club-focused',
            'mastering': 'Loud but dynamic'
        }
    },
    'progressive_house': {
        'tempo_range': (128, 132),
        'structure': {
            'intro': '32-64 bars gradual build',
            'breakdown': 'Emotional, melodic section',
            'build': 'Energy increasing over 32+ bars',
            'drop': 'Full arrangement return',
            'outro': 'Extended, DJ-friendly'
        },
        'melodic_content': {
            'leads': 'Emotional, soaring synthesizers',
            'arps': 'Complex, evolving patterns',
            'pads': 'Lush, wide, evolving textures',
            'progressions': 'Emotional, often minor'
        }
    }
}
```

### Techno Variations
```python
TECHNO_STYLES = {
    'minimal_techno': {
        'tempo_range': (125, 130),
        'philosophy': 'Less is more, hypnotic repetition',
        'elements': {
            'kick': 'Central, driving force',
            'percussion': 'Sparse, precise placement',
            'bass': 'Minimal, functional',
            'melody': 'Subtle, atmospheric'
        },
        'arrangement': {
            'intro_length': '64+ bars',
            'changes': 'Subtle, gradual evolution',
            'breakdown': 'Minimal or absent',
            'outro': 'Extended for DJ mixing'
        }
    },
    'hard_techno': {
        'tempo_range': (145, 160),
        'intensity': 'Aggressive, industrial',
        'sound_design': {
            'kick': 'Hard, distorted, aggressive',
            'bass': 'Grinding, distorted',
            'leads': 'Harsh, metallic textures',
            'atmosphere': 'Dark, industrial'
        },
        'production': {
            'compression': 'Heavy, pumping',
            'distortion': 'Prominent throughout',
            'dynamics': 'Relentless intensity'
        }
    },
    'detroit_techno': {
        'tempo_range': (130, 135),
        'historical_context': 'Original techno blueprint',
        'characteristics': {
            'funk_influence': 'Syncopated rhythms',
            'futurism': 'Space-age synthesizer sounds',
            'soul': 'Emotional depth despite minimalism',
            'innovation': 'Pioneering electronic techniques'
        }
    }
}
```

### Bass Music Evolution
```python
BASS_MUSIC_SPECTRUM = {
    'dubstep': {
        'classic_dubstep': {
            'tempo': 140,  # Half-time feel at 70
            'structure': 'Sparse, space for bass',
            'bass_design': 'LFO modulation, wobbles',
            'drums': 'Snare on 3, syncopated patterns'
        },
        'brostep': {
            'characteristics': 'Aggressive, maximalist',
            'drop_style': 'Heavy, face-melting bass',
            'production': 'Compressed, in-your-face'
        },
        'melodic_dubstep': {
            'focus': 'Emotional progression',
            'vocals': 'Often featured prominently',
            'arrangement': 'Traditional song structures'
        }
    },
    'drum_and_bass': {
        'tempo_range': (160, 180),
        'subgenres': {
            'liquid_dnb': {
                'character': 'Smooth, jazzy, soulful',
                'bass': 'Rolling, melodic',
                'atmosphere': 'Warm, organic'
            },
            'neurofunk': {
                'character': 'Complex, technical',
                'bass': 'Aggressive, processed',
                'production': 'Crisp, detailed'
            },
            'jump_up': {
                'character': 'Energetic, crowd-pleasing',
                'bass': 'Bouncy, catchy hooks',
                'structure': 'Simple, effective'
            }
        }
    },
    'future_bass': {
        'tempo_range': (130, 160),
        'signature_sounds': {
            'chords': 'Detuned, modulated supersaws',
            'bass': 'Sub-heavy with harmonic content',
            'vocals': 'Heavily processed, chopped',
            'drums': 'Trap-influenced patterns'
        },
        'production_techniques': {
            'sidechain': 'Prominent pumping effect',
            'stereo_width': 'Extremely wide mix',
            'saturation': 'Heavy processing on all elements'
        }
    }
}
```

---

## Rock & Alternative Analysis

### Rock Genre Spectrum
```python
ROCK_CLASSIFICATIONS = {
    'indie_rock': {
        'tempo_range': (110, 140),
        'instrumentation': {
            'guitars': 'Clean to mild overdrive, jangly tone',
            'bass': 'Melodic, often driving',
            'drums': 'Natural, not overly processed',
            'vocals': 'Intimate, conversational'
        },
        'production_style': {
            'approach': 'Lo-fi to polished',
            'dynamics': 'Natural variation preserved',
            'effects': 'Creative, atmospheric',
            'mix': 'Spacious, not claustrophobic'
        },
        'song_structures': {
            'verse_chorus': 'Traditional but creative',
            'bridges': 'Often instrumental',
            'outros': 'Fade-outs or natural endings'
        }
    },
    'progressive_rock': {
        'tempo_range': (100, 180),  # Highly variable
        'complexity_markers': {
            'time_signatures': 'Frequent changes, odd meters',
            'song_length': 'Extended compositions (8+ minutes)',
            'arrangements': 'Complex, multi-sectional',
            'virtuosity': 'Technical proficiency displayed'
        },
        'instrumentation': {
            'keyboards': 'Prominent, varied sounds',
            'guitars': 'Both rhythmic and lead roles',
            'bass': 'Often melodically active',
            'drums': 'Complex patterns, odd time'
        }
    },
    'metal_subgenres': {
        'thrash_metal': {
            'tempo_range': (120, 200),
            'characteristics': {
                'riffs': 'Fast, aggressive, palm-muted',
                'solos': 'Technical, rapid-fire',
                'vocals': 'Aggressive but melodic',
                'production': 'Tight, precise'
            }
        },
        'doom_metal': {
            'tempo_range': (60, 100),
            'characteristics': {
                'riffs': 'Heavy, slow, crushing',
                'tone': 'Massively distorted',
                'atmosphere': 'Dark, oppressive',
                'dynamics': 'Wide, dramatic'
            }
        },
        'black_metal': {
            'production_style': 'Raw, lo-fi aesthetic',
            'characteristics': {
                'vocals': 'Shrieked, atmospheric',
                'guitars': 'Tremolo picking, dissonant',
                'atmosphere': 'Cold, otherworldly'
            }
        }
    }
}
```

---

## Urban & Hip-Hop Genres

### Hip-Hop Evolution Map
```python
HIP_HOP_TIMELINE = {
    'old_school': {
        'period': '1970s-1980s',
        'tempo_range': (90, 110),
        'characteristics': {
            'breaks': 'Sampled funk/soul breaks',
            'vocals': 'Rhythmic speech, simple rhymes',
            'production': 'Drum machines, basic sampling',
            'culture': 'Block parties, DJ culture'
        }
    },
    'golden_age': {
        'period': '1987-1993',
        'innovations': {
            'sampling': 'Creative, complex layering',
            'lyricism': 'Socially conscious, complex',
            'production': 'Boom-bap aesthetic',
            'groups': 'Public Enemy, De La Soul, Tribe'
        }
    },
    'gangsta_rap': {
        'period': '1988-1997',
        'regional_styles': {
            'west_coast': {
                'tempo': (90, 100),
                'sound': 'G-funk, synthesizer heavy',
                'production': 'Dr. Dre, Parliament samples'
            },
            'east_coast': {
                'tempo': (95, 110),
                'sound': 'Harder, jazz samples',
                'production': 'Premier, Pete Rock'
            }
        }
    },
    'southern_rap': {
        'period': '1990s-present',
        'substyles': {
            'atlanta_trap': {
                'tempo_range': (130, 150),
                'characteristics': {
                    '808s': 'Heavy, tuned sub-bass',
                    'hi_hats': 'Rapid triplet patterns',
                    'snares': 'Crisp, often layered',
                    'atmosphere': 'Dark, minimal'
                }
            },
            'bounce': {
                'origin': 'New Orleans',
                'tempo': (95, 105),
                'call_response': 'Audience interaction',
                'rhythm': 'Syncopated, danceable'
            }
        }
    },
    'modern_trap': {
        'period': '2010s-present',
        'global_influence': {
            'latin_trap': 'Spanish language, reggaeton fusion',
            'uk_drill': 'Dark, aggressive, 138-142 BPM',
            'afro_trap': 'African rhythms, trap production'
        },
        'production_evolution': {
            'melodic_trap': 'Emotional, sung hooks',
            'experimental': 'Unconventional sounds, structures',
            'punk_rap': 'Aggressive, rock influences'
        }
    }
}
```

### R&B and Soul Classification
```python
RNB_EVOLUTION = {
    'classic_soul': {
        'period': '1950s-1970s',
        'characteristics': {
            'vocals': 'Powerful, emotional',
            'rhythm': 'Strong backbeat',
            'harmony': 'Gospel-influenced',
            'instrumentation': 'Horns, rhythm section'
        }
    },
    'contemporary_rnb': {
        'period': '1980s-present',
        'new_jack_swing': {
            'tempo_range': (110, 130),
            'production': 'Hip-hop beats, R&B vocals',
            'swing_feel': 'Syncopated, danceable'
        },
        'neo_soul': {
            'characteristics': {
                'organic': 'Live instrumentation',
                'progressive': 'Jazz harmony, complex',
                'conscious': 'Socially aware lyrics'
            }
        }
    },
    'alternative_rnb': {
        'period': '2010s-present',
        'characteristics': {
            'experimental': 'Unconventional structures',
            'atmospheric': 'Ambient, spacious production',
            'genre_blending': 'Electronic, indie influences',
            'minimalist': 'Sparse arrangements'
        },
        'artists': 'Frank Ocean, The Weeknd, FKA twigs'
    }
}
```

---

## Pop & Commercial Music

### Pop Music Formula Analysis
```python
POP_MUSIC_STANDARDS = {
    'structural_templates': {
        'verse_chorus_pop': {
            'structure': [
                'intro', 'verse1', 'prechorus', 'chorus', 
                'verse2', 'prechorus', 'chorus', 
                'bridge', 'chorus', 'outro'
            ],
            'section_lengths': {
                'intro': 8,
                'verse': 16,
                'prechorus': 8,
                'chorus': 16,
                'bridge': 8,
                'outro': 8
            }
        }
    },
    'chord_progression_analysis': {
        'most_common': {
            'vi_IV_I_V': '80% of pop songs use variations',
            'I_V_vi_IV': 'Axis progression, extremely popular',
            'I_vi_IV_V': '50s progression, still relevant'
        },
        'emotional_mapping': {
            'happy_major': ['I-IV-V-I', 'I-vi-IV-V'],
            'melancholy': ['vi-IV-I-V', 'i-VI-III-VII'],
            'tension': ['ii-V-I', 'V-vi (deceptive)']
        }
    },
    'melodic_patterns': {
        'hook_characteristics': {
            'repetition': 'Core phrase repeated 3-4 times',
            'range': 'Usually within one octave',
            'rhythm': 'Strong relationship to lyrics',
            'contour': 'Memorable shape, often ascending'
        },
        'vocal_production': {
            'lead_vocal': 'Centered, prominent, compressed',
            'harmonies': 'Wide, supporting, layer building',
            'ad_libs': 'Excitement, personality, wide panned',
            'doubles': 'Thickness, commercial polish'
        }
    }
}
```

### Commercial Production Standards
```python
COMMERCIAL_MIXING_SPECS = {
    'loudness_targets': {
        'spotify_optimized': -9,  # LUFS integrated
        'radio_ready': -8,        # LUFS for competitive loudness
        'streaming_safe': -14,     # Platform normalization target
        'true_peak': -1           # Maximum to avoid clipping
    },
    'frequency_balance': {
        'bass_region': {
            'range': (20, 250),
            'balance': 'Present but not overwhelming',
            'mono_point': 120  # Hz - everything below mono
        },
        'midrange': {
            'vocal_presence': (2000, 5000),
            'clarity_zone': (1000, 3000),
            'fullness': (250, 1000)
        },
        'high_frequency': {
            'air_band': (10000, 20000),
            'presence': (4000, 8000),
            'sibilance': (6000, 8000)
        }
    },
    'dynamic_processing': {
        'vocal_compression': {
            'ratio': (3, 6),
            'attack': (1, 5),    # ms
            'release': (50, 100), # ms
            'reduction': (3, 7)   # dB
        },
        'mix_bus_compression': {
            'ratio': (2, 3),
            'attack': (10, 30),
            'release': 'auto',
            'reduction': (1, 3)
        }
    }
}
```

---

## World & Regional Styles

### Latin Music Categories
```python
LATIN_GENRES = {
    'reggaeton': {
        'tempo_range': (80, 100),  # Often feels faster due to dembow
        'core_rhythm': {
            'dembow': 'Signature rhythm pattern from dancehall',
            'pattern': 'Boom ch-boom-chk boom-boom-chk',
            'origin': 'Jamaican dancehall, adapted for Latin music'
        },
        'production_style': {
            'bass': '808-style, tuned and sustained',
            'percussion': 'Crisp, punchy, prominent',
            'vocals': 'Rhythmic, often rapid-fire',
            'autotune': 'Common for melodic hooks'
        },
        'regional_variations': {
            'puerto_rican': 'Original style, raw, street',
            'colombian': 'Melodic, pop-influenced',
            'mexican': 'Norteño influences, banda elements'
        }
    },
    'salsa': {
        'tempo_range': (160, 220),
        'rhythmic_foundation': {
            'clave': 'Fundamental rhythm pattern',
            'montuno': 'Piano rhythm pattern',
            'tumbao': 'Bass rhythm pattern'
        },
        'instrumentation': {
            'rhythm_section': ['piano', 'bass', 'congas', 'timbales'],
            'brass': ['trumpet', 'trombone', 'saxophone'],
            'vocals': 'Lead singer, chorus (coro)'
        }
    },
    'bachata': {
        'tempo_range': (120, 150),
        'characteristics': {
            'guitar': 'Nylon string, arpeggiated patterns',
            'bongos': 'Traditional percussion',
            'bass': 'Walking bass lines',
            'vocals': 'Romantic, emotional lyrics'
        }
    }
}
```

### African Music Integration
```python
AFRICAN_GENRES = {
    'afrobeats': {
        'tempo_range': (100, 128),
        'rhythmic_foundation': {
            'polyrhythm': 'Multiple interlocking rhythms',
            'call_response': 'Traditional vocal patterns',
            'clave_variations': 'African interpretations'
        },
        'modern_production': {
            'electronic_fusion': 'Traditional rhythms + modern production',
            'global_influence': 'Hip-hop, pop, R&B elements',
            'instrumentation': 'Mix of traditional and modern'
        },
        'regional_styles': {
            'nigerian': {
                'artists': 'Burna Boy, Wizkid, Davido',
                'characteristics': 'Heavy percussion, melodic'
            },
            'ghanaian': {
                'influences': 'Highlife, hip-hop fusion',
                'characteristics': 'Guitar-driven, melodic'
            }
        }
    },
    'amapiano': {
        'origin': 'South Africa',
        'tempo_range': (110, 120),
        'characteristics': {
            'piano': 'Jazz-influenced chord progressions',
            'bass': 'Deep, pulsing sub-bass',
            'percussion': 'Minimal, spacious',
            'vocals': 'Often sampled, chopped'
        },
        'production_style': {
            'mix_approach': 'Wide, spacious',
            'dynamics': 'Breathing, organic',
            'global_influence': 'Spreading to house music scene'
        }
    }
}
```

### Asian Music Modernization
```python
ASIAN_MODERN_GENRES = {
    'k_pop': {
        'production_characteristics': {
            'maximalist': 'Dense arrangements, multiple hooks',
            'genre_fusion': 'Pop, hip-hop, R&B, EDM elements',
            'structure': 'Non-traditional, dynamic changes',
            'vocals': 'Highly produced, layered harmonies'
        },
        'mixing_approach': {
            'loudness': 'Competitive commercial levels',
            'clarity': 'Every element audible',
            'punch': 'Aggressive, in-your-face',
            'space': 'Wide stereo image'
        }
    },
    'j_pop': {
        'characteristics': {
            'melodic': 'Strong emphasis on melody',
            'quirky': 'Unique, creative elements',
            'polished': 'High production values',
            'accessible': 'Catchy, mainstream appeal'
        }
    },
    'cantopop': {
        'linguistic': 'Cantonese language',
        'style': 'Ballad-heavy, emotional',
        'production': 'Clean, polished'
    }
}
```

---

## Hybrid & Emerging Genres

### Genre Fusion Mapping
```python
HYBRID_GENRES_2024 = {
    'future_funk': {
        'components': ['disco', 'funk', 'vaporwave', 'house'],
        'characteristics': {
            'sampling': 'Heavy use of disco/funk samples',
            'processing': 'Side-chain compression, filtering',
            'tempo': 'Around 110-120 BPM',
            'aesthetic': 'Nostalgic but futuristic'
        }
    },
    'trap_metal': {
        'components': ['trap', 'hardcore', 'industrial'],
        'characteristics': {
            'aggression': 'Extreme, confrontational',
            'production': 'Distorted, compressed',
            'tempo_switches': 'Dramatic tempo changes',
            'vocals': 'Screamed, aggressive'
        }
    },
    'lo_fi_house': {
        'components': ['house', 'lo-fi hip-hop', 'ambient'],
        'characteristics': {
            'fidelity': 'Deliberately degraded',
            'tempo': '115-125 BPM',
            'atmosphere': 'Relaxed, nostalgic',
            'production': 'Warm, analog-style'
        }
    },
    'afro_house': {
        'components': ['house', 'afrobeats', 'tribal'],
        'tempo_range': (118, 125),
        'characteristics': {
            'percussion': 'Traditional African rhythms',
            'bass': 'Deep house foundations',
            'vocals': 'African languages, chanting',
            'atmosphere': 'Spiritual, communal'
        }
    }
}
```

### Emerging Microgenres
```python
MICROGENRES_2024 = {
    'phonk': {
        'origin': 'Memphis rap + trap',
        'characteristics': {
            'vocals': 'Pitched down, aggressive',
            'samples': '90s Memphis rap',
            'drums': 'Trap patterns, heavy 808s',
            'atmosphere': 'Dark, underground'
        },
        'subgenres': {
            'drift_phonk': 'High energy, car culture',
            'cowbell_phonk': 'Prominent cowbell usage',
            'space_phonk': 'Ambient, atmospheric'
        }
    },
    'hyperpop': {
        'characteristics': {
            'maximalism': 'Extremely dense arrangements',
            'auto_tune': 'Heavy, creative usage',
            'tempo': 'Often 140+ BPM',
            'genre_mixing': 'Pop, punk, electronic, experimental'
        },
        'production_techniques': {
            'distortion': 'Heavy on all elements',
            'compression': 'Extreme, pumping',
            'pitch_shifting': 'Dramatic vocal processing'
        }
    },
    'vaporwave_variants': {
        'mallsoft': {
            'atmosphere': 'Shopping mall ambience',
            'tempo': 'Slow, dreamy',
            'samples': '80s/90s corporate music'
        },
        'hardvapour': {
            'tempo': 'Fast, aggressive',
            'aesthetic': 'Dark, industrial vaporwave'
        }
    }
}
```

---

## Genre Detection Algorithms

### Machine Learning Approach
```python
class AdvancedGenreDetector:
    """
    Multi-modal genre classification system
    """
    
    def __init__(self):
        self.feature_extractors = {
            'spectral': SpectralFeatureExtractor(),
            'rhythmic': RhythmicFeatureExtractor(),
            'harmonic': HarmonicFeatureExtractor(),
            'timbral': TimbralFeatureExtractor(),
            'structural': StructuralFeatureExtractor()
        }
        
        self.models = {
            'cnn': self.load_cnn_model(),
            'transformer': self.load_transformer_model(),
            'ensemble': self.load_ensemble_model()
        }
    
    def extract_features(self, audio):
        """
        Comprehensive feature extraction
        """
        features = {}
        
        # Spectral features
        features['mfcc'] = librosa.feature.mfcc(audio, n_mfcc=13)
        features['spectral_centroid'] = librosa.feature.spectral_centroid(audio)
        features['spectral_rolloff'] = librosa.feature.spectral_rolloff(audio)
        features['zero_crossing_rate'] = librosa.feature.zero_crossing_rate(audio)
        
        # Rhythmic features
        features['tempo'], features['beats'] = librosa.beat.beat_track(audio)
        features['onset_strength'] = librosa.onset.onset_strength(audio)
        
        # Harmonic features
        features['chroma'] = librosa.feature.chroma_stft(audio)
        features['tonnetz'] = librosa.feature.tonnetz(audio)
        
        # Timbral features
        features['zcr_variance'] = np.var(features['zero_crossing_rate'])
        features['spectral_contrast'] = librosa.feature.spectral_contrast(audio)
        
        return features
    
    def classify_with_confidence(self, audio):
        """
        Multi-model genre classification
        """
        features = self.extract_features(audio)
        
        # CNN prediction (spectrograms)
        spectrogram = librosa.stft(audio)
        cnn_pred = self.models['cnn'].predict(spectrogram)
        
        # Transformer prediction (sequence features)
        sequence_features = self.prepare_sequence_features(features)
        transformer_pred = self.models['transformer'].predict(sequence_features)
        
        # Ensemble prediction
        ensemble_pred = self.models['ensemble'].predict(features)
        
        # Weighted combination
        final_prediction = self.combine_predictions([
            cnn_pred,
            transformer_pred,
            ensemble_pred
        ])
        
        return {
            'primary_genre': final_prediction['genre'],
            'confidence': final_prediction['confidence'],
            'subgenre': final_prediction['subgenre'],
            'hybrid_elements': self.detect_hybrid_elements(features),
            'cultural_markers': self.detect_cultural_markers(features)
        }
```

### Audio Fingerprinting Implementation
```python
class AudioFingerprinting:
    """
    Perceptual hashing for genre identification
    """
    
    def __init__(self):
        self.peak_detector = PeakDetector()
        self.hash_generator = HashGenerator()
    
    def generate_fingerprint(self, audio, window_size=2048):
        """
        Create audio fingerprint for genre matching
        """
        # Convert to spectrogram
        spectrogram = librosa.stft(audio, n_fft=window_size)
        magnitude = np.abs(spectrogram)
        
        # Detect peaks
        peaks = self.peak_detector.find_peaks(magnitude)
        
        # Generate hash from peak patterns
        fingerprint = self.hash_generator.create_hash(peaks)
        
        return fingerprint
    
    def match_genre_database(self, fingerprint):
        """
        Match against known genre fingerprints
        """
        matches = []
        
        for genre, reference_prints in self.genre_database.items():
            for ref_print in reference_prints:
                similarity = self.calculate_similarity(fingerprint, ref_print)
                if similarity > 0.7:  # Threshold for match
                    matches.append({
                        'genre': genre,
                        'similarity': similarity
                    })
        
        return sorted(matches, key=lambda x: x['similarity'], reverse=True)
```

---

## Cultural Context Analysis

### Regional Influence Mapping
```python
CULTURAL_ANALYSIS_FRAMEWORK = {
    'linguistic_markers': {
        'language_detection': {
            'english': 'Global pop, hip-hop, rock',
            'spanish': 'Latin genres, reggaeton',
            'portuguese': 'Brazilian music',
            'yoruba_igbo': 'Afrobeats indicators',
            'korean_japanese': 'K-pop, J-pop markers'
        },
        'accent_patterns': {
            'american_english': 'Hip-hop, pop, rock',
            'british_english': 'UK genres, grime',
            'caribbean_english': 'Dancehall, reggae'
        }
    },
    'instrumental_cultural_markers': {
        'traditional_instruments': {
            'didgeridoo': 'Australian indigenous',
            'kora': 'West African',
            'shamisen': 'Japanese traditional',
            'charango': 'Andean music',
            'tabla': 'Indian classical'
        },
        'modern_adaptations': {
            'electronic_sitar': 'World fusion',
            'synthesized_gamelan': 'Electronic world music',
            'sampled_traditional': 'Cultural fusion genres'
        }
    },
    'rhythmic_cultural_signatures': {
        'african_polyrhythms': 'Complex interlocking patterns',
        'latin_clave': '3-2 or 2-3 rhythmic foundation',
        'middle_eastern_modes': 'Makam-based scales',
        'indian_ragas': 'Specific melodic frameworks'
    }
}
```

### Genre Evolution Tracking
```python
class GenreEvolutionTracker:
    """
    Track how genres change over time and geography
    """
    
    def __init__(self):
        self.historical_database = self.load_historical_data()
        self.regional_variations = self.load_regional_data()
        self.fusion_patterns = self.load_fusion_data()
    
    def analyze_evolution(self, genre, time_period):
        """
        Track genre changes over time
        """
        evolution = {
            'tempo_changes': self.analyze_tempo_evolution(genre, time_period),
            'instrumentation_shifts': self.analyze_instrument_changes(genre, time_period),
            'production_evolution': self.analyze_production_changes(genre, time_period),
            'cultural_spread': self.analyze_geographic_spread(genre, time_period)
        }
        
        return evolution
    
    def predict_future_trends(self, current_data):
        """
        Predict genre evolution based on current trends
        """
        trends = {
            'fusion_probability': self.calculate_fusion_likelihood(),
            'regional_adaptation': self.predict_regional_changes(),
            'technology_influence': self.predict_tech_impact(),
            'cultural_factors': self.analyze_cultural_drivers()
        }
        
        return trends
```

---

## Implementation Systems

### Real-time Genre Analysis
```python
class RealtimeGenreAnalyzer:
    """
    Live genre detection for DAW integration
    """
    
    def __init__(self, sample_rate=44100, buffer_size=2048):
        self.sample_rate = sample_rate
        self.buffer_size = buffer_size
        self.feature_buffer = CircularBuffer(size=100)
        self.genre_classifier = AdvancedGenreDetector()
    
    def process_audio_buffer(self, audio_buffer):
        """
        Process incoming audio for real-time genre detection
        """
        # Extract features from current buffer
        features = self.extract_realtime_features(audio_buffer)
        
        # Add to rolling buffer
        self.feature_buffer.add(features)
        
        # Check if we have enough data for classification
        if self.feature_buffer.is_full():
            # Get genre prediction
            prediction = self.genre_classifier.classify(
                self.feature_buffer.get_combined_features()
            )
            
            return {
                'genre': prediction['primary_genre'],
                'confidence': prediction['confidence'],
                'timestamp': time.time(),
                'recommended_settings': self.get_genre_recommendations(
                    prediction['primary_genre']
                )
            }
        
        return None
    
    def get_genre_recommendations(self, detected_genre):
        """
        Provide mixing/production recommendations based on detected genre
        """
        recommendations = GENRE_MIXING_TEMPLATES.get(detected_genre, {})
        
        return {
            'eq_suggestions': recommendations.get('eq'),
            'compression_settings': recommendations.get('compression'),
            'effects_chain': recommendations.get('effects'),
            'arrangement_tips': recommendations.get('arrangement')
        }
```

### Genre-Aware Mixing Assistant
```python
GENRE_MIXING_TEMPLATES = {
    'house': {
        'eq': {
            'kick': {'boost': '60-80 Hz', 'cut': '200-400 Hz'},
            'bass': {'boost': '80-120 Hz', 'cut': '500 Hz'},
            'hi_hats': {'boost': '8-12 kHz', 'hpf': '500 Hz'}
        },
        'compression': {
            'kick': {'ratio': 4, 'attack': 10, 'release': 100},
            'bass': {'ratio': 6, 'attack': 30, 'release': 150},
            'mix_bus': {'ratio': 2, 'attack': 30, 'release': 'auto'}
        },
        'effects': {
            'reverb': 'Plate reverb on percussion',
            'delay': '1/8 note delay on vocals',
            'sidechain': 'Bass and pads to kick'
        }
    },
    'trap': {
        'eq': {
            '808': {'boost': '40-60 Hz', 'tune': 'to_song_key'},
            'hi_hats': {'boost': '10-15 kHz', 'cut': '500-1000 Hz'},
            'snare': {'boost': '200 Hz', 'boost': '5-8 kHz'}
        },
        'compression': {
            '808': {'ratio': 8, 'attack': 1, 'release': 200},
            'vocals': {'ratio': 6, 'attack': 5, 'release': 50}
        },
        'effects': {
            'autotune': 'Retune speed 0-20',
            'delay': '1/8 and 1/4 note throws',
            'reverb': 'Short room on snare'
        }
    }
}
```

---

## Quality Assurance & Validation

### Genre Classification Accuracy Metrics
```python
VALIDATION_FRAMEWORK = {
    'accuracy_targets': {
        'primary_genre': 0.85,     # 85% accuracy for main genre
        'subgenre': 0.70,          # 70% accuracy for subgenre
        'hybrid_detection': 0.60,  # 60% for hybrid elements
        'cultural_markers': 0.75   # 75% for cultural identification
    },
    'test_datasets': {
        'commercial_releases': 'Known genre labels',
        'independent_music': 'Diverse, emerging genres',
        'historical_catalog': 'Genre evolution tracking',
        'world_music': 'Cultural diversity testing'
    },
    'validation_methods': {
        'human_expert': 'Music professional validation',
        'crowd_sourced': 'Multiple listener opinions',
        'cross_reference': 'Multiple database comparison',
        'cultural_expert': 'Regional music expert validation'
    }
}
```

---

**Document Version:** 2.0  
**Last Updated:** February 2025  
**Application:** Ableton MCP Phase 2 - Intelligence Layer  
**Next Document:** INSTRUMENT_TECHNIQUES_SOURCE_OF_TRUTH.md