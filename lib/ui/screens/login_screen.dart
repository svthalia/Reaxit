import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ImageProvider logo = AssetImage('assets/img/logo.png');

  @override
  void didChangeDependencies() {
    precacheImage(logo, context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        return (current is LoggedOutAuthState ||
            current is LoadingAuthState ||
            current is FailureAuthState);
      },
      builder: (context, authState) {
        if (authState is LoadingAuthState) {
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
        } else {
          return Scaffold(
            backgroundColor: Color(0xFFE62272),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                      ).add(LogInAuthEvent());
                    },
                    child: Text('LOGIN'),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
