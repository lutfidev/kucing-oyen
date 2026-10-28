import 'dart:math' as math;

import 'kitties.dart';
import 'rewards.dart';
import 'snacks.dart';

/// Jam sampai Lapar habis dari 100.
const hungerHours = 12;

/// Jam sampai Senang habis dari 100.
const joyHours = 16;

/// Jam sesudah isi mangkuk dimulai sampai isi berikutnya.
const bowlRefillHours = 4;

/// Lapar yang ditambah mangkuk.
const bowlFood = 40;

/// Kucing hanya makan dari mangkuk kalau Lapar-nya di bawah ini.
const bowlHungerLimit = 70;

/// Koin hadiah per kucing per hari.
const kittyRewardCoins = 10;

/// Hadiah muncul kalau Lapar dan Senang sama-sama paling sedikit ini.
const rewardThreshold = 70;

/// Tanda lesu kalau Lapar atau Senang paling banyak ini.
const sadThreshold = 20;

/// Senang dari satu elusan, dan paling banyak per jam.
const petJoy = 10;
const petJoyPerHour = 30;

/// Senang dari memakai mainan, paling banyak sekali per [playMinutes].
const playJoy = 10;
const playMinutes = 30;

/// Senang untuk semua kucing sesudah menghias, paling banyak sekali per
/// [decorateMinutes].
const decorateJoy = 5;
const decorateMinutes = 60;

/// Nilai bar tertinggi.
const maxNeed = 100.0;

double _bar(double v) => v.isNaN ? 0 : v.clamp(0.0, maxNeed);

int _ms(DateTime time) => time.millisecondsSinceEpoch;

/// Batas atas waktu tersimpan. Lebih jauh dari ini dianggap rusak, supaya
/// `DateTime` tidak melempar saat dibaca atau saat ditambah durasi.
final _latestMs = DateTime.utc(3000).millisecondsSinceEpoch;

/// Waktu dari milidetik sejak 1970; null kalau bukan bilangan bulat atau di
/// luar 1970–3000.
DateTime? _time(Object? json) => json is int && json >= 0 && json <= _latestMs
    ? DateTime.fromMillisecondsSinceEpoch(json)
    : null;

/// Lapar dan Senang satu kucing pada waktu [at], plus batas elus dan main.
/// Keduanya turun lurus mengikuti jam ([decayed]), juga selama aplikasi
/// ditutup, dan berhenti di 0. Jam yang mundur tidak menaikkan bar dan
/// tidak membuka batas baru.
class CatNeeds {
  CatNeeds({
    required double hunger,
    required double joy,
    required this.at,
    this.petWindowStart,
    this.petWindowJoy = 0,
    this.playedAt,
  }) : hunger = _bar(hunger),
       joy = _bar(joy);

  /// Kucing baru atau sesudah reset.
  factory CatNeeds.full(DateTime now) =>
      CatNeeds(hunger: maxNeed, joy: maxNeed, at: now);

  final double hunger;
  final double joy;
  final DateTime at;

  /// Awal jendela elus satu jam, dan Senang dari elusan di jendela itu.
  final DateTime? petWindowStart;
  final int petWindowJoy;

  /// Terakhir memakai mainan.
  final DateTime? playedAt;

  /// Lapar atau Senang ≤ [sadThreshold].
  bool get isSad => hunger <= sadThreshold || joy <= sadThreshold;

  /// Lapar < [bowlHungerLimit].
  bool get canEatFromBowl => hunger < bowlHungerLimit;

  /// Lapar dan Senang ≥ [rewardThreshold].
  bool get canReward => hunger >= rewardThreshold && joy >= rewardThreshold;

  CatNeeds _with({
    double? hunger,
    double? joy,
    DateTime? at,
    DateTime? petWindowStart,
    int? petWindowJoy,
    DateTime? playedAt,
  }) => CatNeeds(
    hunger: hunger ?? this.hunger,
    joy: joy ?? this.joy,
    at: at ?? this.at,
    petWindowStart: petWindowStart ?? this.petWindowStart,
    petWindowJoy: petWindowJoy ?? this.petWindowJoy,
    playedAt: playedAt ?? this.playedAt,
  );

  /// Bar pada [now]; tidak berubah kalau [now] tidak sesudah [at].
  CatNeeds decayed(DateTime now) {
    if (!now.isAfter(at)) return this;
    final hours =
        now.difference(at).inMicroseconds / Duration.microsecondsPerHour;
    return _with(
      hunger: hunger - hours * maxNeed / hungerHours,
      joy: joy - hours * maxNeed / joyHours,
      at: now,
    );
  }

