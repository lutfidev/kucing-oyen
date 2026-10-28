import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';

import '../../app/game_audio.dart';
import '../../app/hint_source.dart';
import '../../game/kucing_game.dart';
import '../../game/model/hints.dart';
import '../../game/model/level_session.dart';
import '../../game/model/progress.dart';
import '../../game/model/rules.dart';
import '../../game/model/run_caption.dart';
import '../../game/model/run_clock.dart';
import '../../game/model/run_frames.dart';
import '../../game/model/sounds.dart';
import '../../game/render/render.dart';
import '../../game/sim/sim.dart';
import '../../l10n/captions.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../replay/replay_view.dart';
import '../result/result_view.dart';
import 'board_semantics.dart';
import 'hint_sheet.dart';
import 'level_bar.dart';
import 'level_board.dart';
import 'rules_sheet.dart';
import 'run_panel.dart';
import 'tray.dart';
import 'tutorial.dart';

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

/// Benda yang dipilih pembaca layar untuk ditaruh tanpa seret: dari baki
/// ([from] null) atau dari petak [from] di papan.
typedef _Pick = ({Item item, Pos? from});

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
/// demi langkah dengan caption, Jeda/Lanjutkan, ×2, dan "Lihat hasil", lalu
/// layar hasil ([ResultView]) menutupi layar level. Dari layar hasil, putar
/// ulang ([ReplayView]) menutupi layar hasil; tombol kembali (juga tombol
/// kembali sistem) menutupnya lagi.
///
/// Di fase atur, tombol Aturan membuka sheet kartu aturan ([rules]), tombol
/// bohlam membuka sheet Petunjuk ([hints]) yang tandanya tetap di papan
/// selama fase atur, dan [tutorial] (kalau ada) menutupi layar sampai yang
/// disorotnya dipakai atau dilewati.
///
/// Aturan ada di [LevelSession]. Layar ini hanya menerjemahkan seretan:
/// lepas di petak menyala = taruh atau pindah; benda dari papan yang
/// dilepas di luar papan kembali ke baki; selain itu benda kembali ke
/// tempat asalnya. Tanpa seret (pembaca layar): pilih slot baki atau benda
/// di papan, lalu ketuk petak yang boleh diisi; benda di papan juga punya
/// aksi "Kembalikan ke baki".
class LevelView extends StatefulWidget {
  const LevelView({
    super.key,
    required this.level,
    required this.backLabel,
    required this.onBack,
    required this.onNext,
    this.onResult,
    this.rules,
    this.tutorial,
    this.onTutorialDone,
    this.hints,
    this.costume = OyenCostume.none,
  });

  final Level level;

  /// Tombol kembali dan label pembaca layarnya.
  final String backLabel;
  final VoidCallback onBack;

  /// "Lanjut" di layar hasil: level berikutnya.
  final VoidCallback onNext;

  /// Dipanggil dengan bintang 0–3 setiap kali layar hasil dibuka;
  /// mengembalikan koin yang didapat (tampil di layar hasil).
  final int Function(int stars)? onResult;

  /// Kartu aturan yang terbuka; null = hanya dari nomor level (progres
  /// kosong).
  final Set<OyenRule>? rules;

  /// Tutorial yang ditampilkan saat layar dibuka; null = tidak ada.
  final Tutorial? tutorial;

  /// Tutorial selesai (dipakai atau dilewati).
  final VoidCallback? onTutorialDone;

  /// Saldo koin dan petunjuk yang terbuka; null = tanpa tombol Petunjuk.
  final HintSource? hints;

  /// Kostum Oyen dari Lemari Kostum: di papan, layar hasil, putar ulang,
  /// dan tutorial.
  final OyenCostume costume;

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
  final _wakeKey = GlobalKey();

  /// Kunci slot baki, tetap sepanjang layar: slot yang kuncinya berganti
  /// dibuat ulang dan seretannya hilang.
  final _slotKeys = {for (final item in Item.values) item: GlobalKey()};
  _ItemDrag? _drag;

  /// Benda yang dipilih pembaca layar; null = tidak ada.
  _Pick? _picked;

