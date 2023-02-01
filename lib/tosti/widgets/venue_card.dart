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
      orderSegment = Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Not available to order.'),
            ElevatedButton(
              onPressed: null,
              child: Text('ORDER AT ${widget.venue.name.toUpperCase()}'),
            ),
          ],
        ),
      );
    } else {
      final shift = widget.venue.shift!;
      final endTime = _formatEndTime(shift.end);
      orderSegment = Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
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

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.venue.name.toUpperCase(),
              style: textTheme.titleLarge,
            ),
          ),
          if (widget.venue.player != null) const Divider(height: 16),
          if (widget.venue.player != null)
            _PlayerSegment(player: widget.venue.player!),
          const Divider(height: 16),
          orderSegment,
        ],
      ),
    );
  }
}

class _PlayerSegment extends StatelessWidget {
  final ThaliedjePlayer player;

  const _PlayerSegment({required this.player});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (player.track?.name == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('Not currently playing.'),
      );
    } else {
      final track = player.track!;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CURRENTLY PLAYING:',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              track.name!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'BY:',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              track.artists.join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall,
            ),
          ],
        ),
      );
    }
  }
}
