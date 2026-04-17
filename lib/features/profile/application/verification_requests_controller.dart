import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/identity/entities/verification_request.dart';
import 'package:sociale_vote/domain/identity/usecases/cancel_verification_request.dart';
import 'package:sociale_vote/domain/identity/usecases/create_verification_request.dart';
import 'package:sociale_vote/domain/identity/usecases/get_pending_verification_request.dart';
import 'package:sociale_vote/domain/identity/usecases/get_verification_requests_for_user.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';

class VerificationRequestsController extends ChangeNotifier {
  final CreateVerificationRequest _createVerificationRequest;
  final GetPendingVerificationRequest _getPendingVerificationRequest;
  final GetVerificationRequestsForUser _getVerificationRequestsForUser;
  final CancelVerificationRequest _cancelVerificationRequest;

  VerificationRequestsController({
    required CreateVerificationRequest createVerificationRequest,
    required GetPendingVerificationRequest getPendingVerificationRequest,
    required GetVerificationRequestsForUser getVerificationRequestsForUser,
    required CancelVerificationRequest cancelVerificationRequest,
  })  : _createVerificationRequest = createVerificationRequest,
        _getPendingVerificationRequest = getPendingVerificationRequest,
        _getVerificationRequestsForUser = getVerificationRequestsForUser,
        _cancelVerificationRequest = cancelVerificationRequest;

  VerificationRequest? _pendingRequest;
  List<VerificationRequest> _requests = const [];

  bool _isLoading = false;
  bool _isCreating = false;
  bool _isCancelling = false;

  String? _errorMessage;
  Future<void>? _activeLoadFuture;

  VerificationRequest? get pendingRequest => _pendingRequest;
  List<VerificationRequest> get requests => _requests;

  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isCancelling => _isCancelling;

  bool get hasPendingRequest => _pendingRequest != null;
  String? get errorMessage => _errorMessage;

  VerificationRequest? get latestRequest {
    if (_requests.isEmpty) {
      return null;
    }
    return _requests.first;
  }

  VerificationRequest? get latestResolvedRequest {
    final pendingId = _pendingRequest?.id;
    for (final request in _requests) {
      if (request.id != pendingId) {
        return request;
      }
    }
    return null;
  }

  Future<void> load(String userId) {
    final activeLoad = _activeLoadFuture;
    if (activeLoad != null) {
      return activeLoad;
    }

    final future = _runLoad(
      userId,
      showLoadingState: true,
    );

    _activeLoadFuture = future;

    return future.whenComplete(() {
      if (identical(_activeLoadFuture, future)) {
        _activeLoadFuture = null;
      }
    });
  }

  Future<void> _refreshAfterMutation(String userId) async {
    final activeLoad = _activeLoadFuture;
    if (activeLoad != null) {
      await activeLoad;
    }

    await _runLoad(
      userId,
      showLoadingState: false,
    );
  }

  Future<void> _runLoad(
    String userId, {
    required bool showLoadingState,
  }) async {
    if (showLoadingState) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait<dynamic>([
        _getPendingVerificationRequest.call(userId),
        _getVerificationRequestsForUser.call(userId),
      ]);

      _pendingRequest = results[0] as VerificationRequest?;
      _requests = (results[1] as List<VerificationRequest>).toList(
        growable: false,
      );
    } catch (_) {
      _errorMessage = 'Impossibile caricare le richieste di verifica.';
    } finally {
      if (showLoadingState) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<bool> createRequest({
    required String userId,
    required VerificationRequestType requestType,
    String? officialTitle,
    String? institutionName,
    InstitutionLevel? targetInstitutionLevel,
  }) async {
    if (_isCreating) return false;

    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _createVerificationRequest.call(
        userId: userId,
        requestType: requestType,
        officialTitle: officialTitle,
        institutionName: institutionName,
        targetInstitutionLevel: targetInstitutionLevel,
      );

      await _refreshAfterMutation(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<bool> cancelPendingRequest(String userId) async {
    final request = _pendingRequest;
    if (request == null || _isCancelling) {
      return false;
    }

    _isCancelling = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _cancelVerificationRequest.call(requestId: request.id);
      await _refreshAfterMutation(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isCancelling = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}