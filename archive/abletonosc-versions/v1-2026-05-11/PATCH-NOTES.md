# AbletonOSC Patch Notes — v1 (2026-05-11)

Patched from base AbletonOSC repo. Applied to:
`/Volumes/T7 Shield/Users/Aditya/Music/Ableton/User Library/Remote Scripts/AbletonOSC/`

## Changes in abletonosc/device.py
- Added `"is_active"` to `properties_rw` → enables `/live/device/get/is_active` and `/live/device/set/is_active`
- Added `/live/device/get/parameter/display_value` handler (alias for value_string)
- Added `/live/device/get/parameter/min` and `/live/device/get/parameter/max` handlers
- Added `/live/device/load` handler — browser search across audio_effects/instruments/midi_effects/plugins
- Added `/live/device/delete` handler — `track.delete_device(device_id)`

## Changes in abletonosc/song.py
- Added `/live/master_track/get/volume` and `/live/master_track/set/volume`
- Added `/live/master_track/get/panning` and `/live/master_track/set/panning`
- Added `/live/return_track/get|set/volume`, `panning`, `name`, `mute`
- Added `/live/song/get/num_return_tracks`
