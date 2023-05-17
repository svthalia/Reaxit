import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/theme.dart';
import 'package:reaxit/ui/widgets.dart';

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
    WidgetsBinding.instance.endOfFrame.then(
      (_) => _scrollToToday(false),
    );
    super.initState();
  }

  void _assureTodayOffset() {
    if (_todayOffset == null && todayKey.currentContext != null) {
      // Calculate the position the widget should be in to avoid being
      // drawn under the header
      final offset = thisMonthKey.currentContext!.size!.height;
      RenderObject renderObject = todayKey.currentContext!.findRenderObject()!;
      RenderAbstractViewport viewport = RenderAbstractViewport.of(renderObject);
      _todayOffset =
          viewport.getOffsetToReveal(renderObject, 0, rect: null).offset -
              offset;
    }
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

  void _scrollToToday(bool animate) {
    _assureTodayOffset();
    if (animate) {
      _controller.animateTo(
        _todayOffset ?? 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      _controller.jumpTo(_todayOffset ?? 0);
    }
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
          } else if (calendarState.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
        onPressed: () => _scrollToToday(true),
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
        } else if (calendarState.isLoading) {
          return const Center(child: CircularProgressIndicator());
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
    if (_controller.hasClients) {
      _controller.jumpTo(0);
    }
    return buildResults(context);
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

  final GlobalKey? todayKey;
  final GlobalKey? thisMonthKey;

  final Key centerkey = UniqueKey();
  final ScrollController controller;
  final CalendarState calendarState;
  final Function() loadMoreUp;
  final List<CalendarViewMonth> _monthGroupedEventsUp;
  final List<CalendarViewMonth> _monthGroupedEventsDown;
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
  })  : _monthGroupedEventsUp = groupByMonth(calendarState.resultsUp)
            .sortedBy((element) => element.month)
            .reversed
            .toList(),
        _enableLoadMore = !calendarState.isDoneUp &&
            calendarState.resultsUp.isNotEmpty &&
            calendarState.resultsDown.isNotEmpty,
        _monthGroupedEventsDown = calendarState.resultsDown.isEmpty
            ? List.empty()
            : ensureContainsToday(
                groupByMonth(calendarState.resultsDown)
                    .sortedBy((element) => element.month),
                now),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // If there are no future events we should still display some events
    final upEvents = _monthGroupedEventsDown.isEmpty && calendarState.isDoneDown
        ? _monthGroupedEventsUp.skip(1).toList()
        : _monthGroupedEventsUp;
    final downEvents = _monthGroupedEventsUp.isEmpty &&
            _monthGroupedEventsDown.isEmpty &&
            calendarState.isDoneDown
        ? [_monthGroupedEventsUp.first]
        : _monthGroupedEventsDown;
    ScrollPhysics scrollPhysics = const AlwaysScrollableScrollPhysics();
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            controller: controller,
            physics: _enableLoadMore
                ? OnTopCallbackScrollPhysics(
                    parent: BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast,
                      parent: scrollPhysics,
                    ),
                    onhittop: loadMoreUp,
                  )
                : scrollPhysics,
            center: centerkey,
            anchor: 0.0,
            slivers: [
              if (_enableLoadMore)
                SliverToBoxAdapter(
                  child: Text(
                    _enableLoadMore ? 'LOADING MORE' : 'SCROLL TO LOAD MORE',
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => CalendarMonth(
                      events: upEvents[index],
                      todayKey: todayKey,
                      thisMonthKey: thisMonthKey,
                      now: now,
                    ),
                    childCount: upEvents.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: downEvents.isEmpty
                    ? EdgeInsets.zero
                    : const EdgeInsets.fromLTRB(12, 0, 12, 12),
                key: centerkey,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => CalendarMonth(
                      events: downEvents[index],
                      todayKey: todayKey,
                      thisMonthKey: thisMonthKey,
                      now: now,
                    ),
                    childCount: downEvents.length,
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
