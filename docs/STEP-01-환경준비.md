# STEP 01 · 환경 준비

렌더러는 `opencv-python`, `numpy`, `av`(PyAV), `Pillow`를 씁니다. 전역 파이썬을
더럽히지 않도록 레포 안에 독립된 `.venv`를 만듭니다.

## 1. 사전 확인

```bash
python --version      # 3.10 이상
ffmpeg -version       # 있어야 함
ffprobe -version       # 있어야 함
```

`ffmpeg`이 없으면 먼저 설치합니다.

- Windows: `winget install Gyan.FFmpeg` 또는 `choco install ffmpeg`
- macOS: `brew install ffmpeg`
- Linux: `sudo apt install ffmpeg`

렌더 자체는 PyAV로 하므로 시스템 ffmpeg 없이도 돌아갑니다. 하지만 STEP 08~09의
켄번즈·먹싱이 ffmpeg CLI를 쓰므로 결국 필요합니다.

## 2. 가상환경 만들기

```bash
PYTHONUTF8=1 python scripts/prepare_env.py
```

`.venv`를 만들고 필요한 패키지를 설치합니다. 처음이면 2분쯤 걸립니다.

성공하면 **마지막 줄**에 이렇게 나옵니다.

```
ENV_PY=C:\...\mayclass-whiteboard-mv-workshop\.venv\Scripts\python.exe
```

이 경로를 앞으로 `<ENV_PY>`라고 부릅니다. 렌더는 이 인터프리터로 돌립니다.

| OS | `<ENV_PY>` |
| --- | --- |
| Windows | `.venv/Scripts/python` |
| macOS · Linux | `.venv/bin/python` |

## 3. 이미 만들어져 있으면

```bash
PYTHONUTF8=1 python scripts/prepare_env.py --check
```

탐지만 하고 설치는 하지 않습니다. 네 패키지가 모두 `[ok]`로 나오고
`ENV_PY=`가 출력되면 준비된 것입니다.

## `PYTHONUTF8=1`을 빼면 안 됩니다

상류 도구 스크립트가 안내문을 **중국어로 출력**합니다. Windows 콘솔 기본
인코딩이 `cp949`라 그대로 실행하면 `UnicodeEncodeError`로 죽습니다.

`PYTHONIOENCODING=utf-8`도 출력 문제는 막아주지만, **경로에 한글이 들어 있으면
다른 곳에서 깨집니다.** 부모 프로세스가 자식의 출력을 `cp949`로 디코딩하려다
`UnicodeDecodeError`가 납니다.

```
UnicodeDecodeError: 'cp949' codec can't decode byte 0xed in position 107
```

이 레포는 `C:\project\강의_프로젝트\...` 같은 한글 경로에서 실제로 이 오류를
만났습니다. 가상환경은 그래도 만들어지지만 트레이스백이 길게 찍혀서
실패한 것처럼 보입니다.

`PYTHONUTF8=1`은 **입출력과 서브프로세스 디코딩을 모두 UTF-8로** 맞추므로
두 문제를 함께 없앱니다. 이걸 쓰세요.

macOS·Linux는 기본이 UTF-8이라 없어도 되지만, 붙여둬도 무해합니다.

## 매번 치기 귀찮으면

```bash
# Windows PowerShell — 세션 동안 유지
$env:PYTHONUTF8 = "1"

# Git Bash · macOS · Linux
export PYTHONUTF8=1
```

이 교재의 명령어는 안전하게 매번 붙여 적었습니다.

---

이전: [00 · 개요](00-개요.md) · 다음: [STEP 02 · 곡 구조 측정과 막 경계](STEP-02-곡구조-막경계.md)
