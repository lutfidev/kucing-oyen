"""Membuat berkas tinjauan terjemahan di docs/translations/ dari ARB.

Pakai:  python tool/translations/make_review.py

Satu berkas per bahasa yang ditinjau penutur asli (Inggris, Portugis
Brasil, Rusia): setiap kunci ARB dengan teks Inggris, teks bahasa itu,
deskripsi, placeholder, dan kolom masukan kosong, lalu listing toko dari
docs/store/. Jalankan ulang setiap kali ARB atau listing berubah.
"""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
L10N = ROOT / "lib" / "l10n"
STORE = ROOT / "docs" / "store"
OUT = ROOT / "docs" / "translations"

LANGUAGES = {
    "en": "English",
    "pt": "Brazilian Portuguese",
    "ru": "Russian",
}

GUIDE = """\
**How to review.** Read each line the way a player would see it in the game.
Write a better version in the *Feedback* column only where the text sounds
wrong, stiff, or unnatural; leave it empty when it is fine. The same goes
for the store listing at the end.

- **Tone:** casual, warm, and a little funny, like a friend telling the
  story of a stubborn cat. Short is better: most lines sit on small buttons
  and chips on a phone.
- **Rules of the game** say the cat *turns clockwise* at a wall or table
  (pt: "sentido horário", ru: "по часовой"), never "turns right".
- **Captions** (what the cat is doing step by step) use screen directions:
  up, down, left, right.
- **Do not translate:** the game name "Ginger Logic", the cat's name
  "Oyen", and the drawn words "PRANG!" and "Zzz".
- **Placeholders** in braces (`{n}`, `{dir}`, ...) stay as they are. Lines
  with `plural` or `select` are ICU messages: change only the words inside
  the inner braces, e.g. `{n, plural, one{{n} step} other{{n} steps}}`.
  Russian plurals have `one`, `few`, and `many` forms.
"""


def load(lang):
    return json.loads((L10N / f"app_{lang}.arb").read_text(encoding="utf-8"))


def cell(text):
    return text.replace("|", "\\|").replace("\n", "<br>")


def notes(meta):
    parts = [meta.get("description", "")]
    placeholders = meta.get("placeholders") or {}
    if placeholders:
        names = ", ".join(f"`{{{name}}}`" for name in placeholders)
        parts.append(f"Placeholders: {names}.")
    return " ".join(p for p in parts if p)


def review(lang, name):
    en = load("en")
    target = load(lang)
    source = load("id")
    keys = [k for k in en if not k.startswith("@")]
    lines = [
        f"# Ginger Logic: {name} review",
        "",
        "Ginger Logic is a casual puzzle game for phones: the player places "
        "fish, water buckets, and boxes on a 7x9 board, then Oyen the orange "
        "cat wakes up and walks on its own, following fixed rules. The game "
        "text was written in Indonesian first.",
        "",
        GUIDE,
        f"{len(keys)} lines. Generated from `lib/l10n/` by "
        "`tool/translations/make_review.py`; do not edit by hand.",
        "",
    ]
    if lang == "en":
        lines += [
            "| Key | English | Indonesian (original) | Notes | Feedback |",
            "| --- | --- | --- | --- | --- |",
        ]
        for key in keys:
            meta = en.get(f"@{key}", {})
            lines.append(
                f"| `{key}` | {cell(en[key])} | {cell(source[key])} "
                f"| {cell(notes(meta))} | |"
            )
    else:
        lines += [
            f"| Key | English | {name} | Notes | Feedback |",
            "| --- | --- | --- | --- | --- |",
        ]
        for key in keys:
            meta = en.get(f"@{key}", {})
            lines.append(
                f"| `{key}` | {cell(en[key])} | {cell(target[key])} "
                f"| {cell(notes(meta))} | |"
            )
    lines += ["", "---", ""]
    if lang != "en":
        lines += [
            "## Store listing: English (for reference)",
            "",
            shift(STORE / "listing-en.md"),
            "",
        ]
    lines += [
        f"## Store listing: {name}",
        "",
        shift(STORE / f"listing-{lang}.md"),
    ]
    return "\n".join(lines).rstrip() + "\n"


def shift(path):
    """Isi listing dengan judulnya turun dua tingkat (di bawah ## berkas ini)."""
    out = []
    in_code = False
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("```"):
            in_code = not in_code
        if not in_code and line.startswith("#"):
            line = "##" + line
        out.append(line)
    return "\n".join(out)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for lang, name in LANGUAGES.items():
        path = OUT / f"review-{lang}.md"
        path.write_text(review(lang, name), encoding="utf-8", newline="\n")
        print(path.relative_to(ROOT))


if __name__ == "__main__":
    main()
