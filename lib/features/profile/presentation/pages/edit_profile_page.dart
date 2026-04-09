import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/features/profile/application/profile_controller.dart';
import 'package:sociale_vote/shared/data/countries.dart' as data;
import 'package:sociale_vote/shared/widgets/country_selector_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = AppDI.instance.currentUserId;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'You must be logged in to edit your profile.',
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
  String? _usernameError;
  String? _locationError;

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _avatarUrlController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        final profile = controller.profile;

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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
          ),
          body: controller.isLoading && profile == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (controller.errorMessage != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            controller.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_avatarUploadError != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _avatarUploadError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_locationError != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _locationError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl.isEmpty
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _isUploadingAvatar || controller.isSaving
                                ? null
                                : _uploadAvatar,
                            icon: _isUploadingAvatar
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload_outlined),
                            label: Text(
                              _isUploadingAvatar
                                  ? 'Uploading...'
                                  : 'Upload Avatar',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _displayNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                        labelText: 'Username',
                        hintText: 'es. mario_roma',
                        helperText: '3-20 caratteri: lettere, numeri, underscore',
                        errorText: _usernameError,
                        prefixText: '@',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _avatarUrlController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Avatar URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bioController,
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CountrySelectorField(
                      selectedCountryCode: _selectedCountryCode,
                      label: 'Country',
                      onCountrySelected: (code) {
                        setState(() {
                          _selectedCountryCode = _normalizeCountryCode(code);
                          _locationError = null;
                        });
                      },
                    ),
                    if (_selectedCountryCode != null &&
                        _selectedCountryCode!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: controller.isSaving || _isUploadingAvatar
                              ? null
                              : () {
                                  setState(() {
                                    _selectedCountryCode = null;
                                    _locationError = null;
                                  });
                                },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear country'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cityController,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) {
                        if (_locationError == null) return;
                        setState(() {
                          _locationError = null;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'City',
                        helperText:
                            'City is validated against the selected country before save.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: controller.isSaving || _isUploadingAvatar
                          ? null
                          : () async {
                              controller.clearError();
                              setState(() {
                                _avatarUploadError = null;
                                _usernameError = null;
                                _locationError = null;
                              });

                              final normalizedUsername =
                                  _normalizeUsernameInput(
                                _usernameController.text,
                              );

                              final usernameValidationError =
                                  _validateUsername(normalizedUsername);

                              if (usernameValidationError != null) {
                                setState(() {
                                  _usernameError = usernameValidationError;
                                });
                                return;
                              }

                              final normalizedCountryCode =
                                  _normalizeCountryCode(_selectedCountryCode);
                              final normalizedCityInput = _normalizeNullable(
                                _cityController.text,
                              );

                              if (normalizedCityInput != null &&
                                  normalizedCountryCode == null) {
                                setState(() {
                                  _locationError =
                                      'Seleziona prima un paese per validare la città.';
                                });
                                return;
                              }

                              String? effectiveCountry = normalizedCountryCode;
                              String? effectiveCity = normalizedCityInput;

                              if (normalizedCountryCode != null ||
                                  normalizedCityInput != null) {
                                try {
                                  final resolved = await AppDI
                                      .instance.geocodingRepository
                                      .geocodeContentLocation(
                                    ContentLocation(
                                      source:
                                          ContentLocationSource.geoScopeFallback,
                                      countryCode: normalizedCountryCode,
                                      cityName: normalizedCityInput,
                                    ),
                                  );

                                  if (normalizedCityInput != null &&
                                      resolved == null) {
                                    setState(() {
                                      _locationError =
                                          'Città non riconosciuta per il paese selezionato.';
                                    });
                                    return;
                                  }

                                  effectiveCountry = _normalizeCountryCode(
                                    resolved?.countryCode ?? normalizedCountryCode,
                                  );

                                  effectiveCity = _normalizeNullable(
                                    resolved?.cityName ??
                                        normalizedCityInput ??
                                        '',
                                  );
                                } catch (_) {
                                  if (normalizedCityInput != null) {
                                    setState(() {
                                      _locationError =
                                          'Impossibile verificare la città in questo momento.';
                                    });
                                    return;
                                  }
                                }
                              }

                              await controller.updateProfile(
                                userId: widget.currentUserId,
                                displayName: _normalizeNullable(
                                  _displayNameController.text,
                                ),
                                username: normalizedUsername,
                                avatarUrl: _normalizeNullable(
                                  _avatarUrlController.text,
                                ),
                                bio: _normalizeNullable(_bioController.text),
                                country: effectiveCountry,
                                city: effectiveCity,
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
                          : const Text('Save'),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _uploadAvatar() async {
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
        _avatarUploadError = 'Impossibile caricare l’avatar.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploadingAvatar = false;
      });
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

  String? _validateUsername(String? username) {
    if (username == null) {
      return null;
    }

    final regex = RegExp(r'^[a-z0-9_]{3,20}$');
    if (!regex.hasMatch(username)) {
      return 'Username non valido. Usa 3-20 caratteri: lettere, numeri, underscore.';
    }

    return null;
  }
}