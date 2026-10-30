"""Export Arial's brand lettering as SVG outlines; no font is bundled.

Requires fonttools. Run from apps/mobile:
  py tool/generate_brand_wordmark.py C:/Windows/Fonts/arial.ttf
"""
from pathlib import Path
import sys

from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen


font = TTFont(sys.argv[1])
glyphs = font.getGlyphSet()
cmap = font.getBestCmap()
scale = 100 / font['head'].unitsPerEm
paths = []
width = 0
for word, baseline in [('entre', 80), ('huellas', 175)]:
    x = 0
    for char in word:
        name = cmap[ord(char)]
        pen = SVGPathPen(glyphs)
        glyphs[name].draw(TransformPen(pen, (scale, 0, 0, -scale, x, baseline)))
        paths.append(pen.getCommands())
        x += font['hmtx'][name][0] * scale - 5  # CSS letter-spacing: -.05em.
    width = max(width, x + 5)

target = Path('assets/branding/wordmark.svg')
target.write_text(
    f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width:.6f} 190">\n'
    '<!-- Arial regular outlines: CSS weight 500 resolves to regular; tracking -.05em. -->\n'
    + ''.join(f'<path fill="#171918" d="{path}"/>\n' for path in paths)
    + '</svg>\n', encoding='utf-8',
)
print(f'{target}: viewBox width={width:.6f}, height=190')
