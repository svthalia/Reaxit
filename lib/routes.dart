import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/screens.dart';
import 'package:reaxit/ui/screens/album_screen.dart';

final List<RouteBase> routes = [
  GoRoute(
    // This redirect is above the members route because
    // the members path is a prefix of this albums path.
    path: '/members/photos/:albumSlug',
    redirect: (context, state) =>
        '/albums/${state.pathParameters['albumSlug']}',
  ),
  GoRoute(
    // This redirect is above the members route because
    // the members path is a prefix of this albums path.
    path: '/members/photos',
    redirect: (context, state) => '/albums',
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
            slug: state.pathParameters['albumSlug']!,
            album: state.extra as ListAlbum?,
          ),
        ),
      ),
    ],
  ),
];
