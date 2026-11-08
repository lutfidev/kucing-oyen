"""Original v2 vector artwork. Python stdlib only; run from any directory."""
import argparse
import io
import json
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'assets/art/v2'
INK = '#573018'
CREAM = '#FFF4E2'
WOOD = '#E9AE60'
ORANGE = '#FF982E'
GREEN = '#769954'
files = {}
entries = {}


def path(d, fill='none', stroke=INK, sw=2.4):
    return f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"/>'


def oval(x, y, rx, ry, fill, stroke=INK, sw=2.4):
    return f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"/>'


def rect(x, y, w, h, fill, r=4, stroke=INK, sw=2.4):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"/>'


def group(s, transform):
    return f'<g transform="{transform}">{s}</g>'


def asset(key, content, w=128, h=128, pivot=(64, 116), **meta):
    filename = key + '.svg'
    files[filename] = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'
                       f'<g stroke-linecap="round" stroke-linejoin="round">{content}</g></svg>\n').encode()
    entries[key] = dict(file=filename, width=w, height=h, pivot=list(pivot), **meta)


# New shapes and warm palettes, preserving the catalogue identities only.
# fur, muzzle/belly, pattern, iris, ear. Dark cats use light eye contours.
cats = {
    'oyen': ('#FFB24D', '#FFF0CC', '#CE6D24', '#573018', '#FFBCAD'),
    'salju': ('#FFFCF3', '#FFFFFF', '#E5D8C8', '#70A6CD', '#F4B5B6'),
    'telon': ('#FFF8E8', '#FFFCF3', '#E78B3C', '#573018', '#F4B5B6'),
    'arang': ('#49413E', '#62534A', '#302C2B', '#DDB94D', '#BD8D91'),
    'mendung': ('#A6AAA8', '#E7E6DB', '#737A79', '#83A66A', '#ECC0B5'),
    'kopiSusu': ('#D7AF82', '#FFF0D4', '#A37951', '#573018', '#EBB7A0'),
    'mochi': ('#F2E5CC', '#8B6853', '#70513F', '#8ABCDD', '#BA9486'),
    'bos': ('#3C3635', '#FFFAEB', '#FFFAEB', '#ADCB75', '#BD8D91'),
    'kembang': ('#514039', '#87604A', '#D8893D', '#DFB94F', '#B67F73'),
}
anchors = dict(headTop=[64, 34], headSideLeft=[38, 46],
               headSideRight=[90, 46], face=[64, 65], neck=[64, 86])
