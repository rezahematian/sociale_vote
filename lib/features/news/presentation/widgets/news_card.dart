import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';
import 'package:sociale_vote/shared/widgets/app_card.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

/// Card visuale per una singola news.
///
/// v2 (UI hardening):
/// - header: favicon + source + time ago + "open source"
/// - title + description
/// - image (se presente)
/// - footer invariato: comment badge + engagement bar
class NewsCard extends StatelessWidget {
  final NewsItem news;

  /// Conteggio like (🔥) e dislike (❄) da mostrare sotto la news.
  final int fireCount;
  final int iceCount;

  /// Callback per tap su 🔥 e ❄.
  ///
  /// IMPORTANTE:
  /// - La UI non chiama più direttamente questi callback.
  /// - Prima passa sempre da [AuthGuard.ensureCanPerformAction] con
  ///   [ParticipationAction.react].
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const NewsCard({
    super.key,
    required this.news,
    this.fireCount = 0,
    this.iceCount = 0,
    this.onFireTap,
    this.onIceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    VoidCallback? wrapReactCallback(VoidCallback? original) {
      if (original == null) return null;

      return () async {
        final allowed = await AuthGuard.ensureCanPerformAction(
          context,
          ParticipationAction.react,
        );
        if (!allowed) return;

        original();
      };
    }

    final dynamic n = news;

    final String title =
        (n.title is String && (n.title as String).trim().isNotEmpty)
            ? (n.title as String).trim()
            : news.toString();

    final String? description =
        (n.description is String &&
                (n.description as String).trim().isNotEmpty)
            ? (n.description as String).trim()
            : null;

    final String? imageUrl =
        (n.imageUrl is String && (n.imageUrl as String).trim().isNotEmpty)
            ? (n.imageUrl as String).trim()
            : (n.image is String && (n.image as String).trim().isNotEmpty)
            ? (n.image as String).trim()
            : null;

    final String? sourceName =
        (n.sourceName is String && (n.sourceName as String).trim().isNotEmpty)
            ? (n.sourceName as String).trim()
            : (n.source is String && (n.source as String).trim().isNotEmpty)
            ? (n.source as String).trim()
            : null;

    final String? url = (n.url is String && (n.url as String).trim().isNotEmpty)
        ? (n.url as String).trim()
        : null;

    final DateTime? publishedAt =
        (n.publishedAt is DateTime) ? (n.publishedAt as DateTime) : null;

    final String timeAgo = _formatTimeAgo(publishedAt);

    final String? domain = _extractDomain(url);
    final String? faviconUrl = (domain == null)
        ? null
        : 'https://www.google.com/s2/favicons?domain=$domain&sz=64';

    Future<void> openSource() async {
      if (url == null || url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.newsDetail_openSourceUnavailable)),
        );
        return;
      }

      final uri = Uri.tryParse(url);
      if (uri == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.newsDetail_openSourceUnavailable)),
        );
        return;
      }

      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.newsDetail_openSourceUnavailable)),
        );
      }
    }

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevated: true,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NewsDetailPage(news: news),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Favicon(
                  url: faviconUrl,
                  fallbackLetter:
                      (sourceName != null && sourceName.isNotEmpty)
                      ? sourceName[0].toUpperCase()
                      : 'N',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sourceName ?? l10n.newsCard_headerTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeAgo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.newsDetail_openSource,
                  onPressed: openSource,
                  icon: Icon(
                    Icons.open_in_new,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.75),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.78),
                  height: 1.25,
                ),
              ),
            ],
            if (imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: theme.colorScheme.onSurface.withOpacity(0.06),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 22,
                        color: theme.colorScheme.onSurface.withOpacity(0.35),
                      ),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: theme.colorScheme.onSurface.withOpacity(0.06),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: progress.expectedTotalBytes == null
                                ? null
                                : progress.cumulativeBytesLoaded /
                                      (progress.expectedTotalBytes ?? 1),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                _CommentCountBadge(news: news),
                const Spacer(),
                EngagementBar(
                  fireCount: fireCount,
                  iceCount: iceCount,
                  onFireTap: wrapReactCallback(onFireTap),
                  onIceTap: wrapReactCallback(onIceTap),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now().toUtc();
    final d = date.toUtc();

    final diff = now.difference(d);
    if (diff.isNegative) return '';

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return '$day/$month/$year';
  }

  String? _extractDomain(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    try {
      final uri = Uri.parse(url.trim());
      final host = uri.host;
      if (host.isEmpty) return null;
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      return null;
    }
  }
}

class _Favicon extends StatelessWidget {
  final String? url;
  final String fallbackLetter;

  const _Favicon({
    required this.url,
    required this.fallbackLetter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget fallback() {
      return Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          fallbackLetter,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface.withOpacity(0.75),
          ),
        ),
      );
    }

    if (url == null) return fallback();

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url!,
        width: 22,
        height: 22,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      ),
    );
  }
}

class _CommentCountBadge extends StatelessWidget {
  final NewsItem news;

  const _CommentCountBadge({required this.news});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: AppDI.instance.getCommentsForTarget(TargetRef.news(news.id.value)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final comments = snapshot.data as List<dynamic>? ?? const [];
        final count = comments.length;

        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.comment_outlined,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}