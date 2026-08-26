import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sociale_vote/shared/widgets/content_directionality.dart';

void main() {
  test('authored content keeps its own base direction independent of UI locale',
      () {
    expect(
      socialVoteContentDirection('Social Vote parte da Merano'),
      TextDirection.ltr,
    );
    expect(
      socialVoteContentDirection('West Nile, muore donna'),
      TextDirection.ltr,
    );
    expect(
      socialVoteContentDirection('آینده را با هم شکل دهید'),
      TextDirection.rtl,
    );
    expect(
      socialVoteContentDirection('2026-08-25'),
      TextDirection.ltr,
    );
  });
}
