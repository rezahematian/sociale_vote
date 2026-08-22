import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/organization/entities/organization_models.dart';

class OrganizationCoverHeader extends StatelessWidget {
  final OrganizationProfile organization;
  final String verifiedLabel;
  final VoidCallback? onEdit;

  const OrganizationCoverHeader({
    super.key,
    required this.organization,
    required this.verifiedLabel,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cover = organization.coverUrl?.trim() ?? '';
    final logo = organization.logoUrl?.trim() ?? '';

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            child: cover.isNotEmpty
                ? Image.network(
                    cover,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackCover(context),
                  )
                : _fallbackCover(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: theme.colorScheme.surface,
                    child: CircleAvatar(
                      radius: 38,
                      backgroundImage: logo.isNotEmpty ? NetworkImage(logo) : null,
                      child: logo.isEmpty
                          ? const Icon(Icons.apartment_rounded, size: 36)
                          : null,
                    ),
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
                          children: [
                            Expanded(
                              child: Text(
                                organization.publicName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (onEdit != null)
                              IconButton(
                                onPressed: onEdit,
                                icon: const Icon(Icons.edit_outlined),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 17,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                verifiedLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if ((organization.city?.isNotEmpty ?? false) ||
                            (organization.countryCode?.isNotEmpty ?? false)) ...[
                          const SizedBox(height: 5),
                          Text(
                            [organization.city, organization.countryCode]
                                .whereType<String>()
                                .where((value) => value.trim().isNotEmpty)
                                .join(' · '),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if ((organization.description?.trim().isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(organization.description!.trim()),
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
            colors.primaryContainer,
            colors.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.how_to_vote_rounded,
          size: 52,
          color: colors.onPrimaryContainer.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
