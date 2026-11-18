"""Draws the TaskForge mark (docs/brand/taskforge-mark.svg) for every platform.

Run from app/:  python3 tool/make_brand_icons.py
Needs Pillow. The shapes below are the same polygons as the SVG.
"""
from pathlib import Path

from PIL import Image, ImageDraw

INK, EMBER, SPARK = (22, 22, 24, 255), (251, 146, 60, 255), (255, 232, 204, 255)
ANVIL = [(150, 440), (300, 410), (820, 410), (820, 500), (660, 500), (630, 580),
         (720, 630), (720, 720), (300, 720), (300, 630), (390, 580), (360, 500), (300, 490)]
STAR = [(640, 160), (668, 242), (750, 270), (668, 298), (640, 380), (612, 298),
        (530, 270), (612, 242)]
GRID, SS = 1024, 2  # drawing grid, supersampling


def mark(size: int, style: str) -> Image.Image:
    """style: 'rounded' (rounded square, margin), 'favicon' (rounded, no margin),
    'full' (full-bleed square; the platform masks it)."""
    px = size * SS
    img = Image.new('RGBA', (px, px), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    margin = {'rounded': 0.098, 'favicon': 0.0, 'full': 0.0}[style]
    inner = px * (1 - 2 * margin)
    origin = px * margin
    if style == 'full':
        d.rectangle([0, 0, px, px], fill=INK)
        art = 0.72  # keep the mark inside the maskable safe zone
    else:
        d.rounded_rectangle([origin, origin, origin + inner, origin + inner],
                            radius=inner * 0.2237, fill=INK)
        art = 0.9
    # centre the artwork (bbox x 150..820, y 160..720) in the square
    bx0, by0, bx1, by1 = 150, 160, 820, 720
    scale = inner * art / max(bx1 - bx0, by1 - by0)
    ox = origin + (inner - (bx1 - bx0) * scale) / 2 - bx0 * scale
    oy = origin + (inner - (by1 - by0) * scale) / 2 - by0 * scale
    def pts(poly):
        return [(ox + x * scale, oy + y * scale) for x, y in poly]
    d.polygon(pts(ANVIL), fill=EMBER)
    d.polygon(pts(STAR), fill=SPARK)
    return img.resize((size, size), Image.LANCZOS)


def save(path: str, size: int, style: str) -> None:
    p = Path(path)
    if not p.parent.exists():
        return
    img = mark(size, style)
    if style == 'full' and 'ios' in path:
        img = img.convert('RGB')  # iOS icons must not carry alpha
    img.save(p)


root = Path('.')
for name, size in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)]:
    save(f'android/app/src/main/res/mipmap-{name}/ic_launcher.png', size, 'rounded')
for name, size in [('Icon-192', 192), ('Icon-512', 512)]:
    save(f'web/icons/{name}.png', size, 'rounded')
for name, size in [('Icon-maskable-192', 192), ('Icon-maskable-512', 512)]:
    save(f'web/icons/{name}.png', size, 'full')
save('web/favicon.png', 32, 'favicon')
for size in [16, 32, 64, 128, 256, 512, 1024]:
    save(f'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_{size}.png', size, 'rounded')
ios = Path('ios/Runner/Assets.xcassets/AppIcon.appiconset')
for f in ios.glob('Icon-App-*.png') if ios.exists() else []:
    stem = f.stem.replace('Icon-App-', '')          # 20x20@2x
    base, _, scale = stem.partition('@')
    size = round(float(base.split('x')[0]) * int(scale[:-1]))
    save(str(f), size, 'full')
ico = Path('windows/runner/resources/app_icon.ico')
if ico.parent.exists():
    mark(256, 'rounded').save(ico, sizes=[(s, s) for s in (16, 24, 32, 48, 64, 128, 256)])
mark(512, 'rounded').save('linux/runner/app_icon.png')
print('icons written')


# ---- splash, wordmark and social card -------------------------------------
from PIL import ImageFont  # noqa: E402

INTER = 'assets/fonts/InterVariable.ttf'


def bare_mark(size: int) -> Image.Image:
    """Anvil and spark on transparent, for splash screens on an ink background."""
    px = size * SS
    img = Image.new('RGBA', (px, px), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    bx0, by0, bx1, by1 = 150, 160, 820, 720
    scale = px * 0.9 / max(bx1 - bx0, by1 - by0)
    ox = (px - (bx1 - bx0) * scale) / 2 - bx0 * scale
    oy = (px - (by1 - by0) * scale) / 2 - by0 * scale
    d.polygon([(ox + x * scale, oy + y * scale) for x, y in ANVIL], fill=EMBER)
    d.polygon([(ox + x * scale, oy + y * scale) for x, y in STAR], fill=SPARK)
    return img.resize((size, size), Image.LANCZOS)


def font(size: int, weight: int) -> ImageFont.FreeTypeFont:
    f = ImageFont.truetype(INTER, size)
    f.set_variation_by_axes([14, weight] if len(f.get_variation_axes()) == 2 else [weight])
    return f


def wordmark(height: int, color) -> Image.Image:
    f = font(height, 600)
    w = int(f.getlength('TaskForge')) + 4
    img = Image.new('RGBA', (w, int(height * 1.3)), (0, 0, 0, 0))
    ImageDraw.Draw(img).text((2, 0), 'TaskForge', font=f, fill=color)
    return img


# iOS: 1x/2x/3x launch image (the mark; the storyboard background is ink).
launch = Path('ios/Runner/Assets.xcassets/LaunchImage.imageset')
if launch.exists():
    for name, size in [('LaunchImage', 120), ('LaunchImage@2x', 240), ('LaunchImage@3x', 360)]:
        bare_mark(size).save(launch / f'{name}.png')
# Android: centred mark on ink.
drawable = Path('android/app/src/main/res/drawable')
if drawable.exists():
    bare_mark(288).save(drawable / 'launch_mark.png')
# Social card for link previews (1200x630) and the wordmark.
card = Image.new('RGBA', (1200, 630), INK)
card.alpha_composite(bare_mark(300), (110, 165))
word = wordmark(110, (244, 244, 246, 255))
card.alpha_composite(word, (450, 235))
tag = Image.new('RGBA', (700, 60), (0, 0, 0, 0))
ImageDraw.Draw(tag).text((2, 0), 'Free, self-hostable project management', font=font(32, 400), fill=(180, 180, 188, 255))
card.alpha_composite(tag, (454, 380))
if Path('web').exists():
    card.convert('RGB').save('web/social-card.png')
wordmark(120, INK).save('../docs/brand/taskforge-wordmark.png')
print('splash, wordmark and social card written')
