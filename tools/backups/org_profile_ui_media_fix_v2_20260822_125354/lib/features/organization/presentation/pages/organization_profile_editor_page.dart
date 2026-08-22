import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sociale_vote/domain/organization/entities/organization_models.dart';
import 'package:sociale_vote/features/organization/application/organization_workspace_controller.dart';
import 'package:sociale_vote/features/organization/presentation/widgets/organization_cover_header.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class OrganizationProfileEditorPage extends StatefulWidget {
  final OrganizationWorkspaceController controller;

  const OrganizationProfileEditorPage({
    super.key,
    required this.controller,
  });

  @override
  State<OrganizationProfileEditorPage> createState() =>
      _OrganizationProfileEditorPageState();
}

class _OrganizationProfileEditorPageState
    extends State<OrganizationProfileEditorPage> {
  final _legalName = TextEditingController();
  final _publicName = TextEditingController();
  final _country = TextEditingController();
  final _city = TextEditingController();
  final _website = TextEditingController();
  final _description = TextEditingController();
  OrganizationEntityType _type = OrganizationEntityType.other;
  bool _uploadingCover = false;
  bool _uploadingLogo = false;

  @override
  void initState() {
    super.initState();
    final org = widget.controller.context!.organization;
    _legalName.text = org.legalName;
    _publicName.text = org.publicName;
    _country.text = org.countryCode ?? '';
    _city.text = org.city ?? '';
    _website.text = org.websiteUrl ?? '';
    _description.text = org.description ?? '';
    _type = org.entityType;
  }

  @override
  void dispose() {
    _legalName.dispose();
    _publicName.dispose();
    _country.dispose();
    _city.dispose();
    _website.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _upload({required bool cover}) async {
    final org = widget.controller.context!.organization;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: cover ? 2400.0 : 1000.0,
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (cover) {
        _uploadingCover = true;
      } else {
        _uploadingLogo = true;
      }
    });

    try {
      final bytes = await picked.readAsBytes();
      await widget.controller.repository.uploadOrganizationMedia(
        organizationId: org.id,
        bytes: bytes,
        fileName: picked.name,
        isCover: cover,
      );
      await widget.controller.load(bootstrapIfNeeded: false);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.organizationMediaUpdated,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingCover = false;
          _uploadingLogo = false;
        });
      }
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_legalName.text.trim().isEmpty || _publicName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.organizationNamesRequired)),
      );
      return;
    }

    try {
      await widget.controller.updateProfile(
        entityType: _type,
        legalName: _legalName.text,
        publicName: _publicName.text,
        countryCode: _country.text,
        city: _city.text,
        websiteUrl: _website.text,
        description: _description.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final saving = widget.controller.isSaving;
    final organization = widget.controller.context!.organization;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.organizationProfileEditorTitle)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              OrganizationCoverHeader(
                key: ValueKey(
                  '${organization.coverUrl}|${organization.logoUrl}',
                ),
                organization: organization,
                verifiedLabel: l10n.organizationVerifiedLabel,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _uploadingCover ? null : () => _upload(cover: true),
                      icon: _uploadingCover
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.image_outlined),
                      label: Text(l10n.organizationUploadCover),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _uploadingLogo ? null : () => _upload(cover: false),
                      icon: _uploadingLogo
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.account_circle_outlined),
                      label: Text(l10n.organizationUploadLogo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_user_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(l10n.organizationVerifiedIdentityLocked),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<OrganizationEntityType>(
                initialValue: _type,
                decoration: InputDecoration(labelText: l10n.organizationType),
                items: OrganizationEntityType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_typeLabel(l10n, type)),
                      ),
                    )
                    .toList(),
                onChanged: saving
                    ? null
                    : (value) => setState(() => _type = value ?? _type),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _legalName,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.organizationLegalName,
                  suffixIcon: const Icon(Icons.lock_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _publicName,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.organizationPublicName,
                  suffixIcon: const Icon(Icons.lock_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 620;
                  final country = TextField(
                    controller: _country,
                    readOnly: true,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 2,
                    decoration: InputDecoration(
                      labelText: l10n.organizationCountryCode,
                      counterText: '',
                      suffixIcon: const Icon(Icons.lock_outline_rounded),
                    ),
                  );
                  final city = TextField(
                    controller: _city,
                    textCapitalization: TextCapitalization.words,
                    decoration:
                        InputDecoration(labelText: l10n.organizationCity),
                  );

                  if (!wide) {
                    return Column(
                      children: [
                        country,
                        const SizedBox(height: 12),
                        city,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: country),
                      const SizedBox(width: 12),
                      Expanded(child: city),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _website,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration:
                    InputDecoration(labelText: l10n.organizationWebsite),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _description,
                minLines: 4,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration:
                    InputDecoration(labelText: l10n.organizationDescription),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.45),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: saving ? null : _save,
                    icon: saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(l10n.commonSaveButton),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _typeLabel(AppLocalizations l10n, OrganizationEntityType type) {
    return switch (type) {
      OrganizationEntityType.association => l10n.organizationTypeAssociation,
      OrganizationEntityType.nonprofit => l10n.organizationTypeNonprofit,
      OrganizationEntityType.company => l10n.organizationTypeCompany,
      OrganizationEntityType.cooperative => l10n.organizationTypeCooperative,
      OrganizationEntityType.sports => l10n.organizationTypeSports,
      OrganizationEntityType.publicBody => l10n.organizationTypePublicBody,
      OrganizationEntityType.committee => l10n.organizationTypeCommittee,
      OrganizationEntityType.other => l10n.organizationTypeOther,
    };
  }
}
