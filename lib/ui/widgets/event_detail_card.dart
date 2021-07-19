import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/ui/router.dart';
import 'package:reaxit/ui/screens/event_screen.dart';
import 'package:reaxit/ui/screens/food_screen.dart';

class EventDetailCard extends StatelessWidget {
  static final timeFormatter = DateFormat('HH:mm');
  final Event event;

  EventDetailCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final start = timeFormatter.format(event.start);
    final end = timeFormatter.format(event.end);
    final description = Bidi.stripHtmlIfNeeded(event.description);

    var indicatorColor = Colors.transparent;
    if (event.isRegistered && !event.isInQueue) {
      indicatorColor = Color(0xFFE62272);
    } else if (event.isInQueue) {
      indicatorColor = Colors.yellow;
    } else if (event.canCreateRegistration) {
      indicatorColor = Colors.grey;
    }

    return Card(
      child: InkWell(
        onTap: () {
          ThaliaRouterDelegate.of(context).push(
            MaterialPage(
              child: EventScreen(
                pk: event.pk,
                event: event,
              ),
            ),
          );
        },
        // Prevent painting ink outside of the card.
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '$start - $end | ${event.location}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: indicatorColor,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
      ),
    );
  }
}
