/// Path semua layar. Rute bersarang supaya tombol kembali Android mengikuti
/// alur layar: Beranda → peta babak → level.
abstract final class AppRoutes {
  /// Beranda (desain 01).
  static const home = '/';

  /// Galeri token dan komponen untuk cek visual terhadap desain. Tidak ada
  /// tombolnya di aplikasi; buka dengan `flutter run --route /galeri`.
  static const gallery = '/galeri';

  /// Galeri petak dan papan (desain 15, 17, 18).
  static const galleryBoard = '/galeri/papan';

  /// Galeri sprite Oyen (desain 14, 16).
  static const galleryOyen = '/galeri/oyen';

  /// Peta babak nomor [number] (desain 02).
  static String chapter(int number) => '/babak/$number';

  /// Layar level nomor [id] (fase atur, desain 03), di bawah peta babaknya
  /// supaya tombol kembali menuju peta itu.
  static String level(int id, {required int chapter}) =>
      '/babak/$chapter/level/$id';
}
