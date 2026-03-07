import 'package:flutter/material.dart';
import 'news_item.dart';
import '../../shared/widgets/heat_buttons.dart';

class NewsCard extends StatelessWidget {
  final NewsItem news;
  final VoidCallback? onHot;
  final VoidCallback? onCold;
  final VoidCallback? onReset;
  final VoidCallback? onRead;

  const NewsCard({
    super.key,
    required this.news,
    this.onHot,
    this.onCold,
    this.onReset,
    this.onRead,
  });

  static const double cardHeight = 320; // Altezza fissa per tutte le card
  static const double imageHeight = 140; // Altezza immagine fissa

  @override
  Widget build(BuildContext context) {
    return Container(
      height: cardHeight,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (news.imageUrl == null || news.imageUrl!.isEmpty) {
      return Container(
        height: imageHeight,
        color: Colors.grey.shade200,
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: imageHeight,
          width: double.infinity,
          child: Image.network(
            news.imageUrl!,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: _ScopeChip(label: news.scopeLabel),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetaRow(),
          const SizedBox(height: 6),
          _buildTitle(),
          const SizedBox(height: 4),
          _buildSummary(),
          const Spacer(),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildMetaRow() {
    return Row(
      children: [
        Icon(Icons.public, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            news.locationLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      news.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
    );
  }

  Widget _buildSummary() {
    return Text(
      news.summary,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        height: 1.4,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          _timeAgo(news.publishedAt),
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 12),
        CivicHeatButtons(
          hotCount: news.hotCount,
          coldCount: news.coldCount,
          userVote: news.userVote,
          onHot: onHot,
          onCold: onCold,
          onReset: onReset,
        ),
        const Spacer(),
        InkWell(
          onTap: onRead,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                Text(
                  'Leggi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: Colors.blueGrey.shade700),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min fa';
    if (diff.inHours < 24) return '${diff.inHours} h fa';
    return '${diff.inDays} g fa';
  }
}

class _ScopeChip extends StatelessWidget {
  final String label;
  const _ScopeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}