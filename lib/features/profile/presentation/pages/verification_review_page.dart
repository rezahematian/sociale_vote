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
import 'package:sociale_vote/shared/services/auth_guard.dart';

class VerificationReviewPage extends StatelessWidget {
  const VerificationReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reviewerUserId = AppDI.instance.currentUserId;

    if (reviewerUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Verification Review'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'You must be logged in to review verification requests.',
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
  State<_VerificationReviewGate> createState() => _VerificationReviewGateState();
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
    if (_isCheckingAccess) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Verification Review'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasAccess) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Verification Review'),
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
    final controller = context.watch<VerificationReviewController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Review'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context
            .read<VerificationReviewController>()
            .loadPendingRequests(),
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
                        'Pending requests: ${controller.pendingRequests.length}',
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
                        'No pending verification requests.',
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
                  icon: Icons.person_outline,
                  label: _formatRequestType(request.requestType),
                ),
                _InfoChip(
                  icon: Icons.shield_outlined,
                  label: _formatActorType(request.targetActorType),
                ),
                _InfoChip(
                  icon: Icons.verified_outlined,
                  label: _formatVerificationLevel(
                    request.targetVerificationLevel,
                  ),
                ),
                if (request.targetInstitutionLevel != null)
                  _InfoChip(
                    icon: Icons.account_balance_outlined,
                    label: _formatInstitutionLevel(
                      request.targetInstitutionLevel!,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'User ID',
              value: request.userId,
            ),
            _InfoRow(
              label: 'Submitted',
              value: _formatDateTime(request.submittedAt),
            ),
            if ((request.officialTitle ?? '').trim().isNotEmpty)
              _InfoRow(
                label: 'Official title',
                value: request.officialTitle!.trim(),
              ),
            if ((request.institutionName ?? '').trim().isNotEmpty)
              _InfoRow(
                label: 'Institution',
                value: request.institutionName!.trim(),
              ),
            if ((request.reviewNote ?? '').trim().isNotEmpty)
              _InfoRow(
                label: 'Review note',
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
                    label: const Text('Reject'),
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
                    label: const Text('Approve'),
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
    final noteController = TextEditingController();

    try {
      final note = await showDialog<String?>(
        context: context,
        builder: (dialogContext) {
          final isApprove = status == VerificationRequestStatus.approved;
          bool showValidationError = false;

          return StatefulBuilder(
            builder: (context, setLocalState) {
              final trimmedNote = noteController.text.trim();
              final noteIsRequired = !isApprove;
              final hasValidationError =
                  noteIsRequired && showValidationError && trimmedNote.isEmpty;

              return AlertDialog(
                title: Text(
                  isApprove ? 'Approve request' : 'Reject request',
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isApprove
                          ? 'Confermi approvazione della richiesta?'
                          : 'Confermi rifiuto della richiesta?',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      autofocus: !isApprove,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        labelText: isApprove
                            ? 'Review note opzionale'
                            : 'Reason / review note',
                        helperText: isApprove
                            ? 'Opzionale'
                            : 'Obbligatoria per reject',
                        errorText: hasValidationError
                            ? 'La review note è obbligatoria per reject.'
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) {
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
                    onPressed: () => Navigator.of(dialogContext).pop(null),
                    child: const Text('Annulla'),
                  ),
                  FilledButton(
                    onPressed: () {
                      final normalizedNote = noteController.text.trim();

                      if (!isApprove && normalizedNote.isEmpty) {
                        setLocalState(() {
                          showValidationError = true;
                        });
                        return;
                      }

                      Navigator.of(dialogContext).pop(
                        normalizedNote.isEmpty ? null : normalizedNote,
                      );
                    },
                    child: Text(isApprove ? 'Approve' : 'Reject'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (!context.mounted || note == null && status == VerificationRequestStatus.rejected && false) {
        return;
      }

      if (!context.mounted) return;

      final wasCancelled = note == null &&
          status == VerificationRequestStatus.rejected &&
          false;
      if (wasCancelled) {
        return;
      }

      if (note == null && status == VerificationRequestStatus.approved) {
        // ok: approve con nota opzionale vuota
      }

      if (note == null &&
          status == VerificationRequestStatus.rejected) {
        return;
      }

      final controller = context.read<VerificationReviewController>();

      final result = status == VerificationRequestStatus.approved
          ? await controller.approveRequest(
              requestId: request.id,
              reviewedBy: reviewerUserId,
              reviewNote: note,
            )
          : await controller.rejectRequest(
              requestId: request.id,
              reviewedBy: reviewerUserId,
              reviewNote: note,
            );

      if (!context.mounted) return;

      final success = result != null;
      final message = success
          ? (status == VerificationRequestStatus.approved
              ? 'Request approved.'
              : 'Request rejected.')
          : (controller.errorMessage ?? 'Operation failed.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      noteController.dispose();
    }
  }

  String _formatRequestType(VerificationRequestType value) {
    switch (value) {
      case VerificationRequestType.citizenLevel1:
        return 'Citizen Lv1';
      case VerificationRequestType.citizenLevel2:
        return 'Citizen Lv2';
      case VerificationRequestType.publicOfficial:
        return 'Public Official';
      case VerificationRequestType.institution:
        return 'Institution';
    }
  }

  String _formatActorType(ActorType value) {
    switch (value) {
      case ActorType.citizen:
        return 'Citizen';
      case ActorType.publicOfficial:
        return 'Public Official';
      case ActorType.institution:
        return 'Institution';
    }
  }

  String _formatVerificationLevel(VerificationLevel value) {
    switch (value) {
      case VerificationLevel.none:
        return 'Standard';
      case VerificationLevel.level1:
        return 'Verified Lv1';
      case VerificationLevel.level2:
        return 'Verified Lv2';
    }
  }

  String _formatInstitutionLevel(InstitutionLevel value) {
    switch (value) {
      case InstitutionLevel.municipality:
        return 'Municipality';
      case InstitutionLevel.province:
        return 'Province';
      case InstitutionLevel.region:
        return 'Region';
      case InstitutionLevel.ministry:
        return 'Ministry';
      case InstitutionLevel.government:
        return 'Government';
      case InstitutionLevel.publicAgency:
        return 'Public Agency';
      case InstitutionLevel.otherPublicBody:
        return 'Other Public Body';
    }
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
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
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.18),
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