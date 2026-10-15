import 'dart:convert';

import 'board.dart';
import 'item.dart';
import 'pos.dart';

/// Data satu level dari `assets/levels/*.json`.
class Level {
  Level({
    required this.id,
    required this.name,
    required this.chapter,
    required this.map,
    required this.inventory,
    required this.starItems,
    required this.solution,
    required this.solutionSteps,
  }) : board = Board.parse(map);

  factory Level.fromJson(Map<String, dynamic> json) {
    final inventory = json['inventory'] as Map<String, dynamic>;
    return Level(
      id: json['id'] as int,
      name: json['name'] as String,
      chapter: json['chapter'] as int,
      map: List.unmodifiable((json['map'] as List).cast<String>()),
      inventory: Map.unmodifiable({
        for (final e in inventory.entries) Item.fromKey(e.key): e.value as int,
      }),
      starItems: json['starItems'] as int,
      solution: List.unmodifiable([
        for (final s in (json['solution'] as List).cast<Map<String, dynamic>>())
          Placement(
            Item.fromKey(s['item'] as String),
            Pos(s['x'] as int, s['y'] as int),
          ),
      ]),
      solutionSteps: json['solutionSteps'] as int,
    );
  }

  final int id;
  final String name;
  final int chapter;

  /// Peta teks asli, satu string per baris.
  final List<String> map;
  final Board board;

  /// Isi baki: jumlah tiap benda yang boleh ditaruh pemain.
  final Map<Item, int> inventory;

  /// Jumlah benda paling sedikit untuk bintang 3.
  final int starItems;

  /// Solusi bintang 3 dan jumlah langkahnya.
  final List<Placement> solution;
  final int solutionSteps;

  @override
  String toString() => 'Level $id · $name';
}

/// Mengurai isi file JSON berisi daftar level.
List<Level> parseLevels(String source) => [
  for (final json in (jsonDecode(source) as List).cast<Map<String, dynamic>>())
    Level.fromJson(json),
];
