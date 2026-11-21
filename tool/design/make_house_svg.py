"""Menulis lib/game/render/design_svg_house.dart dari desain rumah dua ruangan.

Pakai: python tool/design/make_house_svg.py docs/design/rumah-dua-ruangan/project lib/game/render/design_svg_house.dart
"""
import re
import sys

src, out = sys.argv[1], sys.argv[2]


def svgs(name):
    text = open(f'{src}/{name}.dc.html', encoding='utf-8').read().replace('\r\n', '\n')
    return [m.group(1) for m in re.finditer(r'<svg\b[^>]*>(.*?)</svg>', text, re.S)]


def keyframes(name):
    text = open(f'{src}/{name}.dc.html', encoding='utf-8').read()
    return '\n'.join(re.findall(r'@keyframes [^\n]*', text))


parts = [
    ('houseLivingBackSvg', 'LatarTengah', 0, 'Latar ruang tengah: dinding, lantai, jendela, dan teras lewat pintu (`LatarTengah.dc.html`).'),
    ('houseLivingFloorLightSvg', 'CahayaTengah', 0, 'Cahaya ruang tengah di lantai, di bawah kucing (`CahayaTengah.dc.html`, `lantai`).'),
    ('houseLivingAirLightSvg', 'CahayaTengah', 1, 'Cahaya ruang tengah di udara, di atas kucing (`CahayaTengah.dc.html`, `udara`).'),
    ('houseLivingFrameSvg', 'KusenTengah', 0, 'Kusen pintu depan ruang tengah, di atas kucing yang lewat (`KusenTengah.dc.html`).'),
    ('houseTerraceBackSvg', 'LatarTeras', 0, 'Latar teras: atap, kebun, pagar, dan ruang tengah lewat pintu (`LatarTeras.dc.html`).'),
    ('houseTerraceFloorLightSvg', 'CahayaTeras', 0, 'Cahaya teras di lantai (`CahayaTeras.dc.html`, `lantai`).'),
    ('houseTerraceAirLightSvg', 'CahayaTeras', 1, 'Cahaya teras di udara (`CahayaTeras.dc.html`, `udara`).'),
    ('houseTerraceFrameSvg', 'KusenTeras', 0, 'Kusen pintu depan teras (`KusenTeras.dc.html`).'),
]

lines = [
    '// Isi <svg> desain rumah dua ruangan (docs/design/rumah-dua-ruangan/project),',
    '// disalin utuh. Jangan diketik ulang: tulis ulang dengan',
    '// tool/design/make_house_svg.py. Dijaga design_sync_test.',
    '',
    'library;',
    '',
]
for name, file, index, doc in parts:
    body = svgs(file)[index]
    assert "'''" not in body
    lines += [f'/// {doc} viewBox 0 0 390 652.', f"const {name} = r'''{body}''';", '']

lines += [
    '/// `@keyframes` lapisan rumah (sama di keenam berkas).',
    f"const houseKeyframesCss = r'''{keyframes('LatarTengah')}''';",
    '',
    '/// Kelas animasi lapisan rumah (`.rm-awan`, `.rm-daun`, `.rm-denyut`).',
    'const houseClassStyles = {',
    "  'rm-awan': 'animation: rmAwan 16s ease-in-out infinite alternate',",
    "  'rm-daun':",
    "      'transform-box: fill-box; transform-origin: 50% 100%; '",
    "      'animation: rmDaun 3.6s ease-in-out infinite',",
    "  'rm-denyut': 'animation: rmDenyut 5s ease-in-out infinite',",
    '};',
    '',
]
open(out, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines))
print('ok')
