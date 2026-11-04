import 'package:flutter/widgets.dart';

/// Bunyi "tap" tombol. Dipasang lapisan aplikasi (`AudioScope` memasangnya
/// di bawahnya), supaya `lib/widgets/` tidak bergantung pada `lib/app/`.
/// Tanpa scope ini (mis. test widget) tombol senyap.
class TapSoundScope extends InheritedWidget {
  const TapSoundScope({super.key, required this.play, required super.child});

  /// Memutar bunyi tap (sakelar Efek suara diurus pemiliknya).
  final VoidCallback play;

  /// Dibaca saat diketuk, tanpa membuat widget bergantung pada scope ini.
  static VoidCallback? maybeRead(BuildContext context) =>
      context.getInheritedWidgetOfExactType<TapSoundScope>()?.play;

  @override
  bool updateShouldNotify(TapSoundScope oldWidget) => false;
}

/// [action] yang lebih dulu membunyikan tap lewat [TapSoundScope]; null
/// tetap null (tombol nonaktif senyap).
VoidCallback? tapSound(BuildContext context, VoidCallback? action) =>
    action == null
    ? null
    : () {
        TapSoundScope.maybeRead(context)?.call();
        action();
      };
