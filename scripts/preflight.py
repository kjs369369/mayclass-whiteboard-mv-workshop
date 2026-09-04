"""시연·실습 전에 환경이 준비됐는지 한 번에 점검한다.

    PYTHONUTF8=1 python scripts/preflight.py

전부 [OK] 면 바로 시작해도 된다. [NG] 가 하나라도 있으면 그 줄의 조치를 먼저 한다.
종료 코드는 NG 개수다(0 이면 통과).
"""
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FAILS = []


def line(ok: bool, label: str, detail: str = "", fix: str = "") -> None:
    tag = "[OK]" if ok else "[NG]"
    print(f"{tag} {label:<24} {detail}")
    if not ok:
        FAILS.append(label)
        if fix:
            print(f"     └ 조치: {fix}")


def check_python() -> None:
    v = sys.version_info
    line(v >= (3, 10), "Python 3.10+",
         f"{v.major}.{v.minor}.{v.micro}",
         "python.org 에서 3.10 이상 설치")


def check_utf8() -> None:
    on = sys.flags.utf8_mode or os.environ.get("PYTHONUTF8") == "1"
    line(bool(on), "PYTHONUTF8=1",
         "켜짐" if on else "꺼짐 — 한글 경로에서 스크립트가 죽습니다",
         "모든 명령 앞에 PYTHONUTF8=1 을 붙이거나 export PYTHONUTF8=1")


def check_binary(name: str) -> None:
    p = shutil.which(name)
    ver = ""
    if p:
        try:
            out = subprocess.run([name, "-version"], capture_output=True,
                                 text=True, errors="replace", timeout=20).stdout
            ver = out.splitlines()[0][:60] if out else ""
        except Exception:
            ver = "(버전 확인 실패)"
    line(bool(p), name, ver or "없음",
         "Windows: winget install Gyan.FFmpeg / macOS: brew install ffmpeg")


def check_git() -> None:
    p = shutil.which("git")
    line(bool(p), "git", p or "없음", "git-scm.com 에서 설치")


def venv_python() -> Path | None:
    for rel in (".venv/Scripts/python.exe", ".venv/bin/python"):
        p = ROOT / rel
        if p.exists():
            return p
    return None


def check_venv() -> Path | None:
    py = venv_python()
    line(bool(py), ".venv",
         str(py) if py else "없음",
         "PYTHONUTF8=1 python scripts/prepare_env.py")
    return py


def check_packages(py: Path | None) -> None:
    if py is None:
        line(False, "렌더 의존성", "가상환경이 없어 확인 불가",
             "PYTHONUTF8=1 python scripts/prepare_env.py")
        return
    code = (
        "import importlib,sys\n"
        "miss=[n for m,n in "
        "(('cv2','opencv-python'),('numpy','numpy'),('av','av'),('PIL','Pillow')) "
        "if not importlib.util.find_spec(m)]\n"
        "print(','.join(miss))"
    )
    r = subprocess.run([str(py), "-c", code], capture_output=True,
                       text=True, errors="replace", timeout=90)
    miss = r.stdout.strip()
    line(not miss, "렌더 의존성",
         "opencv-python, numpy, av, Pillow" if not miss else f"빠짐: {miss}",
         "PYTHONUTF8=1 python scripts/prepare_env.py")


def check_font() -> None:
    sys.path.insert(0, str(ROOT / "scripts"))
    try:
        from render_annotation_preview import FONT_CANDIDATES
    except Exception as exc:
        line(False, "한글 폰트", f"확인 실패: {exc}")
        return
    found = next((c for c in FONT_CANDIDATES if Path(c).exists()), None)
    hangul = found is not None and "msyh" not in found
    line(hangul, "한글 폰트",
         found or "없음",
         "맑은 고딕·나눔고딕·Noto Sans CJK 중 하나를 설치 (없어도 렌더는 됩니다)")


def check_assets() -> None:
    need = [
        "assets/drawing-hand-clean.png",
        "assets/preview.html",
        "assets/whiteboard/aiclab-shine/shine-cut.mp3",
        "assets/whiteboard/mayclass-dreamers/scene-01-first-step.png",
    ]
    missing = [n for n in need if not (ROOT / n).exists()]
    line(not missing, "교재 자산",
         "전부 있음" if not missing else f"빠짐: {', '.join(missing)}",
         "git clone 을 다시 하거나 git status 로 확인")


def main() -> int:
    print(f"점검 대상: {ROOT}\n")
    check_python()
    check_utf8()
    check_git()
    check_binary("ffmpeg")
    check_binary("ffprobe")
    py = check_venv()
    check_packages(py)
    check_font()
    check_assets()

    print()
    if FAILS:
        print(f"[실패] {len(FAILS)}건 — {', '.join(FAILS)}")
        print("위 조치를 먼저 하고 다시 실행하세요.")
    else:
        print("[통과] 준비 완료. docs/00-개요.md 부터 시작하세요.")
        if py:
            print(f"ENV_PY={py}")
    return len(FAILS)


if __name__ == "__main__":
    raise SystemExit(main())
