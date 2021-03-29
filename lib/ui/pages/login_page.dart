import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/router/router.dart';

class LoginPage extends StatefulWidget {
  final Future Function(bool isLoggedIn)? onLoginResult;

  const LoginPage({Key? key, this.onLoginResult}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  ImageProvider logo = AssetImage('assets/img/logo.png');

  @override
  void didChangeDependencies() {
    precacheImage(logo, context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        return (current is LoggedOutAuthState || current is LoadingAuthState);
      },
      builder: (context, authState) {
        if (authState is LoggedOutAuthState) {
          return Scaffold(
            backgroundColor: Color(0xFFE62272),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image(
                    image: logo,
                    width: 260,
                  ),
                ),
                SizedBox(height: 50),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black87,
                      onPrimary: Colors.white,
                    ),
                    onPressed: () {
                      BlocProvider.of<AuthBloc>(
                        context,
                        listen: false,
                      ).add(RequestLogInAuthEvent());
                    },
                    child: Text('LOGIN'),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Color(0xFFE62272),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image(
                    image: logo,
                    width: 260,
                  ),
                ),
                SizedBox(height: 50),
                SizedBox(
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
      listenWhen: (previous, current) {
        if (previous is LoggedInAuthState && current is LoggedOutAuthState) {
          return true;
        } else if (current is LoggedInAuthState) {
          return true;
        } else if (current is LoggingInAuthState) {
          return true;
        }
        return false;
      },
      listener: (context, authState) async {
        if (authState is LoggingInAuthState) {
          final responseUrl = Uri.parse(
            await FlutterWebAuth.authenticate(
              url: authState.authorizeUrl.toString(),
              callbackUrlScheme: authState.redirectUrl.scheme,
            ),
          );
          BlocProvider.of<AuthBloc>(context, listen: false).add(
            CompleteLogInAuthEvent(
              responseUrl: responseUrl,
              grant: authState.grant,
            ),
          );
        } else if (authState is LoggedOutAuthState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Logged out'),
            duration: Duration(seconds: 2),
          ));
        } else if (authState is LoggedInAuthState) {
          if (widget.onLoginResult != null) {
            await widget.onLoginResult!.call(true);
          } else {
            await AutoRouter.of(context).replace(WelcomeRoute());
          }
        }
      },
    );
  }
}
