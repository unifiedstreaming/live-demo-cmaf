#!/usr/bin/python3
"""
Entrypoint to run ffmpeg
"""
import json
import logging
import os
import subprocess
from collections.abc import Iterable
from datetime import datetime
from fractions import Fraction


logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
formatter = logging.Formatter(
    "%(asctime)s - %(name)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)


def flatten(items):
    """Yield items from any nested iterable, use to flatten command"""
    for x in items:
        if isinstance(x, Iterable) and not isinstance(x, (str, bytes)):
            yield from flatten(x)
        else:
            yield x


# fixed options
FFMPEG = ["ffmpeg"]
MOVFLAGS = "frag_every_frame+empty_moov+separate_moof+default_base_moof"
ALL_TRACK_OPTS = [
    "-fflags", "genpts",
    "-write_prft", "pts",
    "-movflags", MOVFLAGS,
    "-f", "mp4",
    ]

# env options
if "PUB_POINT_URI" in os.environ:
    pub_point_uri = os.environ["PUB_POINT_URI"]
else:
    logger.critical("must set PUB_POINT_URI")
    exit(1)

hostname = os.environ["HOSTNAME"] if "HOSTNAME" in os.environ else "ffmpeg"
frame_rate = os.environ["FRAME_RATE"] if "FRAME_RATE" in os.environ else "25"
gop_length = os.environ["GOP_LENGTH"] if "GOP_LENGTH" in os.environ else "24"

logo_overlay = os.environ["LOGO_OVERLAY"] if "LOGO_OVERLAY" in os.environ else "https://raw.githubusercontent.com/unifiedstreaming/live-demo/master/ffmpeg/usp_logo_white.png"
logo_filter = ""
if logo_overlay:
    logo_overlay = ["-i", logo_overlay]
    logo_filter = ";[v][1]overlay=eval=init:x=15:y=15[v]"

# defaults
DEFAULT_TRACKS = {
    "video": [
        {
            "width": 1280,
            "height": 720,
            "bitrate": "700k",
            "codec": "libx264",
            "framerate": frame_rate,
            "gop": gop_length,
            "timescale": 10000000
        }
    ],
    "audio": [
        {
            "samplerate": 48000,
            "bitrate": "64k",
            "codec": "aac",
            "language": "eng",
            "timescale": 48000
        }
    ]
}

# handle tracks
tracks = json.loads(os.environ["TRACKS"]) if "TRACKS" in os.environ else DEFAULT_TRACKS

# verify tracks make sense
# if multiple videos, do their frame rates & gops line up
if len(tracks["video"]) > 1:
    if len(set([Fraction(x["framerate"])/Fraction(x["gop"]) for x in tracks["video"]])) != 1:
        logger.critical("mismatched framerates/gop lengths")
        exit(1)
    if len(set([x["timescale"] for x in tracks["video"]])) != 1:
        logger.critical("mismatched video timescales not supported")
        exit(1)

# audio check sample rate and timescales
if len(tracks["audio"]) > 1:
    if len(set([x["samplerate"] for x in tracks["audio"]])) != 1:
        logger.critical("mismatched audio sample rates not supported")
        exit(1)
    if len(set([x["timescale"] for x in tracks["audio"]])) != 1:
        logger.critical("mismatched audio timescales not supported")
        exit(1)

# use highest framerate, resolution, etc for source and filters
max_framerate = max([Fraction(x["framerate"]) for x in tracks["video"]])
max_width = max([x["width"] for x in tracks["video"]])
max_height = max([x["height"] for x in tracks["video"]])

# Timing stuff
# floor to gop length based offset from epoch
gop = Fraction(Fraction(tracks["video"][0]["gop"]), Fraction(tracks["video"][0]["framerate"]))
now = Fraction(
        int(Fraction(Fraction(datetime.now().timestamp()), gop)),
        1/gop)

now_seconds = int(now)
now_micro = int(now % 1 * 1000000)

audio_delay = int((1000000 - now_micro)/1000)

video_offset = int(tracks["video"][0]["timescale"] * now)
audio_offset = int(tracks["audio"][0]["timescale"] * now)

now_mod_days = Fraction(int(now * 1000000) % 86400000000, 1000000)

max_framerate_int = int(max_framerate)
now_timecode = (datetime.utcfromtimestamp(float(now)).strftime("%H\:%M\:%S"))
now_milliseconds = int((datetime.utcfromtimestamp(float(now)).strftime("%f"))[:-3])
now_frames = int(now_milliseconds / (1000 / max_framerate_int))

logger.debug(f"max_framerate_int {max_framerate_int}")
logger.debug(f"now_timecode {now_timecode}")
logger.debug(f"now_milliseconds {now_milliseconds}")
logger.debug(f"now_frames {now_frames}")
logger.debug(f"now {now}")
logger.debug(f"float(now) {float(now)}")
logger.debug(f"now_seconds {now_seconds}")
logger.debug(f"now_micro {now_micro}")
logger.debug(f"audio_delay {audio_delay}")
logger.debug(f"video_offset {video_offset}")
logger.debug(f"audio_offset {audio_offset}")
logger.debug(f"now_mod_days {now_mod_days}")
logger.debug(f"float(now_mod_days) {float(now_mod_days)}")

# build the stupid command

# input smptebars
smptebars = [
    "-f", "lavfi",
    "-i", f"smptehdbars=size={max_width}x{max_height}:rate={max_framerate}"
]

# build the filter
filter_complex = f"""
[0]drawbox=
y=25: x=iw/2-iw/7: c=0x00000000@1: w=iw/3.5: h=36: t=fill,
drawtext=timecode_rate={max_framerate_int}: timecode='{now_timecode}\\:{now_frames}'" : tc24hmax=1: fontsize=32: x=(w-tw)/2+tw/2: y=30: fontcolor=white,
drawtext=text='%{{pts\:gmtime\:{now_seconds}\:%Y-%m-%d}}\ ': fontsize=32: x=(w-tw)/2-tw/2: y=30: fontcolor=white,
drawtext=
    text='Live Media Ingest (CMAF)':
    fontsize=32:
    x=(w-text_w)/2:
    y=75:
    fontcolor=white,
drawtext=
    text='Live Media Ingest (CMAF)':
    fontsize=32:
    x=(w-text_w)/2:
    y=75:
    fontsize=32:
    fontcolor=white,
drawtext=
    fontcolor=white:
    fontsize=20:
    text='Dual Encoder Sync - Active ContainerID {hostname}':
    x=(w-text_w)/2:
    y=125
    [v];
sine=frequency=1:beep_factor=480:sample_rate=48000,
atempo=1,
adelay={audio_delay},
highpass=40,
asplit=2[a][a_waves];
[a_waves]showwaves=
    mode=p2p:
    colors=white:
    size=1280x100:
    scale=lin:
    rate={max_framerate}
[waves];
color=size={max_width}x100:color=black[blackbg];
[blackbg][waves]overlay[waves2];
[v][waves2]overlay=y=620[v]
{logo_filter}
;[v]split={len(tracks["video"])}{"".join(["[v"+str(x)+"]" for x in range(1, len(tracks["video"])+1)])};
[a]asplit={len(tracks["audio"])}{"".join(["[a"+str(x)+"]" for x in range(1, len(tracks["audio"])+1)])}
"""

command = [
    FFMPEG,
    "-nostats",
    "-re",
    smptebars,
    logo_overlay,
    "-filter_complex", filter_complex
]

# all the various outputs
count = 0
for video in tracks["video"]:
    count += 1
    command.append([
        "-map", f"[v{count}]",
        "-s", f"{video['width']}x{video['height']}",
        "-c:v", "libx264",
        "-b:v", video["bitrate"],
        "-profile:v", "main",
        "-preset", "ultrafast",
        "-tune", "zerolatency",
        "-g", str(video["gop"]),
        "-r", str(video["framerate"]),
        "-ism_offset", str(video_offset),
        "-video_track_timescale", str(video["timescale"]),
        ALL_TRACK_OPTS,
        f"{pub_point_uri}/Streams(video-{video['width']}x{video['height']}-{video['bitrate']}.cmfv)"
    ])

count = 0
for audio in tracks["audio"]:
    count += 1
    command.append([
        "-map", f"[a{count}]",
        "-c:a", "aac",
        "-b:a", str(audio["bitrate"]),
        "-ar", str(audio["samplerate"]),
        "-metadata:s:a:0", f"language={audio['language']}",
        "-ism_offset", str(audio_offset),
        "-audio_track_timescale", str(audio["timescale"]),
        ALL_TRACK_OPTS,
        f"{pub_point_uri}/Streams(audio-{audio['language']}-{audio['bitrate']}.cmfa)"
    ])

logger.info(f"ffmpeg command: {list(flatten(command))}")

subprocess.run(list(flatten(command)))
