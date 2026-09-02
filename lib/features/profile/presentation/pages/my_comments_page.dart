import 'package:flutter/material.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/widgets/content_directionality.dart';

class MyCommentsPage extends StatefulWidget {
  const MyCommentsPage({super.key});

  @override
  State<MyCommentsPage> createState() => _MyCommentsPageState();
}

class _MyCommentsPageState extends State<MyCommentsPage> {
  bool _isLoading = true;
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final userId = AppDI.instance.currentUserId;
    if (userId == null) return;

    setState(() {
      _isLoading = true;
    });

    final myComments =
        await AppDI.instance.commentRepository.getCommentsByUser(userId);

    setState(() {
      _comments = myComments;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = AppDI.instance.currentUserId;
    final l10n = AppLocalizations.of(context)!;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.profileMyCommentsTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.profileMyCommentsLoginRequired,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileMyCommentsTitle),
      ),
      body: RefreshIndicator(
        onRefresh: _loadComments,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _comments.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.profileMyCommentsEmpty,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  comment.content,
                                  textDirection:
                                      socialVoteContentDirection(comment.content),
                                  textAlign:
                                      socialVoteContentTextAlign(comment.content),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(context, comment.createdAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime dateTime) {
    final local = dateTime.toLocal();
    final material = MaterialLocalizations.of(context);
    final date = material.formatMediumDate(local);
    final time = material.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
    return '$date $time';
  }
}
