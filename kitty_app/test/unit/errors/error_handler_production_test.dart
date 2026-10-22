import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/errors/app_exception.dart';
import 'package:kitty_app/core/errors/error_handler.dart';
import 'package:kitty_app/core/errors/failure.dart';

void main() {
  group('Phase 15 - ErrorHandler & Production Error Mapping Suite', () {
    test('1. Maps NetworkException to NetworkFailure with clean message', () {
      const exception = NetworkException();
      final failure = ErrorHandler.handle(exception);

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, contains('Unable to connect'));
      expect(failure.message, isNot(contains('http://')));
      expect(failure.message, isNot(contains('https://')));
    });

    test('2. Maps TimeoutException to TimeoutFailure with user-friendly message', () {
      const exception = TimeoutException();
      final failure = ErrorHandler.handle(exception);

      expect(failure, isA<TimeoutFailure>());
      expect(failure.message, contains('The request timed out'));
    });

    test('3. Maps UnauthorizedException to AuthFailure with session expiry message', () {
      const exception = UnauthorizedException();
      final failure = ErrorHandler.handle(exception);

      expect(failure, isA<AuthFailure>());
      expect(failure.message, contains('session has expired'));
      expect(failure.message, isNot(contains('Bearer')));
      expect(failure.message, isNot(contains('jwt')));
    });

    test('4. Maps ServerException to ServerFailure without database internals', () {
      const exception = ServerException();
      final failure = ErrorHandler.handle(exception);

      expect(failure, isA<ServerFailure>());
      expect(failure.message, contains('maintenance'));
      expect(failure.message, isNot(contains('SQL')));
      expect(failure.message, isNot(contains('SELECT')));
    });

    test('5. Maps non-AppException to UnknownFailure without leaking internal error strings', () {
      final rawException = Exception('DioException [bad response]: https://api.swastik.com/private/users 500 StackTrace: line 42');
      final failure = ErrorHandler.handle(rawException);

      expect(failure, isA<UnknownFailure>());
      expect(failure.message, equals('Something went wrong. Please try again.'));
      expect(failure.message, isNot(contains('https://')));
      expect(failure.message, isNot(contains('DioException')));
      expect(failure.message, isNot(contains('StackTrace')));
    });
  });
}
