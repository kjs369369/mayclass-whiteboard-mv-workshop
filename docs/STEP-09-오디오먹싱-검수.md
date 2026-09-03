# STEP 09 · 오디오 먹싱과 검수

STEP 08의 `kenburns_and_mux.sh`가 [4/5] 이어붙이기와 [5/5] 먹싱까지 다 합니다.
이 문서는 **그 안에서 무슨 일이 일어나는지**와 **완성본을 무엇으로 검수하는지**를
다룹니다.

## `merge_scenes.py`는 오디오를 다루지 않습니다

레포에 있는 `scripts/merge_scenes.py`는 상류 도구의 스크립트입니다.

```bash
PYTHONUTF8=1 .venv/Scripts/python scripts/merge_scenes.py \
  --inputs 막1.mp4 막2.mp4 막3.mp4 --output merged.mp4
```

**영상만 이어붙입니다. 오디오 처리가 없습니다.** 그래서 음원은 합친 뒤에
따로 먹싱합니다.

## 이어붙이기

같은 코덱·같은 규격이므로 재인코딩 없이 붙입니다.

```bash
printf "file '%s'\n" _cam-01.mp4 _cam-02.mp4 _cam-03.mp4 > _concat.txt
ffmpeg -v error -y -f concat -safe 0 -i _concat.txt -c copy _merged.mp4
```

`-c copy`라 몇 초면 끝납니다. 규격이 다르면 여기서 실패하므로, 세 막을
같은 옵션으로 렌더했는지 STEP 07에서 확인해 둔 것이 여기서 쓰입니다.

## 먹싱

```bash
ffmpeg -v error -y -i _merged.mp4 -i "Dreamers of 메이클래스.mp3" \
  -map 0:v -map 1:a -c:v copy -c:a aac -b:a 192k -shortest \
  mayclass-dreamers-final.mp4
```

| 옵션 | 뜻 |
| --- | --- |
| `-map 0:v` | 첫 입력에서 영상만 |
| `-map 1:a` | 둘째 입력에서 오디오만 |
| `-c:v copy` | 영상 재인코딩 안 함 (화질 보존, 빠름) |
| `-c:a aac -b:a 192k` | 오디오는 AAC 192kbps |
| `-shortest` | 둘 중 짧은 쪽에서 끝냄 |

`-shortest`가 안전망입니다. 하지만 **여기에 의존하면 안 됩니다.** 막 길이의
합이 음원 길이와 맞지 않으면 영상이 잘리거나 뒤에 정지 화면이 남습니다.

```
34.00 + 31.00 + 22.76 = 87.76초 = 음원 길이 ✓
```

## Dreamers 음원이 없을 때

레포에 원본 mp3가 들어 있지 않습니다. 완성본에 먹싱돼 있으니 거기서 뽑습니다.

```bash
ffmpeg -i assets/whiteboard/mayclass-dreamers/mayclass-dreamers-final.mp4 \
       -vn -c:a libmp3lame -q:a 2 out/dreamers.mp3
```

Shine은 `assets/whiteboard/aiclab-shine/shine-cut.mp3`가 그대로 있습니다.
78.3초로 잘리고 끝 3초 페이드된 상태입니다.

## 완성본 규격 확인

```bash
ffprobe -v error \
  -show_entries format=duration,bit_rate \
  -show_entries stream=codec_type,codec_name,width,height,r_frame_rate,channels,sample_rate \
  -of default=nw=1 <완성본.mp4>
```

기대값:

| 항목 | 값 |
| --- | --- |
| 영상 | h264, 1920x1080, 30/1 |
| 오디오 | aac, 2ch, 48000Hz |
| 길이 | 음원 길이와 일치 (Dreamers 87.76초) |

## 검수 체크리스트

완성본을 처음부터 끝까지 한 번 봅니다. 그리고 아래를 하나씩 확인합니다.

### 그림

