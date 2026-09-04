# STEP 08 · 켄번즈 카메라 무빙

**렌더러에는 카메라가 없습니다.** 렌더 결과는 고정 프레임이라, 90초 내내
같은 프레임을 보게 됩니다. 손그림이 차분한 톤이라 더 심심합니다.

그래서 무음 MP4에 ffmpeg로 별도 패스를 얹습니다. 이 단계는 상류 도구에 없는
기능이고, 스크립트도 이 레포에서 새로 쓴 것입니다.

## 1막짜리는 스크립트 하나로 끝납니다

막이 하나면 고칠 값이 없는 전용 스크립트를 씁니다. 해상도·프레임 수·16:9 크롭을
입력에서 직접 읽습니다. STEP 09의 먹싱까지 함께 끝납니다.

```bash
bash scripts/kenburns_1act.sh <무음.mp4> <음원.mp3> <출력.mp4> [zoomin|pan|pullback]
```

| 무브 | 움직임 |
| --- | --- |
| `zoomin` (기본) | 1.00 → 1.12, 시선 살짝 위 |
| `pan` | 좌→우, 1.05 → 1.15, 이동 폭 50% (J절) |
| `pullback` | 1.18 → 1.00 |

아래 내용은 **여러 막**일 때 읽으세요.

## 여러 막이면 준비된 스크립트를 복사해 씁니다

```bash
cp assets/whiteboard/mayclass-dreamers/kenburns_and_mux.sh \
   assets/whiteboard/<내프로젝트>/kenburns_and_mux.sh
```

두 개가 들어 있으니 곡 성격에 가까운 쪽을 고릅니다.

| 파일 | 곡 | 카메라 폭 |
| --- | --- | --- |
| `mayclass-dreamers/kenburns_and_mux.sh` | K-POP 응원가 | 넓게 (줌 0.12~0.18) |
| `aiclab-shine/kenburns_and_mux.sh` | 보사노바·재즈 | 좁게 (줌 0.08~0.15) |

**잔잔한 편곡에 큰 무브를 얹으면 화면이 곡보다 앞서 나갑니다.** Shine에서
Dreamers의 카메라 폭을 그대로 썼다가 줄인 이유입니다.

## 반드시 고칠 값

### 1. 프레임 수 `N1 N2 N3`

```bash
N1=1020; N2=930; N3=683           # 실측 프레임 수
```

**Dreamers 값이 박혀 있습니다.** 자기 렌더 결과의 실제 프레임 수로 바꿉니다.

```bash
for f in assets/whiteboard/<내프로젝트>/scene-*-whiteboard.mp4; do
  printf "%-60s " "$f"
  ffprobe -v error -count_frames -select_streams v:0 \
    -show_entries stream=nb_read_frames -of csv=p=0 "$f"
done
```

안 바꾸면 무빙 속도가 어긋납니다. 특히 STEP 07에서 `--fps 30`을 빼먹었으면
프레임 수가 두 배라, 무빙이 영상 **절반에서 끝납니다.** (함정노트 L절)

### 2. 파일 이름

스크립트 안의 `scene-01-first-step-whiteboard.mp4` 같은 이름을 자기 장면
이름으로 바꿉니다. 마지막 출력 이름(`mayclass-dreamers-final.mp4`)도 바꿉니다.

### 3. 크롭 — 그대로 둡니다

```bash
CROP="crop=2524:1420:18:0"        # 2560x1420 → 16:9
```

렌더 출력이 **2560x1420**인데 이건 비율 1.803입니다. 16:9는 1.778입니다.
그대로 1920x1080으로 내보내면 **가로가 1.4% 눌립니다.**

그래서 켄번즈 **전에** 16:9를 먼저 확보합니다. 폭 2524는 1420 × 16 ÷ 9 = 2524.4에서
나온 값이고, `:18:0`은 좌우에서 각각 18px씩 버려 가운데를 남깁니다.

렌더 출력 크기가 다르면 이 값을 다시 계산합니다. (함정노트 C절)

## 무브 설계

곡 에너지에 맞춰 막마다 다르게 갑니다. Dreamers의 실제 설계입니다.

| 막 | 무브 | 이유 |
| --- | --- | --- |
| 1 | 줌인 `1.00 → 1.12`, 중심 살짝 위 (`0.42`) | 조용히 다가가기 |
| 2 | 좌→우 슬로우 팬 + `1.05 → 1.15` | 빌드업이 밀어 올림 |
| 3 | 풀백 `1.18 → 1.00` | 전체가 드러나며 끝맺음 |

이징은 전 구간 완만하게. **급격한 무브는 손그림의 차분한 톤과 싸웁니다.**

원본 2524px → 출력 1920px이므로 **1.31배까지는 확대해도 화질 손실이 없습니다.**
그 이상 가면 뭉개집니다.

## `zoompan` 식 읽기

```bash
kb () {  # kb <입력> <출력> <z식> <x식> <y식>
  ffmpeg -v error -y -i "$1" \
    -vf "${CROP},zoompan=z='$3':x='$4':y='$5':d=1:s=${OUT_W}x${OUT_H}:fps=${FPS},format=yuv420p" \
    -c:v libx264 -preset medium -crf 18 -an "$2"
}
```

`on`은 현재 프레임 번호(0부터), `N`은 총 프레임 수입니다.

