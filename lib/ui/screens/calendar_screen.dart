import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarScreen extends StatefulWidget {
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late ScrollController _controller;
  late CalendarCubit _cubit;

  @override
  void initState() {
    _cubit = BlocProvider.of<CalendarCubit>(context);
    _controller = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      // Only request loading more if that's not already happening.
      if (!_cubit.state.isLoadingMore) {
        _cubit.more();
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
            padding: const EdgeInsets.all(16),
            icon: const Icon(Icons.search),
            onPressed: () async {
              final searchCubit = CalendarCubit(
                RepositoryProvider.of<ApiRepository>(context),
              );

              await showSearch(
                context: context,
                delegate: CalendarSearchDelegate(searchCubit),
              );

              searchCubit.close();
            },
          ),
        ],
      ),
      drawer: MenuDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _cubit.load();
        },
        child: BlocBuilder<CalendarCubit, CalendarState>(
          builder: (context, calendarState) {
            if (calendarState.hasException) {
              return ErrorScrollView(calendarState.message!);
            } else {
              return CalendarScrollView(
                key: const PageStorageKey('calendar'),
                controller: _controller,
                calendarState: calendarState,
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
  final CalendarCubit _cubit;

  CalendarSearchDelegate(this._cubit) {
    _controller = ScrollController()..addListener(_scrollListener);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = super.appBarTheme(context);
    return theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        headline6: GoogleFonts.openSans(
          textStyle: Theme.of(context).textTheme.headline6,
        ),
      ),
    );
  }

  void _scrollListener() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      // Only request loading more if that's not already happening.
      if (!_cubit.state.isLoadingMore) {
        _cubit.more();
      }
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return <Widget>[
        IconButton(
          padding: const EdgeInsets.all(16),
          tooltip: 'Clear search bar',
          icon: const Icon(Icons.clear),
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
    return BackButton(
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarState>(
      bloc: _cubit..search(query),
      builder: (context, listState) {
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return CalendarScrollView(
            key: const PageStorageKey('calendar-search'),
            controller: _controller,
            calendarState: listState,
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarState>(
      bloc: _cubit..search(query),
      builder: (context, listState) {
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return CalendarScrollView(
            key: const PageStorageKey('calendar-search'),
            controller: _controller,
            calendarState: listState,
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
/// should do that. The [calendarState] also must not have an exception.
class CalendarScrollView extends StatelessWidget {
  static final monthFormatter = DateFormat('MMMM');
  static final monthYearFormatter = DateFormat('MMMM yyyy');

  final ScrollController controller;
  final CalendarState calendarState;

  const CalendarScrollView({
    Key? key,
    required this.controller,
    required this.calendarState,
  }) : super(key: key);

  static Map<DateTime, List<CalendarEvent>> _groupByMonth(
    List<CalendarEvent> eventList,
  ) {
    return groupBy<CalendarEvent, DateTime>(
      eventList,
      (event) => DateTime(
        event.start.year,
        event.start.month,
      ),
    );
  }

  static Map<DateTime, List<CalendarEvent>> _groupByDay(
    List<CalendarEvent> eventList,
  ) {
    return groupBy<CalendarEvent, DateTime>(
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
    final monthGroupedEvents = _groupByMonth(calendarState.results);
    final months = monthGroupedEvents.keys.toList();

    return Scrollbar(
      controller: controller,
      child: CustomScrollView(
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
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            month.year == DateTime.now().year
                                ? monthFormatter
                                    .format(month.toLocal())
                                    .toUpperCase()
                                : monthYearFormatter
                                    .format(month.toLocal())
                                    .toUpperCase(),
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        for (final day in days)
                          _DayCard(day: day, events: dayGroupedEvents[day]!),
                      ],
                    ),
                  );
                },
                childCount: monthGroupedEvents.length,
              ),
            ),
          ),
          if (calendarState.isLoadingMore)
            const SliverPadding(
              padding: EdgeInsets.all(12),
              sliver: SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime day;
  final List<CalendarEvent> events;

  static final dayFormatter = DateFormat(DateFormat.ABBR_WEEKDAY);

  _DayCard({required this.day, required this.events})
      : super(key: ValueKey(day));

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Padding(
            padding: const EdgeInsets.only(right: 12, top: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  dayFormatter.format(day.toLocal()).toUpperCase(),
                  style: Theme.of(context).textTheme.caption!.apply(
                      color: Theme.of(context)
                          .textTheme
                          .caption!
                          .color!
                          .withOpacity(0.5)),
                ),
                Text(
                  day.day.toString(),
                  style: Theme.of(context).textTheme.headline3,
                  strutStyle: const StrutStyle(
                    forceStrutHeight: true,
                    leading: 2.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [for (final event in events) _EventCard(event)],
          ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final CalendarEvent event;

  _EventCard(this.event) : super(key: ObjectKey(event));

  @override
  Widget build(BuildContext context) {
    Color color;
    if (event.parentEvent is Event &&
        (event.parentEvent as Event).isRegistered) {
      color = const Color(0xFFE62272);
    } else if (event.parentEvent is PartnerEvent) {
      color = Colors.black;
    } else {
      color = Colors.grey[800]!;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        type: MaterialType.card,
        color: color,
        child: InkWell(
          onTap: () {
            if (event.parentEvent is PartnerEvent) {
              launchUrl(
                (event.parentEvent as PartnerEvent).url,
                mode: LaunchMode.externalApplication,
              );
            } else {
              context.pushNamed(
                'event',
                params: {'eventPk': event.pk.toString()},
                extra: event.parentEvent,
              );
            }
          },
          // Prevent painting ink outside of the card.
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  event.label,
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
}
