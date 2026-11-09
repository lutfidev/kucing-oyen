"""Measure actual packaged art contribution (not total APK delta)."""
import hashlib
import json
from pathlib import Path
import sys
import zipfile

apk = Path(sys.argv[1])
with zipfile.ZipFile(apk) as archive:
    entries = [i for i in archive.infolist() if '/assets/art/v2/' in i.filename]
    manifest = json.loads(archive.read('assets/flutter_assets/assets/art/v2/manifest.json'))
    required = {'assets/flutter_assets/assets/art/v2/' + v['file'] for v in manifest['assets'].values()}
    painted = 'assets/flutter_assets/assets/art/v2/scenes/santai-painted-v1.webp'
    required.add(painted)
    names = {i.filename for i in entries}
    if not required.issubset(names):
        raise SystemExit('APK is missing art files')
    report = dict(apk=apk.name, apkBytes=apk.stat().st_size,
                  sha256=hashlib.sha256(apk.read_bytes()).hexdigest(),
                  packagedArtEntries=len(entries),
                  packagedArtBytes=sum(i.file_size for i in entries),
                  packagedArtCompressedBytes=sum(i.compress_size for i in entries),
                  paintedSceneBytes=archive.getinfo(painted).file_size,
                  paintedSceneDecodeBudgetBytes=1024 * 1024 * 4,
                  note='Debug APK. Art entries only; not an APK size delta against v1 or a release size forecast.')
print(json.dumps(report, indent=2))
