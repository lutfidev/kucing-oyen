import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/theme/theme.dart';

import '../test_helpers.dart';

void main() {
  final theme = KoTheme.light();

  test('semua grup token terpasang sebagai ThemeExtension', () {
    expect(theme.extension<KoColors>(), KoColors.standard);
    expect(theme.extension<KoType>(), KoType.standard);
    expect(theme.extension<KoSpace>(), KoSpace.standard);
    expect(theme.extension<KoRadius>(), KoRadius.standard);
    expect(theme.extension<KoShadow>(), isNotNull);
    expect(theme.extension<KoSize>(), KoSize.standard);
  });

  test('warna inti sama dengan lembar token desain', () {
    const c = KoColors.standard;
    final expected = <Color, int>{
      c.cream: 0xFFFFF4E2,
      c.surface: 0xFFFFFBF3,
      c.line: 0xFFEAD3AE,
      c.ink: 0xFF3B2716,
      c.inkSoft: 0xFF6B4F3A,
      c.floor: 0xFFF7E8CE,
      c.orange: 0xFFF59A33,
      c.orangeDeep: 0xFFC9650C,
      c.fur: 0xFFF29A3A,
      c.furStripe: 0xFFC4651A,
      c.water: 0xFF8FD3F0,
      c.waterDeep: 0xFF2F86B8,
      c.box: 0xFFC8955A,
      c.boxEdge: 0xFF9E6C37,
      c.success: 0xFF2BB5A0,
      c.successDeep: 0xFF1C8676,
      c.brick: 0xFFC2492F,
      c.brickDeep: 0xFF9A3520,
      c.wood: 0xFFB07A4F,
      c.star: 0xFFFFC83D,
      c.starEdge: 0xFFC98F00,
    };
    for (final MapEntry(key: color, value: argb) in expected.entries) {
      expect(color.toARGB32(), argb);
    }
    expect(theme.scaffoldBackgroundColor, c.cream);
  });

  test('tipografi: Fredoka untuk judul dan angka, Nunito untuk teks', () {
    const t = KoType.standard;
    void check(TextStyle s, String family, FontWeight weight, double size) {
      expect((s.fontFamily, s.fontWeight, s.fontSize), (family, weight, size));
    }

    check(t.display, KoFonts.fredoka, FontWeight.w700, 46);
    check(t.title, KoFonts.fredoka, FontWeight.w700, 26);
    check(t.heading, KoFonts.fredoka, FontWeight.w600, 20);
    check(t.number, KoFonts.fredoka, FontWeight.w700, 30);
    check(t.body, KoFonts.nunito, FontWeight.w700, 15);
    check(t.label, KoFonts.nunito, FontWeight.w800, 15);
    check(t.overline, KoFonts.nunito, FontWeight.w800, 12);
    expect(t.overline.letterSpacing, 1.2);
    expect(theme.textTheme.bodyMedium!.fontFamily, KoFonts.nunito);
  });

  test('jarak dan radius sesuai skala desain', () {
    const sp = KoSpace.standard;
    expect(
      [sp.s4, sp.s8, sp.s12, sp.s16, sp.s24, sp.s32],
      [4, 8, 12, 16, 24, 32],
    );
    const r = KoRadius.standard;
    expect(
      [r.tile, r.icon, r.button, r.primary, r.sheet, r.pill],
      [8, 14, 20, 24, 28, 999],
    );
  });

  test('bayangan press, card, dan board', () {
    final sh = KoShadow.standard;
    expect(sh.press, 6);
    expect(sh.card.single.offset, const Offset(0, 6));
    expect(sh.card.single.blurRadius, 16);
    expect(sh.board.first.spreadRadius, 4);
    expect(sh.board.first.color, KoColors.standard.boardRing);
    expect(
      KoShadow.solid(KoColors.standard.orangeDeep, sh.press).single.offset,
      const Offset(0, 6),
    );
  });

  test('lerp di ujung mengembalikan token yang sama', () {
    final other = KoColors.standard.copyWith(orange: const Color(0xFF000000));
    expect(KoColors.standard.lerp(other, 0).orange, KoColors.standard.orange);
    expect(KoColors.standard.lerp(other, 1).orange, other.orange);
    expect(KoSpace.standard.lerp(KoSpace.standard, 0.5).s8, 8);
    expect(KoType.standard.lerp(null, 0.5), KoType.standard);
  });

  test('font asli termuat di test (bukan font kotak bawaan)', () {
    // Font bawaan test menggambar tiap huruf sebagai kotak 1 em, jadi
    // "Kucing Oren" selebar 11 em. Fredoka asli jauh lebih sempit.
    double widthOf(TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: 'Kucing Oren', style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      addTearDown(painter.dispose);
      return painter.width;
    }

    const t = KoType.standard;
    expect(widthOf(t.title), lessThan(t.title.fontSize! * 8));
    expect(widthOf(t.body), lessThan(t.body.fontSize! * 8));
    // Bobot berbeda memakai berkas font yang berbeda.
    expect(
      widthOf(t.title),
      isNot(widthOf(t.title.copyWith(fontWeight: FontWeight.w500))),
    );
  });

  test('teks Rusia di gaya Fredoka memakai Nunito, bukan font sistem', () {
    // Fredoka tidak punya huruf Sirilik. Dengan cadangan Nunito, lebarnya
    // sama dengan teks Nunito (selisih kecil dari spasi Fredoka); tanpa
    // cadangan, hurufnya jatuh ke font lain.
    const text = 'Правила Ойена';
    double widthOf(TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      addTearDown(painter.dispose);
      return painter.width;
    }

    const t = KoType.standard;
    for (final style in [t.display, t.title, t.heading, t.number, t.logo]) {
      expect(style.fontFamily, KoFonts.fredoka);
      final nunito = widthOf(style.copyWith(fontFamily: KoFonts.nunito));
      expect(widthOf(style), closeTo(nunito, nunito * 0.02));
      expect(
        widthOf(style.copyWith(fontFamilyFallback: const [])),
        isNot(closeTo(nunito, nunito * 0.02)),
      );
    }
    expect(t.body.fontFamily, KoFonts.nunito);
  });

  test('semua gaya Fredoka punya cadangan Nunito', () {
    final source = File('lib/theme/ko_type.dart').readAsLinesSync();
    var fredoka = 0;
    for (var i = 0; i < source.length; i++) {
      if (source[i].trim() != 'fontFamily: KoFonts.fredoka,') continue;
      fredoka++;
      expect(
        source[i + 1].trim(),
        'fontFamilyFallback: _fredokaFallback,',
        reason: 'baris ${i + 1}',
      );
    }
    expect(fredoka, greaterThan(20));
    expect(source, contains('const _fredokaFallback = [KoFonts.nunito];'));
  });

  testWidgets('context tanpa tema Kucing Oren memakai nilai standar', (
    tester,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          captured = context;
          return const SizedBox();
        },
      ),
    );
    expect(captured.koColors, KoColors.standard);
    expect(captured.koSize.button, 64);
  });

  testWidgets('teks tanpa jarak huruf eksplisit tidak mendapat jarak huruf '
      'Material', (tester) async {
    await tester.pumpWidget(testApp(home: const Scaffold(body: Text('x'))));
    final context = tester.element(find.text('x'));
    final inherited = DefaultTextStyle.of(context).style;
    expect(inherited.letterSpacing, 0);
    const t = KoType.standard;
    expect(inherited.merge(t.body).letterSpacing, 0);
    expect(inherited.merge(t.overline).letterSpacing, t.overline.letterSpacing);

    final text = Theme.of(context).textTheme;
    final mapped = {
      'displayLarge': (text.displayLarge, t.display),
      'displayMedium': (text.displayMedium, t.number),
      'headlineMedium': (text.headlineMedium, t.title),
      'titleLarge': (text.titleLarge, t.heading),
      'bodyMedium': (text.bodyMedium, t.body),
      'labelLarge': (text.labelLarge, t.label),
      'labelSmall': (text.labelSmall, t.overline),
    };
    for (final MapEntry(key: name, value: (style, ko)) in mapped.entries) {
      expect(style!.letterSpacing, ko.letterSpacing ?? 0, reason: name);
    }
    final others = {
      'displaySmall': text.displaySmall,
      'headlineLarge': text.headlineLarge,
      'headlineSmall': text.headlineSmall,
      'titleMedium': text.titleMedium,
      'titleSmall': text.titleSmall,
      'bodyLarge': text.bodyLarge,
      'bodySmall': text.bodySmall,
      'labelMedium': text.labelMedium,
    };
    for (final MapEntry(key: name, value: style) in others.entries) {
      expect(style!.letterSpacing, 0, reason: name);
    }
  });
}
