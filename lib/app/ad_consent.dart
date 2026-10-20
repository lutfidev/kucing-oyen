import 'package:flutter/widgets.dart';

/// Persetujuan iklan (formulir UMP Google di wilayah yang mewajibkan).
/// Pendengar diberi tahu saat [canRequestAds] atau
/// [privacyOptionsRequired] berubah.
abstract class AdConsent extends ChangeNotifier {
  /// Dipanggil sekali saat aplikasi mulai: memperbarui info persetujuan
  /// dan menampilkan formulir kalau wajib. Tidak menahan layar pertama dan
  /// tidak melempar.
  Future<void> gather();

  /// Iklan boleh diminta (persetujuan sudah cukup atau tidak diwajibkan).
  bool get canRequestAds;

  /// Pemain wajib bisa membuka formulir persetujuan lagi dari Pengaturan.
  bool get privacyOptionsRequired;

  /// Membuka formulir persetujuan dari Pengaturan → Privasi.
  Future<void> showPrivacyOptions();
}

/// Persetujuan palsu untuk test: nilainya diatur langsung.
class FakeAdConsent extends AdConsent {
  FakeAdConsent({
    this._canRequestAds = true,
    this._privacyOptionsRequired = false,
  });

  bool _canRequestAds;
  bool _privacyOptionsRequired;

  /// Berapa kali [gather] dipanggil.
  int gathered = 0;

  /// Berapa kali formulir dibuka dari Pengaturan.
  int optionsShown = 0;

  @override
  bool get canRequestAds => _canRequestAds;
  set canRequestAds(bool value) {
    _canRequestAds = value;
    notifyListeners();
  }

  @override
  bool get privacyOptionsRequired => _privacyOptionsRequired;
  set privacyOptionsRequired(bool value) {
    _privacyOptionsRequired = value;
    notifyListeners();
  }

  @override
  Future<void> gather() async => gathered++;

  @override
  Future<void> showPrivacyOptions() async => optionsShown++;
}

/// Membagikan [AdConsent] ke Pengaturan. Tanpa scope (test, galeri) tombol
/// persetujuan tidak tampil.
class AdConsentScope extends InheritedNotifier<AdConsent> {
  const AdConsentScope({
    super.key,
    required AdConsent consent,
    required super.child,
  }) : super(notifier: consent);

  /// Persetujuan terdekat (ikut dibangun ulang saat berubah), atau null.
  static AdConsent? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdConsentScope>()?.notifier;
}
