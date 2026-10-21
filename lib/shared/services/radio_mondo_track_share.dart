import 'package:share_plus/share_plus.dart';

import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/shared/services/radio_mondo_service.dart';

/// Shares a public Social Vote page, never the Storage audio URL.
/// Sharing does not fetch catalog/audio or write analytics to Supabase.
class RadioMondoTrackShare {
  RadioMondoTrackShare._();

  static String url(RadioMondoStation station) =>
      AppRouter.publicRadioTrackUrl(station.id);

  static Future<void> share(RadioMondoStation station) async {
    await Share.share(
      'Social Vote · Radio Mondo\n${station.title}\n${url(station)}',
      subject: station.title,
    );
  }
}
