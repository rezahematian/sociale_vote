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
  String? _errorMessage;

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
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pendingRequests = await _getPendingVerificationRequests.call(
        limit: limit,
        offset: offset,
      );
    } catch (_) {
      _errorMessage = 'Impossibile caricare le richieste pending.';
    } finally {
      _isLoading = false;
      notifyListeners();
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
    final normalizedRequestId = requestId.trim();
    final normalizedReviewedBy = reviewedBy.trim();

    if (normalizedRequestId.isEmpty) {
      _errorMessage = 'Request id non valido.';
      notifyListeners();
      return null;
    }

    if (normalizedReviewedBy.isEmpty) {
      _errorMessage = 'Reviewed by non valido.';
      notifyListeners();
      return null;
    }

    if (_processingRequestIds.contains(normalizedRequestId)) {
      return null;
    }

    _processingRequestIds.add(normalizedRequestId);
    _errorMessage = null;
    notifyListeners();

    try {
      final reviewedRequest =
          await _reviewVerificationRequestAndUpdateProfile.call(
        requestId: normalizedRequestId,
        status: status,
        reviewedBy: normalizedReviewedBy,
        reviewNote: _normalizeNullable(reviewNote),
      );

      _pendingRequests = _pendingRequests
          .where((request) => request.id != normalizedRequestId)
          .toList(growable: false);

      return reviewedRequest;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _processingRequestIds.remove(normalizedRequestId);
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  String? _normalizeNullable(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}