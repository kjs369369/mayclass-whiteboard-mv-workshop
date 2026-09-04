# STEP 04 · 선화 생성

막마다 **선화 PNG 한 장**을 만듭니다. 이 그림이 곧 그 막의 전부입니다.
렌더러는 새로 그리지 않고, 이 그림을 영역별로 가려뒀다가 순서대로 드러냅니다.

여기서 잘못 만들면 STEP 05 이후를 전부 다시 해야 합니다. 시간을 들일 곳입니다.

## 규격

| 항목 | 값 |
| --- | --- |
| 해상도 | **긴 변 2560px 이상.** 두 사례는 2752x1536 |
| 배경 | 미색 종이 `#F5EBD7` |
| 파일명 | `scene-01-<이름>.png`, `scene-02-<이름>.png`, … |
| 위치 | `assets/whiteboard/<프로젝트>/` |

### 왜 2560px 이상인가

최종 출력은 1920x1080입니다. 하지만 STEP 08에서 켄번즈 카메라가 그 안에서
1920x1080 창을 움직이며 확대합니다. 렌더를 2560px로 하면 **1.33배 줌까지
화질 손실이 없습니다.**

4K로 하면 확대 여유가 더 크지만, 렌더러가 프레임마다 마스크 연산을 하는 구조라
렌더 시간이 몇 배로 늘어납니다. 2560이 균형점입니다.

이미지 생성 도구는 요청한 크기를 정확히 주지 않습니다. 두 사례의 실제 선화는
**2752x1536**으로 나왔고, 렌더할 때 `--cap-long-edge 2560`이 긴 변을 2560으로
맞춰 **2560x1420** 출력이 됐습니다. 긴 변이 2560 이상이면 되므로 굳이 정확한
픽셀을 맞추려 애쓸 필요는 없습니다. 대신 **`annotation.json`의 `canvas`는
실제 PNG 크기와 정확히 같아야 합니다**(STEP 05).

## 이 단계는 두 갈래입니다

**갈래 A — Claude Code가 직접 그립니다.** 계정에 이미지 생성 커넥터
(Higgsfield·Abocado·Gamma 등)가 붙어 있으면 스킬이 프롬프트를 짜고 **바로 생성까지**
합니다. 이 경우 **곡만 넣으면 선화 단계도 자동으로 지나갑니다.**
이 레포의 두 완성 사례(Dreamers·Shine)가 실제로 이렇게 만들어졌습니다.

**갈래 B — 수강생이 직접 만듭니다.** 커넥터가 없으면 스킬이 프롬프트 3개를 주고
멈춥니다. ChatGPT·Nano Banana·Midjourney 등에서 PNG를 만들어
`assets/whiteboard/<프로젝트>/` 에 넣고 "됐어"라고 하면 이어서 진행합니다.

> **커넥터는 클론에 따라오지 않습니다.** 렌더 엔진·스크립트·스킬 문서는 git에
> 들어 있지만, 이미지 생성 커넥터는 **계정에 붙는 것**이라 레포에 담기지 않습니다.
> 갈래 A로 가려면 수강생이 자기 Claude 계정에 커넥터를 붙여야 합니다.

어느 갈래든 프롬프트 내용은 같습니다. 아래 규범이 그 프롬프트입니다.

## 프롬프트 규범 — 전부 넣습니다

아래를 **하나도 빼지 않고** 넣습니다. 하나씩 빠질 때마다 뒤에서 문제가 생깁니다.

```
Extremely minimal hand-drawn sketch illustration, pure pencil-sketch style,
restrained doodle aesthetic like Notion illustrations.

Background: warm beige paper tone #F5EBD7.
Lines: dark grey sketch strokes.
Accent colors: ONLY red, orange, blue — used sparingly as conceptual highlights.

Paper: single clean flat uniform tone, no stains, no cracks, no vignette,
no aged look, no paper grain.

Composition: simple, clean background, generous white space.
Keep all key elements within the central 80% of the frame.
Leave clear empty space between separate subjects.

Subjects expressed with simple outlines and few lines — emphasize
relationship / change / core concept, not realistic proportion or texture.

ABSOLUTELY NO text, words, letters, numbers, typography, or labels anywhere
in the image.
NO photorealism, no photographic detail, no 3D effects, no painterly texture.
NO complex scenes, dense backgrounds, ornate decoration, or high saturation.

Aspect ratio 16:9, 2560x1440.
```

### 각 규범이 왜 있는가

**"no stains, no cracks, no vignette, no paper grain"** — 가장 중요합니다.
렌더러는 원본 모서리에서 샘플한 **단색**으로 캔버스를 칠하고 그 위로 그림을
드러냅니다. 그래서 **어떤 영역에도 속하지 않은 픽셀은 전부 마지막에 갑자기
나타납니다.** 종이에 얼룩이 있으면 완성 순간 화면 전체가 확 바뀝니다.

측정으로도 드러났습니다. 명시하지 않았을 때 모서리 표준편차가 4.6~5.3이었고,
영역 검출을 돌리면 33개 덩어리 중 **28개가 얼룩**이었습니다. 명시하니
처음부터 **0.00**이 나왔습니다. (함정노트 F·K절)

**"central 80% of the frame"** — 켄번즈가 화면 가장자리를 잘라냅니다. 이걸
놓치면 마지막 막의 풀백에서 잘린 인물이 드러납니다. (함정노트 J절)

