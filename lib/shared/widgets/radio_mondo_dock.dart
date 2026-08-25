import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/radio_mondo_service.dart';
import 'package:sociale_vote/shared/services/social_vote_hud_service.dart';

class RadioMondoDock extends StatelessWidget {
  const RadioMondoDock({super.key});

  @override
  Widget build(BuildContext context) {
    final radio = RadioMondoService.instance;

    return AnimatedBuilder(
      animation: radio,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final active = radio.isPlaying;
        final showLabel = MediaQuery.sizeOf(context).width >= 720;

        return SafeArea(
          minimum: const EdgeInsets.all(12),
          child: Align(
            // Radio Mondo is a persistent utility, not reading-order content:
            // keep it in the same physical corner when locale switches RTL/LTR.
            alignment: Alignment.bottomLeft,
            child: Semantics(
              button: true,
              label: active
                  ? '${l10n.radioMondoTitle}. ${l10n.radioMondoPlaying}'
                  : l10n.radioMondoTitle,
              child: Tooltip(
                message: l10n.radioMondoTitle,
                child: Material(
                  elevation: active ? 8 : 4,
                  shadowColor: Colors.black.withValues(alpha: 0.24),
                  color: active
                      ? const Color(0xFF132940)
                      : theme.colorScheme.surface.withValues(
                          alpha: isDark ? 0.94 : 0.98,
                        ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: active
                          ? const Color(0xFF5BA9F8)
                          : theme.dividerColor.withValues(alpha: 0.58),
                    ),
                  ),
                  child: InkWell(
                    key: const ValueKey<String>('radio-mondo-open'),
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _openRadio(context),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 48,
                      constraints: BoxConstraints(
                        minWidth: 48,
                        maxWidth: showLabel ? 190 : 48,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: showLabel ? 14 : 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 26,
                            height: 28,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.graphic_eq_rounded,
                                  size: 24,
                                  color: active
                                      ? const Color(0xFF8FC8FF)
                                      : theme.colorScheme.onSurface.withValues(
                                          alpha: 0.84,
                                        ),
                                ),
                                if (active)
                                  Positioned(
                                    right: 0,
                                    top: 1,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF42D392),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                if (radio.isLoading)
                                  const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (showLabel) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                l10n.radioMondoTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: active
                                      ? const Color(0xFFE8F4FF)
                                      : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openRadio(BuildContext context) async {
    final radio = RadioMondoService.instance;
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return AnimatedBuilder(
          animation: radio,
          builder: (context, _) {
            return SafeArea(
              minimum: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.radio_rounded, size: 26),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.radioMondoTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (radio.isPlaying)
                          TextButton.icon(
                            key: const ValueKey<String>('radio-mondo-stop'),
                            onPressed: radio.isLoading
                                ? null
                                : () async {
                                    await radio.stop();
                                    if (sheetContext.mounted) {
                                      SocialVoteHud.showInfo(
                                        l10n.radioMondoStopped,
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.stop_rounded),
                            label: Text(l10n.radioMondoStopAction),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.radioMondoDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    for (final track in RadioMondoTrack.values)
                      _RadioTrackTile(
                        track: track,
                        selected:
                            radio.isPlaying && radio.currentTrack == track,
                        enabled: !radio.isLoading,
                        onTap: () async {
                          final success = await radio.play(track);
                          if (!sheetContext.mounted) return;
                          if (success) {
                            SocialVoteHud.showInfo(
                              l10n.radioMondoPlaying,
                              detail: _trackLabel(l10n, track),
                            );
                          } else {
                            SocialVoteHud.showError(
                              l10n.radioMondoPlaybackError,
                            );
                          }
                        },
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.volume_down_rounded),
                        Expanded(
                          child: Slider(
                            value: radio.volume,
                            min: 0,
                            max: 0.75,
                            divisions: 15,
                            label: '${(radio.volume * 100).round()}%',
                            onChanged: radio.isLoading
                                ? null
                                : (value) {
                                    unawaited(radio.setVolume(value));
                                  },
                          ),
                        ),
                        const Icon(Icons.volume_up_rounded),
                      ],
                    ),
                    Text(
                      l10n.radioMondoForegroundOnly,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.62),
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static String _trackLabel(
    AppLocalizations l10n,
    RadioMondoTrack track,
  ) {
    return switch (track) {
      RadioMondoTrack.classicalOrbit => l10n.radioMondoTrackClassical,
      RadioMondoTrack.worldRain => l10n.radioMondoTrackRain,
      RadioMondoTrack.youngPulse => l10n.radioMondoTrackYoung,
    };
  }
}

class _RadioTrackTile extends StatelessWidget {
  final RadioMondoTrack track;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _RadioTrackTile({
    required this.track,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = RadioMondoDock._trackLabel(l10n, track);
    final icon = switch (track) {
      RadioMondoTrack.classicalOrbit => Icons.piano_rounded,
      RadioMondoTrack.worldRain => Icons.water_drop_outlined,
      RadioMondoTrack.youngPulse => Icons.graphic_eq_rounded,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: selected
          ? Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.55)
          : null,
      child: ListTile(
        key: ValueKey<String>('radio-track-${track.name}'),
        enabled: enabled,
        selected: selected,
        onTap: onTap,
        leading: Icon(icon),
        title: Text(label),
        trailing: selected
            ? const Icon(Icons.equalizer_rounded)
            : const Icon(Icons.play_arrow_rounded),
      ),
    );
  }
}
