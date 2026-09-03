# STEP 07 · 막별 렌더

막마다 무음 MP4를 뽑습니다. 여기서부터 기계가 오래 일합니다 — 막당 3분입니다.

## 명령

```bash
PYTHONUTF8=1 .venv/Scripts/python scripts/render_stream_whiteboard.py \
  assets/whiteboard/mayclass-dreamers/scene-01-first-step.png \
  assets/whiteboard/mayclass-dreamers/scene-01-first-step.annotation.json \
  assets/whiteboard/mayclass-dreamers/scene-01-first-step-whiteboard.mp4 \
  assets/drawing-hand-clean.png \
  --cap-long-edge 2560 --fps 30 --total-ms 34000
```

인자 순서는 **선화 → annotation → 출력 → 펜 이미지**입니다.

## 옵션 하나하나가 함정입니다

### `--cap-long-edge 2560` — 없으면 1080으로 줄어듭니다

`stream_render.py`의 `cap_long_edge` 기본값이 **1080**입니다. 2752px 원본을
줘도 출력이 1080px이 됩니다.

그러면 두 번째 문제가 따라옵니다. 손 이미지 크기가 `target_hand_height = 493`
**절대 픽셀**로 고정돼 있어서, 저해상도에서 화면을 덮습니다.

| 렌더 해상도 | 손이 차지하는 프레임 높이 |
| --- | --- |
| 1080x600 | **82%** — 그림이 안 보인다 |
| 2560x1420 | 34% — 적정 |

해상도를 올리면 두 문제가 함께 풀립니다. (함정노트 B·D절)

### `--fps 30` — 없으면 60으로 렌더됩니다

기본값이 **60**입니다. 주석에 "고주파 출력으로 펜 끝 움직임을 연속에 가깝게"라고
적혀 있습니다.

60fps로 렌더하면 프레임 수가 두 배가 되고, STEP 08 켄번즈 스크립트의 `N` 값
(1020 / 930 / 683 — 30fps 기준)과 어긋나 **카메라 무빙이 영상 절반에서 끝납니다.**

| 명령 | fps | 프레임 수 |
| --- | --- | --- |
| `--cap-long-edge 2560` | 60 | 2040 |
| `--cap-long-edge 2560 --fps 30` | 30 | **1020** ← 기준본과 일치 |

최종 출력이 30fps이므로 여기서 맞춰두는 게 파일도 작고 계산도 맞습니다.
(함정노트 L절)

### `--total-ms 34000` — STEP 02에서 측정한 막 길이

생략하면 `annotation.json`의 `sceneDurationMs`를 씁니다. 두 값을 같게 관리하는
게 안전하지만, 명시하면 실수를 줄일 수 있습니다.

### `assets/drawing-hand-clean.png` — 원본 펜을 쓰면 안 됩니다

기본값인 `assets/drawing-hand.png`의 **펜대에 원저자의 채널명이 인쇄돼**
있습니다. 유튜브에 올릴 영상이라면 반드시 제거본을 씁니다. (함정노트 E절)

### 필적·색칠 방식 (선택)

| 옵션 | 기본 | 대안 |
| --- | --- | --- |
| `--ink-path` | `grid` (격자, 안정적) | `skeleton` (골격 추적, 선화가 깔끔할 때 더 잘 붙는다) |
| `--color-fill` | `contour-wipe` (윤곽 스캔) | `brush` (궤적을 따라 칠하기) |
| `--pause` | `heavy` | `auto` · `light` · `off` |
| `--bare-tip` | — | 손·펜 없이 점만 표시 |

기본값으로 시작하고, 결과를 본 뒤에만 바꿉니다. 매번 3분입니다.

## 진행 확인

```
========================================================
SRT 白板动画整合渲染器 (mask 编排 + stream 画法)
========================================================
  输入: .../scene-01-first-step.png
  输出尺寸: 2560x1420, 帧率: 30
  区域数: 10, 总时长: 34000ms, 笔迹: grid, 上色: contour-wipe
  H.264 转码完成(ffmpeg): .../scene-01-first-step-whiteboard.mp4

最终视频: .../scene-01-first-step-whiteboard.mp4  (2.82 MB)
========================================================
OUTPUT=.../scene-01-first-step-whiteboard.mp4
```