for name, (fur, muzzle, stripe, eye, ear) in cats.items():
    dark = name in ('arang', 'bos', 'kembang')
    eye_line = '#FFF1D8' if dark else INK
    body = path('M42 77 Q36 85 37 104 Q37 115 51 116 L80 116 Q94 114 90 98 Q88 79 78 76 Z', fur)
    body += oval(64, 99, 17, 16, muzzle, 'none')
    if name in ('oyen', 'mendung'):
        body += path('M40 89 L49 93 M39 98 L47 101 M87 88 L80 93', stroke=stripe, sw=4)
    if name in ('telon', 'kembang'):
        body += oval(80, 94, 9, 11, stripe, 'none') + oval(45, 106, 6, 7, '#4B3B33' if name == 'telon' else '#A56F46', 'none')
    asset(f'cats/{name}-body', body)
    rear = path('M42 77 Q36 85 37 104 Q37 115 51 116 L80 116 Q94 114 90 98 Q88 79 78 76 Z', fur)
    if name in ('oyen', 'mendung', 'kopiSusu'):
        rear += path('M57 84 L60 91 M70 84 L67 91', stroke=stripe, sw=3)
    if name in ('telon', 'kembang'):
        rear += oval(52, 88, 11, 10, stripe, 'none') + oval(78, 105, 8, 9, '#4B3B33' if name == 'telon' else '#A56F46', 'none')
    asset(f'cats/{name}-body-back', rear)
    tail = path('M85 104 C110 112 120 91 109 79 C104 74 97 79 102 85 C110 95 102 102 89 97 Z', fur)
    tail += path('M108 80 Q106 83 110 88', stroke=stripe, sw=5)
    asset(f'cats/{name}-tail', tail)
    paw = oval(53, 112, 10, 5, muzzle if name in ('bos', 'mochi') else fur)
    paw += path('M51 111 L51 114 M55 111 L55 114', stroke=INK, sw=1)
    asset(f'cats/{name}-paw', paw)
    # Ears belong to the head; each expression shares the same attachment space.
    base = path('M31 53 Q24 38 31 29 Q42 30 49 40 Q64 35 79 40 Q89 26 98 31 Q101 41 97 55 Q108 74 92 84 Q65 98 37 84 Q21 75 31 53 Z', fur)
    base += path('M32 36 L36 50 L44 43 Z', stripe if name == 'mochi' else ear, 'none')
    base += path('M94 36 L83 44 L94 50 Z', stripe if name == 'mochi' else ear, 'none')
    markings = ''
    if name in ('oyen', 'mendung', 'kopiSusu'):
        markings += path('M51 42 L56 51 M63 40 L65 49 M76 42 L73 51 M31 63 L39 66 M97 63 L89 66', stroke=stripe, sw=4)
    if name in ('telon', 'kembang'):
        markings += path('M31 53 Q29 38 34 32 Q45 32 53 43 Q57 62 42 63 Z', stripe, 'none')
        markings += path('M81 42 Q91 30 96 32 L98 55 Q86 64 80 53 Z', '#4B3B33' if name == 'telon' else '#A66A42', 'none')
    if name == 'mochi':
        markings += path('M35 53 Q46 48 60 59 Q65 62 70 58 Q86 48 96 56 Q104 77 85 85 L43 84 Q25 74 35 53 Z', stripe, 'none')
    if name == 'bos':
        markings += path('M64 46 Q62 64 48 77 Q63 89 81 77 Q67 66 64 46 Z', muzzle, 'none')
    if name == 'kembang':
        markings += oval(41, 75, 8, 5, stripe, 'none')
    for expr in ('open', 'closed', 'happy', 'startled', 'tired', 'back', 'side', 'closed-side', 'happy-side', 'startled-side', 'tired-side'):
        side = expr == 'side' or expr.endswith('-side')
        mood = expr.split('-')[0]
        face = ''
        if expr == 'back':
            if name in ('oyen', 'mendung', 'kopiSusu'):
                face = path('M50 56 L55 65 M64 53 L64 63 M78 56 L74 65', stroke=stripe, sw=4)
            elif name in ('telon', 'kembang'):
                face = oval(44, 51, 13, 11, stripe, 'none') + oval(83, 65, 10, 9, '#4B3B33' if name == 'telon' else '#A56F46', 'none')
        else:
            face += oval(42 if side else 64, 77, 14 if side else 16, 9 if side else 10, muzzle, 'none')
            ex1, ex2 = (44, 65) if side else (48, 80)
            if mood in ('closed', 'happy', 'tired'):
                cy = 60 if mood == 'happy' else 70
                for ex in (ex1, ex2):
                    face += path(f'M{ex-5} 65 Q{ex} {cy} {ex+5} 65', stroke=eye_line, sw=2.5)
                    if mood == 'tired':
                        face += path(f'M{ex-5} 60 L{ex+5} 62', stroke=eye_line, sw=1.5)
            else:
                ry = 6 if mood == 'startled' else 4.4
                face += oval(ex1, 66, 3.8, ry, eye, eye_line, 1.3) + oval(ex2, 66, 3.8, ry, eye, eye_line, 1.3)
                face += oval(ex1-1, 64, 1, 1, CREAM, 'none') + oval(ex2-1, 64, 1, 1, CREAM, 'none')
            nx = 43 if side else 64
            face += path(f'M{nx-3} 74 Q{nx} 71 {nx+3} 74 L{nx} 77 Z', '#BD7068', 'none')
            if mood == 'startled':
                face += oval(nx, 82, 2.5, 3.6, INK, 'none')
            else:
                face += path(f'M{nx} 77 Q{nx} 83 {nx-6} 80 M{nx} 77 Q{nx} 83 {nx+6} 80', stroke=CREAM if name in ('mochi', 'kembang', 'arang') else INK, sw=1.6)
            face += path('M30 72 L38 74 M29 77 L37 78 M91 74 L99 72 M92 78 L100 77', stroke=eye_line, sw=1.2)
        asset(f'cats/{name}-head-{expr}', base + ('' if expr == 'back' else markings) + face, anchors=anchors)

