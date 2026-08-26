import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/organization/entities/organization_models.dart';
import 'package:sociale_vote/shared/widgets/social_vote_symbols.dart';

class OrganizationCoverHeader extends StatefulWidget {
  final OrganizationProfile organization;
  final String verifiedLabel;
  final VoidCallback? onEdit;
  final bool compact;

  const OrganizationCoverHeader({
    super.key,
    required this.organization,
    required this.verifiedLabel,
    this.onEdit,
    this.compact = false,
  });

  @override
  State<OrganizationCoverHeader> createState() =>
      _OrganizationCoverHeaderState();
}

class _OrganizationCoverHeaderState extends State<OrganizationCoverHeader> {
  late String _cacheToken;

  @override
  void initState() {
    super.initState();
    _refreshCacheToken();
  }

  @override
  void didUpdateWidget(covariant OrganizationCoverHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Media paths are intentionally stable (cover.jpg/logo.png etc.).
    // After an overwrite the URL can therefore remain identical even though
    // the underlying object changed. A newly loaded OrganizationProfile is
    // enough reason to issue a fresh cache token.
    if (!identical(oldWidget.organization, widget.organization)) {
      _refreshCacheToken();
    }
  }

  void _refreshCacheToken() {
    _cacheToken = DateTime.now().microsecondsSinceEpoch.toString();
  }

  String _freshUrl(String url) {
    final raw = url.trim();
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme) {
      return raw;
    }

    final query = Map<String, String>.from(uri.queryParameters);
    query['sv'] = _cacheToken;
    return uri.replace(queryParameters: query).toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final organization = widget.organization;
    final cover = organization.coverUrl?.trim() ?? '';
    final logo = organization.logoUrl?.trim() ?? '';
    final location = [organization.city, organization.countryCode]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' · ');
    final description = organization.description?.trim() ?? '';
    final coverHeight = widget.compact ? 126.0 : 174.0;
    final logoRadius = widget.compact ? 34.0 : 40.0;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: coverHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (cover.isNotEmpty)
                  Image.network(
                    _freshUrl(cover),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => _fallbackCover(context),
                  )
                else
                  _fallbackCover(context),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x26000000),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              widget.compact ? 14 : 16,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: PublisherAvatar(
                    displayName: organization.publicName,
                    imageUrl: logo.isEmpty ? null : _freshUrl(logo),
                    actorType: ActorType.organization,
                    size: logoRadius * 2,
                    showTooltip: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                organization.publicName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            if (widget.onEdit != null)
                              IconButton(
                                onPressed: widget.onEdit,
                                tooltip: MaterialLocalizations.of(context)
                                    .moreButtonTooltip,
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.edit_outlined),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 17,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  widget.verifiedLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            if (location.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    location,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (description.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                widget.compact ? 0 : 2,
                16,
                16,
              ),
              child: Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.42),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallbackCover(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.secondary,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.how_to_vote_rounded,
          size: widget.compact ? 42 : 50,
          color: colors.onPrimary.withValues(alpha: 0.58),
        ),
      ),
    );
  }
}
