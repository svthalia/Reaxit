import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reaxit/ui/screens/calendar_screen.dart';
import 'package:reaxit/ui/screens/event_screen.dart';
import 'package:reaxit/ui/screens/pizza_screen.dart';
import 'package:reaxit/ui/screens/splash_screen.dart';
import 'package:reaxit/ui/screens/welcome_screen.dart';

// TODO: rename
class MyRouterDelegate extends RouterDelegate<MyPage>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<MyPage> {
  final GlobalKey<NavigatorState> navigatorKey;

  static MyRouterDelegate of(BuildContext context) {
    RouterDelegate delegate = Router.of(context).routerDelegate;
    assert(delegate is MyRouterDelegate, 'Delegate type must match.');
    return delegate as MyRouterDelegate;
  }

  MyRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  // TODO: keep app state
  List<MyPage> _stack = [MyPage(child: SplashScreen())];

  @override
  Widget build(BuildContext context) {
    // TODO: remove print
    print("${describeIdentity(_stack)}: $_stack");
    return Navigator(
      key: navigatorKey,
      onPopPage: _onPopPage,
      pages: _stack.toList(),
    );
  }

  bool _onPopPage(route, result) {
    if (!route.didPop(result)) return false;

    // Change the app state to reflect pop.
    // TODO: change app state
    if (_stack.length > 1) _stack.removeLast();

    notifyListeners();

    return true;
  }

  @override
  Future<void> setNewRoutePath(MyPage page) async {
    // TODO: change app state
    // Here we should take info from the MyPage and use it to sepcify more
    // such as other pages under it.
    print("setNewRoutePath: $page");
    _stack
      ..clear()
      ..add(page);
    return SynchronousFuture(null);
  }

  void push(MyPage newPage) {
    _stack.add(newPage);
    notifyListeners();
  }

  void pop() {
    if (_stack.length > 1) _stack.removeLast();
    notifyListeners();
  }

  void replace(MyPage page) {
    _stack
      ..clear()
      ..add(page);
    notifyListeners();
  }
}

class MyRouteInformationParser implements RouteInformationParser<MyPage> {
  @override
  Future<MyPage> parseRouteInformation(routeInformation) async {
    print(routeInformation.location);
    Uri uri = Uri.parse(routeInformation.location);
    String path = uri.path;
    List<String> segments = uri.pathSegments;

    // Handle "/".
    if (uri.pathSegments.length == 0) return MyPage(child: SplashScreen());

    if (RegExp('^/pizzas/\$').hasMatch(path)) {
      return MyPage(child: PizzaScreen());
    } else if (RegExp('^/events/\$').hasMatch(path)) {
      return MyPage(child: CalendarScreen());
    } else if (RegExp('^/events/([0-9]+)/\$').hasMatch(path)) {
      return MyPage(child: EventScreen(int.parse(segments[1])));
    }

    // Handle unknown path.
    return MyPage(child: WelcomeScreen());
  }

  @override
  RouteInformation restoreRouteInformation(configuration) {
    return RouteInformation(location: "/");
  }
}

class MyPage extends MaterialPage {
  // TODO: keep some extra parameters, such as about parent pages, so that from
  // parser, we can specify that a memberDetail should have as parent the memberList.
  MyPage({Widget child}) : super(child: child, key: ObjectKey(child));
}
