/// Exception thrown by the Jyotish library.
///
/// This exception is thrown when an error occurs during library initialization,
/// calculation, or any other operation.
class JyotishException implements Exception {
  /// Creates a new [JyotishException].
  ///
  /// [message] - A description of the error.
  /// [originalError] - The original error that caused this exception.
  /// [stackTrace] - The stack trace of the original error.
  JyotishException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  /// The error message.
  final String message;

  /// The original error that caused this exception, if any.
  final Object? originalError;

  /// The stack trace of the original error, if any.
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buffer = StringBuffer('JyotishException: $message');
    if (originalError != null) {
      buffer.write('\nCaused by: $originalError');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    return buffer.toString();
  }
}

/// Exception thrown when Swiss Ephemeris calculation fails.
class CalculationException extends JyotishException {
  CalculationException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when initialization fails.
class InitializationException extends JyotishException {
  InitializationException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when invalid input is provided.
class ValidationException extends JyotishException {
  ValidationException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when a divisional chart is requested with an incorrect ayanamsa.
class AyanamsaMismatchException extends JyotishException {
  AyanamsaMismatchException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when requested house systems fail in polar regions due to extreme latitudes.
class PolarRegionException extends JyotishException {
  PolarRegionException(
    super.message, {
    required this.latitude,
    required this.houseSystem,
    super.originalError,
    super.stackTrace,
  });

  /// The latitude that caused the failure
  final double latitude;

  /// The requested house system ('P', 'K', etc.)
  final String houseSystem;
}
