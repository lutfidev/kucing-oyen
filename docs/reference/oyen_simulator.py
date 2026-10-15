"""Simulator & solver aturan Oyen.

Legenda peta:
  #  tembok            .  lantai
  M  meja kosong       G  meja + gelas plastik (boleh jatuh)
  V  meja + vas Ibu    (tidak boleh jatuh)
  T  tujuan (mangkuk)  F  ikan bawaan level (godaan)
  A  genangan/ember bawaan   K  kardus bawaan
  ^ > v <  Oyen + arah hadap awal
Benda pemain: F (ikan), A (ember air), K (kardus)
"""
from itertools import combinations, permutations
import itertools

DIRS = {'^': (0, -1), '>': (1, 0), 'v': (0, 1), '<': (-1, 0)}
ORDER = ['^', '>', 'v', '<']


def right(d): return ORDER[(ORDER.index(d) + 1) % 4]
def left(d): return ORDER[(ORDER.index(d) - 1) % 4]
def back(d): return ORDER[(ORDER.index(d) + 2) % 4]


TABLES = set('MGV')
MAX_STEPS = 80


def parse(rows):
    grid = {}
    start = None
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if c in DIRS:
                start = (x, y, c)
                c = '.'
            grid[(x, y)] = c
    return grid, start, len(rows[0]), len(rows)


def simulate(rows, placed=None, trace=False):
    """placed: dict pos->item ('F','A','K'). Returns dict result."""
    grid, (x, y, d), W, H = parse(rows)
    grid = dict(grid)
    if placed:
        for p, it in placed.items():
            assert grid[p] == '.', p
            grid[p] = it
    knocked = set()
    vase = False
    sit = 0
    seen = set()
    log = []

    def cell(p):
        return grid.get(p, '#')

    for step in range(MAX_STEPS + 1):
        if cell((x, y)) == 'T':
            return dict(win=True, vase=vase, steps=step, log=log)
        state = (x, y, d, sit, frozenset(k for k, v in grid.items() if v in 'FKA'), frozenset(knocked))
        if state in seen:
            return dict(win=False, vase=vase, steps=step, reason='mondar-mandir', log=log)
        seen.add(state)
        if sit > 0:
            sit -= 1
            log.append((x, y, d, 'duduk'))
            if sit == 0:
                grid[(x, y)] = '.'  # kardus penyok
            continue
        # 1. jatuhkan barang di meja sebelah
        did = False
        for dd in (d, right(d), left(d), back(d)):
            dx, dy = DIRS[dd]
            q = (x + dx, y + dy)
            if cell(q) in 'GV' and q not in knocked:
                knocked.add(q)
                if cell(q) == 'V':
                    vase = True
                log.append((x, y, d, 'jatuhkan ' + ('VAS' if cell(q) == 'V' else 'gelas')))
                did = True
                break
        if did:
            continue
        # 2. ikan terlihat
        best = None
        for pri, dd in enumerate((d, right(d), left(d), back(d))):
            dx, dy = DIRS[dd]
            dist = 1
            while True:
                q = (x + dx * dist, y + dy * dist)
                c = cell(q)
                if c == '#' or c in TABLES or c == 'K':
                    break
                if c == 'F':
                    if best is None or dist < best[0]:
                        best = (dist, pri, dd)
                    break
                dist += 1
        if best:
            d = best[2]
        dx, dy = DIRS[d]
        nxt = (x + dx, y + dy)
        c = cell(nxt)
        if c == 'A':
            d = back(d)
            log.append((x, y, d, 'kaget air, putar balik'))
            continue
        if c == '#' or c in TABLES:
            d = right(d)
            log.append((x, y, d, 'tembok, belok kanan'))
            continue
        x, y = nxt
        if c == 'F':
            grid[nxt] = '.'
            log.append((x, y, d, 'makan ikan'))
        elif c == 'K':
            sit = 2
            log.append((x, y, d, 'masuk kardus'))
        else:
            log.append((x, y, d, 'jalan'))
    return dict(win=False, vase=vase, steps=MAX_STEPS, reason='kelamaan', log=log)


def empty_cells(rows):
    grid, (sx, sy, _), W, H = parse(rows)
    return [p for p, c in sorted(grid.items(), key=lambda kv: (kv[0][1], kv[0][0]))
            if c == '.' and p != (sx, sy)]


def solve(rows, inventory, need_safe=True, limit=None):
    """inventory: dict item->count. Cari solusi dengan benda paling sedikit.
    Return (n_items, placement, result) atau None. Juga hitung jumlah solusi minimum."""
    cells = empty_cells(rows)
    items = []
    for it, n in inventory.items():
        items += [it] * n
    best = None
    for k in range(0, len(items) + 1):
        sols = []
        subsets = set()
        for sub in combinations(items, k):
            subsets.add(tuple(sorted(sub)))
        for sub in subsets:
            # assign distinct cells
            for cs in permutations(cells, len(sub)):
                # avoid duplicate orderings for identical items
                key = tuple(sorted(zip(sub, cs)))
                placed = {c: it for it, c in zip(sub, cs)}
                r = simulate(rows, placed)
                if r['win'] and (not need_safe or not r['vase']):
                    sols.append(key)
        if sols:
            sols = sorted(set(sols))
            return k, sols, len(sols)
    return None


def show(rows, placed=None):
    out = []
    for y, row in enumerate(rows):
        line = ''
        for x, c in enumerate(row):
            if placed and (x, y) in placed:
                line += placed[(x, y)].lower()
            else:
                line += c
        out.append(line)
    return '\n'.join(out)
