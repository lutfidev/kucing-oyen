import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/theme/theme.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

/// Geseran turun permukaan tombol (efek tekan).
double shiftOf(WidgetTester tester, Finder button) {
  final transform = tester.widget<Transform>(
    find.descendant(of: button, matching: find.byType(Transform)).first,
  );
  return transform.transform.getTranslation().y;
}

/// Bayangan padat (tanpa blur) di bawah tombol, atau null.
BoxShadow? solidShadowOf(WidgetTester tester, Finder button) {
  final shadows = decorationOf(tester, button).boxShadow ?? const [];
  return shadows.where((s) => s.blurRadius == 0).firstOrNull;
}

void main() {
  const c = KoColors.standard;

  group('KoButton', () {
    testWidgets('ketuk memanggil onPressed', (tester) async {
      var taps = 0;
      await pumpThemed(
        tester,
        KoButton(label: 'Lanjut', onPressed: () => taps++),
      );
      await tester.tap(find.text('Lanjut'));
      expect(taps, 1);
    });

    testWidgets('ditekan: permukaan turun dan bayangan padat hilang', (
      tester,
    ) async {
      await pumpThemed(tester, KoButton(label: 'Lanjut', onPressed: () {}));
      final button = find.byType(KoButton);
      expect(shiftOf(tester, button), 0);
      expect(solidShadowOf(tester, button)!.offset, const Offset(0, 6));
      expect(solidShadowOf(tester, button)!.color, c.orangeDeep);

      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 150));
      expect(shiftOf(tester, button), 6);
      expect(solidShadowOf(tester, button), isNull);

      await gesture.up();
      await tester.pump();
      expect(shiftOf(tester, button), 0);
      expect(solidShadowOf(tester, button)!.offset, const Offset(0, 6));
    });

    testWidgets('jari bergeser keluar: tombol kembali naik tanpa ketuk', (
      tester,
    ) async {
      var taps = 0;
      await pumpThemed(
        tester,
        KoButton(label: 'Lanjut', onPressed: () => taps++),
      );
      final button = find.byType(KoButton);
      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 150));
      await gesture.moveBy(const Offset(0, 300));
      await gesture.up();
      await tester.pump();
      expect(shiftOf(tester, button), 0);
      expect(taps, 0);
    });

    testWidgets('warna dan tinggi per jenis dan ukuran', (tester) async {
      await pumpThemed(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KoButton(label: 'Utama', onPressed: () {}),
            KoButton(
              label: 'Sukses',
              kind: KoButtonKind.success,
              onPressed: () {},
            ),
            KoButton(
              label: 'Sekunder',
              kind: KoButtonKind.secondary,
              onPressed: () {},
            ),
            KoButton(
              label: 'Bangunkan Oyen',
              size: KoButtonSize.large,
              icon: KoIcons.wake,
              onPressed: () {},
            ),
            KoButton(
              label: 'Main',
              size: KoButtonSize.hero,
              icon: KoIcons.play,
              onPressed: () {},
            ),
          ],
        ),
      );
      Finder button(String label) => find.widgetWithText(KoButton, label);

      expect(decorationOf(tester, button('Utama')).color, c.orange);
      expect(tester.getSize(button('Utama')).height, 64);

      expect(decorationOf(tester, button('Sukses')).color, c.success);
      expect(solidShadowOf(tester, button('Sukses'))!.color, c.successDeep);
      final successText = tester.widget<Text>(find.text('Sukses'));
      expect(successText.style!.color, c.onSuccess);

      final secondary = decorationOf(tester, button('Sekunder'));
      expect(secondary.color, c.surface);
      expect(secondary.border, Border.all(color: c.line, width: 2));
      expect(solidShadowOf(tester, button('Sekunder'))!.offset.dy, 4);

      expect(tester.getSize(button('Bangunkan Oyen')).height, 72);
      expect(solidShadowOf(tester, button('Bangunkan Oyen'))!.offset.dy, 7);
      expect(find.byType(KoIcon), findsNWidgets(2));
      expect(tester.getSize(button('Main')).height, 76);
    });

    testWidgets('nonaktif: tidak bisa diketuk, tidak turun, abu-abu', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpThemed(
        tester,
        const KoButton(label: 'Lanjut', onPressed: null),
      );
      final button = find.byType(KoButton);
      expect(decorationOf(tester, button).color, c.disabled);

      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 150));
      expect(shiftOf(tester, button), 0);
      await gesture.up();

      expect(
        tester.getSemantics(button),
        isSemantics(
          label: 'Lanjut',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      semantics.dispose();
    });

    testWidgets('pembaca layar bisa menekan tombol', (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await pumpThemed(
        tester,
        KoButton(label: 'Lanjut', onPressed: () => taps++),
      );
      expect(
        tester.getSemantics(find.byType(KoButton)),
        isSemantics(
          label: 'Lanjut',
          isButton: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      tester.semantics.tap(find.semantics.byLabel('Lanjut'));
      expect(taps, 1);
      semantics.dispose();
    });

    testWidgets('di dalam Row (lebar tak terbatas) selebar isinya', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KoButton(
              label: 'Ulangi',
              kind: KoButtonKind.secondary,
              onPressed: () {},
            ),
            KoButton(label: 'Lanjut', icon: KoIcons.play, onPressed: () {}),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      final width = tester
          .getSize(find.widgetWithText(KoButton, 'Ulangi'))
          .width;
      expect(width, greaterThan(48));
      expect(width, lessThan(200));
    });

    testWidgets('label panjang mengecil di tempat sempit, tanpa overflow', (
      tester,
    ) async {
      setTextScale(tester, 1.3);
      await pumpThemed(
        tester,
        SizedBox(
          width: 160,
          child: KoButton(
            label: 'Bangunkan Oyen',
            size: KoButtonSize.large,
            icon: KoIcons.wake,
            onPressed: () {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(KoButton)).width, 160);
    });
  });

  group('KoIconButton', () {
    testWidgets('label untuk pembaca layar dan ketuk', (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await pumpThemed(
        tester,
        KoIconButton(
          icon: KoIcons.back,
          semanticLabel: 'Kembali ke peta',
          onPressed: () => taps++,
        ),
      );
      final button = find.byType(KoIconButton);
      expect(tester.getSize(button), const Size(44, 44));
      expect(
        tester.getSemantics(button),
        isSemantics(label: 'Kembali ke peta', isButton: true),
      );
      await tester.tap(button);
      expect(taps, 1);
      semantics.dispose();
    });

    testWidgets('ditekan turun 3 px', (tester) async {
      await pumpThemed(
        tester,
        KoIconButton(
          icon: KoIcons.back,
          semanticLabel: 'Kembali',
          onPressed: () {},
        ),
      );
      final button = find.byType(KoIconButton);
      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 150));
      expect(shiftOf(tester, button), 3);
      await gesture.up();
      await tester.pump();
      expect(shiftOf(tester, button), 0);
    });

    testWidgets('nada petunjuk bulat kuning; datar dan lantai tanpa bayangan', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KoIconButton(
              icon: KoIcons.hint,
              semanticLabel: 'Petunjuk',
              tone: KoIconButtonTone.hint,
              onPressed: () {},
            ),
            KoIconButton(
              icon: KoIcons.close,
              semanticLabel: 'Tutup',
              tone: KoIconButtonTone.flat,
              onPressed: () {},
            ),
            KoIconButton(
              icon: KoIcons.reset,
              semanticLabel: 'Kosongkan papan',
              tone: KoIconButtonTone.floor,
              onPressed: () {},
            ),
          ],
        ),
      );
      Finder button(String label) => find.byWidgetPredicate(
        (w) => w is KoIconButton && w.semanticLabel == label,
      );
      final hint = decorationOf(tester, button('Petunjuk'));
      expect(hint.shape, BoxShape.circle);
      expect(hint.color, c.hint);
      expect(solidShadowOf(tester, button('Petunjuk'))!.color, c.hintDeep);
      expect(solidShadowOf(tester, button('Tutup')), isNull);
      expect(decorationOf(tester, button('Kosongkan papan')).color, c.floor);
      expect(solidShadowOf(tester, button('Kosongkan papan')), isNull);
    });

    testWidgets('petunjuk berlabel tidak digambar bulat', (tester) async {
      await pumpThemed(
        tester,
        KoIconButton(
          icon: KoIcons.hint,
          semanticLabel: 'Petunjuk',
          label: 'Petunjuk',
          tone: KoIconButtonTone.hint,
          onPressed: () {},
        ),
      );
      final button = find.byType(KoIconButton);
      expect(decorationOf(tester, button).shape, BoxShape.rectangle);
      expect(decorationOf(tester, button).color, c.hint);
    });

    testWidgets('label mengecil di tempat sempit dengan teks 130%', (
      tester,
    ) async {
      setTextScale(tester, 1.3);
      await pumpThemed(
        tester,
        SizedBox(
          width: 80,
          child: KoIconButton(
            icon: KoIcons.rules,
            semanticLabel: 'Aturan',
            label: 'Aturan',
            onPressed: () {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(KoIconButton)).width, 80);
    });

    testWidgets('dengan label melebar berisi ikon dan teks', (tester) async {
      await pumpThemed(
        tester,
        KoIconButton(
          icon: KoIcons.rules,
          semanticLabel: 'Aturan',
          label: 'Aturan',
          onPressed: () {},
        ),
      );
      expect(find.text('Aturan'), findsOneWidget);
      final size = tester.getSize(find.byType(KoIconButton));
      expect(size.height, 44);
      expect(size.width, greaterThan(44));
    });
  });
}
