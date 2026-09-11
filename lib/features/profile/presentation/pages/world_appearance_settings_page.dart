import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sociale_vote/shared/services/world_appearance_service.dart';
import 'package:sociale_vote/shared/widgets/content_directionality.dart';
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
        title: Text(
          copy.title,
          textDirection: socialVoteLocaleTextDirection(context),
          textAlign: socialVoteLocaleTextAlign(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _appearance.reset(),
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(
              copy.reset,
              textDirection: socialVoteLocaleTextDirection(context),
              textAlign: socialVoteLocaleTextAlign(context),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: _appearance,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        copy.subtitle,
                        textDirection: socialVoteLocaleTextDirection(context),
                        textAlign: socialVoteLocaleTextAlign(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _LiveWorldPreview(
                        globeStyle: _appearance.globeStyle,
                        radioStyle: _appearance.radioStyle,
                        rotationStyle: _appearance.rotationStyle,
                        globeLabel: copy.globeLabel(_appearance.globeStyle),
                        radioLabel: copy.radioLabel(_appearance.radioStyle),
                        rotationLabel:
                            copy.rotationLabel(_appearance.rotationStyle),
                      ),
                      const SizedBox(height: 18),
                      _AppearanceSection(
                        title: copy.globeTitle,
                        subtitle: copy.globeSubtitle,
                        minCardWidth: 168,
                        maxColumns: 3,
                        children: [
                          for (final style
                              in WorldAppearanceService.selectableGlobeStyles)
                            _AppearanceChoice(
                              selected: _appearance.globeStyle == style,
                              label: copy.globeLabel(style),
                              previewHeight: 96,
                              preview: PremiumGlobePreview(
                                style: style,
                                size: 82,
                              ),
                              onTap: () => _appearance.setGlobeStyle(style),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _AppearanceSection(
                        title: copy.radioTitle,
                        subtitle: copy.radioSubtitle,
                        minCardWidth: 175,
                        maxColumns: 4,
                        children: [
                          for (final style
                              in WorldAppearanceService.selectableRadioStyles)
                            _AppearanceChoice(
                              selected: _appearance.radioStyle == style,
                              label: copy.radioLabel(style),
                              previewHeight: 56,
                              preview: PremiumRadioControlVisual(
                                style: style,
                                size: 44,
                              ),
                              onTap: () => _appearance.setRadioStyle(style),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _AppearanceSection(
                        title: copy.rotationTitle,
                        subtitle: copy.rotationSubtitle,
                        minCardWidth: 175,
                        maxColumns: 4,
                        children: [
                          for (final style in WorldAppearanceService
                              .selectableRotationStyles)
                            _AppearanceChoice(
                              selected: _appearance.rotationStyle == style,
                              label: copy.rotationLabel(style),
                              previewHeight: 56,
                              preview: PremiumRotationPreview(
                                style: style,
                                size: 44,
                              ),
                              onTap: () => _appearance.setRotationStyle(style),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
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
  final String globeLabel;
  final String radioLabel;
  final String rotationLabel;

  const _LiveWorldPreview({
    required this.globeStyle,
    required this.radioStyle,
    required this.rotationStyle,
    required this.globeLabel,
    required this.radioLabel,
    required this.rotationLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final languageCode = Localizations.localeOf(context).languageCode;

    final title = switch (languageCode) {
      'it' => 'Anteprima live',
      'de' => 'Live-Vorschau',
      'fa' => 'پیش‌نمایش زنده',
      'es' => 'Vista previa',
      'pt' => 'Prévia ao vivo',
      'fr' => 'Aperçu en direct',
      'ar' => 'معاينة مباشرة',
      'ro' => 'Previzualizare live',
      'ru' => 'Предпросмотр',
      'zh' => '实时预览',
      _ => 'Live preview',
    };
    final subtitle = switch (languageCode) {
      'it' => 'Le tre scelte qui sotto cambiano solo l’aspetto della vista del mondo.',
      'de' => 'Die drei Optionen ändern nur die Darstellung der Weltansicht.',
      'fa' => 'این سه انتخاب فقط ظاهر نمای جهان را تغییر می‌دهند.',
      'es' => 'Las tres opciones solo cambian la apariencia de la vista del mundo.',
      'pt' => 'As três opções alteram apenas a aparência da vista do mundo.',
      'fr' =>
        'Les trois choix ci-dessous modifient uniquement l’apparence de la vue du monde.',
      'ar' => 'تغيّر الخيارات الثلاثة أدناه مظهر عرض العالم فقط.',
      'ro' => 'Cele trei opțiuni de mai jos modifică doar aspectul vizualizării lumii.',
      'ru' => 'Три варианта ниже меняют только внешний вид представления мира.',
      'zh' => '下面三个选项只会改变世界视图的外观。',
      _ => 'The three choices below change only the World appearance.',
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final globeSize = compact ? 140.0 : 164.0;
        final controlSize = compact ? 40.0 : 44.0;

        final info = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 19,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  textDirection: socialVoteLocaleTextDirection(context),
                  textAlign: socialVoteLocaleTextAlign(context),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textDirection: socialVoteLocaleTextDirection(context),
              textAlign: socialVoteLocaleTextAlign(context),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SelectionPill(
                  icon: Icons.public_rounded,
                  label: globeLabel,
                ),
                _SelectionPill(
                  icon: Icons.radio_rounded,
                  label: radioLabel,
                ),
                _SelectionPill(
                  icon: Icons.rotate_right_rounded,
                  label: rotationLabel,
                ),
              ],
            ),
          ],
        );

        final visual = SizedBox(
          width: compact ? 232 : 272,
          height: compact ? 156 : 182,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              PremiumGlobePreview(style: globeStyle, size: globeSize),
              Positioned(
                left: 8,
                bottom: 12,
                child: PremiumRadioControlVisual(
                  style: radioStyle,
                  size: controlSize,
                ),
              ),
              Positioned(
                right: 8,
                bottom: 12,
                child: PremiumRotationPreview(
                  style: rotationStyle,
                  size: controlSize,
                ),
              ),
            ],
          ),
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 20,
            vertical: compact ? 14 : 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF0E1622), Color(0xFF101B2A)]
                  : const [Color(0xFFF8FAFE), Color(0xFFF0F4FA)],
            ),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.70),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.055),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    info,
                    const SizedBox(height: 8),
                    Center(child: visual),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 18),
                    visual,
                  ],
                ),
        );
      },
    );
  }
}