**`输出尺寸`가 2560x1420, `帧率`가 30인지 세 번째 줄에서 바로 확인하세요.**
여기가 틀렸으면 지금 멈추고 옵션을 고칩니다. 3분을 버리지 않습니다.

말미에 `OUTPUT=`이 나오면 성공입니다.

## 렌더 후 검증

프레임 수와 규격을 읽습니다. **STEP 08에 이 프레임 수가 필요합니다.**

```bash
ffprobe -v error -count_frames -select_streams v:0 \
  -show_entries stream=width,height,nb_read_frames,r_frame_rate \
  -show_entries format=duration -of csv=p=0 \
  assets/whiteboard/mayclass-dreamers/scene-01-first-step-whiteboard.mp4
# → 2560,1420,30/1,1020
#    34.000000
```

기대값:

| 항목 | 값 |
| --- | --- |
| 폭 x 높이 | 2560 x 1420 |
| fps | 30/1 |
| 길이 | `--total-ms`와 일치 |
| 프레임 수 | 길이 × 30 |

## 눈으로 볼 것 — 세 시점

영상을 열어 세 지점을 확인합니다.

**1. 첫 프레임** — 깨끗한 미색 종이여야 합니다. 선이 하나도 미리 보이면 안 됩니다.

**2. 겹치는 영역의 중간** — 아직 시작하지 않은 영역과 보호구역이 보이지
않아야 합니다. 미리 새어나오면 `protectedRegions`를 손봐야 합니다.

**3. 마지막 프레임** — 완성된 그림 전체가 보이고, 최소 0.5초 머물러야 합니다.

여기서 **완성 순간 화면 색감이 확 바뀌면** 종이 얼룩 문제입니다. 어떤 영역에도
속하지 않은 픽셀이 마지막에 한꺼번에 나타나는 것입니다. 선화를 평탄화하거나
다시 생성해야 합니다. (함정노트 F·K절)

프레임을 뽑아 보려면:

```bash
ffmpeg -v error -y -i <막.mp4> -vf "select=eq(n\,0)" -vframes 1 out/frame-first.png
ffmpeg -v error -y -i <막.mp4> -sseof -0.2 -vframes 1 out/frame-last.png
```

## 실측 렌더 시간

Dreamers, 2560px, 30fps 기준.

| 막 | 길이 | 프레임 | 렌더 시간 |
| --- | --- | --- | --- |
| 1 | 34.00초 | 1020 | 3분 33초 |
| 2 | 31.00초 | 930 | 2분 45초 |
| 3 | 22.76초 | 683 | 2분 33초 |
| 합계 | 87.76초 | 2633 | **약 9분** |

## 세 막 다 돌리기

```bash
PYTHONUTF8=1 .venv/Scripts/python scripts/render_stream_whiteboard.py \
  assets/whiteboard/mayclass-dreamers/scene-02-through-the-rain.png \
  assets/whiteboard/mayclass-dreamers/scene-02-through-the-rain.annotation.json \
  assets/whiteboard/mayclass-dreamers/scene-02-through-the-rain-whiteboard.mp4 \
  assets/drawing-hand-clean.png \
  --cap-long-edge 2560 --fps 30 --total-ms 31000

PYTHONUTF8=1 .venv/Scripts/python scripts/render_stream_whiteboard.py \
  assets/whiteboard/mayclass-dreamers/scene-03-shine-as-one.png \
  assets/whiteboard/mayclass-dreamers/scene-03-shine-as-one.annotation.json \
  assets/whiteboard/mayclass-dreamers/scene-03-shine-as-one-whiteboard.mp4 \
  assets/drawing-hand-clean.png \
  --cap-long-edge 2560 --fps 30 --total-ms 22760
```

**막별 길이의 합이 음원 길이와 맞는지** 다시 확인합니다.

```
34.00 + 31.00 + 22.76 = 87.76초 ✓
```

---

이전: [STEP 06 · 예뷰대 조정](STEP-06-예뷰대조정.md) · 다음: [STEP 08 · 켄번즈 카메라 무빙](STEP-08-켄번즈.md)
