sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}

class InvalidMoveException extends AppException {
  const InvalidMoveException(super.message);
}
