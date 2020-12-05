import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:reaxit/api/oauth_client.dart';

enum Status {
  INIT, SIGNED_IN, SIGNED_OUT
}

class AuthModel extends ChangeNotifier {
  OAuth2Helper _helper;
  Status _status;

  String _name = 'loading';

  Status get status => _status;
  String get name => _name;

  AuthModel() {
    _status = Status.INIT;

    _init();
  }

  Future<void> _init() async {
    OAuthClient client = OAuthClient(
        redirectUri: 'nu.thalia://callback',
        customUriScheme: 'nu.thalia'
    );

    _helper = OAuth2Helper(
        client,
        grantType: OAuth2Helper.AUTHORIZATION_CODE,
        clientId: '3zlt7pqGVMiUCGxOnKTZEpytDUN7haeFBP2kVkig',
        clientSecret: 'Chwh1BE3MgfU1OZZmYRV3LU3e3GzpZJ6tiWrqzFY3dPhMlS7VYD3qMm1RC1pPBvg3WaWmJxfRq8bv5ElVOpjRZwabAGOZ0DbuHhW3chAMaNlOmwXixNfUJIKIBzlnr7I',
        scopes: ['read', 'write', 'members:read', 'activemembers:read']
    );

    AccessTokenResponse token = await _helper.getTokenFromStorage();
    _status = token == null ? Status.SIGNED_OUT : Status.SIGNED_IN;

    if (status == Status.SIGNED_IN)
      _loadUserData();

    notifyListeners();
  }

  Future<void> _loadUserData() async {
    Response response = await _helper.get('https://staging.thalia.nu/api/v1/members/me');
    if (response.statusCode == 200) {
      _name = jsonDecode(response.body)['first_name'].toString() + ' ' + jsonDecode(response.body)['last_name'].toString();
    }
  }

  logOut() {
    _helper.disconnect();
    _status = Status.SIGNED_OUT;
  }

  Future<String> logIn() async {
    try {
      await _helper.getToken();
    } on PlatformException catch (e) {
      return e.message;
    } on SocketException {
      return 'No internet';
    } catch (error) {
      return 'Unknown error';
    }

    _loadUserData();
    return 'success';
  }
}