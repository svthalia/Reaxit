import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:reaxit/ui/screens/event_screen.dart';
import 'package:reaxit/ui/screens/food_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailCard extends StatelessWidget {
  static final timeFormatter = DateFormat('HH:mm');
  final Event event;

  EventDetailCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final start = timeFormatter.format(event.start);
    final end = timeFormatter.format(event.end);
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(event.title),
            subtitle: Text('$start - $end | ${event.location}'),
            trailing: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: event.isRegistered ? Color(0xFFE62272) : Colors.grey,
              ),
            ),
          ),
          Divider(height: 0),
          ConstrainedBox(
            constraints: BoxConstraints.loose(Size.fromHeight(200)),
            child: ClipRect(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    child: HtmlWidget(
                      event.description,
                      onTapUrl: (String url) async {
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Could not open '$url'."),
                            duration: Duration(seconds: 1),
                          ));
                        }
                      },
                    ),
                  ),
                  Positioned.fill(
                    top: 185,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        gradient: LinearGradient(
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.10),
                          ],
                          stops: [0.0, 1.0],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
              left: 16,
              right: 16,
              bottom: 10,
            ),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    ThaliaRouterDelegate.of(context).push(
                      MaterialPage(
                        child: EventScreen(
                          pk: event.pk,
                          event: event,
                        ),
                      ),
                    );
                  },
                  child: Text('MORE INFO'),
                ),
                if (event.hasFoodEvent) ...[
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    label: Text('FOOD'),
                    icon: Icon(Icons.local_pizza),
                    onPressed: () {
                      ThaliaRouterDelegate.of(context).push(
                        MaterialPage(
                          child: FoodScreen(
                            pk: event.foodEvent!,
                            event: event,
                          ),
                        ),
                      );
                    },
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}
