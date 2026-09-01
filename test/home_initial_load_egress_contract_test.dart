import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('essential Home content is not blocked by automatic egress budget', () {
    final source = File(
      'lib/features/home/presentation/pages/public_home_screen.dart',
    ).readAsStringSync();

    expect(source, contains('void _scheduleEssentialHomeLoad('));
    expect(
      source,
      contains('() => controller.loadPolls(userId: currentUserId)'),
    );
    expect(
      source,
      contains('() => controller.loadFeed(userId: currentUserId)'),
    );
    expect(
      source,
      contains('() => controller.loadNews(userId: currentUserId)'),
    );

    final essentialLoadStart = source.indexOf(
      'void _scheduleEssentialHomeLoad(',
    );
    final essentialLoadEnd = source.indexOf(
      'void _markNextHomeReloadUserInitiated()',
      essentialLoadStart,
    );
    final essentialLoadSource = source.substring(
      essentialLoadStart,
      essentialLoadEnd,
    );

    expect(essentialLoadSource, isNot(contains('tryConsumeAutomatic')));
  });
}
