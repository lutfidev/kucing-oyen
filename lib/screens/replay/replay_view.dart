import 'package:flutter/widgets.dart';

import '../../game/model/level_session.dart';
import '../../game/model/replay.dart';
import '../../game/model/run_frames.dart';
import '../../game/render/render.dart';
import '../../l10n/captions.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../result/result_parts.dart';
import 'replay_parts.dart';

/// Putar ulang (desain 09) percobaan [session] yang sudah di layar hasil:
/// papan di langkah mana pun dengan seluruh jalur dan nomor jejak, caption
/// per langkah, slider waktu, dan mundur/maju satu langkah.
///
/// Keadaan papan tiap langkah dibangun ulang dari `SimResult.trace`
/// (`runFrames`), tanpa menjalankan ulang simulasi. Dibuka di langkah 0.
class ReplayView extends StatefulWidget {
  const ReplayView({
    super.key,
    required this.session,
    required this.onBack,
    required this.onMap,
    this.costume = OyenCostume.none,
  });

  /// Kostum Oyen dari Lemari Kostum.
  final OyenCostume costume;

  /// Sesi di fase hasil.
  final LevelSession session;

  /// Tombol kembali: layar hasil.
  final VoidCallback onBack;

  /// "Kembali ke peta".
  final VoidCallback onMap;

  @override
  State<ReplayView> createState() => _ReplayViewState();
}

class _ReplayViewState extends State<ReplayView> {
  late final _level = widget.session.level;
  late final _result = widget.session.result!;
  late final _placed = widget.session.placed;
  late final _frames = runFrames(_level.board, _result);
  late final _trail = replayTrail(_frames);
  late final _captions = replayCaptions(_level.board, _result, _frames);
  int _step = 0;

  int get _last => _frames.length - 1;

  void _go(int step) => setState(() => _step = step.clamp(0, _last));

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    final l = context.l10n;
    final captions = [for (final c in _captions) replayCaptionText(l, c)];
    return ResultPage(
      background: context.koColors.cream,
      children: [
        ReplayBar(
          kicker: 'Level ${_level.id} · ${_level.name}',
          onBack: widget.onBack,
        ),
        SizedBox(height: space.s24),
        Expanded(
          child: ReplayBoard(
            scene: replayScene(
              _level.map,
              _placed,
              _frames,
              _trail,
              _step,
            ).dressed(widget.costume),
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
          ),
        ),
        SizedBox(height: space.s14),
        ReplaySlider(value: _step, max: _last, onChanged: _go),
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
