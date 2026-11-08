part of 'progress_scope.dart';

/// Pause reasons compose, so closing a sheet cannot resume an ad/background
/// pause. UI integrations in steps 5–9 drive these and monotonic active dt.
enum HouseholdPause { hidden, background, ad, decorating, reset }

class _HomeChange {
  const _HomeChange({
    required this.home,
    required this.needs,
    required this.household,
    this.coins = 0,
  });
  final Home home;
  final HomeNeeds needs;
  final Household household;
  final int coins;
}

extension HouseholdController on ProgressController {
  Household get household => _household;
  bool get householdPaused => _homePauses.isNotEmpty;
  bool get householdSaveFailed => _pendingHome != null;
  bool get householdBusy => _homeBusy;

  void pauseHousehold(HouseholdPause reason) => _homePauses.add(reason);
  void resumeHousehold(HouseholdPause reason) => _homePauses.remove(reason);

  Future<bool> inviteKitty(KittyId kitty, HomeActivity activity) {
    if (_homePauses.contains(HouseholdPause.decorating) ||
        !_home.ownsKitty(kitty)) {
      return Future.value(false);
    }
    final routine = _household.routine.invite(kitty, activity);
    if (identical(routine, _household.routine)) return Future.value(true);
    return _commitHousehold(
      _HomeChange(
        home: _home,
        needs: _needs,
        household: _household.copyWith(routine: routine),
      ),
    );
  }

  Future<bool> cancelInvitation(KittyId kitty) {
    if (!_home.ownsKitty(kitty)) return Future.value(false);
    return _commitHousehold(
      _HomeChange(
        home: _home,
        needs: _needs,
        household: _household.copyWith(
          routine: _household.routine.cancel(kitty),
        ),
      ),
    );
  }

  Future<bool> advanceHousehold(double activeSeconds) {
    if (householdPaused || !activeSeconds.isFinite || activeSeconds < 0) {
      return Future.value(false);
    }
    _HomeChange build() {
      final next = _household.advance(activeSeconds, _needs, _effectiveNow);
      return _HomeChange(
        home: _home,
        needs: next.needs,
        household: next.household,
      );
    }

    return _commitHousehold(build(), rebuild: build);
  }

  List<KittyId> get claimableKitties => [
    for (final k in KittyId.values)
      if (_home.ownsKitty(k) && _needs.canClaim(k, _effectiveNow)) k,
  ];
  int get householdRewardCoins => claimableKitties.length * kittyRewardCoins;

  Future<bool> claimAllKittyRewards() {
    _HomeChange? build() {
      final now = _effectiveNow;
      var needs = _needs;
      var count = 0;
      for (final k in KittyId.values.where(_home.ownsKitty)) {
        final next = needs.claim(k, now);
        if (next != null) {
          needs = next;
          count++;
        }
      }
      if (count == 0) return null;
      return _HomeChange(
        home: _home,
        needs: needs,
        household: _household,
        coins: count * kittyRewardCoins,
      );
    }

    final change = build();
    if (change == null) return Future.value(false);
    return _commitHousehold(change, rebuild: build);
  }

  Future<bool> setHomeArea(HomeArea area) => _commitHousehold(
    _HomeChange(
      home: _home,
      needs: _needs,
      household: _household.copyWith(lastArea: area),
    ),
  );
  Future<bool> setReducedMotion(bool value) => _commitHousehold(
    _HomeChange(
      home: _home,
      needs: _needs,
      household: _household.copyWith(reducedMotion: value),
    ),
  );
  Future<bool> acknowledgeHomeMigration() => _commitHousehold(
    _HomeChange(
      home: _home,
      needs: _needs,
      household: _household.copyWith(migrationNotice: false),
    ),
  );

  /// Draft changes become visible together, with a single decorate bonus only
  /// when the actual layout changed. Built-in facilities remain available.
  Future<bool> saveAreaLayout(HomeAreas draft) {
    final normal = HomeAreas.fromJson(draft.toJson(), _home);
    if (normal == _household.areas) return Future.value(false);
    var routine = _household.routine;
    for (final entry in routine.activities.entries) {
      final facility = entry.value.facility;
      if (facility != null && !normal.placed.containsKey(facility)) {
        routine = routine.interrupt(entry.key);
      }
    }
    return _commitHousehold(
      _HomeChange(
        home: _home,
        needs: _needs.finishDecorating(_home.kitties, _effectiveNow) ?? _needs,
        household: _household.copyWith(areas: normal, routine: routine),
      ),
    );
  }
}

// Implementation is in the same library as ProgressController to share its
// write queue. No asynchronous callback can interleave two home transactions.
extension _HouseholdTransactions on ProgressController {
  DateTime get _effectiveNow {
    var now = _household.time(clock());
    for (final cat in _needs.cats.values) {
      for (final at in [cat.at, cat.playedAt, cat.petWindowStart]) {
        if (at != null && at.isAfter(now)) now = at;
      }
    }
    for (final at in [_needs.bowl.filledAt, _needs.decoratedAt]) {
      if (at != null && at.isAfter(now)) now = at;
    }
    return now;
  }

  ProgressSnapshot get _snapshot => ProgressSnapshot(
    progress: _progress,
    tutorials: _tutorialsDone,
    coins: _coins,
    hints: _hints,
    home: _home,
    needs: _needs,
    rewards: _rewards,
    language: _language,
    household: _household.copyWith(effectiveAt: _effectiveNow),
  );

  Future<bool> _commitHousehold(
    _HomeChange change, {
    _HomeChange? Function()? rebuild,
  }) {
    if (_homeBusy || _pendingHome != null || store is! SnapshotStore) {
      return Future.value(false);
    }
    _homeBusy = true;
    final task = _saving.then((_) async {
      final actual = rebuild == null ? change : rebuild();
      if (actual == null) return false;
      final candidate = ProgressSnapshot(
        progress: _progress,
        tutorials: _tutorialsDone,
        coins: _coins + actual.coins,
        hints: _hints,
        home: actual.home,
        needs: actual.needs,
        rewards: _rewards,
        language: _language,
        household: actual.household.copyWith(effectiveAt: _effectiveNow),
      );
      try {
        await (store as SnapshotStore).writeSnapshot(candidate.toJson());
      } on Object catch (error) {
        _pendingHome = actual;
        _pendingHomeRebuild = rebuild;
        debugPrint('Transaksi rumah gagal disimpan: $error');
        return false;
      }
      _home = candidate.home;
      _needs = candidate.needs;
      _household = candidate.household;
      // Puzzle/ads may have added coins while storage was awaiting. Preserve
      // that newer delta; their queued save writes the combined snapshot next.
      _coins += actual.coins;
      return true;
    });
    _saving = task.then<void>((_) {});
    return task.whenComplete(() {
      _homeBusy = false;
      _notifyHousehold();
    });
  }
}
