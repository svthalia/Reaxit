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
            return CalendarScrollView(
              key: const PageStorageKey('calendar'),
              controller: _controller,
              calendarState: calendarState,
              loadMoreUp: _cubit.moreUp,
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _controller.animateTo(0,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
        },
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
  final bool _enableLoadMore;

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

  void startLoadMoreUp() {
    controller.animateTo(controller.position.minScrollExtent,
        duration: const Duration(milliseconds: 100), curve: Curves.ease);
    loadMoreUp();
  }

  @override
  Widget build(BuildContext context) {
    ScrollPhysics scrollPhysics = const AlwaysScrollableScrollPhysics();

    return Scrollbar(
      controller: controller,
      child: CustomScrollView(
        controller: controller,
        physics: _enableLoadMore
            ? OverscrollableScrollPhysics(
                parent: scrollPhysics,
                onhittop: startLoadMoreUp,
              )
            : scrollPhysics,
        center: centerkey,
        slivers: [
          SliverToBoxAdapter(
            child: AnimatedLoader(
              visible: calendarState.isLoadingMoreUp,
            ),
          ),
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
                (_, index) =>
                    _CalendarMonth(events: _monthGroupedEventsUp[index]),
                childCount: _monthGroupedEventsUp.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            key: centerkey,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, index) =>
                    _CalendarMonth(events: _monthGroupedEventsDown[index]),
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

class _CalendarMonth extends StatelessWidget {
  final _CalendarViewMonth events;

  static final monthFormatter = DateFormat('MMMM');
  static final monthYearFormatter = DateFormat('MMMM yyyy');

  const _CalendarMonth({required this.events});

  @override
  Widget build(BuildContext context) {
    return StickyHeader(
      header: SizedBox(
        width: double.infinity,
        child: Material(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              events.month.year == DateTime.now().year
                  ? monthFormatter.format(events.month.toLocal()).toUpperCase()
                  : monthYearFormatter
                      .format(events.month.toLocal())
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
          for (final day in events.byDay())
            _DayCard(day: day.day, events: day.events),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime day;
  final List<Widget> eventWidgets;

  static final dayFormatter = DateFormat(DateFormat.ABBR_WEEKDAY);

  _DayCard({required DateTime day, required List<CalendarEvent> events})
      : eventWidgets = events.map((event) => _EventCard(event)).toList(),
        day = day.toLocal(),
        super(key: ValueKey(day));

  @override
  Widget build(BuildContext context) {
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
                      color: textTheme.bodySmall!.color!.withOpacity(0.5)),
                ),
                Text(
                  day.toLocal().day.toString(),
                  style: textTheme.displaySmall,
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
            children: eventWidgets,
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

class OverscrollableScrollPhysics extends ScrollPhysics {
  final Function() onhittop;

  const OverscrollableScrollPhysics({super.parent, required this.onhittop});

  @override
  OverscrollableScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OverscrollableScrollPhysics(
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

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) =>
      super.applyBoundaryConditions(
          position.copyWith(minScrollExtent: position.minScrollExtent), value) *
      0.9;
}
