import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/identity/entities/verification_request.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/features/profile/application/verification_review_controller.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

class VerificationReviewPage extends StatelessWidget {
  const VerificationReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reviewerUserId = AppDI.instance.currentUserId;

    if (reviewerUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.verificationReviewPageTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.verificationReviewLoginRequired,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => AppDI.instance.createVerificationReviewController(),
      child: _VerificationReviewGate(
        reviewerUserId: reviewerUserId,
      ),
    );
  }
}

class _VerificationReviewGate extends StatefulWidget {
  final String reviewerUserId;

  const _VerificationReviewGate({
    required this.reviewerUserId,
  });

  @override
  State<_VerificationReviewGate> createState() =>
      _VerificationReviewGateState();
}

class _VerificationReviewGateState extends State<_VerificationReviewGate> {
  bool _isCheckingAccess = true;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccess();
    });
  }

  Future<void> _checkAccess() async {
    final session = await AppDI.instance.sessionRepository.getCurrentSession();
    final role = session?.role ?? Role.user;

    if (!mounted) return;

    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.reviewVerificationRequests,
      role: role,
    );

    if (!mounted) return;

    if (!allowed) {
      setState(() {
        _isCheckingAccess = false;
        _hasAccess = false;
      });

      final popped = await Navigator.of(context).maybePop();
      if (!popped && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.home,
          (route) => false,
        );
      }
      return;
    }

    await context.read<VerificationReviewController>().loadPendingRequests();

    if (!mounted) return;

    setState(() {
      _isCheckingAccess = false;
      _hasAccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isCheckingAccess) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.verificationReviewPageTitle),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasAccess) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.verificationReviewPageTitle),
        ),
        body: const SizedBox.shrink(),
      );
    }

    return _VerificationReviewView(
      reviewerUserId: widget.reviewerUserId,
    );
  }
}

class _VerificationReviewView extends StatelessWidget {
  final String reviewerUserId;

