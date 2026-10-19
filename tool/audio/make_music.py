"""Membuat musik latar game di assets/audio/music/ (buatan sendiri).

Pakai:  python tool/audio/make_music.py
Butuh:  pip install numpy soundfile

Dua lagu yang berulang mulus:
  - home.ogg  : Beranda, peta, Lemari Kostum, Pengaturan. F mayor, 108 BPM,
                marimba + petikan + bas + perkusi lembut, santai-ceria.
  - level.ogg : layar level. C mayor, 84 BPM, kalimba + pad + bas + lonceng,
                tenang dan jarang supaya tidak mengganggu berpikir.

Melodi ditulis tangan di bawah. Satu putaran = 2 × 8 birama; ekor nada dan
gema di akhir dibungkus ke awal, jadi sambungan ulangnya tidak terdengar.
Hasilnya deterministik (seed tetap).
"""

import os

import numpy as np
import soundfile as sf

RATE = 32000
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "audio", "music")
rng = np.random.default_rng(16)

NOTES = {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}


def midi(name):
    """'Bb4' -> 70."""
    pitch = NOTES[name[0]]
    rest = name[1:]
    if rest.startswith("b"):
        pitch -= 1
        rest = rest[1:]
    elif rest.startswith("#"):
        pitch += 1
        rest = rest[1:]
    return 12 * (int(rest) + 1) + pitch


def freq(m):
    return 440.0 * 2 ** ((m - 69) / 12)


def phrase(text):
    """'C5:2 r:1 A4:1' -> [(mulai, panjang, midi)] dalam satuan seperdelapan."""
    out, at = [], 0
    for token in text.split():
        name, length = token.split(":")
        length = float(length)
        if name != "r":
            out.append((at, length, midi(name)))
        at += length
    return out, at


# ── Instrumen: (frekuensi, detik) -> sinyal ─────────────────────────────


def env_time(seconds):
    return np.arange(int(seconds * RATE)) / RATE


def attack(t, seconds=0.004):
    return np.minimum(1, t / seconds)


def marimba(f, dur):
    t = env_time(max(dur, 0.9))
    body = np.sin(2 * np.pi * f * t) * np.exp(-t * 5)
    knock = 0.35 * np.sin(2 * np.pi * f * 4 * t) * np.exp(-t * 28)
    return (body + knock) * attack(t)


def kalimba(f, dur):
    t = env_time(max(dur, 1.6))
    tone = np.sin(2 * np.pi * f * t) * np.exp(-t * 2.2)
    tine = 0.25 * np.sin(2 * np.pi * f * 5.95 * t) * np.exp(-t * 14)
    return (tone + tine) * attack(t, 0.006)


def bell(f, dur):
    t = env_time(max(dur, 2.4))
    mod = 1.4 * np.exp(-t * 3) * np.sin(2 * np.pi * f * 3.5 * t)
    return np.sin(2 * np.pi * f * t + mod) * np.exp(-t * 1.4) * attack(t, 0.01)


def pluck(f, dur):
    """Karplus-Strong: derau yang disaring berulang per periode."""
    n = int(max(dur, 0.6) * RATE)
    period = max(2, int(round(RATE / f)))
    y = np.zeros(n + period)
    y[:period] = rng.uniform(-1, 1, period)
    for start in range(period, n + period, period):
        prev = y[start - period : start]
        nxt = 0.5 * (prev + np.roll(prev, 1)) * 0.996
        end = min(start + period, n + period)
        y[start:end] = nxt[: end - start]
    return y[period:]


def bass(f, dur):
    t = env_time(dur + 0.15)
    tone = np.sin(2 * np.pi * f * t) + 0.25 * np.sin(4 * np.pi * f * t)
    release = np.clip((dur + 0.15 - t) / 0.15, 0, 1)
    return tone * np.exp(-t * 1.8) * attack(t, 0.012) * release


def pad(f, dur):
    t = env_time(dur + 0.6)
    tone = sum(
        np.sin(2 * np.pi * f * d * t) for d in (0.997, 1.0, 1.003)
    ) + 0.3 * np.sin(4 * np.pi * f * t)
    rise = np.minimum(1, t / 0.7)
    fall = np.clip((dur + 0.6 - t) / 0.6, 0, 1)
    return tone * rise * fall / 3.3


def kick(_f, _dur):
    t = env_time(0.3)
    sweep = 2 * np.pi * np.cumsum(50 + 70 * np.exp(-t * 30)) / RATE
    return np.sin(sweep) * np.exp(-t * 14)


def rim(_f, _dur):
    t = env_time(0.08)
    noise = np.diff(rng.uniform(-1, 1, len(t) + 1))
    return (0.5 * noise + np.sin(2 * np.pi * 1700 * t)) * np.exp(-t * 70)


def shaker(_f, _dur):
    t = env_time(0.07)
    noise = np.diff(rng.uniform(-1, 1, len(t) + 1))
    return noise * np.exp(-t * 55) * attack(t, 0.01)


# ── Lagu ────────────────────────────────────────────────────────────────