  /// Tutorial yang masih menutupi layar.
  late Tutorial? _tutorial = widget.tutorial;

  /// Fase jalan dan layar hasil; null di fase atur.
  _Run? _run;

  /// Putar ulang sedang terbuka di atas layar hasil.
  bool _replaying = false;
  Duration _lastTick = Duration.zero;
  bool _reduceMotion = false;

  Level get _level => widget.level;

  /// Ada vas di peta: status vas tampil di fase jalan.
  late final bool _hasVase = _level.board.copyCells().contains(Cell.tableVase);

  /// Koin yang didapat percobaan terakhir, untuk layar hasil.
  int _coinsEarned = 0;

  /// Langkah fase jalan terakhir yang suaranya sudah diputar.
  int _heardStep = 0;

  void _play(GameSound sound) => AudioScope.maybeRead(context)?.play(sound);

  @override
  void initState() {
    super.initState();
    widget.hints?.addListener(_onHints);
  }

  @override
  void didUpdateWidget(LevelView old) {
    super.didUpdateWidget(old);
    if (!identical(old.hints, widget.hints)) {
      old.hints?.removeListener(_onHints);
      widget.hints?.addListener(_onHints);
      _game.scene = _buildScene();
    }
  }

  /// Tingkat petunjuk baru dibuka: tandanya langsung tampil di papan.
  void _onHints() {
    if (mounted) _update(() {});
  }

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
    widget.hints?.removeListener(_onHints);
    _ticker.dispose();
    super.dispose();
  }

  /// Isi papan dari sesi. Fase atur: benda pemain (kecuali yang sedang
  /// diangkat dari papan), petak tujuan yang menyala, tanda petunjuk, dan
  /// Oyen tidur di petak awalnya. Fase jalan: keadaan papan di langkah yang
  /// tampil.
  BoardScene _buildScene() => _undressedScene().dressed(widget.costume);

  BoardScene _undressedScene() {
    final run = _run;
    if (run != null) {
      return runScene(_level.map, _session.placed, run.frames, run.clock.step);
    }
    final drag = _drag;
    final hintGlow = <Pos>{};
    final ghosts = <Pos, Item>{};
    final tier = widget.hints?.hintTier(_level.id) ?? 0;
    for (final MapEntry(key: pos, :value) in hintMarks(_level, tier).entries) {
      final placed = pos == drag?.from ? null : _session.itemAt(pos);
      // Jenis yang belum dibuka: benda apa pun memadamkan petak, supaya
      // jenisnya tidak bisa ditebak dengan coba-coba.
      if (placed == null || (value != null && placed != value)) {
        hintGlow.add(pos);
      }
      if (value != null && placed == null) ghosts[pos] = value;
    }
    // Benda dipilih tanpa seret: semua petak yang boleh diisi menyala.
    final board = _level.board;
    final targets = <Pos>{
      if (_picked != null)
        for (var y = 0; y < board.height; y++)
          for (var x = 0; x < board.width; x++)
            if (_session.canPlaceAt(Pos(x, y))) Pos(x, y),
    };
    return BoardScene.fromMap(
      _level.map,
      items: {
        for (final p in _session.placed)
          if (p.pos != drag?.from) p.pos: ItemArt.tileItem(p.item),
      },
      glow: {...hintGlow, ...targets, ?drag?.target},
      ghosts: ghosts,
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
    _update(() {
      _drag = drag;
      _picked = null;
    });
    _play(GameSound.pickUp);
    return _HandDrag(this, drag);
  }

  Drag? _startFromTray(Item item, Offset global) {
    final drag = _start(item, null, global);
    if (drag != null && _tutorial?.item == item) _finishTutorial();
    return drag;
  }

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
    _play(drag.target == null ? GameSound.back : GameSound.place);
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
    if (!_isCurrent(drag)) return;
    _play(GameSound.back);
    _update(() => _drag = null);
  }

  // ── Tanpa seret (pembaca layar) ─────────────────────────────────────

  void _announce(String message) => unawaited(
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
    ),
  );

  /// Memilih [item] dari baki ([from] null) atau dari petak [from].
  void _pick(Item item, Pos? from) {
    if (_drag != null || _session.phase != SessionPhase.arrange) return;
    _update(() => _picked = (item: item, from: from));
    _play(GameSound.pickUp);
    final l = context.l10n;
    _announce(l.itemPickedAnnounce(itemName(l, item)));
    if (from == null && _tutorial?.item == item) _finishTutorial();
  }

  /// Slot baki: pilih, atau batal kalau slot ini yang sedang dipilih.
  void _pickFromTray(Item item) {
    final picked = _picked;
    if (picked != null && picked.from == null && picked.item == item) {
      _unpick();
    } else if ((_session.remaining[item] ?? 0) > 0) {
      _pick(item, null);
    }
  }

  void _unpick() {
    if (_picked == null) return;
    _play(GameSound.back);
    _update(() => _picked = null);
  }

  /// Menaruh atau memindah benda yang dipilih ke petak [to].
  void _dropPicked(Pos to) {
    final picked = _picked;
    if (picked == null) return;
    final from = picked.from;
    var done = false;
    _update(() {
      done = from == null
          ? _session.place(picked.item, to)
          : _session.move(from, to);
      _picked = null;
    });
    if (!done) return;
    _play(GameSound.place);
    final l = context.l10n;
    _announce(
      l.itemPlacedAnnounce(itemName(l, picked.item), to.y + 1, to.x + 1),
    );
  }

  /// "Kembalikan ke baki" untuk benda pemain di petak [pos].
  void _returnToTray(Pos pos) {
    final item = _session.itemAt(pos);
    if (item == null || _drag != null) return;
    _update(() {
      _session.remove(pos);
      if (_picked?.from == pos) _picked = null;
    });
    _play(GameSound.back);
    final l = context.l10n;
    _announce(l.itemReturnedAnnounce(itemName(l, item)));
  }

  /// Petak papan untuk pembaca layar di fase atur, urut baris.
  List<BoardTileSemantics> _tileSemantics() {
    final l = context.l10n;
    final board = _level.board;
    return [
      for (var y = 0; y < board.height; y++)
        for (var x = 0; x < board.width; x++) _tileSemantic(l, Pos(x, y)),
    ];
  }

  BoardTileSemantics _tileSemantic(AppLocalizations l, Pos pos) {
    final board = _level.board;
    final picked = _picked;
    final item = _session.itemAt(pos);
    final content = item != null
        ? l.tilePlayerItem(itemName(l, item))
        : pos == board.start
        ? l.tileOyen(board.startDir.name)
        : cellName(l, board.cellAt(pos));
    final label = l.tileLabel(pos.y + 1, pos.x + 1, content);
    if (picked != null && _session.canPlaceAt(pos)) {
      return BoardTileSemantics(
        label: label,
        onTap: () => _dropPicked(pos),
        onTapHint: l.tilePlaceHint,
      );
    }
    if (item == null) return BoardTileSemantics(label: label);
    final isPicked = picked?.from == pos;
    return BoardTileSemantics(
      label: label,
      selected: isPicked,
      onTap: isPicked ? _unpick : () => _pick(item, pos),
      onTapHint: isPicked ? l.traySlotUnselectHint : l.tilePickHint,
      onReturn: () => _returnToTray(pos),
      returnLabel: l.tileReturn,
    );
  }

  // ── Fase ────────────────────────────────────────────────────────────

  // Tombol tetap aktif selama benda diseret, seperti desain 03. Kalau
  // ditekan jari lain, seretan dibatalkan dulu; sisa seretan itu diabaikan.
  void _wake() {
    // Ketukan kedua di bingkai yang sama sudah bukan fase atur.
    if (_session.phase != SessionPhase.arrange) return;
    if (_tutorial != null && _tutorial!.item == null) _finishTutorial();
    _update(() {
      _drag = null;
      _picked = null;
      final board = _level.board;
      final frames = runFrames(board, _session.wake());
      final l = context.l10n;
      final run = _Run(frames, [
        for (var i = 0; i < frames.length; i++)
          runCaptionText(l, runCaption(board, frames, i)),
      ]);
      if (_reduceMotion) run.clock.skipToEnd();
      _run = run;
    });
    _play(GameSound.wake);
    _heardStep = 0;
    _playStep();
    _syncTicker();
  }

  /// Fase jalan atau layar hasil → fase atur, susunan benda tetap ("Atur
  /// Lagi", "Coba Lagi").
  void _arrangeAgain() {
    if (_session.phase == SessionPhase.arrange) return;
    _update(() {
      _session.arrangeAgain();
      _run = null;
      _replaying = false;
    });
    _syncTicker();
  }

  /// "Lihat hasil": layar hasil.
  void _finish() {
    if (_session.phase != SessionPhase.running) return;
    _update(() {
      _session.finish();
      _coinsEarned = widget.onResult?.call(_session.stars!) ?? 0;
    });
    // Bintang dan koin berbunyi di layar hasil; gagal = Oyen bosan.
    if (_session.stars == 0) _play(GameSound.bored);
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
    if (clock.tick(dt > clock.interval ? clock.interval : dt)) {
      _update(() {});
      _playStep();
    }
    if (!clock.playing) _ticker.stop();
  }

  void _control(void Function(RunClock clock) action) {
    final clock = _run?.clock;
    if (clock == null) return;
    _update(() => action(clock));
    _playStep();
    _syncTicker();
  }

  /// Suara langkah yang baru tampil, hanya kalau maju tepat satu langkah:
  /// lompatan ke akhir (kurangi gerak) senyap.
  void _playStep() {
    final run = _run;
    if (run == null) return;
    final step = run.clock.step;
    if (step == _heardStep + 1) {
      if (stepSound(run.frame) case final sound?) _play(sound);
    }
    _heardStep = step;
  }

  void _togglePause() => _control((clock) => clock.togglePause());
  void _toggleFast() => _control((clock) => clock.toggleFast());
  void _stepOnce() => _control((clock) => clock.stepOnce());

  /// Tombol Aturan. Seretan yang sedang berjalan dibatalkan dulu, seperti
  /// tombol lain di fase atur.
  void _openRules() {
    if (_session.phase != SessionPhase.arrange) return;
    if (_drag != null) _update(() => _drag = null);
    showRulesSheet(
      context,
      learned: widget.rules ?? learnedRules(Progress.empty, _level.id),
    );
  }

  /// Tombol bohlam. Seretan yang sedang berjalan dibatalkan dulu.
  void _openHints() {
    final hints = widget.hints;
    if (hints == null || _session.phase != SessionPhase.arrange) return;
    if (_drag != null) _update(() => _drag = null);
    showHintSheet(context, level: _level, hints: hints);
  }

  void _finishTutorial() {
    setState(() => _tutorial = null);
    widget.onTutorialDone?.call();
  }

  void _clear() {
    _play(GameSound.back);
    _update(() {
      _drag = null;
      _picked = null;
      _session.reset();
    });
  }

  /// "Ulangi" di layar Berhasil: fase atur dengan papan kosong.
  void _restart() {
    if (_session.phase != SessionPhase.result) return;
    _update(() {
      _session.reset();
      _run = null;
      _replaying = false;
    });
    _syncTicker();
  }

  /// "Tonton putar ulang" dan "Putar Ulang" di layar hasil.
  void _openReplay() {
    if (_session.phase != SessionPhase.result) return;
    setState(() => _replaying = true);
  }

  void _closeReplay() => setState(() => _replaying = false);

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    final drag = _drag;
    final run = _run;
    final running = _session.phase == SessionPhase.running;
    final showResult = _session.phase == SessionPhase.result;

    // Tombol kembali sistem seperti tombol kembali di layar: putar ulang →
    // layar hasil; fase jalan dan layar hasil → fase atur (susunan tetap);
    // fase atur → peta.
    return PopScope(
      canPop: _session.phase == SessionPhase.arrange && !_replaying,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _replaying ? _closeReplay() : _arrangeAgain();
      },
      child: Scaffold(
        body: Stack(
          key: _stageKey,
          children: [
            // Layar level tetap terpasang di bawah layar hasil supaya papan
            // Flame tidak dilepas lalu dipasang lagi.
            Positioned.fill(
              child: Offstage(
                offstage: showResult,
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
                          title: levelTitle(context.l10n, _level),
                          backLabel: running
                              ? context.l10n.backToArrange
                              : widget.backLabel,
                          onBack: running ? _arrangeAgain : widget.onBack,
                          trailing: run == null
                              ? RulesButton(onPressed: _openRules)
                              : StepCounter(
                                  step: run.clock.step,
                                  announce: !run.clock.playing,
                                ),
                        ),
                        // Target dan tombol Petunjuk (desain 03). Barisnya
                        // tetap ada di fase jalan supaya papan tidak berubah
                        // ukuran.
                        if (_level.inventory.isNotEmpty ||
                            widget.hints != null) ...[
                          SizedBox(height: space.s10),
                          SizedBox(
                            height: context.koSize.iconButton,
                            child: Row(
                              children: [
                                if (_level.inventory.isNotEmpty)
                                  run == null
                                      // Mengecil kalau teksnya panjang.
                                      ? Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: AlignmentDirectional
                                                .centerStart,
                                            child: TargetChip(
                                              items: _level.starItems,
                                            ),
                                          ),
                                        )
                                      : RunStatus(
                                          vaseBroken: _hasVase
                                              ? run.frame.vaseBroken
                                              : null,
                                          itemsUsed: _session.itemsUsed,
                                        ),
                                const Spacer(),
                                if (run == null && widget.hints != null)
                                  HintButton(onPressed: _openHints),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: space.s12),
                        Expanded(
                          child: LevelBoard(
                            game: _game,
                            tiles: run == null ? _tileSemantics() : null,
                          ),
                        ),
                        SizedBox(height: space.s14),
                        _bottom(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Layar hasil tetap terpasang di bawah putar ulang supaya
            // bintangnya tidak muncul ulang; animasinya berhenti selama
            // tertutup.
            if (showResult)
              Positioned.fill(
                child: Offstage(
                  offstage: _replaying,
                  child: TickerMode(
                    enabled: !_replaying,
                    child: ResultView(
                      session: _session,
                      onArrange: _arrangeAgain,
                      onRestart: _restart,
                      onNext: widget.onNext,
                      onReplay: _openReplay,
                      coins: _coinsEarned,
                      costume: widget.costume,
                    ),
                  ),
                ),
              ),
            if (showResult && _replaying)
              Positioned.fill(
                child: ReplayView(
                  session: _session,
                  onBack: _closeReplay,
                  onMap: widget.onBack,
                  costume: widget.costume,
                ),
              ),
            if (_tutorial case final tutorial?
                when _session.phase == SessionPhase.arrange)
              Positioned.fill(
                child: TutorialOverlay(
                  tutorial: tutorial,
                  target: _slotKeys[tutorial.item] ?? _wakeKey,
                  targetRadius: tutorial.item == null
                      ? context.koRadius.primary
                      : context.koRadius.slot,
                  onSkip: _finishTutorial,
                  costume: widget.costume,
                ),
              ),
            if (drag != null) _lifted(drag),
          ],
        ),
      ),
    );
  }

  /// Bagian bawah: baki dan tombol (fase atur), atau caption dan kontrol
  /// putar (fase jalan; di bawah layar hasil). Tingginya sama di semua fase
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
        if (run != null) {
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
            KoButton(
              key: _wakeKey,
              label: context.l10n.wakeOyen,
              icon: KoIcons.wake,
              size: KoButtonSize.large,
              // Bunyi bangun menggantikan tap.
              silent: true,
              onPressed: _wake,
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

  /// Baki fase atur.
  Widget _tray() {
    if (_level.inventory.isEmpty) {
      return TrayMessage(context.l10n.trayEmpty);
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
      selected: _picked?.from == null ? _picked?.item : null,
      onSelect: _pickFromTray,
      onDragStart: _startFromTray,
      slotKeys: _slotKeys,
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
