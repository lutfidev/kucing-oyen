import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';

import '../../app/game_audio.dart';
import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/accessories.dart';
import '../../game/model/home.dart';
import '../../game/model/home_items.dart';
import '../../game/model/house.dart';
import '../../game/model/kitties.dart';
import '../../game/model/lane.dart';
import '../../game/model/lane_life.dart';
import '../../game/model/needs.dart';
import '../../game/model/room_life.dart';
import '../../game/model/sounds.dart';
import '../../game/render/render.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../coins/coin_sheet.dart';
import '../lane/lane_view.dart';
import '../shop/shop_tab.dart';
import 'room_geometry.dart';
import 'decorate.dart';
import 'door_parts.dart';
import 'front_door.dart';
import 'house_pager.dart';
import 'kitty_card.dart';
import 'lane_camera.dart';
import 'room_parts.dart';
import 'room_reaction.dart';
import 'room_scene.dart';

/// Oyen saat rumah dibuka: kaki di (205, 556) seperti desain
/// (`AdeganTengah.dc.html` isi `baru`), jauh dari gelembung ajakan.
final starterOyenSpot = const HouseFloor().spotAtFeet(205, 556);

/// Jarak paling dekat dua kucing di tempat awalnya (px desain).
const _homeGap = 60.0;

/// Ruangan dan tempat awal tiap kucing saat rumah dibuka (tidak disimpan):
/// Oyen di tengah ruang tengah, kucing lain dibagi bergantian ke teras dan
/// ruang tengah menurut urutan acak [random], di tempat acak yang tidak di
/// jalur pintu dan tidak menempel kucing lain. Kucing [fresh] (baru, tag
/// "Baru!") selalu di ruang tengah supaya langsung terlihat.
Map<KittyId, (HouseRoom, Spot)> houseHomes(
  Iterable<KittyId> kitties,
  Random random, {
  Set<KittyId> fresh = const {},
}) {
  final owned = kitties.toSet();
  final homes = <KittyId, (HouseRoom, Spot)>{
    if (owned.contains(KittyId.oyen))
      KittyId.oyen: (HouseRoom.living, starterOyenSpot),
  };
  final others = [
    for (final kitty in KittyId.values)
      if (kitty != KittyId.oyen && owned.contains(kitty)) kitty,
  ]..shuffle(random);
  var shared = 0;
  for (final kitty in others) {
    var room = HouseRoom.living;
    if (!fresh.contains(kitty) && (shared++).isEven) room = HouseRoom.terrace;
    homes[kitty] = (room, freeHomeSpot(room, homes.values, random));
  }
  return homes;
}

/// Tempat acak di lantai [room] yang tidak di jalur pintu dan (kalau bisa)
/// tidak dekat [taken] di ruangan yang sama.
Spot freeHomeSpot(
  HouseRoom room,
  Iterable<(HouseRoom, Spot)> taken,
  Random random,
) {
  const floor = HouseFloor();
  Spot? fallback;
  for (var tries = 0; tries < 60; tries++) {
    final spot = Spot(
      0.1 + random.nextDouble() * 0.8,
      0.1 + random.nextDouble() * 0.8,
    );
    if (floor.onDoorPath(room, spot)) continue;
    fallback ??= spot;
    if (taken.every(
      (t) => t.$1 != room || floor.distance(t.$2, spot) >= _homeGap,
    )) {
      return spot;
    }
  }
  return fallback ?? Spot(0.3, 0.6);
}

/// Titik merah Toko: ada barang atau kucing yang belum dimiliki dan
/// terjangkau [coins]. Camilan tidak dihitung.
bool shopHasAffordable(Home home, int coins) =>
    shopItems.any((item) => home.room.canBuy(item.id, coins)) ||
    kitties.any((kitty) => home.canBuyKitty(kitty.id, coins));

/// Titik merah Aksesoris: ada aksesoris yang belum dimiliki dan terjangkau.
bool accessoriesHaveAffordable(Home home, int coins) =>
    accessories.any((a) => home.closet.canBuy(a.id, coins));

/// Kamar Oyen (desain 19): barang yang ditaruh, kucing yang tinggal di
/// kamar, header (koin, logo, bintang), dan panel bawah (Main, Toko,
/// Aksesoris, Pengaturan). Kamar digambar dari tepi atas layar sampai
/// panel bawah; header di bawah status bar.
class RoomView extends StatefulWidget {
  const RoomView({
    super.key,
    required this.progress,
    this.random,
    this.life = true,
    this.showKitty,
  });

  final ProgressController progress;

  /// Buka ruangan tempat kucing ini berada, tanpa geser (mis. "Lihat di
  /// kamar" sesudah membeli kucing).
  final KittyId? showKitty;

  /// Pengacak posisi kucing dan rutinitasnya; null = acak sungguhan.
  final Random? random;

  /// Kamar hidup (desain 21c): kucing berkedip, berjalan ke barang, dan
  /// memakainya; barang bergerak. False = kamar diam (test layar lain).
  final bool life;

  @override
  State<RoomView> createState() => _RoomViewState();
}

/// Kucing yang diangkat membesar 1,1× (`AdeganTengah` mode `angkat`), dan
/// dilepas di pintu kalau jari dalam [liftDoorSlop] px desain dari
/// bukaannya.
const liftScale = 1.1;
const liftDoorSlop = 16.0;

/// Kucing yang diangkat naik 30 px desain di atas jari.
const catLift = 30.0;

/// Selang penyegaran bar kebutuhan, gelembung hadiah, dan label mangkuk.
const roomRefreshInterval = Duration(seconds: 30);

/// Selang (detik animasi) kunjungan Kumis dicek ulang selama Oyen
/// menunggu bebas untuk momen ekor.
const laneCheckSeconds = 0.5;

