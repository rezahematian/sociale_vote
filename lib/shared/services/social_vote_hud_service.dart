import 'dart:async';

import 'package:flutter/material.dart';

enum SocialVoteHudTone { success, info, warning, error }

@immutable
class SocialVoteHudMessage {
  final int id;
  final String title;
  final String? detail;
  final SocialVoteHudTone tone;
  final Duration duration;

  const SocialVoteHudMessage({
    required this.id,
    required this.title,
    required this.detail,
    required this.tone,
    required this.duration,
  });
}

/// Punto unico per i nuovi feedback non bloccanti dell'app.
///
/// Le vecchie SnackBar restano compatibili e possono essere migrate per
/// feature senza un refactor massivo. Nuovi flussi devono usare questo HUD.
abstract final class SocialVoteHud {
  static final ValueNotifier<SocialVoteHudMessage?> message =
      ValueNotifier<SocialVoteHudMessage?>(null);

  static Timer? _dismissTimer;
  static int _messageId = 0;

  static void showSuccess(String title, {String? detail}) {
    show(
      title,
      detail: detail,
      tone: SocialVoteHudTone.success,
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfo(String title, {String? detail}) {
    show(
      title,
      detail: detail,
      tone: SocialVoteHudTone.info,
      duration: const Duration(seconds: 3),
    );
  }

  static void showWarning(String title, {String? detail}) {
    show(
      title,
      detail: detail,
      tone: SocialVoteHudTone.warning,
      duration: const Duration(seconds: 4),
    );
  }

  static void showError(String title, {String? detail}) {
    show(
      title,
      detail: detail,
      tone: SocialVoteHudTone.error,
      duration: const Duration(seconds: 6),
    );
  }

  static void show(
    String title, {
    String? detail,
    SocialVoteHudTone tone = SocialVoteHudTone.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) return;

    final normalizedDetail = detail?.trim();
    _dismissTimer?.cancel();
    final id = ++_messageId;
    message.value = SocialVoteHudMessage(
      id: id,
      title: normalizedTitle,
      detail: normalizedDetail == null || normalizedDetail.isEmpty
          ? null
          : normalizedDetail,
      tone: tone,
      duration: duration,
    );
    _dismissTimer = Timer(duration, () {
      if (message.value?.id == id) {
        message.value = null;
      }
    });
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    message.value = null;
  }
}

class SocialVoteHudOverlay extends StatelessWidget {
  const SocialVoteHudOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SocialVoteHudMessage?>(
      valueListenable: SocialVoteHud.message,
      builder: (context, message, _) {
        return IgnorePointer(
          ignoring: message == null,
          child: SafeArea(
            minimum: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Align(
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                reverseDuration: const Duration(milliseconds: 140),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(
                    begin: const Offset(0, -0.18),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: message == null
                    ? const SizedBox.shrink(key: ValueKey<String>('hud-empty'))
                    : _SocialVoteHudCard(
                        key: ValueKey<int>(message.id),
                        message: message,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SocialVoteHudCard extends StatelessWidget {
  final SocialVoteHudMessage message;

  const _SocialVoteHudCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _palette(theme, message.tone);

    return Semantics(
      liveRegion: true,
      container: true,
      label: message.detail == null
          ? message.title
          : '${message.title}. ${message.detail}',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Material(
          elevation: 10,
          shadowColor: Colors.black.withValues(alpha: 0.28),
          color: palette.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: palette.border),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 11, 8, 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: palette.accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    palette.icon,
                    size: 19,
                    color: palette.accent,
                  ),
                ),
                const SizedBox(width: 11),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: palette.foreground,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (message.detail != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          message.detail!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.foreground.withValues(alpha: 0.76),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: SocialVoteHud.dismiss,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: palette.foreground.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _HudPalette _palette(ThemeData theme, SocialVoteHudTone tone) {
    final isDark = theme.brightness == Brightness.dark;
    final accent = switch (tone) {
      SocialVoteHudTone.success => const Color(0xFF18A66B),
      SocialVoteHudTone.info => const Color(0xFF2F80ED),
      SocialVoteHudTone.warning => const Color(0xFFE39A26),
      SocialVoteHudTone.error => const Color(0xFFE45151),
    };
    final icon = switch (tone) {
      SocialVoteHudTone.success => Icons.check_rounded,
      SocialVoteHudTone.info => Icons.info_outline_rounded,
      SocialVoteHudTone.warning => Icons.warning_amber_rounded,
      SocialVoteHudTone.error => Icons.error_outline_rounded,
    };

    return _HudPalette(
      accent: accent,
      icon: icon,
      background: isDark ? const Color(0xFF121C2A) : const Color(0xFFF9FBFE),
      foreground: isDark ? const Color(0xFFF4F7FB) : const Color(0xFF172033),
      border: accent.withValues(alpha: isDark ? 0.48 : 0.28),
    );
  }
}

class _HudPalette {
  final Color accent;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color border;

  const _HudPalette({
    required this.accent,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.border,
  });
}