**"clear empty space between separate subjects"** — STEP 05에서 그림을 사각형
영역으로 쪼갭니다. 주체들이 붙어 있으면 쪼갤 수 없습니다.

**"NO text anywhere"** — 브랜드명조차 글자로 쓰지 않습니다. "메이클래스"를
넣고 싶으면 **기호로** 표현합니다. Dreamers에서는 AI 클래스라는 정체성을
**노트북 화면의 빛, 연결된 점과 선, 전구, 별**로 표현했습니다.
등불·두루마리 같은 고전적 상징은 톤이 어긋나서 쓰지 않았습니다.

## 막마다 하나의 핵심 의미만

STEP 03에서 정리한 "이 막에서 일어나는 사건"을 하나의 그림에 담습니다.
사건이 4~6개면 요소가 4~6개인 그림이 됩니다.

Dreamers 1막(0–34초, "한 걸음씩 하늘로")의 요소 구성:

| # | 요소 | 서사 역할 | 강조색 |
| --- | --- | --- | --- |
| 1 | 지면과 위로 뻗는 오르막 | 장면 바탕 | — |
| 2 | 계단처럼 놓인 발판들 | 한 걸음씩 | — |
| 3 | 한 칸 올라선 작은 사람 (뒷모습) | 주인공 등장 | — |
| 4 | 위쪽의 빛 | 길잡이 빛 | 주황 |
| 5 | 노트북을 든 두 번째 사람 | 함께 오르는 동료 | 파랑(화면) |
| 6 | 발밑의 작은 새싹 | 자라나는 배움 | — |

`docs/설계-mayclass-dreamers.md` 6절에 3막 전체가 이렇게 정리돼 있습니다.
자기 곡의 표를 이 형식으로 먼저 쓰고, 그 표를 프롬프트에 녹입니다.

## 생성 후 확인

레포의 실제 선화를 열어 비교하세요.

```
assets/whiteboard/mayclass-dreamers/scene-01-first-step.png
assets/whiteboard/mayclass-dreamers/scene-02-through-the-rain.png
assets/whiteboard/mayclass-dreamers/scene-03-shine-as-one.png
```

체크리스트:

- [ ] 긴 변이 2560px 이상인가
- [ ] 글자가 하나도 없는가 (숫자·라벨 포함)
- [ ] 종이가 균일한가 — 얼룩·금·비네팅이 없는가
- [ ] 주요 요소가 중앙 80% 안에 있는가
- [ ] 주체들 사이에 여백이 있는가 (사각형으로 쪼갤 수 있는가)
- [ ] 강조색이 빨강·주황·파랑뿐이고 소량인가
- [ ] 3막의 선·인물·색감이 서로 일관되는가

해상도 확인:

```bash
PYTHONUTF8=1 .venv/Scripts/python -c "
from PIL import Image; import sys
for p in sys.argv[1:]:
    im = Image.open(p); print(f'{im.size[0]}x{im.size[1]}  {p}')
" assets/whiteboard/mayclass-dreamers/*.png
```

종이 균일도 확인(모서리 표준편차가 1 미만이면 안전):

```bash
PYTHONUTF8=1 .venv/Scripts/python - <<'PY'
import cv2, numpy as np, glob
for p in sorted(glob.glob("assets/whiteboard/mayclass-dreamers/scene-*.png")):
    im = cv2.imread(p)
    h, w = im.shape[:2]
    k = 60
    corners = [im[0:k,0:k], im[0:k,w-k:w], im[h-k:h,0:k], im[h-k:h,w-k:w]]
    sds = [float(c.reshape(-1,3).std(axis=0).mean()) for c in corners]
    print(f"{max(sds):6.2f}  {p.split('/')[-1]}")
PY
```

## 결함이 있을 때 — 재생성보다 보정

이미지 생성은 크레딧이 듭니다. 재생성 전에 보정으로 해결되는지 봅니다.

**종이 얼룩** → 플랫필드 보정. 저주파 배경장을 추정해 빼면 그림 선과 강조색은
그대로 남습니다. 1/8로 축소 → 강한 미디언 블러 → 원래 크기로 확대 = 배경장,
`원본 - 배경장 + 목표종이색`, 밝고 저채도인 픽셀만 목표색으로 스냅.
실측에서 모서리 표준편차 4.6~5.3 → 0.04~1.11로 떨어졌습니다.

**속이 빈 도형** → Dreamers 3막의 태양이 속 빈 원으로 나왔습니다. 클라이맥스인데
중심이 허전했습니다. 재생성 대신 1막 태양에서 색을 샘플링해 채웠고,
두 태양의 톤이 정확히 일치하는 부수 효과까지 얻었습니다. (함정노트 H절)

## 여기서 멈춥니다

Claude Code로 진행하는 경우, 스킬이 이 지점에서 **선화를 보여주고 멈춰**
확인을 요청합니다. 다음 단계로 넘어가기 전에 반드시 눈으로 봅니다.

렌더가 막당 3분씩 걸리고, 선화가 틀리면 STEP 05~07을 전부 다시 해야 합니다.

---

이전: [STEP 03 · SRT 작성](STEP-03-SRT작성.md) · 다음: [STEP 05 · annotation.json 작성](STEP-05-annotation작성.md)
