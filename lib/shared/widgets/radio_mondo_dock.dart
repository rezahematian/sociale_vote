import 'package:flutter/material.dart';

import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/radio_mondo_service.dart';
import 'package:sociale_vote/shared/services/social_vote_hud_service.dart';
import 'package:sociale_vote/shared/services/world_appearance_service.dart';
import 'package:sociale_vote/shared/widgets/world_control_visuals.dart';

/// Compact Radio Mondo control beside the Home Globe.
///
/// Home intentionally shows one circular control only. Tap toggles playback;
/// long-press opens the enabled Admin catalog. Playback policy remains owned by
/// [RadioMondoService]: no autoplay, no background service, no GeoScope coupling.
class RadioMondoDock extends StatelessWidget {
  final RadioVisualStyle visualStyle;
  final double size;
  final GlobeVisualStyle? globeStyle;
  final GlobeRotationVisualStyle rotationVisualStyle;
  final VoidCallback? onPickerOpened;
  final VoidCallback? onPickerDismissed;
  final VoidCallback? onPickerClosed;

  const RadioMondoDock({
    super.key,
    this.visualStyle = RadioVisualStyle.oldStyle,
    this.size = 44,
    this.globeStyle,
    this.rotationVisualStyle = GlobeRotationVisualStyle.classic,
    this.onPickerOpened,
    this.onPickerDismissed,
    this.onPickerClosed,
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
        final label = station == null
            ? l10n.radioMondoTitle
            : active
                ? '${l10n.radioMondoTitle}. ${l10n.radioMondoPlaying}. '
                    '${_stationLabel(l10n, station)}'
                : '${l10n.radioMondoTitle}. ${_stationLabel(l10n, station)}';

        if (globeStyle != null) {
          return WorldRoundControl(
            key: const ValueKey<String>('radio-mondo-open'),
            icon: switch (visualStyle) {
              RadioVisualStyle.vintageClassic => Icons.music_note_rounded,
              RadioVisualStyle.retroElegant => Icons.equalizer_rounded,
              RadioVisualStyle.woodMinimal => Icons.graphic_eq_rounded,
              _ => Icons.radio_rounded,
            },
            label: label,
            active: active,
            loading: radio.isLoading,
            globeStyle: globeStyle!,
            visualStyle: rotationVisualStyle,
            size: size,
            onTap: () => _togglePlayback(context, radio),
            onLongPress: () => _showTrackPicker(context, radio),
          );
        }

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

    var station = radio.selectedStation;

    if (station == null) {
      await radio.reloadCatalog();
      if (!context.mounted) return;

      station = radio.selectedStation;
      if (station == null) {
        SocialVoteHud.showError(l10n.radioMondoPlaybackError);
        return;
      }
    }

    await _playStation(context, radio, station);
  }

  Future<void> _showTrackPicker(
    BuildContext context,
    RadioMondoService radio,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final stations = radio.stations;
    // Disable the underlying Web Globe before the Radio picker is shown.
    onPickerOpened?.call();

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
                        subtitle: Text(
                          [
                            if (station.isLive) 'LIVE',
                            _channelLabel(station),
                            if (station.languageCode != null)
                              station.languageCode!.toUpperCase(),
                            if (station.attribution != null)
                              station.attribution!,
                          ].join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: station.id == radio.selectedStation?.id
                            ? Icon(
                                radio.isPlaying
                                    ? Icons.equalizer_rounded
                                    : Icons.check_rounded,
                              )
                            : null,
                        onTap: () {
                          // Web mobile: arm the Home surface guard BEFORE the
                          // station picker disappears. Otherwise the same
                          // physical pointer can fall through to HtmlElementView
                          // and open Civic Map.
                          onPickerClosed?.call();
                          Navigator.pop(sheetContext, station);
                        },
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

    // The modal route is now gone. The existing V3 trailing-tap guard
    // remains active while Globe pointer handling is restored.
    onPickerDismissed?.call();

    // On mobile Web the Home globe is an HtmlElementView. Closing this
    // Flutter bottom sheet on the same physical tap used to select a station
    // can expose the underlying WebGL surface before the browser finishes
    // dispatching that pointer. Give the Home globe a chance to suppress that
    // trailing surface tap so station selection never becomes Civic Map nav.
    onPickerClosed?.call();

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

  static String _channelLabel(RadioMondoStation station) {
    return switch (station.channelType) {
      RadioMondoChannelType.worldLive => 'World Live',
      RadioMondoChannelType.nature => 'Nature',
      RadioMondoChannelType.worldBrief => 'World Brief Audio',
      RadioMondoChannelType.liveEvent => 'Live Event',
      RadioMondoChannelType.special => 'Special',
    };
  }

  static IconData _stationIcon(RadioMondoStation station) {
    if (station.isLive || station.sourceType == RadioMondoSourceType.stream) {
      return Icons.cell_tower_rounded;
    }
    return switch (station.channelType) {
      RadioMondoChannelType.worldLive => Icons.public_rounded,
      RadioMondoChannelType.nature => Icons.spa_outlined,
      RadioMondoChannelType.worldBrief => Icons.campaign_outlined,
      RadioMondoChannelType.liveEvent => Icons.sensors_rounded,
      RadioMondoChannelType.special => Icons.graphic_eq_rounded,
    };
  }
}