  /// Diberi [snack] pada [now].
  CatNeeds fed(Snack snack, DateTime now) {
    final d = decayed(now);
    return d._with(hunger: d.hunger + snack.hunger, joy: d.joy + snack.joy);
  }

  /// Makan dari mangkuk pada [now] (+[bowlFood]); syaratnya dicek
  /// [HomeNeeds.eatFromBowl].
  CatNeeds ateFromBowl(DateTime now) {
    final d = decayed(now);
    return d._with(hunger: d.hunger + bowlFood);
  }

  /// Dielus pada [now]: +[petJoy] Senang, paling banyak [petJoyPerHour] per
  /// jendela satu jam sejak elusan pertama di jendela itu. Null kalau
  /// batasnya sudah habis.
  CatNeeds? petted(DateTime now) {
    final start = petWindowStart;
    final fresh =
        start == null || !now.isBefore(start.add(const Duration(hours: 1)));
    final used = fresh ? 0 : petWindowJoy;
    if (used >= petJoyPerHour) return null;
    final gain = math.min(petJoy, petJoyPerHour - used);
    final d = decayed(now);
    return d._with(
      joy: d.joy + gain,
      petWindowStart: fresh ? now : start,
      petWindowJoy: used + gain,
    );
  }

  /// Memakai mainan pada [now]: +[playJoy] Senang, paling banyak sekali per
  /// [playMinutes]. Null kalau belum waktunya.
  CatNeeds? played(DateTime now) {
    final last = playedAt;
    if (last != null &&
        now.isBefore(last.add(const Duration(minutes: playMinutes)))) {
      return null;
    }
    final d = decayed(now);
    return d._with(joy: d.joy + playJoy, playedAt: now);
  }

  /// Senang ditambah [amount] pada [now].
  CatNeeds withJoy(int amount, DateTime now) {
    final d = decayed(now);
    return d._with(joy: d.joy + amount);
  }

  Map<String, Object?> toJson() => {
    'hunger': hunger,
    'joy': joy,
    'at': _ms(at),
    if (petWindowStart case final start?) ...{
      'petAt': _ms(start),
      'petJoy': petWindowJoy,
    },
    if (playedAt case final played?) 'playedAt': _ms(played),
  };

