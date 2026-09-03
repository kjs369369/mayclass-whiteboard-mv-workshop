import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

# 원본은 폰트를 C:/Windows/Fonts/msyh.ttc 하나로 고정했다. 그 폰트에는 한글
# 글리프가 없어 라벨이 □□□로 나오고, 경로가 Windows 전용이라 macOS·Linux에서는
# FileNotFoundError로 죽는다. 한글이 있는 폰트를 먼저 찾고 순서대로 내려간다.
FONT_CANDIDATES = (
    "C:/Windows/Fonts/malgun.ttf",                            # 맑은 고딕 (Windows)
    "C:/Windows/Fonts/NanumGothic.ttf",
    "/System/Library/Fonts/AppleSDGothicNeo.ttc",             # macOS
    "/System/Library/Fonts/Supplemental/AppleGothic.ttf",
    "/usr/share/fonts/truetype/nanum/NanumGothic.ttf",        # Linux
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
    "/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc",
    "C:/Windows/Fonts/msyh.ttc",                              # 원본 기본값 (한글 없음)
)


def load_font(size: int):
    for path in FONT_CANDIDATES:
        if Path(path).exists():
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                continue
    print("[경고] 한글 폰트를 찾지 못해 기본 폰트를 씁니다. 라벨이 작게 나옵니다.")
    return ImageFont.load_default()


def main(image_path: str, annotation_path: str, output_path: str) -> None:
    image = Image.open(image_path).convert("RGBA")
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    font = load_font(28)
    small_font = load_font(18)
    colors = [(38, 103, 255, 225), (255, 105, 92, 225), (41, 167, 102, 225), (181, 100, 255, 225)]

    data = json.loads(Path(annotation_path).read_text(encoding="utf-8"))
    for index, element in enumerate(data["elements"], start=1):
        region = element["region"]
        x, y = region["x"], region["y"]
        right, bottom = x + region["width"], y + region["height"]
        color = colors[(index - 1) % len(colors)]
        fill = (*color[:3], 24)
        draw.rounded_rectangle((x, y, right, bottom), radius=12, outline=color, width=4, fill=fill)
        draw.ellipse((x + 8, y + 8, x + 44, y + 44), fill=color)
        draw.text((x + 19, y + 8), str(index), anchor="ma", font=small_font, fill="white")
        label = f"{index}. {element['label']}  {element['reveal']['direction']}"
        draw.rounded_rectangle((x + 52, y + 8, min(right - 8, x + 52 + len(label) * 19), y + 46), radius=6, fill=(255, 255, 255, 225))
        draw.text((x + 60, y + 12), label, font=small_font, fill=color)
        start = tuple(element["handPath"]["start"])
        end = tuple(element["handPath"]["end"])
        draw.line((start, end), fill=color, width=4)
        draw.polygon((end, (end[0] - 13, end[1] - 7), (end[0] - 13, end[1] + 7)), fill=color)

    result = Image.alpha_composite(image, overlay).convert("RGB")
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    result.save(output_path, quality=95)


if __name__ == "__main__":
    main(*sys.argv[1:4])
