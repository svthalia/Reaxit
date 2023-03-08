import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  GlobalKey todayKey = GlobalKey();
  GlobalKey thisMonthKey = GlobalKey();
  double? _todayOffset;

  @override
  void initState() {
    _cubit = BlocProvider.of<CalendarCubit>(context);
    _controller = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  void _assureTodayOffset() {
    if (_todayOffset == null && todayKey.currentContext != null) {
      // Calculate the position the widget should be in to avoid being
      // drawn under the header
      final offset = thisMonthKey.currentContext!.size!.height + 8;
      final totalHeight =
          Scrollable.of(todayKey.currentContext!).context.size!.height;

      RenderObject renderObject = todayKey.currentContext!.findRenderObject()!;
      RenderAbstractViewport viewport = RenderAbstractViewport.of(renderObject);
      _todayOffset = viewport
          .getOffsetToReveal(renderObject, offset / totalHeight, rect: null)
          .offset;
    }
  }

  void _scrollListener() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      _cubit.more();
    }
    _assureTodayOffset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void openSearch() async {
    final searchCubit = CalendarCubit(
      RepositoryProvider.of<ApiRepository>(context),
    );

    await showSearch(
      context: context,
      delegate: CalendarSearchDelegate(searchCubit),
    );

    searchCubit.close();
  }

  void scrollToToday() {
    _assureTodayOffset();
    _controller.animateTo(
      _todayOffset ?? 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
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
            onPressed: openSearch,
          ),
        ],
      ),
      drawer: MenuDrawer(),
      body: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, calendarState) {
          if (calendarState.hasException) {
            return ErrorScrollView(calendarState.message!);
          } else {
            todayKey = GlobalKey();
            thisMonthKey = GlobalKey();
            return CalendarScrollView(
              key: const PageStorageKey('calendar'),
              controller: _controller,
              calendarState: calendarState,
              loadMoreUp: _cubit.moreUp,
              todayKey: todayKey,
              thisMonthKey: thisMonthKey,
              now: calendarState.now,
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: scrollToToday,
        icon: const Icon(Icons.today),
        label: const Text('Today'),
        backgroundColor: magenta,
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
      builder: (context, calendarState) {
        if (calendarState.hasException) {
          return ErrorScrollView(calendarState.message!);
        } else {
          return CalendarScrollView(
            key: const PageStorageKey('calendar-search'),
            controller: _controller,
            calendarState: calendarState,
            loadMoreUp: _cubit.moreUp,
            now: calendarState.now,
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
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
  final List<_CalendarViewDay> days;

  _CalendarViewMonth({required this.month, required List<CalendarEvent> events})
      : days = groupBy<CalendarEvent, DateTime>(
          events.sortedBy((element) => element.start),
          (event) => DateTime(
            event.start.year,
            event.start.month,
            event.start.day,
          ),
        )
            .entries
            .map((entry) =>
                _CalendarViewDay(day: entry.key, events: entry.value))
            .sortedBy((element) => element.day);

  List<_CalendarViewDay> byDay() => days;
}

List<_CalendarViewMonth> _ensureContainsToday(
    List<_CalendarViewMonth> events, DateTime now) {
  DateTime today = DateTime(
    now.year,
    now.month,
    now.day,
  );
  DateTime thisMonth = DateTime(
    now.year,
    now.month,
  );
  for (var i = 0; i < events.length; i++) {
    if (events[i].month.isAfter(thisMonth)) {
      events.insert(i, _CalendarViewMonth(month: thisMonth, events: []));
      events[i].days.add(_CalendarViewDay(day: today, events: []));

      return events;
    }
    if (events[i].month == thisMonth) {
      for (var j = 0; j < events[i].days.length; j++) {
        if (events[i].days[j].day == today) return events;
        if (events[i].days[j].day.isAfter(today)) {
          events[i].days.insert(j, _CalendarViewDay(day: today, events: []));
          return events;
        }
      }
      return events;
    }
  }
  return events;
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

  final GlobalKey? todayKey;
  final GlobalKey? thisMonthKey;

  final Key centerkey = UniqueKey();
  final ScrollController controller;
  final CalendarState calendarState;
  final Function() loadMoreUp;
  final List<_CalendarViewMonth> _monthGroupedEventsUp;
  final List<_CalendarViewMonth> _monthGroupedEventsDown;
  final bool _enableLoadMore;

  final DateTime now;

  CalendarScrollView({
    Key? key,
    required this.controller,
    required this.calendarState,
    required this.loadMoreUp,
    this.todayKey,
    this.thisMonthKey,
    required this.now,
  })  : _monthGroupedEventsUp = _groupByMonth(calendarState.resultsUp)
            .sortedBy((element) => element.month)
            .reversed
            .toList(),
        _monthGroupedEventsDown = _ensureContainsToday(
            _groupByMonth(calendarState.resultsDown)
                .sortedBy((element) => element.month),
            now),
        _enableLoadMore = !calendarState.isDoneUp &&
            calendarState.resultsUp.isNotEmpty &&
            calendarState.resultsDown.isNotEmpty,
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
    ScrollPhysics scrollPhysics = const AlwaysScrollableScrollPhysics();
    return Column(
      children: [
        if (_enableLoadMore)
          AnimatedLoader(
            visible: calendarState.isLoadingMoreUp,
          ),
        Expanded(
          child: CustomScrollView(
            controller: controller,
            physics: _enableLoadMore
                ? OnTopCallbackScrollPhysics(
                    parent: BouncingScrollPhysics(
                        decelerationRate: ScrollDecelerationRate.fast,
                        parent: scrollPhysics),
                    onhittop: loadMoreUp,
                  )
                : scrollPhysics,
            center: centerkey,
            slivers: [
              if (_enableLoadMore)
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
                    (_, index) => _CalendarMonth(
                      events: _monthGroupedEventsUp[index],
                      todayKey: todayKey,
                      thisMonthKey: thisMonthKey,
                      now: now,
                    ),
                    childCount: _monthGroupedEventsUp.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                key: centerkey,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => _CalendarMonth(
                      events: _monthGroupedEventsDown[index],
                      todayKey: todayKey,
                      thisMonthKey: thisMonthKey,
                      now: now,
                    ),
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
        ),
      ],
    );
  }
}

class _CalendarMonth extends StatelessWidget {
  final _CalendarViewMonth events;
  final Key? todayKey;
  final Key? thisMonthKey;
  final DateTime now;

  static final monthFormatter = DateFormat('MMMM');
  static final monthYearFormatter = DateFormat('MMMM yyyy');

  const _CalendarMonth(
      {required this.events,
      this.todayKey,
      this.thisMonthKey,
      required this.now});

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime(
      now.year,
      now.month,
      now.day,
    );
    DateTime thisMonth = DateTime(
      now.year,
      now.month,
    );
    return StickyHeader(
      header: Column(
        key: events.month == thisMonth ? thisMonthKey : null,
        children: [
          SizedBox(
            width: double.infinity,
            child: Material(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  events.month.year == now.year
                      ? monthFormatter
                          .format(events.month.toLocal())
                          .toUpperCase()
                      : monthYearFormatter
                          .format(events.month.toLocal())
                          .toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final day in events.byDay())
            _DayCard(
                day: day.day,
                events: day.events,
                now: now,
                key: day.day == today ? todayKey : null),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime day;
  final DateTime now;
  final List<Widget> eventWidgets;

  static final dayFormatter = DateFormat(DateFormat.ABBR_WEEKDAY);

  _DayCard(
      {required DateTime day,
      required List<CalendarEvent> events,
      required this.now,
      Key? key})
      : eventWidgets = events.map((event) => _EventCard(event)).toList(),
        day = day.toLocal(),
        super(key: key ?? ValueKey(day));

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final textTheme = Theme.of(context).textTheme;
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
                  dayFormatter.format(day).toUpperCase(),
                  style: textTheme.bodySmall!.apply(
                      color: day == today
                          ? magenta
                          : textTheme.bodySmall!.color!.withOpacity(0.5)),
                ),
                Text(
                  day.day.toString(),
                  style: textTheme.displaySmall!.apply(
                      color: day == today
                          ? magenta
                          : textTheme.displaySmall!.color!.withOpacity(0.5)),
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
            children: eventWidgets.isNotEmpty
                ? eventWidgets
                : [
                    Center(
                      child: Text(
                        'There are no events this day',
                        style: TextStyle(
                          color: day == today
                              ? magenta
                              : textTheme.displaySmall!.color!.withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        strutStyle: const StrutStyle(
                          forceStrutHeight: true,
                          leading: 4,
                        ),
                      ),
                    )
                  ],
          ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final CalendarEvent event;

  _EventCard(this.event) : super(key: ObjectKey(event));

  void openEvent(BuildContext context) {
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
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    if (event.parentEvent is Event &&
        (event.parentEvent as Event).isRegistered) {
      color = Theme.of(context).highlightColor;
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
          onTap: () => openEvent(context),
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

class OnTopCallbackScrollPhysics extends ScrollPhysics {
  final Function() onhittop;

  const OnTopCallbackScrollPhysics({super.parent, required this.onhittop});

  @override
  OnTopCallbackScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OnTopCallbackScrollPhysics(
        parent: buildParent(ancestor), onhittop: onhittop);
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if (position.pixels < position.minScrollExtent) {
      onhittop();
    }

    return super.createBallisticSimulation(position, velocity);
  }
}
