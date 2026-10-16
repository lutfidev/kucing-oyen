import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../game/kucing_game.dart';
import '../../game/model/level_session.dart';
import '../../game/render/render.dart';
import '../../game/sim/sim.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'level_bar.dart';
import 'level_board.dart';
import 'tray.dart';

/// Benda yang sedang diseret jari, dari baki atau dari papan.
class _ItemDrag {
  _ItemDrag({required this.item, required this.from, required this.finger});

  final Item item;

  /// Petak asal di papan; null = dari baki.
  final Pos? from;

  /// Posisi jari di layar.
  Offset finger;

  /// Posisi jari di koordinat layar level, untuk menggambar benda di tangan.
  Offset local = Offset.zero;

  /// Petak di bawah jari yang boleh diisi (menyala), atau null.
  Pos? target;
}

/// Layar satu level: bar atas, target bintang, papan [KucingGame], baki,
/// dan tombol "Bangunkan Oyen".
///
/// Aturan ada di [LevelSession]. Layar ini hanya menerjemahkan seretan:
/// lepas di petak menyala = taruh atau pindah; benda dari papan yang
/// dilepas di luar papan kembali ke baki; selain itu benda kembali ke
/// tempat asalnya.
class LevelView extends StatefulWidget {
  const LevelView({
    super.key,
    required this.level,
    required this.backLabel,
    required this.onBack,
  });

  final Level level;

  /// Tombol kembali dan label pembaca layarnya.
  final String backLabel;
  final VoidCallback onBack;

  @override
  State<LevelView> createState() => _LevelViewState();
}

class _LevelViewState extends State<LevelView> implements BoardInput {
  late final LevelSession _session = LevelSession(widget.level);
  late final KucingGame _game = KucingGame(scene: _buildScene(), input: this);
  final _stageKey = GlobalKey();
  _ItemDrag? _drag;

