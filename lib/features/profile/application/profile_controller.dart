import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/usecases/get_user_profile.dart';
import 'package:sociale_vote/domain/identity/usecases/update_user_profile.dart';

class ProfileController extends ChangeNotifier {
  final GetUserProfile _getUserProfile;
  final UpdateUserProfile _updateUserProfile;

  ProfileController({
    required GetUserProfile getUserProfile,
    required UpdateUserProfile updateUserProfile,
  })  : _getUserProfile = getUserProfile,
        _updateUserProfile = updateUserProfile;

  UserProfile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get hasProfile => _profile != null;

  Future<void> loadProfile(String userId) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _getUserProfile(userId);
    } catch (_) {
      _errorMessage = 'Impossibile caricare il profilo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? country,
    String? city,
  }) async {
    if (_isSaving) return;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _updateUserProfile(
        userId: userId,
        displayName: displayName,
        avatarUrl: avatarUrl,
        bio: bio,
        country: country,
        city: city,
      );
    } catch (_) {
      _errorMessage = 'Impossibile aggiornare il profilo.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}