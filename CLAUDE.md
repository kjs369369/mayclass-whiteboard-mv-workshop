# 화이트보드 뮤직비디오 교재 — 프로젝트 규칙

노래를 미색 종이 위 손그림 화이트보드 애니메이션으로 만드는 교재 저장소.
수강생이 클론해서 따라하는 것이 목적이다.

- GitHub: https://github.com/kjs369369/mayclass-whiteboard-mv-workshop (public, `main`)
- 완성 사례: https://youtu.be/C_g08YIftkc
- 렌더 엔진 출처: [geeklee/srt-whiteboard-animation](https://github.com/geeklee/srt-whiteboard-animation) (MIT). `NOTICE.md` 참조.

## 제작 요청이 들어오면

"화이트보드 뮤직비디오 만들어줘", "이 노래로 손그림 영상" 같은 요청에는
`.claude/skills/whiteboard-mv/SKILL.md`를 따른다. 그 문서가 확인 관문과
파라미터의 단일 기준이다. 여기에 절차를 다시 적지 않는다.

## 실행 명령

`ENV_PY`는 `.venv/Scripts/python` (Windows) / `.venv/bin/python` (macOS·Linux).

```bash
# 환경 준비 (최초 1회)
PYTHONUTF8=1 python scripts/prepare_env.py

# 막 하나 렌더
PYTHONUTF8=1 <ENV_PY> scripts/render_stream_whiteboard.py \
  <선화.png> <annotation.json> <출력.mp4> assets/drawing-hand-clean.png \
  --cap-long-edge 2560 --fps 30 --total-ms <밀리초>

# 영역 검사도
PYTHONUTF8=1 python scripts/render_annotation_preview.py <png> <json> <출력.png>

# 카메라 무빙 + 합치기 + 먹싱
bash assets/whiteboard/<프로젝트>/kenburns_and_mux.sh <음원.mp3>
```

## 이 프로젝트만의 함정

전부 `docs/함정노트.md`에 근거와 측정값이 있다. 가장 자주 걸리는 것만 옮긴다.

| # | 함정 | 조치 |
| --- | --- | --- |
| A | 스크립트가 중국어를 출력해 Windows `cp949`에서 죽는다. 한글 경로면 `PYTHONIOENCODING`으로도 안 풀린다 | 모든 실행 앞에 `PYTHONUTF8=1` |
| B | `stream_render.py`의 `cap_long_edge` 기본값이 1080이라 고해상도 원본을 줘도 1080으로 줄인다 | `--cap-long-edge 2560` 필수 |
| C | `--cap-long-edge 2560` 출력이 2560x1420 (비율 1.803) — 16:9가 아니다 | 켄번즈 전에 `crop=2524:1420:18:0` |
| D | 손 크기가 절대 픽셀(493px)이라 저해상도에서 화면을 덮는다 | 2560px로 렌더하면 자연히 해결 |
| E | 기본 펜 `drawing-hand.png` 펜대에 원저자 채널명이 인쇄돼 있다 | 항상 `drawing-hand-clean.png` 사용 |
| F | 어떤 영역에도 속하지 않은 픽셀은 마지막 프레임에 한꺼번에 튀어나온다 | 선화 프롬프트에 "얼룩 없는 균일한 종이" 명시(K절) + 플랫필드 보정 |
| G | `parse_srt.py`의 분경 제안은 자막 길이만 본다 — 음악을 모른다 | 막 경계는 오디오 RMS 에너지 전이점에서 잡는다 |
| L | 렌더러 기본 fps가 60이라 켄번즈 스크립트의 프레임 수(1020/930/683)와 어긋난다 | `--fps 30` 필수 |

## 문서를 고칠 때

- 함정을 새로 발견하면 `docs/함정노트.md`에 **측정값과 함께** 추가한다.
  "이렇게 하면 좋다"가 아니라 "이 값이 이랬고 이렇게 바뀌었다"로 쓴다.
- STEP 문서의 명령어를 바꿨으면 **실제로 클린 클론에서 돌려보고** 커밋한다.
  수강생이 복붙하는 줄이라 틀리면 바로 막힌다.
- `scripts/` 안의 상류 코드는 되도록 건드리지 않는다. 고쳐야 하면
  `NOTICE.md`의 "그대로" 표기를 함께 수정한다.
