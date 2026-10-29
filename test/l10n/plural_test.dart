import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/l10n/l10n.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final id = lookupAppLocalizations(const Locale('id'));
  final pt = lookupAppLocalizations(const Locale('pt'));
  final ru = lookupAppLocalizations(const Locale('ru'));

  test('Rusia punya tiga bentuk jamak: 1 шаг, 2 шага, 5 шагов, 21 шаг', () {
    expect(
      [
        for (final n in [1, 2, 5, 21, 22, 11]) '$n ${ru.stepsUnit(n)}',
      ],
      ['1 шаг', '2 шага', '5 шагов', '21 шаг', '22 шага', '11 шагов'],
    );
    expect(ru.coinsAmount(1), '1 монета');
    expect(ru.coinsAmount(3), '3 монеты');
    expect(ru.coinsAmount(120), '120 монет');
    expect(ru.storageCount(1), '1 вещь');
    expect(ru.storageCount(3), '3 вещи');
    expect(ru.storageCount(5), '5 вещей');
    expect(ru.nodeStars(2), '2 звезды');
    expect(ru.starsOf(31, 60), '31 из 60 звёзд');
  });

  test('Inggris dan Portugis: satu dan banyak', () {
    expect(en.coinsAmount(1), '1 coin');
    expect(en.coinsAmount(20), '20 coins');
    expect(en.itemsUsed(1), '1 item used');
    expect(en.targetItems(2), 'use 2 items');
    expect(pt.coinsAmount(1), '1 moeda');
    expect(pt.storageCount(1), '1 item');
    expect(pt.storageCount(3), '3 itens');
    // Harga, bukan kekurangan koin.
    expect(en.notEnoughCoins(40), 'Not enough · 40');
    expect(pt.notEnoughCoins(40), 'Moedas insuficientes · 40');
  });

  test('Indonesia tanpa bentuk jamak', () {
    expect(id.coinsAmount(1), '1 koin');
    expect(id.coinsAmount(20), '20 koin');
    expect(id.stepsUnit(6), 'langkah');
  });

  test('aturan memakai searah jarum jam, bukan belok kanan', () {
    for (final l in [en, id, pt, ru]) {
      expect(
        l.ruleWallTurn,
        isNot(contains(RegExp('right|kanan|direita|право'))),
      );
    }
    expect(en.ruleWallTurn, 'Oyen turns clockwise');
    expect(en.tieClockwise, 'clockwise');
    expect(pt.tieClockwise, 'sentido horário');
    expect(ru.tieClockwise, 'по часовой');
  });

  test('nama game tidak diterjemahkan', () {
    expect(appName, 'Ginger Logic');
  });
}
