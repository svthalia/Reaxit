import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/models.dart';
import 'package:reaxit/tosti/tosti_api_repository.dart';
import 'package:reaxit/tosti/tosti_screen.dart';
import 'package:reaxit/tosti/tosti_shift_screen.dart';
import 'package:reaxit/ui/screens.dart';
import 'package:reaxit/ui/widgets.dart';

/// Returns true if [uri] is a deep link that can be handled by the app.
bool isDeepLink(Uri uri) {
  if (uri.host != config.apiHost) return false;
  return _deepLinkRegExps.any((re) => re.hasMatch(uri.path));
}

const _uuid = '([a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12})';

/// The [RegExp]s that can used as deep links. This list should
/// contain all deep links that should be handled by the app.
final List<RegExp> _deepLinkRegExps = <RegExp>[
  RegExp('^/\$'),
  RegExp('^/pizzas/?\$'),
  RegExp('^/events/?\$'),
  RegExp('^/events/([0-9]+)/?\$'),
  RegExp('^/members/photos/?\$'),
  RegExp('^/members/photos/([a-z0-9-_]+)/?\$'),
  RegExp('^/sales/order/$_uuid/pay/?\$'),
  RegExp('^/events/([0-9]+)/mark-present/$_uuid/?\$'),
];

final List<GoRoute> routes = [
  GoRoute(
      path: '/',
      name: 'welcome',
      pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: WelcomeScreen(),
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
                child: child,
              );
            },
          ),
      routes: [
        GoRoute(
          path: 'sales/order/:pk/pay',
          name: 'sales-order-pay',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              barrierColor: Colors.black54,
              opaque: false,
              transitionDuration: const Duration(milliseconds: 150),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                  child: child,
                );
              },
              child: SalesOrderDialog(pk: state.params['pk']!),
            );
          },
        ),
      ]),
  GoRoute(
    path: '/events',
    name: 'calendar',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: CalendarScreen(),
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
          child: child,
        );
      },
    ),
    routes: [
      GoRoute(
        path: ':eventPk',
        name: 'event',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: EventScreen(
            pk: int.parse(state.params['eventPk']!),
            event: state.extra as Event?,
          ),
        ),
        routes: [
          GoRoute(
            path: 'mark-present/:token',
            name: 'mark-present',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                barrierColor: Colors.black54,
                opaque: false,
                transitionDuration: const Duration(milliseconds: 150),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    ),
                    child: child,
                  );
                },
                child: MarkPresentDialog(
                  pk: int.parse(state.params['eventPk']!),
                  token: state.params['token']!,
                ),
              );
            },
          ),
          GoRoute(
            path: 'admin',
            name: 'event-admin',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: EventAdminScreen(
                pk: int.parse(state.params['eventPk']!),
              ),
            ),
          ),
          GoRoute(
            path: 'registration/:registrationPk',
            name: 'event-registration',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: RegistrationScreen(
                eventPk: int.parse(state.params['eventPk']!),
                registrationPk: int.parse(state.params['registrationPk']!),
              ),
            ),
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    // This redirect is above the members route because
    // the members path is a prefix of this albums path.
    path: '/members/photos/:albumSlug',
    redirect: (context, state) => '/albums/${state.params['albumSlug']}',
  ),
  GoRoute(
    // This redirect is above the members route because
    // the members path is a prefix of this albums path.
    path: '/members/photos',
    redirect: (context, state) => '/albums',
  ),
  GoRoute(
    path: '/members',
    name: 'members',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: MembersScreen(),
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
          child: child,
        );
      },
    ),
    routes: [
      GoRoute(
        path: 'profile/:memberPk',
        name: 'member',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: ProfileScreen(
            pk: int.parse(state.params['memberPk']!),
            member: state.extra as ListMember?,
          ),
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/albums',
    name: 'albums',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: AlbumsScreen(),
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
          child: child,
        );
      },
    ),
    routes: [
      GoRoute(
        path: ':albumSlug',
        name: 'album',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AlbumScreen(
            slug: state.params['albumSlug']!,
            album: state.extra as ListAlbum?,
          ),
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/settings',
    name: 'settings',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: SettingsScreen(),
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
          child: child,
        );
      },
    ),
  ),
  GoRoute(
    path: '/pizzas',
    name: 'food',
    pageBuilder: (context, state) {
      return MaterialPage(
        key: state.pageKey,
        child: FoodScreen(
          pk: (state.extra as Event?)?.foodEvent,
          event: state.extra as Event?,
        ),
      );
    },
    routes: [
      GoRoute(
        path: 'admin',
        name: 'food-admin',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: FoodAdminScreen(
            pk: state.extra as int,
          ),
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/login',
    name: 'login',
    pageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: const LoginScreen(),
    ),
  ),
  if (config.tostiEnabled) // Otherwise, all T.O.S.T.I. stuff is removed.
    GoRoute(
      path: '/tosti',
      name: 'tosti',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const TostiScreen(),
      ),
      routes: [
        GoRoute(
          path: 'shift/:shiftId',
          name: 'tosti-shift',
          redirect: (context, state) {
            // Redirect to TostiScreen if not authenticated.
            // TODO: Is there a nicer way to pass tosti api to other pages?
            if (state.extra is! TostiApiRepository) return '/tosti';
            return null;
          },
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: TostiShiftScreen(
              id: int.parse(state.params['shiftId']!),
              api: state.extra as TostiApiRepository,
            ),
          ),
        )
      ],
    ),
];
