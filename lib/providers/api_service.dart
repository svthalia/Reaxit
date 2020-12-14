import 'package:flutter/material.dart';
import 'package:reaxit/providers/auth_provider.dart';

enum ApiStatus {
  LOADING, DONE, NO_INTERNET, NOT_AUTHENTICATED, UNKNOWN_ERROR
}

abstract class ApiService extends ChangeNotifier {
  final AuthProvider authProvider;

  ApiStatus status;

  ApiService(this.authProvider) {
    load();
  }

  Future<void> load();
}