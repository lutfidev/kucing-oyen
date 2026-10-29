import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/chapter.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/snacks.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/l10n/names.dart';
import 'package:kucing_oren/screens/level/tutorial.dart';

import '../test_helpers.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ru = lookupAppLocalizations(const Locale('ru'));
  final chapters = chaptersOf(testLevels);

  test('nama level Indonesia sama dengan data level, ke-20 level', () {
    for (final level in testLevels) {
      expect(levelName(l10nId, level), level.name, reason: '${level.id}');
    }
  });

  test('nama level bahasa lain, bos dengan awalan', () {
    expect(levelName(en, testLevels[12]), "Mom's Vase");
    expect(levelName(en, testLevels[9]), 'BOSS: Salted Fish Feast');
    expect(levelName(ru, testLevels[19]), 'БОСС: Ураза-байрам');
    for (final level in testLevels) {
      expect(levelName(en, level), isNot(level.name), reason: '${level.id}');
    }
  });

  test('level tanpa terjemahan memakai nama di data', () {
    final extra = Level(
      id: 21,
      name: 'Lorong Panjang',
      chapter: 3,
      map: testLevels.first.map,
      inventory: const {},
      starItems: 0,
      solution: const [],
      solutionSteps: 0,
    );
    expect(levelName(en, extra), 'Lorong Panjang');
  });

  test('babak dan bos', () {
    final [kitchen, livingRoom] = chapters;
    expect(chapterName(l10nId, kitchen), 'Dapur');
    expect(chapterTitle(l10nId, kitchen), 'Babak 1 – Dapur');
    expect(chapterTitle(en, livingRoom), 'Chapter 2 – Living Room');
    expect(bossName(l10nId, kitchen), 'Pesta Ikan Asin');
    expect(bossName(l10nId, livingRoom), 'Hari Lebaran');
    expect(bossName(en, livingRoom), 'Eid Day');
  });

  test('benda dan Oyen', () {
    expect(itemName(l10nId, Item.water), 'Ember air');
    expect(itemName(en, Item.fish), 'Salted fish');
    const look = OyenLook(pose: OyenPose.sleep, dir: Direction.left);
    expect(oyenLabel(l10nId, look), 'Oyen tidur, menghadap kiri');
    expect(oyenLabel(en, look), 'Oyen asleep, facing left');
    expect(
      oyenLabel(ru, const OyenLook(pose: OyenPose.walk, dir: Direction.up)),
      'Ойен идёт, смотрит вверх',
    );
  });

  test('isi petak untuk pembaca layar: semua sel, keempat bahasa', () {
    expect(cellName(l10nId, Cell.tableVase), 'meja dengan vas');
    expect(cellName(en, Cell.bowl), "Oyen's bowl");
    for (final locale in ['en', 'id', 'pt', 'ru']) {
      final l = lookupAppLocalizations(Locale(locale));
      final names = {for (final cell in Cell.values) cellName(l, cell)};
      expect(names, hasLength(Cell.values.length), reason: locale);
      expect(names.where((n) => n.trim().isEmpty), isEmpty, reason: locale);
    }
  });

  test('tutorial level 1, 3, 6', () {
    expect(
      tutorialTitle(l10nId, tutorialFor(1)!),
      'Oyen nggak bisa disuruh. Bangunkan saja dia!',
    );
    expect(
      tutorialBody(l10nId, tutorialFor(6)!),
      'Taruh ember di jalannya. Ketemu air, dia kaget lalu putar balik.',
    );
    expect(
      tutorialTitle(en, tutorialFor(3)!),
      "Oyen can't resist salted fish!",
    );
  });

  group('katalog Toko', () {
    const itemNames = {
      RoomItemId.tikus: 'Tikus Mainan',
      RoomItemId.akuarium: 'Akuarium',
      RoomItemId.rumah: 'Rumah Kucing',
      RoomItemId.kasur: 'Kasur Bantal',
      RoomItemId.catnip: 'Pot Catnip',
      RoomItemId.jam: 'Jam Kucing',
      RoomItemId.kardus: 'Kardus Nyaman',
      RoomItemId.bola: 'Bola Benang',
      RoomItemId.karpet: 'Karpet Bulat',
      RoomItemId.tiang: 'Tiang Garukan',
      RoomItemId.lukisan: 'Lukisan Ikan',
      RoomItemId.rak: 'Rak Dinding',
      RoomItemId.pancingan: 'Pancingan Bulu',
      RoomItemId.lampuBulan: 'Lampu Bulan',
      RoomItemId.bantalIkan: 'Bantal Ikan',
      RoomItemId.monstera: 'Tanaman Monstera',
      RoomItemId.terowongan: 'Terowongan Kucing',
      RoomItemId.hammock: 'Hammock Jendela',
      RoomItemId.sofaMini: 'Sofa Mini',
      RoomItemId.jendelaBurung: 'Jendela Burung',
      RoomItemId.mangkuk: 'Mangkuk makan',
    };

    test('nama barang Indonesia sama dengan katalog desain', () {
      for (final MapEntry(:key, :value) in itemNames.entries) {
        expect(roomItemName(l10nId, key), value, reason: key.name);
      }
    });

    test('nama kucing, aksesoris, dan camilan Indonesia dari desain', () {
      expect(kittyName(l10nId, KittyId.oyen), 'Oyen');
      expect(kittyName(l10nId, KittyId.kopiSusu), 'Kopi Susu');
      expect(kittyName(l10nId, KittyId.kembang), 'Kembang');
      expect(accessoryName(l10nId, AccessoryId.kalung), 'Kalung Lonceng');
      expect(accessoryName(l10nId, AccessoryId.mahkotaRaja), 'Mahkota Raja');
      expect(accessoryName(l10nId, AccessoryId.kacamata), 'Kacamata Bulat');
      expect(snackName(l10nId, SnackId.puding), 'Puding Ikan');
      expect(snackName(l10nId, SnackId.tuna), 'Tuna Kaleng');
    });

    test('deskripsi Indonesia dari desain, dan tidak ada yang kosong', () {
      expect(
        roomItemDesc(l10nId, RoomItemId.kardus),
        'Yang dipilih kardusnya, bukan isinya.',
      );
      expect(
        kittyDesc(l10nId, KittyId.bos),
        'Selalu pakai jas. Rapat tiap jam makan.',
      );
      expect(
        accessoryDesc(l10nId, AccessoryId.topiKoki),
        'Masak? Nggak. Cicip? Selalu.',
      );
      expect(
        snackDesc(l10nId, SnackId.biskuit),
        'Kriuk dan murah. Kenyangnya sedikit.',
      );
      for (final l in [l10nId, en, ru]) {
        for (final id in RoomItemId.values) {
          expect(roomItemName(l, id), isNotEmpty, reason: id.name);
          if (id != RoomItemId.mangkuk) {
            expect(roomItemDesc(l, id), isNotEmpty, reason: id.name);
          }
        }
        for (final id in KittyId.values) {
          expect(kittyName(l, id), isNotEmpty, reason: id.name);
          expect(kittyDesc(l, id), isNotEmpty, reason: id.name);
        }
        for (final id in AccessoryId.values) {
          expect(accessoryName(l, id), isNotEmpty, reason: id.name);
          expect(accessoryDesc(l, id), isNotEmpty, reason: id.name);
        }
        for (final id in SnackId.values) {
          expect(snackName(l, id), isNotEmpty, reason: id.name);
          expect(snackDesc(l, id), isNotEmpty, reason: id.name);
        }
      }
    });

    test('nama katalog bahasa lain diterjemahkan; Oyen tetap', () {
      expect(roomItemName(en, RoomItemId.kardus), 'Cozy Box');
      expect(accessoryName(en, AccessoryId.pita), 'Ribbon');
      expect(snackName(en, SnackId.susu), 'Milk');
      expect(kittyName(en, KittyId.salju), 'Snowy');
      expect(kittyName(l10nId, KittyId.oyen), 'Oyen');
      expect(kittyName(en, KittyId.oyen), 'Oyen');
      // Teks Rusia yang sudah ada juga menulis namanya dengan Kiril.
      expect(kittyName(ru, KittyId.oyen), 'Ойен');
      for (final id in RoomItemId.values) {
        expect(
          roomItemName(en, id),
          isNot(roomItemName(l10nId, id)),
          reason: id.name,
        );
      }
    });

    test('kelangkaan per bahasa', () {
      expect(rarityName(l10nId, Rarity.common), 'Biasa');
      expect(rarityName(l10nId, Rarity.rare), 'Langka');
      expect(rarityName(l10nId, Rarity.special), 'Spesial');
      for (final rarity in Rarity.values) {
        expect(rarityName(en, rarity), isNotEmpty);
        expect(rarityName(ru, rarity), isNotEmpty);
      }
    });

    test('label pembaca layar kucing kamar', () {
      expect(
        kittyLabel(l10nId, const KittyLook(kitty: KittyId.oyen)),
        'Oyen duduk diam',
      );
      expect(
        kittyLabel(
          l10nId,
          const KittyLook(
            kitty: KittyId.salju,
            pose: KittyPose.sleep,
            accessory: AccessoryId.pita,
          ),
        ),
        'Salju tidur melingkar, memakai Pita',
      );
      expect(
        kittyLabel(
          en,
          const KittyLook(kitty: KittyId.bos, pose: KittyPose.eat),
        ),
        'Boss eating from the bowl',
      );
    });
  });
}