# Each accessory has a drawing-space pivot (50,45); target supplied by the rig.
accessories = {
    'pita': ('headSideRight', path('M50 45 Q24 24 26 45 Q26 64 50 45 Q76 24 74 45 Q74 64 50 45 Z', '#D96E62') + oval(50, 45, 5, 5, '#EFA28B')),
    'jepitBunga': ('headSideLeft', ''.join(oval(x, y, 7, 7, '#F3BC74') for x, y in [(42, 40), (50, 35), (58, 40), (55, 49), (45, 49)]) + oval(50, 43, 5, 5, '#D38951')),
    'bandana': ('neck', path('M26 40 Q50 51 74 40 L53 66 Z', GREEN) + oval(53, 51, 3, 3, CREAM, 'none')),
    'dasiKupu': ('neck', path('M50 45 L29 34 Q24 45 29 56 Z M50 45 L71 34 Q76 45 71 56 Z', '#D58954') + oval(50, 45, 5, 5, '#F4C88C')),
    'kalung': ('neck', path('M26 40 Q50 56 74 40', stroke='#BC6A59', sw=6) + oval(50, 54, 7, 7, '#E7B14B') + path('M50 53 L50 57', sw=1)),
    'syal': ('neck', path('M28 39 Q50 51 72 39 L75 48 Q62 58 50 53 L62 62 L48 65 L38 52 Q31 52 26 47 Z', '#93A79A')),
    'beanie': ('headTop', path('M25 45 Q26 18 50 18 Q74 18 75 45 Z', '#D38C71') + rect(22, 40, 56, 12, '#EAA88E') + oval(50, 15, 7, 7, '#EAA88E')),
    'topiKoki': ('headTop', path('M30 44 L28 29 Q16 24 25 15 Q33 9 41 17 Q50 4 59 17 Q76 6 80 22 Q80 30 72 32 L70 44 Z', CREAM) + rect(28, 40, 44, 12, '#F1DABD')),
    'baret': ('headTop', oval(48, 35, 29, 13, '#8A9C75') + rect(30, 43, 39, 8, '#6D805C') + path('M50 23 L54 15', stroke='#6D805C', sw=5)),
    'kacamata': ('face', oval(32, 45, 14, 12, '#C2E2E7', sw=3) + oval(68, 45, 14, 12, '#C2E2E7', sw=3) + path('M46 43 Q50 39 54 43 M18 42 L11 39 M82 42 L89 39', sw=3)),
    'headphone': ('headTop', path('M18 65 L18 43 Q18 12 50 12 Q82 12 82 43 L82 65', stroke='#7C8D9B', sw=9) + rect(10, 49, 16, 24, '#D99572') + rect(74, 49, 16, 24, '#D99572')),
    'tandukRusa': ('headTop', path('M33 48 L26 29 L20 10 M26 28 L12 21 M26 28 L34 17 M67 48 L74 29 L80 10 M74 28 L88 21 M74 28 L66 17', stroke='#A8784C', sw=6) + path('M27 48 Q50 39 73 48', stroke='#D69164', sw=5)),
    'topiPesta': ('headTop', path('M29 46 L50 7 L72 46 Z', '#ECA06D') + path('M36 33 L62 29 M43 20 L56 17', stroke=CREAM, sw=4) + oval(50, 7, 5, 5, '#F5CF78')),
    'topiPenyihir': ('headTop', path('M30 45 Q38 24 48 7 Q57 7 69 16 L58 18 L71 45 Z', '#8B809E') + oval(50, 47, 34, 7, '#A396B0') + path('M38 35 L64 35', stroke='#F2CB7F', sw=5)),
    'mahkota': ('headTop', path('M25 47 L22 24 L39 34 L50 17 L61 34 L78 24 L75 47 Z', '#EFC560') + rect(25, 43, 50, 9, '#DAA94D') + oval(50, 39, 4, 5, '#D77C65')),
    'mahkotaRaja': ('headTop', path('M24 45 Q23 15 50 15 Q77 15 76 45 Z', '#C97968') + path('M30 45 L23 25 L40 35 L50 17 L60 35 L77 25 L70 45 Z', '#E8BB59') + rect(22, 43, 56, 12, CREAM) + oval(50, 36, 4, 5, '#7FA1A5')),
}
for name, (anchor, art) in accessories.items():
    asset(f'accessories/{name}', art, 100, 80, (50, 45), anchor=anchor)