class _RoomViewState extends State<RoomView>
    with SingleTickerProviderStateMixin {
  late final Random _random = widget.random ?? Random();

  /// Ruangan dan tempat awal tiap kucing; kucing yang baru dibeli muncul
  /// di ruang tengah.
  late final Map<KittyId, (HouseRoom, Spot)> _homes = houseHomes(
    _progress.home.kitties,
    _random,
    fresh: {
      for (final kitty in _progress.home.kitties)
        if (_progress.home.isFresh(kitty)) kitty,
    },
  );
  late final RoomLife _life = RoomLife(random: _random);

  /// Jam kamar: memajukan rutinitas dan waktu animasi. Hanya jalan kalau
  /// kamar hidup dan gerak tidak dikurangi; `TickerMode` mematikannya saat
  /// layar lain menutupi kamar.
  late final Ticker _ticker = createTicker(_tick);

  /// Momen ekor Kumis: [_time] saat ekor muncul, null = tidak ada.
  double? _tailAt;

  /// Ayunan pintu kucing sesudah Oyen lewat: [_time] mulai dan sudut awal.
  (double, double)? _flapSwing;

  /// Kunjungan paksa 20 detik sesudah ruang tengah tampil (sekali per
  /// layar; [ProgressController.forceFirstVisit] sekali per sesi).
  Timer? _forceTimer;

  /// Oyen sedang pulang lewat pintu kucing (bingkai terakhir): pintu kucing
  /// berayun saat ia sampai.
  bool _oyenComingHome = false;

  /// Aplikasi di latar belakang: kunjungan tidak ditahan, tidak ada momen
  /// ekor, dan pemain tidak dianggap di gang. Kembali = keadaan dihitung
  /// ulang dari jam ([_checkLane] `opening`).
  bool _hidden = false;
  AppLifecycleListener? _lifecycle;

  /// Pemain di Gang Depan (di luar pager rumah).
  bool _inLane = false;

  /// Kamera menembus pintu yang sedang berjalan: false = ke gang, true =
  /// pulang; null = tidak ada.
  bool? _camera;
  final _cameraKey = GlobalKey<LaneCameraState>();

  /// Opasitas chip "‹ Ruang tengah" selama kamera ke gang.
  double _cameraChip = 0;

  /// Rutinitas Oyen dan Kumis di gang (maju walau pemain di rumah) dan
  /// awal kunjungan yang sedang diputarnya.
  late LaneLife _lane = LaneLife(random: _random);
  DateTime? _laneVisitStart;

  /// Kotak tiap kucing gang di bingkai terakhir (letak reaksi).
  final Map<LaneCat, Rect> _laneBoxes = {};

  /// Hati di atas kucing gang: kucingnya (null = keduanya, saat duduk
  /// bersama pertama kali) dan nomor urutnya.
  (LaneCat?, int)? _laneHeart;
  bool _laneHeartShown = false;

  /// Pemain sedang melihat gang (di sana atau kamera sedang berjalan).
  bool get _laneWatched => _inLane || _camera != null;

  /// [_time] terakhir kunjungan dicek dari jam di bingkai kamar.
  double _laneCheckedAt = double.negativeInfinity;
  Duration _lastTick = Duration.zero;
  double _time = 0;
  Timer? _refresh;

  /// Gerak dikurangi (`disableAnimations`): semua loop berhenti.
  bool _still = false;

  /// Animasi kucing dan barang sedang jalan.
  bool get _animating => widget.life && !_still;

  ProgressController get _progress => widget.progress;

  /// Geometri kamar terakhir (untuk seretan dan letak reaksi).
  RoomGeometry? _geo;

  /// Rute tiap kucing ke tiap barang (lompatan ke barang dinding), dan
  /// keadaan kamar yang menghasilkannya (rute dihitung ulang hanya kalau
  /// keadaan itu berubah).
  Map<(RoomItemId, KittyId), ItemPath> _paths = const {};
  Object? _pathsKey;

  /// Kotak tiap kucing yang tampil di bingkai terakhir (di lantai, di
  /// dalam barang, atau melompat), untuk letak reaksi.
  Map<KittyId, Rect> _shownBoxes = const {};

  /// Kucing yang kartunya terbuka.
  KittyId? _selected;

  /// Reaksi yang sedang melayang, kucingnya, dan nomor urutnya (reaksi
  /// baru memulai ulang animasi).
  (RoomReaction, KittyId, int)? _reaction;
  int _reactions = 0;

  bool _decorating = false;
  bool _finishing = false;

  /// Ruangan yang sedang dibuka (awal ruang tengah, tidak disimpan).
  HouseRoom _house = HouseRoom.living;

  /// Naik tiap ruangan dibuka tanpa geser (pager dibangun ulang).
  int _pagerJumps = 0;

  /// Ruangan yang sudah tampil penuh: chip "Ruang tengah" muncul di akhir
  /// transisi (`TransisiRuang.dc.html`).
  HouseRoom _arrived = HouseRoom.living;

  /// Pujian sesudah menghias: dapat bonus Senang atau tidak, dan nomor
  /// urutnya.
  (bool, int)? _praise;
  int _praises = 0;

  /// Barang yang sedang diseret, letaknya sekarang, pojok kiri-atasnya
  /// saat mulai diseret, dan titik jari (layar) saat mulai dan sekarang.
  RoomItemId? _dragging;
  Spot? _dragSpot;
  Offset _dragOrigin = Offset.zero;
  Offset _dragDown = Offset.zero;
  Offset _dragPointer = Offset.zero;

  final _trayKey = GlobalKey();

  /// Keterangan di atas slot Gudang (barang redup atau gantungan teras):
  /// barangnya, teksnya, dan kotak slot di layar. Hilang sendiri.
  (RoomItemId, String, Rect)? _trayTip;
  Timer? _trayTipTimer;

  /// Lama keterangan slot Gudang tampil.
  static const trayTipDuration = Duration(milliseconds: 2400);

  /// Kucing yang sedang diangkat (tahan-seret), kotaknya saat diangkat,
  /// dan titik jari (lokal rumah) saat mulai dan sekarang.
  KittyId? _lifted;
  Rect _liftBox = Rect.zero;
  Offset _liftDown = Offset.zero;
  Offset _liftPointer = Offset.zero;

  /// Kotak kucing yang diangkat sekarang (sebelum diangkat ke atas jari).
  Rect get _liftedBox => _liftBox.shift(_liftPointer - _liftDown);

  /// Kamar baru: belum punya barang selain mangkuk.
  bool get _empty =>
      _progress.home.room.owned.every((id) => roomItemOf(id).builtIn);

  (HouseRoom, Spot) _homeOf(KittyId kitty) => _homes.putIfAbsent(
    kitty,
    () => (
      HouseRoom.living,
      freeHomeSpot(HouseRoom.living, _homes.values, _random),
    ),
  );

  /// Kucing di Gang Depan (hanya Oyen): tidak digambar di rumah.
  bool _isOut(KittyId kitty) => widget.life && _life.of(kitty).outside;

  /// Tempat kucing sekarang: dari rutinitas kalau kamar hidup.
  Spot _catSpot(KittyId kitty) =>
      widget.life ? _life.of(kitty).spot : _homeOf(kitty).$2;

  /// Ruangan kucing sekarang.
  HouseRoom _catRoom(KittyId kitty) =>
      widget.life ? _life.of(kitty).room : _homeOf(kitty).$1;

  @override
  void initState() {
    super.initState();
    _house = _arrived = _roomShowing(widget.showKitty) ?? HouseRoom.living;
    if (widget.life) {
      _syncKitties();
      _refresh = Timer.periodic(roomRefreshInterval, (_) => _refreshNeeds());
      // Dibuka di tengah kunjungan: Oyen sudah di bangku, tanpa ekor.
      _checkLane(opening: true);
      if (_house == HouseRoom.living) _armForcedVisit();
      _lifecycle = AppLifecycleListener(onHide: _onHide, onShow: _onShow);
    }
  }

  void _onHide() {
    _hidden = true;
    _lane.playerHere(false);
    if (_tailAt != null) {
      _tailAt = null;
      _life.rest(KittyId.oyen);
    }
  }

  void _onShow() {
    if (!mounted) return;
    _hidden = false;
    _checkLane(opening: true);
    if (_inLane && _camera == null && TickerMode.valuesOf(context).enabled) {
      _lane.playerHere(true);
    }
    if (_house == HouseRoom.living && !_inLane) _armForcedVisit();
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    // Rute lain menutupi kamar (Toko, level) = pemain pergi dari gang.
    if (widget.life) {
      final shown = TickerMode.valuesOf(context).enabled;
      _lane.playerHere(_inLane && _camera == null && shown && !_hidden);
      if (shown && _house == HouseRoom.living && !_inLane) _armForcedVisit();
    }
    if (_animating && !_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    } else if (!_animating && _ticker.isActive) {
      _ticker.stop();
    }
    if (widget.life && _still) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _eatWithoutWalking());
    }
  }

  @override
  void didUpdateWidget(RoomView old) {
    super.didUpdateWidget(old);
    if (widget.showKitty != old.showKitty) {
      if (_roomShowing(widget.showKitty) case final room?) {
        _inLane = false;
        _camera = null;
        _lane.playerHere(false);
        _house = _arrived = room;
        // Pager baru = langsung di ruangan itu, tanpa animasi geser.
        _pagerJumps++;
      }
    }
  }

  /// Ruangan kucing [kitty], atau null.
  HouseRoom? _roomShowing(KittyId? kitty) {
    if (kitty == null || !_progress.home.ownsKitty(kitty)) return null;
    // Rute dihitung dengan ukuran rumah terakhir: tanpa ukuran, semua
    // kucing kehilangan rutenya dan turun dari barangnya.
    if (widget.life) _syncKitties(_geo?.room);
    return _catRoom(kitty);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _refresh?.cancel();
    _forceTimer?.cancel();
    _lifecycle?.dispose();
    _trayTipTimer?.cancel();
    super.dispose();
  }

  void _sound(GameSound sound) => AudioScope.maybeRead(context)?.play(sound);

  void _tick(Duration elapsed) {
    // Bingkai yang tertunda lama (aplikasi dijeda) tidak melompatkan kucing.
    final dt = ((elapsed - _lastTick).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _lastTick = elapsed;
    _time += dt;
    _life.paused =
        _selected != null ||
        _decorating ||
        _reaction != null ||
        _lifted != null;
    _advanceTail();
    _lane.paused = _selected != null;
    for (final event in _lane.advance(dt)) {
      switch (event) {
        case SatTogether():
          _progress.meetNeighbor();
        case OyenEnteredHouse():
          _life.comeHome(KittyId.oyen, instant: !_watchingLiving);
        case KumisGone():
          break;
      }
    }
    if (_lane.heart && !_laneHeartShown && _inLane) {
      _laneHeart = (null, ++_reactions);
    }
    _laneHeartShown = _lane.heart;
    for (final event in _life.advance(dt)) {
      switch (event) {
        case ReachedBowl(:final kitty):
          _eatFromBowl(kitty);
        case UsedToy(:final kitty, :final item):
          _progress.play(kitty, item);
        case LeftRoom(:final kitty, :final from) when from == _house:
          _announceLeft(kitty, from.other);
        case WentOut(:final kitty, viaFlap: true):
          _swingFlap(flapOutDeg);
          if (_house == HouseRoom.living) _announceWentOut(kitty);
        case EnteredRoom(:final kitty, to: HouseRoom.living)
            when kitty == KittyId.oyen && _oyenComingHome:
          _swingFlap(flapInDeg);
        case LeftRoom() || EnteredRoom() || WentOut():
          break;
      }
    }
    if (_progress.home.ownsKitty(KittyId.oyen)) {
      final oyen = _life.of(KittyId.oyen);
      _oyenComingHome = oyen.viaFlap && oyen.activity == CatActivity.entering;
    }
    setState(() {});
  }

  /// Pintu kucing berayun dari [from] (Oyen baru lewat) dengan bunyinya.
  void _swingFlap(double from) {
    _flapSwing = (_time, from);
    _sound(GameSound.flap);
  }

  /// Pembaca layar: Oyen menyelinap ke Gang Depan dari ruang tengah.
  void _announceWentOut(KittyId kitty) {
    final l = context.l10n;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        l.oyenWentOut(kittyName(l, kitty)),
        Directionality.of(context),
      ),
    );
  }

  /// Kunjungan paksa pertama 20 detik sesudah ruang tengah tampil, kalau
  /// pertemuan pertama belum terjadi. Kalau saat itu pemain tidak di ruang
  /// tengah, dicoba lagi saat ruang tengah tampil lagi.
  void _armForcedVisit() {
    if (_forceTimer != null || _progress.metNeighbor) return;
    if (!_progress.lanesOpen) return;
    _forceTimer = Timer(laneForcedDelay, () {
      if (!mounted) return;
      _forceTimer = null;
      if (!_seeingLiving) return;
      if (_progress.forceFirstVisit()) _checkLane();
    });
  }

  /// Oyen bebas untuk momen ekor: di ruang tengah, di lantai, tidak lewat
  /// pintu, tidak diangkat, tidak bereaksi, kartunya tertutup, tidak Hias.
  bool get _oyenFree {
    final cat = _life.of(KittyId.oyen);
    return _selected == null &&
        !_decorating &&
        _reaction == null &&
        _lifted == null &&
        cat.room == HouseRoom.living &&
        !cat.outside &&
        !cat.isPassing &&
        (cat.activity == CatActivity.idle ||
            cat.activity == CatActivity.walking ||
            cat.activity == CatActivity.sad);
  }

  /// Pemain melihat ruang tengah sekarang (aplikasi tampil, rumah tidak
  /// tertutup layar lain, tidak di gang atau di tengah kamera).
  bool get _seeingLiving =>
      !_hidden &&
      _house == HouseRoom.living &&
      !_inLane &&
      _camera == null &&
      !_ticker.muted;

  /// [_seeingLiving] dan gerak hidup: momen ekor dan Oyen yang terlihat
  /// lewat pintu kucing.
  bool get _watchingLiving => _seeingLiving && _animating;

  /// Keadaan kunjungan Kumis ke keadaan Oyen: kunjungan berjalan = Oyen
  /// keluar (dengan momen ekor kalau pemain melihat ruang tengah, langsung
  /// kalau tidak atau saat aplikasi dibuka [opening]); kunjungan selesai =
  /// Oyen pulang.
  void _checkLane({bool opening = false}) {
    if (!widget.life || !_progress.home.ownsKitty(KittyId.oyen)) return;
    final cat = _life.of(KittyId.oyen);
    // Lapar di gang: Oyen pulang lebih dulu ke mangkuk.
    if (cat.outside &&
        _progress.oyenInLane &&
        _progress.catNeeds(KittyId.oyen).hunger <= sadThreshold) {
      _progress.sendOyenHome();
    }
    _syncLane(opening: opening);
    if (_progress.oyenInLane) {
      if (cat.outside || cat.goingOut || cat.wantsOut || _tailAt != null) {
        return;
      }
      if (cat.isPassing && cat.viaFlap) return;
      if (opening || !_watchingLiving) {
        _life.goOut(KittyId.oyen, instant: true);
        if (!opening && _house == HouseRoom.living) {
          _announceWentOut(KittyId.oyen);
        }
        return;
      }
      if (cat.room != HouseRoom.living) {
        _life.goOut(KittyId.oyen);
        return;
      }
      if (_oyenFree) _startTail();
      return;
    }
    if (_tailAt != null) {
      _tailAt = null;
      _life.rest(KittyId.oyen);
    }
    if (cat.outside) {
      // Pemain di gang: Oyen pulang lewat pintu kucing gang dulu
      // ([OyenEnteredHouse]).
      if (_laneWatched && _lane.of(LaneCat.oyen) != null) return;
      _life.comeHome(KittyId.oyen, instant: opening || !_watchingLiving);
    } else if (cat.goingOut || cat.wantsOut) {
      _life.comeHome(KittyId.oyen);
    }
  }

  /// Kunjungan ke rutinitas gang: kunjungan baru = Kumis datang (dan Oyen
  /// kalau ikut), dibuka di tengah kunjungan [opening] = keduanya sudah di
  /// bangku; Oyen pulang lebih dulu = ia masuk lewat pintu kucing gang;
  /// kunjungan selesai = Kumis pergi lalu Oyen pulang (kalau pemain di
  /// gang), atau gang langsung kosong.
  void _syncLane({bool opening = false}) {
    final visit = _progress.laneVisit;
    if (visit == null) {
      _laneVisitStart = null;
      if (_lane.actors.isEmpty) return;
      if (_laneWatched && !_still && !opening) {
        _lane.leave();
      } else {
        _lane = LaneLife(random: _random);
      }
      return;
    }
    if (_laneVisitStart != visit.start) {
      _laneVisitStart = visit.start;
      _lane.start(
        firstMeeting: !_progress.metNeighbor,
        oyenComing: _progress.oyenInLane,
        midVisit: opening || _still,
      );
      if (_inLane) _lane.playerHere(true);
      return;
    }
    if (!_progress.oyenInLane && _lane.of(LaneCat.oyen) != null) {
      if (_laneWatched && !_still) {
        _lane.oyenGoesHome();
      } else {
        _lane.start(firstMeeting: false, oyenComing: false, midVisit: true);
      }
    }
  }

  /// Pemain tiba di gang (akhir kamera): kunjungan ditahan, pertemuan
  /// pertama mulai. Gerak dikurangi = langsung duduk bersama (tanpa
  /// naskah yang bergerak) dan dihitung sudah bertemu.
  void _arriveInLane() {
    _progress.holdLane();
    if (_still && _lane.actors.isNotEmpty) {
      final oyen = _lane.of(LaneCat.oyen) != null || _progress.oyenInLane;
      _lane.start(firstMeeting: false, oyenComing: oyen, midVisit: true);
      if (oyen) _progress.meetNeighbor();
    }
    _lane.playerHere(true);
  }

  /// Pemain menyusul ke gang selama kunjungan: Oyen yang belum keluar
  /// (momen ekor, jalan ke pintu, diajak, di barang) langsung di luar, jadi
  /// Oyen di gang selalu Oyen yang di luar rumah.
  void _followOyen() {
    if (!widget.life || !_progress.home.ownsKitty(KittyId.oyen)) return;
    if (!_progress.oyenInLane || _isOut(KittyId.oyen)) return;
    _tailAt = null;
    _progress.followTail();
    _life.goOutNow(KittyId.oyen);
  }

  /// Ketuk Kumis: meong dan hati kecil, tanpa kartu (`ReaksiKumis`).
  void _tapKumis() {
    _sound(GameSound.meow);
    _lane.react(
      LaneCat.kumis,
      LifePose.happy,
      ReactionOverlay.duration.inMilliseconds / 1000,
    );
    setState(() => _laneHeart = (LaneCat.kumis, ++_reactions));
  }

  /// Ekor Kumis muncul: pintu kucing terdorong, Oyen diam lalu menoleh.
  void _startTail() {
    _tailAt = _time;
    _sound(GameSound.meow);
    _life.react(KittyId.oyen, LifePose.idle, tailMomentSeconds);
  }

  /// Maju momen ekor tiap bingkai: batal kalau Oyen diganggu (kartu,
  /// angkat, Hias), selesai = Oyen berjalan ke pintu depan. Tanpa momen,
  /// kunjungan yang menunggu Oyen bebas dicek lagi.
  void _advanceTail() {
    final start = _tailAt;
    if (start == null) {
      if (_hidden || _time - _laneCheckedAt < laneCheckSeconds) return;
      _laneCheckedAt = _time;
      if (_oyenFree && _waitingForOyen) _checkLane();
      return;
    }
    if (_selected != null || _decorating || _lifted != null) {
      _tailAt = null;
      _life.goOut(KittyId.oyen);
      return;
    }
    if (tailPhaseAt(_time - start) != null) return;
    _tailAt = null;
    _progress.followTail();
    _life
      ..rest(KittyId.oyen)
      ..goOut(KittyId.oyen);
  }

  /// Kunjungan berjalan tapi Oyen masih di rumah tanpa permintaan keluar
  /// (menunggu bebas untuk momen ekor). Dihitung dari jam hanya kalau
  /// perlu, supaya tiap bingkai murah.
  bool get _waitingForOyen {
    if (!_progress.home.ownsKitty(KittyId.oyen)) return false;
    final cat = _life.of(KittyId.oyen);
    if (cat.outside || cat.goingOut || cat.wantsOut) return false;
    return _progress.oyenInLane;
  }

  /// Pembaca layar: tempat yang baru dicapai sesudah kamera pintu depan
  /// (gang tidak punya chip atau judul lain yang dibacakan).
  void _announcePlace(bool home) {
    final l = context.l10n;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        home ? l.roomName(HouseRoom.living.name) : l.laneName,
        Directionality.of(context),
      ),
    );
  }

  /// Pembaca layar: kucing keluar dari ruangan yang sedang dibuka.
  void _announceLeft(KittyId kitty, HouseRoom to) {
    final l = context.l10n;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        l.kittyLeftTo(kittyName(l, kitty), to.name),
        Directionality.of(context),
      ),
    );
  }

  Future<void> _eatFromBowl(KittyId kitty) async {
    if (await _progress.eatFromBowl(kitty) && mounted) {
      _sound(GameSound.munch);
    }
  }

  /// Kurangi gerak: kucing tidak berjalan, jadi yang lapar langsung makan
  /// dari mangkuk (kebutuhan tetap berjalan).
  void _eatWithoutWalking() {
    if (!mounted || !_still) return;
    for (final kitty in _progress.home.kitties) {
      if (!_isOut(kitty) && _progress.canEatFromBowl(kitty)) {
        _eatFromBowl(kitty);
      }
    }
  }

  void _refreshNeeds() {
    if (!mounted || _hidden) return;
    if (_inLane && TickerMode.valuesOf(context).enabled) _progress.holdLane();
    _checkLane();
    setState(() {});
    _eatWithoutWalking();
  }

  /// Kucing yang dimiliki, kebutuhannya, dan tempat memakai tiap barang
  /// (di ruangannya, rumah seukuran [size]) ke rutinitas.
  void _syncKitties([Size? size]) {
    final home = _progress.home;
    final placed = home.room.placed;
    final key = (
      size,
      _decorating,
      Object.hashAllUnordered(
        placed.entries.map((e) => (e.key, e.value, home.room.roomOf(e.key))),
      ),
      Object.hashAllUnordered(home.kitties),
    );
    if (key != _pathsKey) {
      _pathsKey = key;
      _paths = size == null || _decorating ? const {} : _pathsFor(size);
    }
    _life.sync(
      homes: {for (final kitty in home.kitties) kitty: _homeOf(kitty)},
      itemRooms: {for (final id in placed.keys) id: home.room.roomOf(id)},
      targets: {
        for (final id in placed.keys)
          id: {
            for (final kitty in home.kitties)
              if (_paths[(id, kitty)] case final path?)
                kitty: LifeRoute(path.stand, hops: path.hops),
          },
      },
      uses: {for (final id in placed.keys) id: roomItemOf(id).use},
      toys: {
        for (final id in placed.keys)
          if (roomItemOf(id).toy) id,
      },
      hungry: {
        for (final kitty in home.kitties)
          if (_progress.canEatFromBowl(kitty)) kitty,
      },
      sad: {
        for (final kitty in home.kitties)
          if (_progress.catNeeds(kitty).isSad) kitty,
      },
    );
  }

  /// Rute tiap kucing ke tiap barang, di ruangan barang itu.
  Map<(RoomItemId, KittyId), ItemPath> _pathsFor(Size size) {
    final home = _progress.home;
    final paths = <(RoomItemId, KittyId), ItemPath>{};
    for (final room in HouseRoom.values) {
      final geo = RoomGeometry(size, room);
      final items = home.room.placedIn(room);
      for (final id in items.keys) {
        for (final kitty in home.kitties) {
          if (geo.pathTo(kitty, id, items) case final path?) {
            paths[(id, kitty)] = path;
          }
        }
      }
    }
    return paths;
  }

  void _select(KittyId kitty) {
    _sound(GameSound.meow);
    setState(() => _selected = kitty);
    _progress.seeKitty(kitty);
  }

  void _closeCard() => setState(() => _selected = null);

  /// Ajak [kitty] ke ruangan sebelah: berjalan lewat pintu, langsung
  /// keluar dari ambang ([atDoor]), atau langsung pindah saat kurangi
  /// gerak.
  void _invite(KittyId kitty, {bool atDoor = false}) {
    // Langsung pindah (tanpa lewat pintu): diumumkan di sini, karena tidak
    // ada peristiwa keluar ruangan.
    if ((!widget.life || _still) && _catRoom(kitty) == _house) {
      _announceLeft(kitty, _house.other);
    }
    if (widget.life) {
      _life.invite(kitty, atDoor: atDoor && !_still, instant: _still);
    } else {
      final to = _homeOf(kitty).$1.other;
      _homes[kitty] = (to, const HouseFloor().threshold(to));
    }
    setState(() {});
  }

  /// Kucing paling depan di bawah [point] (lokal rumah), atau null.
  KittyId? _kittyAt(Offset point) {
    final geo = _geo;
    if (geo == null) return null;
    KittyId? best;
    var bestFeet = double.negativeInfinity;
    for (final MapEntry(key: kitty, value: box) in _shownBoxes.entries) {
      final feet = geo.feetOf(box);
      if (box.contains(point) && feet > bestFeet) {
        best = kitty;
        bestFeet = feet;
      }
    }
    return best;
  }

  void _liftStart(Offset point) {
    final kitty = _kittyAt(point);
    final box = _shownBoxes[kitty];
    if (kitty == null || box == null) return;
    setState(() {
      _lifted = kitty;
      _liftBox = box;
      _liftDown = point;
      _liftPointer = point;
    });
  }

  void _liftMove(Offset point) {
    if (_lifted == null) return;
    setState(() => _liftPointer = point);
  }

  /// Angkat batal: kucing kembali ke tempatnya tanpa pindah.
  void _liftCancel() {
    if (_lifted == null) return;
    setState(() => _lifted = null);
  }

  /// Lepas kucing yang diangkat: di pintu (dilebarkan [liftDoorSlop]) =
  /// diajak ke ruangan sebelah; di tempat lain = diletakkan di lantai di
  /// bawah jari.
  void _liftEnd() {
    final kitty = _lifted;
    final geo = _geo;
    if (kitty == null) return;
    setState(() => _lifted = null);
    if (geo == null) return;
    final box = _liftedBox;
    final door = geo.door.getBounds().inflate(liftDoorSlop * geo.artScale);
    if (door.contains(_liftPointer)) {
      _invite(kitty, atDoor: true);
      return;
    }
    final spot = geo.catSpotAt(kitty, box);
    if (widget.life) {
      _life.moveTo(kitty, spot);
    } else {
      _homes[kitty] = (geo.which, spot);
    }
  }

  /// Kucing di ruangan [room] yang perlu dicek, untuk ikon di pintu ke
  /// sana: lapar (aturan tanda lesu), lesu, lalu hadiah koin (kamar hidup,
  /// bukan kucing yang masih bertanda baru, seperti gelembungnya).
  (KittyId, DoorNeed)? _doorAttention(HouseRoom room) {
    final home = _progress.home;
    return doorAttention(
      [
        for (final kitty in home.kitties)
          if (_catRoom(kitty) == room && !_isOut(kitty)) kitty,
      ],
      hungry: (kitty) => _progress.catNeeds(kitty).hunger <= sadThreshold,
      sad: (kitty) => _progress.catNeeds(kitty).isSad,
      reward: (kitty) =>
          widget.life &&
          !home.isFresh(kitty) &&
          _progress.canClaimKittyReward(kitty),
    );
  }

  /// Ikon perhatian di pintu depan untuk Oyen yang di gang (lapar, lesu,
  /// lalu hadiah), atau null.
  DoorNeed? _frontAttention() {
    if (!_isOut(KittyId.oyen)) return null;
    return doorAttention(
      const [KittyId.oyen],
      hungry: (kitty) => _progress.catNeeds(kitty).hunger <= sadThreshold,
      sad: (kitty) => _progress.catNeeds(kitty).isSad,
      // Hadiah koin tidak bisa diambil di gang: penanda tetap tampil.
      reward: (_) => false,
    )?.$2;
  }

  /// Sudut pintu kucing pintu depan sekarang; null = Oyen sedang lewat.
  double? _flapDeg() {
    if (!widget.life || _still) return 0;
    if (_progress.home.ownsKitty(KittyId.oyen)) {
      final cat = _life.of(KittyId.oyen);
      if (cat.isPassing && cat.viaFlap && !_decorating) return null;
    }
    if (_tailAt case final start?) return tailFlapAt(_time - start);
    if (_flapSwing case (final start, final from)) {
      return flapSwingAt(_time - start, from);
    }
    return 0;
  }

  /// Kucing yang memakai barang [id] (null kalau sedang diangkat).
  KittyId? _userOf(RoomItemId id) {
    if (!widget.life || _decorating) return null;
    final user = _life.userOf(id);
    return user == _lifted ? null : user;
  }

  void _react(KittyId kitty, RoomReaction reaction) {
    if (reaction.sound case final sound?) _sound(sound);
    if (_isOut(kitty)) {
      _lane.react(
        LaneCat.oyen,
        reaction.pose,
        ReactionOverlay.duration.inMilliseconds / 1000,
      );
    } else if (widget.life) {
      _life.react(
        kitty,
        reaction.pose,
        ReactionOverlay.duration.inMilliseconds / 1000,
      );
    }
    setState(() => _reaction = (reaction, kitty, ++_reactions));
  }

  void _reactionDone() {
    final kitty = _reaction?.$2;
    if (widget.life && kitty != null) _life.rest(kitty);
    setState(() => _reaction = null);
  }

  /// Ambil hadiah koin kucing yang dirawat (gelembung).
  Future<void> _claim(KittyId kitty) async {
    final l = context.l10n;
    if (!await _progress.claimKittyReward(kitty) || !mounted) return;
    _react(
      kitty,
      RoomReaction(
        text: l.reactionCoins(kittyRewardCoins),
        hearts: false,
        sound: GameSound.reward,
      ),
    );
  }

  void _openShop([ShopTab tab = ShopTab.items]) =>
      context.go(AppRoutes.shop(tab: tab));

  void _startDecorating() => setState(() {
    _decorating = true;
    _selected = null;
    _reaction = null;
    _clearTrayTip();
    _life.interrupt();
  });

  /// Keterangan slot Gudang hilang (tanpa setState).
  void _clearTrayTip() {
    _trayTipTimer?.cancel();
    _trayTip = null;
  }

  /// Selesai menghias (juga tombol kembali sistem): kembali ke mode normal,
  /// lalu pujian, dengan bonus Senang kalau belum diberikan sejam ini.
  Future<void> _finish() async {
    if (_finishing || !_decorating) return;
    _finishing = true;
    setState(() {
      _decorating = false;
      _dragging = null;
      _dragSpot = null;
      _clearTrayTip();
    });
    final bonus = await _progress.finishDecorating();
    if (!mounted) return;
    setState(() {
      _finishing = false;
      _praise = (bonus, ++_praises);
    });
  }

  void _dragStart(RoomItemId id, Rect box, Offset pointer) {
    _dragOrigin = box.topLeft;
    _dragDown = pointer;
    _dragPointer = pointer;
  }

  void _dragUpdate(RoomItemId id, Offset pointer) {
    final geo = _geo;
    // Barang tidak bisa diseret lewat pintu (spec): hanya barang di
    // ruangan yang sedang dibuka.
    if (geo == null || _progress.home.room.roomOf(id) != _house) return;
    _dragPointer = pointer;
    setState(() {
      _dragging = id;
      _dragSpot = geo.spotFor(
        roomItemOf(id),
        _dragOrigin + (pointer - _dragDown),
      );
    });
  }

  /// Lepas di atas baki = masuk Gudang (kecuali mangkuk), selain itu
  /// ditaruh. Keduanya langsung disimpan. Gantungan teras hanya bisa ke
  /// Gudang: dilepas di tempat lain, ia kembali ke titik gantungnya.
  void _dragEnd(RoomItemId id) {
    final spot = _dragSpot;
    if (_dragging == id) {
      if (_overTray(_dragPointer) && !roomItemOf(id).builtIn) {
        _progress.storeItem(id);
      } else if (spot != null && !(_geo?.hangs(id) ?? false)) {
        _progress.placeItem(id, spot, room: _house);
      }
    }
    setState(() {
      _dragging = null;
      _dragSpot = null;
    });
  }

  /// Ketuk barang di Gudang: ditaruh di posisi bawaannya di ruangan ini;
  /// gantungan teras memunculkan "Gantung di balok atap".
  Future<void> _placeFromTray(RoomItemId id, Rect slot) async {
    final placed = await _progress.placeItem(
      id,
      roomItemOf(id).defaultSpot,
      room: _house,
    );
    if (!mounted) return;
    if (placed && _house == HouseRoom.terrace && terraceHangers.contains(id)) {
      _showTrayTip(id, context.l10n.hangNote, slot);
    } else if (_trayTip != null) {
      _trayTipTimer?.cancel();
      setState(() => _trayTip = null);
    }
  }

  void _showTrayTip(RoomItemId id, String text, Rect slot) {
    _trayTipTimer?.cancel();
    _trayTipTimer = Timer(trayTipDuration, () {
      if (mounted) setState(() => _trayTip = null);
    });
    setState(() => _trayTip = (id, text, slot));
  }

  /// Keterangan [text] di atas slot Gudang [slot] (layar), di atas baki
  /// (`Teras.dc.html`: lebar 222 untuk barang redup, 196 untuk gantungan,
  /// dijepit 12 px dari tepi layar).
  Widget _trayTipAt(RoomItemId id, String text, Rect slot) {
    final s = context.koSize;
    final space = context.koSpace;
    final screen = MediaQuery.sizeOf(context).width;
    final tray = _trayKey.currentContext?.findRenderObject() as RenderBox?;
    final trayTop = tray != null && tray.hasSize
        ? tray.localToGlobal(Offset.zero).dy
        : slot.top;
    final unit = _geo?.artScale ?? 1;
    final wide = !canPlaceIn(id, _house);
    final width = min(
      (wide ? s.roomTrayTipWide : s.roomTrayTip) * unit,
      screen - space.s12 * 2,
    );
    final left = (slot.center.dx - width / 2)
        .clamp(space.s12, max(space.s12, screen - space.s12 - width))
        .toDouble();
    return Positioned(
      left: left,
      width: width,
      bottom: MediaQuery.sizeOf(context).height - trayTop + space.s14,
      child: IgnorePointer(
        child: TrayTip(text: text, arrowX: slot.center.dx - left),
      ),
    );
  }

  bool _overTray(Offset pointer) {
    final box = _trayKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return false;
    return (box.localToGlobal(Offset.zero) & box.size).contains(pointer);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final compact = MediaQuery.sizeOf(context).height < s.roomCompactHeight;
    final home = _progress.home;
    final coins = _progress.coins;
    final selected = _selected;
    final reaction = _reaction;
    final praise = _praise;
    final geo = _geo;
    final padding = MediaQuery.paddingOf(context);
    final cardTop = padding.top + s.roomCardTop;
    final cardMax =
        MediaQuery.sizeOf(context).height -
        cardTop -
        padding.bottom -
        space.s16;
    // Panel bawah setinggi sama saat menghias, supaya kamar tidak berubah
    // ukuran.
    final panel = compact
        ? s.roomPlayCompact + space.s12 + s.roomMenuButtonCompact
        : s.roomPlay + space.s16 + s.roomMenuButton;
    return PopScope(
      canPop: selected == null && !_decorating && !_inLane && _camera == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_camera != null) {
          _cameraKey.currentState?.skip();
        } else if (selected != null) {
          _closeCard();
        } else if (_inLane) {
          _goHome();
        } else if (_decorating) {
          _finish();
        } else {
          _closeCard();
        }
      },
      child: Scaffold(
        backgroundColor: c.roomFloorBoards,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => _houseArea(box.biggest),
                  ),
                ),
                RoomPanel(
                  compact: compact,
                  child: SizedBox(
                    height: panel,
                    child: _decorating
                        ? StorageTray(
                            key: _trayKey,
                            items: home.room.stored,
                            compact: compact,
                            dimmed: {
                              for (final id in home.room.stored)
                                if (!canPlaceIn(id, _house)) id,
                            },
                            selected: _trayTip?.$1,
                            onPlace: _placeFromTray,
                            onDimmed: (id, slot) => _showTrayTip(
                              id,
                              context.l10n.livingOnlyNote,
                              slot,
                            ),
                          )
                        : RoomMenu(
                            compact: compact,
                            shopDot: shopHasAffordable(home, coins),
                            accessoryDot: accessoriesHaveAffordable(
                              home,
                              coins,
                            ),
                            onPlay: () => context.go(
                              AppRoutes.chapter(
                                _progress.currentChapter.number,
                              ),
                            ),
                            onShop: _openShop,
                            onAccessories: () => _openShop(ShopTab.accessories),
                            onSettings: () => context.go(AppRoutes.settings),
                          ),
                  ),
                ),
              ],
            ),
            if ((_decorating, _trayTip) case (
              true,
              (final id, final text, final slot),
            ))
              _trayTipAt(id, text, slot),
            if (selected != null) ...[
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _closeCard,
                  child: ColoredBox(color: c.roomScrim),
                ),
              ),
              Positioned(
                left: space.s16,
                right: space.s16,
                top: cardTop,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: max(0, cardMax)),
                  child: KittyCard(
                    key: ValueKey(selected),
                    progress: _progress,
                    kitty: selected,
                    room: _isOut(selected) ? null : _catRoom(selected),
                    onReaction: (r) => _react(selected, r),
                    onInvite: () {
                      _closeCard();
                      _invite(selected);
                    },
                    onClose: _closeCard,
                  ),
                ),
              ),
            ],
            if ((reaction, geo)
                case ((final r, final kitty, final n), final geo?)
                when _progress.home.ownsKitty(kitty))
              ReactionOverlay(
                key: ValueKey(n),
                reaction: r,
                anchor: _isOut(kitty)
                    ? _laneBoxes[LaneCat.oyen] ?? Rect.zero
                    : _shownBoxes[kitty] ??
                          geo.catBoxOf(kitty, _catSpot(kitty)),
                onDone: _reactionDone,
              ),
            if ((_laneHeart, _inLane) case ((final cat, final n), true))
              ReactionOverlay(
                key: ValueKey('lane-heart-$n'),
                reaction: const RoomReaction(),
                anchor: _laneHeartAnchor(cat),
                onDone: () => setState(() => _laneHeart = null),
              ),
            if (praise case (final bonus, final n))
              Positioned(
                left: s.roomPraiseInset,
                right: s.roomPraiseInset,
                top: padding.top + s.roomPraiseTop,
                child: PraiseToast(
                  key: ValueKey(n),
                  title: context.l10n.decoratePraise,
                  subtitle: bonus
                      ? context.l10n.decoratePraiseJoy(decorateJoy)
                      : null,
                  onDone: () => setState(() => _praise = null),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Ketuk pintu depan: kamera menembus pintu ke Gang Depan. Ketukan
  /// selama kamera berjalan melompat ke akhir, bukan transisi baru.
  void _openLane() => _startCamera(home: false);

  /// Ketuk pintu pulang, chip, atau tombol kembali di gang: pulang.
  void _goHome() => _startCamera(home: true);

  void _startCamera({required bool home}) {
    if (_camera != null) {
      _cameraKey.currentState?.skip();
      return;
    }
    if (_inLane != home) return;
    if (home) {
      _lane.playerHere(false);
    } else {
      _followOyen();
    }
    setState(() {
      _camera = home;
      _cameraChip = 0;
      _selected = null;
      _reaction = null;
      _lifted = null;
    });
  }

  void _cameraDone() {
    final home = _camera;
    if (home == null) return;
    _sound(GameSound.doorClose);
    if (!home) _arriveInLane();
    _announcePlace(home);
    setState(() {
      _camera = null;
      _inLane = !home;
      if (home) {
        _house = _arrived = HouseRoom.living;
        _pagerJumps++;
      }
    });
    if (home) _armForcedVisit();
  }

  /// Kotak hati di gang: di atas [cat], atau di atas keduanya.
  Rect _laneHeartAnchor(LaneCat? cat) {
    if (cat != null) return _laneBoxes[cat] ?? Rect.zero;
    final boxes = _laneBoxes.values;
    if (boxes.isEmpty) return Rect.zero;
    return boxes.reduce((a, b) => a.expandToInclude(b));
  }

  /// Pindah ruangan lewat pintu atau chip (pager menggeser).
  void _goTo(HouseRoom room) => setState(() => _house = room);

  /// Area rumah: ruangan yang bisa digeser, lalu header dan tombol Hias
  /// yang diam di atasnya.
  Widget _houseArea(Size size) {
    // Sekali per bingkai, bukan per ruangan yang dibangun pager.
    if (widget.life) _syncKitties(size);
    final s = context.koSize;
    final space = context.koSpace;
    final empty = _empty;
    final top = MediaQuery.paddingOf(context).top + space.s6;
    // Kurangi gerak: tidak ada transisi, chip langsung tampil.
    final arrived = _still ? _house : _arrived;
    final outside = _inLane || _camera != null;
    final terrace =
        _house == HouseRoom.terrace &&
        arrived == HouseRoom.terrace &&
        !_decorating &&
        !outside;
    final lifted = _lifted;
    // Tahan-seret kucing: satu pengenal untuk seluruh ruangan, supaya
    // seretan tidak putus saat kucing pindah lapisan. Tidak ada di gang.
    final canLift = !_decorating && _selected == null && !outside;
    final livingGeo = RoomGeometry(size, HouseRoom.living);
    final camera = _camera;
    // Chip "‹ Ruang tengah" di gang, memudar masuk di akhir kamera.
    final laneChip = switch ((camera, _inLane)) {
      (false, _) => _cameraChip,
      (true, _) => 0.0,
      (null, true) => 1.0,
      (null, false) => 0.0,
    };
    return Stack(
      key: const ValueKey('room-area'),
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          // Pengenal tahan tidak memberi tahu kalau pointernya dibatalkan
          // sistem (tirai notifikasi, telepon masuk) sesudah diterima:
          // kucing diturunkan di tempatnya semula.
          child: Listener(
            onPointerCancel: (_) => _liftCancel(),
            // Hanya sentuhan di atas kucing yang ikut: menahan pintu atau
            // barang lalu menggeser tetap pindah ruangan.
            child: RawGestureDetector(
              gestures: {
                if (canLift)
                  _CatLongPress:
                      GestureRecognizerFactoryWithHandlers<_CatLongPress>(
                        () => _CatLongPress((p) => _kittyAt(p) != null),
                        (r) => r
                          ..onLongPressStart = ((d) =>
                              _liftStart(d.localPosition))
                          ..onLongPressMoveUpdate = ((d) =>
                              _liftMove(d.localPosition))
                          ..onLongPressEnd = ((_) => _liftEnd()),
                      ),
              },
              child: camera != null
                  ? LaneCamera(
                      key: _cameraKey,
                      home: camera,
                      geo: livingGeo,
                      from: camera
                          ? (deg) => _laneArea(livingGeo, homeDeg: deg)
                          : (deg) =>
                                _room(livingGeo, frontDeg: deg, leaving: true),
                      to: camera ? _room(livingGeo) : _laneArea(livingGeo),
                      onOpen: () => _sound(GameSound.doorOpen),
                      onFrame: (f) => _cameraChip = f.chipOpacity,
                      onDone: _cameraDone,
                    )
                  : _inLane
                  ? _laneArea(livingGeo)
                  : HousePager(
                      key: ValueKey(_pagerJumps),
                      room: _house,
                      enabled: !_decorating && lifted == null,
                      onRoom: (room) => setState(() => _house = room),
                      onArrive: (room) {
                        if (room == HouseRoom.living && widget.life) {
                          _armForcedVisit();
                        }
                        if (room != _arrived) setState(() => _arrived = room);
                      },
                      builder: (context, room) =>
                          _room(RoomGeometry(size, room)),
                    ),
            ),
          ),
        ),
        Positioned(
          left: space.s16,
          right: space.s16,
          top: top,
          child: RoomHeader(
            coins: _progress.coins,
            bonus: _progress.canClaimBonus,
            stars: _progress.progress.totalStars,
            maxStars: _progress.maxStars,
            onCoins: () => showCoinSheet(context, _progress),
          ),
        ),
        if (laneChip > 0)
          Positioned(
            left: space.s16,
            right: space.s16,
            top: top + s.roomDecorateGap,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Opacity(
                opacity: laneChip,
                child: RoomChip(onPressed: _goHome),
              ),
            ),
          )
        else if (!outside &&
            (!empty || _decorating || terrace || lifted != null))
          Positioned(
            left: space.s16,
            right: space.s16,
            top: top + s.roomDecorateGap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lifted != null)
                  Flexible(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: LiftStatus(to: _catRoom(lifted).other),
                    ),
                  )
                else if (_decorating)
                  const Flexible(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: DecorateHint(),
                    ),
                  )
                else if (terrace)
                  Flexible(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: RoomChip(onPressed: () => _goTo(HouseRoom.living)),
                    ),
                  )
                else
                  const Spacer(),
                if ((!empty || _decorating) && lifted == null) ...[
                  SizedBox(width: space.s8),
                  DecorateButton(
                    done: _decorating,
                    onPressed: _decorating ? _finish : _startDecorating,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  /// Isi satu ruangan [geo]: latar, barang, kucing di ruangan itu (yang
  /// lewat pintu di belakang kusen), dan tanda di atasnya. [leaving] = ruang
  /// tengah di kamera berangkat: penanda dan ikon pintu depan tidak digambar,
  /// karena ikut diperbesar sampai menutupi header.
  Widget _room(RoomGeometry geo, {double frontDeg = 0, bool leaving = false}) {
    final living = geo.which == HouseRoom.living;
    if (geo.which == _house) _geo = geo;
    final current = geo.which == _house;
    final lifted = current ? _lifted : null;
    bool here(KittyId kitty) =>
        _catRoom(kitty) == geo.which && kitty != lifted && !_isOut(kitty);
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final home = _progress.home;
    final now = _progress.clock();
    final bowlFull = !_progress.needs.bowl.isEmptyFor(home.kitties, now);
    final dragging = _dragging;
    final dragSpot = _dragSpot;
    final sprites = roomSprites(
      items: {
        ...home.room.placedIn(geo.which),
        if (dragging != null && dragSpot != null && geo.which == _house)
          dragging: dragSpot,
      },
      cats: {
        for (final kitty in home.kitties)
          if (here(kitty) && (!widget.life || _life.of(kitty).activity.onFloor))
            kitty: _catSpot(kitty),
      },
      geo: geo,
    );
    // Barang yang diangkat digambar paling depan. Gantungan teras tidak
    // punya spot: ia mengikuti jari dan kembali ke titik gantungnya.
    final ordered = [
      for (final sprite in sprites)
        if (sprite is! ItemSprite || sprite.id != dragging) sprite,
      for (final sprite in sprites)
        if (sprite is ItemSprite && sprite.id == dragging)
          geo.hangs(sprite.id) && geo.which == _house
              ? ItemSprite(
                  sprite.id,
                  sprite.box.shift(_dragPointer - _dragDown),
                )
              : sprite,
    ];
    final hopping = {
      for (final kitty in home.kitties)
        if (here(kitty)) kitty: ?_hopBox(kitty, geo),
    };
    final catBoxes = {..._catBoxes(sprites, geo), ...hopping};
    if (geo.which == _house) _shownBoxes = catBoxes;
    final empty = _empty && living;
    final top = MediaQuery.paddingOf(context).top + space.s6;
    // Tag dan gelembung tidak naik ke bawah header dan tombol Hias, yang
    // digambar di atasnya dan menelan ketukan.
    final overlayTop =
        top + s.roomDecorateGap + s.roomDecorateButton + space.s8;
    final unit = geo.artScale;
    final attention = _decorating ? null : _doorAttention(geo.which.other);
    final front = living && !_decorating && !leaving ? _frontAttention() : null;
    final oyenOut = living && _isOut(KittyId.oyen);
    final tailAt = living ? _tailAt : null;
    final tailTime = tailAt == null ? null : _time - tailAt;
    final shadows = [
      for (final sprite in ordered)
        switch (sprite) {
          ItemSprite(:final id, :final flat)
              when !flat && roomItemOf(id).zone == RoomZone.floor =>
            id == dragging
                ? SceneShadow(
                    SceneShadow.ofItem(sprite.box, unit: unit).oval,
                    SceneShadow.lifted,
                  )
                : SceneShadow.ofItem(sprite.box, unit: unit),
          ItemSprite(:final id)
              when id == RoomItemId.hammock &&
                  geo.hangs(id) &&
                  id != dragging =>
            SceneShadow(
              Rect.fromCenter(
                center: geo.toScreen(hammockShadow.x, hammockShadow.y),
                width: hammockShadowRadius * 2 * unit,
                height: hammockShadowRadius * 0.4 * unit,
              ),
              hammockShadowOpacity,
            ),
          KittySprite(:final box) => SceneShadow.ofCat(
            box,
            geo.feetOf(box),
            unit: unit,
          ),
          _ => null,
        },
      if (lifted != null)
        SceneShadow.ofCat(
          _liftedBox,
          geo.feetOf(_liftedBox),
          unit: unit,
          lifted: true,
        ),
    ].nonNulls.toList();
    final scene = RoomScene(
      geo: geo,
      time: _animating ? _time : null,
      shadows: shadows,
      // Pintu depan ke Gang Depan di dinding kiri, tertutup dengan pintu
      // kucing (artboard 1).
      door: [
        if (living)
          Positioned.fill(
            child: FrontDoor(
              angleDeg: frontDeg,
              flapDeg: frontDeg > 0 ? 0 : _flapDeg(),
              tail: tailTime != null && tailVisibleAt(tailTime),
              time: _animating ? tailTime : null,
            ),
          ),
      ],
      passing: [
        for (final kitty in home.kitties)
          if (here(kitty)) ?_passing(kitty, geo),
      ],
      floor: [
        // Garis panduan Hias di bawah barang: barang yang diangkat tetap di
        // atasnya (chipnya di atas semua, lihat di bawah).
        if (_decorating && geo.which == _house)
          Positioned.fill(
            child: ZoneGuides(geo: geo, time: _animating ? _time : null),
          ),
        // Tempat nyaman teras pemain baru di bawah kucing (kucing yang sudah
        // dibeli tanpa barang bisa duduk di sana).
        if (_empty && !living && !_decorating)
          Positioned.fill(child: EmptyTerraceSpots(geo: geo)),
        // Pintu di bawah kucing dan barang: kucing di ambang tetap bisa
        // diketuk.
        if (!_decorating && living)
          FrontDoorButton(
            key: const ValueKey('front-door'),
            geo: geo,
            label: switch ((front, oyenOut)) {
              (final need?, _) => context.l10n.frontDoorAttention(
                kittyName(context.l10n, KittyId.oyen),
                need.name,
              ),
              (null, true) => context.l10n.frontDoorOyenOut(
                kittyName(context.l10n, KittyId.oyen),
              ),
              (null, false) => context.l10n.frontDoorTo,
            },
            onTap: _openLane,
          ),
        if (!_decorating)
          DoorButton(
            geo: geo,
            label: switch (attention) {
              (final kitty, final need) => context.l10n.doorAttention(
                geo.which.other.name,
                kittyName(context.l10n, kitty),
                need.name,
              ),
              null => context.l10n.doorTo(geo.which.other.name),
            },
            onTap: () => _goTo(geo.which.other),
          ),
        for (final sprite in sprites.whereType<KittySprite>())
          if (sprite.kitty == _selected)
            Positioned(
              left: sprite.box.left + sprite.box.width * 0.12,
              top: sprite.box.top + sprite.box.height * 0.84,
              width: sprite.box.width * 0.76,
              height: space.s16 + space.s4,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: c.roomSelectFill,
                  shape: OvalBorder(
                    side: BorderSide(color: c.orange, width: s.artBorder),
                  ),
                ),
              ),
            ),
      ],
      // Daun pintu depan yang terbuka (kamera ke gang) menutup bagian
      // barang dan kucing di belakangnya (keputusan pemilik repo).
      cover: [
        if (living && frontDeg > 0)
          Positioned.fill(
            child: DoorLeafCoverView(
              side: DoorLeafSide.front,
              angleDeg: frontDeg,
              targets: _coverTargets(ordered, geo),
            ),
          ),
      ],
      sprites: [
        for (final sprite in ordered) ...[
          // Tali gantungan teras tepat di belakang barangnya.
          if (sprite case ItemSprite(:final id)
              when geo.hangs(id) && id != dragging)
            Positioned.fill(
              key: ValueKey('rope-${id.name}'),
              child: HangRopes(
                ropes: geo.ropesOf(id, sprite.box),
                width: hangRopeWidth * unit,
              ),
            ),
          if (sprite case ItemSprite(:final id) when id == dragging)
            _itemSprite(sprite, geo, bowlFull, lifted: true)
          else
            switch (sprite) {
              ItemSprite() => _itemSprite(sprite, geo, bowlFull),
              KittySprite(:final kitty) => Positioned.fromRect(
                key: ValueKey(kitty),
                rect: sprite.box,
                child: IgnorePointer(
                  ignoring: _decorating,
                  child: _kitty(kitty, sprite.box),
                ),
              ),
            },
        ],
        // Kucing yang melompat ke atau dari barang dinding, paling depan.
        for (final MapEntry(key: kitty, value: box) in hopping.entries)
          Positioned.fromRect(
            key: ValueKey(kitty),
            rect: box,
            child: _kitty(kitty, box, hopFacing: _hopFacing(kitty, geo)),
          ),
        // Kucing yang diangkat: naik 30 px desain dan sedikit membesar
        // dengan titik tumpu di kakinya (`AdeganTengah` mode `angkat`).
        if (lifted != null)
          Positioned.fromRect(
            key: ValueKey(lifted),
            rect: _liftedBox,
            child: IgnorePointer(
              child: Transform.translate(
                offset: Offset(0, -catLift * unit),
                child: Transform.scale(
                  scale: liftScale,
                  alignment: const Alignment(0, 2 * catFeetFactor - 1),
                  child: _kitty(lifted, _liftedBox),
                ),
              ),
            ),
          ),
      ],
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: scene),
        // Chip panduan Hias di atas barang dan kucing, seperti desain
        // (z 890): label jalur pintu tidak tertutup barang. Garis dan
        // arsirnya di lapisan lantai. Sentuhan tembus.
        if (_decorating)
          Positioned.fill(child: ZoneGuides(geo: geo, labels: true)),
        if (attention case (_, final need))
          DoorAttention(geo: geo, need: need, time: _animating ? _time : null),
        if (front case final need?)
          DoorAttention(
            geo: geo,
            need: need,
            front: true,
            time: _animating ? _time : null,
          )
        else if (oyenOut && !_decorating && !leaving)
          LaneMarker(
            key: const ValueKey('lane-marker'),
            geo: geo,
            time: _animating ? _time : null,
          ),
        if ((tailTime, _shownBoxes[KittyId.oyen]) case (final t?, final box?)
            when current && tailPhaseAt(t) == TailPhase.notice)
          SeruMark(cat: box, unit: unit, time: _animating ? t : null),
        if (lifted != null)
          Positioned.fill(
            child: DoorGlow(
              key: const ValueKey('door-glow'),
              geo: geo,
              time: _animating ? _time : null,
            ),
          ),
        // Petunjuk rumah kosong di bawah gelembung dan tanda di atas kucing,
        // supaya gelembung hadiah Oyen tetap bisa diketuk.
        if (empty && !_decorating)
          Positioned.fill(
            child: EmptyRoomHints(
              geo: geo,
              onShop: _openShop,
              time: _animating ? _time : null,
            ),
          ),
        if (!_decorating)
          for (final MapEntry(key: kitty, value: box) in catBoxes.entries)
            if (_progress.catNeeds(kitty) case final needs when needs.isSad)
              Positioned(
                left: box.left + box.width * 0.19,
                top: box.top - box.width * 0.19,
                child: SadMarkView(
                  hungry: needs.hunger <= sadThreshold,
                  size: RoomArt.sadMarkViewBox.width * geo.artScale,
                  time: _animating ? _time : null,
                ),
              )
            else if (home.isFresh(kitty))
              Positioned.fill(
                child: CustomSingleChildLayout(
                  // Desain: tag di tengah kotak kucing (kiri − 26 untuk
                  // "Baru!" selebar ±52), atas − 14.
                  delegate: KeepInside(
                    Offset(box.center.dx, box.top - 14 * geo.artScale),
                    margin: space.s8,
                    top: overlayTop,
                    centered: true,
                  ),
                  child: const NewKittyTag(),
                ),
              )
            else if (widget.life && _progress.canClaimKittyReward(kitty))
              Positioned.fill(
                child: CustomSingleChildLayout(
                  // Desain: gelembung di (163, 362) untuk Oyen 116 di
                  // (137, 430); dijepit supaya tidak keluar tepi kamar.
                  delegate: KeepInside(
                    Offset(
                      box.left + box.width * 26 / oyenRoomSize,
                      box.top - box.width * 68 / oyenRoomSize,
                    ),
                    margin: space.s8,
                    top: overlayTop,
                  ),
                  child: CoinBubbleView(
                    key: ValueKey('reward-${kitty.name}'),
                    coins: kittyRewardCoins,
                    label: context.l10n.kittyRewardLabel(
                      kittyRewardCoins,
                      kittyName(context.l10n, kitty),
                    ),
                    size: RoomArt.coinBubbleViewBox.width * geo.artScale,
                    time: _animating ? _time : null,
                    onTap: () => _claim(kitty),
                  ),
                ),
              ),
        if (!_decorating && widget.life)
          if ((
                _bowlRefill(now),
                home.room.placedIn(geo.which)[RoomItemId.mangkuk],
              )
              case (final left?, final spot?))
            if (geo.boxOf(roomItemOf(RoomItemId.mangkuk), spot) case final bowl)
              Positioned.fill(
                child: CustomSingleChildLayout(
                  // Desain: label di (282, 566) untuk mangkuk di (298, 596),
                  // dijepit supaya tidak keluar tepi kamar.
                  delegate: KeepInside(
                    Offset(
                      bowl.left - 16 * geo.artScale,
                      bowl.top - 30 * geo.artScale,
                    ),
                    margin: context.koSpace.s8,
                  ),
                  child: BowlRefillLabel(left: left),
                ),
              ),
      ],
    );
  }

  /// Gambar ruangan [geo] yang bisa tertutup daun pintu yang terbuka, di
  /// koordinat desain.
  List<DoorCoverTarget> _coverTargets(
    List<RoomSprite> sprites,
    RoomGeometry geo,
  ) {
    Rect design(Rect r) => Rect.fromLTRB(
      r.left / geo.sx,
      r.top / geo.sy,
      r.right / geo.sx,
      r.bottom / geo.sy,
    );
    return [
      for (final sprite in sprites)
        switch (sprite) {
          ItemSprite(:final id, :final box, :final flat) => DoorCoverTarget(
            design(box),
            feet: box.bottom / geo.sy,
            depth: flat ? DoorCoverTarget.flat : DoorCoverTarget.item,
            wall: roomItemOf(id).zone == RoomZone.wall && !geo.hangs(id),
          ),
          KittySprite(:final box) => DoorCoverTarget(
            design(box),
            feet: geo.feetOf(box) / geo.sy,
            depth: DoorCoverTarget.upright,
          ),
        },
    ];
  }

  /// Gang Depan (desain 7–13): latar, pintu pulang terbuka [homeDeg], Oyen
  /// dan Kumis dari rutinitas gang, dan tombol pintu pulang.
  Widget _laneArea(
    RoomGeometry geo, {
    double homeDeg = LaneDoorAngles.homeRest,
  }) {
    final l = context.l10n;
    _laneBoxes.clear();
    final hungry = _progress.catNeeds(KittyId.oyen).hunger <= sadThreshold;
    final name = kittyName(l, KittyId.oyen);
    return LaneView(
      geo: geo,
      life: _lane,
      time: _animating ? _time : null,
      homeDeg: homeDeg,
      oyenAccessory: _progress.home.closet.wearingOf(KittyId.oyen),
      oyenLabel: hungry ? l.kittyTapHintHungry(name) : l.kittyTapHint(name),
      boxes: _laneBoxes,
      onOyen: () => _select(KittyId.oyen),
      onKumis: _tapKumis,
      onHome: _goHome,
    );
  }

  /// Kucing [kitty] yang sedang lewat pintu ruangan [geo], digambar di
  /// belakang kusen; null kalau tidak sedang lewat.
  Widget? _passing(KittyId kitty, RoomGeometry geo) {
    if (!widget.life || _decorating) return null;
    final cat = _life.of(kitty);
    if (!cat.isPassing) return null;
    final leaving = cat.activity == CatActivity.leaving;
    if (cat.viaFlap) {
      final box = geo.flapPassingBox(kitty, cat.doorProgress, leaving: leaving);
      return Positioned.fromRect(
        key: ValueKey('passing-${kitty.name}'),
        rect: box,
        child: IgnorePointer(
          child: ExcludeSemantics(
            child: ClipRect(
              clipper: FlapClipper(geo.flapClip - box.left),
              child: _kitty(kitty, box),
            ),
          ),
        ),
      );
    }
    final box = geo.passingBox(kitty, cat.doorProgress, leaving: leaving);
    return Positioned.fromRect(
      key: ValueKey('passing-${kitty.name}'),
      rect: box,
      child: IgnorePointer(child: ExcludeSemantics(child: _kitty(kitty, box))),
    );
  }

  /// Kotak tiap kucing di kamar: sprite-nya sendiri, atau kotak kucing di
  /// barang yang sedang dipakainya.
  Map<KittyId, Rect> _catBoxes(List<RoomSprite> sprites, RoomGeometry geo) {
    final boxes = <KittyId, Rect>{};
    for (final sprite in sprites) {
      switch (sprite) {
        case KittySprite(:final kitty):
          boxes[kitty] = sprite.box;
        case ItemSprite(:final id):
          final user = _userOf(id);
          if (user == null) continue;
          boxes[user] = geo.userBoxOf(id, sprite.box);
      }
    }
    return boxes;
  }

  /// Rute lompatan kucing [kitty] yang sedang naik atau turun, urut dari
  /// tempatnya sekarang; null kalau tidak sedang melompat.
  List<Rect>? _hopBoxes(KittyId kitty) {
    if (!widget.life || _decorating) return null;
    final cat = _life.of(kitty);
    final item = cat.item;
    if (!cat.isHopping || item == null) return null;
    final boxes = _paths[(item, kitty)]?.boxes;
    if (boxes == null) return null;
    return cat.activity == CatActivity.descending
        ? boxes.reversed.toList()
        : boxes;
  }

  Rect? _hopBox(KittyId kitty, RoomGeometry geo) {
    final boxes = _hopBoxes(kitty);
    if (boxes == null) return null;
    return hopBox(
      boxes,
      _life.of(kitty).hopProgress,
      arc: catHopArc * geo.artScale,
    );
  }

  /// Arah hadap selama melompat: ke lompatan yang sedang dijalani.
  KittyFacing _hopFacing(KittyId kitty, RoomGeometry geo) {
    final boxes = _hopBoxes(kitty)!;
    final hops = boxes.length - 1;
    final i = min((_life.of(kitty).hopProgress * hops).floor(), hops - 1);
    final dx = boxes[i + 1].center.dx - boxes[i].center.dx;
    if (dx.abs() < geo.artScale) return KittyFacing.down;
    return dx < 0 ? KittyFacing.left : KittyFacing.right;
  }

  /// Sisa waktu sampai mangkuk terisi lagi, atau null kalau mangkuknya
  /// tidak kosong.
  Duration? _bowlRefill(DateTime now) {
    final bowl = _progress.needs.bowl;
    if (!bowl.isEmptyFor(_progress.home.kitties, now)) return null;
    return bowl.refillIn(now);
  }

  Widget _itemSprite(
    ItemSprite sprite,
    RoomGeometry geo,
    bool bowlFull, {
    bool lifted = false,
  }) {
    final s = context.koSize;
    final id = sprite.id;
    final user = _userOf(id);
    final time = _animating ? _time : null;
    if (user != null) {
      final mirror = geo.mirrorsInUse(id, sprite.box);
      final box = RoomItemArt.inUseBox(id, sprite.box, mirror: mirror);
      return Positioned.fromRect(
        key: ValueKey(id),
        rect: box,
        child: _kittyButton(
          user,
          RoomItemView(
            id: id,
            box: box.size,
            full: id != RoomItemId.mangkuk || bowlFull,
            time: time,
            mirror: mirror,
            user: KittyLook(
              kitty: user,
              accessory: _progress.home.closet.wearingOf(user),
              time: time,
            ),
          ),
        ),
      );
    }
    Widget art = RoomItemView(
      id: id,
      box: sprite.box.size,
      full: id != RoomItemId.mangkuk || bowlFull,
      // Barang diam tidak digambar ulang tiap bingkai.
      time: RoomItemArt.isAnimated(id) ? time : null,
    );
    // Hanya ruangan yang sedang dibuka yang bisa dihias: selama transisi
    // pintu kedua ruangan dibangun, dan barang ruangan yang sedang keluar
    // tidak boleh terseret ke ruangan ini.
    if (_decorating && geo.which == _house) {
      final l = context.l10n;
      art = DecorOutline(
        child: Semantics(
          label: roomItemName(l, id),
          excludeSemantics: true,
          customSemanticsActions: roomItemOf(id).builtIn
              ? null
              : {
                  CustomSemanticsAction(label: l.storeItemAction): () =>
                      _progress.storeItem(id),
                },
          child: art,
        ),
      );
      if (lifted) {
        art = Transform.translate(
          offset: Offset(0, -s.roomLift * geo.artScale),
          child: Transform.scale(scale: s.roomLiftScale, child: art),
        );
      }
      // Gerakan tetap paling luar: kalau jenis widget di atasnya berganti
      // saat barang terangkat, pengenal seretnya ikut dibuang di tengah
      // seretan.
      art = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (d) => _dragStart(id, sprite.box, d.globalPosition),
        onPanUpdate: (d) => _dragUpdate(id, d.globalPosition),
        onPanEnd: (_) => _dragEnd(id),
        onPanCancel: () => _dragEnd(id),
        child: art,
      );
    }
    return Positioned.fromRect(key: ValueKey(id), rect: sprite.box, child: art);
  }

  /// Kucing yang bisa diketuk untuk membuka kartunya.
  Widget _kittyButton(KittyId kitty, Widget child) {
    final l = context.l10n;
    final hungry = _progress.catNeeds(kitty).hunger <= sadThreshold;
    final fresh = _progress.home.isFresh(kitty);
    final name = kittyName(l, kitty);
    return Semantics(
      button: true,
      label: switch ((fresh, hungry)) {
        (true, true) => l.kittyTapHintNewHungry(name),
        (true, false) => l.kittyTapHintNew(name),
        (false, true) => l.kittyTapHintHungry(name),
        (false, false) => l.kittyTapHint(name),
      },
      excludeSemantics: true,
      onTap: () => _select(kitty),
      customSemanticsActions: {
        CustomSemanticsAction(
          label: l.inviteTo(_catRoom(kitty).other.name),
        ): () =>
            _invite(kitty),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _select(kitty),
        child: child,
      ),
    );
  }

  Widget _kitty(KittyId kitty, Rect box, {KittyFacing? hopFacing}) {
    final needs = _progress.catNeeds(kitty);
    var pose = needs.isSad ? KittyPose.lesu : KittyPose.idle;
    var facing = KittyFacing.down;
    if (widget.life && !_decorating) {
      final cat = _life.of(kitty);
      pose = switch (cat.pose) {
        LifePose.idle => KittyPose.idle,
        LifePose.lick => KittyPose.lick,
        LifePose.walk => KittyLook.walkPose(cat.elapsed),
        LifePose.sad => KittyPose.lesu,
        LifePose.happy => KittyPose.happy,
        LifePose.petted => KittyPose.petted,
        LifePose.eat => KittyPose.eat,
        LifePose.sleep => KittyPose.sleep,
        LifePose.lounge => KittyPose.rebah,
      };
      facing = switch (cat.heading) {
        LifeHeading.down => KittyFacing.down,
        LifeHeading.left => KittyFacing.left,
        LifeHeading.right => KittyFacing.right,
      };
    }
    facing = hopFacing ?? facing;
    final tailAt = kitty == KittyId.oyen ? _tailAt : null;
    if (tailAt != null) {
      final phase = tailPhaseAt(_time - tailAt);
      if (phase == TailPhase.notice || phase == TailPhase.settle) {
        facing = KittyFacing.left;
      }
    }
    return _kittyButton(
      kitty,
      KittyView(
        look: KittyLook(
          kitty: kitty,
          pose: pose,
          facing: facing,
          accessory: _progress.home.closet.wearingOf(kitty),
          // Desain: kucing tidak dianimasikan selama mode hias.
          time: _animating && !_decorating ? _time : null,
        ),
        size: box.width,
      ),
    );
  }
}

/// Tahan (500 ms) yang hanya menerima sentuhan yang dimulai di atas kucing
/// ([allowed], titik lokal rumah).
class _CatLongPress extends LongPressGestureRecognizer {
  _CatLongPress(this.allowed);

  final bool Function(Offset local) allowed;

  @override
  bool isPointerAllowed(PointerDownEvent event) =>
      allowed(event.localPosition) && super.isPointerAllowed(event);
}
