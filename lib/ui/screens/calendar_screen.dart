import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/theme.dart';
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
      _cubit.more();
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
      body: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, calendarState) {
          if (calendarState.hasException) {
            return ErrorScrollView(calendarState.message!);
          } else {
            return CalendarScrollView(
              key: const PageStorageKey('calendar'),
              controller: _controller,
              calendarState: calendarState,
              loadMoreUp: _cubit.moreUp,
            );
          }
        },
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
        titleLarge: GoogleFonts.openSans(
          textStyle: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }

  void _scrollListener() {
    // Only request loading more if that's not already happening.
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      if (!_cubit.state.isLoadingMoreDown) {
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
            loadMoreUp: _cubit.moreUp,
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
            loadMoreUp: _cubit.moreUp,
          );
        }
      },
    );
  }
}

/// _CalendarViewDay holds events attached to a day
class _CalendarViewDay {
  final DateTime day;
  final List<CalendarEvent> events;

  _CalendarViewDay({required this.day, required List<CalendarEvent> events})
      : events = events.sortedBy((element) => element.start);
}

/// _CalendarViewMonth holds events attached to a month
class _CalendarViewMonth {
  final DateTime month;
  final List<CalendarEvent> events;

  _CalendarViewMonth({required this.month, required List<CalendarEvent> events})
      : events = events.sortedBy((element) => element.start);

  List<_CalendarViewDay> byDay() {
    return groupBy<CalendarEvent, DateTime>(
      events,
      (event) => DateTime(
        event.start.year,
        event.start.month,
        event.start.day,
      ),
    )
        .entries
        .map((entry) => _CalendarViewDay(day: entry.key, events: entry.value))
        .sortedBy((element) => element.day);
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

  final Key centerkey = UniqueKey();
  final ScrollController controller;
  final CalendarState calendarState;
  final Function() loadMoreUp;
  final List<_CalendarViewMonth> _monthGroupedEventsUp;
  final List<_CalendarViewMonth> _monthGroupedEventsDown;

  CalendarScrollView({
    Key? key,
    required this.controller,
    required this.calendarState,
    required this.loadMoreUp,
  })  : _monthGroupedEventsUp = _groupByMonth(calendarState.resultsUp)
            .sortedBy((element) => element.month)
            .reversed
            .toList(),
        _monthGroupedEventsDown = _groupByMonth(calendarState.resultsDown)
            .sortedBy((element) => element.month),
        super(key: key);

  static List<_CalendarViewMonth> _groupByMonth(
    List<CalendarEvent> eventList,
  ) =>
      groupBy<CalendarEvent, DateTime>(
        eventList,
        (event) => DateTime(
          event.start.year,
          event.start.month,
        ),
      )
          .entries
          .map((entry) =>
              _CalendarViewMonth(month: entry.key, events: entry.value))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      child: CustomScrollView(
        controller: controller,
        physics: OverscrollableScrollPhysics(
          parent: const AlwaysScrollableScrollPhysics(),
          onhittop: loadMoreUp,
          overscroll: 30,
        ),
        center: centerkey,
        slivers: [
          SliverToBoxAdapter(
            child: AnimatedLoader(
              visible: calendarState.isLoadingMoreUp,
            ),
          ),
          if (!calendarState.isDoneUp)
            SliverToBoxAdapter(
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextButton(
                    onPressed: loadMoreUp,
                    child: const Text('LOAD MORE'),
                  ),
                ],
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final monthEvents = _monthGroupedEventsUp[index];
                  final eventsByDay = monthEvents.byDay();
                  return StickyHeader(
                    header: SizedBox(
                      width: double.infinity,
                      child: Material(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            monthEvents.month.year == DateTime.now().year
                                ? monthFormatter
                                    .format(monthEvents.month.toLocal())
                                    .toUpperCase()
                                : monthYearFormatter
                                    .format(monthEvents.month.toLocal())
                                    .toUpperCase(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        for (final day in eventsByDay)
                          _DayCard(day: day.day, events: day.events),
                      ],
                    ),
                  );
                },
                childCount: _monthGroupedEventsUp.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            key: centerkey,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final monthEvents = _monthGroupedEventsDown[index];
                  final eventsByDay = monthEvents.byDay();
                  return StickyHeader(
                    header: SizedBox(
                      width: double.infinity,
                      child: Material(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            monthEvents.month.year == DateTime.now().year
                                ? monthFormatter
                                    .format(monthEvents.month.toLocal())
                                    .toUpperCase()
                                : monthYearFormatter
                                    .format(monthEvents.month.toLocal())
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
                        for (final day in eventsByDay)
                          _DayCard(day: day.day, events: day.events),
                      ],
                    ),
                  );
                },
                childCount: _monthGroupedEventsDown.length,
              ),
            ),
          ),
          if (calendarState.isLoadingMoreDown)
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
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .color!
                          .withOpacity(0.5)),
                ),
                Text(
                  day.day.toString(),
                  style: Theme.of(context).textTheme.displaySmall,
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
      color = magenta;
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
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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

class AnimatedLoader extends StatefulWidget {
  final bool visible;
  const AnimatedLoader({super.key, required this.visible});

  @override
  State<AnimatedLoader> createState() => _AnimatedLoaderState();
}

/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class _AnimatedLoaderState extends State<AnimatedLoader>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void didUpdateWidget(AnimatedLoader oldWidget) {
    if (widget.visible) {
      _controller.value = 1;
    } else {
      _controller.reverse();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      axis: Axis.vertical,
      child: const Center(
        child: Padding(
            padding: EdgeInsets.all(12), child: CircularProgressIndicator()),
      ),
    );
  }
}

class OverscrollableScrollPhysics extends ScrollPhysics {
  final Function() onhittop;
  final int overscroll;

  const OverscrollableScrollPhysics(
      {super.parent, required this.onhittop, required this.overscroll});

  @override
  OverscrollableScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OverscrollableScrollPhysics(
        parent: buildParent(ancestor),
        onhittop: onhittop,
        overscroll: overscroll);
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if (position.pixels <= position.minScrollExtent - overscroll) {
      onhittop();
      return super.createBallisticSimulation(position, 0);
    } else {
      return super.createBallisticSimulation(position, velocity);
    }
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) =>
      super.applyBoundaryConditions(
          position.copyWith(
              minScrollExtent: position.minScrollExtent - overscroll),
          value) *
      0.9;
}
