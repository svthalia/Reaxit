import 'package:flutter/material.dart';
import 'package:reaxit/api/token_auth.dart';
import 'package:thalia_api/api.dart';

enum Status {
  INIT, SIGNED_IN, SIGNED_OUT, SIGNING_IN
}

class AuthModel extends ChangeNotifier {
  var apiInstance = TokenAuthApi();

  String _token;

  Status status = Status.INIT;
  String authError;

  AuthModel() {
    status = Status.SIGNED_OUT;
  }

  Future<String> logIn(String username, String password) async {
    AuthToken response = await apiInstance.createAuthToken(username, password);

    if (response.token != null){
      _token = response.token;
      status = Status.SIGNED_IN;

      return 'success';
    }

    return 'Something went wrong.';
  }
}