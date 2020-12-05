import 'package:oauth2_client/oauth2_client.dart';
import 'package:meta/meta.dart';

class OAuthClient extends OAuth2Client {
  OAuthClient({@required String redirectUri, @required String customUriScheme}) : super(
    authorizeUrl: 'https://staging.thalia.nu/user/oauth/authorize/',
    tokenUrl: 'https://staging.thalia.nu/user/oauth/token/',
    redirectUri: redirectUri,
    customUriScheme: customUriScheme
  );
}