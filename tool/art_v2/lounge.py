"""Original vector lounge architecture, kept separate from owned furniture."""

INK = '#88542F'


def p(d, fill='none', stroke=INK, width=2):
    return f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{width}"/>'


def r(x, y, w, h, fill, radius=4, stroke=INK, width=2):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{radius}" fill="{fill}" stroke="{stroke}" stroke-width="{width}"/>'


def e(x, y, rx, ry, fill, stroke='none', width=1):
    return f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{fill}" stroke="{stroke}" stroke-width="{width}"/>'


def leaf(x, y, angle, scale=1):
    art = p('M0 0 C-19 -1 -20 -19 -9 -20 C3 -20 7 -8 0 0 Z', '#8EA75E', '#678448', 1.2)
    art += p('M0 0 L-9 -13', stroke='#B9C883', width=1)
    return f'<g transform="translate({x} {y}) rotate({angle}) scale({scale})">{art}</g>'


def lounge_layers():
    wall = r(0, 0, 390, 260, '#FFE5BF', 0, 'none')
    for x in range(-9, 390, 29):
        wall += r(x, 0, 13, 258, '#FFF0D6', 0, 'none')
        wall += p(f'M{x+14} 0 L{x+14} 256', stroke='#F7DAB1', width=.7)
    wall += r(0, 0, 390, 8, '#FFF2D8', 0, 'none')
    wall += '<g opacity="0.12">' + r(121, 44, 157, 165, '#7A482B', 11, 'none') + '</g>'
    wall += r(120, 38, 150, 161, '#D19A58', 9) + r(126, 44, 138, 149, '#F7CE8B', 6)
    wall += r(131, 49, 128, 138, '#A8D8E9', 4, '#A87645', 1.4)
    wall += p('M132 143 Q154 118 178 145 Q215 105 258 144 L258 186 L132 186 Z', '#B9C889', 'none')
    wall += p('M132 165 Q171 136 207 157 Q235 145 258 159 L258 186 L132 186 Z', '#8FA86B', 'none')
    wall += e(161, 77, 15, 6, '#FFF8E6') + e(176, 78, 18, 5, '#FFF8E6') + e(232, 104, 15, 5, '#EDF7F1')
    wall += '<g opacity="0.34">' + p('M139 53 L165 53 L133 111 L133 84 Z M230 53 L253 53 L187 183 L165 183 Z', '#FFFFFF', 'none') + '</g>'
    wall += p('M194 49 L194 186 M132 116 L258 116', stroke='#AB7943', width=6)
    wall += p('M192 49 L192 186 M132 113 L258 113', stroke='#F5D39C', width=2)
    wall += r(116, 192, 159, 9, '#BD874C', 4) + p('M121 194 L269 194', stroke='#F4CE94', width=2)
    wall += p('M110 35 L281 35', stroke='#8F5B34', width=5)
    wall += e(107, 35, 5, 6, '#D79D5B', INK) + e(284, 35, 5, 6, '#D79D5B', INK)
    for mirror in [False, True]:
        curtain = p('M115 36 Q132 41 151 36 Q153 87 132 132 L144 194 Q128 203 110 194 L121 133 Q108 92 115 36 Z', '#FFF6DC', '#BA8B58', 1.7)
        curtain += p('M122 44 Q120 84 126 118 M137 45 Q137 84 130 113 M123 145 L118 189 M133 145 L138 192', stroke='#EBD8B3', width=2)
        curtain += p('M119 130 Q128 135 136 130 L138 137 Q127 142 119 136 Z', '#DFA15D', '#BA8148', 1.4)
        wall += f'<g transform="translate(390 0) scale(-1 1)">{curtain}</g>' if mirror else curtain
    floor = r(0, 253, 390, 137, '#E9AF68', 0, 'none')
    ys = [253, 267, 284, 305, 331, 361, 397]
    shades = ['#ECC087', '#F0BE7E', '#EDB671', '#EFB976', '#F2C084', '#EAB16E']
    for row, (top, bottom) in enumerate(zip(ys, ys[1:])):
        floor += r(0, top, 390, bottom-top, shades[row], 0, 'none')
        floor += p(f'M0 {top} L390 {top}', stroke='#C98E4F', width=1.1)
        floor += p(f'M0 {top+1.7} L390 {top+1.7}', stroke='#F9D69C', width=1.1)
        for x in range(-45 + (row % 2)*64, 440, 112):
            end = 195 + (x-195)*(1 + (bottom-top)/350)
            floor += p(f'M{x} {top} L{end:.1f} {bottom}', stroke='#CD985B', width=.8)
            floor += p(f'M{x+16} {top+6} q18 -2 34 0', stroke='#DFAB6B', width=.7)
    floor += r(0, 246, 390, 11, '#C38E57', 0, '#AC7544', 1)
    floor += p('M0 248 L390 248', stroke='#F4D09C', width=2)
    floor += '<g opacity="0.14">' + p('M133 256 L260 256 L326 345 L66 345 Z', '#FFF9DB', 'none') + '</g>'
    decor = '<g opacity="0.12">' + r(15, 116, 99, 9, '#74472B', 4, 'none') + '</g>'
    for x,y,w,h,color in [(40,84,11,29,'#9BADA0'),(53,79,10,34,'#D8A15B'),(66,87,12,26,'#C5876A'),(80,83,13,30,'#A5AF76')]:
        decor += r(x,y,w,h,color,2,'#966C45',1.3) + p(f'M{x+3} {y+5} L{x+w-3} {y+5}',stroke='#F4DCB2',width=1)
    decor += r(12,111,101,8,'#D9A063',3) + p('M16 113 L107 113',stroke='#F3CD95',width=1.5)
    decor += p('M18 91 L38 91 L34 111 L22 111 Z','#D4A16C','#A47446',1.6)
    decor += p('M29 92 Q18 68 25 54 M28 89 Q41 69 44 67 M27 92 Q8 93 15 122 Q24 141 16 157',stroke='#779552',width=2)
    for x,y,a,s in [(26,70,-15,.78),(28,86,80,.8),(43,73,105,.7),(19,96,-30,.65),(17,119,70,.65),(20,137,-30,.58),(17,153,80,.52)]:
        decor += leaf(x,y,a,s)
    decor += '<g opacity="0.12">' + e(64,257,52,5,'#6C4529') + '</g>'
    decor += r(17,189,87,62,'#BE8B54',6) + r(14,184,94,10,'#E9BA7D',4)
    decor += r(23,198,34,43,'#7E6240',3,'#9E7146',1.3)
    for x,y,color in [(27,208,'#B1B48A'),(35,203,'#DFB575'),(43,213,'#CA9273')]:
        decor += r(x,y,6,27,color,1,'none')
    decor += r(64,199,32,39,'#E8C38C',3,'#A67747',1.5) + p('M76 216 L84 216',stroke='#A57445',width=3)
    decor += p('M25 251 L24 256 M96 251 L97 256',stroke='#8B603B',width=4)
    decor += p('M307 71 L331 53 L357 71',stroke='#B88754',width=1.6)
    decor += r(303,71,58,51,'#D5A367',5) + r(308,76,48,41,'#FFF2D6',3,'#AD7B46',1.4)
    decor += p('M318 92 L320 84 L326 90 Q332 87 339 90 L346 84 L347 94 Q351 109 333 110 Q314 109 318 92 Z','#ECAA58','#B67D43',1.1)
    decor += p('M324 98 Q326 96 328 98 M337 98 Q339 96 341 98 M330 104 Q333 107 336 104',stroke='#9B6635',width=1.2)
    decor += p('M305 253 L305 190 C305 140 380 140 380 190 L380 253 Z','#9B6A43','#875530',2)
    decor += p('M314 253 L314 190 C314 153 372 153 372 190 L372 253 Z','#F2D3A4','#C28B50',2)
    decor += p('M358 164 Q372 172 372 190 L372 253 L358 242 Z','#DBB37D','none')
    decor += p('M314 239 L358 237 L372 253 L314 253 Z','#E7B579','none')
    decor += p('M326 251 L325 199 Q325 174 347 172 L347 241 Z','#EDC78E','#B78550',1.3) + e(339,215,2,3,'#9A6C3C')
    decor += r(322,170,27,23,'#FFF4D9',5,'#B3834B',1.2)
    decor += p('M330 176 L330 184 M327 176 L327 180 Q330 183 333 180 L333 176 M341 176 L341 186',stroke='#BA8447',width=1.6)
    decor += '<g opacity="0.14">' + e(8,386,35,6,'#6D5536') + '</g>'
    decor += p('M-10 390 Q-3 354 9 336 M3 390 Q20 360 35 362',stroke='#68814B',width=3)
    for x,y,a,s in [(7,348,-25,1.25),(4,364,65,1.2),(28,364,95,1.1),(18,382,58,1.05),(-3,383,-30,1.2)]:
        decor += leaf(x,y,a,s)
    return wall, floor, decor
