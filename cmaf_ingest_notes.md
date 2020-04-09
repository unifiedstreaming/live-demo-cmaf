# Overview

CMAF Live reference streams with ffmpeg ustilising 'DASH-IF Live Media Ingest
Protocol’ Interface 1. 

- Video Track 1 - 1920x1080 1000k AVC 48GOP@25FPS
- Video Track 2 - 1280x720 500k AVC 48GOP@25FPS
- Audio Track 1 - 64kbs 48kHz AAC-LC - Dutch language 
- Audio Track 2 - 128kbs 48kHz AAC-LC - English language

# Known issues
- Lack of bit-rate signalling for audio tracks 
- CMAF subtitles (not supported in ffmpeg)
- Timed Metadata (unable to generate dynamically/requires external tooling)

# To do
- Multi framerate (add 50FPS)
- Enable prft in ffmpeg
- Optimise Encoding profiles/quality
- Optimise Origin configuration
- Add aditional test to video to differentiate between MSS/CMAF Reference streams
- Test Interface 2 DASH ingest with apache rewrite rules

# Demo Stream
http://dai-interop.unified-streaming.com:8081/test/test.isml/.mpd
