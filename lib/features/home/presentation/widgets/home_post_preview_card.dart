import 'package:flutter/material.dart';

import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/features/social/presentation/widgets/post_card.dart';

class HomePostPreviewCard extends StatefulWidget {
  final Post post;

  final int fireCount;
  final int iceCount;
  final int commentCount;
  final ReactionType? userReaction;

  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;
  final VoidCallback? onReturnedFromDetail;

  const HomePostPreviewCard({
    super.key,
    required this.post,
    this.fireCount = 0,
    this.iceCount = 0,
    this.commentCount = 0,
    this.userReaction,
    this.onFireTap,
    this.onIceTap,
    this.onReturnedFromDetail,
  });

  @override
  State<HomePostPreviewCard> createState() => _HomePostPreviewCardState();
}

class _HomePostPreviewCardState extends State<HomePostPreviewCard> {
  Post get post => widget.post;

  Future<void> _openPostDetail() async {
    await Navigator.pushNamed(
      context,
      AppRouter.socialDetail,
      arguments: post.id.value,
    );

    widget.onReturnedFromDetail?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openPostDetail,
      child: PostCard(
        post: post,
        fireCount: widget.fireCount,
        iceCount: widget.iceCount,
        commentCount: widget.commentCount,
        userReaction: widget.userReaction,
        onFireTap: widget.onFireTap,
        onIceTap: widget.onIceTap,
        onCommentTap: _openPostDetail,
      ),
    );
  }
}