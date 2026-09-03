#!/usr/bin/env bash
# AIC LAB "Shine" — 무음 3막 → 카메라 무빙 → 이어붙이기 → 음원 먹싱
#
# 곡이 보사노바·재즈라 카메라 폭을 지난 곡보다 줄였다.
# 잔잔한 편곡에 큰 무브를 얹으면 화면이 곡보다 앞서 나간다.
#
# 렌더 출력 2560x1420(비율 1.803)은 16:9가 아니므로 먼저 자른다.
# zoompan 의 zoom 은 1.0 미만이면 안 되므로 max() 로 막는다.
set -euo pipefail
cd "$(dirname "$0")"

SONG="${1:-shine-cut.mp3}"
FPS=30; OUT_W=1920; OUT_H=1080
CROP="crop=2524:1420:18:0"

N1=930; N2=726; N3=693        # 31.0 / 24.2 / 23.1 초 × 30fps

kb () {
  ffmpeg -v error -y -i "$1" \
    -vf "${CROP},zoompan=z='$3':x='$4':y='$5':d=1:s=${OUT_W}x${OUT_H}:fps=${FPS},format=yuv420p" \
    -c:v libx264 -preset medium -crf 18 -an "$2"
}

echo "[1/5] 1막 · 아주 느린 줌인 1.00→1.10 (방 안으로 들어가듯)"
kb scene-01-morning-light-whiteboard.mp4 _cam-01.mp4 \
   "max(1.0,1.0+0.10*on/$((N1-1)))" "(iw-iw/zoom)/2" "(ih-ih/zoom)*0.45"

echo "[2/5] 2막 · 좌→우 팬 + 1.05→1.13 (발자국이 가는 방향)"
kb scene-02-just-try-whiteboard.mp4 _cam-02.mp4 \
   "max(1.0,1.05+0.08*on/$((N2-1)))" "(iw-iw/zoom)*(on/$((N2-1)))*0.5" "(ih-ih/zoom)/2"

echo "[3/5] 3막 · 풀백 1.15→1.00 (길이 드러나며 마무리)"
kb scene-03-side-by-side-whiteboard.mp4 _cam-03.mp4 \
   "max(1.0,1.15-0.15*on/$((N3-1)))" "(iw-iw/zoom)/2" "(ih-ih/zoom)/2"

echo "[4/5] 이어붙이기"
printf "file '%s'\n" _cam-01.mp4 _cam-02.mp4 _cam-03.mp4 > _concat.txt
ffmpeg -v error -y -f concat -safe 0 -i _concat.txt -c copy _merged.mp4

echo "[5/5] 음원 먹싱 (이미 78.3초로 잘리고 끝 3초 페이드된 파일)"
ffmpeg -v error -y -i _merged.mp4 -i "$SONG" \
  -map 0:v -map 1:a -c:v copy -c:a aac -b:a 192k -shortest \
  aiclab-shine-final.mp4

rm -f _cam-0*.mp4 _concat.txt _merged.mp4
echo "--- 완성본 ---"
ffprobe -v error -show_entries format=duration:stream=codec_type,codec_name,width,height,r_frame_rate \
  -of default=nw=1 aiclab-shine-final.mp4
