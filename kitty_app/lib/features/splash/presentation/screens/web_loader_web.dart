import 'dart:js_interop';

@JS('__kittyWebLoaderStartTime')
external JSNumber? get _kittyWebLoaderStartTime;

@JS('dismissKittyWebLoader')
external JSFunction? get _dismissKittyWebLoader;

void dismissWebLoader() {
  try {
    final JSFunction? fn = _dismissKittyWebLoader;
    if (fn != null) {
      fn.callAsFunction();
    }
  } catch (_) {}
}

double? getWebLoaderElapsedSeconds() {
  try {
    final JSNumber? startTimeNum = _kittyWebLoaderStartTime;
    if (startTimeNum != null) {
      final double startTimeMs = startTimeNum.toDartDouble;
      final double nowMs = DateTime.now().millisecondsSinceEpoch.toDouble();
      final double elapsedMs = nowMs - startTimeMs;
      if (elapsedMs >= 0) {
        return elapsedMs / 1000.0;
      }
    }
  } catch (_) {}
  return null;
}
