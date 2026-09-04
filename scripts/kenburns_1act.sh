#!/usr/bin/env bash
# 1막짜리 무음 MP4에 카메라 무빙을 얹고 음원을 먹싱한다. 시연·짧은 곡용.
#
# assets/whiteboard/*/kenburns_and_mux.sh 는 3막 전용이고 프레임 수가 손으로
# 박혀 있다. 이 스크립트는 입력에서 해상도와 프레임 수를 직접 읽으므로
# 고칠 값이 없다.
#
# 사용:
#   bash scripts/kenburns_1act.sh <무음.mp4> <음원.mp3> <출력.mp4> [무브]
#
#   무브: zoomin (기본) | pan | pullback
#
# 예:
#   bash scripts/kenburns_1act.sh out/demo-01.mp4 assets/whiteboard/demo/song.mp3 \
#        assets/whiteboard/demo/demo-final.mp4 zoomin
set -euo pipefail

IN="${1:?무음 MP4 경로를 주세요}"
SONG="${2:?음원 경로를 주세요}"
OUT="${3:?출력 MP4 경로를 주세요}"
MOVE="${4:-zoomin}"

FPS=30; OUT_W=1920; OUT_H=1080

[ -f "$IN" ]   || { echo "[에러] 입력 없음: $IN" >&2; exit 1; }
[ -f "$SONG" ] || { echo "[에러] 음원 없음: $SONG" >&2; exit 1; }

# --- 입력 규격 읽기 (손으로 고칠 값이 없는 이유) ---------------------------
# Windows 의 ffprobe 는 CRLF 로 출력한다. \r 이 남으면 산술 확장이 깨지므로 지운다.
probe() { ffprobe -v error "$@" | tr -d '\r'; }

read -r W H N < <(probe -count_frames -select_streams v:0 \
  -show_entries stream=width,height,nb_read_frames -of csv=p=0 "$IN" | tr ',' ' ')
DUR=$(probe -show_entries format=duration -of csv=p=0 "$IN")
SDUR=$(probe -show_entries format=duration -of csv=p=0 "$SONG")

echo "입력  : ${W}x${H}, ${N}프레임, ${DUR}초"
echo "음원  : ${SDUR}초"

if [ "$N" -lt 2 ]; then echo "[에러] 프레임이 너무 적습니다: $N" >&2; exit 1; fi

# --- 16:9 크롭 계산 (렌더 출력은 16:9가 아니다 — 함정노트 C절) -------------
# 높이 기준으로 16:9 폭을 구하고, 폭이 모자라면 폭 기준으로 뒤집는다.
CROP_W=$(( (H * 16 / 9 / 2) * 2 ))
CROP_H=$H
if [ "$CROP_W" -gt "$W" ]; then
  CROP_W=$(( (W / 2) * 2 ))
  CROP_H=$(( (W * 9 / 16 / 2) * 2 ))
fi
OFF_X=$(( (W - CROP_W) / 2 ))
OFF_Y=$(( (H - CROP_H) / 2 ))
CROP="crop=${CROP_W}:${CROP_H}:${OFF_X}:${OFF_Y}"
echo "크롭  : ${CROP}  (16:9 확보)"

# --- 무브 식 -----------------------------------------------------------------
# zoompan 의 zoom 은 1.0 미만이면 안 되므로 max() 로 막는다.
# pan 은 이동 최대치까지 밀면 가장자리 요소가 잘린다(함정노트 J절). 0.5 를 곱해
# 양쪽에 여유를 남긴다.
P="on/$((N-1))"
case "$MOVE" in
  zoomin)   Z="max(1.0,1.0+0.12*${P})"; X="(iw-iw/zoom)/2";            Y="(ih-ih/zoom)*0.42" ;;
  pan)      Z="max(1.0,1.05+0.10*${P})"; X="(iw-iw/zoom)*(${P})*0.5";  Y="(ih-ih/zoom)/2" ;;
  pullback) Z="max(1.0,1.18-0.18*${P})"; X="(iw-iw/zoom)/2";           Y="(ih-ih/zoom)/2" ;;
  *) echo "[에러] 무브는 zoomin | pan | pullback 중 하나입니다: $MOVE" >&2; exit 1 ;;
esac
echo "무브  : ${MOVE}"

TMP="$(dirname "$OUT")/_cam_$$.mp4"
mkdir -p "$(dirname "$OUT")"
trap 'rm -f "$TMP"' EXIT

echo "[1/2] 카메라 무빙"
ffmpeg -v error -y -i "$IN" \
  -vf "${CROP},zoompan=z='${Z}':x='${X}':y='${Y}':d=1:s=${OUT_W}x${OUT_H}:fps=${FPS},format=yuv420p" \
  -c:v libx264 -preset medium -crf 18 -an "$TMP"

echo "[2/2] 음원 먹싱"
ffmpeg -v error -y -i "$TMP" -i "$SONG" \
  -map 0:v -map 1:a -c:v copy -c:a aac -b:a 192k -shortest "$OUT"

echo "--- 완성본 ---"
ffprobe -v error \
  -show_entries stream=codec_type,codec_name,width,height,r_frame_rate \
  -show_entries format=duration -of default=nw=1 "$OUT"
echo
echo "OUTPUT=$OUT"
