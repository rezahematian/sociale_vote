import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/radio_mondo_service.dart';
import 'package:sociale_vote/shared/services/social_vote_hud_service.dart';
import 'package:sociale_vote/shared/services/world_appearance_service.dart';
import 'package:sociale_vote/shared/widgets/world_control_visuals.dart';

/// Compact Radio Mondo control beside the Home Globe.
///
/// Home intentionally shows one circular control only. Tap toggles play/pause;
/// long-press opens categories, playlist controls and the enabled catalog.
/// Playback policy remains owned by [RadioMondoService]: no autoplay and no
/// GeoScope coupling.
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
        final station = radio.currentStation ?? radio.selectedStation;
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
      await radio.pause();
      if (context.mounted) {
        SocialVoteHud.showInfo(
            _uiText(context, 'Radio in pausa', 'Radio paused'));
      }
      return;
    }

    if (radio.currentStation != null) {
      await radio.resume();
      if (context.mounted && radio.isPlaying) {
        SocialVoteHud.showInfo(
          l10n.radioMondoPlaying,
          detail: _stationLabel(l10n, radio.currentStation!),
        );
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
    onPickerOpened?.call();

    final viewport = MediaQuery.sizeOf(context);
    final wideSheet = viewport.width >= 720;
    final sheetHeight = viewport.height * (wideSheet ? 0.70 : 0.80);

    final selected = await showModalBottomSheet<RadioMondoStation>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: wideSheet ? 760 : viewport.width,
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: sheetHeight,
            child: AnimatedBuilder(
              animation: radio,
              builder: (sheetContext, _) {
                final l10n = AppLocalizations.of(sheetContext)!;
                final theme = Theme.of(sheetContext);
                final colors = theme.colorScheme;
                final category = radio.selectedCategory;
                final stations = radio.stationsForCategory(category);
                final activeStation =
                    radio.currentStation ?? radio.selectedStation;

                Widget buildPlaybackControls() {
                  final controlsEnabled =
                      stations.isNotEmpty && !radio.isLoading;

                  Widget transportGlyph({
                    required bool next,
                    required Color color,
                  }) {
                    final triangle = Text(
                      next ? '▶' : '◀',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    );

                    final stopBar = Container(
                      width: 2.4,
                      height: 17,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );

                    return SizedBox(
                      width: 25,
                      height: 22,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: next
                              ? [
                                  triangle,
                                  const SizedBox(width: 1),
                                  stopBar,
                                ]
                              : [
                                  stopBar,
                                  const SizedBox(width: 1),
                                  triangle,
                                ],
                        ),
                      ),
                    );
                  }

                  Widget playPauseGlyph({
                    required bool playing,
                    required Color color,
                  }) {
                    if (!playing) {
                      return Text(
                        '▶',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: color,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      );
                    }

                    return SizedBox(
                      width: 22,
                      height: 24,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 20,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 5,
                              height: 20,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  Widget transportButton({
                    required String tooltip,
                    required bool next,
                    required VoidCallback? onPressed,
                  }) {
                    final glyphColor = controlsEnabled
                        ? colors.onSurface
                        : colors.onSurface.withValues(alpha: 0.38);

                    return IconButton(
                      tooltip: tooltip,
                      constraints: const BoxConstraints.tightFor(
                        width: 44,
                        height: 44,
                      ),
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surfaceContainerHighest,
                        foregroundColor: colors.onSurface,
                        disabledBackgroundColor: colors.surfaceContainerHighest
                            .withValues(alpha: 0.55),
                        disabledForegroundColor:
                            colors.onSurface.withValues(alpha: 0.38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colors.outlineVariant),
                        ),
                      ),
                      onPressed: onPressed,
                      icon: transportGlyph(
                        next: next,
                        color: glyphColor,
                      ),
                    );
                  }

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      transportButton(
                        tooltip: _uiText(
                          sheetContext,
                          'Precedente',
                          'Previous',
                        ),
                        next: false,
                        onPressed: controlsEnabled
                            ? () => unawaited(radio.playPrevious())
                            : null,
                      ),
                      const SizedBox(width: 7),
                      IconButton.filled(
                        tooltip: radio.isPlaying
                            ? _uiText(sheetContext, 'Pausa', 'Pause')
                            : _uiText(sheetContext, 'Riproduci', 'Play'),
                        constraints: const BoxConstraints.tightFor(
                          width: 48,
                          height: 48,
                        ),
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          disabledBackgroundColor:
                              colors.surfaceContainerHighest,
                          disabledForegroundColor:
                              colors.onSurface.withValues(alpha: 0.38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: controlsEnabled
                            ? () => unawaited(
                                  _togglePlayback(sheetContext, radio),
                                )
                            : null,
                        icon: playPauseGlyph(
                          playing: radio.isPlaying,
                          color: controlsEnabled
                              ? colors.onPrimary
                              : colors.onSurface.withValues(alpha: 0.38),
                        ),
                      ),
                      const SizedBox(width: 7),
                      transportButton(
                        tooltip: _uiText(
                          sheetContext,
                          'Successivo',
                          'Next',
                        ),
                        next: true,
                        onPressed: controlsEnabled
                            ? () => unawaited(radio.playNext())
                            : null,
                      ),
                    ],
                  );
                }

                Widget buildTrackIdentity() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        activeStation == null
                            ? _uiText(
                                sheetContext,
                                'Nessun brano',
                                'No track',
                              )
                            : _stationLabel(l10n, activeStation),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (activeStation != null)
                        Text(
                          _channelLabel(activeStation),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  );
                }

                Widget buildVolume({double width = 150}) {
                  return SizedBox(
                    width: width,
                    child: Row(
                      children: [
                        Icon(
                          Icons.volume_down_rounded,
                          size: 20,
                          color: colors.onSurfaceVariant,
                        ),
                        Expanded(
                          child: Slider(
                            value: radio.volume,
                            onChanged: (value) =>
                                unawaited(radio.setVolume(value)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.radioMondoTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: MaterialLocalizations.of(sheetContext)
                                .closeButtonTooltip,
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final item in RadioMondoCategory.values)
                              Tooltip(
                                message:
                                    radio.stationCountForCategory(item) == 0
                                        ? _uiText(
                                            sheetContext,
                                            'Nessun brano',
                                            'No track',
                                          )
                                        : _categoryLabel(sheetContext, item),
                                child: FilterChip(
                                  avatar: Icon(
                                    _categoryIcon(item),
                                    size: 18,
                                  ),
                                  selected: item == category,
                                  showCheckmark: false,
                                  label: Text(
                                    _categoryLabel(sheetContext, item),
                                  ),
                                  onSelected:
                                      radio.stationCountForCategory(item) ==
                                                  0 ||
                                              radio.isLoading
                                          ? null
                                          : (_) => unawaited(
                                                radio.selectCategory(item),
                                              ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 560) {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        buildPlaybackControls(),
                                        const SizedBox(width: 8),
                                        Expanded(child: buildTrackIdentity()),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Spacer(),
                                        buildVolume(
                                          width: constraints.maxWidth * 0.72,
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  buildPlaybackControls(),
                                  const SizedBox(width: 12),
                                  Expanded(child: buildTrackIdentity()),
                                  const SizedBox(width: 12),
                                  buildVolume(),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          _categoryLabel(sheetContext, category),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: stations.isEmpty
                          ? Center(
                              child: Text(
                                _uiText(
                                  sheetContext,
                                  'Nessun brano in questa categoria',
                                  'No tracks in this category',
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              itemCount: stations.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, index) {
                                final station = stations[index];
                                final selectedStation =
                                    station.id == radio.selectedStation?.id;
                                final playingStation = radio.isPlaying &&
                                    radio.currentStation?.id == station.id;

                                return ListTile(
                                  selected: selectedStation,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 2,
                                  ),
                                  leading: Icon(
                                    _stationIcon(station),
                                    color: selectedStation
                                        ? colors.primary
                                        : colors.onSurfaceVariant,
                                  ),
                                  title: Text(
                                    _stationLabel(l10n, station),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    [
                                      if (station.isLive) 'LIVE',
                                      _channelLabel(station),
                                      if (station.languageCode != null)
                                        station.languageCode!.toUpperCase(),
                                      if (station.attribution != null)
                                        station.attribution!,
                                    ].join(' · '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: selectedStation
                                      ? Icon(
                                          playingStation
                                              ? Icons.equalizer_rounded
                                              : Icons.check_circle_rounded,
                                          color: colors.primary,
                                        )
                                      : null,
                                  onTap: () {
                                    onPickerClosed?.call();
                                    Navigator.pop(sheetContext, station);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    onPickerDismissed?.call();
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

  static String _categoryLabel(
    BuildContext context,
    RadioMondoCategory category,
  ) {
    final language = Localizations.localeOf(context).languageCode.toLowerCase();
    final labels = switch (category) {
      RadioMondoCategory.reggae => const <String, String>{
          'default': 'Reggae',
        },
      RadioMondoCategory.classical => const <String, String>{
          'it': 'Classica',
          'de': 'Klassik',
          'fa': 'کلاسیک',
          'es': 'Clásica',
          'pt': 'Clássica',
          'fr': 'Classique',
          'ar': 'كلاسيكية',
          'ro': 'Clasică',
          'ru': 'Классика',
          'zh': '古典音乐',
          'default': 'Classical',
        },
      RadioMondoCategory.house => const <String, String>{
          'default': 'House',
        },
      RadioMondoCategory.jazzSoul => const <String, String>{
          'default': 'Jazz & Soul',
        },
      RadioMondoCategory.worldMusic => const <String, String>{
          'it': 'Musiche del mondo',
          'de': 'Weltmusik',
          'fa': 'موسیقی جهان',
          'es': 'Músicas del mundo',
          'pt': 'Músicas do mundo',
          'fr': 'Musiques du monde',
          'ar': 'موسيقى العالم',
          'ro': 'Muzică din lume',
          'ru': 'Музыка мира',
          'zh': '世界音乐',
          'default': 'World music',
        },
      RadioMondoCategory.soundsAtmospheres => const <String, String>{
          'it': 'Suoni & Atmosfere',
          'de': 'Klänge & Atmosphären',
          'fa': 'صداها و فضاها',
          'es': 'Sonidos y atmósferas',
          'pt': 'Sons e atmosferas',
          'fr': 'Sons & atmosphères',
          'ar': 'أصوات وأجواء',
          'ro': 'Sunete și atmosfere',
          'ru': 'Звуки и атмосферы',
          'zh': '声音与氛围',
          'default': 'Sounds & Atmospheres',
        },
    };
    return labels[language] ?? labels['default']!;
  }

  static String _uiText(
    BuildContext context,
    String it,
    String en,
  ) {
    final language = Localizations.localeOf(context).languageCode.toLowerCase();
    final translations = <String, Map<String, String>>{
      'Precedente': <String, String>{
        'de': 'Zurück',
        'fa': 'قبلی',
        'es': 'Anterior',
        'pt': 'Anterior',
        'fr': 'Précédent',
        'ar': 'السابق',
        'ro': 'Anterior',
        'ru': 'Предыдущий',
        'zh': '上一首',
      },
      'Pausa': <String, String>{
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
      'Riproduci': <String, String>{
        'de': 'Abspielen',
        'fa': 'پخش',
        'es': 'Reproducir',
        'pt': 'Reproduzir',
        'fr': 'Lire',
        'ar': 'تشغيل',
        'ro': 'Redă',
        'ru': 'Воспроизвести',
        'zh': '播放',
      },
      'Successivo': <String, String>{
        'de': 'Weiter',
        'fa': 'بعدی',
        'es': 'Siguiente',
        'pt': 'Seguinte',
        'fr': 'Suivant',
        'ar': 'التالي',
        'ro': 'Următor',
        'ru': 'Следующий',
        'zh': '下一首',
      },
      'Nessun brano': <String, String>{
        'de': 'Kein Titel',
        'fa': 'بدون قطعه',
        'es': 'Sin pista',
        'pt': 'Sem faixa',
        'fr': 'Aucun titre',
        'ar': 'لا توجد مقطوعة',
        'ro': 'Nicio piesă',
        'ru': 'Нет трека',
        'zh': '暂无曲目',
      },
      'Nessun brano in questa categoria': <String, String>{
        'de': 'Keine Titel in dieser Kategorie',
        'fa': 'در این دسته قطعه‌ای وجود ندارد',
        'es': 'No hay pistas en esta categoría',
        'pt': 'Não há faixas nesta categoria',
        'fr': 'Aucun titre dans cette catégorie',
        'ar': 'لا توجد مقطوعات في هذه الفئة',
        'ro': 'Nicio piesă în această categorie',
        'ru': 'В этой категории нет треков',
        'zh': '此分类暂无曲目',
      },
      'Radio in pausa': <String, String>{
        'de': 'Radio pausiert',
        'fa': 'رادیو مکث شد',
        'es': 'Radio en pausa',
        'pt': 'Rádio em pausa',
        'fr': 'Radio en pause',
        'ar': 'الراديو متوقف مؤقتًا',
        'ro': 'Radio în pauză',
        'ru': 'Радио на паузе',
        'zh': '电台已暂停',
      },
    };
    if (language == 'it') return it;
    return translations[it]?[language] ?? en;
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

  static IconData _categoryIcon(RadioMondoCategory category) {
    return switch (category) {
      RadioMondoCategory.reggae => Icons.waves_rounded,
      RadioMondoCategory.classical => Icons.piano_rounded,
      RadioMondoCategory.house => Icons.graphic_eq_rounded,
      RadioMondoCategory.jazzSoul => Icons.music_note_rounded,
      RadioMondoCategory.worldMusic => Icons.public_rounded,
      RadioMondoCategory.soundsAtmospheres => Icons.spa_outlined,
    };
  }

  static IconData _stationIcon(RadioMondoStation station) {
    if (station.isLive || station.sourceType == RadioMondoSourceType.stream) {
      return Icons.cell_tower_rounded;
    }
    return switch (station.category) {
      RadioMondoCategory.reggae => Icons.waves_rounded,
      RadioMondoCategory.classical => Icons.piano_rounded,
      RadioMondoCategory.house => Icons.graphic_eq_rounded,
      RadioMondoCategory.jazzSoul => Icons.music_note_rounded,
      RadioMondoCategory.worldMusic => Icons.public_rounded,
      RadioMondoCategory.soundsAtmospheres => Icons.spa_outlined,
    };
  }
}
