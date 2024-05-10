import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';

class LoggingClient extends oauth2.Client {
  LoggingClient(
    super.credentials, {
    super.identifier,
    super.secret,
    super.basicAuth,
    super.httpClient,
    super.onCredentialsRefreshed,
  });

  LoggingClient.fromClient(oauth2.Client client)
      : super(
          client.credentials,
          identifier: client.identifier,
          secret: client.secret,
        );

  static void logResponse(Uri url, int statusCode) {
    if (kDebugMode) {
      print('url: $url, response code: $statusCode');
    }
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await super.send(request);
    if (kDebugMode) {
      print('url: ${request.url}, response code: ${response.statusCode}');
    }
    return response;
  }
}

/// Provides an interface to the api.
///
/// Its methods may throw an [ApiException] if there are unexpected results.
/// In case credentials cannot be refreshed, this calls `logOut`, which should
/// close the client and indicates that the user is no longer logged in.
class ConcrexitApiRepository implements ApiRepository {
  /// The authenticated client used to access the API.
  LoggingClient? _innerClient;

  ConcrexitApiRepository({
    /// The authenticated client used to access the API.
    required LoggingClient client,

    /// Called when the client can no longer authenticate.
    required Function() onLogOut,
  }) : _innerClient = client;

  @override
  void close() {
    if (_innerClient != null) {
      _innerClient!.close();
      _innerClient = null;
    }
  }
}
