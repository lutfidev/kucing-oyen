"""Membuat efek suara game di assets/audio/sfx/ dari paket CC0.

Sumber tidak ikut repo. Unduh dan bongkar ke satu folder:
  - Kenney (https://kenney.nl, CC0): Interface Sounds, Impact Sounds,
    RPG Audio -> <sumber>/kenney_<paket>/Audio/*.ogg
  - OpenGameArt (CC0): "Meow" oleh IgnasD (Meow.ogg), "Kitten Mew" oleh
    AntumDeluge (kitten_mew-1.wav), "Cat Purr & Meow" oleh Kerzoven
    (cat_softmew.wav) -> <sumber>/oga/

Pakai:  python tool/audio/make_sfx.py <sumber>
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
}


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
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    os.makedirs(OUT, exist_ok=True)
    for name, (layers, max_len, peak) in SOUNDS.items():
        out = os.path.join(OUT, name + ".ogg")
        sf.write(out, build(sys.argv[1], layers, max_len, peak), RATE,
                 format="OGG", subtype="VORBIS")
        print(f"{name:8s} {os.path.getsize(out) // 1024:3d} KB")


if __name__ == "__main__":
    main()
