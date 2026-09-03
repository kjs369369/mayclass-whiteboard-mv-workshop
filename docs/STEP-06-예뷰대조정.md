# STEP 06 · 영역 검사도와 예뷰대 조정

렌더는 막당 3분 걸립니다. 그 전에 두 가지 도구로 **눈으로 확인**합니다.

1. **영역 검사도** — 정적 PNG. 영역 위치·번호·방향을 한눈에 본다
2. **예뷰대** — 브라우저 도구. 끌어서 고치고 재생해서 본다

## 1. 영역 검사도

```bash
PYTHONUTF8=1 .venv/Scripts/python scripts/render_annotation_preview.py \
  assets/whiteboard/mayclass-dreamers/scene-01-first-step.png \
  assets/whiteboard/mayclass-dreamers/scene-01-first-step.annotation.json \
  out/regions-01.png
```

선화 위에 영역 사각형·번호·라벨·방향 화살표가 겹쳐진 PNG가 나옵니다.
Dreamers 1막을 돌리면 10개 영역이 이렇게 보입니다.

```
3. 길잡이 빛  top_to_bottom     ← 우상단, 초록
10. 앞서 오르는 사람  top_to_bottom
6. 다섯 번째 발판  left_to_right
7. 새싹  top_to_bottom          ← 좌하단, 초록
```

### 확인할 것

- [ ] **번호 순서가 가사의 사건 순서와 맞는가** — 이게 가장 중요합니다
- [ ] 모든 사각형이 캔버스 안에 있는가
- [ ] 각 사각형이 의도한 주체를 감싸고 있는가
- [ ] 겹치는 주체가 `protectedRegions`로 보호됐는가
- [ ] 화살표 방향이 그림의 형태와 어울리는가

한글 라벨이 `□□□`로 나오면 폰트 문제입니다. 이 레포는 이미 고쳐 뒀지만,
경고가 뜨면 함정노트 M절을 보세요.

### 여기서 멈춥니다

Claude Code로 진행하는 경우, 스킬이 이 검사도를 보여주고 **멈춰** 확인을
요청합니다. 렌더를 시작하기 전 마지막 관문입니다.

## 2. 예뷰대

Chrome 또는 Edge로 엽니다.

```bash
start assets/preview.html      # Windows
open assets/preview.html       # macOS
xdg-open assets/preview.html   # Linux
```

**"폴더 열기"**를 눌러 장면 폴더를 고릅니다.

```
assets/whiteboard/mayclass-dreamers
```

폴더 안의 모든 `<이름>.png` + `<이름>.annotation.json` 짝을 한꺼번에
불러옵니다. 그래서 파일 이름이 같아야 합니다(STEP 05).

### 무엇을 할 수 있나

| 조작 | 바뀌는 값 |
| --- | --- |
| 사각형의 변·꼭지점을 끈다 | `region` (x, y, width, height) |
| 오른쪽 패널에서 이름·방향 수정 | `label`, `reveal.direction` |
| 오른쪽 패널에서 시작(ms)·종료(ms) 수정 | `reveal.startMs`, `durationMs` (종료−시작, 읽기전용) |
| 오른쪽 패널에서 자막 수정 | `subtitle` |
| 모듈 목록을 끌어 순서 변경 | `sequence` 자동 재배열 |
| 모듈 선택 | 대응하는 자막이 자동 강조 |
| 타임라인을 끌거나 재생 | 드러나는 순서를 미리 본다 (시작 안 한 영역은 안 보임) |

**저장**을 누르면 원본 `.annotation.json`에 다시 씁니다.
`sceneDurationMs`는 마지막 영역 종료 + 0.5초로 자동 정렬됩니다.

### 브라우저 제약

파일 쓰기는 **File System Access API**를 씁니다. Chrome·Edge에서만 됩니다.
Firefox·Safari에서는 다운로드만 되므로 받아서 수동으로 덮어써야 합니다.

폴더 접근에 사용자 제스처가 필요하니, "폴더 열기" 버튼은 직접 눌러야 합니다.

### 사각형은 대역입니다

예뷰대가 보여주는 것은 **사각형이 방향대로 지워지는 미리보기**입니다.
완성 영상의 실제 펜 궤적은 이것과 다릅니다 — 렌더러가 선화의 골격/격자를
따라 자동 생성합니다.

그래서 예뷰대로 확인할 것은 **위치·순서·타이밍**이고, 필적의 모양이 아닙니다.
`direction`과 `handPath`도 여기서만 쓰입니다.

## 조정 요령

**타이밍이 촘촘해 보이면** 재생해 보고 각 영역이 그려지는 속도를 봅니다.
너무 빠르면 `durationMs`를 늘립니다. 단, 총합이 `sceneDurationMs`를 넘지 않게
뒤 영역들의 `startMs`도 함께 밀어야 합니다.

**영역이 다른 주체를 삼키면** 사각형을 줄이거나, 줄일 수 없으면 앞 순서 영역의
`protectedRegions`에 뒤 주체 영역을 넣습니다.

**순서를 바꾸면** 마스크 계산도 같이 바뀝니다(허용 마스크에서 뒤 순서 영역이
빠지므로). 순서를 크게 바꿨으면 영역 검사도를 다시 뽑아 확인합니다.

## 조정 후

수정된 JSON으로 STEP 05의 검증 스크립트를 한 번 더 돌립니다.
시간이 겹치지 않는지, 끝 여유가 0.5초 이상인지 확인합니다.

---

이전: [STEP 05 · annotation.json 작성](STEP-05-annotation작성.md) · 다음: [STEP 07 · 막별 렌더](STEP-07-막별렌더.md)
