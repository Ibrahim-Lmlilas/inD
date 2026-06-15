import 'package:flutter/foundation.dart';

// Base provider class that protects against calling
// notifyListeners() after the provider has been disposed.
//
// Extend this instead of ChangeNotifier in your providers.
abstract class DisposableProvider extends ChangeNotifier {
  bool _isDisposed = false;

  // Whether this provider has been disposed.
  bool get isDisposed => _isDisposed;

  // Safe wrapper around notifyListeners().
  // Will only notify if the provider has not been disposed yet.
  @protected
  void safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
