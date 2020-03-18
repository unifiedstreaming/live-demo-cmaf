# simple cmaf ingest with ffmpeg

audio (aac) and video ingest (avc) 
CMAF support via mov muxer in ffmpeg

# To Be Done

- bit-rate signalling for audio tracks 
- ism offset / timestamp offset 
- multiple bit-rates (due to creating the same init segment/avc config for different tracks)
- CMAF subtitles (not supported in ffmpeg)

# a better/fuller demo can be found: 
https://github.com/unifiedstreaming/cmaf-ingest-demo 
- multiple bit-rates in AS 
- subtitles 
- timed metadata 
- no ffmpeg
