"""Menulis lib/game/render/design_svg_lane.dart dari desain Gang Depan.

Pakai: python tool/design/make_lane_svg.py docs/design/gang-depan/project lib/game/render/design_svg_lane.dart [--kitty lib/game/render/design_svg_home.dart]

Dengan --kitty, `kittySvg` dan `kittyKeyframes` di berkas itu juga ditulis
ulang dari `Kucing.dc.html` Gang Depan (Kumis, pose `endus`/`geser`).
"""
import json
import re
import sys

src, out = sys.argv[1], sys.argv[2]
kitty_out = sys.argv[sys.argv.index('--kitty') + 1] if '--kitty' in sys.argv else None


def text(name):
    return open(f'{src}/{name}.dc.html', encoding='utf-8').read().replace('\r\n', '\n')


def svgs(name):
    return [m.group(1) for m in re.finditer(r'<svg\b[^>]*>(.*?)</svg>', text(name), re.S)]


def svg_with(name, marker):
    """Isi <svg> di berkas [name] yang (termasuk tag <svg>-nya) memuat
    [marker]; harus tepat satu."""
    found = [
        m.group(2)
        for m in re.finditer(r'(<svg\b[^>]*>)(.*?)</svg>', text(name), re.S)
        if marker in m.group(0)
    ]
    assert len(found) == 1, (name, marker, len(found))
    return found[0]


def sc_if(name, value):
    """Isi blok `<sc-if value="{{value}}">` di berkas [name]; harus tepat satu."""
    found = re.findall(
        r'<sc-if value="\{\{' + value + r'\}\}"[^>]*>(.*?)</sc-if>', text(name), re.S)
    assert len(found) == 1, (name, value, len(found))
    return found[0]


def keyframes(*names):
    seen = {}
    for name in names:
        for line in re.findall(r'@keyframes [^\n]*', text(name)):
            key = line.split('{', 1)[0]
            seen.setdefault(key, line)
    return '\n'.join(seen.values())


def classes(names, files):
    """Deklarasi CSS kelas [names] dari blok <style> berkas [files]."""
    found = {}
    for name in files:
        for cls, body in re.findall(r'^\.([a-z0-9-]+)\{([^}]*)\}', text(name), re.M):
            if cls in names:
                found.setdefault(cls, body.replace(':', ': ').replace(';', '; ').strip())
    missing = [n for n in names if n not in found]
    assert not missing, missing
    return found


def door_data():
    m = re.search(r'const DATA = (\{.*?\});\n', text('PintuDepan'), re.S)
    assert m
    return json.loads(m.group(1))


def dart(value, indent=0):
    """Literal Dart dari nilai JSON (daftar, peta, angka, teks)."""
    pad = '  ' * indent
    if isinstance(value, dict):
        items = [f"{pad}  '{k}': {dart(v, indent + 1).lstrip()}," for k, v in value.items()]
        return pad + '{\n' + '\n'.join(items) + f'\n{pad}}}'
    if isinstance(value, list):
        if all(isinstance(v, (int, float)) for v in value):
            return pad + '[' + ', '.join(dart(v) for v in value) + ']'
        items = [dart(v, indent + 1) + ',' for v in value]
        return pad + '[\n' + '\n'.join(items) + f'\n{pad}]'
    if value is None:
        return pad + 'null'
    if isinstance(value, str):
        assert "'" not in value
        return pad + f"'{value}'"
    if isinstance(value, float) and value.is_integer():
        return pad + f'{value:.1f}'
    return pad + (f'{value}.0' if isinstance(value, int) else repr(value))


