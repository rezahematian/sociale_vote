import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

({int width, int height}) _pngSize(String path) {
  final bytes = File(path).readAsBytesSync();
  expect(bytes.length, greaterThanOrEqualTo(26), reason: path);
  expect(
    bytes.sublist(0, 8),
    equals(<int>[137, 80, 78, 71, 13, 10, 26, 10]),
    reason: '$path must be PNG',
  );
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  return (
    width: data.getUint32(16, Endian.big),
    height: data.getUint32(20, Endian.big),
  );
}

void main() {
  test('Home header uses the single centralized exact Social Vote lockup', () {
    final topBar = _read(
      'lib/features/home/presentation/widgets/home_top_bar.dart',
    );
    final brand = _read(
      'lib/shared/widgets/social_vote_brand_lockup.dart',
    );
    expect(topBar, contains('SocialVoteHeaderBrand'));
    expect(
      topBar,
      isNot(contains('assets/branding/social_vote_header_wordmark_exact.png')),
    );
    expect(
      brand,
      contains('assets/branding/social_vote_header_neon_lockup.png'),
    );
    expect(brand, contains('this.height = 48'));
    expect(brand, contains('FilterQuality.high'));
    expect(brand, contains('isAntiAlias: true'));
    expect(brand, isNot(contains("fontFamily: 'sans-serif'")));
    expect(brand, isNot(contains('FontWeight.w800')));
  });

  test('Exact Home header lockup is high resolution and transparent-capable', () {
    const path = 'assets/branding/social_vote_header_neon_lockup.png';
    expect(File(path).existsSync(), isTrue);
    expect(_pngSize(path), (width: 2095, height: 496));
    final bytes = File(path).readAsBytesSync();
    expect(bytes[25], equals(6), reason: 'PNG color type must be RGBA');
  });

  test('Flutter asset contract includes the official branding directory', () {
    final pubspec = _read('pubspec.yaml');
    expect(pubspec, contains('    - assets/branding/'));
    for (final path in <String>[
      'assets/branding/social_vote_header_neon_lockup.png',
      'assets/branding/social_vote_wordmark_horizontal.png',
      'assets/branding/social_vote_logo_stacked.png',
      'assets/branding/social_vote_symbol.png',
      'assets/icons/app_icon.png',
    ]) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });

  test('Web favicon, PWA, Apple and OG identity use official assets', () {
    final index = _read('web/index.html');
    expect(index, contains('favicon-48x48.png'));
    expect(index, contains('apple-touch-icon.png'));
    expect(index, contains('summary_large_image'));
    expect(index, contains('og:image:width'));
    expect(index, contains('content="1200"'));
    expect(index, contains('content="630"'));

    final expected = <String, ({int width, int height})>{
      'web/favicon-16x16.png': (width: 16, height: 16),
      'web/favicon-32x32.png': (width: 32, height: 32),
      'web/favicon-48x48.png': (width: 48, height: 48),
      'web/favicon.png': (width: 96, height: 96),
      'web/apple-touch-icon.png': (width: 180, height: 180),
      'web/icons/Icon-192.png': (width: 192, height: 192),
      'web/icons/Icon-512.png': (width: 512, height: 512),
      'web/icons/Icon-maskable-192.png': (width: 192, height: 192),
      'web/icons/Icon-maskable-512.png': (width: 512, height: 512),
      'web/social-vote-og.png': (width: 1200, height: 630),
    };
    for (final entry in expected.entries) {
      expect(_pngSize(entry.key), entry.value, reason: entry.key);
    }
    expect(File('web/favicon.ico').existsSync(), isTrue);
  });

  test('Android launcher and splash assets use the existing brand set', () {
    final expected = <String, ({int width, int height})>{
      'android/app/src/main/res/mipmap-mdpi/ic_launcher.png':
          (width: 48, height: 48),
      'android/app/src/main/res/mipmap-hdpi/ic_launcher.png':
          (width: 72, height: 72),
      'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png':
          (width: 96, height: 96),
      'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png':
          (width: 144, height: 144),
      'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png':
          (width: 192, height: 192),
      'android/app/src/main/res/drawable/launch_image.png':
          (width: 1280, height: 1280),
      'assets/icons/app_icon.png': (width: 1024, height: 1024),
    };
    for (final entry in expected.entries) {
      expect(_pngSize(entry.key), entry.value, reason: entry.key);
    }
  });

  test('Static public pages reference the existing official Web identity', () {
    final deletePage = _read('web/delete-account/index.html');
    final childSafety = _read('web/child-safety/index.html');
    expect(deletePage, contains('/brand/social-vote-symbol-128.png'));
    expect(deletePage, contains('/favicon-48x48.png'));
    expect(deletePage, contains('/apple-touch-icon.png'));
    expect(childSafety, contains('/favicon-48x48.png'));
    expect(childSafety, contains('/apple-touch-icon.png'));
  });
}
