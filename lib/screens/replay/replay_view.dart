import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../game/model/level_session.dart';
import '../../game/model/replay.dart';
import '../../game/model/run_frames.dart';
import '../../game/render/render.dart';
import '../../l10n/captions.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/theme.dart';
import '../result/result_parts.dart';
import 'replay_parts.dart';

/// Putar ulang (desain 09) percobaan [session] yang sudah di layar hasil:
/// papan di langkah mana pun dengan seluruh jalur dan nomor jejak, caption
/// per langkah, slider waktu, mundur/maju satu langkah, dan putar otomatis
/// (tidak ada di desain; disembunyikan saat kurangi gerak).
///
/// Keadaan papan tiap langkah dibangun ulang dari `SimResult.trace`
/// (`runFrames`), tanpa menjalankan ulang simulasi. Dibuka di langkah 0.
class ReplayView extends StatefulWidget {
  const ReplayView({
    super.key,
    required this.session,
    required this.onBack,
    required this.onMap,
  });

  /// Sesi di fase hasil.
  final LevelSession session;

  /// Tombol kembali: layar hasil.
  final VoidCallback onBack;

  /// "Kembali ke peta".
  final VoidCallback onMap;

  /// Lama satu langkah saat putar otomatis: lebih lambat dari fase jalan
  /// supaya caption sempat terbaca.
  static const autoStepTime = Duration(milliseconds: 700);

  @override
  State<ReplayView> createState() => _ReplayViewState();
}

class _ReplayViewState extends State<ReplayView>
    with SingleTickerProviderStateMixin {
  late final _level = widget.session.level;
  late final _result = widget.session.result!;
  late final _placed = widget.session.placed;
  late final _frames = runFrames(_level.board, _result);
  late final _trail = replayTrail(_frames);
  late final _captions = replayCaptions(_level.board, _result, _frames);
  late final Ticker _ticker = createTicker(_onTick);
  int _step = 0;
  bool _reduceMotion = false;

  /// Waktu sejak langkah terakhir dimajukan putar otomatis.
  Duration _sinceStep = Duration.zero;
  Duration _lastTick = Duration.zero;

  int get _last => _frames.length - 1;

  bool get _playing => _ticker.isActive;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_reduceMotion) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// Slider dan tombol langkah: pindah ke [step] dan hentikan putar otomatis.
  void _go(int step) {
    _ticker.stop();
    setState(() => _step = step.clamp(0, _last));
  }

  /// Putar dari langkah ini (dari awal kalau sudah di akhir), atau jeda.
  void _togglePlay() {
    if (_playing) {
      setState(_ticker.stop);
      return;
    }
    if (_last == 0) return;
    setState(() {
      if (_step == _last) _step = 0;
      _sinceStep = Duration.zero;
      _lastTick = Duration.zero;
      _ticker.start();
    });
  }

  /// Maju paling banyak satu langkah per bingkai, berhenti di akhir.
  void _onTick(Duration elapsed) {
    _sinceStep += elapsed - _lastTick;
    _lastTick = elapsed;
    if (_sinceStep < ReplayView.autoStepTime) return;
    _sinceStep = Duration.zero;
    setState(() {
      _step++;
      if (_step >= _last) _ticker.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    final l = context.l10n;
    final captions = [for (final c in _captions) replayCaptionText(l, c)];
    return ResultPage(
      background: context.koColors.cream,
      children: [
        ReplayBar(kicker: levelTitle(l, _level), onBack: widget.onBack),
        SizedBox(height: space.s24),
        Expanded(
          child: ReplayBoard(
            scene: replayScene(_level.map, _placed, _frames, _trail, _step),
          ),
        ),
        SizedBox(height: space.s16),
        LayoutBuilder(
          builder: (context, constraints) => ReplayCaption(
            step: _step,
            text: captions[_step],
            lines: ReplayCaption.linesFor(
              context,
              constraints.maxWidth,
              captions,
            ),
            announce: !_playing,
          ),
        ),
        SizedBox(height: space.s14),
        Row(
          children: [
            if (!_reduceMotion) ...[
              ReplayPlayButton(playing: _playing, onPressed: _togglePlay),
              SizedBox(width: space.s12),
            ],
            Expanded(
              child: ReplaySlider(value: _step, max: _last, onChanged: _go),
            ),
          ],
        ),
        SizedBox(height: space.s16),
        ReplayControls(
          onPrev: _step > 0 ? () => _go(_step - 1) : null,
          onNext: _step < _last ? () => _go(_step + 1) : null,
          onMap: widget.onMap,
        ),
      ],
    );
  }
}
