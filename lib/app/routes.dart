/// Path semua layar. Rute bersarang supaya tombol kembali Android mengikuti
/// alur layar.
abstract final class AppRoutes {
  /// Beranda (sementara, diganti di langkah 9 roadmap).
  static const home = '/';

  /// Galeri token dan komponen untuk cek visual terhadap desain.
  static const gallery = '/galeri';

  /// Galeri petak dan papan (desain 15, 17, 18).
  static const galleryBoard = '/galeri/papan';

  /// Galeri sprite Oyen (desain 14, 16).
  static const galleryOyen = '/galeri/oyen';

  /// Layar level nomor [id] (fase atur, desain 03).
  static String level(int id) => '/level/$id';
}
