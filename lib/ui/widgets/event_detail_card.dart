import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/models/event.dart';

class EventDetailCard extends StatelessWidget {
  static final timeFormatter = DateFormat('HH:mm');
  final Event event;

  const EventDetailCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final start = timeFormatter.format(event.start.toLocal());
    final end = timeFormatter.format(event.end.toLocal());

    // Remove HTML tags.
    final description =
        event.description.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');

    var indicatorColor = Colors.transparent;
    if (event.isInvited) {
      indicatorColor = const Color(0xFFE62272);
    } else if (event.isInQueue) {
      indicatorColor = Colors.yellow;
    } else if (event.canCreateRegistration) {
      indicatorColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => context.pushNamed(
          'event',
          params: {'eventPk': event.pk.toString()},
          extra: event,
        ),
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
                bottom: 8,
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
                        const SizedBox(height: 4),
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
                bottom: 8,
              ),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () => context.pushNamed(
                      'event',
                      params: {'eventPk': event.pk.toString()},
                      extra: event,
                    ),
                    child: const Text('MORE INFO'),
                  ),
                  if (event.hasFoodEvent) ...[
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      label: const Text('FOOD'),
                      icon: const Icon(Icons.local_pizza),
                      onPressed: () => context.pushNamed('food', extra: event),
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
