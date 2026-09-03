#!/usr/bin/env bash
# 화이트보드 무음 MP4 3막 → 카메라 무빙(켄번즈) → 이어붙이기 → 음원 먹싱
#
# 이 도구에는 카메라가 없다. 렌더는 고정 프레임으로 나오므로 여기서 얹는다.
#
# 주의 1) 렌더 출력이 2560x1420 (비율 1.803) 이라 16:9(1.778)가 아니다.
#         그대로 1920x1080 으로 내보내면 가로가 1.4% 눌리므로 먼저 16:9 로 자른다.
# 주의 2) zoompan 의 zoom 은 1.0 미만이면 안 된다. max() 로 막는다.
# 원본 2524px, 출력 1920px → 1.31배까지는 확대해도 화질 손실이 없다.
set -euo pipefail
cd "$(dirname "$0")"

SONG="${1:?음원 mp3 경로를 인자로 주세요}"
FPS=30; OUT_W=1920; OUT_H=1080
CROP="crop=2524:1420:18:0"        # 2560x1420 → 16:9

N1=1020; N2=930; N3=683           # 실측 프레임 수

kb () {  # kb <입력> <출력> <z식> <x식> <y식>
  ffmpeg -v error -y -i "$1" \
    -vf "${CROP},zoompan=z='$3':x='$4':y='$5':d=1:s=${OUT_W}x${OUT_H}:fps=${FPS},format=yuv420p" \
    -c:v libx264 -preset medium -crf 18 -an "$2"
}

echo "[1/5] 1막 · 천천히 줌인 1.00→1.12, 시선 살짝 위"
kb scene-01-first-step-whiteboard.mp4 _cam-01.mp4 \
   "max(1.0,1.0+0.12*on/$((N1-1)))" "(iw-iw/zoom)/2" "(ih-ih/zoom)*0.42"

echo "[2/5] 2막 · 좌→우 슬로우 팬 + 미세 줌인 1.05→1.15"
kb scene-02-through-the-rain-whiteboard.mp4 _cam-02.mp4 \
   "max(1.0,1.05+0.10*on/$((N2-1)))" "(iw-iw/zoom)*(on/$((N2-1)))" "(ih-ih/zoom)/2"

echo "[3/5] 3막 · 풀백 1.18→1.00, 전체가 드러나며 마무리"
kb scene-03-shine-as-one-whiteboard.mp4 _cam-03.mp4 \
   "max(1.0,1.18-0.18*on/$((N3-1)))" "(iw-iw/zoom)/2" "(ih-ih/zoom)/2"

echo "[4/5] 세 막 이어붙이기"
printf "file '%s'\n" _cam-01.mp4 _cam-02.mp4 _cam-03.mp4 > _concat.txt
ffmpeg -v error -y -f concat -safe 0 -i _concat.txt -c copy _merged.mp4

echo "[5/5] 음원 먹싱"
ffmpeg -v error -y -i _merged.mp4 -i "$SONG" \
  -map 0:v -map 1:a -c:v copy -c:a aac -b:a 192k -shortest \
  mayclass-dreamers-final.mp4

rm -f _cam-0*.mp4 _concat.txt _merged.mp4
echo "--- 완성본 ---"
ffprobe -v error -show_entries format=duration:stream=codec_type,codec_name,width,height,r_frame_rate \
  -of default=nw=1 mayclass-dreamers-final.mp4
