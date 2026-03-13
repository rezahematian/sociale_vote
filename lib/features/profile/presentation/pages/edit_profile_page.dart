import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/features/profile/application/profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _displayNameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _bioController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();

  bool _didInit = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _avatarUrlController.dispose();
    _bioController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

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

    return ChangeNotifierProvider(
      create: (_) => ProfileController(
        getUserProfile: AppDI.instance.getUserProfile,
        updateUserProfile: AppDI.instance.updateUserProfile,
      )..loadProfile(currentUserId),
      child: Consumer<ProfileController>(
        builder: (context, controller, _) {
          final profile = controller.profile;

          if (!_didInit && profile != null) {
            _didInit = true;
            _displayNameController.text = profile.displayName ?? '';
            _avatarUrlController.text = profile.avatarUrl ?? '';
            _bioController.text = profile.bio ?? '';
            _countryController.text = profile.country ?? '';
            _cityController.text = profile.city ?? '';
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
            ),
            body: controller.isLoading
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
                      TextField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Display name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _avatarUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Avatar URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _countryController,
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: controller.isSaving
                            ? null
                            : () async {
                                await controller.updateProfile(
                                  userId: currentUserId,
                                  displayName:
                                      _displayNameController.text.trim(),
                                  avatarUrl:
                                      _avatarUrlController.text.trim(),
                                  bio: _bioController.text.trim(),
                                  country: _countryController.text.trim(),
                                  city: _cityController.text.trim(),
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
      ),
    );
  }
}