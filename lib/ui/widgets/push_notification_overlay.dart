import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:reaxit/routes.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PushNotificationOverlay extends StatelessWidget {
  final RemoteMessage message;
  PushNotificationOverlay(this.message) : super(key: ObjectKey(message));

  @override
  Widget build(BuildContext context) {
    Uri? uri;
    if (message.data.containsKey('url') && message.data['url'] is String) {
      uri = Uri.tryParse(message.data['url'] as String);
      if (uri?.scheme.isEmpty ?? false) uri = uri!.replace(scheme: 'https');
    }

    // This is just to figure out whats wrong with notifications
    Sentry.addBreadcrumb(
      Breadcrumb(
        message:
            'Message: $message (${message.messageType}, ${message.notification}, ${message.senderId} ${message.sentTime})',
      ),
    );

    return SafeArea(
      child: Card(
        child: ListTile(
          onTap:
              uri != null
                  ? () async {
                    if (isDeepLink(uri!)) {
                      context.go(
                        Uri(path: uri.path, query: uri.query).toString(),
                      );
                    } else {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  }
                  : null,
          title: Text(message.notification!.title ?? '', maxLines: 1),
          subtitle: Text(message.notification!.body ?? '', maxLines: 2),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => OverlaySupportEntry.of(context)!.dismiss(),
          ),
        ),
      ),
    );
  }
}