parts = [
    ('laneBackSvg', svgs('LatarGang')[0],
     'Latar gang: langit, rumah belakang, tanah, warung, depan rumah, dan pemandangan hangat di balik pintu pulang (`LatarGang.dc.html`).'),
    ('laneFloorLightSvg', svgs('CahayaGang')[0],
     'Cahaya gang di tanah, di bawah kucing (`CahayaGang.dc.html`, `lantai`).'),
    ('laneAirLightSvg', svgs('CahayaGang')[1],
     'Cahaya gang di udara dan kupu-kupu (`{{kupu}}`), di atas kucing (`CahayaGang.dc.html`, `udara`).'),
    ('laneFrameSvg', svgs('KusenGang')[0],
     'Kusen depan pintu pulang di gang, di atas kucing yang lewat (`KusenGang.dc.html`).'),
    ('livingFrontFrameSvg', svgs('KusenDepan')[0],
     'Kusen depan pintu depan ruang tengah (`KusenDepan.dc.html`).'),
    ('benchBackSvg', svgs('Bangku')[0],
     'Bangku gang lapis belakang: kaki belakang dan dudukan (`Bangku.dc.html`, `belakang`).'),
    ('benchFrontSvg', svgs('Bangku')[1],
     'Bangku gang lapis depan: tepi dudukan dan kaki depan (`Bangku.dc.html`, `depan`).'),
]
small = [
    ('laneMarkerSvg', svgs('PenandaGang')[0], '0 0 48 52',
     'Penanda "Oyen di gang" di dekat pintu depan (`PenandaGang.dc.html`).'),
    ('kumisTailSvg', svg_with('AdeganTengah', 'ek-goyang'), '0 0 390 652',
     'Ekor Kumis di pintu kucing ruang tengah, goyang `ekGoyang` di sekitar pangkalnya (46,2, 426,2) (`AdeganTengah.dc.html`).'),
    ('seruSvg', svg_with('AdeganTengah', 'at-seru'), '0 0 24 30',
     'Gelembung "!" di atas Oyen saat menyadari ekor (`AdeganTengah.dc.html`).'),
    ('lanePuffSvg', sc_if('AdeganGang', 'puff'), '0 0 390 652',
     'Kepulan kecil di antara hidung Oyen dan Kumis saat mengendus di bangku (`AdeganGang.dc.html`, `temuD`).'),
]

lane_classes = classes(
    ['rm-awan', 'gg-awan2', 'rm-daun', 'gg-daun2', 'rm-denyut', 'gg-ayun',
     'gg-kibar', 'gg-kupu', 'gg-kupu2', 'gg-sayap', 'pg-bob', 'ek-goyang',
     'at-seru'],
    ['CahayaGang', 'PenandaGang', 'AdeganTengah'],
)

lines = [
    '// Isi <svg> desain Gang Depan (docs/design/gang-depan/project), disalin',
    '// utuh. Jangan diketik ulang: tulis ulang dengan',
    '// tool/design/make_lane_svg.py. Dijaga design_sync_test.',
    '',
    'library;',
    '',
]
# Tepi dibuang: Dart membuang baris pertama string tiga kutip yang kosong,
# jadi isi yang diawali baris baru tidak bisa disalin persis.
parts = [(name, body.strip(), doc) for name, body, doc in parts]
small = [(name, body.strip(), box, doc) for name, body, box, doc in small]
for name, body, doc in parts:
    assert "'''" not in body
    lines += [f'/// {doc} viewBox 0 0 390 652.', f"const {name} = r'''{body}''';", '']
for name, body, box, doc in small:
    assert "'''" not in body
    lines += [f'/// {doc} viewBox {box}.', f"const {name} = r'''{body}''';", '']

lines += [
    '/// `@keyframes` lapisan gang, penanda, ekor, dan "!".',
    f"const laneKeyframesCss = r'''{keyframes('CahayaGang', 'PenandaGang', 'AdeganTengah')}''';",
    '',
    '/// Kelas animasi lapisan gang (deklarasi CSS desain).',
    'const laneClassStyles = {',
]
for cls, body in lane_classes.items():
    lines.append(f"  '{cls}': '{body}',")
lines += [
    '};',
    '',
    '/// Data daun pintu depan dan pintu pulang (`PintuDepan.dc.html`, `DATA`):',
    '/// `E` = poligon daun (`f` `d` sisi dalam, `l` sisi luar; `p` titik',
    '/// (u, v) 0–1 dari engsel dan atas; `h` lubang pintu kucing), `FL` =',
    '/// poligon daun pintu kucing (a, b 0–1).',
    f'const doorLeafData = {dart(door_data()).lstrip()};',
    '',
]
open(out, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines))
print('ok')


def replace_const(dart_text, name, body):
    """Ganti isi `const [name] = r'''...''';` dengan [body]."""
    head = f"const {name} = r'''"
    start = dart_text.index(head) + len(head)
    end = dart_text.index("''';", start)
    assert "'''" not in body
    return dart_text[:start] + '\n' + body + '\n' + dart_text[end:]


if kitty_out:
    kucing = text('Kucing')
    inner = re.search(r'<svg\b[^>]*>\n(.*?)\n\s*</svg>', kucing, re.S).group(1)
    frames = '\n'.join(re.findall(r'@keyframes [^\n]*', kucing))
    home = open(kitty_out, encoding='utf-8').read()
    home = replace_const(home, 'kittySvg', inner)
    home = replace_const(home, 'kittyKeyframes', frames)
    open(kitty_out, 'w', encoding='utf-8', newline='\n').write(home)
    print('ok kitty')
