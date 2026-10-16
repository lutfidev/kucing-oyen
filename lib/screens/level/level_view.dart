import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../game/kucing_game.dart';
import '../../game/model/level_session.dart';
import '../../game/model/run_caption.dart';
import '../../game/model/run_clock.dart';
import '../../game/model/run_frames.dart';
import '../../game/render/render.dart';
import '../../game/sim/sim.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'level_bar.dart';
import 'level_board.dart';
import 'run_panel.dart';
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

/// Keadaan fase jalan: langkah-langkah Oyen dan jam pemutarnya.
class _Run {
  _Run(this.frames, this.captions) : clock = RunClock(frames.length - 1);

  final List<RunFrame> frames;
  final List<String> captions;
  final RunClock clock;

  RunFrame get frame => frames[clock.step];
  String get caption => captions[clock.step];
}

/// Layar satu level: bar atas, target bintang, papan [KucingGame], baki,
/// dan tombol "Bangunkan Oyen"; setelah dibangunkan, Oyen berjalan langkah
/// demi langkah dengan caption, Jeda/Lanjutkan, ×2, dan "Lihat hasil".
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

class _LevelViewState extends State<LevelView>
    with SingleTickerProviderStateMixin
    implements BoardInput {
  late final LevelSession _session = LevelSession(widget.level);
  late final KucingGame _game = KucingGame(scene: _buildScene(), input: this);
  late final Ticker _ticker = createTicker(_onTick);
  final _stageKey = GlobalKey();
  _ItemDrag? _drag;

  /// Fase jalan dan layar hasil sementara; null di fase atur.
  _Run? _run;
  Duration _lastTick = Duration.zero;
  bool _reduceMotion = false;

  Level get _level => widget.level;

  /// Ada vas di peta: status vas tampil di fase jalan.
  late final bool _hasVase = _level.board.copyCells().contains(Cell.tableVase);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    // Loop Flame tidak ikut TickerMode sendiri (rute tertutup rute lain).
    _game.animate = TickerMode.valuesOf(context).enabled && !_reduceMotion;
    final clock = _run?.clock;
    if (_reduceMotion && clock != null && !clock.done) {
      clock.skipToEnd();
      _syncTicker();
      _game.scene = _buildScene();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// Isi papan dari sesi. Fase atur: benda pemain (kecuali yang sedang
  /// diangkat dari papan), petak tujuan yang menyala, dan Oyen tidur di
  /// petak awalnya. Fase jalan: keadaan papan di langkah yang tampil.
  BoardScene _buildScene() {
    final run = _run;
    if (run != null) {
      return runScene(_level.map, _session.placed, run.frames, run.clock.step);
    }
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
  void _wake() {
    // Ketukan kedua di bingkai yang sama sudah bukan fase atur.
    if (_session.phase != SessionPhase.arrange) return;
    _update(() {
      _drag = null;
      final board = _level.board;
      final frames = runFrames(board, _session.wake());
      final run = _Run(frames, [
        for (var i = 0; i < frames.length; i++) runCaption(board, frames, i),
      ]);
      if (_reduceMotion) run.clock.skipToEnd();
      _run = run;
    });
    _syncTicker();
  }

  /// Fase jalan atau layar hasil → fase atur, susunan benda tetap.
  void _arrangeAgain() {
    if (_session.phase == SessionPhase.arrange) return;
    _update(() {
      _session.arrangeAgain();
      _run = null;
    });
    _syncTicker();
  }

  /// "Lihat hasil": layar hasil sementara sampai langkah 8.
  void _finish() {
    if (_session.phase == SessionPhase.running) _update(_session.finish);
  }

  // ── Fase jalan ──────────────────────────────────────────────────────

  /// Ticker jalan selama jam [_run] berputar; Oyen digeser selama satu
  /// langkah.
  void _syncTicker() {
    final clock = _run?.clock;
    _game.moveTime = clock == null
        ? 0
        : clock.interval.inMicroseconds / Duration.microsecondsPerSecond;
    if (clock == null || !clock.playing) {
      _ticker.stop();
    } else if (!_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final clock = _run?.clock;
    final dt = elapsed - _lastTick;
    _lastTick = elapsed;
    if (clock == null) return;
    // Selama aplikasi di latar belakang atau rute tertutup, waktu ticker
    // tetap berjalan; jangan sampai Oyen melompati langkah sekaligus.
    if (clock.tick(dt > clock.interval ? clock.interval : dt)) _update(() {});
    if (!clock.playing) _ticker.stop();
  }

  void _control(void Function(RunClock clock) action) {
    final clock = _run?.clock;
    if (clock == null) return;
    _update(() => action(clock));
    _syncTicker();
  }

  void _togglePause() => _control((clock) => clock.togglePause());
  void _toggleFast() => _control((clock) => clock.toggleFast());
  void _stepOnce() => _control((clock) => clock.stepOnce());

  void _clear() => _update(() {
    _drag = null;
    _session.reset();
  });

  /// Hasil sementara sampai layar hasil (langkah 8) dibuat.
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
    final run = _run;
    final running = _session.phase == SessionPhase.running;

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
                      backLabel: running
                          ? 'Kembali ke fase atur'
                          : widget.backLabel,
                      onBack: running ? _arrangeAgain : widget.onBack,
                      trailing: run == null
                          ? const RulesButton(onPressed: null)
                          : StepCounter(step: run.clock.step),
                    ),
                    if (_level.inventory.isNotEmpty) ...[
                      SizedBox(height: space.s10),
                      SizedBox(
                        height: context.koSize.iconButton,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: run == null
                              ? TargetChip(items: _level.starItems)
                              : RunStatus(
                                  vaseBroken: _hasVase
                                      ? run.frame.vaseBroken
                                      : null,
                                  itemsUsed: _session.itemsUsed,
                                ),
                        ),
                      ),
                    ],
                    SizedBox(height: space.s12),
                    Expanded(child: LevelBoard(game: _game)),
                    SizedBox(height: space.s14),
                    _bottom(),
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

  /// Bagian bawah: baki dan tombol (fase atur, hasil sementara), atau
  /// caption dan kontrol putar (fase jalan). Tingginya sama di semua fase
  /// supaya papan tidak berubah ukuran saat Oyen dibangunkan atau caption
  /// berganti.
  Widget _bottom() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final space = context.koSpace;
        final s = context.koSize;
        final run = _run;
        final lines = run == null
            ? RunCaption.minLines
            : RunCaption.linesFor(context, constraints.maxWidth, run.captions);
        final runHeight =
            RunCaption.heightFor(context, lines) +
            space.s24 +
            RunControls.heightOf(context);
        final arrangeHeight = s.tray + space.s16 + s.buttonLarge;
        final List<Widget> children;
        if (run != null && _session.phase == SessionPhase.running) {
          final clock = run.clock;
          children = [
            RunCaption(step: clock.step, text: run.caption, lines: lines),
            SizedBox(height: space.s24),
            if (clock.done)
              RunDoneButton(onPressed: _finish)
            else
              RunControls(
                playing: clock.playing,
                fast: clock.fast,
                onStepOnce: _stepOnce,
                onTogglePlay: _togglePause,
                onToggleFast: _toggleFast,
              ),
          ];
        } else {
          children = [
            _tray(),
            SizedBox(height: space.s16),
            if (_session.phase == SessionPhase.arrange)
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
          ];
        }
        return SizedBox(
          height: math.max(runHeight, arrangeHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );
      },
    );
  }

  /// Baki (fase atur) atau hasil sementara (layar hasil).
  Widget _tray() {
    final result = _session.result;
    if (result != null) return TrayMessage(_resultText(result), strong: true);
    if (_level.inventory.isEmpty) {
      return const TrayMessage('Level ini belum butuh benda.');
    }
    final drag = _drag;
    final remaining = _session.remaining;
    final fromTray = drag != null && drag.from == null ? drag.item : null;
    return TrayPanel(
      counts: {
        for (final item in _level.inventory.keys)
          item: remaining[item]! - (item == fromTray ? 1 : 0),
      },
      dragging: fromTray,
      onDragStart: _startFromTray,
      onClear: _session.itemsUsed > 0 ? _clear : null,
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
