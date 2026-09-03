import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/features/profile/application/profile_controller.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/data/countries.dart' as data;
import 'package:sociale_vote/shared/widgets/content_directionality.dart';
import 'package:sociale_vote/shared/widgets/country_selector_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String? currentUserId = AppDI.instance.currentUserId;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.profileEditPageTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.profileLoginRequiredMessage,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    ProfileController? inheritedController;

    try {
      inheritedController = context.read<ProfileController>();
    } catch (_) {
      inheritedController = null;
    }

    if (inheritedController != null) {
      return _EditProfileView(currentUserId: currentUserId);
    }

    return ChangeNotifierProvider(
      create: (_) => ProfileController(
        getUserProfile: AppDI.instance.getUserProfile,
        updateUserProfile: AppDI.instance.updateUserProfile,
      )..loadProfile(currentUserId),
      child: _EditProfileView(currentUserId: currentUserId),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  final String currentUserId;

  const _EditProfileView({
    required this.currentUserId,
  });

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileSectionTitle extends StatelessWidget {
  final String title;

  const _EditProfileSectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _EditProfileErrorCard extends StatelessWidget {
  final String message;

  const _EditProfileErrorCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  bool _didInitForm = false;
  bool _isUploadingAvatar = false;

  String? _selectedCountryCode;
  String? _avatarUploadError;
  String? _displayNameError;
  String? _usernameError;
  String? _countryError;
  String? _cityError;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _displayNameController.addListener(_refreshEditableDirection);
    _bioController.addListener(_refreshEditableDirection);
    _cityController.addListener(_refreshEditableDirection);
  }

  void _refreshEditableDirection() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _displayNameController.removeListener(_refreshEditableDirection);
    _bioController.removeListener(_refreshEditableDirection);
    _cityController.removeListener(_refreshEditableDirection);
    _displayNameController.dispose();
    _usernameController.dispose();
    _avatarUrlController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        final profile = controller.profile;
        final theme = Theme.of(context);

        if (!_didInitForm && profile != null) {
          _didInitForm = true;
          _displayNameController.text = profile.displayName ?? '';
          _usernameController.text = profile.username ?? '';
          _avatarUrlController.text = profile.avatarUrl ?? '';
          _bioController.text = profile.bio ?? '';
          _selectedCountryCode = _normalizeCountryCode(profile.country);
          _cityController.text = profile.city ?? '';
        }

        final avatarUrl = _avatarUrlController.text.trim();
        final actionsDisabled = controller.isSaving || _isUploadingAvatar;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.profileEditPageTitle),
          ),
          body: controller.isLoading && profile == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (controller.errorMessage != null) ...[
                            _EditProfileErrorCard(
                              message: controller.errorMessage!,
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (_avatarUploadError != null) ...[
                            _EditProfileErrorCard(
                              message: _avatarUploadError!,
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (_locationError != null) ...[
                            _EditProfileErrorCard(
                              message: _locationError!,
                            ),
                            const SizedBox(height: 12),
                          ],
                          _EditProfileSectionTitle(
                            title: l10n.homeProfileButton,
                          ),
                          Card(
                            margin: EdgeInsets.zero,
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 38,
                                        backgroundImage: avatarUrl.isNotEmpty
                                            ? NetworkImage(avatarUrl)
                                            : null,
                                        child: avatarUrl.isEmpty
                                            ? const Icon(
                                                Icons.person,
                                                size: 38,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _displayNameController.text
                                                      .trim()
                                                      .isNotEmpty
                                                  ? _displayNameController.text
                                                      .trim()
                                                  : l10n
                                                      .profileDisplayNameLabel,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            OutlinedButton.icon(
                                              onPressed: actionsDisabled
                                                  ? null
                                                  : _uploadAvatar,
                                              icon: _isUploadingAvatar
                                                  ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.upload_outlined,
                                                    ),
                                              label: Text(
                                                _isUploadingAvatar
                                                    ? l10n
                                                        .profileAvatarUploading
                                                    : l10n
                                                        .profileUploadAvatarButton,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: _displayNameController,
                                    textDirection: socialVoteEditableTextDirection(
                                      context,
                                      _displayNameController.text,
                                    ),
                                    textAlign: socialVoteEditableTextAlign(
                                      context,
                                      _displayNameController.text,
                                    ),
                                    textInputAction: TextInputAction.next,
                                    onChanged: (_) {
                                      if (_displayNameError == null) return;
                                      setState(() {
                                        _displayNameError = null;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: l10n.profileDisplayNameLabel,
                                      errorText: _displayNameError,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  TextField(
                                    controller: _usernameController,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (_) {
                                      if (_usernameError == null) return;
                                      setState(() {
                                        _usernameError = null;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: l10n.authUsernameLabel,
                                      hintText: l10n.profileUsernameHint,
                                      helperText: l10n.profileUsernameHelper,
                                      errorText: _usernameError,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  TextField(
                                    controller: _bioController,
                                    textDirection: socialVoteEditableTextDirection(
                                      context,
                                      _bioController.text,
                                    ),
                                    textAlign: socialVoteEditableTextAlign(
                                      context,
                                      _bioController.text,
                                    ),
                                    minLines: 3,
                                    maxLines: 5,
                                    textInputAction: TextInputAction.newline,
                                    decoration: InputDecoration(
                                      labelText: l10n.profileBioLabel,
                                      alignLabelWithHint: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _EditProfileSectionTitle(
                            title: l10n.authCountryOfResidenceLabel,
                          ),
                          Card(
                            margin: EdgeInsets.zero,
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  CountrySelectorField(
                                    key: ValueKey(
                                      'edit-profile-country-'
                                      '${_selectedCountryCode ?? 'none'}',
                                    ),
                                    selectedCountryCode: _selectedCountryCode,
                                    label: l10n.authCountryOfResidenceLabel,
                                    required: true,
                                    onCountrySelected: (code) {
                                      final normalizedCountryCode =
                                          _normalizeCountryCode(code);
                                      final countryChanged =
                                          normalizedCountryCode !=
                                              _selectedCountryCode;

                                      setState(() {
                                        _selectedCountryCode =
                                            normalizedCountryCode;
                                        if (countryChanged) {
                                          _cityController.clear();
                                          _cityError = null;
                                        }
                                        _countryError = null;
                                        _locationError = null;
                                      });
                                    },
                                  ),
                                  if (_countryError != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      _countryError!,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  ],
                                  if (_selectedCountryCode != null &&
                                      _selectedCountryCode!
                                          .trim()
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextButton.icon(
                                        onPressed: actionsDisabled
                                            ? null
                                            : () {
                                                setState(() {
                                                  _selectedCountryCode = null;
                                                  _cityController.clear();
                                                  _countryError = null;
                                                  _cityError = null;
                                                  _locationError = null;
                                                });
                                              },
                                        icon: const Icon(
                                          Icons.clear,
                                          size: 18,
                                        ),
                                        label: Text(
                                          l10n.profileClearCountryButton,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _cityController,
                                    textDirection: socialVoteEditableTextDirection(
                                      context,
                                      _cityController.text,
                                    ),
                                    textAlign: socialVoteEditableTextAlign(
                                      context,
                                      _cityController.text,
                                    ),
                                    textInputAction: TextInputAction.done,
                                    onChanged: (_) {
                                      if (_cityError == null &&
                                          _locationError == null) {
                                        return;
                                      }
                                      setState(() {
                                        _cityError = null;
                                        _locationError = null;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: l10n.authCityOfResidenceLabel,
                                      helperText:
                                          l10n.profileCityResidenceHelper,
                                      errorText: _cityError,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 50,
                            child: FilledButton(
                              onPressed: actionsDisabled
                                  ? null
                                  : () async {
                                      controller.clearError();
                                      setState(() {
                                        _avatarUploadError = null;
                                        _displayNameError = null;
                                        _usernameError = null;
                                        _countryError = null;
                                        _cityError = null;
                                        _locationError = null;
                                      });

                                      final normalizedDisplayName =
                                          _normalizeNullable(
                                        _displayNameController.text,
                                      );
                                      final normalizedUsername =
                                          _normalizeUsernameInput(
                                        _usernameController.text,
                                      );
                                      final normalizedCountryCode =
                                          _normalizeCountryCode(
                                        _selectedCountryCode,
                                      );
                                      final normalizedCityInput =
                                          _normalizeNullable(
                                        _cityController.text,
                                      );

                                      bool hasValidationError = false;

                                      if (normalizedDisplayName == null) {
                                        _displayNameError = l10n
                                            .profileDisplayNameRequiredError;
                                        hasValidationError = true;
                                      }

                                      final usernameValidationError =
                                          _validateUsername(
                                        normalizedUsername,
                                        l10n,
                                      );

                                      if (usernameValidationError != null) {
                                        _usernameError =
                                            usernameValidationError;
                                        hasValidationError = true;
                                      }

                                      if (normalizedCountryCode == null) {
                                        _countryError =
                                            l10n.authCountryRequiredError;
                                        hasValidationError = true;
                                      }

                                      if (hasValidationError) {
                                        setState(() {});
                                        return;
                                      }

                                      String? effectiveCountry =
                                          normalizedCountryCode;
                                      String? effectiveCity =
                                          normalizedCityInput;

                                      if (normalizedCityInput != null) {
                                        try {
                                          final resolved = await AppDI
                                              .instance.geocodingRepository
                                              .geocodeContentLocation(
                                            ContentLocation(
                                              source:
                                                  ContentLocationSource.manual,
                                              countryCode:
                                                  normalizedCountryCode,
                                              cityName: normalizedCityInput,
                                            ),
                                          );

                                          if (resolved == null) {
                                            setState(() {
                                              _cityError =
                                                  l10n.profileCityNotFoundError;
                                            });
                                            return;
                                          }

                                          effectiveCountry =
                                              _normalizeCountryCode(
                                            resolved.countryCode ??
                                                normalizedCountryCode,
                                          );

                                          effectiveCity = _normalizeNullable(
                                            resolved.cityName ??
                                                normalizedCityInput,
                                          );
                                        } catch (_) {
                                          setState(() {
                                            _locationError = l10n
                                                .profileCityVerificationError;
                                          });
                                          return;
                                        }
                                      }

                                      await controller.updateProfile(
                                        userId: widget.currentUserId,
                                        displayName: normalizedDisplayName,
                                        username: normalizedUsername,
                                        avatarUrl: _normalizeNullable(
                                          _avatarUrlController.text,
                                        ),
                                        bio: _normalizeNullable(
                                          _bioController.text,
                                        ),
                                        country: effectiveCountry,
                                        city: effectiveCity ?? '',
                                      );

                                      if (!context.mounted) return;

                                      if (controller.errorMessage == null) {
                                        Navigator.of(context).pop(true);
                                      }
                                    },
                              child: controller.isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(l10n.commonSaveButton),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Future<void> _uploadAvatar() async {
    final uploadErrorMessage =
        AppLocalizations.of(context)!.profileAvatarUploadError;

    setState(() {
      _avatarUploadError = null;
    });

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      setState(() {
        _isUploadingAvatar = true;
      });

      final Uint8List bytes = await pickedFile.readAsBytes();
      final String path = '${widget.currentUserId}/avatar.jpg';

      await Supabase.instance.client.storage.from('avatars').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final String publicUrl =
          Supabase.instance.client.storage.from('avatars').getPublicUrl(path);

      if (!mounted) return;

      setState(() {
        _avatarUrlController.text = publicUrl;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _avatarUploadError = uploadErrorMessage;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  String? _normalizeNullable(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String? _normalizeCountryCode(String? value) {
    final normalized = _normalizeNullable(value ?? '');
    if (normalized == null) {
      return null;
    }

    final upper = normalized.toUpperCase();

    for (final country in data.Countries.all) {
      if (country.code.toUpperCase() == upper) {
        return country.code.toUpperCase();
      }
    }

    final lower = normalized.toLowerCase();

    for (final country in data.Countries.all) {
      if (country.name.toLowerCase() == lower) {
        return country.code.toUpperCase();
      }
    }

    return null;
  }

  String? _normalizeUsernameInput(String value) {
    var normalized = value.trim().toLowerCase();
    if (normalized.startsWith('@')) {
      normalized = normalized.substring(1);
    }
    return normalized.isEmpty ? null : normalized;
  }

  String? _validateUsername(
    String? username,
    AppLocalizations l10n,
  ) {
    if (username == null) {
      return l10n.authUsernameRequiredError;
    }

    final regex = RegExp(r'^[a-z0-9_]{3,20}$');
    if (!regex.hasMatch(username)) {
      return l10n.authUsernameInvalidError;
    }

    return null;
  }
}
