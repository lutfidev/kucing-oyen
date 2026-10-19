import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/language.dart';

void main() {
  group('resolveLocale', () {
    test('pilihan pemain menang atas bahasa HP', () {
      expect(
        resolveLocale(AppLanguage.ru, const [Locale('id', 'ID')]),
        const Locale('ru'),
      );
      expect(
        resolveLocale(AppLanguage.id, const [Locale('en', 'US')]),
        const Locale('id'),
      );
    });

    test('ikuti HP: bahasa pertama yang didukung', () {
      expect(
        resolveLocale(AppLanguage.system, const [
          Locale('fr', 'FR'),
          Locale('pt', 'BR'),
          Locale('ru'),
        ]),
        const Locale('pt'),
      );
      expect(
        resolveLocale(AppLanguage.system, const [Locale('id', 'ID')]),
        const Locale('id'),
      );
    });

    test('Portugis Portugal juga mendapat Portugis Brasil', () {
      expect(
        resolveLocale(AppLanguage.system, const [Locale('pt', 'PT')]),
        const Locale('pt'),
      );
    });

    test('ikuti HP tanpa bahasa yang didukung jatuh ke Inggris', () {
      expect(
        resolveLocale(AppLanguage.system, const [Locale('fr'), Locale('ja')]),
        const Locale('en'),
      );
      expect(resolveLocale(AppLanguage.system, const []), const Locale('en'));
    });
  });

  test('AppLanguage.parse membaca nama dan membuang yang rusak', () {
    expect(AppLanguage.parse('pt'), AppLanguage.pt);
    expect(AppLanguage.parse('system'), AppLanguage.system);
    expect(AppLanguage.parse('fr'), AppLanguage.system);
    expect(AppLanguage.parse(null), AppLanguage.system);
  });

  test('nama bahasa ditulis dalam bahasanya sendiri', () {
    expect(AppLanguage.en.nativeName, 'English');
    expect(AppLanguage.id.nativeName, 'Bahasa Indonesia');
    expect(AppLanguage.pt.nativeName, 'Português (Brasil)');
    expect(AppLanguage.ru.nativeName, 'Русский');
    expect(AppLanguage.system.nativeName, isNull);
  });
}
