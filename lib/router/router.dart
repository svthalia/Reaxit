import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:reaxit/router/auth_guard.dart';
import 'package:reaxit/ui/pages/albums_page.dart';
import 'package:reaxit/ui/pages/calendar_page.dart';
import 'package:reaxit/ui/pages/event_admin_page.dart';
import 'package:reaxit/ui/pages/event_page.dart';
import 'package:reaxit/ui/pages/login_page.dart';
import 'package:reaxit/ui/pages/members_page.dart';
import 'package:reaxit/ui/pages/profile_page.dart';
import 'package:reaxit/ui/pages/settings_page.dart';
import 'package:reaxit/ui/pages/welcome_page.dart';

export 'router.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(path: '/login', page: LoginPage),
    AutoRoute(
      guards: [AuthGuard],
      path: '/',
      page: WelcomePage,
    ),
    AutoRoute(
      guards: [AuthGuard],
      path: '/members/photos',
      page: AlbumsPage,
    ),
    AutoRoute(
      guards: [AuthGuard],
      path: '/members',
      name: 'MembersRouter',
      page: MembersPage,
      children: <AutoRoute>[
        AutoRoute(page: ProfilePage, path: ':pk'),
      ],
    ),
    AutoRoute(
      guards: [AuthGuard],
      path: '/events/',
      page: CalendarPage,
      children: [
        AutoRoute(
          path: ':pk',
          page: EventPage,
          children: [AutoRoute(page: EventAdminPage)],
        ),
      ],
    ),
    AutoRoute(
      guards: [AuthGuard],
      page: SettingsPage,
    ),
    RedirectRoute(path: '*', redirectTo: '/'),
  ],
)
class $AppRouter {}
