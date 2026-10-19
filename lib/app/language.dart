import 'dart:ui';

/// Bahasa pilihan pemain di Pengaturan. [system] = ikuti bahasa HP.
enum AppLanguage {
  system(null),
  en('English'),
  id('Bahasa Indonesia'),
  pt('Português (Brasil)'),
  ru('Русский');

  const AppLanguage(this.nativeName);

  /// Nama bahasa dalam bahasanya sendiri; null untuk [system] (teksnya
  /// ikut bahasa yang sedang dipakai).
  final String? nativeName;

  /// Bahasa yang didukung, urut pilihan di Pengaturan.
  static const supported = [en, id, pt, ru];

  /// Nama yang disimpan; nama tidak dikenal atau null = [system].
  static AppLanguage parse(String? name) => values.asNameMap()[name] ?? system;
}

/// Locale aplikasi: pilihan pemain, atau bahasa HP pertama yang didukung
/// (cocok kode bahasa saja, jadi pt-PT juga mendapat Portugis Brasil),
/// selain itu Inggris.
Locale resolveLocale(AppLanguage language, List<Locale> device) {
  if (language != AppLanguage.system) return Locale(language.name);
  for (final locale in device) {
    for (final supported in AppLanguage.supported) {
      if (locale.languageCode == supported.name) return Locale(supported.name);
    }
  }
  return Locale(AppLanguage.en.name);
}
