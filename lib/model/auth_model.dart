import 'package:flutter/material.dart';
import 'package:reaxit/api/token_auth.dart';

enum Status {
  INIT, SIGNED_IN, SIGNED_OUT, SIGNING_IN
}

class AuthModel extends ChangeNotifier {
  final String apiUrl = 'https://thalia.nu/api/v1';

  String _token;

  Status status = Status.INIT;
  String authError;

  AuthModel() {
    status = Status.SIGNED_OUT;
  }

  Future<AuthResponse> logIn(String username, String password) async {
    AuthResponse response = await TokenAuth.authenticate(username, password);

    if (response.success){
      _token = response.token;
      status = Status.SIGNED_IN;
    }

    return response;
  }
}