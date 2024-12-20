import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';

mixin Initializer {
  Future<dynamic>? _initPromise;

  /// This method is just a helper method to call [waitForInitialization] and return the promise
  Future<dynamic> initialize() => waitForInitialization();

  Future<dynamic> waitForInitialization({bool rethrowError = false}) async {
    if (_initPromise == null) {
      try {
        _initPromise = runInitialization_();
        await _initPromise;
      } catch (error) {
        _initPromise = null;
        if (rethrowError == true) {
          rethrow;
        }
      }
    }
    return _initPromise;
  }

  /// [never] to be called [directly] !
  @protected
  @visibleForOverriding
  @visibleForTesting
  Future<dynamic> runInitialization_();

  bool get isInitialized => _initPromise != null;

  void dispose() {
    _initPromise = null;
  }
}
