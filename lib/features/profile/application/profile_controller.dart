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

  bool _isDisposed = false;
  int _profileOperationId = 0;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get hasProfile => _profile != null;

  Future<void> loadProfile(String userId) async {
    if (_isLoading || _isDisposed) return;

    final operationId = ++_profileOperationId;

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final loadedProfile = await _getUserProfile(userId);

      if (_isOperationCurrent(operationId)) {
        _profile = loadedProfile;
      }
    } catch (e) {
      if (_isOperationCurrent(operationId)) {
        _errorMessage = 'Impossibile caricare il profilo.';
      }
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
    String? country,
    String? city,
  }) async {
    if (_isSaving || _isDisposed) return;

    final operationId = ++_profileOperationId;

    _isSaving = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final updatedProfile = await _updateUserProfile(
        userId: userId,
        displayName: displayName,
        username: username,
        avatarUrl: avatarUrl,
        bio: bio,
        country: country,
        city: city,
      );

      if (_isOperationCurrent(operationId)) {
        _profile = updatedProfile;
      }
    } catch (e) {
      if (_isOperationCurrent(operationId)) {
        _errorMessage = 'Impossibile aggiornare il profilo.';
      }
    } finally {
      if (!_isDisposed) {
        _isSaving = false;
        _safeNotifyListeners();
      }
    }
  }

  void clearError() {
    if (_errorMessage == null || _isDisposed) return;
    _errorMessage = null;
    _safeNotifyListeners();
  }

  bool _isOperationCurrent(int operationId) {
    return !_isDisposed && operationId == _profileOperationId;
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _profileOperationId++;
    super.dispose();
  }
}
