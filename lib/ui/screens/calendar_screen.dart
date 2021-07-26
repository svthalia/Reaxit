import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/event_list_bloc.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/ui/router.dart';
import 'package:reaxit/ui/screens/event_screen.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

// TODO: Styling
// TODO: Change padding/margin insets everywhere to 4, 8, 12, 16.
class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late ScrollController _controller;
  late EventListBloc _bloc;

  @override
  void initState() {
    _bloc = BlocProvider.of<EventListBloc>(context);
    _controller = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      // Only request loading more if that's not already happening.
      if (!_bloc.state.isLoadingMore) {
        _bloc.add(EventListEvent.more());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(
        title: const Text('CALENDAR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CalendarSearchDelegate(
                  EventListBloc(
                    RepositoryProvider.of<ApiRepository>(
                      context,
                      listen: false,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: MenuDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          _bloc.add(EventListEvent.load());
          await _bloc.stream.firstWhere(
            (state) => !state.isLoading,
          );
        },
        child: BlocBuilder<EventListBloc, EventListState>(
          builder: (context, listState) {
            if (listState.hasException) {
              return ErrorScrollView(listState.message!);
            } else {
              return CalendarScrollView(
                controller: _controller,
                listState: listState,
              );
            }
          },
        ),
      ),
    );
  }
}

class CalendarSearchDelegate extends SearchDelegate {
  late final ScrollController _controller;
  final EventListBloc _bloc;

  CalendarSearchDelegate(this._bloc) {
    _controller = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      // Only request loading more if that's not already happening.
      if (!_bloc.state.isLoadingMore) {
        _bloc.add(EventListEvent.more());
      }
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return <Widget>[
        IconButton(
          tooltip: 'Clear search bar',
          icon: const Icon(Icons.delete),
          onPressed: () {
            query = '';
          },
        )
      ];
    } else {
      return [];
    }
  }

  @override
  Widget buildLeading(BuildContext context) {
    return CloseButton(
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _bloc.add(EventListEvent.load(search: query));
    return BlocBuilder<EventListBloc, EventListState>(
      bloc: _bloc,
      builder: (context, listState) {
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return CalendarScrollView(
            controller: _controller,
            listState: listState,
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _bloc.add(EventListEvent.load(search: query));
    return BlocBuilder<EventListBloc, EventListState>(
      bloc: _bloc,
      builder: (context, listState) {
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return CalendarScrollView(
            controller: _controller,
            listState: listState,
          );
        }
      },
    );
  }
}

/// A ScrollView that shows a calendar with [Event]s.
///
/// The events are grouped by month, and date.
///
/// This does not take care of communicating with a Bloc. The [controller]
/// should do that. The [listState] also must not have an exception.
class CalendarScrollView extends StatelessWidget {
  static final monthFormatter = DateFormat('MMMM');
  static final monthYearFormatter = DateFormat('MMMM yyyy');

  final ScrollController controller;
  final EventListState listState;

  const CalendarScrollView({
    Key? key,
    required this.controller,
    required this.listState,
  }) : super(key: key);

  static Map<DateTime, List<Event>> _groupByMonth(List<Event> eventList) {
    return groupBy<Event, DateTime>(
      eventList,
      (event) => DateTime(
        event.start.year,
        event.start.month,
      ),
    );
  }

  static Map<DateTime, List<Event>> _groupByDay(List<Event> eventList) {
    return groupBy<Event, DateTime>(
      eventList,
      (event) => DateTime(
        event.start.year,
        event.start.month,
        event.start.day,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthGroupedEvents = _groupByMonth(listState.results);
    final months = monthGroupedEvents.keys.toList();

    return CustomScrollView(
      controller: controller,
      physics: const RangeMaintainingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final month = months[index];
                final events = monthGroupedEvents[month]!;

                final dayGroupedEvents = _groupByDay(events);
                final days = dayGroupedEvents.keys.toList();
                return StickyHeader(
                  header: SizedBox(
                    width: double.infinity,
                    child: Material(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          month.year == DateTime.now().year
                              ? monthFormatter.format(month)
                              : monthYearFormatter.format(month),
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ),
                  ),
                  content: Column(children: [
                    const SizedBox(height: 8),
                    for (final day in days)
                      _DayCard(day: day, events: dayGroupedEvents[day]!),
                  ]),
                );
              },
              childCount: monthGroupedEvents.length,
            ),
          ),
        ),
        if (listState.isLoadingMore)
          const SliverPadding(
            padding: EdgeInsets.all(10),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime day;
  final List<Event> events;

  static final dayFormatter = DateFormat(DateFormat.ABBR_WEEKDAY);

  const _DayCard({Key? key, required this.day, required this.events})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                day.day.toString(),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.headline3,
              ),
              Text(
                dayFormatter.format(day).toUpperCase(),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [for (final event in events) _EventCard(event)],
          ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard(this.event, {Key? key}) : super(key: key);

  static final timeFormatter = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final startTime = timeFormatter.format(event.start);
    final endTime = timeFormatter.format(event.end);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        type: MaterialType.card,
        color: event.isRegistered ? const Color(0xFFE62272) : Colors.grey[800],
        child: InkWell(
          onTap: () {
            ThaliaRouterDelegate.of(context).push(
              MaterialPage(child: EventScreen(pk: event.pk)),
            );
          },
          // Prevent painting ink outside of the card.
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$startTime - $endTime | ${event.location}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // TODO: Add partner events.
}
