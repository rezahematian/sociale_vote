import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/organization/entities/organization_models.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/widgets/content_directionality.dart';
import 'package:sociale_vote/shared/widgets/country_selector_field.dart';

class OrganizationVerificationRequestDraft {
  final String legalName;
  final String publicName;
  final OrganizationEntityType entityType;
  final String countryCode;
  final String? city;
  final String? websiteUrl;
  final String representativeRole;
  final String? registryId;
  final String authorityNote;

  const OrganizationVerificationRequestDraft({
    required this.legalName,
    required this.publicName,
    required this.entityType,
    required this.countryCode,
    required this.city,
    required this.websiteUrl,
    required this.representativeRole,
    required this.registryId,
    required this.authorityNote,
  });
}

class OrganizationVerificationRequestPage extends StatefulWidget {
  const OrganizationVerificationRequestPage({super.key});

  @override
  State<OrganizationVerificationRequestPage> createState() =>
      _OrganizationVerificationRequestPageState();
}

class _OrganizationVerificationRequestPageState
    extends State<OrganizationVerificationRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _legalName = TextEditingController();
  final _publicName = TextEditingController();
  final _city = TextEditingController();
  final _website = TextEditingController();
  final _representativeRole = TextEditingController();
  final _registryId = TextEditingController();
  final _authorityNote = TextEditingController();

  OrganizationEntityType _entityType = OrganizationEntityType.association;
  String? _countryCode;

  @override
  void initState() {
    super.initState();
    for (final controller in <TextEditingController>[
      _legalName,
      _publicName,
      _city,
      _representativeRole,
      _authorityNote,
    ]) {
      controller.addListener(_refreshEditableDirection);
    }
  }

  void _refreshEditableDirection() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _legalName,
      _publicName,
      _city,
      _representativeRole,
      _authorityNote,
    ]) {
      controller.removeListener(_refreshEditableDirection);
    }
    _legalName.dispose();
    _publicName.dispose();
    _city.dispose();
    _website.dispose();
    _representativeRole.dispose();
    _registryId.dispose();
    _authorityNote.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    return (value?.trim().isEmpty ?? true)
        ? AppLocalizations.of(context)!.organizationVerificationRequired
        : null;
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final country = _countryCode?.trim().toUpperCase();
    if (country == null || !RegExp(r'^[A-Z]{2}$').hasMatch(country)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.organizationVerificationCountryRequired)),
      );
      return;
    }

    Navigator.of(context).pop(
      OrganizationVerificationRequestDraft(
        legalName: _legalName.text.trim(),
        publicName: _publicName.text.trim(),
        entityType: _entityType,
        countryCode: country,
        city: _nullable(_city.text),
        websiteUrl: _nullable(_website.text),
        representativeRole: _representativeRole.text.trim(),
        registryId: _nullable(_registryId.text),
        authorityNote: _authorityNote.text.trim(),
      ),
    );
  }

  String? _nullable(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  TextDirection _directionFor(TextEditingController controller) {
    return socialVoteEditableTextDirection(context, controller.text);
  }

  TextAlign _alignFor(TextEditingController controller) {
    return socialVoteEditableTextAlign(context, controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.verificationOrganizationDialogTitle)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.verified_user_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(l10n.organizationVerificationIntro),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _legalName,
                  textDirection: _directionFor(_legalName),
                  textAlign: _alignFor(_legalName),
                  textCapitalization: TextCapitalization.words,
                  validator: _required,
                  decoration: InputDecoration(
                    labelText: '${l10n.organizationVerificationLegalName} *',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _publicName,
                  textDirection: _directionFor(_publicName),
                  textAlign: _alignFor(_publicName),
                  textCapitalization: TextCapitalization.words,
                  validator: _required,
                  decoration: InputDecoration(
                    labelText: '${l10n.organizationVerificationPublicName} *',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<OrganizationEntityType>(
                  initialValue: _entityType,
                  decoration: InputDecoration(
                    labelText: '${l10n.organizationVerificationType} *',
                  ),
                  items: OrganizationEntityType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_typeLabel(l10n, type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _entityType = value);
                  },
                ),
                const SizedBox(height: 12),
                CountrySelectorField(
                  selectedCountryCode: _countryCode,
                  required: true,
                  label: l10n.organizationVerificationCountry,
                  onCountrySelected: (value) {
                    setState(() => _countryCode = value.trim().toUpperCase());
                  },
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 620;
                    final city = TextFormField(
                      controller: _city,
                      textDirection: _directionFor(_city),
                      textAlign: _alignFor(_city),
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.organizationVerificationCity,
                      ),
                    );
                    final website = TextFormField(
                      controller: _website,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: l10n.organizationVerificationWebsite,
                      ),
                    );
                    if (!wide) {
                      return Column(
                        children: [city, const SizedBox(height: 12), website],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: city),
                        const SizedBox(width: 12),
                        Expanded(child: website),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _representativeRole,
                  textDirection: _directionFor(_representativeRole),
                  textAlign: _alignFor(_representativeRole),
                  textCapitalization: TextCapitalization.words,
                  validator: _required,
                  decoration: InputDecoration(
                    labelText:
                        '${l10n.organizationVerificationRepresentativeRole} *',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _registryId,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    labelText: l10n.organizationVerificationRegistryId,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _authorityNote,
                  textDirection: _directionFor(_authorityNote),
                  textAlign: _alignFor(_authorityNote),
                  minLines: 3,
                  maxLines: 6,
                  validator: _required,
                  decoration: InputDecoration(
                    labelText:
                        '${l10n.organizationVerificationAuthorityNote} *',
                    helperText: l10n.organizationVerificationAuthorityHelper,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send_outlined),
                  label: Text(l10n.verificationSubmitRequestAction),
                ),
              ],
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
