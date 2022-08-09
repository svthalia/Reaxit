import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/tosti/models.dart';
import 'package:reaxit/tosti/tosti_api_repository.dart';

class VenueCard extends StatefulWidget {
  final TostiVenue venue;
  const VenueCard(this.venue);

  @override
  State<VenueCard> createState() => _VenueCardState();
}

class _VenueCardState extends State<VenueCard> {
  static final _timeFormatter = DateFormat('HH:mm');
  static final _dateTimeFormatter = DateFormat('E d MMM y, HH:mm');

  static String _formatEndTime(DateTime endTime) {
    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final t = endTime.toLocal();
    if (DateTime(t.year, t.month, t.day) == today) {
      return _timeFormatter.format(t);
    } else if (DateTime(t.year, t.month, t.day) ==
        today.add(const Duration(days: 1))) {
      return '${_timeFormatter.format(t)} tomorrow';
    } else {
      return _dateTimeFormatter.format(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    late final Widget orderSegment;
    if (widget.venue.shift == null) {
      orderSegment = const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text('Not available to order.'),
      );
    } else {
      final shift = widget.venue.shift!;
      final endTime = _formatEndTime(shift.end);
      orderSegment = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order until $endTime, or capacity is reached (${shift.amountOfOrders}/${shift.maxOrdersTotal}).',
            ),
            ElevatedButton(
              onPressed: () {
                context.pushNamed(
                  'tosti-shift',
                  params: {'shiftId': shift.id.toString()},
                  extra: RepositoryProvider.of<TostiApiRepository>(context),
                );
              },
              child: Text('ORDER AT ${widget.venue.name.toUpperCase()}'),
            ),
          ],
        ),
      );
    }

    late final Widget playerSegment;
    if (widget.venue.player == null) {
      playerSegment = const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text('No player.'),
      );
    } else {
      final player = widget.venue.player!;
      if (player.track == null || !player.isPlaying) {
        playerSegment = const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text('No currently playing.'),
        );
      } else {
        final track = player.track!;
        playerSegment = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              const Text('Currently playing:'),
              Text(track.name),
              Text(
                track.artists.join(', '),
              ),
            ],
          ),
        );
      }
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              widget.venue.name.toUpperCase(),
              style: textTheme.headline6,
            ),
          ),
          const Divider(height: 0),
          playerSegment,
          const Divider(height: 0),
          orderSegment,
        ],
      ),
    );
  }
}
