import 'package:flutter/material.dart';

import 'package:sociale_vote/shared/widgets/content_directionality.dart';

enum ProductSignatureKind {
  socialVote,
  vote,
  voce,
  news,
  world,
  worldBrief,
  pulse,
  pulseNow,
}

class ProductSignatureCopy {
  final String brand;
  final String descriptor;

  const ProductSignatureCopy({
    required this.brand,
    required this.descriptor,
  });

  static ProductSignatureCopy of(
    BuildContext context,
    ProductSignatureKind kind,
  ) {
    final languageCode =
        Localizations.localeOf(context).languageCode.toLowerCase();
    return forLanguageCode(languageCode, kind);
  }

  static ProductSignatureCopy forLanguageCode(
    String languageCode,
    ProductSignatureKind kind,
  ) {
    final brand = switch (kind) {
      ProductSignatureKind.socialVote => 'Social Vote',
      ProductSignatureKind.vote => 'Vote',
      ProductSignatureKind.voce => 'Voce',
      ProductSignatureKind.news => 'News',
      ProductSignatureKind.world => 'World',
      ProductSignatureKind.worldBrief => 'World Brief',
      ProductSignatureKind.pulse => 'Pulse',
      ProductSignatureKind.pulseNow => 'Pulse Now',
    };

    final normalized = languageCode.trim().toLowerCase();
    final descriptor = switch (normalized) {
      'it' => _descriptorIt(kind),
      'de' => _descriptorDe(kind),
      'fa' => _descriptorFa(kind),
      'es' => _descriptorEs(kind),
      'pt' => _descriptorPt(kind),
      'fr' => _descriptorFr(kind),
      'ar' => _descriptorAr(kind),
      'ro' => _descriptorRo(kind),
      'ru' => _descriptorRu(kind),
      'zh' => _descriptorZh(kind),
      _ => _descriptorEn(kind),
    };

    return ProductSignatureCopy(brand: brand, descriptor: descriptor);
  }

  static String _descriptorEn(ProductSignatureKind kind) => switch (kind) {
        ProductSignatureKind.socialVote => 'Participation and public opinion',
        ProductSignatureKind.vote => 'Voting',
        ProductSignatureKind.voce => 'Opinions and expression',
        ProductSignatureKind.news => 'Current affairs',
        ProductSignatureKind.world => 'Global view',
        ProductSignatureKind.worldBrief => 'Global summary',
        ProductSignatureKind.pulse => 'Relevant content',
        ProductSignatureKind.pulseNow => 'What is moving now',
      };

  static String _descriptorIt(ProductSignatureKind kind) => switch (kind) {
        ProductSignatureKind.socialVote => 'Partecipazione e opinione pubblica',
        ProductSignatureKind.vote => 'Votazioni',
        ProductSignatureKind.voce => 'Opinioni ed espressione',
        ProductSignatureKind.news => 'Notizie',
        ProductSignatureKind.world => 'Mondo',
        ProductSignatureKind.worldBrief => 'Sintesi globale',
        ProductSignatureKind.pulse => 'Contenuti rilevanti',
        ProductSignatureKind.pulseNow => 'Cosa si muove ora',
      };

  static String _descriptorDe(ProductSignatureKind kind) => switch (kind) {
        ProductSignatureKind.socialVote => 'Beteiligung und öffentliche Meinung',
        ProductSignatureKind.vote => 'Abstimmungen',
        ProductSignatureKind.voce => 'Meinung und Ausdruck',
        ProductSignatureKind.news => 'Nachrichten',
        ProductSignatureKind.world => 'Welt',
        ProductSignatureKind.worldBrief => 'Weltüberblick',
        ProductSignatureKind.pulse => 'Relevante Inhalte',
        ProductSignatureKind.pulseNow => 'Was jetzt bewegt',
      };

  static String _descriptorFa(ProductSignatureKind kind) => switch (kind) {
        ProductSignatureKind.socialVote => 'مشارکت و افکار عمومی',
        ProductSignatureKind.vote => 'رأی‌گیری',
        ProductSignatureKind.voce => 'دیدگاه و بیان نظر',
        ProductSignatureKind.news => 'خبرها',
        ProductSignatureKind.world => 'جهان',
        ProductSignatureKind.worldBrief => 'خلاصه جهان',
        ProductSignatureKind.pulse => 'محتوای مرتبط',
        ProductSignatureKind.pulseNow => 'آنچه اکنون در جریان است',
      };

  static String _descriptorEs(ProductSignatureKind kind) => switch (kind) {
        ProductSignatureKind.socialVote => 'Participación y opinión pública',
        ProductSignatureKind.vote => 'Votaciones',
        ProductSignatureKind.voce => 'Opinión y expresión',
        ProductSignatureKind.news => 'Noticias',
        ProductSignatureKind.world => 'Mundo',
        ProductSignatureKind.worldBrief => 'Resumen global',
        ProductSignatureKind.pulse => 'Contenido relevante',
        ProductSignatureKind.pulseNow => 'Lo que se mueve ahora',
      };