asset('accessories/kacamata-back', path('M12 43 Q50 32 88 43', stroke=INK, sw=3), 100, 80, (50, 45), anchor='face')
asset('accessories/kalung-back', path('M26 40 Q50 56 74 40', stroke='#BC6A59', sw=6), 100, 80, (50, 45), anchor='neck')
asset('accessories/dasiKupu-back', path('M26 40 Q50 56 74 40', stroke='#D58954', sw=6), 100, 80, (50, 45), anchor='neck')
asset('accessories/bandana-back', path('M26 40 Q50 54 74 40 L72 49 Q50 61 28 49 Z', GREEN), 100, 80, (50, 45), anchor='neck')

# Furniture is separated into back and front masks for cat occlusion.
furniture = {}
furniture['tikus'] = (oval(63, 95, 27, 13, '#B7B0A7') + oval(70, 81, 8, 9, '#D7B1AA') + path('M36 95 Q10 80 15 105', stroke='#B3887D', sw=3) + oval(85, 93, 2, 2, INK, 'none'), '')
furniture['akuarium'] = (rect(24, 29, 80, 74, '#ABD6DB', 12) + path('M27 49 Q49 44 65 49 Q84 54 101 49', stroke=CREAM, sw=2) + path('M42 89 Q38 74 47 63 M88 92 Q96 74 87 63', stroke=GREEN, sw=5) + oval(65, 70, 12, 7, ORANGE) + path('M76 70 L85 63 L85 77 Z', ORANGE), rect(21, 98, 86, 13, WOOD) + path('M33 40 L33 65', stroke=CREAM, sw=3))
furniture['rumah'] = (rect(25, 45, 80, 66, '#EDB57D', 8) + path('M15 49 L64 14 L114 49 Z', '#D28A59') + path('M43 111 L43 83 Q64 49 85 83 L85 111 Z', '#76523C'), path('M25 109 L105 109', stroke=WOOD, sw=6))
furniture['kasur'] = (oval(64, 88, 52, 24, '#DFA565') + oval(64, 83, 44, 18, CREAM), path('M12 86 Q64 117 116 86 L114 103 Q64 131 14 103 Z', '#E7B777') + path('M25 101 Q64 116 104 102', stroke='#F7D59B', sw=2))
furniture['catnip'] = (rect(43, 83, 43, 28, '#D3946B') + path('M64 88 L64 42 M64 72 Q29 75 39 54 Q55 51 64 68 M65 58 Q91 61 90 38 Q69 35 65 58', GREEN), '')
furniture['jam'] = (rect(42, 24, 45, 73, '#DDA96D') + oval(64, 48, 25, 25, CREAM) + path('M64 32 L64 48 L77 53 M64 78 L64 99', sw=3) + oval(64, 100, 8, 8, WOOD), '')
furniture['kardus'] = (rect(24, 60, 80, 49, '#C9995F') + path('M24 60 L39 44 L116 46 L104 60 Z M24 60 L12 46 L33 39 L43 55 Z', '#E7BA81'), rect(24, 83, 80, 28, '#D7A56A') + path('M26 84 L63 91 L102 84 M64 92 L64 110', stroke='#996F42', sw=2))
furniture['bola'] = (oval(64, 85, 25, 25, '#E99B9F') + path('M43 73 Q72 67 82 95 M48 104 Q78 85 63 60 M39 87 Q64 92 88 79', stroke='#AD6770', sw=2), '')
furniture['karpet'] = (oval(64, 91, 59, 23, '#EDD5A6') + oval(64, 91, 52, 17, '#FFF0CD', '#CDA779', 1.6) + path('M19 90 Q26 86 32 90 M89 96 Q97 91 105 96', stroke='#EDD5A6', sw=2), '')
furniture['tiang'] = (rect(18, 102, 94, 10, '#D59964') + rect(54, 24, 20, 79, '#EBD1A0') + ''.join(path(f'M55 {y} L73 {y-5}', stroke='#B58B5A', sw=1.4) for y in range(36, 99, 7)) + rect(34, 18, 60, 12, WOOD), '')
furniture['lukisan'] = (rect(20, 23, 88, 79, WOOD) + rect(28, 31, 72, 63, CREAM) + path('M42 55 L44 43 L55 51 Q64 48 73 51 L83 43 L86 57 Q93 81 65 84 Q37 82 42 55 Z', ORANGE) + path('M52 65 Q56 61 59 65 M71 65 Q75 61 78 65 M61 74 Q65 79 69 74', sw=1.8), '')
furniture['rak'] = (''.join(rect(22+i*16, 49-(i%2)*8, 12, 42+(i%2)*8, c, 2) for i, c in enumerate(['#C9805C', '#7A9F99', '#E9BD65', '#8B9E6B', '#D6A37A'])) + rect(15, 91, 100, 12, WOOD), '')
furniture['pancingan'] = (path('M22 111 L70 28', stroke='#C48B57', sw=6) + path('M70 28 Q111 36 94 82', stroke='#B59B79', sw=1.5) + path('M94 80 Q116 80 103 101 Q87 105 88 92 Z', '#C78A86'), '')
furniture['lampuBulan'] = (path('M86 30 C34 11 21 94 77 103 C58 85 52 58 86 30 Z', '#F4CE75') + path('M45 57 Q39 74 49 85', stroke=CREAM, sw=3), '')
furniture['bantalIkan'] = (path('M20 87 L9 67 L9 108 Z M20 87 C34 55 100 54 115 85 C102 114 34 117 20 87 Z', '#A3BCB0') + oval(98, 82, 2, 2, INK, 'none') + path('M66 69 Q48 87 66 104', stroke='#7C9788', sw=2), '')
furniture['monstera'] = (path('M61 91 L67 29 M64 68 Q31 65 30 42 Q53 24 64 58 M66 48 Q80 18 101 36 Q103 61 66 63 M62 82 Q27 89 24 68 Q44 49 62 77', GREEN) + path('M38 44 L57 58 M91 38 L73 52 M33 70 L54 77', stroke='#A6BA6F', sw=2) + path('M39 89 L90 89 L83 114 L46 114 Z', '#D89D70'), '')
furniture['terowongan'] = (rect(25, 61, 81, 48, '#C59A83', 22) + oval(101, 85, 20, 24, '#E0B69B') + oval(101, 85, 14, 18, '#7A5745'), path('M45 64 Q32 86 45 107 M67 63 Q55 85 67 108', stroke='#EBC6AA', sw=3))
furniture['hammock'] = (path('M20 34 L20 93 M108 34 L108 93', stroke=WOOD, sw=7) + path('M23 65 Q64 94 105 65 L101 91 Q64 117 27 91 Z', '#E5B99E'), path('M23 65 Q64 99 105 65', stroke=CREAM, sw=5))
furniture['sofaMini'] = (rect(19, 50, 91, 50, '#B6BF95', 18) + rect(13, 82, 103, 28, '#C6CEA9', 10) + rect(11, 70, 18, 36, '#A3B17F', 8) + rect(99, 70, 18, 36, '#A3B17F', 8), path('M23 109 L23 117 M105 109 L105 117', stroke=WOOD, sw=7))
furniture['jendelaBurung'] = (rect(22, 21, 85, 87, WOOD) + rect(29, 28, 71, 73, '#B9DBE2') + oval(75, 72, 12, 9, '#E1B562') + path('M86 70 L94 73 L86 76 Z', '#D08545') + oval(79, 69, 1.5, 1.5, INK, 'none') + path('M31 88 Q64 76 101 88', stroke=GREEN, sw=6), path('M64 29 L64 99 M30 63 L99 63', stroke=WOOD, sw=5) + rect(15, 102, 99, 10, WOOD))
furniture['mangkuk'] = (oval(64, 83, 43, 15, '#EEB871') + oval(64, 81, 32, 9, '#90603B') + ''.join(oval(x, y, 3, 2, '#D6A45B', 'none') for x, y in [(43, 80), (52, 78), (63, 82), (76, 79), (83, 83), (57, 86)]), path('M21 83 L27 107 Q64 118 101 107 L107 83 Q64 104 21 83 Z', ORANGE) + oval(64, 105, 4, 3, CREAM, 'none') + oval(59, 100, 2, 2, CREAM, 'none') + oval(68, 99, 2, 2, CREAM, 'none'))
for name, (back, front) in furniture.items():
    for layer, art in [('back', back), ('front', front)]:
        asset(f'items/{name}-{layer}', art, interaction=[64, 86], footY=116,
              layer=layer, occludes=bool(front))

