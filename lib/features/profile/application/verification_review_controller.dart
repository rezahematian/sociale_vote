import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/identity/entities/verification_request.dart';
import 'package:sociale_vote/domain/identity/usecases/get_pending_verification_requests.dart';
import 'package:sociale_vote/domain/identity/usecases/review_verification_request_and_update_profile.dart';

class VerificationReviewController extends ChangeNotifier {
  final GetPendingVerificationRequests _getPendingVerificationRequests;
  final ReviewVerificationRequestAndUpdateProfile
      _reviewVerificationRequestAndUpdateProfile;

  VerificationReviewController({
    required GetPendingVerificationRequests getPendingVerificationRequests,
    required ReviewVerificationRequestAndUpdateProfile
        reviewVerificationRequestAndUpdateProfile,
  })  : _getPendingVerificationRequests = getPendingVerificationRequests,
        _reviewVerificationRequestAndUpdateProfile =
            reviewVerificationRequestAndUpdateProfile;

  List<VerificationRequest> _pendingRequests = const [];
  bool _isLoading = false;
  final Set<String> _processingRequestIds = <String>{};
  final Set<String> _resolvedRequestIds = <String>{};
  String? _errorMessage;

  bool _isDisposed = false;
  int _loadOperationId = 0;

  List<VerificationRequest> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPendingRequests => _pendingRequests.isNotEmpty;

  bool isProcessing(String requestId) {
    return _processingRequestIds.contains(requestId.trim());
  }

  Future<void> loadPendingRequests({
    int limit = 50,
    int offset = 0,
  }) async {
    if (_isLoading || _isDisposed) return;

    final operationId = ++_loadOperationId;

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final loadedRequests = await _getPendingVerificationRequests.call(
        limit: limit,
        offset: offset,
      );

      if (!_isLoadOperationCurrent(operationId)) {
        return;
      }

      _pendingRequests = loadedRequests
          .where(
            (request) =>
                !_processingRequestIds.contains(request.id) &&
                !_resolvedRequestIds.contains(request.id),
          )
          .toList(growable: false);
    } catch (_) {
      if (_isLoadOperationCurrent(operationId)) {
        _errorMessage = 'Impossibile caricare le richieste pending.';
      }
    } finally {
      if (_isLoadOperationCurrent(operationId)) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<VerificationRequest?> approveRequest({
    required String requestId,
    required String reviewedBy,
    String? reviewNote,
  }) {
    return _review(
      requestId: requestId,
      reviewedBy: reviewedBy,
      reviewNote: reviewNote,
      status: VerificationRequestStatus.approved,
    );
  }

  Future<VerificationRequest?> rejectRequest({
    required String requestId,
    required String reviewedBy,
    String? reviewNote,
  }) {
    return _review(
      requestId: requestId,
      reviewedBy: reviewedBy,
      reviewNote: reviewNote,
      status: VerificationRequestStatus.rejected,
    );
  }

  Future<VerificationRequest?> _review({
    required String requestId,
    required String reviewedBy,
    required VerificationRequestStatus status,
    String? reviewNote,
  }) async {
    if (_isDisposed) return null;

    final normalizedRequestId = requestId.trim();
    final normalizedReviewedBy = reviewedBy.trim();

    if (normalizedRequestId.isEmpty) {
      _errorMessage = 'Request id non valido.';
      _safeNotifyListeners();
      return null;
    }

    if (normalizedReviewedBy.isEmpty) {
      _errorMessage = 'Reviewed by non valido.';
      _safeNotifyListeners();
      return null;
    }

    if (_processingRequestIds.contains(normalizedRequestId)) {
      return null;
    }

    _processingRequestIds.add(normalizedRequestId);
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final reviewedRequest =
          await _reviewVerificationRequestAndUpdateProfile.call(
        requestId: normalizedRequestId,
        status: status,
        reviewedBy: normalizedReviewedBy,
        reviewNote: _normalizeNullable(reviewNote),
      );

      if (_isDisposed) {
        return null;
      }

      _resolvedRequestIds.add(normalizedRequestId);
      _pendingRequests = _pendingRequests
          .where((request) => request.id != normalizedRequestId)
          .toList(growable: false);

      return reviewedRequest;
    } catch (e) {
      if (!_isDisposed) {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      return null;
    } finally {
      if (!_isDisposed) {
        _processingRequestIds.remove(normalizedRequestId);
        _safeNotifyListeners();
      }
    }
  }

  void clearError() {
    if (_errorMessage == null || _isDisposed) return;
    _errorMessage = null;
    _safeNotifyListeners();
  }

  bool _isLoadOperationCurrent(int operationId) {
    return !_isDisposed && operationId == _loadOperationId;
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _loadOperationId++;
    super.dispose();
  }

  String? _normalizeNullable(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
