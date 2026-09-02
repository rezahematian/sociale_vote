import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sociale_vote/domain/organization/entities/organization_models.dart';
import 'package:sociale_vote/features/organization/application/organization_workspace_controller.dart';
import 'package:sociale_vote/features/organization/presentation/widgets/organization_cover_header.dart';
import 'package:sociale_vote/features/organization/presentation/widgets/organization_external_channel_icon.dart';
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
  final _youtube = TextEditingController();
  final _linkedin = TextEditingController();
  final _whatsapp = TextEditingController();
  final _instagram = TextEditingController();
  final _telegram = TextEditingController();
  OrganizationEntityType _type = OrganizationEntityType.other;
  bool _uploadingCover = false;
  bool _uploadingLogo = false;

  @override
  void initState() {
    super.initState();
    _fillFromCurrentOrganization();
  }

  void _fillFromCurrentOrganization() {
    final contextData = widget.controller.context;
    if (contextData == null) {
      return;
    }

    final org = contextData.organization;
    _legalName.text = org.legalName;
    _publicName.text = org.publicName;
    _country.text = org.countryCode ?? '';
    _city.text = org.city ?? '';
    _website.text = org.websiteUrl ?? '';
    _description.text = org.description ?? '';
    _type = org.entityType;

    for (final link in widget.controller.externalLinks) {
      _externalController(link.provider).text = link.canonicalUrl;
    }
  }

  @override
  void dispose() {
    _legalName.dispose();
    _publicName.dispose();
    _country.dispose();
    _city.dispose();
    _website.dispose();
    _description.dispose();
    _youtube.dispose();
    _linkedin.dispose();
    _whatsapp.dispose();
    _instagram.dispose();
    _telegram.dispose();
    super.dispose();
  }

  Future<void> _upload({required bool cover}) async {
    final contextData = widget.controller.context;
    if (contextData == null) {
      return;
    }

    final org = contextData.organization;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: cover ? 2400.0 : 1000.0,
    );
    if (picked == null || !mounted) {
      return;
    }

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
      if (!mounted) {
        return;
      }

      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.organizationMediaUpdated,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
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

    final externalLinks = <OrganizationExternalLinkProvider, String?>{};
    for (final provider in OrganizationExternalLinkProvider.values) {
      final raw = _externalController(provider).text;
      try {
        externalLinks[provider] = provider.normalizeUrl(raw);
      } on FormatException {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tr(
                context,
                it: 'Controlla il link ${provider.label}: deve essere un URL HTTPS ufficiale.',
                en: 'Check the ${provider.label} link: it must be an official HTTPS URL.',
                de: 'Prüfe den ${provider.label}-Link: Er muss eine offizielle HTTPS-URL sein.',
                fa: 'پیوند ${provider.label} را بررسی کنید: باید نشانی رسمی HTTPS باشد.',
              ),
            ),
          ),
        );
        return;
      }
    }

    try {
      await widget.controller.replaceExternalLinks(externalLinks);
      await widget.controller.updateProfile(
        entityType: _type,
        legalName: _legalName.text,
        publicName: _publicName.text,
        countryCode: _country.text,
        city: _city.text,
        websiteUrl: _website.text,
        description: _description.text,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  TextEditingController _externalController(
    OrganizationExternalLinkProvider provider,
  ) {
    return switch (provider) {
      OrganizationExternalLinkProvider.youtube => _youtube,
      OrganizationExternalLinkProvider.linkedin => _linkedin,
      OrganizationExternalLinkProvider.whatsapp => _whatsapp,
      OrganizationExternalLinkProvider.instagram => _instagram,
      OrganizationExternalLinkProvider.telegram => _telegram,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contextData = widget.controller.context;

    if (contextData == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.organizationProfileEditorTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.organizationRequiresVerificationBody),
          ),
        ),
      );
    }

    final saving = widget.controller.isSaving;
    final organization = contextData.organization;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.organizationProfileEditorTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OrganizationCoverHeader(
                    organization: organization,
                    verifiedLabel: l10n.organizationVerifiedLabel,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _uploadingCover
                              ? null
                              : () => _upload(cover: true),
                          icon: _uploadingCover
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.image_outlined),
                          label: Text(l10n.organizationUploadCover),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _uploadingLogo
                              ? null
                              : () => _upload(cover: false),
                          icon: _uploadingLogo
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
                            child: Text(
                              l10n.organizationVerifiedIdentityLocked,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<OrganizationEntityType>(
                    initialValue: _type,
                    decoration: InputDecoration(
                      labelText: l10n.organizationType,
                    ),
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
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() => _type = value);
                          },
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
                        decoration: InputDecoration(
                          labelText: l10n.organizationCity,
                        ),
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
                    decoration: InputDecoration(
                      labelText: l10n.organizationWebsite,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.hub_outlined),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _tr(
                                    context,
                                    it: 'Canali ufficiali',
                                    en: 'Official channels',
                                    de: 'Offizielle Kanäle',
                                    fa: 'کانال‌های رسمی',
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _tr(
                              context,
                              it: 'Aggiungi solo profili dell’Organization. Questi link non assegnano automaticamente verifica o accesso Workspace.',
                              en: 'Add only organization profiles. These links never grant verification or Workspace access automatically.',
                              de: 'Füge nur Profile der Organisation hinzu. Diese Links gewähren niemals automatisch Verifizierung oder Workspace-Zugriff.',
                              fa: 'فقط پروفایل‌های سازمان را اضافه کنید. این پیوندها به‌طور خودکار تأیید یا دسترسی Workspace نمی‌دهند.',
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 14),
                          ...OrganizationExternalLinkProvider.values.map(
                            (provider) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TextField(
                                controller: _externalController(provider),
                                keyboardType: TextInputType.url,
                                autocorrect: false,
                                enableSuggestions: false,
                                decoration: InputDecoration(
                                  labelText: provider.label,
                                  hintText: _externalHint(provider),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: OrganizationExternalChannelIcon(
                                      provider: provider,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _description,
                    minLines: 4,
                    maxLines: 8,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.organizationDescription,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
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
                ],
              ),
            ),
          ),
        ],
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

  String _externalHint(OrganizationExternalLinkProvider provider) {
    return switch (provider) {
      OrganizationExternalLinkProvider.youtube =>
        'https://www.youtube.com/@socialvote',
      OrganizationExternalLinkProvider.linkedin =>
        'https://www.linkedin.com/company/social-vote',
      OrganizationExternalLinkProvider.whatsapp => 'https://wa.me/…',
      OrganizationExternalLinkProvider.instagram =>
        'https://www.instagram.com/socialvote',
      OrganizationExternalLinkProvider.telegram => 'https://t.me/socialvote',
    };
  }

}

String _tr(
  BuildContext context, {
  required String it,
  required String en,
  required String de,
  required String fa,
}) {
  return switch (Localizations.localeOf(context).languageCode) {
    'it' => it,
    'de' => de,
    'fa' => fa,
    _ => en,
  };
}
