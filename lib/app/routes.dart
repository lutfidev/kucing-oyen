import '../game/model/sounds.dart';
import '../screens/shop/shop_tab.dart';

/// Path semua layar. Rute bersarang supaya tombol kembali Android mengikuti
/// alur layar: Beranda → peta babak → level.
abstract final class AppRoutes {
  /// Beranda: kamar Oyen (desain 19).
  static const home = '/';

  /// Galeri token dan komponen untuk cek visual terhadap desain. Tidak ada
  /// tombolnya di aplikasi; buka dengan `flutter run --route /galeri`.
  static const gallery = '/galeri';
  static const galleryUiV2 = '/galeri/ui-v2';
  static const galleryV2 = '/galeri/aset-v2';

  /// Galeri petak dan papan (desain 15, 17, 18).
  static const galleryBoard = '/galeri/papan';

  /// Galeri sprite Oyen (desain 14, 16).
  static const galleryOyen = '/galeri/oyen';

  /// Galeri sprite kucing kamar, aksesoris, barang, dan camilan
  /// (desain 21, 22).
  static const galleryKitty = '/galeri/kucing';

  /// Galeri efek suara dan musik, untuk didengar di perangkat.
  static const gallerySound = '/galeri/suara';
  static const galleryMotion = '/galeri/gerak';

  /// Toko (desain 20), dibuka dari Beranda. Dengan [tab] langsung membuka
  /// tab itu (`/toko?tab=accessories`).
  static String shop({ShopTab? tab}) =>
      tab == null ? '/toko' : '/toko?tab=${tab.name}';

  /// Pengaturan (tidak ada di desain), dibuka dari Beranda.
  static const settings = '/pengaturan';

  /// Peta babak nomor [number] (desain 23). Dari "Lanjut": [from] = level
  /// yang baru dimenangkan (Oyen berjalan darinya, `?dari=12`), [intro] =
  /// babak ini baru terbuka (kartu "Babak baru terbuka!", `?baru=1`).
  static String chapter(int number, {int? from, bool intro = false}) {
    final query = [if (from != null) 'dari=$from', if (intro) 'baru=1'];
    return query.isEmpty
        ? '/babak/$number'
        : '/babak/$number?${query.join('&')}';
  }

  /// Layar level nomor [id] (fase atur, desain 03), di bawah peta babaknya
  /// supaya tombol kembali menuju peta itu.
  static String level(int id, {required int chapter}) =>
      '/babak/$chapter/level/$id';
}

/// Musik latar di [path]: lagu level di layar level (termasuk hasil dan
/// putar ulang yang ada di dalam rutenya), lagu Beranda di layar lain.
MusicTrack musicFor(String path) =>
    RegExp(r'^/babak/[^/]+/level/[^/]+/?$').hasMatch(path)
    ? MusicTrack.level
    : MusicTrack.home;
