import 'package:flutter/services.dart';

import 'sim/level.dart';

/// Level Babak 1 (Dapur) dan Babak 2 (Ruang Tamu).
const chapter1to2Asset = 'assets/levels/chapter1-2.json';

/// Memuat daftar level dari aset aplikasi.
///
/// Tanpa cache `rootBundle`: Future yang di-cache terikat zona tempat ia
/// dibuat, jadi di widget test hanya test pertama yang memuatnya yang bisa
/// menunggu sampai selesai. Asetnya kecil, jadi dibaca ulang tiap kali.
Future<List<Level>> loadLevels({
  String asset = chapter1to2Asset,
  AssetBundle? bundle,
}) async {
  final source = await (bundle ?? rootBundle).loadString(asset, cache: false);
  return parseLevels(source);
}
