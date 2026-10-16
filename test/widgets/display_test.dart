import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/theme/theme.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

/// Gambar [child] (persegi [side] px) lalu kembalikan pembaca warna
/// pikselnya.
Future<Color Function(double x, double y)> _pixels(
  WidgetTester tester,
  Widget child,
  double side,
) async {
  final key = GlobalKey();
  await pumpThemed(
    tester,
    RepaintBoundary(
      key: key,
      child: SizedBox.square(dimension: side, child: child),
    ),
  );
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = (await tester.runAsync(() async {
    final image = await boundary.toImage();
    return image.toByteData();
  }))!;
  return (x, y) {
    final i = (y.floor() * side.toInt() + x.floor()) * 4;
    return Color.fromARGB(
      bytes.getUint8(i + 3),
      bytes.getUint8(i),
      bytes.getUint8(i + 1),
      bytes.getUint8(i + 2),
    );
  };
}

void main() {
  const c = KoColors.standard;

  group('KoChip', () {
    testWidgets('chip krem: ikon dan angka', (tester) async {
      await pumpThemed(
        tester,
        const KoChip(leading: KoStar(size: 22), text: '14/60'),
      );
      final chip = find.byType(KoChip);
      expect(find.text('14/60'), findsOneWidget);
      expect(find.byType(KoStar), findsOneWidget);
      expect(tester.getSize(chip).height, 40);
      expect(decorationOf(tester, chip).color, c.cream);
    });

    testWidgets('chip gelap: label dan angka berwarna krem', (tester) async {
      await pumpThemed(tester, const KoChip.dark(label: 'Langkah', text: '1'));
      final chip = find.byType(KoChip);
      expect(decorationOf(tester, chip).color, c.ink);
      expect(tester.widget<Text>(find.text('Langkah')).style!.color, c.cream);
      expect(tester.widget<Text>(find.text('1')).style!.color, c.cream);
    });

    testWidgets('chip gelap besar: 44 px, angka 24 (desain 04)', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        const KoChip.dark(label: 'Langkah', text: '6', large: true),
      );
      expect(tester.getSize(find.byType(KoChip)).height, 44);
      final number = tester.widget<Text>(find.text('6')).style!;
      expect((number.fontFamily, number.fontSize), (KoFonts.fredoka, 24));
      // Label dan angka sejajar garis dasar huruf.
      expect(
        tester.getBottomLeft(find.text('Langkah')).dy,
        lessThan(tester.getBottomLeft(find.text('6')).dy),
      );
    });
  });

  group('TraySlot', () {
    const item = SizedBox.expand(key: Key('item'));

    testWidgets('berisi benda dan angka sisa', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpThemed(
        tester,
        const TraySlot(count: 2, semanticLabel: 'Kardus, sisa 2', child: item),
      );
      final slot = find.byType(TraySlot);
      expect(find.text('2'), findsOneWidget);
      expect(tester.getSize(slot), const Size(64, 64));
      expect(tester.getSize(find.byKey(const Key('item'))), const Size(50, 50));
      expect(find.byType(KoDashedBorder), findsNothing);
      expect(decorationOf(tester, slot).color, c.floor);
      expect(tester.getSemantics(slot), isSemantics(label: 'Kardus, sisa 2'));
      semantics.dispose();
    });

    testWidgets('sisa 0: garis putus-putus dan benda pudar', (tester) async {
      await pumpThemed(
        tester,
        const TraySlot(count: 0, semanticLabel: 'Ember, sisa 0', child: item),
      );
      expect(find.text('0'), findsOneWidget);
      expect(find.byType(KoDashedBorder), findsOneWidget);
      expect(tester.getSize(find.byType(TraySlot)), const Size(64, 64));
      expect(tester.getSize(find.byKey(const Key('item'))), const Size(40, 40));
      final ghost = tester.widget<Opacity>(
        find.ancestor(
          of: find.byKey(const Key('item')),
          matching: find.byType(Opacity),
        ),
      );
      expect(ghost.opacity, 0.28);
    });

    testWidgets('badge menempel di sudut kanan atas', (tester) async {
      await pumpThemed(
        tester,
        const TraySlot(count: 1, semanticLabel: 'Ikan, sisa 1'),
      );
      final slot = tester.getRect(find.byType(TraySlot));
      final badge = tester.getRect(
        find.ancestor(of: find.text('1'), matching: find.byType(Container)),
      );
      expect(badge.right, slot.right + 8);
      expect(badge.top, slot.top - 8);
      expect(badge.height, 24);
    });
  });

  group('KoCard', () {
    testWidgets('kartu biasa bergaris, terkunci putus-putus', (tester) async {
      await pumpThemed(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KoCard(child: Text('Air? Putar balik')),
            KoCard(locked: true, child: Text('Kardus: ???')),
            KoCard(elevated: true, child: Text('Bayangan')),
          ],
        ),
      );
      expect(find.text('Air? Putar balik'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('Kardus: ???'),
          matching: find.byType(KoDashedBorder),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.text('Air? Putar balik'),
          matching: find.byType(KoDashedBorder),
        ),
        findsNothing,
      );
      final elevated = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.text('Bayangan'),
              matching: find.byType(DecoratedBox),
            )
            .last,
      );
      expect(
        (elevated.decoration as BoxDecoration).boxShadow,
        KoShadow.standard.card,
      );
    });
  });

  group('KoStar', () {
    // Kilau "M9 9.5l2-.4" di viewBox 24: tengahnya (10, 9.3).
    const shineAt = Offset(100, 93);

    testWidgets('kilau hanya di bintang kuning', (tester) async {
      var at = await _pixels(tester, const KoStar(size: 240, shine: true), 240);
      expect(at(shineAt.dx, shineAt.dy), c.starShine);
      at = await _pixels(tester, const KoStar(size: 240), 240);
      expect(at(shineAt.dx, shineAt.dy), c.star);
      at = await _pixels(
        tester,
        const KoStar(size: 240, filled: false, shine: true),
        240,
      );
      expect(at(shineAt.dx, shineAt.dy), c.starEmpty);
    });
  });

  group('KoIcon', () {
    testWidgets('viewBox selain 0 0 24 24: jejak kaki di tengah', (
      tester,
    ) async {
      final at = await _pixels(
        tester,
        KoIcon(KoIcons.steps, size: 240, color: c.statIcon),
        240,
      );
      // Telapak (0, 3) dan jari kiri (-5.2, -3.6) di viewBox -10 -12 20 20.
      expect(at(120, 180), c.statIcon);
      expect(at(57.6, 100.8), c.statIcon);
      expect(at(5, 5).a, 0);
      expect(at(120, 100).a, 0);
    });
  });

  group('KoStars', () {
    testWidgets('bintang kuning dari kiri, sisanya pudar', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpThemed(tester, const KoStars(earned: 2));
      final stars = tester.widgetList<KoStar>(find.byType(KoStar));
      expect(stars.map((s) => s.filled), [true, true, false]);
      expect(
        tester.getSemantics(find.byType(KoStars)),
        isSemantics(label: '2 dari 3 bintang'),
      );
      expect(tester.getSize(find.byType(KoStar).first), const Size(36, 36));
      semantics.dispose();
    });
  });
}
