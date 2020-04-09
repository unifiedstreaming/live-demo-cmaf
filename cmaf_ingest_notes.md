# simple cmaf ingest with ffmpeg

2x audio (aac) and 2x video ingest (avc) 
CMAF support via mov muxer in ffmpeg

# To Be Done
- bit-rate signalling for audio tracks 
- CMAF subtitles (not supported in ffmpeg)

# a better/fuller demo can be found: 
https://github.com/unifiedstreaming/cmaf-ingest-demo 
- multiple bit-rates in AS 
- subtitles 
- timed metadata 
- no ffmpeg

# example test stream 
an example test stream is made temporarily available deploying this setup
http://ec2-54-93-96-123.eu-central-1.compute.amazonaws.com/test/test.isml/.mpd
