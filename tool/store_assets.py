"""Serialize opaque Play assets as RGB PNG and verify the complete v2 inventory.

Run after the Flutter generators: python tool/store_assets.py
Use --check in verification; --sheets makes inspection-only contact sheets.
Requires Pillow (also used by tool/art_v2).
"""
from __future__ import annotations
import argparse
import hashlib
import json
import re
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
STORE = ROOT / 'docs/store'
MANIFEST = STORE / 'assets-v2.json'
LANGS = ('en', 'id', 'pt', 'ru')
PORTRAITS = ('01-santai', '02-makan', '03-main', '04-rawat',
             '05-toko-aksesoris', '06-peta-babak-2',
             '07-fase-atur-level-13', '08-berhasil-level-13')
EXTRA = ('10-peta-babak-1', '11-toko-barang', '12-koleksi-kucing',
         '13-toko-camilan', '14-pengaturan')


def check_inventory():
    expected = {f'{lang}/{name}.png' for lang in LANGS for name in PORTRAITS}
    actual = {p.relative_to(STORE / 'screenshots').as_posix()
              for p in (STORE / 'screenshots').rglob('*.png')}
    if actual != expected:
        raise ValueError(f'Store inventory missing={expected-actual}, extra={actual-expected}')
    for lang in LANGS:
        hashes = {hashlib.sha256((STORE/'screenshots'/lang/f'{name}.png').read_bytes()).hexdigest()
                  for name in PORTRAITS[:4]}
        if len(hashes) != 4:
            raise ValueError(f'{lang}: four home areas must have distinct captures')
    docs = ROOT / 'docs/screenshots'
    expected_docs = {f'{name}.png' for name in (*PORTRAITS, '09-fase-jalan-level-13')}
    expected_docs |= {f'{lang}/{name}.png' for lang in LANGS for name in EXTRA}
    actual_docs = {p.relative_to(docs).as_posix() for p in docs.rglob('*.png')}
    if actual_docs != expected_docs:
        raise ValueError(f'Documentation inventory missing={expected_docs-actual_docs}, extra={actual_docs-expected_docs}')


def opaque_png(path: Path, check: bool):
    with Image.open(path) as im:
        if im.mode == 'RGB':
            return
        if im.mode != 'RGBA' or im.getchannel('A').getextrema() != (255, 255):
            raise ValueError(f'Expected fully opaque UI capture: {path}')
        if check:
            raise ValueError(f'Run export to encode 24-bit RGB: {path}')
        # Lossless serialization only: no compositing, retouching, or resizing.
        im.convert('RGB').save(path, optimize=True)


def build_manifest():
    files = sorted((STORE / 'screenshots').rglob('*.png'))
    files += sorted(STORE.glob('feature-graphic*.png')) + [STORE / 'icon-512.png']
    files += sorted((ROOT / 'docs/screenshots').rglob('*.png'))
    files += sorted((ROOT / 'android/app/src/main/res').rglob('*.png'))
    records = []
    for p in files:
        with Image.open(p) as im:
            if p.parent.parent == STORE / 'screenshots':
                assert im.size == (1080, 1920), p
            if p.name.startswith('feature-graphic'):
                assert im.size == (1024, 500), p
            if p.name == 'icon-512.png':
                assert im.size == (512, 512) and im.mode == 'RGBA', p
                assert p.stat().st_size <= 1024 * 1024, p
            if p.name in ('ic_launcher_foreground.png', 'ic_launcher_monochrome.png', 'splash_icon.png'):
                # Check actual alpha pixels against the Android safe circle.
                radius = im.width * (96/288 if p.name == 'splash_icon.png' else 33/108)
                alpha = im.getchannel('A')
                for y in range(im.height):
                    for x in range(im.width):
                        if alpha.getpixel((x,y)) > 16 and ((x+.5-im.width/2)**2 + (y+.5-im.height/2)**2) > radius**2:
                            raise ValueError(f'Outside Android safe circle: {p} at {x},{y}')
            records.append(dict(path=p.relative_to(ROOT).as_posix(),
                                width=im.width, height=im.height, mode=im.mode,
                                bytes=p.stat().st_size,
                                sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
    listings = {}
    for lang in LANGS:
        sections = re.findall(r'```\s*\n(.*?)\n```',
                              (STORE / f'listing-{lang}.md').read_text(encoding='utf-8'), re.S)
        lengths = [len(s) for s in sections[:3]]
        assert len(lengths) == 3 and all(n <= limit for n, limit in zip(lengths, (30, 80, 4000))), (lang, lengths)
        listings[lang] = dict(zip(('title', 'short', 'full'), lengths))
    return dict(version=2, generator='Flutter runtime v2; host widget captures',
                store_screenshots_per_language=8, listings=listings, assets=records)


def sheet(paths, name, columns, thumb):
    w, h = thumb
    out = Image.new('RGB', (columns*w, ((len(paths)+columns-1)//columns)*(h+26)), '#eee7dc')
    draw = ImageDraw.Draw(out)
    for i, p in enumerate(paths):
        with Image.open(p) as im:
            im.thumbnail(thumb)
            x, y = (i % columns)*w, (i//columns)*(h+26)
            out.paste(im, (x+(w-im.width)//2, y))
            draw.text((x+4, y+h+4), p.stem, fill='#573018')
    target = ROOT / 'build/store-review' / name
    target.parent.mkdir(parents=True, exist_ok=True)
    out.save(target)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--sheets', action='store_true')
    args = parser.parse_args()
    check_inventory()
    for p in [*sorted((STORE/'screenshots').rglob('*.png')),
              *sorted(STORE.glob('feature-graphic*.png'))]:
        opaque_png(p, args.check)
    manifest = json.dumps(build_manifest(), ensure_ascii=False, indent=2)+'\n'
    if args.check:
        if not MANIFEST.exists() or MANIFEST.read_text(encoding='utf-8') != manifest:
            raise ValueError('Asset manifest stale; run python tool/store_assets.py')
    else:
        MANIFEST.write_text(manifest, encoding='utf-8')
    if args.sheets:
        for lang in LANGS:
            sheet([STORE/'screenshots'/lang/f'{name}.png' for name in PORTRAITS],
                  f'store-{lang}.png', 4, (270, 480))
            sheet([ROOT/'docs/screenshots'/lang/f'{name}.png' for name in EXTRA],
                  f'docs-{lang}.png', 5, (234, 507))
        sheet([STORE/'icon-512.png', *sorted(STORE.glob('feature-graphic*.png'))],
              'brand.png', 2, (512, 280))
    print('V2 assets verified: 32 store portraits, 29 documentation captures, localized graphics, Android resources; listing limits valid.')


if __name__ == '__main__':
    main()
