import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reaxit/ui/screens/album_screen.dart';

final List<RouteBase> routes = [
  GoRoute(
    path: '/albums',
    name: 'albums',
    pageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: const AlbumScreen(),
    ),
  ),
];
