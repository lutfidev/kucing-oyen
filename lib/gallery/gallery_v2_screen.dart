import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../app/routes.dart';
import '../game/model/accessories.dart';
import '../game/model/home_items.dart';
import '../game/model/kitties.dart';
import '../game/render/v2/art_pack.dart';
import '../game/render/v2/cat_rig.dart';
import '../game/render/v2/room_art.dart';
import 'gallery_page.dart';

/// Development gallery. Indonesian labels follow the existing gallery policy.
class GalleryV2Screen extends StatefulWidget {
  const GalleryV2Screen({super.key, this.load});

  final Future<ArtPack> Function()? load;

  @override
  State<GalleryV2Screen> createState() => _GalleryV2ScreenState();
}

class _GalleryV2ScreenState extends State<GalleryV2Screen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Future<ArtPack> _pack;
  late final Ticker _ticker;
  KittyId _cat = KittyId.oyen;
  CatMotion _motion = CatMotion.idle;
  CatDirection _direction = CatDirection.front;
  AccessoryId? _accessory;
  bool _playing = true;
  bool _foreground = true;
  double _time = 0;
  Duration? _last;

  @override
  void initState() {
    super.initState();
    _pack = (widget.load ?? ArtPack.load)();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker((elapsed) {
      final delta = _last == null
          ? 0.0
          : (elapsed - _last!).inMicroseconds / 1e6;
      _last = elapsed;
      setState(() => _time = (_time + delta) % 46);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncTicker();
  }

  void _syncTicker() {
    final running =
        _playing &&
        _foreground &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    if (running && !_ticker.isActive) {
      _last = null;
      _ticker.start();
    } else if (!running && _ticker.isActive) {
      _ticker.stop();
      _last = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return FutureBuilder<ArtPack>(
      future: _pack,
      builder: (context, snapshot) => GalleryPage(
        overline: 'Desain v2 · langkah 2',
        title: 'Galeri aset baru',
        description: 'Paket seni untuk ditinjau. Rumah dan puzzle dipasang bertahap pada langkah berikutnya.',
        backTo: AppRoutes.gallery,
        backLabel: 'Kembali ke galeri',
        children: [
          if (snapshot.hasError) ...[
            const Text('Aset gagal dimuat.'),
            TextButton(
              onPressed: () {
                setState(() {
                  _pack = (widget.load ?? ArtPack.load)();
                });
              },
              child: const Text('Coba lagi'),
            ),
          ] else if (!snapshot.hasData)
            const Center(child: CircularProgressIndicator())
          else
            ..._content(snapshot.data!, reduced),
        ],
      ),
    );
  }

  List<Widget> _content(ArtPack pack, bool reduced) {
    final time = reduced ? null : _time;
    return [
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _select(
            'Kucing',
            _cat,
            KittyId.values,
            (v) => setState(() => _cat = v),
          ),
          _select(
            'Pose',
            _motion,
            CatMotion.values,
            (v) => setState(() => _motion = v),
          ),
          _select(
            'Arah',
            _direction,
            CatDirection.values,
            (v) => setState(() => _direction = v),
          ),
          _select<AccessoryId?>('Aksesoris', _accessory, [
            null,
            ...AccessoryId.values,
          ], (v) => setState(() => _accessory = v)),
        ],
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Putar animasi'),
        subtitle: reduced ? const Text('Kurangi gerak aktif: pose diam') : null,
        value: _playing && !reduced,
        onChanged: reduced
            ? null
            : (v) {
                setState(() => _playing = v);
                _syncTicker();
              },
      ),
      Slider(
        label: 'Fase ${(_time % 0.8).toStringAsFixed(2)} detik',
        value: _time % 0.8,
        max: 0.8,
        onChanged: reduced
            ? null
            : (v) {
                setState(() {
                  _playing = false;
                  _time = v;
                });
                _syncTicker();
              },
      ),
      _tile(
        'Sprite · ${_cat.name} · ${_motion.name}',
        Size(128, 128),
        (c) => CatRig(
          cat: _cat,
          motion: _motion,
          direction: _direction,
          accessory: _accessory,
          time: time,
        ).paint(c, pack),
        height: 190,
      ),
      GallerySection(
        title: 'Sembilan identitas · potret utuh',
        child: GalleryGrid(
          minWidth: 90,
          children: [
            for (final cat in KittyId.values)
              _tile(
                cat.name,
                const Size(128, 128),
                (c) => CatRig(cat: cat).paint(c, pack, portrait: true),
              ),
          ],
        ),
      ),
      GallerySection(
        title: 'Empat area · lapisan terpisah',
        child: Column(
          children: [
            for (final area in ArtArea.values)
              _tile(
                area.name,
                const Size(390, 390),
                (c) => paintAreaArt(c, pack, area, time: time),
                height: 310,
              ),
          ],
        ),
      ),
      GallerySection(
        title: '21 barang · mask depan/belakang',
        child: GalleryGrid(
          minWidth: 120,
          children: [
            for (final item in RoomItemId.values)
              _tile(item.name, const Size(128, 128), (c) {
                pack.paint(c, 'items/${item.name}-back');
                pack.paint(c, 'items/${item.name}-front');
              }),
          ],
        ),
      ),
      Text(
        '${pack.parts.length} bagian vector · ${pack.sourceBytes} byte sumber · tanpa cache bingkai',
      ),
    ];
  }

  Widget _select<T>(
    String label,
    T value,
    List<T> values,
    ValueChanged<T> changed,
  ) => SizedBox(
    width: 148,
    child: DropdownButtonFormField<T>(
      key: ValueKey('v2-$label'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final v in values)
          DropdownMenuItem<T>(
            value: v,
            child: Text(
              v == null ? 'Tanpa' : (v as Enum).name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (v) => changed(v as T),
    ),
  );

  Widget _tile(
    String label,
    Size designSize,
    void Function(Canvas) paint, {
    double height = 120,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Semantics(
        label: label,
        image: true,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _ArtPainter(designSize, paint)),
        ),
      ),
      Text(label, textAlign: TextAlign.center),
      const SizedBox(height: 12),
    ],
  );
}

class _ArtPainter extends CustomPainter {
  _ArtPainter(this.designSize, this.draw);
  final Size designSize;
  final void Function(Canvas) draw;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.width / designSize.width).clamp(
      0.0,
      size.height / designSize.height,
    );
    canvas.save();
    canvas.translate(
      (size.width - designSize.width * scale) / 2,
      (size.height - designSize.height * scale) / 2,
    );
    canvas.scale(scale);
    draw(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ArtPainter oldDelegate) => true;
}
