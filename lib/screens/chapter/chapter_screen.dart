import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';

import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/accessories.dart';
import '../../game/model/chapter.dart';
import '../../game/model/kitties.dart';
import '../../game/model/map_walk.dart';
import '../../game/model/progress.dart';
import '../../game/render/render.dart';
import '../../game/sim/sim.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'chapter_header.dart';
import 'chapter_intro.dart';
import 'chapter_map.dart';

/// Rute `/babak/:chapter`: peta babak dari [ProgressScope]. Dari "Lanjut",
/// [walkFrom] = level yang baru dimenangkan dan [intro] = babak ini baru
/// terbuka.
class ChapterScreen extends StatelessWidget {
  const ChapterScreen({
    super.key,
    required this.chapter,
    this.walkFrom,
    this.intro = false,
  });

  /// Nomor babak; null kalau path-nya bukan angka.
  final int? chapter;

  /// `?dari=`: diteruskan hanya kalau level itu ada di babak ini dan
  /// bukan bosnya, atau bos babak terakhir (Oyen berdiri di bos).
  final int? walkFrom;

  /// `?baru=1`: kartu "Babak baru terbuka!" (desain 23c).
  final bool intro;

  @override
  Widget build(BuildContext context) {
    final controller = ProgressScope.of(context);
    final number = chapter;
    final current = number == null ? null : controller.chapter(number);
    void home() => context.go(AppRoutes.home);
    if (current == null) return _NotFound(onBack: home);

    final chapters = controller.chapters;
    final i = chapters.indexOf(current);
    final other = i > 0
        ? chapters[i - 1]
        : (i + 1 < chapters.length ? chapters[i + 1] : null);
    final from = walkFrom;
    final ids = current.ids.toList();
    final validFrom =
        from != null &&
        ids.contains(from) &&
        (from != current.boss.id || current == chapters.last);
    return ChapterView(
      key: ValueKey(current.number),
      chapter: current,
      other: other,
      progress: controller.progress,
      onBack: home,
      onOpen: (chapter) => context.go(AppRoutes.chapter(chapter.number)),
      onPlay: (level) =>
          context.go(AppRoutes.level(level.id, chapter: level.chapter)),
      walkFrom: validFrom ? from : null,
      intro: intro && current.isUnlocked(controller.progress),
      oyenAccessory: controller.home.closet.wearingOf(KittyId.oyen),
    );
  }
}

/// Peta babak bergambar (desain 23): judul tetap di atas, peta di bawahnya
/// bisa digulir kalau layarnya pendek. Peta selebar layar dengan skala
/// lebar layar ÷ 390, dan dibuka dengan token Oyen di tengah.
///
/// Dengan [walkFrom] (dari "Lanjut" level itu), Oyen berjalan dari node
/// level itu ke node berikutnya lalu level berikutnya dibuka sendiri
/// ([MapWalk]); sentuhan apa pun atau tombol kembali membatalkan
/// pembukaannya. Saat pembaca layar aktif, tidak ada pembukaan otomatis.
class ChapterView extends StatefulWidget {
  const ChapterView({
    super.key,
    required this.chapter,
    required this.other,
    required this.progress,
    required this.onBack,
    required this.onOpen,
    required this.onPlay,
    this.walkFrom,
    this.intro = false,
    this.oyenAccessory,
  });

  final Chapter chapter;
  final Chapter? other;
  final Progress progress;
  final VoidCallback onBack;
  final ValueChanged<Chapter> onOpen;
  final ValueChanged<Level> onPlay;

  /// Level yang baru dimenangkan lewat "Lanjut"; null = tanpa jalan.
  final int? walkFrom;

  /// Kartu "Babak baru terbuka!" di atas peta sampai ditutup.
  final bool intro;

  /// Aksesoris yang sedang dipakai Oyen di rumah.
  final AccessoryId? oyenAccessory;