- [ ] **첫 프레임이 깨끗한 미색 종이.** 선이 하나도 미리 보이지 않는다
- [ ] 중간에 아직 안 그려진 영역이나 보호구역이 새어나오지 않는다
- [ ] 펜 끝이 지금 그려지는 필적에 붙어 있다
- [ ] 막마다 끝에서 최소 0.5초 완성된 그림이 머문다
- [ ] **완성 순간 화면 색감이 확 바뀌지 않는다** ← 바뀌면 종이 얼룩 문제(함정노트 F절)
- [ ] **화면 어디에도 글자가 없다** — 숫자·라벨 포함
- [ ] 펜대에 원저자 채널명이 없다 (`drawing-hand-clean.png`를 썼는지, 함정노트 E절)

### 카메라

- [ ] 잘린 인물·요소가 없다. 특히 **풀백 막의 첫 프레임**(함정노트 J절)
- [ ] 무빙이 영상 끝까지 이어진다. 절반에서 멈추면 `N` 값 문제(함정노트 L절)
- [ ] 가로가 눌리지 않았다. 눌렸으면 크롭을 빼먹은 것(함정노트 C절)
- [ ] 무빙이 곡보다 앞서 나가지 않는다

### 음악과 싱크

- [ ] 최종 길이가 음원 길이와 같다
- [ ] **막 전환이 곡의 전환과 맞는다** — STEP 02에서 측정한 그 지점
- [ ] 끝에서 음악이 잘리지 않는다

### 프레임 뽑아서 보기

눈으로 넘기기 어려운 지점은 정지 프레임으로 봅니다.

```bash
F=<완성본.mp4>
ffmpeg -v error -y -i "$F" -vf "select=eq(n\,0)" -vframes 1 out/chk-00-first.png
ffmpeg -v error -y -i "$F" -ss 33.9 -vframes 1 out/chk-01-act1-end.png
ffmpeg -v error -y -i "$F" -ss 34.1 -vframes 1 out/chk-02-act2-start.png
ffmpeg -v error -y -i "$F" -ss 65.1 -vframes 1 out/chk-03-act3-start.png
ffmpeg -v error -y -i "$F" -sseof -0.2 -vframes 1 out/chk-04-last.png
```

막 경계 앞뒤(33.9 / 34.1초)를 나란히 보면 전환이 튀는지 바로 보입니다.

## 유튜브 업로드 전에

- [ ] 펜대의 원저자 표식 제거 확인 (다시 한 번)
- [ ] 음원이 자기 것인지 확인. AI 생성곡이면 해당 서비스의 상업적 이용 약관 확인
- [ ] 썸네일은 완성본에서 좋은 프레임을 뽑아 씁니다

```bash
ffmpeg -v error -y -i <완성본.mp4> -ss <좋은시점> -vframes 1 out/thumbnail.png
```

## 다시 만들어야 할 때 — 어디로 돌아가나

| 문제 | 돌아갈 곳 |
| --- | --- |
| 완성 순간 색감이 바뀐다 | STEP 04 — 선화 평탄화 또는 재생성 |
| 그리는 순서가 가사와 어긋난다 | STEP 05 — `sequence` 수정 → STEP 07 재렌더 |
| 특정 영역이 너무 빠르거나 느리다 | STEP 06 — 예뷰대에서 타이밍 → STEP 07 재렌더 |
| 미리 새어나오는 선이 있다 | STEP 05 — `protectedRegions` → STEP 07 재렌더 |
| 손이 화면을 덮는다 | STEP 07 — `--cap-long-edge 2560` 확인 |
| 무빙이 절반에서 끝난다 | STEP 07 `--fps 30` 확인 → STEP 08 `N` 값 |
| 인물이 잘린다 | STEP 08 — 팬 계수 재계산 |
| 화면이 눌렸다 | STEP 08 — 크롭 확인 |

**재렌더는 막 단위로만 하면 됩니다.** 3막 전체를 다시 돌릴 필요는 없습니다.

## 새 함정을 만났다면

[함정노트](함정노트.md)에 추가하세요. 형식은 그 문서 마지막에 있습니다.
증상·원인·**측정값**·조치·관련 STEP 다섯 항목입니다.

측정값이 없으면 다음 사람이 판단할 수 없습니다. "느렸다"가 아니라
"3분 33초 걸렸다"로 적습니다.

---

이전: [STEP 08 · 켄번즈](STEP-08-켄번즈.md) · 처음으로: [00 · 개요](00-개요.md)
