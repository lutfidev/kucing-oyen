// Konfigurasi Android yang kalau salah membuat aplikasi crash saat dibuka
// atau ditolak Play Console. Berkas dibaca sebagai teks.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/theme/theme.dart';

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

  group('ikon dan splash', () {
    const res = '$_main/res';
    const densities = {
      'mdpi': 1.0,
      'hdpi': 1.5,
      'xhdpi': 2.0,
      'xxhdpi': 3.0,
      'xxxhdpi': 4.0,
    };

    /// Lebar × tinggi dari header IHDR PNG.
    (int, int) pngSize(String path) {
      final bytes = File(path).readAsBytesSync();
      final data = ByteData.sublistView(bytes);
      return (data.getUint32(16), data.getUint32(20));
    }

    void expectPng(String path, double width, double height, double ratio) {
      expect(File(path).existsSync(), isTrue, reason: path);
      expect(pngSize(path), (
        (width * ratio).round(),
        (height * ratio).round(),
      ), reason: path);
    }

    test('PNG ikon dan splash per densitas, ukurannya benar', () {
      for (final MapEntry(key: dpi, value: ratio) in densities.entries) {
        expectPng(
          '$res/mipmap-$dpi/ic_launcher_foreground.png',
          108,
          108,
          ratio,
        );
        expectPng(
          '$res/mipmap-$dpi/ic_launcher_monochrome.png',
          108,
          108,
          ratio,
        );
        expectPng('$res/mipmap-$dpi/ic_launcher.png', 48, 48, ratio);
        expectPng('$res/drawable-$dpi/splash_icon.png', 288, 288, ratio);
        for (final lang in ['', '-in', '-pt', '-ru']) {
          expectPng(
            '$res/drawable$lang-$dpi/splash_branding.png',
            200,
            80,
            ratio,
          );
        }
      }
    });

    test('Indonesia memakai kualifier Android "in", bukan "id"', () {
      final ids = Directory(res)
          .listSync()
          .map((e) => e.path.replaceAll('\\', '/').split('/').last)
          .where((name) => name.startsWith('drawable-id'));
      expect(ids, isEmpty);
    });

    test('warna krem sama dengan KoColors', () {
      final cream = KoTheme.light().extension<KoColors>()!.cream;
      final hex = (cream.toARGB32() & 0xFFFFFF)
          .toRadixString(16)
          .padLeft(6, '0')
          .toUpperCase();
      expect(
        _read('$res/values/colors.xml'),
        contains('<color name="cream">#$hex</color>'),
      );
    });

    test('ikon adaptif: latar krem, depan, dan monokrom', () {
      final icon = _read('$res/mipmap-anydpi-v26/ic_launcher.xml');
      expect(icon, contains('<adaptive-icon'));
      expect(icon, contains('@color/cream'));
      expect(icon, contains('@mipmap/ic_launcher_foreground'));
      expect(icon, contains('<monochrome'));
      expect(icon, contains('@mipmap/ic_launcher_monochrome'));
    });

    test('splash Android 12+ dan cadangannya', () {
      final v31 = _read('$res/values-v31/styles.xml');
      expect(v31, contains('android:windowSplashScreenBackground'));
      expect(v31, contains('@color/cream'));
      expect(v31, contains('android:windowSplashScreenAnimatedIcon'));
      expect(v31, contains('@drawable/splash_icon'));
      expect(v31, contains('android:windowSplashScreenBrandingImage'));
      expect(v31, contains('@drawable/splash_branding'));
      final launch = _read('$res/drawable/launch_background.xml');
      expect(launch, contains('@color/cream'));
      expect(launch, contains('@drawable/splash_icon'));
      expect(launch, contains('@drawable/splash_branding'));
      expect(
        File('$res/drawable-v21/launch_background.xml').existsSync(),
        isFalse,
      );
    });

    test('latar Flutter krem tanpa mode gelap (tanpa kedip putih)', () {
      for (final path in [
        '$res/values/styles.xml',
        '$res/values-v31/styles.xml',
      ]) {
        final styles = _read(path);
        expect(styles, contains('name="NormalTheme"'), reason: path);
        expect(
          RegExp(r'name="NormalTheme"[\s\S]*?@color/cream').hasMatch(styles),
          isTrue,
          reason: path,
        );
      }
      expect(Directory('$res/values-night').existsSync(), isFalse);
    });
  });
}
