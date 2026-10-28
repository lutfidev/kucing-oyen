import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'ko_pressable.dart';

/// Membuka sheet bawah (sheet Aturan desain 05 dan Petunjuk desain 10 di
/// layar level, sheet Tambah Koin di Beranda dan Lemari Kostum, konfirmasi
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
  final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: barrierLabel,
    barrierColor: barrierColor ?? context.koColors.scrim,
    transitionDuration: reduceMotion ? Duration.zero : KoSheet.openTime,
    pageBuilder: (context, _, _) {
      final route = ModalRoute.of(context);
      // Hanya menutup sheet ini, walau dipanggil lagi saat sheet sedang
      // menutup (layar level di bawahnya tidak ikut ditutup).
      return builder(context, () {
        if (route?.isCurrent ?? false) Navigator.of(context).pop();
      });
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
  );
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
  });

  /// Nama sheet untuk pembaca layar.
  final String label;
  final Widget header;
  final List<Widget> children;
  final VoidCallback onClose;

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

  double _drag = 0;
  double _settleFrom = 0;

  @override
  void dispose() {
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
    final sheetRadius = Radius.circular(context.koRadius.sheet);

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
          widget.header,
        ],
      ),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: math.max(0, media.size.height - top),
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
                  color: c.cream,
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
  });

  final String label;
  final Widget icon;
  final Color color;
  final Color line;
  final Color edge;
  final VoidCallback? onPressed;

  /// Lihat [KoPressable.silent].
  final bool silent;

  /// Warna label saat aktif; default [KoColors.ink].
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final enabled = onPressed != null;
    return KoPressable(
      onPressed: onPressed,
      silent: silent,
      semanticLabel: label,
      color: enabled ? color : c.disabled,
      borderColor: enabled ? line : c.disabledLine,
      borderWidth: s.border,
      edgeColor: enabled ? edge : null,
      depth: context.koShadow.pressIcon,
      radius: context.koRadius.icon,
      height: s.hintButton,
      padding: EdgeInsets.symmetric(horizontal: space.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox(width: space.s6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: context.koType.chipLabel.copyWith(
                  color: enabled ? labelColor ?? c.ink : c.onLockedSoft,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
