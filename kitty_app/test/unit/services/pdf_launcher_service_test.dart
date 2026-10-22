import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/errors/app_exception.dart';
import 'package:kitty_app/core/services/pdf_launcher_service.dart';

class _FakePdfLauncherService extends PdfLauncherService {
  String? lastLaunchedUrl;
  bool shouldSucceed = true;

  @override
  Future<bool> launchPdf(String url) async {
    final String cleanUrl = url.trim();
    if (!isValidPdfUrl(cleanUrl)) {
      throw const ValidationException('Invalid receipt URL provided.');
    }
    if (!shouldSucceed) {
      throw const ServerException('Could not open PDF viewer on your device.');
    }
    lastLaunchedUrl = cleanUrl;
    return true;
  }
}

void main() {
  group('PdfLauncherService Unit Tests', () {
    late _FakePdfLauncherService service;

    setUp(() {
      service = _FakePdfLauncherService();
    });

    test('isValidPdfUrl correctly validates HTTPS/HTTP URLs', () {
      expect(
        service.isValidPdfUrl('https://res.cloudinary.com/swastik/receipt.pdf'),
        isTrue,
      );
      expect(service.isValidPdfUrl('http://example.com/receipt.pdf'), isTrue);
      expect(service.isValidPdfUrl(''), isFalse);
      expect(service.isValidPdfUrl(null), isFalse);
      expect(service.isValidPdfUrl('ftp://example.com/receipt.pdf'), isFalse);
      expect(service.isValidPdfUrl('not-a-url'), isFalse);
    });

    test('launchPdf succeeds with valid HTTPS Cloudinary URL', () async {
      const String url = 'https://res.cloudinary.com/swastik-test/image/upload/rec_10821.pdf';
      final bool result = await service.launchPdf(url);

      expect(result, isTrue);
      expect(service.lastLaunchedUrl, equals(url));
    });

    test('launchPdf throws ValidationException on invalid URL', () async {
      expect(
        () => service.launchPdf('invalid-url'),
        throwsA(isA<ValidationException>()),
      );
      expect(service.lastLaunchedUrl, isNull);
    });

    test('launchPdf throws ServerException on platform failure', () async {
      service.shouldSucceed = false;
      expect(
        () => service.launchPdf('https://example.com/receipt.pdf'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
