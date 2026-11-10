import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/ko_ui.dart';
import '../theme/puzzle_theme.dart';
import 'v2/ui_button.dart';

/// Membuka sheet bawah (sheet Aturan desain 05 dan Petunjuk desain 10 di
/// layar level, sheet Tambah Koin di kamar dan Toko, konfirmasi
/// reset di Pengaturan): latar gelap, sheet naik sambil muncul. Ditutup
/// dengan `onClose` dari [builder] (tombol tutup, tarik ke bawah), ketuk
/// latar, atau tombol kembali sistem. [barrierColor] default
/// [KoColors.scrim].
Future<void> showKoSheet(
  BuildContext context, {
  required String barrierLabel,
  Color? barrierColor,
  required Widget Function(BuildContext context, VoidCallback onClose) builder,
}) {
  final trigger = FocusManager.instance.primaryFocus;
  final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: barrierLabel,
    barrierColor: barrierColor ?? KoUi.scrim,
    transitionDuration: reduceMotion ? Duration.zero : KoSheet.openTime,
    pageBuilder: (context, _, _) {
      final route = ModalRoute.of(context);
      // Hanya menutup sheet ini, walau dipanggil lagi saat sheet sedang
      // menutup (layar level di bawahnya tidak ikut ditutup).
      return Theme(
        data: puzzleTheme(),
        child: Builder(
          builder: (context) => builder(context, () {
            if (route?.isCurrent ?? false) Navigator.of(context).pop();
          }),
        ),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      final t = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return AnimatedBuilder(
        animation: t,
        builder: (context, child) => Opacity(
          opacity: t.value,
          child: Transform.translate(
            offset: Offset(0, KoSheet.openRise * (1 - t.value)),
            child: child,
          ),
        ),
        child: child,
      );
    },
  ).whenComplete(() {
    if (trigger?.context != null) trigger!.requestFocus();
  });
}

/// Bingkai sheet bawah: pegangan, [header], lalu [children] yang digulir
/// kalau tidak muat. Pegangan dan [header] bisa ditarik ke bawah untuk
/// menutup. Sheet setinggi isinya; bar atas layar level tetap terlihat di
/// atasnya seperti desain.
class KoSheet extends StatefulWidget {
  const KoSheet({
    super.key,
    required this.label,
    required this.header,
    required this.children,
    required this.onClose,
    this.footer,
  });

  /// Nama sheet untuk pembaca layar.
  final String label;
  final Widget header;
  final List<Widget> children;
  final VoidCallback onClose;
  final Widget? footer;

  /// Sheet naik [openRise] sambil muncul dalam [openTime] (`koSheet`).
  static const openTime = Duration(milliseconds: 350);
  static const double openRise = 60;

  /// Tarikan ke bawah sejauh [closeDrag], atau lebih cepat dari
  /// [closeFling] (px/detik), menutup sheet.
  static const double closeDrag = 80;
  static const double closeFling = 700;

  @override
  State<KoSheet> createState() => _KoSheetState();
}

class _KoSheetState extends State<KoSheet> with SingleTickerProviderStateMixin {
  /// Sheet kembali ke tempatnya kalau tarikan kurang jauh.
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..addListener(_onSettle);

  final _titleFocus = FocusNode();
  double _drag = 0;
  double _settleFrom = 0;

  @override
  void dispose() {
    _titleFocus.dispose();
    _settle.dispose();
    super.dispose();
  }

  void _onSettle() => setState(
    () => _drag = _settleFrom * (1 - Curves.easeOut.transform(_settle.value)),
  );

  void _dragBy(DragUpdateDetails details) {
    _settle.stop();
    setState(() => _drag = math.max(0, _drag + details.delta.dy));
  }

  void _release(DragEndDetails details) {
    final fling = details.primaryVelocity ?? 0;
    if (_drag > KoSheet.closeDrag || fling > KoSheet.closeFling) {
      widget.onClose();
    } else {
      _settleFrom = _drag;
      _settle.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    final media = MediaQuery.of(context);
    // Bar atas layar level (desain: sheet mulai 18 px di bawahnya).
    final top = media.padding.top + space.s8 + s.iconButton + space.s16;
    const sheetRadius = Radius.circular(KoUi.sheetRadius);

    final header = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: _dragBy,
      onVerticalDragEnd: _release,
      child: Column(
        children: [
          Container(
            width: s.sheetHandle,
            height: s.sheetHandleThickness,
            decoration: BoxDecoration(
              color: c.sheetHandle,
              borderRadius: BorderRadius.circular(context.koRadius.pill),
            ),
          ),
          SizedBox(height: space.s10),
          Focus(focusNode: _titleFocus, autofocus: true, child: widget.header),
        ],
      ),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: math.max(
            0,
            math.min(
              (media.size.height - media.padding.vertical) * .9,
              media.size.height - top - media.viewInsets.bottom,
            ),
          ),
        ),
        child: Transform.translate(
          offset: Offset(0, _drag),
          child: Material(
            type: MaterialType.transparency,
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: widget.label,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: KoUi.paper,
                  border: Border.all(color: KoUi.ink, width: KoUi.outline),
                  borderRadius: BorderRadius.vertical(top: sheetRadius),
                  boxShadow: context.koShadow.sheet,
                ),
                padding: EdgeInsets.fromLTRB(
                  space.s16,
                  space.s10,
                  space.s16,
                  space.s24 + media.padding.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    SizedBox(height: space.s10),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(top: space.s4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: widget.children,
                        ),
                      ),
                    ),
                    if (widget.footer != null) ...[
                      const SizedBox(height: KoUi.s12),
                      widget.footer!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol di kartu sheet ("Tonton iklan" dan bayar koin di sheet Petunjuk,
/// tombol hadiah di sheet Tambah Koin). Nonaktif = abu-abu tanpa bayangan.
class SheetButton extends StatelessWidget {
  const SheetButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.line,
    required this.edge,
    required this.onPressed,
    this.labelColor,
    this.silent = false,
    this.loading = false,
  });

  final String label;
  final Widget icon;
  final Color color;
  final Color line;
  final Color edge;
  final VoidCallback? onPressed;

  /// Lihat [KoPressable.silent].
  final bool silent;
  final bool loading;

  /// Warna label saat aktif; default [KoColors.ink].
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return UiButton(
      label: label,
      leading: icon,
      kind: color == context.koColors.brick
          ? UiButtonKind.danger
          : color == context.koColors.orange
          ? UiButtonKind.primary
          : UiButtonKind.secondary,
      silent: silent,
      loading: loading,
      onPressed: onPressed,
    );
  }
}