# Layered 390-square rooms. No text, interactive furniture baked into decor,
# bathtub, or additional functional food bowls.
for area, wall in [('santai', '#FFE5BE'), ('makan', '#F9E5C5'), ('main', '#F9DFC4'), ('rawat', '#F6E8CF')]:
    wallpaper = rect(0, 0, 390, 260, wall, 0, 'none')
    wallpaper += ''.join(rect(x, 0, 12, 260, '#FFF2D9', 0, 'none') for x in range(8, 390, 28))
    wallpaper += rect(123, 42, 144, 144, '#BE8A53', 8) + rect(131, 50, 128, 128, '#A4D4E5', 3)
    wallpaper += path('M134 146 Q154 108 183 147 Q216 104 257 149 L257 177 L134 177 Z', '#A7B76A', 'none')
    wallpaper += oval(170, 78, 21, 8, CREAM, 'none') + path('M195 50 L195 176 M131 116 L259 116', stroke='#BE8A53', sw=7)
    wallpaper += path('M113 40 Q135 49 149 42 Q149 99 126 128 Q112 92 113 40 Z M277 40 Q255 49 241 42 Q241 99 264 128 Q278 92 277 40 Z', CREAM, '#B88B5C', 2)
    wallpaper += path('M126 127 L115 180 Q132 187 143 177 L132 126 Z M264 127 L275 180 Q258 187 247 177 L258 126 Z', CREAM, '#B88B5C', 2)
    wallpaper += path('M116 124 L136 127 M254 127 L274 124', stroke='#DB975D', sw=6)
    asset(f'rooms/{area}-wall', wallpaper, 390, 390, (0, 0), layer='wall')
    floor = rect(0, 257, 390, 133, WOOD, 0, 'none')
    for y in range(263, 390, 22):
        floor += path(f'M0 {y} L390 {y}', stroke='#C58A4B', sw=1.3)
        for x in range((y//22 % 2)*45, 390, 90):
            floor += path(f'M{x} {y} L{x+7} {y+22}', stroke='#CC975B', sw=1)
    floor += rect(0, 251, 390, 9, '#C58E57', 0, '#B78551', 1)
    asset(f'rooms/{area}-floor', floor, 390, 390, (0, 0), layer='floor')
    if area == 'santai':
        decor = group(furniture['rak'][0], 'translate(6 69) scale(0.86)')
        decor += rect(18, 197, 87, 60, '#C89359') + rect(25, 205, 33, 44, '#F0C386') + rect(64, 205, 33, 44, '#F6D9A6') + path('M77 225 L86 225', sw=3)
        decor += group(furniture['lukisan'][0], 'translate(286 70) scale(0.65)')
    elif area == 'makan':
        decor = rect(15, 192, 97, 65, '#C99A64') + rect(21, 200, 40, 49, '#E4BC82') + rect(65, 200, 40, 49, '#E4BC82') + path('M54 218 L54 228 M72 218 L72 228', sw=2)
        decor += rect(11, 184, 105, 10, '#E8B774') + rect(33, 150, 37, 33, '#F7D49C') + rect(31, 145, 41, 9, '#D39860')
        decor += group(furniture['rak'][0], 'translate(294 73) scale(0.65)')
    elif area == 'main':
        decor = rect(18, 198, 84, 59, '#D1AA73') + rect(25, 207, 70, 42, '#F1D4A2') + path('M25 207 L95 249 M95 207 L25 249', stroke='#C7A374', sw=1.5)
        decor += group(furniture['pancingan'][0], 'translate(299 124) scale(0.75)')
    else:
        decor = rect(13, 210, 98, 13, WOOD) + rect(26, 194, 60, 15, '#E9B6A4') + rect(30, 181, 60, 13, CREAM) + rect(26, 167, 60, 14, '#A5BAAC')
        decor += rect(306, 204, 66, 52, '#D5AF7C') + rect(315, 188, 47, 16, CREAM) + path('M322 192 L352 192', stroke='#CFBFA5', sw=1.4)
        # Brush is passive decor; the interaction layer is supplied by the app.
        decor += rect(321, 157, 9, 30, WOOD) + rect(312, 144, 27, 18, '#E5BF8D') + path('M315 142 L315 149 M321 142 L321 149 M327 142 L327 149 M333 142 L333 149', sw=1.4)
    asset(f'rooms/{area}-decor', decor, 390, 390, (0, 0), layer='decor')

manifest = dict(version=2, source='tool/art_v2/generate.py', license='Original project artwork; see LICENSE.txt',
                canvas=[128, 128], headAnchors=anchors, assets=entries,
                animation=dict(walkFrames=8, walkSeconds=0.8, reactionFrames=4, cache='finite static parts; no frame cache'))
files['manifest.json'] = (json.dumps(manifest, indent=2, ensure_ascii=False) + '\n').encode()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    stale = []
    for rel, data in files.items():
        dest = OUT / rel
        if args.check:
            if not dest.exists() or dest.read_bytes() != data:
                stale.append(rel)
        else:
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(data)
    unexpected = {str(p.relative_to(OUT)).replace('\\', '/') for p in OUT.rglob('*.svg')} - files.keys()
    if stale or unexpected:
        raise SystemExit(f'Stale/missing: {stale}; unexpected SVG: {sorted(unexpected)}')
    packed = io.BytesIO()
    with zipfile.ZipFile(packed, 'w', zipfile.ZIP_DEFLATED) as archive:
        for rel, data in sorted(files.items()):
            archive.writestr(rel, data)
    print(json.dumps(dict(assets=len(entries), sourceBytes=sum(map(len, files.values())),
                          zipBytes=len(packed.getvalue()), decodedRasterBytes=0, atlasPages=0)))


if __name__ == '__main__':
    main()
