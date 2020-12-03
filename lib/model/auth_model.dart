import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:reaxit/api/oauth_client.dart';
import 'package:reaxit/api/token_auth.dart';
import 'package:thalia_api/api.dart';

enum Status {
  INIT, SIGNED_IN, SIGNED_OUT, SIGNING_IN
}

class AuthModel extends ChangeNotifier {
  var apiInstance = TokenAuthApi();

  OAuthClient client = OAuthClient(redirectUri: 'https://staging.thalia.nu/callback', customUriScheme: 'https://staging.thalia.nu');

  String _token;

  Status status = Status.INIT;
  String authError;

  AuthModel() {
    status = Status.SIGNED_OUT;
  }

  Future<String> logIn() async {
    OAuth2Helper helper = OAuth2Helper(
      client,
      grantType: OAuth2Helper.AUTHORIZATION_CODE,
      clientId: '3zlt7pqGVMiUCGxOnKTZEpytDUN7haeFBP2kVkig',
      clientSecret: 'Chwh1BE3MgfU1OZZmYRV3LU3e3GzpZJ6tiWrqzFY3dPhMlS7VYD3qMm1RC1pPBvg3WaWmJxfRq8bv5ElVOpjRZwabAGOZ0DbuHhW3chAMaNlOmwXixNfUJIKIBzlnr7I'
    );

    helper.getToken().then((value) => print(value.accessToken));

    return 'test';
  }
}