**줌인**: 1.00에서 시작해 0.12만큼 선형 증가

```
max(1.0, 1.0 + 0.12 * on/(N-1))
```

**풀백**: 1.18에서 시작해 0.18만큼 감소

```
max(1.0, 1.18 - 0.18 * on/(N-1))
```

`max(1.0, ...)`으로 감싼 이유: `zoompan`의 `zoom`이 1.0 미만이면 안 됩니다.
반올림 오차로 0.9999가 되면 에러가 납니다.

**중심 고정**: `x='(iw-iw/zoom)/2'` — 가로 중앙
**시선 위로**: `y='(ih-ih/zoom)*0.42'` — 0.5가 중앙, 작으면 위쪽

## 팬은 이동 최대치까지 밀지 않습니다

Shine에서 실제로 걸린 함정입니다. 이렇게 짰습니다.

```bash
x='(iw-iw/zoom)*(on/(N-1))'
```

이러면 마지막 프레임에서 **이동 가능한 최대치**까지 밀립니다. 줌 1.13에서
가능한 오프셋이 290px인데 가장 왼쪽 요소가 225px 지점에 있어, **인물의 왼쪽이
66px 잘렸습니다.**

켄번즈에서 무언가 화면 밖으로 나가는 건 정상이지만, **인물이 반쯤 잘리면
의도가 아니라 실수로 보입니다.**

### 계수를 계산합니다

```
끝 오프셋 = (크롭폭 - 크롭폭/최대줌) × 계수

조건 1: 끝 오프셋 <= 가장 왼쪽 요소의 x
조건 2: 끝 오프셋 + 크롭폭/최대줌 >= 가장 오른쪽 요소의 x + 폭
```

Shine 2막 실측:

| 계수 | 결과 |
| --- | --- |
| 100% | 인물 66px 잘림 |
| 75% | 여유 7px — 아슬아슬 |
| **50%** | 여유 80px — 안전 |

그래서 Shine은 이렇게 됐습니다.

```bash
x='(iw-iw/zoom)*(on/(N-1))*0.5'
```

**눈대중하지 말고 계산합니다.** 그리고 원본 좌표(`annotation.json`의 `region`)를
렌더 좌표로 옮길 때 **해상도 스케일과 16:9 크롭 오프셋을 함께 적용**해야
값이 맞습니다.

```
렌더 x = (원본 x × 2560 / 원본폭) - 18
```

계산 스크립트:

```bash
PYTHONUTF8=1 .venv/Scripts/python - <<'PY'
import json
ANN = "assets/whiteboard/mayclass-dreamers/scene-02-through-the-rain.annotation.json"
ZOOM_MAX, CROP_W, CROP_OFF, RENDER_W = 1.15, 2524, 18, 2560

d = json.load(open(ANN, encoding="utf-8"))
src_w = d["canvas"]["width"]
scale = RENDER_W / src_w
xs = [(e["region"]["x"] * scale - CROP_OFF,
       (e["region"]["x"] + e["region"]["width"]) * scale - CROP_OFF)
      for e in d["elements"]]
left, right = min(a for a, _ in xs), max(b for _, b in xs)
span = CROP_W - CROP_W / ZOOM_MAX
print(f"요소 범위 x {left:.0f} ~ {right:.0f}  (크롭폭 {CROP_W}, 최대 이동 {span:.0f}px)")
for k in (1.0, 0.75, 0.5):
    end = span * k
    win_r = end + CROP_W / ZOOM_MAX
    ok = "안전" if end <= left and win_r >= right else "잘림"
    print(f"  계수 {k:.2f}: 끝오프셋 {end:6.0f}  창 우단 {win_r:6.0f}  "
          f"좌여유 {left-end:6.0f}  우여유 {win_r-right:6.0f}  {ok}")
PY
```

## 실행

```bash
bash assets/whiteboard/<내프로젝트>/kenburns_and_mux.sh <음원.mp3>
```

Dreamers는 음원 경로가 필수 인자, Shine은 기본값이 `shine-cut.mp3`입니다.
레포에 들어 있는 Shine으로 그대로 돌려볼 수 있습니다.

```bash
bash assets/whiteboard/aiclab-shine/kenburns_and_mux.sh
```

스크립트가 [1/5]~[5/5]까지 진행 상황을 찍고, 중간 파일(`_cam-0*.mp4`,
`_concat.txt`, `_merged.mp4`)은 끝에 지웁니다.

## 확인

풀백이 있는 막(보통 마지막 막)의 **첫 프레임**을 반드시 봅니다. 가장 많이
확대된 순간이라 잘림이 여기서 드러납니다.

```bash
ffmpeg -v error -y -i <완성본.mp4> -ss 65.0 -vframes 1 out/check-act3-start.png
```

- [ ] 인물·주요 요소가 잘리지 않았는가
- [ ] 무빙이 영상 끝까지 이어지는가 (절반에서 멈추면 `N` 값 문제)
- [ ] 가로가 눌리지 않았는가 (크롭을 빼먹었으면 눌린다)
- [ ] 무빙이 곡보다 앞서 나가지 않는가

---

이전: [STEP 07 · 막별 렌더](STEP-07-막별렌더.md) · 다음: [STEP 09 · 오디오 먹싱과 검수](STEP-09-오디오먹싱-검수.md)
