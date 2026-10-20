// Konfigurasi Android yang kalau salah membuat aplikasi crash saat dibuka
// atau ditolak Play Console. Berkas dibaca sebagai teks.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _app = 'android/app';
const _main = '$_app/src/main';

String _read(String path) => File(path).readAsStringSync();

void main() {
  group('identitas dan iklan', () {
    test('applicationId dan namespace com.gingerlogic.app', () {
      final gradle = _read('$_app/build.gradle.kts');
      expect(gradle, contains('applicationId = "com.gingerlogic.app"'));
      expect(gradle, contains('namespace = "com.gingerlogic.app"'));
    });

    test('MainActivity di paket com.gingerlogic.app', () {
      final file = File('$_main/kotlin/com/gingerlogic/app/MainActivity.kt');
      expect(file.existsSync(), isTrue);
      expect(file.readAsStringSync(), contains('package com.gingerlogic.app'));
      expect(Directory('$_main/kotlin/com/example').existsSync(), isFalse);
    });

    test('ID aplikasi AdMob ditempel di satu tempat dan masuk manifest', () {
      final gradle = _read('$_app/build.gradle.kts');
      expect(gradle, contains('val admobAppId = "ca-app-pub-'));
      expect(gradle, contains('TEMPEL ID ASLI DI SINI'));
      expect(gradle, contains('manifestPlaceholders["admobAppId"]'));
      final manifest = _read('$_main/AndroidManifest.xml');
      // Tanpa meta-data ini SDK iklan menghentikan aplikasi saat dibuka.
      expect(
        manifest,
        matches(
          RegExp(
            r'android:name="com\.google\.android\.gms\.ads\.APPLICATION_ID"'
            r'\s+android:value="\$\{admobAppId\}"',
          ),
        ),
      );
    });

    test('Auto Backup tetap aktif dan tautan https bisa dibuka', () {
      final manifest = _read('$_main/AndroidManifest.xml');
      expect(manifest, isNot(contains('allowBackup="false"')));
      expect(manifest, contains('android.intent.action.VIEW'));
      expect(manifest, contains('android:scheme="https"'));
    });

    test('signing release dari key.properties dengan cadangan debug', () {
      final gradle = _read('$_app/build.gradle.kts');
      expect(gradle, contains('key.properties'));
      expect(gradle, contains('signingConfigs.getByName("debug")'));
      expect(_read('android/.gitignore'), contains('key.properties'));
    });

    test('versi 1.0.0+1', () {
      expect(
        _read('pubspec.yaml'),
        matches(RegExp(r'^version: 1\.0\.0\+1\r?$', multiLine: true)),
      );
    });
  });
}
