import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/router/router.dart';

class AuthGuard implements AutoRouteGuard {
  bool _authenticated = false;

  AuthGuard(Stream<AuthState> authStream) {
    authStream.listen((authState) {
      _authenticated = (authState is LoggedInAuthState);
    });
  }

  @override
  Future<bool> canNavigate(
    List<PageRouteInfo> pendingRoutes,
    StackRouter router,
  ) {
    print(pendingRoutes);
    if (!_authenticated) {
      router.root.push(LoginRoute(
        onLoginResult: (isLoggedIn) async {
          await router.root.replaceAll(pendingRoutes);
        },
      ));
    }
    return SynchronousFuture(_authenticated);
  }
}
