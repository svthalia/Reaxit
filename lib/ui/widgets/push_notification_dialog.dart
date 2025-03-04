import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reaxit/routes.dart';
import 'package:url_launcher/url_launcher.dart';

class PushNotificationDialog extends StatelessWidget {
  final RemoteMessage message;
  PushNotificationDialog(this.message) : super(key: ObjectKey(message));

  @override
  Widget build(BuildContext context) {
    Uri? uri;
    if (message.data.containsKey('url') && message.data['url'] is String) {
      uri = Uri.tryParse(message.data['url'] as String);
      if (uri?.scheme.isEmpty ?? false) uri = uri!.replace(scheme: 'https');
    }

    return AlertDialog(
      title: Text(message.notification?.title ?? 'Notification'),
      content:
          (message.notification?.body != null &&
                  message.notification!.body!.isNotEmpty)
              ? Text(
                message.notification!.body!,
                style: Theme.of(context).textTheme.bodyMedium,
              )
              : null,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CLOSE'),
        ),
        if (uri != null)
          OutlinedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (isDeepLink(uri!)) {
                context.go(Uri(path: uri.path, query: uri.query).toString());
              } else {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('OPEN'),
          ),
      ],
    );
  }
}
