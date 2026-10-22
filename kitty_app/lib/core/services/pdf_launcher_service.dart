import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../errors/app_exception.dart';
import '../utils/logger.dart';

/// Contract for launching external PDF URLs into platform viewer / browser.
abstract class IPdfLauncherService {
  /// Validates whether the given URL is a valid remote PDF URL.
  bool isValidPdfUrl(String? url);

  /// Launches the PDF URL in the platform browser or PDF viewer.
  /// Throws [AppException] if the URL is invalid or launch fails.
  Future<bool> launchPdf(String url);
}

/// Production implementation of [IPdfLauncherService] backed by [url_launcher].
class PdfLauncherService implements IPdfLauncherService {
  const PdfLauncherService();

  @override
  bool isValidPdfUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final Uri? parsed = Uri.tryParse(url.trim());
    if (parsed == null) return false;
    return parsed.hasScheme &&
        (parsed.scheme == 'https' || parsed.scheme == 'http') &&
        parsed.hasAuthority;
  }

  @override
  Future<bool> launchPdf(String url) async {
    final String cleanUrl = url.trim();
    if (!isValidPdfUrl(cleanUrl)) {
      throw const ValidationException('Invalid receipt URL provided.');
    }

    final Uri uri = Uri.parse(cleanUrl);
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw const ServerException(
          'Could not open PDF viewer on your device. Please try again.',
        );
      }
      return true;
    } catch (e) {
      if (e is AppException) rethrow;
      Logger.error('PdfLauncherService launch error', error: e, tag: 'PDF');
      throw const NetworkException(
        'Unable to open receipt PDF. Please verify your connection or try again.',
      );
    }
  }
}

/// Riverpod provider for [IPdfLauncherService].
final Provider<IPdfLauncherService> pdfLauncherServiceProvider =
    Provider<IPdfLauncherService>((Ref ref) {
  return const PdfLauncherService();
});