class _SelectionPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SelectionPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.surface.withValues(alpha: 0.82),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.70),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              textDirection: socialVoteContentDirection(label),
              textAlign: socialVoteContentTextAlign(label),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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
          textDirection: socialVoteLocaleTextDirection(context),
          textAlign: socialVoteLocaleTextAlign(context),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          textDirection: socialVoteLocaleTextDirection(context),
          textAlign: socialVoteLocaleTextAlign(context),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 8.0;
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
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
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
                        blurRadius: 12,
                        offset: const Offset(0, 4),
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
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        label,
                        textDirection: socialVoteContentDirection(label),
                        textAlign: socialVoteContentTextAlign(label),
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
                      width: 24,
                      height: 24,
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
                        size: 15,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              textDirection: socialVoteLocaleTextDirection(context),
              textAlign: socialVoteLocaleTextAlign(context),
              style: theme.textTheme.bodySmall,
            ),
          ),
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

  String _localized({
    required String it,
    required String en,
    required String de,
    required String fa,
    required String es,
    required String pt,
    String? fr,
    String? ar,
    String? ro,
    String? ru,
    String? zh,
  }) {
    return switch (languageCode) {
      'it' => it,
      'de' => de,
      'fa' => fa,
      'es' => es,
      'pt' => pt,
      'fr' => fr ?? en,
      'ar' => ar ?? en,
      'ro' => ro ?? en,
      'ru' => ru ?? en,
      'zh' => zh ?? en,
      _ => en,
    };
  }

  String get title => _localized(
        it: 'Aspetto del mondo',
        en: 'World appearance',
        de: 'Welt-Darstellung',
        fa: 'ظاهر جهان',
        es: 'Apariencia del mundo',
        pt: 'Aparência do mundo',
        fr: 'Apparence du monde',
        ar: 'مظهر العالم',
        ro: 'Aspectul lumii',
              ru: 'Внешний вид мира',
        zh: '世界外观',
);

  String get subtitle => _localized(
        it: 'Scegli separatamente globo, radio del mondo e controllo rotazione.',
        en: 'Choose globe, world radio and rotation control independently.',
        de: 'Wähle Globus, Weltradio und Rotationssteuerung unabhängig voneinander.',
        fa: 'کره زمین، رادیوی جهان و کنترل چرخش را جداگانه انتخاب کنید.',
        es: 'Elige por separado globo, radio mundial y control de rotación.',
        pt: 'Escolha separadamente globo, rádio mundial e controle de rotação.',
        fr: 'Choisissez séparément le globe, la radio mondiale et le contrôle de rotation.',
        ar: 'اختر الكرة الأرضية وراديو العالم والتحكم في الدوران بشكل مستقل.',
        ro: 'Alege separat globul, radioul mondial și controlul rotației.',
        ru: 'Выбирайте глобус, мировое радио и управление вращением независимо.',
        zh: '可分别选择地球仪、世界电台和旋转控制。',
      );

  String get globeTitle => _localized(
        it: 'Stile del globo',
        en: 'Globe style',
        de: 'Globus-Stil',
        fa: 'سبک کره زمین',
        es: 'Estilo del globo',
        pt: 'Estilo do globo',
        fr: 'Style du globe',
        ar: 'نمط الكرة الأرضية',
        ro: 'Stilul globului',
        ru: 'Стиль глобуса',
        zh: '地球仪风格',
      );

  String get globeSubtitle => _localized(
        it: 'Cambia solo l’aspetto. Dati e marker restano invariati.',
        en: 'Changes appearance only. Data and markers stay unchanged.',
        de: 'Ändert nur die Darstellung. Daten und Marker bleiben unverändert.',
        fa: 'فقط ظاهر را تغییر می‌دهد. داده‌ها و نشانگرها بدون تغییر می‌مانند.',
        es: 'Solo cambia la apariencia. Los datos y marcadores no cambian.',
        pt: 'Altera apenas a aparência. Dados e marcadores permanecem iguais.',
        fr: 'Modifie uniquement l’apparence. Les données et les marqueurs restent inchangés.',
        ar: 'يغيّر المظهر فقط. تبقى البيانات والعلامات دون تغيير.',
        ro: 'Modifică doar aspectul. Datele și marcajele rămân neschimbate.',
        ru: 'Меняет только внешний вид. Данные и маркеры не изменяются.',
        zh: '仅改变外观。数据和标记保持不变。',
      );

  String get radioTitle => _localized(
        it: 'Radio del mondo',
        en: 'World radio',
        de: 'Weltradio',
        fa: 'رادیوی جهان',
        es: 'Radio mundial',
        pt: 'Rádio mundial',
        fr: 'Radio mondiale',
        ar: 'راديو العالم',
        ro: 'Radio mondial',
        ru: 'Мировое радио',
        zh: '世界电台',
      );

  String get radioSubtitle => _localized(
        it: 'Scegli lo stile del pulsante della radio del mondo vicino al globo.',
        en: 'Choose the world radio button style beside the globe.',
        de: 'Wähle den Stil der Weltradio-Taste neben dem Globus.',
        fa: 'سبک دکمه رادیوی جهان کنار کره زمین را انتخاب کنید.',
        es: 'Elige el estilo del botón de radio mundial junto al globo.',
        pt: 'Escolha o estilo do botão de rádio mundial junto ao globo.',
        fr: 'Choisissez le style du bouton de radio mondiale à côté du globe.',
        ar: 'اختر نمط زر راديو العالم بجوار الكرة الأرضية.',
        ro: 'Alege stilul butonului pentru radioul mondial de lângă glob.',
        ru: 'Выберите стиль кнопки мирового радио рядом с глобусом.',
        zh: '选择地球仪旁边的世界电台按钮样式。',
      );

  String get rotationTitle => _localized(
        it: 'Controllo rotazione',
        en: 'Rotation control',
        de: 'Rotationssteuerung',
        fa: 'کنترل چرخش',
        es: 'Control de rotación',
        pt: 'Controle de rotação',
        fr: 'Contrôle de rotation',
        ar: 'التحكم في الدوران',
        ro: 'Controlul rotației',
        ru: 'Управление вращением',
        zh: '旋转控制',
      );

  String get rotationSubtitle => _localized(
        it: 'Scegli lo stile del pulsante che avvia o ferma la rotazione del globo.',
        en: 'Choose the style of the button that starts or stops globe rotation.',
        de: 'Wähle den Stil der Taste, die die Globusrotation startet oder stoppt.',
        fa: 'سبک دکمه شروع یا توقف چرخش کره زمین را انتخاب کنید.',
        es: 'Elige el estilo del botón que inicia o detiene la rotación del globo.',
        pt: 'Escolha o estilo do botão que inicia ou interrompe a rotação do globo.',
        fr: 'Choisissez le style du bouton qui démarre ou arrête la rotation du globe.',
        ar: 'اختر نمط الزر الذي يبدأ أو يوقف دوران الكرة الأرضية.',
        ro: 'Alege stilul butonului care pornește sau oprește rotația globului.',
        ru: 'Выберите стиль кнопки запуска или остановки вращения глобуса.',
        zh: '选择用于启动或停止地球仪旋转的按钮样式。',
      );

  String get reset => _localized(
        it: 'Ripristina',
        en: 'Reset',
        de: 'Zurücksetzen',
        fa: 'بازنشانی',
        es: 'Restablecer',
        pt: 'Redefinir',
        fr: 'Réinitialiser',
        ar: 'إعادة الضبط',
        ro: 'Resetează',
        ru: 'Сбросить',
        zh: '重置',
      );

  String get localOnly => _localized(
        it: 'Queste preferenze restano locali sul dispositivo e non modificano l’ambito geografico, i contenuti o i marker in tempo reale.',
        en: 'These preferences stay local on this device and never change geographic scope, content or live markers.',
        de: 'Diese Einstellungen bleiben lokal auf diesem Gerät und verändern weder den geografischen Bereich noch Inhalte oder Live-Marker.',
        fa: 'این تنظیمات فقط روی این دستگاه ذخیره می‌شوند و محدوده جغرافیایی، محتوا یا نشانگرهای زنده را تغییر نمی‌دهند.',
        es: 'Estas preferencias permanecen en este dispositivo y no cambian el ámbito geográfico, el contenido ni los marcadores en vivo.',
        pt: 'Estas preferências permanecem neste dispositivo e não alteram o âmbito geográfico, o conteúdo nem os marcadores em tempo real.',
        fr: 'Ces préférences restent sur cet appareil et ne modifient ni le périmètre géographique, ni le contenu, ni les marqueurs en direct.',
        ar: 'تبقى هذه التفضيلات على هذا الجهاز ولا تغيّر النطاق الجغرافي أو المحتوى أو العلامات المباشرة.',
        ro: 'Aceste preferințe rămân pe acest dispozitiv și nu modifică aria geografică, conținutul sau marcajele live.',
        ru: 'Эти настройки остаются локальными на этом устройстве и не изменяют географический охват, контент или маркеры в реальном времени.',
        zh: '这些偏好仅保存在此设备上，不会改变地理范围、内容或实时标记。',
      );

  String globeLabel(GlobeVisualStyle style) {
    final preset = GlobePresetVisual.forStyle(style);
    return '${preset.code} · ${preset.name}';
  }

  String radioLabel(RadioVisualStyle style) {
    return switch (style) {
      RadioVisualStyle.vintageClassic => _localized(
          it: '1 · Nota',
          en: '1 · Note',
          de: '1 · Note',
          fa: '1 · نت موسیقی',
          es: '1 · Nota',
          pt: '1 · Nota',
          fr: '1 · Note',
          ar: '1 · نغمة',
          ro: '1 · Notă',          ru: '1 · Нота',
          zh: '1 · 音符',
),
      RadioVisualStyle.oldStyle => _localized(
          it: '2 · Radio',
          en: '2 · Radio',
          de: '2 · Radio',
          fa: '2 · رادیو',
          es: '2 · Radio',
          pt: '2 · Rádio',
          fr: '2 · Radio',
          ar: '2 · راديو',
          ro: '2 · Radio',          ru: '2 · Радио',
          zh: '2 · 电台',
),
      RadioVisualStyle.retroElegant => _localized(
          it: '3 · Equalizer',
          en: '3 · Equalizer',
          de: '3 · Equalizer',
          fa: '3 · اکولایزر',
          es: '3 · Ecualizador',
          pt: '3 · Equalizador',
          fr: '3 · Égaliseur',
          ar: '3 · معادل صوتي',
          ro: '3 · Egalizator',          ru: '3 · Эквалайзер',
          zh: '3 · 均衡器',
),
      RadioVisualStyle.woodMinimal => _localized(
          it: '4 · Onda',
          en: '4 · Wave',
          de: '4 · Welle',
          fa: '4 · موج',
          es: '4 · Onda',
          pt: '4 · Onda',
          fr: '4 · Onde',
          ar: '4 · موجة',
          ro: '4 · Undă',          ru: '4 · Волна',
          zh: '4 · 波形',
),
      RadioVisualStyle.modernVintage => _localized(
          it: '5 · Cuffie',
          en: '5 · Headphones',
          de: '5 · Kopfhörer',
          fa: '5 · هدفون',
          es: '5 · Auriculares',
          pt: '5 · Fones',
          fr: '5 · Casque',
          ar: '5 · سماعات',
          ro: '5 · Căști',          ru: '5 · Наушники',
          zh: '5 · 耳机',
),
      RadioVisualStyle.steampunk => _localized(
          it: '6 · Disco',
          en: '6 · Disc',
          de: '6 · Platte',
          fa: '6 · دیسک',
          es: '6 · Disco',
          pt: '6 · Disco',
          fr: '6 · Disque',
          ar: '6 · قرص',
          ro: '6 · Disc',          ru: '6 · Диск',
          zh: '6 · 唱片',
),
      RadioVisualStyle.minimalChic => _localized(
          it: '7 · Pulse',
          en: '7 · Pulse',
          de: '7 · Pulse',
          fa: '7 · پالس',
          es: '7 · Pulso',
          pt: '7 · Pulso',
          fr: '7 · Pulse',
          ar: '7 · نبض',
          ro: '7 · Puls',          ru: '7 · Pulse',
          zh: '7 · 脉搏',
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
          es: '1 · Clásico',
          pt: '1 · Clássico',
          fr: '1 · Classique',
          ar: '1 · كلاسيكي',
          ro: '1 · Clasic',          ru: '1 · Классический',
          zh: '1 · 经典',
),
      GlobeRotationVisualStyle.minimal => _localized(
          it: '2 · Minimal',
          en: '2 · Minimal',
          de: '2 · Minimal',
          fa: '2 · مینیمال',
          es: '2 · Minimal',
          pt: '2 · Minimal',
          fr: '2 · Minimal',
          ar: '2 · بسيط',
          ro: '2 · Minimal',          ru: '2 · Минимальный',
          zh: '2 · 极简',
),
      GlobeRotationVisualStyle.subtle => _localized(
          it: '3 · Sottile',
          en: '3 · Subtle',
          de: '3 · Dezent',
          fa: '3 · ظریف',
          es: '3 · Sutil',
          pt: '3 · Sutil',
          fr: '3 · Subtil',
          ar: '3 · خفيف',
          ro: '3 · Subtil',          ru: '3 · Ненавязчивый',
          zh: '3 · 轻柔',
),
      GlobeRotationVisualStyle.neon => _localized(
          it: '4 · Neon',
          en: '4 · Neon',
          de: '4 · Neon',
          fa: '4 · نئون',
          es: '4 · Neón',
          pt: '4 · Neon',
          fr: '4 · Néon',
          ar: '4 · نيون',
          ro: '4 · Neon',          ru: '4 · Неон',
          zh: '4 · 霓虹',
),
      GlobeRotationVisualStyle.filled => _localized(
          it: '5 · Pieno',
          en: '5 · Filled',
          de: '5 · Gefüllt',
          fa: '5 · پر',
          es: '5 · Lleno',
          pt: '5 · Preenchido',
          fr: '5 · Plein',
          ar: '5 · ممتلئ',
          ro: '5 · Plin',          ru: '5 · Заполненный',
          zh: '5 · 实心',
),
      GlobeRotationVisualStyle.glass => _localized(
          it: '6 · Glass',
          en: '6 · Glass',
          de: '6 · Glas',
          fa: '6 · شیشه‌ای',
          es: '6 · Cristal',
          pt: '6 · Vidro',
          fr: '6 · Verre',
          ar: '6 · زجاج',
          ro: '6 · Sticlă',          ru: '6 · Стекло',
          zh: '6 · 玻璃',
),
      GlobeRotationVisualStyle.premium => _localized(
          it: '7 · Premium',
          en: '7 · Premium',
          de: '7 · Premium',
          fa: '7 · پریمیوم',
          es: '7 · Premium',
          pt: '7 · Premium',
          fr: '7 · Premium',
          ar: '7 · مميز',
          ro: '7 · Premium',          ru: '7 · Premium',
          zh: '7 · 高级',
),
    };
  }
}
