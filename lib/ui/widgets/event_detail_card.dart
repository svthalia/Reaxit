import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/ui/theme.dart';

class EventDetailCard extends StatelessWidget {
  static final timeFormatter = DateFormat('HH:mm');
  final BaseEvent event;
  final Color _indicatorColor;
  final bool _hasFoodEvent;
  final Color? _color;

  static Color _getIndicatorColor(Event event) {
    if (event.isInvited) {
      return magenta;
    } else if (event.isInQueue) {
      return Colors.yellow;
    } else if (event.canCreateRegistration) {
      return Colors.grey;
    }

    return Colors.transparent;
  }

  EventDetailCard({
    required this.event,
  })  : _color = event is PartnerEvent ? Colors.black : null,
        _indicatorColor =
            event is Event ? _getIndicatorColor(event) : Colors.transparent,
        _hasFoodEvent = event is Event ? event.hasFoodEvent : false;

  void _onTap(BuildContext context) {
    if (event is Event) {
      context.pushNamed(
        'event',
        params: {'eventPk': event.pk.toString()},
        extra: event,
      );
    } else if (event is PartnerEvent) {
      launchUrl(
        (event as PartnerEvent).url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = timeFormatter.format(event.start.toLocal());
    final end = timeFormatter.format(event.end.toLocal());

    // Remove HTML tags.
    final description =
        event.description.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');

    return Card(
      color: _color,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _onTap(context),
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
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$start - $end | ${event.location}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _indicatorColor,
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
                    onPressed: () => _onTap(context),
                    child: const Text('MORE INFO'),
                  ),
                  if (_hasFoodEvent) ...[
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
