import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reaxit/ui/screens/splash_screen.dart';

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
    Uri uri = Uri.parse(routeInformation.location);
    String path = uri.path;
    List<String> segments = uri.pathSegments;

    // Handle "/".
    if (uri.pathSegments.length == 0) return MyPage(child: SplashScreen());

    if (RegExp('^/pizzas/\$').hasMatch(path)) {
      return MyPage(child: TestScreen(page: "pizza"));
    } else if (RegExp('^/events/\$').hasMatch(path)) {
      return MyPage(child: TestScreen(page: "eventList"));
    } else if (RegExp('^/events/([0-9]+)/\$').hasMatch(path)) {
      return MyPage(child: TestScreen(page: "eventDetail_${segments[1]}"));
    }

    // Handle unknown path.
    return MyPage(child: TestScreen(page: "unknown"));
  }

  @override
  RouteInformation restoreRouteInformation(configuration) {
    // TODO: implement restoreRouteInformation
    var screen = configuration.child as TestScreen;
    return RouteInformation(location: screen.page);
  }
}

class TestScreen extends StatelessWidget {
  final String page;

  const TestScreen({Key key, this.page}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(page),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => MyRouterDelegate.of(context).push(
                  MyPage(
                    child: TestScreen(
                      page: "pushed",
                    ),
                  ),
                ),
                child: Text("push"),
              ),
            ),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => MyRouterDelegate.of(context).pop(),
                child: Text("pop"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyPage extends MaterialPage {
  // TODO: keep some extra parameters, such as about parent pages, so that from
  // parser, we can specify that a memberDetail should have as parent the memberList.
  MyPage({Widget child}) : super(child: child, key: ObjectKey(child));
}