  /// Node tempat token berdiri: node sesudah [walkFrom] kalau sah (level
  /// babak ini, bukan bos), bos kalau [walkFrom] = bos, selain itu level
  /// saat ini; bos kalau babak selesai; null kalau babak terkunci.
  static int? tokenIndexOf(
    Chapter chapter,
    Progress progress, {
    int? walkFrom,
  }) {
    final ids = chapter.ids.toList();
    final from = walkFrom == null ? -1 : ids.indexOf(walkFrom);
    if (from >= 0) return math.min(from + 1, ids.length - 1);
    if (!chapter.isUnlocked(progress)) return null;
    final current = progress.current(ids);
    return current == null ? ids.length - 1 : ids.indexOf(current);
  }

  @override
  State<ChapterView> createState() => _ChapterViewState();
}

class _ChapterViewState extends State<ChapterView>
    with SingleTickerProviderStateMixin {
  ScrollController? _scroll;
  double _scale = 1;
  double _viewport = 0;

  /// Bingkai terpanjang yang dimajukan sekaligus (detik).
  static const double _maxFrame = 0.1;

  late final Ticker _ticker = createTicker(_onTick);
  Duration _last = Duration.zero;

  /// Jalan yang sedang berlangsung, dari node [_walkIndex].
  MapWalk? _walk;
  int _walkIndex = 0;
  bool _announced = false;
  bool _pendingWalk = true;
  late bool _introOpen = widget.intro;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pendingWalk) {
      _pendingWalk = false;
      _startWalk();
    }
  }

  @override
  void didUpdateWidget(ChapterView old) {
    super.didUpdateWidget(old);
    if (widget.intro && !old.intro) _introOpen = true;
    if (old.walkFrom != widget.walkFrom) {
      _startWalk();
      // Tanpa walkFrom (level terbuka di atas peta): peta diam di bawah
      // halaman level yang sedang masuk, tidak melompat ke level saat ini.
      final scroll = _scroll;
      if (widget.walkFrom != null && scroll != null && scroll.hasClients) {
        scroll.jumpTo(_initialOffset());
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scroll?.dispose();
    super.dispose();
  }

  /// Layar kecil (`n360`): node lebih kecil, jalur dirapatkan.
  bool get _compact =>
      MediaQuery.sizeOf(context).height < context.koSize.roomCompactHeight;

  /// Indeks [walkFrom] di babak ini kalau Oyen harus berjalan darinya.
  int? get _walkStart {
    final from = widget.walkFrom;
    if (from == null) return null;
    final ids = widget.chapter.ids.toList();
    final i = ids.indexOf(from);
    return i >= 0 && i + 1 < ids.length ? i : null;
  }

  /// Oyen berdiri senang di bos sesudah bos dimenangkan lewat "Lanjut".
  bool get _atBossHappy =>
      widget.walkFrom != null && widget.walkFrom == widget.chapter.boss.id;

  void _startWalk() {
    _ticker.stop();
    _walk = null;
    _announced = false;
    final start = _walkStart;
    if (start == null) return;
    final media = MediaQuery.of(context);
    _walkIndex = start;
    _walk = MapWalk(
      autoOpen: !media.accessibleNavigation,
      still: media.disableAnimations,
    );
    _last = Duration.zero;
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final walk = _walk;
    if (walk == null || !mounted) return;
    // Bingkai yang tertunda (aplikasi di latar) dibatasi supaya Oyen tetap
    // terlihat berjalan dan level tidak langsung terbuka.
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    walk.tick(math.min(dt, _maxFrame));
    _last = elapsed;
    if (walk.takeOpen()) {
      _ticker.stop();
      widget.onPlay(widget.chapter.levels[_walkIndex + 1]);
      return;
    }
    if (walk.arrived && !walk.autoOpen && !_announced) {
      _announced = true;
      _announce(widget.chapter.levels[_walkIndex + 1].id);
    }
    if (walk.done) _ticker.stop();
    setState(() {});
  }

  void _announce(int id) => unawaited(
    SemanticsService.sendAnnouncement(
      View.of(context),
      context.l10n.mapOyenArrived(id),
      Directionality.of(context),
    ),
  );

  /// Sentuhan atau kembali selama jalan: level tidak dibuka sendiri.
  void _cancel() {
    final walk = _walk;
    if (walk == null || walk.cancelled) return;
    setState(walk.cancel);
  }

  bool get _capturing {
    final walk = _walk;
    return walk != null && walk.autoOpen && !walk.cancelled && !walk.done;
  }

  /// Token Oyen sekarang (koordinat peta), atau null.
  MapTokenSpot? _token() {
    final walk = _walk;
    if (walk != null) {
      final walking = walk.walking;
      return MapTokenSpot(
        at: ChapterMap.onRoad(_walkIndex, walk.t, compact: _compact),
        pose: walking
            ? KittyLook.walkPose(_last.inMicroseconds / 1e6)
            : KittyPose.idle,
        facing: walking ? _facing(walk.t) : KittyFacing.down,
      );
    }
    final index = ChapterView.tokenIndexOf(
      widget.chapter,
      widget.progress,
      walkFrom: widget.walkFrom,
    );
    if (index == null) return null;
    return MapTokenSpot(
      at: ChapterMap.pointOf(index, compact: _compact),
      pose: _atBossHappy ? KittyPose.happy : KittyPose.idle,
    );
  }

  /// Arah hadap selama jalan, dari arah jalur di [t]: hampir lurus naik
  /// atau turun = hadap depan, selain itu kiri/kanan.
  KittyFacing _facing(double t) {
    final d =
        ChapterMap.onRoad(
          _walkIndex,
          math.min(1, t + _tangentStep),
          compact: _compact,
        ) -
        ChapterMap.onRoad(
          _walkIndex,
          math.max(0, t - _tangentStep),
          compact: _compact,
        );
    if (d.dx.abs() < d.dy.abs() * _sideways) return KittyFacing.down;
    return d.dx > 0 ? KittyFacing.right : KittyFacing.left;
  }

  /// Jarak di kurva untuk arah jalur, dan perbandingan dx/dy di bawahnya
  /// Oyen menghadap depan.
  static const double _tangentStep = 0.02;
  static const double _sideways = 0.5;

  /// Gulir awal: token Oyen di tengah tempat peta.
  double _initialOffset() {
    final start = _walkStart;
    final index =
        start ??
        ChapterView.tokenIndexOf(
          widget.chapter,
          widget.progress,
          walkFrom: widget.walkFrom,
        );
    if (index == null) return 0;
    final at = ChapterMap.pointOf(index, compact: _compact);
    const token = PictureMapArt.tokenSize;
    final middle =
        (at.dy + PictureMapArt.tokenOffset.dy + token.height / 2) * _scale;
    final max = ChapterMap.size.height * _scale - _viewport;
    return (middle - _viewport / 2).clamp(0, math.max(0, max)).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final kitchen = widget.chapter.number == 1;
    return PopScope(
      canPop: !_introOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _introOpen) {
          setState(() => _introOpen = false);
        }
        _cancel();
      },
      child: Scaffold(
        backgroundColor: kitchen ? c.mapKitchen : c.mapFloor,
        body: Stack(
          children: [
            CustomMultiChildLayout(
              delegate: _HeaderOverMap(),
              children: [
                LayoutId(id: _Slot.map, child: _map(context)),
                LayoutId(
                  id: _Slot.header,
                  child: ChapterHeader(
                    chapter: widget.chapter,
                    other: widget.other,
                    progress: widget.progress,
                    onBack: widget.onBack,
                    onOpen: widget.onOpen,
                  ),
                ),
              ],
            ),
            if (_capturing)
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => _cancel(),
                ),
              ),
            if (_introOpen)
              Positioned.fill(
                child: ChapterIntroCard(
                  chapter: widget.chapter,
                  onClose: () => setState(() => _introOpen = false),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _map(BuildContext context) {
    final c = context.koColors;
    final kitchen = widget.chapter.number == 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        _viewport = constraints.maxHeight;
        _scale = width / ChapterMap.size.width;
        final height = ChapterMap.size.height * _scale;
        _scroll ??= ScrollController(initialScrollOffset: _initialOffset());
        return SingleChildScrollView(
          controller: _scroll,
          child: CustomPaint(
            painter: kitchen
                ? _Tiles(c.mapKitchenTile, _scale)
                : _Floor(c.plank, c.plankJoint, _scale),
            child: SizedBox(
              width: width,
              height: math.max(height, _viewport),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: FittedBox(
                    child: ChapterMap(
                      chapter: widget.chapter,
                      progress: widget.progress,
                      onPlay: widget.onPlay,
                      token: _token(),
                      oyenAccessory: widget.oyenAccessory,
                      compact: _compact,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _Slot { header, map }

/// Judul di atas; peta mulai dari awal pudar judul ([MapArt.headerFade]
/// dari bawah judul) sampai bawah layar, digambar di bawah judul.
class _HeaderOverMap extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    final header = layoutChild(
      _Slot.header,
      BoxConstraints(maxWidth: size.width, maxHeight: size.height),
    );
    positionChild(_Slot.header, Offset.zero);
    final top = math.max(0.0, header.height - MapArt.headerFade);
    layoutChild(
      _Slot.map,
      BoxConstraints.tightFor(
        width: size.width,
        height: math.max(0.0, size.height - top),
      ),
    );
    positionChild(_Slot.map, Offset(0, top));
  }

  @override
  bool shouldRelayout(_HeaderOverMap old) => false;
}

/// Lantai kayu: garis antarpapan tiap 48 px dan sambungan papan tiap
/// 142 px (`repeating-linear-gradient` desain 23), di koordinat layar
/// desain dikali [scale]. Peta mulai di y [_origin] layar desain.
class _Floor extends CustomPainter {
  _Floor(this.plank, this.joint, this.scale);

  final Color plank;
  final Color joint;
  final double scale;

  static const double _row = 48;
  static const double _column = 142;
  static const double _line = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rows = Paint()..color = plank;
    final first = ((_origin - _row) / _row).floor();
    for (var k = first; ; k++) {
      final top = (k * _row + _row - _line - _origin) * scale;
      if (top > size.height) break;
      canvas.drawRect(Rect.fromLTWH(0, top, size.width, _line * scale), rows);
    }
    final columns = Paint()..color = joint;
    for (var k = 0; ; k++) {
      final left = (k * _column + _column - _line) * scale;
      if (left > size.width) break;
      canvas.drawRect(
        Rect.fromLTWH(left, 0, _line * scale, size.height),
        columns,
      );
    }
  }

  @override
  bool shouldRepaint(_Floor old) =>
      old.plank != plank || old.joint != joint || old.scale != scale;
}

/// y layar desain di atas peta yang digulir.
const _origin = PictureMapArt.mapTop - PictureMapArt.topPad;

/// Ubin dapur: kotak 28 px biru di kanan atas dan kiri bawah tiap petak
/// 56 px (`conic-gradient` desain 23d), di koordinat layar desain dikali
/// [scale].
class _Tiles extends CustomPainter {
  _Tiles(this.tile, this.scale);

  final Color tile;
  final double scale;

  static const double _cell = 56;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = tile;
    const half = _cell / 2;
    final first = (_origin / _cell).floor();
    for (var row = first; ; row++) {
      final top = (row * _cell - _origin) * scale;
      if (top > size.height) break;
      for (var col = 0; col * _cell * scale < size.width; col++) {
        final left = col * _cell * scale;
        canvas
          ..drawRect(
            Rect.fromLTWH(left + half * scale, top, half * scale, half * scale),
            paint,
          )
          ..drawRect(
            Rect.fromLTWH(left, top + half * scale, half * scale, half * scale),
            paint,
          );
      }
    }
  }

  @override
  bool shouldRepaint(_Tiles old) => old.tile != tile || old.scale != scale;
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(space.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KoIconButton(
                icon: KoIcons.back,
                semanticLabel: context.l10n.backToHome,
                onPressed: onBack,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    context.l10n.chapterMissing,
                    textAlign: TextAlign.center,
                    style: context.koType.body.copyWith(
                      color: context.koColors.inkSoft,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
