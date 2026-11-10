part of 'progress_scope.dart';

class _GuidanceChange {
  const _GuidanceChange({required this.coins, this.hints, this.rewards});
  final int coins;
  final Map<int, int>? hints;
  final DailyRewards? rewards;
}

extension _GuidanceTransactions on ProgressController {
  Future<bool> _commitGuidance(_GuidanceChange? Function() build) {
    if (_resetting || _guidanceBusy || _pendingGuidance != null) {
      return Future.value(false);
    }
    _guidanceBusy = true;
    _notifyHousehold();
    final task = _saving.then((_) async {
      final change = build();
      if (change == null || _coins + change.coins < 0) return false;
      final candidate = ProgressSnapshot(
        progress: _progress,
        tutorials: _tutorialsDone,
        coins: _coins + change.coins,
        hints: change.hints ?? _hints,
        home: _home,
        needs: _needs,
        rewards: change.rewards ?? _rewards,
        language: _language,
        household: _household.copyWith(effectiveAt: _effectiveNow),
      );
      try {
        await (store as SnapshotStore).writeSnapshot(candidate.toJson());
      } on Object catch (error) {
        _pendingGuidance = build;
        debugPrint('Transaksi bantuan gagal disimpan: $error');
        return false;
      }
      // Preserve puzzle earnings which arrived while the write was awaiting.
      _coins += change.coins;
      if (change.hints != null) _hints = Map.unmodifiable(change.hints!);
      if (change.rewards != null) _rewards = change.rewards!;
      return true;
    });
    _saving = task.then<void>((_) {});
    return task.whenComplete(() {
      _guidanceBusy = false;
      _notifyHousehold();
    });
  }
}
