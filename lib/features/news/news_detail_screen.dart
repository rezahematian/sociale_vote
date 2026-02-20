import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'news_item.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsItem news;

  const NewsDetailScreen({
    super.key,
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    final hasFullContent =
        news.fullContent != null && news.fullContent!.trim().isNotEmpty;

    final content = hasFullContent ? news.fullContent! : news.summary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: news.imageUrl != null &&
                      news.imageUrl!.isNotEmpty
                  ? Image.network(
                      news.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(color: Colors.grey.shade300),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= TITLE =================

                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ================= META =================

                  Row(
                    children: [
                      Icon(
                        Icons.public,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          news.locationLabel,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _formatDate(news.publishedAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ================= CONTENT =================

                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.75,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ================= SOURCE =================

                  if (news.sourceUrl != null &&
                      news.sourceUrl!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 32),
                        const SizedBox(height: 8),
                        const Text(
                          "Fonte originale",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () async {
                            final uri = Uri.parse(news.sourceUrl!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          child: const Text("Apri articolo completo"),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