  /// Null kalau bar atau waktunya rusak. Batas elus yang rusak dianggap
  /// habis, supaya simpanan rusak tidak memberi Senang tambahan.
  static CatNeeds? fromJson(Object? json) {
    if (json
        case {
          'hunger': final num hunger,
          'joy': final num joy,
          'at': final int ms,
        }
        when hunger.isFinite && joy.isFinite) {
      final at = _time(ms);
      if (at == null) return null;
      final petAt = _time(json['petAt']);
      final petJoy = json['petJoy'];
      return CatNeeds(
        hunger: hunger.toDouble(),
        joy: joy.toDouble(),
        at: at,
        petWindowStart: petAt,
        petWindowJoy: petAt == null
            ? 0
            : petJoy is int && petJoy >= 0 && petJoy <= petJoyPerHour
            ? petJoy
            : petJoyPerHour,
        playedAt: _time(json['playedAt']),
      );
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is CatNeeds &&
      other.hunger == hunger &&
      other.joy == joy &&
      other.at == at &&
      other.petWindowStart == petWindowStart &&
      other.petWindowJoy == petWindowJoy &&
      other.playedAt == playedAt;

  @override
  int get hashCode =>
      Object.hash(hunger, joy, at, petWindowStart, petWindowJoy, playedAt);

  @override
  String toString() => 'CatNeeds(${toJson()})';
}

/// Mangkuk makanan kering bersama. Satu isi dimulai saat kucing pertama
/// makan darinya dan berlaku [bowlRefillHours] jam; dalam satu isi tiap
/// kucing makan sekali. Isi yang terlewat tidak menumpuk, dan mangkuk yang
/// tidak disentuh tetap penuh.
class Bowl {
  Bowl({this.filledAt, Iterable<KittyId> eaten = const []})
    : eaten = Set.unmodifiable(eaten);

  static final full = Bowl();

  /// Awal isi terakhir; null = belum pernah dimakan.
  final DateTime? filledAt;

  /// Kucing yang sudah makan dari isi [filledAt].
  final Set<KittyId> eaten;

  /// Isi [filledAt] masih berlaku pada [now]. Jam yang mundur ke sebelum
  /// [filledAt] tetap memakai isi itu.
  bool isActive(DateTime now) {
    final start = filledAt;
    return start != null &&
        now.isBefore(start.add(const Duration(hours: bowlRefillHours)));
  }

  bool hasEaten(KittyId kitty, DateTime now) =>
      isActive(now) && eaten.contains(kitty);

  /// [kitty] makan pada [now]; memulai isi baru kalau isi lama habis
  /// waktunya.
  Bowl eat(KittyId kitty, DateTime now) => isActive(now)
      ? Bowl(filledAt: filledAt, eaten: {...eaten, kitty})
      : Bowl(filledAt: now, eaten: {kitty});

  /// Saat isi berikutnya datang; null kalau tidak ada isi yang berjalan.
  DateTime? refillAt(DateTime now) => isActive(now)
      ? filledAt!.add(const Duration(hours: bowlRefillHours))
      : null;

  /// Semua [kitties] sudah makan dari isi yang berjalan (mangkuk tampil
  /// kosong).
  bool isEmptyFor(Iterable<KittyId> kitties, DateTime now) =>
      isActive(now) && kitties.every(eaten.contains);

  Map<String, Object?> toJson() => {
    if (filledAt case final start?) ...{
      'at': _ms(start),
      'eaten': [
        for (final k in KittyId.values)
          if (eaten.contains(k)) k.name,
      ],
    },
  };

  /// Waktu yang rusak = penuh; nama kucing yang tidak dikenal dibuang.
  factory Bowl.fromJson(Map<String, dynamic> json) {
    final start = _time(json['at']);
    if (start == null) return full;
    final names = KittyId.values.asNameMap();
    return Bowl(
      filledAt: start,
      eaten: [
        if (json['eaten'] case final List list)
          for (final name in list) ?names[name],
      ],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Bowl &&
      other.filledAt == filledAt &&
      other.eaten.length == eaten.length &&
      other.eaten.containsAll(eaten);

  @override
  int get hashCode => Object.hash(filledAt, Object.hashAllUnordered(eaten));

  @override
  String toString() => 'Bowl(${toJson()})';
}

/// Kebutuhan semua kucing, mangkuk, hari hadiah per kucing, dan waktu
/// bonus menghias terakhir. Bar dibaca lewat [of] supaya selalu diturunkan
/// ke waktu sekarang.
class HomeNeeds {
  HomeNeeds({
    Map<KittyId, CatNeeds> cats = const {},
    Bowl? bowl,
    Map<KittyId, int> rewardDays = const {},
    this.decoratedAt,
  }) : cats = Map.unmodifiable(cats),
       bowl = bowl ?? Bowl.full,
       rewardDays = Map.unmodifiable(rewardDays);

  static final empty = HomeNeeds();

  final Map<KittyId, CatNeeds> cats;
  final Bowl bowl;

  /// Hari ([dayNumber]) hadiah terakhir diambil per kucing.
  final Map<KittyId, int> rewardDays;

  /// Terakhir bonus menghias diberikan.
  final DateTime? decoratedAt;

  HomeNeeds _with({
    Map<KittyId, CatNeeds>? cats,
    Bowl? bowl,
    Map<KittyId, int>? rewardDays,
    DateTime? decoratedAt,
  }) => HomeNeeds(
    cats: cats ?? this.cats,
    bowl: bowl ?? this.bowl,
    rewardDays: rewardDays ?? this.rewardDays,
    decoratedAt: decoratedAt ?? this.decoratedAt,
  );

  HomeNeeds _set(KittyId kitty, CatNeeds needs) =>
      _with(cats: {...cats, kitty: needs});

  /// Kebutuhan [kitty] pada [now]; penuh kalau belum tercatat.
  CatNeeds of(KittyId kitty, DateTime now) =>
      (cats[kitty] ?? CatNeeds.full(now)).decayed(now);

  /// Mencatat kucing [kitties] yang belum ada, penuh pada [now]. Sama
  /// persis ([identical]) kalau semuanya sudah tercatat.
  HomeNeeds withKitties(Iterable<KittyId> kitties, DateTime now) {
    final missing = kitties.where((k) => !cats.containsKey(k)).toList();
    if (missing.isEmpty) return this;
    return _with(
      cats: {...cats, for (final k in missing) k: CatNeeds.full(now)},
    );
  }

  /// [kitty] baru dibeli: kedua bar penuh pada [now], menggantikan catatan
  /// lama kalau ada.
  HomeNeeds adopted(KittyId kitty, DateTime now) =>
      _set(kitty, CatNeeds.full(now));

  HomeNeeds feed(KittyId kitty, Snack snack, DateTime now) =>
      _set(kitty, of(kitty, now).fed(snack, now));

  /// Null kalau batas elus [kitty] sudah habis.
  HomeNeeds? pet(KittyId kitty, DateTime now) =>
      switch (of(kitty, now).petted(now)) {
        final needs? => _set(kitty, needs),
        null => null,
      };

  /// Null kalau [kitty] baru saja bermain.
  HomeNeeds? play(KittyId kitty, DateTime now) =>
      switch (of(kitty, now).played(now)) {
        final needs? => _set(kitty, needs),
        null => null,
      };

  /// Belum makan dari isi yang berjalan dan Lapar < [bowlHungerLimit].
  bool canEatFromBowl(KittyId kitty, DateTime now) =>
      !bowl.hasEaten(kitty, now) && of(kitty, now).canEatFromBowl;

  HomeNeeds? eatFromBowl(KittyId kitty, DateTime now) =>
      canEatFromBowl(kitty, now)
      ? _with(
          cats: {...cats, kitty: of(kitty, now).ateFromBowl(now)},
          bowl: bowl.eat(kitty, now),
        )
      : null;

  /// Hadiah [kitty] hari ini belum diambil dan kedua bar ≥
  /// [rewardThreshold]. Jam yang mundur ke hari sebelum hadiah terakhir
  /// menahannya.
  bool canClaim(KittyId kitty, DateTime now) {
    final last = rewardDays[kitty];
    return (last == null || dayNumber(now) > last) && of(kitty, now).canReward;
  }

  /// Menandai hadiah [kitty] hari ini sudah diambil; koin ditambah
  /// pemanggil.
  HomeNeeds? claim(KittyId kitty, DateTime now) => canClaim(kitty, now)
      ? _with(rewardDays: {...rewardDays, kitty: dayNumber(now)})
      : null;

  /// Selesai menghias: +[decorateJoy] Senang untuk [kitties], paling banyak
  /// sekali per [decorateMinutes]. Null kalau belum waktunya.
  HomeNeeds? finishDecorating(Iterable<KittyId> kitties, DateTime now) {
    final last = decoratedAt;
    if (last != null &&
        now.isBefore(last.add(const Duration(minutes: decorateMinutes)))) {
      return null;
    }
    return _with(
      cats: {
        ...cats,
        for (final k in kitties) k: of(k, now).withJoy(decorateJoy, now),
      },
      decoratedAt: now,
    );
  }

  /// Reset progres: hanya Oyen, penuh pada [now]. Mangkuk, hari hadiah,
  /// dan waktu menghias tetap, supaya hadiah hari ini tidak bisa diambil
  /// ulang.
  HomeNeeds reset(DateTime now) => HomeNeeds(
    cats: {KittyId.oyen: CatNeeds.full(now)},
    bowl: bowl,
    rewardDays: rewardDays,
    decoratedAt: decoratedAt,
  );

  Map<String, Object?> toJson() => {
    'cats': {
      for (final MapEntry(:key, :value) in cats.entries)
        key.name: value.toJson(),
    },
    'bowl': bowl.toJson(),
    'rewardDays': {
      for (final MapEntry(:key, :value) in rewardDays.entries) key.name: value,
    },
    if (decoratedAt case final at?) 'decoratedAt': _ms(at),
  };

  /// Entri yang rusak dibuang per bagian.
  factory HomeNeeds.fromJson(Map<String, dynamic> json) {
    final names = KittyId.values.asNameMap();
    return HomeNeeds(
      cats: {
        if (json['cats'] case final Map<String, dynamic> cats)
          for (final MapEntry(:key, :value) in cats.entries)
            if ((names[key], CatNeeds.fromJson(value)) case (
              final KittyId kitty,
              final CatNeeds needs,
            ))
              kitty: needs,
      },
      bowl: switch (json['bowl']) {
        final Map<String, dynamic> bowl => Bowl.fromJson(bowl),
        _ => Bowl.full,
      },
      rewardDays: {
        if (json['rewardDays'] case final Map<String, dynamic> days)
          for (final MapEntry(:key, :value) in days.entries)
            if ((names[key], value) case (final KittyId kitty, final int day)
                when day >= 0)
              kitty: day,
      },
      decoratedAt: _time(json['decoratedAt']),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HomeNeeds &&
      other.bowl == bowl &&
      other.decoratedAt == decoratedAt &&
      other.cats.length == cats.length &&
      cats.entries.every((e) => other.cats[e.key] == e.value) &&
      other.rewardDays.length == rewardDays.length &&
      rewardDays.entries.every((e) => other.rewardDays[e.key] == e.value);

  @override
  int get hashCode => Object.hash(
    bowl,
    decoratedAt,
    Object.hashAllUnordered([
      for (final e in cats.entries) Object.hash(e.key, e.value),
    ]),
    Object.hashAllUnordered([
      for (final e in rewardDays.entries) Object.hash(e.key, e.value),
    ]),
  );

  @override
  String toString() => 'HomeNeeds(${toJson()})';
}
