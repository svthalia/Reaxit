import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/event_list_bloc.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:reaxit/ui/screens/event_screen.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';
import 'package:collection/collection.dart';

// TODO: fix ordering
// TODO: styling
class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late ScrollController _controller;
  late EventListBloc _bloc;

  @override
  void initState() {
    _bloc = BlocProvider.of<EventListBloc>(context, listen: false);
    _controller = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      _bloc.add(EventListEvent.more());
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
      appBar: AppBar(
        title: Text('Calendar'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
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
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      // TODO: add a range, so we start fetching before scrolling to the very end.
      _bloc.add(EventListEvent.more());
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return <Widget>[
        IconButton(
          tooltip: 'Clear search bar',
          icon: Icon(Icons.delete),
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

  @override
  Widget build(BuildContext context) {
    final monthGroupedEvents = _groupByMonth(listState.results);
    final months = monthGroupedEvents.keys.toList();

    return CustomScrollView(
      controller: controller,
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(10),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final month = months[index];
                final events = monthGroupedEvents[month]!;
                return _MonthCard(month: month, events: events);
              },
              childCount: monthGroupedEvents.length,
            ),
          ),
        ),
        if (listState.isLoadingMore)
          SliverPadding(
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

class _MonthCard extends StatelessWidget {
  final DateTime month;
  final List<Event> events;

  static final _monthFormatter = DateFormat('MMMM');
  static final _monthYearFormatter = DateFormat('MMMM - yyyy');

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

  const _MonthCard({Key? key, required this.month, required this.events})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayGroupedEvents = _groupByDay(events);
    final days = dayGroupedEvents.keys.toList();

    return Column(
      children: [
        Text(
          month.year == DateTime.now().year
              ? _monthFormatter.format(month)
              : _monthYearFormatter.format(month),
          style: Theme.of(context).textTheme.headline5,
        ),
        Column(
          children: days
              .map((day) => _DayCard(day: day, events: dayGroupedEvents[day]!))
              .toList(),
        )
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime day;
  final List<Event> events;

  static final _dayFormatter = DateFormat(DateFormat.ABBR_WEEKDAY);

  const _DayCard({Key? key, required this.day, required this.events})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  day.day.toString(),
                  style: TextStyle(fontSize: 30),
                ),
                Text(_dayFormatter.format(day)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: events.map((event) => _EventCard(event)).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard(this.event, {Key? key}) : super(key: key);

  static final _timeFormatter = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final startTime = _timeFormatter.format(event.start);
    final endTime = _timeFormatter.format(event.end);
    return InkWell(
      onTap: () {
        ThaliaRouterDelegate.of(context).push(
          MaterialPage(child: EventScreen(pk: event.pk)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          color: event.isRegistered ? Color(0xFFE62272) : Colors.grey,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$startTime - $endTime | ${event.location}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