class Song:
    def __init__(self, bpm, bars):
        self.eighth = 30 / bpm
        self.length = int(bars * 8 * self.eighth * RATE)
        self.mix = np.zeros(self.length)

    def add(self, instrument, at, length, note, gain):
        """Nada di seperdelapan ke-[at]; ekor yang lewat akhir lagu
        dibungkus ke awal."""
        sound = instrument(freq(note), length * self.eighth) * gain
        start = int(at * self.eighth * RATE) % self.length
        idx = (start + np.arange(len(sound))) % self.length
        np.add.at(self.mix, idx, sound)

    def melody(self, instrument, bars_text, gain, first_bar=0):
        for i, text in enumerate(bars_text):
            notes, length = phrase(text)
            assert length == 8, (text, length)
            for at, dur, note in notes:
                self.add(instrument, (first_bar + i) * 8 + at, dur, note, gain)

    def finish(self, wet, peak=0.8):
        ir_t = env_time(1.6)
        ir = rng.normal(0, 1, len(ir_t)) * np.exp(-ir_t / 0.38)
        ir = np.convolve(ir, np.ones(6) / 6, mode="same")
        ir /= np.sqrt((ir**2).sum())
        n = self.length
        wet_sig = np.fft.irfft(np.fft.rfft(self.mix) * np.fft.rfft(ir, n), n)
        out = self.mix + wet * wet_sig
        out = np.tanh(out / np.abs(out).max() * 1.2)
        return out * (peak / np.abs(out).max())


def chord_tones(name, octave):
    """'Dm' -> midi akar, terts, kuint (+ septim kalau '7')."""
    root = midi(name[0] + ("b" if name[1:2] == "b" else "") + str(octave))
    quality = name[1:].lstrip("b")
    third = 3 if quality.startswith("m") and not quality.startswith("maj") else 4
    tones = [root, root + third, root + 7]
    if "maj7" in quality:
        tones.append(root + 11)
    elif "7" in quality:
        tones.append(root + 10)
    elif "6" in quality:
        tones.append(root + 9)
    return tones


def home():
    s = Song(bpm=108, bars=16)
    chords = ["F", "Dm", "Bb", "C", "F", "Dm", "Bb", "F"]
    a = [
        "C5:2 A4:1 C5:1 F5:2 E5:1 D5:1",
        "C5:3 A4:1 D5:4",
        "D5:2 C5:1 Bb4:1 A4:2 G4:2",
        "G4:2 A4:1 Bb4:1 C5:4",
        "C5:2 A4:1 C5:1 F5:2 G5:1 A5:1",
        "G5:2 F5:1 D5:1 F5:4",
        "D5:2 Bb4:2 C5:2 E5:2",
        "F5:6 r:2",
    ]
    b = [
        "A5:2 G5:1 F5:1 C5:2 A4:2",
        "D5:2 F5:2 A5:2 G5:1 F5:1",
        "F5:3 D5:1 Bb4:2 D5:2",
        "C5:2 E5:2 G5:4",
        "A5:2 G5:1 F5:1 C5:2 F5:2",
        "E5:1 F5:1 D5:2 A4:4",
        "Bb4:2 D5:2 E5:2 G5:2",
        "F5:4 C5:2 A4:2",
    ]
    s.melody(marimba, a, 0.5)
    s.melody(marimba, b, 0.5, first_bar=8)
    for bar in range(16):
        name = chords[bar % 8]
        # Birama 7: Bb lalu C.
        halves = [name, "C"] if bar % 8 == 6 else [name, name]
        for half, chord in enumerate(halves):
            r, t3, f5 = chord_tones(chord, 3)[:3]
            for i, note in enumerate([r, f5, r + 12, t3 + 12]):
                s.add(pluck, bar * 8 + half * 4 + i, 1, note, 0.18)
            s.add(bass, bar * 8 + half * 4, 3, r - 12, 0.45)
        s.add(bass, bar * 8 + 7, 1, chord_tones(halves[1], 2)[2], 0.3)
        for beat in range(4):
            at = bar * 8 + beat * 2
            if beat in (0, 2):
                s.add(kick, at, 1, 0, 0.5)
            else:
                s.add(rim, at, 1, 0, 0.12)
            s.add(shaker, at + 1, 1, 0, 0.1)
            s.add(shaker, at, 1, 0, 0.05)
    return s.finish(wet=0.25)


def level():
    s = Song(bpm=84, bars=16)
    chords = ["Cmaj7", "Am7", "Fmaj7", "G6", "Em7", "Am7", "Dm7", "G"]
    melody = [
        "r:2 E5:2 G5:4",
        "E5:3 D5:1 C5:4",
        "r:2 A4:2 C5:2 E5:2",
        "D5:6 r:2",
        "r:2 G5:2 E5:2 D5:2",
        "C5:6 r:2",
        "r:2 F5:2 E5:2 D5:2",
        "B4:4 D5:4",
    ]
    s.melody(bell, melody, 0.22, first_bar=8)
    for bar in range(16):
        tones = chord_tones(chords[bar % 8], 4)
        pattern = [(0, tones[0]), (3, tones[2]), (4, tones[-1]), (6, tones[1] + 12)]
        for at, note in pattern:
            s.add(kalimba, bar * 8 + at, 2, note, 0.3)
        for note in chord_tones(chords[bar % 8], 3):
            s.add(pad, bar * 8, 8, note, 0.07)
        s.add(bass, bar * 8, 6, tones[0] - 24, 0.4)
        s.add(shaker, bar * 8 + 4, 1, 0, 0.04)
    return s.finish(wet=0.35)


def write_ogg(path, signal):
    """Ditulis per blok: libsndfile di Windows kehabisan stack kalau satu
    blok Vorbis terlalu panjang."""
    with sf.SoundFile(path, "w", RATE, 1, format="OGG", subtype="VORBIS",
                      compression_level=0.75) as f:
        for start in range(0, len(signal), 4096):
            f.write(signal[start : start + 4096])


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, make in [("home", home), ("level", level)]:
        out = os.path.join(OUT, name + ".ogg")
        signal = make()
        write_ogg(out, signal)
        print(f"{name:6s} {len(signal) / RATE:5.1f} s "
              f"{os.path.getsize(out) // 1024:4d} KB")


if __name__ == "__main__":
    main()
