import 'package:flutter/material.dart';

import '../../game/model/house.dart';

/// Lama pindah ruangan (desain `TransisiRuang.dc.html`: 420 ms ease-in-out).
const housePageDuration = Duration(milliseconds: 420);

/// Area rumah yang bisa pindah ruangan seperti kamera berjalan lewat pintu:
/// ruang tengah di kiri, teras di kanan. Geser dari area kosong (ruang
/// tengah ke kiri, teras ke kanan) mengikuti jari; dilepas lewat sepertiga
/// lebar atau dilempar cepat = pindah, selain itu kembali. Mengganti
/// [room] dari luar (ketuk pintu atau chip) menggeser dengan animasi.
/// Kurangi gerak: langsung pindah. Kedua ruangan hanya dibangun selama
/// bergeser.
class HousePager extends StatefulWidget {
  const HousePager({
    super.key,
    required this.room,
    required this.onRoom,
    required this.builder,
    this.enabled = true,
    this.onArrive,
  });

  final HouseRoom room;

  /// Pindah ruangan karena geseran pemain.
  final ValueChanged<HouseRoom> onRoom;

  /// Isi satu ruangan.
  final Widget Function(BuildContext context, HouseRoom room) builder;

  /// False (mode Hias, kucing diangkat): geser ruangan tidak dikenali.
  final bool enabled;

  /// Ruangan sudah tampil penuh (akhir geser atau langsung pindah).
  final ValueChanged<HouseRoom>? onArrive;

  /// Lemparan yang cukup untuk pindah ruangan, px/detik.
  static const flingVelocity = 700.0;

  @override
  State<HousePager> createState() => _HousePagerState();
}

class _HousePagerState extends State<HousePager>
    with SingleTickerProviderStateMixin {
  /// 0 = ruang tengah penuh, 1 = teras penuh.
  late final AnimationController _position = AnimationController(
    vsync: this,
    duration: housePageDuration,
    value: _valueOf(widget.room),
  );

  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _position.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _arrived();
      }
    });
  }

  /// Dipanggil sesudah bingkai ini (bisa terjadi di tengah build).
  void _arrived() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final value = _position.value;
      if (mounted && (value == 0 || value == 1)) {
        widget.onArrive?.call(
          value == 0 ? HouseRoom.living : HouseRoom.terrace,
        );
      }
    });
  }

  static double _valueOf(HouseRoom room) => room == HouseRoom.living ? 0 : 1;

  bool get _still => MediaQuery.disableAnimationsOf(context);

  @override
  void didUpdateWidget(HousePager old) {
    super.didUpdateWidget(old);
    if (widget.room != old.room && !_dragging) _goTo(widget.room);
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  void _goTo(HouseRoom room) {
    final target = _valueOf(room);
    if (_still) {
      _position.value = target;
    } else {
      _position.animateTo(target, curve: Curves.easeInOut);
    }
  }

  void _dragUpdate(DragUpdateDetails details, double width) {
    _dragging = true;
    _position.value = (_position.value - details.primaryDelta! / width).clamp(
      0.0,
      1.0,
    );
  }

  void _dragEnd(DragEndDetails details) {
    _dragging = false;
    final from = widget.room;
    final velocity = details.primaryVelocity ?? 0;
    final moved = (_position.value - _valueOf(from)).abs();
    final toward = from == HouseRoom.living ? -velocity : velocity;
    final go = moved > 1 / 3 || toward > HousePager.flingVelocity;
    final target = go && moved > 0 ? from.other : from;
    _goTo(target);
    if (target != from) widget.onRoom(target);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: widget.enabled
              ? (d) => _dragUpdate(d, width)
              : null,
          onHorizontalDragEnd: widget.enabled ? _dragEnd : null,
          onHorizontalDragCancel: widget.enabled
              ? () => _dragEnd(DragEndDetails(primaryVelocity: 0))
              : null,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _position,
              builder: (context, _) {
                final p = _position.value;
                return Stack(
                  children: [
                    if (p < 1)
                      Positioned(
                        key: const ValueKey('house-living'),
                        left: -p * width,
                        top: 0,
                        width: width,
                        bottom: 0,
                        child: widget.builder(context, HouseRoom.living),
                      ),
                    if (p > 0)
                      Positioned(
                        key: const ValueKey('house-terrace'),
                        left: (1 - p) * width,
                        top: 0,
                        width: width,
                        bottom: 0,
                        child: widget.builder(context, HouseRoom.terrace),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
