import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:http/http.dart' as http;

/// OAuth2Helper extended to provide [put()] and [patch()] methods.
class OAuthHelper extends OAuth2Helper {
  static const AUTHORIZATION_CODE = OAuth2Helper.AUTHORIZATION_CODE;
  static const CLIENT_CREDENTIALS = OAuth2Helper.CLIENT_CREDENTIALS;
  static const IMPLICIT_GRANT = OAuth2Helper.IMPLICIT_GRANT;

  OAuthHelper(OAuth2Client client,
      {int grantType = OAuth2Helper.AUTHORIZATION_CODE,
      String clientId,
      String clientSecret,
      List<String> scopes})
      : super(
          client,
          grantType: grantType,
          clientId: clientId,
          clientSecret: clientSecret,
          scopes: scopes,
        );

  Future<http.Response> put(String url,
      {Map<String, String> headers, dynamic body, httpClient}) async {
    httpClient ??= http.Client();

    headers ??= {};

    http.Response resp;

    var tknResp = await getToken();

    try {
      headers['Authorization'] = 'Bearer ' + tknResp.accessToken;
      resp = await httpClient.put(url, body: body, headers: headers);

      if (resp.statusCode == 401) {
        if (tknResp.hasRefreshToken()) {
          tknResp = await refreshToken(tknResp.refreshToken);
        } else {
          tknResp = await fetchToken();
        }

        if (tknResp != null) {
          headers['Authorization'] = 'Bearer ' + tknResp.accessToken;
          resp = await httpClient.put(url, body: body, headers: headers);
        }
      }
    } catch (e) {
      rethrow;
    }
    return resp;
  }

  Future<http.Response> patch(String url,
      {Map<String, String> headers, dynamic body, httpClient}) async {
    httpClient ??= http.Client();

    headers ??= {};

    http.Response resp;

    var tknResp = await getToken();

    try {
      headers['Authorization'] = 'Bearer ' + tknResp.accessToken;
      resp = await httpClient.patch(url, body: body, headers: headers);

      if (resp.statusCode == 401) {
        if (tknResp.hasRefreshToken()) {
          tknResp = await refreshToken(tknResp.refreshToken);
        } else {
          tknResp = await fetchToken();
        }

        if (tknResp != null) {
          headers['Authorization'] = 'Bearer ' + tknResp.accessToken;
          resp = await httpClient.patch(url, body: body, headers: headers);
        }
      }
    } catch (e) {
      rethrow;
    }
    return resp;
  }
}
