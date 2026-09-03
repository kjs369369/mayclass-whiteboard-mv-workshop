# STEP 05 · annotation.json 작성

이 단계가 이 파이프라인의 심장입니다. 선화 한 장을 **영역으로 쪼개고,
각 영역을 몇 번째로 몇 초에 그릴지** 지정합니다.

## 파일 이름 규칙

```
scene-01-first-step.png  ↔  scene-01-first-step.annotation.json
```

**PNG와 JSON의 이름이 같아야 합니다.** 예뷰대가 이 규칙으로 짝을 찾습니다.

## 작성 전에 반드시

1. **그 막의 가사를 읽습니다.**
2. **실제로 이미지를 봅니다.** 가사만 보고 추측하면 안 됩니다.
3. **원본 PNG의 픽셀 크기를 구합니다.**

```bash
PYTHONUTF8=1 .venv/Scripts/python -c "
from PIL import Image
im = Image.open('assets/whiteboard/mayclass-dreamers/scene-01-first-step.png')
print(im.size)   # (2752, 1536)
"
```

## 구조

```json
{
  "sceneId": "scene-01",
  "canvas": { "width": 2752, "height": 1536 },
  "storyBasis": "함께 오르기 시작한다. 메이클래스가 길잡이 빛이 되고, 한 걸음씩 하늘을 좇는다.",
  "sceneDurationMs": 34000,
  "elements": [
    {
      "id": "step-1",
      "label": "첫 발판",
      "sequence": 1,
      "narrativeRole": "한 걸음씩 오르기 시작",
      "subtitle": "Together we rise, with passion inside",
      "type": "structure",
      "region": { "x": 824, "y": 1162, "width": 292, "height": 172 },
      "reveal": {
        "direction": "left_to_right",
        "startMs": 800,
        "durationMs": 4200,
        "maskPaddingPx": 22,
        "protectedRegions": []
      },
      "handPath": { "start": [830, 1250], "end": [1110, 1250], "easing": "easeInOut" }
    }
  ]
}
```

실제 파일을 열어 전체를 보세요. Dreamers 1막은 요소가 10개입니다.

```
assets/whiteboard/mayclass-dreamers/scene-01-first-step.annotation.json
```

## 필드별 규칙

### `canvas`

**원본 PNG 픽셀 크기와 정확히 같아야 합니다.** 백분율·비율·추정값 금지.
이게 틀리면 모든 좌표가 어긋납니다.

레포의 여섯 장면 전부 `canvas`가 PNG 크기와 일치하는지 확인해 보세요.

```bash
PYTHONUTF8=1 .venv/Scripts/python - <<'PY'
from PIL import Image
import glob, json, os
for p in sorted(glob.glob("assets/whiteboard/*/scene-*.png")):
    im = Image.open(p)
    j = p.replace(".png", ".annotation.json")
    if not os.path.exists(j):
        print(f"[없음] {j}"); continue
    c = json.load(open(j, encoding="utf-8"))["canvas"]
    ok = "OK" if (c["width"], c["height"]) == im.size else "불일치!"
    print(f"{im.size[0]}x{im.size[1]}  canvas {c['width']}x{c['height']}  {ok}")
PY
```

### `sequence` — 가사의 사건 순서

**화면 좌표 순서가 아닙니다.** 왼쪽→오른쪽, 위→아래로 기계적으로 정렬하면
영상이 가사와 어긋납니다.

가사에서 사건을 뽑고, 이미지에서 보이는 주체를 그 사건에 대응시켜
이 순서로 배치합니다.

```
장면 바탕  →  핵심 인물·물체  →  동작·변화  →  반응·결과
```

Dreamers 1막의 실제 순서(가사: 함께 일어선다 → 길잡이 빛 → 한 걸음씩 →
배우는 마음):

| seq | id | label | 서사 역할 |
| --- | --- | --- | --- |
| 1 | `step-1` | 첫 발판 | 한 걸음씩 오르기 시작 |
| 2 | `step-2` | 두 번째 발판 | |
| 3 | `guiding-light` | 길잡이 빛 | 메이클래스가 길이 된다 |
| 4 | `step-3` | 세 번째 발판 | |
| 5 | `step-4` | 네 번째 발판 | |
| 6 | `step-5` | 다섯 번째 발판 | |
| 7 | `sprout` | 새싹 | 자라나는 배움 |
| 8 | `learner` | 배우는 사람 | 주인공 등장 |
| 9 | `laptop` | 노트북 | 배움의 도구 |
| 10 | `climber` | 앞서 오르는 사람 | 함께 오르는 동료 |

`sequence`는 **1부터 연속**입니다. 건너뛰지 않습니다.

### `region` — 정수 픽셀

```json
"region": { "x": 824, "y": 1162, "width": 292, "height": 172 }
```

- 원점은 **좌상단**
- 모두 **정수**. 소수점 금지
- 캔버스 안에 완전히 들어가야 합니다: `x + width <= canvas.width`

영역은 그 주체를 감싸는 사각형입니다. 딱 맞게 잡기보다 조금 여유를 줍니다.

### `startMs` / `durationMs` — 펜은 하나입니다

