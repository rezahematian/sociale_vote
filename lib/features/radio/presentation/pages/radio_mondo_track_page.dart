import 'package:flutter/material.dart';

import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/radio_mondo_service.dart';
import 'package:sociale_vote/shared/services/radio_mondo_track_share.dart';

/// Public landing page for a shared Radio Mondo track.
/// The already-initialized catalog is reused: no fetch, preview, or autoplay.
class RadioMondoTrackPage extends StatelessWidget {
  final String stationId;

  const RadioMondoTrackPage({super.key, required this.stationId});

  static const _translations = <String, Map<String, String>>{
    'listen': {
      'it': 'Ascolta',
      'en': 'Listen',
      'de': 'Anhören',
      'fa': 'گوش دادن',
      'es': 'Escuchar',
      'pt': 'Ouvir',
      'fr': 'Écouter',
      'ar': 'استمع',
      'ro': 'Ascultă',
      'ru': 'Слушать',
      'zh': '收听',
    },
    'pause': {
      'it': 'Pausa',
      'en': 'Pause',
      'de': 'Pause',
      'fa': 'مکث',
      'es': 'Pausa',
      'pt': 'Pausa',
      'fr': 'Pause',
      'ar': 'إيقاف مؤقت',
      'ro': 'Pauză',
      'ru': 'Пауза',
      'zh': '暂停',
    },
    'share': {
      'it': 'Condividi',
      'en': 'Share',
      'de': 'Teilen',
      'fa': 'اشتراک‌گذاری',
      'es': 'Compartir',
      'pt': 'Compartilhar',
      'fr': 'Partager',
      'ar': 'مشاركة',
      'ro': 'Distribuie',
      'ru': 'Поделиться',
      'zh': '分享',
    },
    'unavailable': {
      'it': 'Questo brano non è disponibile',
      'en': 'This track is unavailable',
      'de': 'Dieser Titel ist nicht verfügbar',
      'fa': 'این قطعه در دسترس نیست',
      'es': 'Esta pista no está disponible',
      'pt': 'Esta faixa não está disponível',
      'fr': 'Ce morceau est indisponible',
      'ar': 'هذه المقطوعة غير متاحة',
      'ro': 'Această piesă nu este disponibilă',
      'ru': 'Этот трек недоступен',
      'zh': '此曲目不可用',
    },
    'error': {
      'it': 'Operazione non riuscita',
      'en': 'Action failed',
      'de': 'Aktion fehlgeschlagen',
      'fa': 'عملیات ناموفق بود',
      'es': 'La operación falló',
      'pt': 'A operação falhou',
      'fr': 'Échec de l’action',
      'ar': 'فشلت العملية',
      'ro': 'Operațiune nereușită',
      'ru': 'Действие не выполнено',
      'zh': '操作失败',
    },
  };

  String _t(BuildContext context, String key) {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    return _translations[key]?[lang] ?? _translations[key]!['en']!;
  }

  Future<void> _toggle(BuildContext context, RadioMondoStation station) async {
    final radio = RadioMondoService.instance;
    final same = radio.currentStation?.id == station.id;
    try {
      if (same && radio.isPlaying) {
        await radio.pause();
      } else if (same) {
        await radio.resume();
      } else {
        final success = await radio.playStation(station);
        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_t(context, 'error'))),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t(context, 'error'))),
        );
      }
    }
  }

  Future<void> _share(BuildContext context, RadioMondoStation station) async {
    try {
      await RadioMondoTrackShare.share(station);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t(context, 'error'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final radio = RadioMondoService.instance;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.radioMondoTitle)),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: radio,
          builder: (context, _) {
            RadioMondoStation? station;
            for (final item in radio.stations) {
              if (item.id == stationId) {
                station = item;
                break;
              }
            }
            final track = station;
            if (track == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: radio.isLoading
                      ? const CircularProgressIndicator()
                      : Text(_t(context, 'unavailable')),
                ),
              );
            }
            final playing =
                radio.isPlaying && radio.currentStation?.id == track.id;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.library_music_rounded,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 22),
                      Text(track.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall),
                      if (track.attribution?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Text(track.attribution!, textAlign: TextAlign.center),
                      ],
                      const SizedBox(height: 22),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: radio.isLoading
                                ? null
                                : () => _toggle(context, track),
                            icon: Icon(playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded),
                            label:
                                Text(_t(context, playing ? 'pause' : 'listen')),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _share(context, track),
                            icon: const Icon(Icons.share_outlined),
                            label: Text(_t(context, 'share')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