  Level get _level => widget.level;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Loop Flame tidak ikut TickerMode sendiri (rute tertutup rute lain).
    _game.animate =
        TickerMode.valuesOf(context).enabled &&
        !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
  }

  /// Isi papan dari sesi: benda pemain (kecuali yang sedang diangkat dari
  /// papan) dan petak tujuan yang menyala. Oyen tidur di petak awalnya.
  BoardScene _buildScene() {
    final drag = _drag;
    return BoardScene.fromMap(
      _level.map,
      items: {
        for (final p in _session.placed)
          if (p.pos != drag?.from) p.pos: ItemArt.tileItem(p.item),
      },
      glow: {?drag?.target},
    );
  }

  /// Mengubah keadaan lalu menggambar ulang layar dan papan.
  void _update(VoidCallback change) {
    setState(change);
    _game.scene = _buildScene();
  }

  // ── Seret ───────────────────────────────────────────────────────────

  Offset _toStage(Offset global) {
    final stage = _stageKey.currentContext?.findRenderObject() as RenderBox?;
    return stage?.globalToLocal(global) ?? global;
  }

  Pos? _targetAt(Offset global) {
    final tile = _game.tileAtGlobal(global);
    return tile != null && _session.canPlaceAt(tile) ? tile : null;
  }

  /// Mulai menyeret [item] (dari petak [from], atau dari baki kalau null).
  /// Satu seretan sekaligus, hanya di fase atur.
  Drag? _start(Item item, Pos? from, Offset global) {
    if (_drag != null || _session.phase != SessionPhase.arrange) return null;
    final drag = _ItemDrag(item: item, from: from, finger: global)
      ..local = _toStage(global)
      ..target = _targetAt(global);
    _update(() => _drag = drag);
    return _HandDrag(this, drag);
  }

  Drag? _startFromTray(Item item, Offset global) => _start(item, null, global);

  @override
  Drag? pickUp(Pos tile, Offset global) {
    final item = _session.itemAt(tile);
    return item == null ? null : _start(item, tile, global);
  }

  /// Seretan yang sudah dibatalkan (mis. tombol ditekan jari lain) atau
  /// yang layarnya sudah ditutup tidak boleh lagi mengubah apa pun.
  bool _isCurrent(_ItemDrag drag) => mounted && identical(drag, _drag);

  void _dragBy(_ItemDrag drag, Offset delta) {
    if (!_isCurrent(drag)) return;
    final finger = drag.finger + delta;
    final local = _toStage(finger);
    final target = _targetAt(finger);
    void move() => drag
      ..finger = finger
      ..local = local
      ..target = target;
    // Papan digambar ulang hanya kalau petak tujuannya berganti.
    target == drag.target ? setState(move) : _update(move);
  }

  void _drop(_ItemDrag drag) {
    if (!_isCurrent(drag)) return;
    _update(() {
      _drag = null;
      final target = drag.target;
      final from = drag.from;
      if (target != null) {
        if (from == null) {
          _session.place(drag.item, target);
        } else {
          _session.move(from, target);
        }
      } else if (from != null && _game.tileAtGlobal(drag.finger) == null) {
        _session.remove(from);
      }
    });
  }

  void _cancel(_ItemDrag drag) {
    if (_isCurrent(drag)) _update(() => _drag = null);
  }

  // ── Fase ────────────────────────────────────────────────────────────

  // Tombol tetap aktif selama benda diseret, seperti desain 03. Kalau
  // ditekan jari lain, seretan dibatalkan dulu; sisa seretan itu diabaikan.
  void _wake() => _update(() {
    _drag = null;
    _session.wake();
  });

  void _arrangeAgain() => _update(_session.arrangeAgain);

  void _clear() => _update(() {
    _drag = null;
    _session.reset();
  });

  /// Hasil sementara sampai animasi jalan (langkah 7) dan layar hasil
  /// (langkah 8) dibuat.
  String _resultText(SimResult result) {
    if (result.win) {
      final broken = result.vaseBrokenAtStep;
      if (broken != null) {
        return 'Oyen sampai, tapi vas pecah di langkah $broken. '
            '${_session.stars} bintang.';
      }
      return 'Oyen sampai di mangkuk! ${result.steps} langkah, '
          '${_session.stars} bintang.';
    }
    return switch (result.failReason) {
      FailReason.tooManySteps =>
        'Oyen kelamaan jalan, lewat $maxSteps langkah.',
      _ => 'Oyen bosan mondar-mandir.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    final drag = _drag;
    final arranging = _session.phase == SessionPhase.arrange;
    final result = _session.result;

    final Widget panel;
    if (result != null) {
      panel = TrayMessage(_resultText(result), strong: true);
    } else if (_level.inventory.isEmpty) {
      panel = const TrayMessage('Level ini belum butuh benda.');
    } else {
      final remaining = _session.remaining;
      final fromTray = drag != null && drag.from == null ? drag.item : null;
      panel = TrayPanel(
        counts: {
          for (final item in _level.inventory.keys)
            item: remaining[item]! - (item == fromTray ? 1 : 0),
        },
        dragging: fromTray,
        onDragStart: _startFromTray,
        onClear: _session.itemsUsed > 0 ? _clear : null,
      );
    }

    return Scaffold(
      body: Stack(
        key: _stageKey,
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  space.gutter,
                  space.s8,
                  space.gutter,
                  space.s16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LevelTopBar(
                      title: 'Level ${_level.id} · ${_level.name}',
                      backLabel: widget.backLabel,
                      onBack: widget.onBack,
                      onRules: null,
                    ),
                    if (_level.inventory.isNotEmpty) ...[
                      SizedBox(height: space.s10),
                      SizedBox(
                        height: context.koSize.iconButton,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TargetChip(items: _level.starItems),
                        ),
                      ),
                    ],
                    SizedBox(height: space.s12),
                    Expanded(child: LevelBoard(game: _game)),
                    SizedBox(height: space.s14),
                    panel,
                    SizedBox(height: space.s16),
                    if (arranging)
                      KoButton(
                        label: 'Bangunkan Oyen',
                        icon: KoIcons.wake,
                        size: KoButtonSize.large,
                        onPressed: _wake,
                      )
                    else
                      KoButton(
                        label: 'Atur Lagi',
                        size: KoButtonSize.large,
                        onPressed: _arrangeAgain,
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (drag != null) _lifted(drag),
        ],
      ),
    );
  }

  /// Benda di tangan, mengikuti jari.
  Widget _lifted(_ItemDrag drag) {
    final center = drag.local + ItemArt.liftFromFinger;
    const half = ItemArt.liftSize / 2;
    return Positioned(
      left: center.dx - half,
      top: center.dy - half,
      child: IgnorePointer(child: LiftedItemView(drag.item)),
    );
  }
}

/// Penerima satu seretan, dari slot baki maupun dari papan.
class _HandDrag implements Drag {
  _HandDrag(this._view, this._drag);

  final _LevelViewState _view;
  final _ItemDrag _drag;

  /// Posisi di event pertama masih posisi awal sentuhan; jumlahkan geseran.
  @override
  void update(DragUpdateDetails details) => _view._dragBy(_drag, details.delta);

  @override
  void end(DragEndDetails details) => _view._drop(_drag);

  @override
  void cancel() => _view._cancel(_drag);
}
