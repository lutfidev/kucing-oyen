import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/gallery/gallery_screen.dart';
import 'package:kucing_oren/screens/home/home_screen.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('Beranda → galeri → kembali ke Beranda', (tester) async {
    await pumpApp(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Kucing Oren'), findsOneWidget);

    await tester.tap(find.text('Galeri komponen'));
    await tester.pumpAndSettle();
    expect(find.byType(GalleryScreen), findsOneWidget);
    expect(find.text('Token & komponen'), findsOneWidget);

    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is KoIconButton && w.semanticLabel == 'Kembali ke Beranda',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('galeri menampilkan semua komponen dasar', (tester) async {
    // Layar tinggi supaya semua bagian galeri dibangun ListView.
    setScreenSize(tester, const Size(390, 5000));
    await pumpApp(tester, location: '/galeri');
    for (final type in [
      KoButton,
      KoIconButton,
      KoChip,
      TraySlot,
      KoStars,
      KoCard,
    ]) {
      expect(find.byType(type), findsWidgets);
    }
  });
}