  const _VerificationReviewView({
    required this.reviewerUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<VerificationReviewController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verificationReviewPageTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<VerificationReviewController>().loadPendingRequests(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.verificationReviewPendingCount(
                          controller.pendingRequests.length,
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (controller.isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
            if (controller.errorMessage != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    controller.errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (!controller.isLoading && controller.pendingRequests.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.inbox_outlined, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        l10n.verificationReviewNoPendingRequests,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...controller.pendingRequests.map(
                (request) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _VerificationRequestCard(
                    request: request,
                    isProcessing: controller.isProcessing(request.id),
                    reviewerUserId: reviewerUserId,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VerificationRequestCard extends StatelessWidget {
  final VerificationRequest request;
  final bool isProcessing;
  final String reviewerUserId;

  const _VerificationRequestCard({
    required this.request,
    required this.isProcessing,
    required this.reviewerUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: _actorIcon(request.targetActorType),
                  label: _formatRequestType(l10n, request.requestType),
                ),
                _InfoChip(
                  icon: Icons.shield_outlined,
                  label: _formatActorType(l10n, request.targetActorType),
                ),
                if (request.targetActorType == ActorType.citizen)
                  _InfoChip(
                    icon: Icons.verified_outlined,
                    label: _formatVerificationLevel(
                      l10n,
                      request.targetVerificationLevel,
                    ),
                  ),
                if (request.targetInstitutionLevel != null)
                  _InfoChip(
                    icon: Icons.account_balance_outlined,
                    label: _formatInstitutionLevel(
                      l10n,
                      request.targetInstitutionLevel!,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: l10n.verificationReviewUserIdLabel,
              value: request.userId,
            ),
            _InfoRow(
              label: l10n.verificationReviewSubmittedLabel,
              value: _formatDateTime(context, request.submittedAt),
            ),
            if ((request.officialTitle ?? '').trim().isNotEmpty)
              _InfoRow(
                label: l10n.verificationReviewOfficialTitleLabel,
                value: request.officialTitle!.trim(),
              ),
            if ((request.institutionName ?? '').trim().isNotEmpty)
              _InfoRow(
                label: l10n.verificationReviewInstitutionLabel,
                value: request.institutionName!.trim(),
              ),
            if ((request.organizationName ?? '').trim().isNotEmpty)
              _InfoRow(
                label: l10n.verificationReviewOrganizationLabel,
                value: request.organizationName!.trim(),
              ),
            if ((request.reviewNote ?? '').trim().isNotEmpty)
              _InfoRow(
                label: l10n.verificationReviewNoteLabel,
                value: request.reviewNote!.trim(),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isProcessing
                        ? null
                        : () => _openReviewDialog(
                              context,
                              status: VerificationRequestStatus.rejected,
                            ),
                    icon: isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.close_rounded,
                            color: theme.colorScheme.error,
                          ),
                    label: Text(l10n.verificationReviewRejectAction),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isProcessing
                        ? null
                        : () => _openReviewDialog(
                              context,
                              status: VerificationRequestStatus.approved,
                            ),
                    icon: isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(l10n.verificationReviewApproveAction),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openReviewDialog(
    BuildContext context, {
    required VerificationRequestStatus status,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final isApprove = status == VerificationRequestStatus.approved;

    final reviewResult = await showDialog<({bool confirmed, String? note})>(
      context: context,
      builder: (dialogContext) {
        String note = '';
        bool showValidationError = false;

        return StatefulBuilder(
          builder: (context, setLocalState) {
            final normalizedNote = note.trim();
            final hasValidationError =
                !isApprove && showValidationError && normalizedNote.isEmpty;

            return AlertDialog(
              title: Text(
                isApprove
                    ? l10n.verificationReviewApproveDialogTitle
                    : l10n.verificationReviewRejectDialogTitle,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isApprove
                        ? l10n.verificationReviewApproveConfirmation
                        : l10n.verificationReviewRejectConfirmation,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    maxLines: 3,
                    autofocus: !isApprove,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      labelText: isApprove
                          ? l10n.verificationReviewOptionalNoteLabel
                          : l10n.verificationReviewRequiredNoteLabel,
                      helperText: isApprove
                          ? l10n.verificationReviewOptionalHelper
                          : l10n.verificationReviewRequiredHelper,
                      errorText: hasValidationError
                          ? l10n.verificationReviewRequiredNoteError
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      note = value;
                      if (!showValidationError) return;
                      setLocalState(() {
                        showValidationError = false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(
                    (confirmed: false, note: null),
                  ),
                  child: Text(l10n.commonCancelButton),
                ),
                FilledButton(
                  onPressed: () {
                    final normalizedNote = note.trim();

                    if (!isApprove && normalizedNote.isEmpty) {
                      setLocalState(() {
                        showValidationError = true;
                      });
                      return;
                    }

                    Navigator.of(dialogContext).pop(
                      (
                        confirmed: true,
                        note: normalizedNote.isEmpty ? null : normalizedNote,
                      ),
                    );
                  },
                  child: Text(
                    isApprove
                        ? l10n.verificationReviewApproveAction
                        : l10n.verificationReviewRejectAction,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (!context.mounted || reviewResult == null || !reviewResult.confirmed) {
      return;
    }

    final controller = context.read<VerificationReviewController>();
    final result = status == VerificationRequestStatus.approved
        ? await controller.approveRequest(
            requestId: request.id,
            reviewedBy: reviewerUserId,
            reviewNote: reviewResult.note,
          )
        : await controller.rejectRequest(
            requestId: request.id,
            reviewedBy: reviewerUserId,
            reviewNote: reviewResult.note,
          );

    if (!context.mounted) return;

    final success = result != null;
    final message = success
        ? (status == VerificationRequestStatus.approved
            ? l10n.verificationReviewApprovedSuccess
            : l10n.verificationReviewRejectedSuccess)
        : (controller.errorMessage ?? l10n.verificationReviewOperationFailure);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  IconData _actorIcon(ActorType value) {
    switch (value) {
      case ActorType.citizen:
        return Icons.person_outline;
      case ActorType.publicOfficial:
        return Icons.badge_outlined;
      case ActorType.institution:
        return Icons.account_balance_outlined;
      case ActorType.organization:
        return Icons.corporate_fare_outlined;
    }
  }

  String _formatRequestType(
    AppLocalizations l10n,
    VerificationRequestType value,
  ) {
    switch (value) {
      case VerificationRequestType.citizenLevel1:
        return l10n.verificationRequestPersonLevel1;
      case VerificationRequestType.citizenLevel2:
        return l10n.verificationRequestPersonLevel2;
      case VerificationRequestType.publicOfficial:
        return l10n.verificationRequestPublicOfficial;
      case VerificationRequestType.institution:
        return l10n.verificationRequestPublicInstitution;
      case VerificationRequestType.organization:
        return l10n.verificationRequestVerifiedOrganization;
    }
  }

  String _formatActorType(
    AppLocalizations l10n,
    ActorType value,
  ) {
    switch (value) {
      case ActorType.citizen:
        return l10n.identityActorTypePerson;
      case ActorType.publicOfficial:
        return l10n.identityActorTypePublicOfficial;
      case ActorType.institution:
        return l10n.identityActorTypePublicInstitution;
      case ActorType.organization:
        return l10n.identityActorTypeVerifiedOrganization;
    }
  }

  String _formatVerificationLevel(
    AppLocalizations l10n,
    VerificationLevel value,
  ) {
    switch (value) {
      case VerificationLevel.none:
        return l10n.identityVerificationNotVerified;
      case VerificationLevel.level1:
        return l10n.identityVerificationLevel1;
      case VerificationLevel.level2:
        return l10n.identityVerificationLevel2;
    }
  }

  String _formatInstitutionLevel(
    AppLocalizations l10n,
    InstitutionLevel value,
  ) {
    switch (value) {
      case InstitutionLevel.municipality:
        return l10n.identityInstitutionLevelMunicipality;
      case InstitutionLevel.province:
        return l10n.identityInstitutionLevelProvince;
      case InstitutionLevel.region:
        return l10n.identityInstitutionLevelRegion;
      case InstitutionLevel.ministry:
        return l10n.identityInstitutionLevelMinistry;
      case InstitutionLevel.government:
        return l10n.identityInstitutionLevelGovernment;
      case InstitutionLevel.publicAgency:
        return l10n.identityInstitutionLevelPublicAgency;
      case InstitutionLevel.otherPublicBody:
        return l10n.identityInstitutionLevelOtherPublicBody;
    }
  }

  String _formatDateTime(
    BuildContext context,
    DateTime value,
  ) {
    final local = value.toLocal();
    final materialLocalizations = MaterialLocalizations.of(context);
    final date = materialLocalizations.formatMediumDate(local);
    final time = materialLocalizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return '$date · $time';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: value,
            ),
          ],
        ),
      ),
    );
  }
}
