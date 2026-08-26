import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sociale_vote/shared/services/world_appearance_service.dart';
import 'package:sociale_vote/shared/widgets/world_control_visuals.dart';

class WorldAppearanceSettingsPage extends StatefulWidget {
  const WorldAppearanceSettingsPage({super.key});

  @override
  State<WorldAppearanceSettingsPage> createState() =>
      _WorldAppearanceSettingsPageState();
}

class _WorldAppearanceSettingsPageState
    extends State<WorldAppearanceSettingsPage> {
  final WorldAppearanceService _appearance = WorldAppearanceService.instance;

  @override
  void initState() {
    super.initState();
    unawaited(_appearance.ensureLoaded());
  }

  @override
  Widget build(BuildContext context) {
    final copy = _WorldAppearanceCopy.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(copy.title),
        actions: [
          TextButton.icon(
            onPressed: () => _appearance.reset(),
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(copy.reset),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: _appearance,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        copy.subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _LiveWorldPreview(
                        globeStyle: _appearance.globeStyle,
                        radioStyle: _appearance.radioStyle,
                        rotationStyle: _appearance.rotationStyle,
                      ),
                      const SizedBox(height: 30),
                      _AppearanceSection(
                        title: copy.globeTitle,
                        subtitle: copy.globeSubtitle,
                        minCardWidth: 285,
                        maxColumns: 3,
                        children: [
                          for (final style in GlobeVisualStyle.values)
                            _AppearanceChoice(
                              selected: _appearance.globeStyle == style,
                              label: copy.globeLabel(style),
                              previewHeight: 182,
                              preview: PremiumGlobePreview(
                                style: style,
                                size: 156,
                              ),
                              onTap: () => _appearance.setGlobeStyle(style),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _AppearanceSection(
                        title: copy.radioTitle,
                        subtitle: copy.radioSubtitle,
                        minCardWidth: 220,
                        maxColumns: 4,
                        children: [
                          for (final style in RadioVisualStyle.values)
                            _AppearanceChoice(
                              selected: _appearance.radioStyle == style,
                              label: copy.radioLabel(style),
                              previewHeight: 92,
                              preview: PremiumRadioControlVisual(
                                style: style,
                                size: 64,
                              ),
                              onTap: () => _appearance.setRadioStyle(style),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _AppearanceSection(
                        title: copy.rotationTitle,
                        subtitle: copy.rotationSubtitle,
                        minCardWidth: 180,
                        maxColumns: 4,
                        children: [
                          for (final style in GlobeRotationVisualStyle.values)
                            _AppearanceChoice(
                              selected: _appearance.rotationStyle == style,
                              label: copy.rotationLabel(style),
                              previewHeight: 92,
                              preview: PremiumRotationPreview(
                                style: style,
                                size: 62,
                              ),
                              onTap: () => _appearance.setRotationStyle(style),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _LocalPreferenceNotice(text: copy.localOnly),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LiveWorldPreview extends StatelessWidget {
  final GlobeVisualStyle globeStyle;
  final RadioVisualStyle radioStyle;
  final GlobeRotationVisualStyle rotationStyle;

  const _LiveWorldPreview({
    required this.globeStyle,
    required this.radioStyle,
    required this.rotationStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final globeSize = compact ? 220.0 : 270.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 18 : 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF0E1622), Color(0xFF101B2A)]
                  : const [Color(0xFFF7FAFF), Color(0xFFEDF3FB)],
            ),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.70),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    switch (Localizations.localeOf(context).languageCode) {
                      'it' => 'Anteprima in tempo reale',
                      'de' => 'Live-Vorschau',
                      'fa' => 'پیش‌نمایش زنده',
                      _ => 'Live preview',
                    },
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                switch (Localizations.localeOf(context).languageCode) {
                  'it' =>
                    'Quello che scegli qui è lo stesso linguaggio visivo usato accanto al Globe.',
                  'de' =>
                    'Die Auswahl hier entspricht der Darstellung direkt am Globe.',
                  'fa' =>
                    'انتخاب‌های این بخش همان ظاهر استفاده‌شده کنار Globe هستند.',
                  _ =>
                    'Your choices here use the same visual language shown beside the Globe.',
                },
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: SizedBox(
                  width: compact ? 330 : 430,
                  height: compact ? 260 : 310,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      PremiumGlobePreview(style: globeStyle, size: globeSize),
                      Positioned(
                        left: compact ? 5 : 12,
                        bottom: compact ? 16 : 22,
                        child: PremiumRadioControlVisual(
                          style: radioStyle,
                          size: compact ? 56 : 64,
                        ),
                      ),
                      Positioned(
                        right: compact ? 5 : 12,
                        bottom: compact ? 16 : 22,
                        child: PremiumRotationPreview(
                          style: rotationStyle,
                          size: compact ? 56 : 64,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final double minCardWidth;
  final int maxColumns;
  final List<Widget> children;

  const _AppearanceSection({
    required this.title,
    required this.subtitle,
    required this.minCardWidth,
    required this.maxColumns,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 14.0;
            final naturalColumns = (constraints.maxWidth / minCardWidth)
                .floor()
                .clamp(1, maxColumns)
                .toInt();
            final columns = naturalColumns;
            final width =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final child in children)
                  SizedBox(width: width, child: child),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AppearanceChoice extends StatelessWidget {
  final bool selected;
  final String label;
  final double previewHeight;
  final Widget preview;
  final VoidCallback onTap;

  const _AppearanceChoice({
    required this.selected,
    required this.label,
    required this.previewHeight,
    required this.preview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: selected
                  ? colors.primaryContainer.withValues(alpha: 0.15)
                  : colors.surfaceContainerLow,
              border: Border.all(
                width: selected ? 1.8 : 1,
                color: selected
                    ? colors.primary.withValues(alpha: 0.90)
                    : colors.outlineVariant.withValues(alpha: 0.72),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : const [],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: previewHeight,
                      child: Center(child: preview),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                if (selected)
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    child: Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.24),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 17,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocalPreferenceNotice extends StatelessWidget {
  final String text;
  const _LocalPreferenceNotice({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 11),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _WorldAppearanceCopy {
  final String languageCode;

  const _WorldAppearanceCopy(this.languageCode);

  factory _WorldAppearanceCopy.of(BuildContext context) {
    return _WorldAppearanceCopy(Localizations.localeOf(context).languageCode);
  }

  bool get _it => languageCode == 'it';
  bool get _de => languageCode == 'de';
  bool get _fa => languageCode == 'fa';

  String get title => _fa
      ? 'ظاهر جهان'
      : _de
          ? 'Welt-Darstellung'
          : _it
              ? 'Aspetto del mondo'
              : 'World appearance';

  String get subtitle => _fa
      ? 'ظاهر Globe، Radio Mondo و کنترل چرخش را جداگانه انتخاب کنید.'
      : _de
          ? 'Wähle Globe, Radio Mondo und Rotationssteuerung unabhängig voneinander.'
          : _it
              ? 'Scegli separatamente Globe, Radio Mondo e controllo rotazione.'
              : 'Choose Globe, Radio Mondo and rotation control independently.';

  String get globeTitle => _fa
      ? 'سبک Globe'
      : _de
          ? 'Globe-Stil'
          : _it
              ? 'Stile Globe'
              : 'Globe style';

  String get globeSubtitle => _fa
      ? 'ظاهر زمین را انتخاب کنید. داده‌ها و نشانگرها تغییر نمی‌کنند.'
      : _de
          ? 'Ändert nur die Darstellung. Daten und Marker bleiben unverändert.'
          : _it
              ? 'Cambia solo l’aspetto. Dati e marker restano invariati.'
              : 'Changes appearance only. Data and markers stay unchanged.';

  String get radioTitle => 'Radio Mondo';

  String get radioSubtitle => _fa
      ? 'سبک دکمه Radio Mondo کنار Globe را انتخاب کنید.'
      : _de
          ? 'Wähle den Stil der Radio-Mondo-Taste neben dem Globe.'
          : _it
              ? 'Scegli lo stile del pulsante Radio Mondo vicino al Globe.'
              : 'Choose the Radio Mondo button style beside the Globe.';

  String get rotationTitle => _fa
      ? 'کنترل چرخش'
      : _de
          ? 'Rotationssteuerung'
          : _it
              ? 'Controllo rotazione'
              : 'Rotation control';

  String get rotationSubtitle => _fa
      ? 'ظاهر دکمه شروع و توقف چرخش Globe را انتخاب کنید.'
      : _de
          ? 'Wähle den Stil der Start/Stopp-Rotationstaste.'
          : _it
              ? 'Scegli lo stile del pulsante che avvia o ferma il Globe.'
              : 'Choose the style of the Globe start/stop rotation button.';

  String get reset => _fa
      ? 'بازنشانی'
      : _de
          ? 'Zurücksetzen'
          : _it
              ? 'Ripristina'
              : 'Reset';

  String get localOnly => _fa
      ? 'این انتخاب‌ها فقط روی این دستگاه ذخیره می‌شوند و GeoScope، محتوا یا نشانگرهای زنده را تغییر نمی‌دهند.'
      : _de
          ? 'Diese Einstellungen bleiben lokal auf diesem Gerät und verändern weder GeoScope noch Inhalte oder Live-Marker.'
          : _it
              ? 'Queste preferenze restano locali sul dispositivo e non modificano GeoScope, contenuti o marker live.'
              : 'These preferences stay local on this device and never change GeoScope, content or live markers.';

  String globeLabel(GlobeVisualStyle style) {
    return switch (style) {
      GlobeVisualStyle.classic => _localized(
          it: 'A · Classico e pulito',
          en: 'A · Classic clean',
          de: 'A · Klassisch klar',
          fa: 'A · کلاسیک و تمیز',
        ),
      GlobeVisualStyle.realistic => _localized(
          it: 'B · Realistico e profondo',
          en: 'B · Realistic deep',
          de: 'B · Realistisch tief',
          fa: 'B · واقع‌گرای عمیق',
        ),
      GlobeVisualStyle.bright => _localized(
          it: 'C · Moderno e luminoso',
          en: 'C · Modern bright',
          de: 'C · Modern hell',
          fa: 'C · مدرن و روشن',
        ),
      GlobeVisualStyle.nightLights => _localized(
          it: 'D · Night Lights',
          en: 'D · Night Lights',
          de: 'D · Nachtlichter',
          fa: 'D · چراغ‌های شب',
        ),
      GlobeVisualStyle.techNeon => _localized(
          it: 'E · Tech & Neon',
          en: 'E · Tech & Neon',
          de: 'E · Tech & Neon',
          fa: 'E · فناوری و نئون',
        ),
      GlobeVisualStyle.minimalDay => _localized(
          it: 'F · Minimal Day',
          en: 'F · Minimal Day',
          de: 'F · Minimaler Tag',
          fa: 'F · روز مینیمال',
        ),
    };
  }

  String radioLabel(RadioVisualStyle style) {
    return switch (style) {
      RadioVisualStyle.vintageClassic => _localized(
          it: '1 · Nota',
          en: '1 · Note',
          de: '1 · Note',
          fa: '1 · نت موسیقی',
        ),
      RadioVisualStyle.oldStyle => _localized(
          it: '2 · Radio',
          en: '2 · Radio',
          de: '2 · Radio',
          fa: '2 · رادیو',
        ),
      RadioVisualStyle.retroElegant => _localized(
          it: '3 · Equalizer',
          en: '3 · Equalizer',
          de: '3 · Equalizer',
          fa: '3 · اکولایزر',
        ),
      RadioVisualStyle.woodMinimal => _localized(
          it: '4 · Onda',
          en: '4 · Wave',
          de: '4 · Welle',
          fa: '4 · موج',
        ),
      RadioVisualStyle.modernVintage => _localized(
          it: '5 · Cuffie',
          en: '5 · Headphones',
          de: '5 · Kopfhörer',
          fa: '5 · هدفون',
        ),
      RadioVisualStyle.steampunk => _localized(
          it: '6 · Disco',
          en: '6 · Disc',
          de: '6 · Platte',
          fa: '6 · دیسک',
        ),
      RadioVisualStyle.minimalChic => _localized(
          it: '7 · Pulse',
          en: '7 · Pulse',
          de: '7 · Pulse',
          fa: '7 · پالس',
        ),
    };
  }

  String rotationLabel(GlobeRotationVisualStyle style) {
    return switch (style) {
      GlobeRotationVisualStyle.classic => _localized(
          it: '1 · Classico',
          en: '1 · Classic',
          de: '1 · Klassisch',
          fa: '1 · کلاسیک',
        ),
      GlobeRotationVisualStyle.minimal => _localized(
          it: '2 · Minimal',
          en: '2 · Minimal',
          de: '2 · Minimal',
          fa: '2 · مینیمال',
        ),
      GlobeRotationVisualStyle.subtle => _localized(
          it: '3 · Sottile',
          en: '3 · Subtle',
          de: '3 · Dezent',
          fa: '3 · ظریف',
        ),
      GlobeRotationVisualStyle.neon => _localized(
          it: '4 · Neon',
          en: '4 · Neon',
          de: '4 · Neon',
          fa: '4 · نئون',
        ),
      GlobeRotationVisualStyle.filled => _localized(
          it: '5 · Pieno',
          en: '5 · Filled',
          de: '5 · Gefüllt',
          fa: '5 · پر',
        ),
      GlobeRotationVisualStyle.glass => _localized(
          it: '6 · Glass',
          en: '6 · Glass',
          de: '6 · Glas',
          fa: '6 · شیشه‌ای',
        ),
      GlobeRotationVisualStyle.premium => _localized(
          it: '7 · Premium',
          en: '7 · Premium',
          de: '7 · Premium',
          fa: '7 · پریمیوم',
        ),
    };
  }

  String _localized({
    required String it,
    required String en,
    required String de,
    required String fa,
  }) {
    if (_fa) return fa;
    if (_de) return de;
    if (_it) return it;
    return en;
  }
}
