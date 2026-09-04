# 화이트보드 손그림 뮤직비디오 만들기 — 메이클래스 실습 교재

노래 한 곡을 **미색 종이 위에 손이 그려나가는 16:9 화이트보드 애니메이션**으로 만드는
전체 과정을 담은 교재입니다. 실제로 완성해 유튜브에 올린 두 편의 작업 파일이
그대로 들어 있어, 클론하면 **같은 결과를 처음부터 재현**할 수 있습니다.

**결과물**: [케이팝 메이클래스 스케치영상](https://youtu.be/C_g08YIftkc) — 87.76초, 1920x1080

| 프로젝트 | 길이 | 곡 | 완성본 |
| --- | --- | --- | --- |
| 메이클래스 "Dreamers" | 87.76초 | K-POP 응원가 | `assets/whiteboard/mayclass-dreamers/mayclass-dreamers-final.mp4` |
| AIC LAB "Shine" | 78.3초 | 보사노바·재즈 | `assets/whiteboard/aiclab-shine/aiclab-shine-final.mp4` |

---

## 두 가지로 쓸 수 있습니다

### 1. 스킬로 — Claude Code에게 맡기기

클론한 폴더에서 Claude Code를 열면 `.claude/skills/whiteboard-mv/`가 자동 인식됩니다.

```
이 노래로 화이트보드 뮤직비디오 만들어줘
```

스킬이 곡 구조 측정 → 막 분할 → 선화 → annotation 작성 → 렌더 → 켄번즈 →
먹싱까지 순서대로 진행합니다. 중간에 **선화 확인**과 **영역 검사도 확인** 두 개의 관문에서
멈춰 물어봅니다. 렌더가 막당 3분씩 걸리므로, 뒤에서 되돌리면 손해가 크기 때문입니다.

선화를 누가 그리는지는 환경에 따라 갈립니다.

| | 선화 | 수강생이 할 일 |
| --- | --- | --- |
| 이미지 생성 커넥터 있음 | 스킬이 직접 생성 | **곡만 준다** |
| 커넥터 없음 | 프롬프트를 받아 외부 도구에서 | 곡 + PNG 3장 |

이 레포의 두 사례는 커넥터가 붙은 환경에서 만들어졌습니다. **커넥터는 계정에
붙는 것이라 클론에 따라오지 않습니다** — 자기 Claude 계정에 따로 붙여야 합니다.

### 2. 코딩으로 — 직접 명령어를 치며 배우기

[`docs/00-개요.md`](docs/00-개요.md)부터 순서대로 따라갑니다. STEP 01~09까지
**이미 레포에 있는 메이클래스 자산으로 그대로 재현**되므로, 자기 노래가 없어도
첫 실습이 가능합니다.

| STEP | 내용 | 걸리는 시간 |
| --- | --- | --- |
| [01](docs/STEP-01-환경준비.md) | 파이썬 가상환경 준비 | 3분 |
| [02](docs/STEP-02-곡구조-막경계.md) | 곡 에너지 측정으로 막 경계 잡기 | 10분 |
| [03](docs/STEP-03-SRT작성.md) | SRT 자막 작성 | 15분 |
| [04](docs/STEP-04-선화생성.md) | 선화 3장 생성 (프롬프트 규범) | 20분 |
| [05](docs/STEP-05-annotation작성.md) | `annotation.json` 작성 | 30분 |
| [06](docs/STEP-06-예뷰대조정.md) | 브라우저 예뷰대에서 조정 | 15분 |
| [07](docs/STEP-07-막별렌더.md) | 막별 MP4 렌더 | 10분 + 렌더 9분 |
| [08](docs/STEP-08-켄번즈.md) | 카메라 무빙 얹기 | 15분 |
| [09](docs/STEP-09-오디오먹싱-검수.md) | 합치기·먹싱·검수 | 10분 |

**[`docs/함정노트.md`](docs/함정노트.md)를 먼저 읽으세요.** 실제로 만들면서 걸린
함정 13개가 정리돼 있습니다. 이걸 모르면 STEP 07에서 손이 화면을 덮거나,
STEP 09에서 완성 순간 화면 전체가 확 바뀌는 결함을 만나게 됩니다.

---

## 3분 퀵스타트

준비물: Python 3.10 이상, ffmpeg, Chrome 또는 Edge.

```bash
git clone https://github.com/kjs369369/mayclass-whiteboard-mv-workshop.git
cd mayclass-whiteboard-mv-workshop
PYTHONUTF8=1 python scripts/prepare_env.py
```

마지막 줄에 `ENV_PY=<경로>`가 나오면 성공입니다. 이제 메이클래스 1막을 그대로
렌더해 봅니다(약 4분 소요).

```bash
PYTHONUTF8=1 .venv/Scripts/python scripts/render_stream_whiteboard.py \
  assets/whiteboard/mayclass-dreamers/scene-01-first-step.png \
  assets/whiteboard/mayclass-dreamers/scene-01-first-step.annotation.json \
  out/my-scene-01.mp4 \
  assets/drawing-hand-clean.png \
  --cap-long-edge 2560 --fps 30 --total-ms 34000
```

macOS·Linux는 `.venv/Scripts/python`을 `.venv/bin/python`으로 바꿉니다.

제대로 돌았으면 레포의 기준본과 규격이 정확히 같아야 합니다.

```bash
ffprobe -v error -count_frames -select_streams v:0 \
  -show_entries stream=width,height,nb_read_frames,r_frame_rate \
  -of csv=p=0 out/my-scene-01.mp4
# → 2560,1420,30/1,1020
```

> `PYTHONUTF8=1`, `--cap-long-edge 2560`, `--fps 30` 세 개는 **빼면 안 됩니다.**
> 빼면 각각 인코딩 오류로 죽고, 해상도가 1080으로 줄어 손이 화면을 덮고,
> 60fps로 렌더되어 STEP 08의 카메라 무빙이 절반에서 끝납니다.
> 이유는 함정노트 A·B·D·L절에 있습니다.

---

## 폴더 구조

```text
mayclass-whiteboard-mv-workshop/
├── README.md                     이 문서
├── CLAUDE.md                     Claude Code용 프로젝트 규칙
├── NOTICE.md                     출처·저작권
├── .claude/skills/whiteboard-mv/
│   └── SKILL.md                  한국어 스킬 (진입점 1)
├── docs/
│   ├── 00-개요.md ~ STEP-09-*.md  실습 교재 (진입점 2)
│   ├── 함정노트.md                실전 함정 A~M
│   └── 설계-mayclass-dreamers.md  Dreamers 설계 원문
├── scripts/                      렌더러 6종
│   ├── prepare_env.py             가상환경 준비
│   ├── parse_srt.py               자막 파싱·분경 제안
│   ├── render_annotation_preview.py  영역 검사도
│   ├── render_stream_whiteboard.py   막별 MP4 렌더 (메인)
│   ├── stream_render.py           렌더 엔진
│   └── merge_scenes.py            막 합치기
├── assets/
│   ├── drawing-hand-clean.png    기본 펜 ← 이걸 쓰세요
│   ├── drawing-hand.png          원본 펜 (펜대에 원저자 채널명 있음)
│   ├── preview.html              브라우저 예뷰대
│   └── whiteboard/
│       ├── mayclass-dreamers/    선화·annotation·SRT·막별렌더·완성본
│       └── aiclab-shine/         + 음원 shine-cut.mp3
└── reference/                    상류 도구 원본 문서 (중국어)
```

`assets/whiteboard/<프로젝트>/` 안에서 **PNG와 annotation.json은 같은 이름**이어야
합니다. `scene-01-foo.png` ↔ `scene-01-foo.annotation.json`. 예뷰대가 이 규칙으로
짝을 찾습니다.

---

## 음원에 대해

- `aiclab-shine/shine-cut.mp3` — 78.3초로 잘리고 끝 3초 페이드된 상태로 들어 있습니다.
  STEP 09까지 그대로 재현할 수 있습니다.
- `mayclass-dreamers` — 원본 mp3는 들어 있지 않습니다. 완성본에 먹싱돼 있으니
  필요하면 뽑아 쓰세요.

  ```bash
  ffmpeg -i assets/whiteboard/mayclass-dreamers/mayclass-dreamers-final.mp4 \
         -vn -c:a libmp3lame -q:a 2 dreamers.mp3
  ```

자기 노래로 만들려면 Suno 같은 도구로 곡을 먼저 만들고 STEP 02부터 시작합니다.

---

## 출처와 라이선스

렌더 엔진(`scripts/`, `assets/preview.html`, `assets/drawing-hand.png`)은
[geeklee/srt-whiteboard-animation](https://github.com/geeklee/srt-whiteboard-animation)
(MIT, © 江哥是老登啊)에서 가져왔습니다. 원본 문서는 `reference/`에 그대로 보존했습니다.

이 레포가 더한 것은 **한국어 교재·스킬과 실제 완성 사례**입니다.
자세한 구분은 [NOTICE.md](NOTICE.md)를 보세요.

코드는 MIT를 따릅니다. 영상·음원·선화 등 메이클래스 작품 자산은
교육·학습 목적의 실습 재현에 쓸 수 있으나 재배포·상업적 이용은 하지 마세요.
