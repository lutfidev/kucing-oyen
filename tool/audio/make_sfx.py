"""Membuat efek suara game di assets/audio/sfx/ dari paket CC0.

Sumber tidak ikut repo. Unduh dan bongkar ke satu folder:
  - Kenney (https://kenney.nl, CC0): Interface Sounds, Impact Sounds,
    RPG Audio -> <sumber>/kenney_<paket>/Audio/*.ogg
  - OpenGameArt (CC0): "Meow" oleh IgnasD (Meow.ogg), "Kitten Mew" oleh
    AntumDeluge (kitten_mew-1.wav), "Cat Purr & Meow" oleh Kerzoven
    (cat_softmew.wav, cat_mewfood.wav, cat_purractive_loop.wav)
    -> <sumber>/oga/

Lapisan "synth:<jenis>" dibuat sendiri tanpa berkas sumber: "chime:<Hz,...>"
(nada lonceng berurutan) dan "munch" (tiga gigitan derau lembut).

Pakai:  python tool/audio/make_sfx.py <sumber> [nama ...]
        (tanpa nama = semua suara; dengan nama = hanya itu)
Butuh:  pip install numpy soundfile

Setiap suara: lapisan berkas sumber (gain, geser detik) dicampur mono
44,1 kHz, dipotong ke panjang maksimum dengan fade-out, dinormalisasi ke
puncak tertentu, lalu disimpan OGG Vorbis. Kredit di
assets/audio/LICENSE-sfx.txt; asal tiap berkas dicatat di
docs/DESIGN_NOTES.md bagian "Langkah 16".
"""

import os
import sys

import numpy as np
import soundfile as sf

RATE = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "audio", "sfx")

UI = "kenney_interface-sounds/Audio/"
IMPACT = "kenney_impact-sounds/Audio/"
RPG = "kenney_rpg-audio/Audio/"
OGA = "oga/"

# nama -> (lapisan [(berkas, gain, geser detik)], panjang maks detik, puncak)
SOUNDS = {
    "tap": ([(UI + "click_002.ogg", 1, 0)], 0.15, 0.5),
    "pick_up": ([(UI + "maximize_009.ogg", 1, 0)], 0.3, 0.6),
    "place": ([(UI + "drop_002.ogg", 1, 0)], 0.3, 0.7),
    "back": ([(UI + "minimize_009.ogg", 1, 0)], 0.3, 0.6),
    "wake": ([(OGA + "Meow.ogg", 1, 0)], 0.6, 0.7),
    "eat": ([(UI + "confirmation_001.ogg", 1, 0)], 0.35, 0.6),
    "scared": ([(OGA + "kitten_mew-1.wav", 1, 0)], 0.7, 0.75),
    "box": ([(IMPACT + "impactSoft_medium_001.ogg", 1, 0)], 0.3, 0.85),
    "glass": ([(IMPACT + "impactGeneric_light_002.ogg", 1, 0)], 0.3, 0.7),
    "vase": (
        [
            (IMPACT + "impactGlass_heavy_001.ogg", 1, 0),
            (IMPACT + "impactPlate_light_000.ogg", 0.7, 0.03),
            (IMPACT + "impactGlass_light_002.ogg", 0.5, 0.12),
        ],
        0.8,
        0.9,
    ),
    "star": ([(UI + "glass_001.ogg", 1, 0)], 0.4, 0.6),
    "bored": ([(OGA + "cat_softmew.wav", 1, 0)], 1.3, 0.65),
    "coin": ([(RPG + "handleCoins.ogg", 1, 0)], 0.6, 0.6),
    # Kamar Oyen (langkah 24).
    "purr": ([(OGA + "cat_purractive_loop.wav", 1, 0)], 1.4, 0.55),
    "meow": ([(OGA + "cat_mewfood.wav", 1, 0)], 0.9, 0.6),
    "munch": ([("synth:munch", 1, 0)], 0.5, 0.5),
    "reward": ([("synth:chime:1318.5,1975.5", 1, 0)], 0.7, 0.5),
    "buy": ([("synth:chime:1046.5,1318.5,1568", 1, 0)], 0.7, 0.5),
    "wear": ([("synth:chime:1568,2093,2637", 1, 0)], 0.6, 0.45),
}


def synth(kind):
    """Lapisan sintetis: lonceng (sinus dengan nada atas, peluruhan cepat)
    atau gigitan (derau yang disaring, tiga kali)."""
    rng = np.random.default_rng(24)
    if kind.startswith("chime:"):
        notes = [float(n) for n in kind.split(":")[1].split(",")]
        gap, ring = 0.08, 0.45
        out = np.zeros(int((gap * len(notes) + ring) * RATE))
        t = np.arange(int(ring * RATE)) / RATE
        env = np.exp(-t * 9) * np.minimum(1, t * 400)
        for i, f in enumerate(notes):
            tone = np.sin(2 * np.pi * f * t) + 0.3 * np.sin(2 * np.pi * 2 * f * t)
            start = int(i * gap * RATE)
            out[start : start + len(t)] += tone * env
        return out
    if kind == "munch":
        bite = int(0.07 * RATE)
        out = np.zeros(int(0.45 * RATE))
        kernel = np.ones(24) / 24
        for i in range(3):
            noise = np.convolve(rng.standard_normal(bite), kernel, "same")
            env = np.exp(-np.arange(bite) / RATE * 45)
            start = int(i * 0.13 * RATE)
            out[start : start + bite] += noise * env * (1 - 0.15 * i)
        return out
    raise ValueError("synth tidak dikenal: " + kind)


def load(path):
    data, rate = sf.read(path, always_2d=True)
    mono = data.mean(axis=1)
    if rate != RATE:
        t = np.arange(int(len(mono) * RATE / rate)) / RATE
        mono = np.interp(t, np.arange(len(mono)) / rate, mono)
    return mono


def trim_start(x, threshold=0.01):
    loud = np.nonzero(np.abs(x) > threshold * np.abs(x).max())[0]
    return x[loud[0] :] if len(loud) else x


def build(src, layers, max_len, peak):
    parts = []
    for path, gain, shift in layers:
        if path.startswith("synth:"):
            x = synth(path[len("synth:") :]) * gain
        else:
            x = trim_start(load(os.path.join(src, path))) * gain
        parts.append(np.concatenate([np.zeros(int(shift * RATE)), x]))
    mix = np.zeros(max(len(p) for p in parts))
    for p in parts:
        mix[: len(p)] += p
    mix = mix[: int(max_len * RATE)]
    fade = min(len(mix), int(0.04 * RATE))
    mix[-fade:] *= np.linspace(1, 0, fade)
    return mix * (peak / np.abs(mix).max())


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    names = sys.argv[2:] or list(SOUNDS)
    unknown = [n for n in names if n not in SOUNDS]
    if unknown:
        sys.exit("suara tidak dikenal: " + ", ".join(unknown))
    os.makedirs(OUT, exist_ok=True)
    for name in names:
        layers, max_len, peak = SOUNDS[name]
        out = os.path.join(OUT, name + ".ogg")
        sf.write(out, build(sys.argv[1], layers, max_len, peak), RATE,
                 format="OGG", subtype="VORBIS")
        print(f"{name:8s} {os.path.getsize(out) // 1024:3d} KB")


if __name__ == "__main__":
    main()
