import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reaxit/ui/screens/calendar_screen.dart';
import 'package:reaxit/ui/screens/event_screen.dart';
import 'package:reaxit/ui/screens/pizza_screen.dart';
import 'package:reaxit/ui/screens/splash_screen.dart';
import 'package:reaxit/ui/screens/welcome_screen.dart';

// TODO: rename?
class MyRouterDelegate extends RouterDelegate<List<Page>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<Page>> {
  final GlobalKey<NavigatorState> navigatorKey;

  static MyRouterDelegate of(BuildContext context) {
    RouterDelegate delegate = Router.of(context).routerDelegate;
    assert(delegate is MyRouterDelegate, 'Delegate type must match.');
    return delegate as MyRouterDelegate;
  }

  MyRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  // TODO: keep app state
  List<Page> _stack = [MaterialPage(child: SplashScreen())];

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: _onPopPage,
      pages: _stack.toList(),
    );
  }

  bool _onPopPage(route, result) {
    if (!route.didPop(result)) return false;
    if (_stack.length > 1) _stack.removeLast();
    notifyListeners();
    return true;
  }

  @override
  Future<void> setNewRoutePath(List<Page> stack) async {
    _stack
      ..clear()
      ..addAll(stack);
    return SynchronousFuture(null);
  }

  /// Adds a page to the top of the stack.
  void push(Page page) {
    _stack.add(page);
    notifyListeners();
  }

  /// Removes the top of the stack.
  void pop() {
    // TODO: allow return values? This might still be handled by Navigator.
    if (_stack.length > 1) _stack.removeLast();
    notifyListeners();
  }

  /// Replaces the top of the stack.
  void replace(Page page) {
    _stack
      ..removeLast()
      ..add(page);
    notifyListeners();
  }

  /// Replaces the current stack.
  void replaceStack(List<Page> stack) {
    _stack
      ..clear()
      ..addAll(stack);
    notifyListeners();
  }
}

class MyRouteInformationParser implements RouteInformationParser<List<Page>> {
  @override
  Future<List<Page>> parseRouteInformation(routeInformation) async {
    Uri uri = Uri.parse(routeInformation.location);
    String path = uri.path;
    List<String> segments = uri.pathSegments;

    // Handle "/".
    if (uri.pathSegments.length == 0)
      return [MaterialPage(child: SplashScreen())];

    // TODO: How is being logged out handled? Probably shouldn't just open the
    // right place, unless we handle logged out redirection inside each screen,
    // or in a Builder wrapper inside pages.

    if (RegExp('^/pizzas\$').hasMatch(path)) {
      return [
        MaterialPage(child: WelcomeScreen()),
        MaterialPage(child: PizzaScreen()),
      ];
    } else if (RegExp('^/events\$').hasMatch(path)) {
      return [MaterialPage(child: CalendarScreen())];
    } else if (RegExp('^/events/([0-9]+)\$').hasMatch(path)) {
      return [
        MaterialPage(child: CalendarScreen()),
        MaterialPage(child: EventScreen(int.parse(segments[1])))
      ];
    }

    // Handle unknown path.
    return [MaterialPage(child: WelcomeScreen())];
  }

  @override
  RouteInformation restoreRouteInformation(configuration) {
    return RouteInformation(location: "/");
  }
}