**시간이 겹치면 안 됩니다.** 펜이 하나이므로 영역들은 시간상 순차로 진행합니다.

```
다음 startMs = 이전 startMs + 이전 durationMs + (숨돌릴 100~300ms)
```

Dreamers 1막의 실제 타임라인:

| seq | startMs | durationMs | 끝 | 다음 시작 |
| --- | --- | --- | --- | --- |
| 1 | 800 | 4200 | 5000 | 5300 (+300) |
| 2 | 5300 | 3900 | 9200 | 9500 (+300) |
| 3 | 9500 | 4700 | 14200 | 14500 (+300) |
| 4 | 14500 | 2600 | 17100 | 17300 (+200) |
| … | | | | |
| 10 | 30600 | 2900 | 33500 | — |

마지막 요소가 33500ms에 끝나고 `sceneDurationMs`가 34000이므로, **끝에서
0.5초 완성된 그림이 머뭅니다.** 이 여유를 반드시 남깁니다.

`durationMs` 초기 추정값은 **그리는 거리 ÷ 150픽셀/초**입니다. 정확할 필요는
없습니다 — STEP 06 예뷰대에서 눈으로 보며 조정합니다.

영역 안에서 `durationMs`는 `ink : color = 2 : 1`로 쪼개집니다. 선을 긋는 데
2/3, 색을 넣는 데 1/3입니다.

### `protectedRegions` — 겹칠 때만

영역의 **실제 허용 마스크**는 이렇게 계산됩니다.

```
허용 마스크 = region − (뒤 순서 영역들의 region) − protectedRegions
```

뒤 순서 영역은 자동으로 빠지므로, 보통은 `protectedRegions`가 빈 배열입니다.
Dreamers 1막도 10개 요소 전부 빈 배열입니다.

필요한 경우는 이렇습니다.

- 사각형이 너무 커서 다른 주체를 삼킬 때
- 주체가 서로 겹쳐 있을 때
- 배경 선이 미리 새어나올 수 있을 때

이때 **앞 순서 영역의 `protectedRegions`에 뒤 주체의 영역을 적습니다.**
좌표 형식은 `region`과 같습니다.

### `direction` / `handPath` — 예뷰대 전용

**실제 필적에 영향을 주지 않습니다.** 완성 영상의 펜 궤적은 렌더러가
선화의 골격/격자를 따라 자동 생성합니다.

이 두 필드는 STEP 06 예뷰대가 사각형 대역으로 미리보기를 보여줄 때만 씁니다.
그래도 넣어야 예뷰대가 동작합니다. 대략만 채웁니다.

`direction` 가능값: `left_to_right`, `right_to_left`, `top_to_bottom`, `bottom_to_top`.

### `sceneDurationMs`

STEP 02에서 측정한 그 막의 길이입니다. 렌더할 때 `--total-ms`로 다시
지정하므로 두 값을 같게 둡니다.

## 확인

작성 후 JSON이 유효한지, 좌표가 캔버스 안인지, 시간이 겹치지 않는지 봅니다.

```bash
PYTHONUTF8=1 .venv/Scripts/python - <<'PY'
import json, sys
P = "assets/whiteboard/mayclass-dreamers/scene-01-first-step.annotation.json"
d = json.load(open(P, encoding="utf-8"))
cw, ch = d["canvas"]["width"], d["canvas"]["height"]
prev_end, bad = 0, 0
for e in sorted(d["elements"], key=lambda x: x["sequence"]):
    r, rv = e["region"], e["reveal"]
    if r["x"] + r["width"] > cw or r["y"] + r["height"] > ch or r["x"] < 0 or r["y"] < 0:
        print(f"[영역 벗어남] seq{e['sequence']} {e['id']}"); bad += 1
    if any(not isinstance(v, int) for v in r.values()):
        print(f"[정수 아님] seq{e['sequence']} {e['id']}"); bad += 1
    if rv["startMs"] < prev_end:
        print(f"[시간 겹침] seq{e['sequence']} {e['id']} start={rv['startMs']} < 이전끝={prev_end}"); bad += 1
    prev_end = rv["startMs"] + rv["durationMs"]
gap = d["sceneDurationMs"] - prev_end
print(f"마지막 끝 {prev_end}ms, sceneDuration {d['sceneDurationMs']}ms, 여유 {gap}ms")
if gap < 500: print("[경고] 끝 여유가 0.5초 미만"); bad += 1
print("문제 없음" if bad == 0 else f"문제 {bad}건")
PY
```

`P`를 자기 파일 경로로 바꿔 돌립니다.

## 작성 직후 예뷰대를 엽니다

```bash
start assets/preview.html      # Windows
open assets/preview.html       # macOS
xdg-open assets/preview.html   # Linux
```

Claude Code로 진행하는 경우, 스킬이 annotation을 만든 직후 예뷰대를 **자동으로
열고** 장면 폴더를 불러옵니다. 이건 별도 확인 없이 진행되는 동작입니다.

---

이전: [STEP 04 · 선화 생성](STEP-04-선화생성.md) · 다음: [STEP 06 · 예뷰대 조정](STEP-06-예뷰대조정.md)
