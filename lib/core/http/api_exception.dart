class ApiException implements Exception {
  /// HTTP status code (es. 400, 401, 500), se disponibile.
  final int? statusCode;

  /// Messaggio di errore leggibile.
  final String message;

  /// Dettagli opzionali (es. body di errore, codice applicativo, ecc.).
  final dynamic details;

  ApiException({
    this.statusCode,
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, message: $message, details: $details)';
  }
}