import 'kitties.dart';

/// Hadiah koin bergiliran (langkah 40, pilihan C pemilik repo): di satu
/// ruangan hanya satu kucing yang menampilkan gelembung hadiah, yaitu yang
/// pertama menurut urutan [KittyId] di antara [inRoom] yang [eligible];
/// `more` = jumlah kucing lain di ruangan itu yang juga siap.
({KittyId? kitty, int more}) rewardTurn(
  Iterable<KittyId> inRoom,
  bool Function(KittyId) eligible,
) {
  final ready = [
    for (final kitty in KittyId.values)
      if (inRoom.contains(kitty) && eligible(kitty)) kitty,
  ];
  return (kitty: ready.firstOrNull, more: ready.isEmpty ? 0 : ready.length - 1);
}
