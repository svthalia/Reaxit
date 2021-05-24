import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/ui/screens/album_screen.dart';
import 'package:reaxit/ui/screens/albums_screen.dart';
import 'package:reaxit/ui/screens/calendar_screen.dart';
import 'package:reaxit/ui/screens/event_screen.dart';
import 'package:reaxit/ui/screens/login_screen.dart';
import 'package:reaxit/ui/screens/members_screen.dart';
import 'package:reaxit/ui/screens/profile_screen.dart';
import 'package:reaxit/ui/screens/welcome_screen.dart';

class ThaliaRouterDelegate extends RouterDelegate<List<MaterialPage>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<MaterialPage>> {
  static ThaliaRouterDelegate of(BuildContext context) {
    var delegate = Router.of(context).routerDelegate;
    assert(delegate is ThaliaRouterDelegate, 'Delegate type must match.');
    return delegate as ThaliaRouterDelegate;
  }

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  bool _isAuthenticated = false;
  final List<MaterialPage> _stack = [MaterialPage(child: LoginScreen())];

  ThaliaRouterDelegate({required AuthBloc authBloc})
      : navigatorKey = GlobalKey<NavigatorState>() {
    authBloc.stream.listen((event) {
      if (event is LoggedInAuthState) {
        if (!_isAuthenticated) {
          replaceStack([MaterialPage(child: WelcomeScreen())]);
        }
        _isAuthenticated = true;
      } else if (event is LoggedOutAuthState) {
        replaceStack([MaterialPage(child: LoginScreen())]);
        _isAuthenticated = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        if (previous is LoggedInAuthState && current is LoggedOutAuthState) {
          return true;
        } else if (previous is LoggingInAuthState &&
            current is LoggedInAuthState) {
          return true;
        } else if (current is FailureAuthState) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state is LoggedOutAuthState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Logged out'),
            duration: Duration(seconds: 2),
          ));
        } else if (state is LoggedInAuthState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Logged in'),
            duration: Duration(seconds: 2),
          ));
        } else if (state is FailureAuthState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message ?? 'Logging in failed.'),
            duration: Duration(seconds: 2),
          ));
        }
      },
      child: Navigator(
        key: navigatorKey,
        onPopPage: _onPopPage,
        // Copy the stack with `.toList()` to have the navigator update.
        pages: _stack.toList(),
      ),
    );
  }

  bool _onPopPage(route, result) {
    if (!route.didPop(result)) return false;
    if (_stack.length > 1) _stack.removeLast();
    notifyListeners();
    return true;
  }

  @override
  Future<void> setNewRoutePath(List<MaterialPage> stack) async {
    if (!_isAuthenticated) return SynchronousFuture(null);
    _stack
      ..clear()
      ..addAll(stack);
    return SynchronousFuture(null);
  }

  /// Adds a page to the top of the stack.
  void push(MaterialPage page) {
    _stack.add(page);
    notifyListeners();
  }

  /// Removes the top of the stack.
  void pop() {
    if (_stack.length > 1) _stack.removeLast();
    notifyListeners();
  }

  /// Replaces the top of the stack.
  void replace(MaterialPage page) {
    _stack
      ..removeLast()
      ..add(page);
    notifyListeners();
  }

  /// Replaces the current stack.
  void replaceStack(List<MaterialPage> stack) {
    _stack
      ..clear()
      ..addAll(stack);
    notifyListeners();
  }
}

class ThaliaRouteInformationParser
    implements RouteInformationParser<List<MaterialPage>> {
  @override
  Future<List<MaterialPage>> parseRouteInformation(routeInformation) async {
    var uri = Uri.parse(routeInformation.location!);
    var path = uri.path;
    var segments = uri.pathSegments;

    // Handle "/".
    if (uri.pathSegments.isEmpty) {
      return [MaterialPage(child: WelcomeScreen())];
    } else if (RegExp('^/pizzas/\$').hasMatch(path)) {
      return [
        MaterialPage(child: WelcomeScreen()),
        // TODO: get the right foodevent.
        // MaterialPage(child: FoodScreen()),
      ];
    } else if (RegExp('^/events/\$').hasMatch(path)) {
      return [MaterialPage(child: CalendarScreen())];
    } else if (RegExp('^/events/([0-9]+)\$').hasMatch(path)) {
      final pk = int.parse(segments[1]);
      return [
        MaterialPage(child: CalendarScreen()),
        MaterialPage(child: EventScreen(pk: pk))
      ];
    } else if (RegExp('^/members/photos/([a-z0-9\-_]+)\$').hasMatch(path)) {
      return [
        MaterialPage(child: AlbumsScreen()),
        MaterialPage(child: AlbumScreen(slug: segments[2]))
      ];
    } else if (RegExp('^/members/([0-9]+)\$').hasMatch(path)) {
      final pk = int.parse(segments[1]);
      return [
        MaterialPage(child: MembersScreen()),
        MaterialPage(child: ProfileScreen(pk: pk))
      ];
    }

    // Handle unknown path.
    return [MaterialPage(child: WelcomeScreen())];
  }

  @override
  RouteInformation restoreRouteInformation(configuration) {
    return RouteInformation(location: '/');
  }
}
