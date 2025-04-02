import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:reaxit/routes.dart';
import 'package:url_launcher/url_launcher.dart';

class PushNotificationOverlay extends StatelessWidget {
  final RemoteNotification notification;
  final Uri? uri;
  PushNotificationOverlay(this.notification, this.uri)
    : super(key: ObjectKey(notification));

  void onclick(BuildContext context) async {
    if (uri != null) {
      if (isDeepLink(uri!)) {
        context.go(Uri(path: uri!.path, query: uri!.query).toString());
      } else {
        await launchUrl(uri!, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        child: ListTile(
          onTap: () => onclick(context),
          title: Text(notification.title ?? '', maxLines: 1),
          subtitle: Text(notification.body ?? '', maxLines: 2),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => OverlaySupportEntry.of(context)!.dismiss(),
          ),
        ),
      ),
    );
  }
}