  static String _descriptorPt(ProductSignatureKind kind) => switch (kind) {
        ProductSignatureKind.socialVote => 'Participação e opinião pública',
        ProductSignatureKind.vote => 'Votações',
        ProductSignatureKind.voce => 'Opinião e expressão',
        ProductSignatureKind.news => 'Notícias',
        ProductSignatureKind.world => 'Mundo',
        ProductSignatureKind.worldBrief => 'Resumo global',
        ProductSignatureKind.pulse => 'Conteúdo relevante',
        ProductSignatureKind.pulseNow => 'O que está em movimento agora',
      };

  static String _descriptorFr(ProductSignatureKind kind) => switch (kind) {
        ProductSignatureKind.socialVote => 'Participation et opinion publique',
        ProductSignatureKind.vote => 'Votes et consultations',
        ProductSignatureKind.voce => 'Opinion et expression',
        ProductSignatureKind.news => 'Actualités',
        ProductSignatureKind.world => 'Monde',
        ProductSignatureKind.worldBrief => 'Synthèse mondiale',
        ProductSignatureKind.pulse => 'Contenus pertinents',
        ProductSignatureKind.pulseNow => 'Ce qui bouge maintenant',
      };

  static String _descriptorAr(ProductSignatureKind kind) => switch (kind) {
        ProductSignatureKind.socialVote => 'المشاركة والرأي العام',
        ProductSignatureKind.vote => 'التصويت',
        ProductSignatureKind.voce => 'الرأي والتعبير',
        ProductSignatureKind.news => 'الأخبار',
        ProductSignatureKind.world => 'العالم',
        ProductSignatureKind.worldBrief => 'ملخص العالم',
        ProductSignatureKind.pulse => 'محتوى ذو صلة',
        ProductSignatureKind.pulseNow => 'ما يحدث الآن',
      };

  static String _descriptorRo(ProductSignatureKind kind) => switch (kind) {
        ProductSignatureKind.socialVote => 'Participare și opinie publică',
        ProductSignatureKind.vote => 'Voturi',
        ProductSignatureKind.voce => 'Opinii și exprimare',
        ProductSignatureKind.news => 'Știri',
        ProductSignatureKind.world => 'Lume',
        ProductSignatureKind.worldBrief => 'Rezumat global',
        ProductSignatureKind.pulse => 'Conținut relevant',
        ProductSignatureKind.pulseNow => 'Ce se întâmplă acum',
      };

  static String _descriptorRu(ProductSignatureKind kind) => switch (kind) {
        ProductSignatureKind.socialVote => 'Участие и общественное мнение',
        ProductSignatureKind.vote => 'Голосование',
        ProductSignatureKind.voce => 'Мнение и высказывание',
        ProductSignatureKind.news => 'Новости',
        ProductSignatureKind.world => 'Мир',
        ProductSignatureKind.worldBrief => 'Обзор мира',
        ProductSignatureKind.pulse => 'Актуальный контент',
        ProductSignatureKind.pulseNow => 'Что происходит сейчас',
      };

  static String _descriptorZh(ProductSignatureKind kind) => switch (kind) {
        ProductSignatureKind.socialVote => '参与和公共意见',
        ProductSignatureKind.vote => '投票',
        ProductSignatureKind.voce => '观点与表达',
        ProductSignatureKind.news => '新闻',
        ProductSignatureKind.world => '世界',
        ProductSignatureKind.worldBrief => '全球简报',
        ProductSignatureKind.pulse => '相关内容',
        ProductSignatureKind.pulseNow => '此刻正在发生',
      };
}

class ProductSignatureLabel extends StatelessWidget {
  final ProductSignatureKind kind;
  final TextStyle? brandStyle;
  final TextStyle? descriptorStyle;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;
  final int descriptorMaxLines;
  final double gap;

  const ProductSignatureLabel({
    super.key,
    required this.kind,
    this.brandStyle,
    this.descriptorStyle,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textAlign = TextAlign.start,
    this.descriptorMaxLines = 1,
    this.gap = 1,
  });

  @override
  Widget build(BuildContext context) {
    final copy = ProductSignatureCopy.of(context, kind);
    final theme = Theme.of(context);

    return Semantics(
      label: '${copy.brand}: ${copy.descriptor}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            copy.brand,
            textDirection: TextDirection.ltr,
            textAlign: textAlign,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: brandStyle,
          ),
          SizedBox(height: gap),
          Text(
            copy.descriptor,
            textDirection: socialVoteContentDirection(copy.descriptor),
            textAlign: textAlign,
            maxLines: descriptorMaxLines,
            overflow: TextOverflow.ellipsis,
            style: descriptorStyle ??
                theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
