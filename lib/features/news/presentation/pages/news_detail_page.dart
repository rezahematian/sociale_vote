import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/entities/world_brief.dart';
import 'package:sociale_vote/domain/moderation/entities/report.dart';
import 'package:sociale_vote/domain/moderation/repositories/moderation_repository.dart';
import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';
import 'package:sociale_vote/features/discussion/presentation/widgets/comment_section.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';
import 'package:sociale_vote/shared/widgets/social_vote_symbols.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

/// Pagina di dettaglio per una singola news.
///
/// Uso previsto:
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => NewsDetailPage(news: newsItem),
///   ),
/// );
class NewsDetailPage extends StatefulWidget {
  final NewsItem news;

  const NewsDetailPage({
    super.key,
    required this.news,
  });

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  static const List<String> _reportReasons = [
    'spam',
    'harassment',
    'hate_speech',
    'misinformation',
    'violence',
    'other',
  ];

  bool _isFavorite = false;
  bool _favoriteLoading = false;
  int _commentCount = 0;
  String? _initializedNewsId;

  @override
  void initState() {
    super.initState();
    _initializeForCurrentNews();
  }

  @override
  void didUpdateWidget(covariant NewsDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.news.id.value != widget.news.id.value) {
      _isFavorite = false;
      _favoriteLoading = false;
      _commentCount = 0;
      _initializedNewsId = null;
      _initializeForCurrentNews();
    }
  }

  void _initializeForCurrentNews() {
    _initializedNewsId = widget.news.id.value;
    _initFavoriteStatus();
    _loadCommentCount();
  }

  Future<void> _initFavoriteStatus() async {
    final userId = AppDI.instance.currentUserId;

    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _isFavorite = false;
      });
      return;
    }

    try {
      final isFav = await AppDI.instance.isFavorite(
        userId: userId,
        target: TargetRef.news(widget.news.id.value),
      );
      if (!mounted) return;
      setState(() {
        _isFavorite = isFav;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _loadCommentCount() async {
    try {
      final count = await AppDI.instance.getCommentCountForTarget(
        TargetRef.news(widget.news.id.value),
      );
      if (!mounted) return;
      setState(() {
        _commentCount = count;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _commentCount = 0;
      });
    }
  }

  Future<void> _onFavoritePressed() async {
    if (_favoriteLoading) {
      return;
    }

    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.react,
    );
    if (!allowed) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) return;

    setState(() {
      _favoriteLoading = true;
    });

    try {
      final newState = await AppDI.instance.toggleFavorite(
        userId: userId,
        target: TargetRef.news(widget.news.id.value),
      );
      if (!mounted) return;
      setState(() {
        _isFavorite = newState;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.newsDetail_favoriteUpdateError,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _favoriteLoading = false;
        });
      }
    }
  }

  Future<void> _onSharePressed() async {
    final summary = widget.news.summary?.trim();
    final content = widget.news.content.trim();
    final previewSource =
        (summary != null && summary.isNotEmpty) ? summary : content;
    final preview = previewSource.length > 220
        ? '${previewSource.substring(0, 220).trim()}...'
        : previewSource;
    final articleUrl = widget.news.articleUrl?.trim();

    final buffer = StringBuffer()..writeln(widget.news.title);

    if (preview.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(preview);
    }

    if (articleUrl != null && articleUrl.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(articleUrl);
    }

    buffer
      ..writeln()
      ..writeln(AppLocalizations.of(context)!.newsDetail_shareMessage);

    try {
      await Share.share(
        buffer.toString().trim(),
        subject: widget.news.title,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.newsDetail_shareError),
        ),
      );
    }
  }

  Future<void> _onReportPressed() async {
    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.reportContent,
    );
    if (!allowed || !mounted) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.contentReport_authenticationRequired,
          ),
        ),
      );
      return;
    }

    final reason = await _showReportReasonDialog(context);
    if (!mounted || reason == null) return;

    try {
      final result = await AppDI.instance.reportContent(
        Report(
          target: TargetRef.news(widget.news.id.value),
          userId: userId,
          reason: reason,
          createdAt: DateTime.now(),
        ),
      );

      if (!mounted) return;

      final message = switch (result) {
        SubmitReportResult.submitted =>
          AppLocalizations.of(context)!.contentReport_submittedMessage,
        SubmitReportResult.alreadyReported =>
          AppLocalizations.of(context)!.contentReport_alreadySubmittedMessage,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.contentReport_submitError),
        ),
      );
    }
  }

  Future<String?> _showReportReasonDialog(BuildContext context) async {
    String selectedReason = _reportReasons.first;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(dialogContext)!.contentReport_dialogTitle,
              ),
              content: RadioGroup<String>(
                groupValue: selectedReason,
                onChanged: (value) {
                  if (value == null) return;
                  setDialogState(() {
                    selectedReason = value;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _reportReasons.map((reason) {
                    return RadioListTile<String>(
                      value: reason,
                      contentPadding: EdgeInsets.zero,
                      title: Text(_reportReasonLabel(dialogContext, reason)),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                      AppLocalizations.of(dialogContext)!.commonCancelButton),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(selectedReason);
                  },
                  child: Text(
                    AppLocalizations.of(dialogContext)!
                        .contentReport_sendButton,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openOriginalArticle() async {
    await _openExternalSource(widget.news.articleUrl);
  }

  Future<void> _openWorldBriefSource(String? rawUrl) async {
    await _openExternalSource(rawUrl, requireHttps: true);
  }

  Future<void> _openExternalSource(
    String? rawUrl, {
    bool requireHttps = false,
  }) async {
    final normalized = rawUrl?.trim();
    final uri = normalized == null ? null : Uri.tryParse(normalized);
    if (uri == null ||
        !uri.hasScheme ||
        (requireHttps && uri.scheme != 'https') ||
        uri.host.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.newsDetail_openSourceUnavailable,
          ),
        ),
      );
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.newsDetail_openSourceUnavailable,
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.newsDetail_openSourceUnavailable,
          ),
        ),
      );
    }
  }

  String _reportReasonLabel(BuildContext context, String reason) {
    final l10n = AppLocalizations.of(context)!;
    return switch (reason) {
      'spam' => l10n.contentReport_reasonSpam,
      'harassment' => l10n.contentReport_reasonHarassment,
      'hate_speech' => l10n.contentReport_reasonHateSpeech,
      'misinformation' => l10n.contentReport_reasonMisinformation,
      'violence' => l10n.contentReport_reasonViolence,
      'other' => l10n.contentReport_reasonOther,
      _ => reason,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final news = widget.news;
    final sourceLabel = news.effectiveSourceLabel;
    final isDark = theme.brightness == Brightness.dark;
    final pageBackground =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F7FB);

    if (_initializedNewsId != news.id.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _isFavorite = false;
          _favoriteLoading = false;
          _commentCount = 0;
          _initializedNewsId = news.id.value;
        });
        _initializeForCurrentNews();
      });
    }

    NewsController? newsController;
    try {
      newsController = Provider.of<NewsController>(
        context,
        listen: true,
      );
    } catch (_) {
      newsController = null;
    }

    final summary = newsController?.summaryForNews(news);
    final fireCount = summary?.likeCount ?? 0;
    final iceCount = summary?.dislikeCount ?? 0;
    final userReaction = summary?.userReaction;

    return ChangeNotifierProvider<DiscussionController>(
      create: (_) => AppDI.instance.createDiscussionController(
        TargetRef.news(news.id.value),
        onCommentsChanged: _loadCommentCount,
      )..loadComments(),
      child: Scaffold(
        backgroundColor: pageBackground,
        appBar: AppBar(
          title: Row(
            children: [
              const ContentTypeMark(
                kind: SocialVoteContentKind.news,
                size: 28,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.newsDetail_title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'report') {
                  _onReportPressed();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'report',
                  child: Text(l10n.contentReport_menuAction),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NewsDetailHeroCard(
                      news: news,
                      sourceLabel: sourceLabel,
                      bodyText: _resolveBodyText(l10n),
                      publishedAtLabel: _formatPublishedAt(news.publishedAt),
                      isFavorite: _isFavorite,
                      favoriteLoading: _favoriteLoading,
                      showEngagement: newsController != null,
                      fireCount: fireCount,
                      iceCount: iceCount,
                      commentCount: _commentCount,
                      userReaction: userReaction,
                      onSharePressed: _onSharePressed,
                      onFavoritePressed:
                          _favoriteLoading ? null : _onFavoritePressed,
                      onOpenSourcePressed: news.hasOriginalArticleUrl
                          ? _openOriginalArticle
                          : null,
                      onOpenWorldBriefSource: _openWorldBriefSource,
                      onFireTap: newsController == null
                          ? null
                          : () async {
                              final allowed =
                                  await AuthGuard.ensureCanPerformAction(
                                context,
                                ParticipationAction.react,
                              );
                              if (!context.mounted || !allowed) return;

                              final userId = AppDI.instance.currentUserId;
                              if (userId == null) return;

                              newsController!.toggleFireForNews(
                                userId: userId,
                                newsItem: news,
                              );
                            },
                      onIceTap: newsController == null
                          ? null
                          : () async {
                              final allowed =
                                  await AuthGuard.ensureCanPerformAction(
                                context,
                                ParticipationAction.react,
                              );
                              if (!context.mounted || !allowed) return;

                              final userId = AppDI.instance.currentUserId;
                              if (userId == null) return;

                              newsController!.toggleIceForNews(
                                userId: userId,
                                newsItem: news,
                              );
                            },
                    ),
                    const SizedBox(height: 20),
                    CommentSection(
                      userId: AppDI.instance.currentUserId ?? 'guest',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _resolveBodyText(AppLocalizations l10n) {
    final summary = widget.news.summary;
    if (summary != null && summary.trim().isNotEmpty) {
      return summary;
    }

    final content = widget.news.content;
    if (content.trim().isNotEmpty) {
      return content;
    }

    return l10n.newsDetail_bodyFallback;
  }

  String _formatPublishedAt(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}

class _NewsDetailHeroCard extends StatelessWidget {
  final NewsItem news;
  final String? sourceLabel;
  final String bodyText;
  final String publishedAtLabel;
  final bool isFavorite;
  final bool favoriteLoading;
  final bool showEngagement;
  final int fireCount;
  final int iceCount;
  final int commentCount;
  final dynamic userReaction;
  final VoidCallback onSharePressed;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onOpenSourcePressed;
  final Future<void> Function(String? url) onOpenWorldBriefSource;
  final Future<void> Function()? onFireTap;
  final Future<void> Function()? onIceTap;

  const _NewsDetailHeroCard({
    required this.news,
    required this.sourceLabel,
    required this.bodyText,
    required this.publishedAtLabel,
    required this.isFavorite,
    required this.favoriteLoading,
    required this.showEngagement,
    required this.fireCount,
    required this.iceCount,
    required this.commentCount,
    required this.userReaction,
    required this.onSharePressed,
    required this.onFavoritePressed,
    required this.onOpenSourcePressed,
    required this.onOpenWorldBriefSource,
    required this.onFireTap,
    required this.onIceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final cardTopColor =
        isDark ? const Color(0xFF162130) : const Color(0xFFFCFDFE);
    final cardBottomColor =
        isDark ? const Color(0xFF101927) : const Color(0xFFF1F5FA);
    final cardBorderColor =
        isDark ? const Color(0xFF2C3948) : const Color(0xFFD7DFEA);
    final metaColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.64 : 0.58,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF0F172A).withValues(alpha: isDark ? 0.18 : 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color:
                const Color(0xFF94A3B8).withValues(alpha: isDark ? 0.06 : 0.10),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: cardBorderColor,
              width: 1.2,
            ),
            gradient: LinearGradient(
              colors: [cardTopColor, cardBottomColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 640;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (news.isBreaking)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              l10n.newsDetail_breakingBadge,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onError,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        if (news.isSocialVoteBrief)
                          const _NewsMetaChip(
                            icon: Icons.auto_awesome_outlined,
                            label: 'World Brief',
                          ),
                        if (sourceLabel != null &&
                            sourceLabel!.trim().isNotEmpty)
                          _NewsMetaChip(
                            icon: Icons.language_outlined,
                            label: sourceLabel!.trim(),
                          ),
                        _NewsMetaChip(
                          icon: Icons.schedule_outlined,
                          label: publishedAtLabel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      news.title.trim(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (news.worldBrief != null)
                      _WorldBriefBody(
                        brief: news.worldBrief!,
                        onOpenSource: onOpenWorldBriefSource,
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: isDark ? 0.30 : 0.68,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: isDark ? 0.18 : 0.12,
                            ),
                          ),
                        ),
                        child: Text(
                          bodyText,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.48,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: isDark ? 0.88 : 0.86,
                            ),
                          ),
                        ),
                      ),
                    if (onOpenSourcePressed != null) ...[
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: onOpenSourcePressed,
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: Text(l10n.newsDetail_openSource),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Divider(
                      height: 1,
                      color: theme.colorScheme.outline.withValues(
                        alpha: isDark ? 0.20 : 0.14,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (isCompact)
                      Row(
                        children: [
                          if (showEngagement)
                            Expanded(
                              child: EngagementBar(
                                fireCount: fireCount,
                                iceCount: iceCount,
                                commentCount: commentCount,
                                userReaction: userReaction,
                                onFireTap: onFireTap,
                                onIceTap: onIceTap,
                              ),
                            )
                          else
                            const Spacer(),
                          const SizedBox(width: 8),
                          _NewsDetailActionIcon(
                            icon: Icons.share_outlined,
                            tooltip: l10n.newsDetail_shareTooltip,
                            onPressed: onSharePressed,
                          ),
                          const SizedBox(width: 8),
                          _NewsDetailActionIcon(
                            icon: isFavorite
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            tooltip: isFavorite
                                ? l10n.newsDetail_removeFromFavoritesTooltip
                                : l10n.newsDetail_addToFavoritesTooltip,
                            onPressed: onFavoritePressed,
                            isActive: isFavorite,
                            isLoading: favoriteLoading,
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          if (showEngagement)
                            EngagementBar(
                              fireCount: fireCount,
                              iceCount: iceCount,
                              commentCount: commentCount,
                              userReaction: userReaction,
                              onFireTap: onFireTap,
                              onIceTap: onIceTap,
                            ),
                          const Spacer(),
                          _NewsDetailActionIcon(
                            icon: Icons.share_outlined,
                            tooltip: l10n.newsDetail_shareTooltip,
                            onPressed: onSharePressed,
                          ),
                          const SizedBox(width: 8),
                          _NewsDetailActionIcon(
                            icon: isFavorite
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            tooltip: isFavorite
                                ? l10n.newsDetail_removeFromFavoritesTooltip
                                : l10n.newsDetail_addToFavoritesTooltip,
                            onPressed: onFavoritePressed,
                            isActive: isFavorite,
                            isLoading: favoriteLoading,
                          ),
                        ],
                      ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.newsDetail_footerMoreContext,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: metaColor,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _WorldBriefBody extends StatelessWidget {
  final WorldBrief brief;
  final Future<void> Function(String? url) onOpenSource;

  const _WorldBriefBody({
    required this.brief,
    required this.onOpenSource,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sectionColor = theme.colorScheme.surface.withValues(
      alpha: isDark ? 0.30 : 0.68,
    );
    final borderColor = theme.colorScheme.outline.withValues(
      alpha: isDark ? 0.18 : 0.12,
    );

    Widget section(String title, String text, {required IconData icon}) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: sectionColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.48),
            ),
          ],
        ),
      );
    }

    final uncertain = brief.whatIsUncertain?.trim();
    final socialVoteView = brief.socialVoteView?.trim();
    final sources = brief.sourceUrls
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        section(
          l10n.worldBriefWhatHappened,
          brief.whatHappened,
          icon: Icons.fact_check_outlined,
        ),
        const SizedBox(height: 12),
        section(
          l10n.worldBriefWhyItMatters,
          brief.whyItMatters,
          icon: Icons.insights_outlined,
        ),
        if (uncertain != null && uncertain.isNotEmpty) ...[
          const SizedBox(height: 12),
          section(
            l10n.worldBriefWhatIsUncertain,
            uncertain,
            icon: Icons.help_outline_rounded,
          ),
        ],
        if (socialVoteView != null && socialVoteView.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(
                alpha: isDark ? 0.20 : 0.42,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.26),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology_alt_outlined,
                      size: 19,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        l10n.worldBriefSocialVoteView,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.worldBriefSocialVoteViewPublicNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  socialVoteView,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.48),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: sectionColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.worldBriefSources,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              for (var index = 0; index < sources.length; index++)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => onOpenSource(sources[index]),
                    icon: const Icon(Icons.open_in_new_rounded, size: 17),
                    label: Text(
                      _sourceLabel(sources[index], index + 1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _sourceLabel(String rawUrl, int number) {
    final uri = Uri.tryParse(rawUrl);
    final host = uri?.host.trim();
    if (host == null || host.isEmpty) return 'Source $number';
    return '$number · $host';
  }
}

class _NewsMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _NewsMetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: isDark ? 0.34 : 0.72,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: isDark ? 0.18 : 0.12,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsDetailActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isActive;
  final bool isLoading;

  const _NewsDetailActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isActive
        ? colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.10)
        : colorScheme.surface.withValues(alpha: isDark ? 0.30 : 0.82);
    final borderColor = isActive
        ? colorScheme.primary.withValues(alpha: isDark ? 0.32 : 0.22)
        : colorScheme.outline.withValues(alpha: isDark ? 0.18 : 0.14);
    final foregroundColor = isActive
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.84);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foregroundColor,
                      ),
                    )
                  : Icon(
                      icon,
                      size: 18,
                      color: foregroundColor,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
