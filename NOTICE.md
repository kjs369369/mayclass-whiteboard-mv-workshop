# 출처와 저작권

이 레포는 두 층으로 되어 있습니다. 어느 파일이 누구 것인지 헷갈리지 않도록 적어둡니다.

## 1층 · 렌더 엔진 — 원저작자 것

[geeklee/srt-whiteboard-animation](https://github.com/geeklee/srt-whiteboard-animation)
에서 가져왔습니다. MIT License, Copyright (c) 2026 江哥是老登啊.
`LICENSE` 파일은 원문 그대로 유지했습니다.

| 파일 | 비고 |
| --- | --- |
| `scripts/prepare_env.py` | 그대로 |
| `scripts/parse_srt.py` | 그대로 |
| `scripts/render_annotation_preview.py` | **수정.** 폰트를 `msyh.ttc` 고정에서 한글 폰트 후보 탐색으로 변경 (함정노트 M절) |
| `scripts/render_stream_whiteboard.py` | 그대로 |
| `scripts/stream_render.py` | 그대로 |
| `scripts/merge_scenes.py` | 그대로 |
| `assets/preview.html` | 그대로 |
| `assets/drawing-hand.png` | 그대로. 펜대에 원저자 채널명이 인쇄돼 있음 |
| `reference/SKILL-upstream-zh.md` | 원본 `SKILL.md` |
| `reference/README-upstream-zh.md` | 원본 `README.md` |

원본 저장소에 있던 데모 예제(`examples/` — 원숭이산 장면)는 이 교재와 무관해
포함하지 않았습니다. 도구 자체를 보려면 원본 저장소를 보세요.

## 2층 · 교재와 작품 — AICLab(김진수) 것

| 파일 | 비고 |
| --- | --- |
| `README.md` | 신규 작성 |
| `CLAUDE.md` | 신규 작성 |
| `.claude/skills/whiteboard-mv/SKILL.md` | 한국어 스킬. 원본 워크플로를 뮤직비디오 제작으로 재구성 |
| `docs/00-개요.md` ~ `docs/STEP-09-*.md` | 신규 작성 |
| `docs/함정노트.md` | 실제 제작에서 발견한 함정 11개 |
| `docs/설계-mayclass-dreamers.md` | Dreamers 설계 문서 원문 |
| `assets/drawing-hand-clean.png` | 원본 펜에서 채널명을 인페인팅으로 제거한 파생물 |
| `assets/whiteboard/**/kenburns_and_mux.sh` | 카메라 무빙·먹싱 스크립트. 원본 도구에는 없는 기능 |
| `assets/whiteboard/**/*.png` | 선화 (AI 이미지 생성) |
| `assets/whiteboard/**/*.annotation.json` | 영역·시퀀스 표기 |
| `assets/whiteboard/**/*.srt` | 가사 자막 |
| `assets/whiteboard/**/*.mp4` | 막별 렌더와 완성본 |
| `assets/whiteboard/aiclab-shine/shine-cut.mp3` | AI 생성 음원 |

## 이용 범위

- **코드**(`scripts/`, `assets/preview.html`, `kenburns_and_mux.sh`)는 MIT.
  MIT 조건대로 저작권 표시와 라이선스 전문을 함께 유지하면 자유롭게 쓸 수 있습니다.
- **문서**(`README.md`, `docs/`, `SKILL.md`)는 학습·강의 목적으로 자유롭게
  인용·수정해도 됩니다. 출처를 적어주면 고맙습니다.
- **작품 자산**(영상·음원·선화)은 교재를 따라 실습을 재현하는 용도로만 쓰세요.
  재배포하거나 상업적으로 쓰지 마세요.

## 펜 이미지 주의

`assets/drawing-hand.png`의 펜대에는 원저자의 채널명이 크게 인쇄돼 있습니다.
원본 `SKILL.md`도 "사용자가 자기 표식이라고 명시한 경우에만 유지"라고 적고 있습니다.

유튜브 등에 공개할 영상이라면 **`assets/drawing-hand-clean.png`을 쓰세요.**
교재와 스킬 모두 이걸 기본값으로 지정하고 있습니다.
