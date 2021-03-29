// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'dart:async' as _i13;

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i12;

import '../ui/pages/albums_page.dart' as _i5;
import '../ui/pages/calendar_page.dart' as _i6;
import '../ui/pages/event_admin_page.dart' as _i11;
import '../ui/pages/event_page.dart' as _i10;
import '../ui/pages/login_page.dart' as _i3;
import '../ui/pages/members_page.dart' as _i8;
import '../ui/pages/profile_page.dart' as _i9;
import '../ui/pages/settings_page.dart' as _i7;
import '../ui/pages/welcome_page.dart' as _i4;
import 'auth_guard.dart' as _i2;

class AppRouter extends _i1.RootStackRouter {
  AppRouter({required this.authGuard});

  final _i2.AuthGuard authGuard;

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    LoginRoute.name: (entry) {
      var args = entry.routeData
          .argsAs<LoginRouteArgs>(orElse: () => LoginRouteArgs());
      return _i1.MaterialPageX(
          entry: entry,
          child:
              _i3.LoginPage(key: args.key, onLoginResult: args.onLoginResult));
    },
    WelcomeRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i4.WelcomePage());
    },
    AlbumsRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i5.AlbumsPage());
    },
    MembersRouter.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    CalendarRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i6.CalendarPage());
    },
    SettingsRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i7.SettingsPage());
    },
    MembersRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i8.MembersPage());
    },
    ProfileRoute.name: (entry) {
      var pathParams = entry.routeData.pathParams;
      var args = entry.routeData.argsAs<ProfileRouteArgs>(
          orElse: () => ProfileRouteArgs(memberPk: pathParams.getInt('pk')));
      return _i1.MaterialPageX(
          entry: entry,
          child: _i9.ProfilePage(key: args.key, memberPk: args.memberPk));
    },
    EventRoute.name: (entry) {
      var pathParams = entry.routeData.pathParams;
      var args = entry.routeData.argsAs<EventRouteArgs>(
          orElse: () => EventRouteArgs(eventPk: pathParams.getInt('pk')));
      return _i1.MaterialPageX(
          entry: entry,
          child: _i10.EventPage(key: args.key, eventPk: args.eventPk));
    },
    EventAdminRoute.name: (entry) {
      var pathParams = entry.routeData.pathParams;
      var args = entry.routeData.argsAs<EventAdminRouteArgs>(
          orElse: () => EventAdminRouteArgs(eventPk: pathParams.getInt('pk')));
      return _i1.MaterialPageX(
          entry: entry,
          child: _i11.EventAdminPage(key: args.key, eventPk: args.eventPk));
    }
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig(LoginRoute.name, path: '/login'),
        _i1.RouteConfig(WelcomeRoute.name, path: '/', guards: [authGuard]),
        _i1.RouteConfig(AlbumsRoute.name,
            path: '/members/photos', guards: [authGuard]),
        _i1.RouteConfig(MembersRouter.name, path: '/members', guards: [
          authGuard
        ], children: [
          _i1.RouteConfig(MembersRoute.name, path: ''),
          _i1.RouteConfig(ProfileRoute.name, path: ':pk')
        ]),
        _i1.RouteConfig(CalendarRoute.name, path: '/events/', guards: [
          authGuard
        ], children: [
          _i1.RouteConfig(EventRoute.name, path: ':pk', children: [
            _i1.RouteConfig(EventAdminRoute.name, path: 'event-admin-page')
          ])
        ]),
        _i1.RouteConfig(SettingsRoute.name,
            path: '/settings-page', guards: [authGuard]),
        _i1.RouteConfig('*#redirect',
            path: '*', redirectTo: '/', fullMatch: true)
      ];
}

class LoginRoute extends _i1.PageRouteInfo<LoginRouteArgs> {
  LoginRoute(
      {_i12.Key? key, _i13.Future<dynamic> Function(bool)? onLoginResult})
      : super(name,
            path: '/login',
            args: LoginRouteArgs(key: key, onLoginResult: onLoginResult));

  static const String name = 'LoginRoute';
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.onLoginResult});

  final _i12.Key? key;

  final _i13.Future<dynamic> Function(bool)? onLoginResult;
}

class WelcomeRoute extends _i1.PageRouteInfo {
  const WelcomeRoute() : super(name, path: '/');

  static const String name = 'WelcomeRoute';
}

class AlbumsRoute extends _i1.PageRouteInfo {
  const AlbumsRoute() : super(name, path: '/members/photos');

  static const String name = 'AlbumsRoute';
}

class MembersRouter extends _i1.PageRouteInfo {
  const MembersRouter({List<_i1.PageRouteInfo>? children})
      : super(name, path: '/members', initialChildren: children);

  static const String name = 'MembersRouter';
}

class CalendarRoute extends _i1.PageRouteInfo {
  const CalendarRoute({List<_i1.PageRouteInfo>? children})
      : super(name, path: '/events/', initialChildren: children);

  static const String name = 'CalendarRoute';
}

class SettingsRoute extends _i1.PageRouteInfo {
  const SettingsRoute() : super(name, path: '/settings-page');

  static const String name = 'SettingsRoute';
}

class MembersRoute extends _i1.PageRouteInfo {
  const MembersRoute() : super(name, path: '');

  static const String name = 'MembersRoute';
}

class ProfileRoute extends _i1.PageRouteInfo<ProfileRouteArgs> {
  ProfileRoute({_i12.Key? key, required int memberPk})
      : super(name,
            path: ':pk',
            args: ProfileRouteArgs(key: key, memberPk: memberPk),
            params: {'pk': memberPk});

  static const String name = 'ProfileRoute';
}

class ProfileRouteArgs {
  const ProfileRouteArgs({this.key, required this.memberPk});

  final _i12.Key? key;

  final int memberPk;
}

class EventRoute extends _i1.PageRouteInfo<EventRouteArgs> {
  EventRoute(
      {_i12.Key? key, required int eventPk, List<_i1.PageRouteInfo>? children})
      : super(name,
            path: ':pk',
            args: EventRouteArgs(key: key, eventPk: eventPk),
            params: {'pk': eventPk},
            initialChildren: children);

  static const String name = 'EventRoute';
}

class EventRouteArgs {
  const EventRouteArgs({this.key, required this.eventPk});

  final _i12.Key? key;

  final int eventPk;
}

class EventAdminRoute extends _i1.PageRouteInfo<EventAdminRouteArgs> {
  EventAdminRoute({_i12.Key? key, required int eventPk})
      : super(name,
            path: 'event-admin-page',
            args: EventAdminRouteArgs(key: key, eventPk: eventPk),
            params: {'pk': eventPk});

  static const String name = 'EventAdminRoute';
}

class EventAdminRouteArgs {
  const EventAdminRouteArgs({this.key, required this.eventPk});

  final _i12.Key? key;

  final int eventPk;
}
