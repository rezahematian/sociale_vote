import 'package:flutter/material.dart';

import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/radio_mondo_service.dart';
import 'package:sociale_vote/shared/services/social_vote_hud_service.dart';
import 'package:sociale_vote/shared/services/world_appearance_service.dart';
import 'package:sociale_vote/shared/widgets/world_control_visuals.dart';

/// Compact Radio Mondo control beside the Home Globe.
///
/// Home intentionally shows one circular control only. Tap toggles playback;
/// long-press opens the original tracks and the enabled Admin catalog. Playback policy remains owned by
/// [RadioMondoService]: no autoplay, no background service, no GeoScope coupling.
class RadioMondoDock extends StatelessWidget {
  final RadioVisualStyle visualStyle;
  final double size;

  const RadioMondoDock({
    super.key,
    this.visualStyle = RadioVisualStyle.vintageClassic,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final radio = RadioMondoService.instance;

    return AnimatedBuilder(
      animation: radio,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final station = radio.selectedStation;
        final active = radio.isPlaying;
        final label = active
            ? '${l10n.radioMondoTitle}. ${l10n.radioMondoPlaying}. '
                '${_stationLabel(l10n, station)}'
            : '${l10n.radioMondoTitle}. ${_stationLabel(l10n, station)}';

        return Semantics(
          button: true,
          toggled: active,
          label: label,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              key: const ValueKey<String>('radio-mondo-open'),
              customBorder: const CircleBorder(),
              onTap: radio.isLoading
                  ? null
                  : () => _togglePlayback(context, radio),
              onLongPress: radio.isLoading
                  ? null
                  : () => _showTrackPicker(context, radio),
              child: PremiumRadioControlVisual(
                style: visualStyle,
                active: active,
                loading: radio.isLoading,
                size: size,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _togglePlayback(
    BuildContext context,
    RadioMondoService radio,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    if (radio.isPlaying) {
      await radio.stop();
      if (context.mounted) {
        SocialVoteHud.showInfo(l10n.radioMondoStopped);
      }
      return;
    }

    await _playStation(context, radio, radio.selectedStation);
  }

  Future<void> _showTrackPicker(
    BuildContext context,
    RadioMondoService radio,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final stations = radio.stations;
    final selected = await showModalBottomSheet<RadioMondoStation>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * 0.72,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.radioMondoTitle,
                      style: Theme.of(sheetContext)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: stations.length,
                    itemBuilder: (_, index) {
                      final station = stations[index];
                      return ListTile(
                        leading: Icon(_stationIcon(station)),
                        title: Text(_stationLabel(l10n, station)),
                        subtitle: station.attribution == null
                            ? null
                            : Text(
                                station.attribution!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        trailing: station.id == radio.selectedStation.id
                            ? Icon(
                                radio.isPlaying
                                    ? Icons.equalizer_rounded
                                    : Icons.check_rounded,
                              )
                            : null,
                        onTap: () => Navigator.pop(sheetContext, station),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && context.mounted) {
      await _playStation(context, radio, selected);
    }
  }

  Future<void> _playStation(
    BuildContext context,
    RadioMondoService radio,
    RadioMondoStation station,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await radio.playStation(station);
    if (!context.mounted) return;

    if (success) {
      SocialVoteHud.showInfo(
        l10n.radioMondoPlaying,
        detail: _stationLabel(l10n, station),
      );
    } else {
      SocialVoteHud.showError(l10n.radioMondoPlaybackError);
    }
  }

  static String _stationLabel(
    AppLocalizations l10n,
    RadioMondoStation station,
  ) {
    final track = station.builtInTrack;
    if (track == null) return station.title;
    return switch (track) {
      RadioMondoTrack.classicalOrbit => l10n.radioMondoTrackClassical,
      RadioMondoTrack.worldRain => l10n.radioMondoTrackRain,
      RadioMondoTrack.youngPulse => l10n.radioMondoTrackYoung,
    };
  }

  static IconData _stationIcon(RadioMondoStation station) {
    final track = station.builtInTrack;
    if (track == null) return Icons.library_music_outlined;
    return switch (track) {
      RadioMondoTrack.classicalOrbit => Icons.piano_rounded,
      RadioMondoTrack.worldRain => Icons.water_drop_outlined,
      RadioMondoTrack.youngPulse => Icons.graphic_eq_rounded,
    };
  }
}
