import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/blocs/event_cubit.dart';
import 'package:reaxit/blocs/registrations_cubit.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/event_registration.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:reaxit/ui/screens/event_admin_screen.dart';
import 'package:reaxit/ui/screens/registration_screen.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/ui/widgets/member_tile.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

class EventScreen extends StatefulWidget {
  final int pk;
  final Event? event;

  EventScreen({required this.pk, this.event}) : super(key: ValueKey(pk));

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen>
    with TickerProviderStateMixin {
  late final EventCubit _eventCubit;
  late final RegistrationsCubit _registrationsCubit;

  @override
  void initState() {
    final api = RepositoryProvider.of<ApiRepository>(context);
    _eventCubit = EventCubit(api)..load(widget.pk);
    _registrationsCubit = RegistrationsCubit(api)..load(widget.pk);
    super.initState();
  }

  Widget _makeMap(Event event) {
    return Link(
      uri: Uri.parse(
        'https://maps.${Platform.isIOS ? 'apple' : 'google'}.com'
        '/maps?daddr=${Uri.encodeComponent(event.location)}',
      ),
      builder: (context, followLink) => GestureDetector(
        onTap: followLink,
        child: Center(
          child: FadeInImage.assetNetwork(
            fadeInDuration: Duration(milliseconds: 300),
            fadeOutDuration: Duration(milliseconds: 300),
            placeholder: 'assets/img/map_placeholder.png',
            image: event.mapsUrl,
          ),
        ),
      ),
    );
  }

  Widget _makeInfo(Event event) {
    // TODO @LCKnol: make info
    return Text('info');
  }

  Widget _makeButtons(Event event) {
    Widget? registrationButton;
    // TODO: add disabled versions when registration is not yet or not anymore possible
    if (event.canCreateRegistration && event.registrationIsRequired) {
      registrationButton = Column(
        key: ValueKey('register'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  final registration = await _eventCubit.register(event.pk);
                  if (event.hasFields) {
                    ThaliaRouterDelegate.of(context).push(
                      MaterialPage(
                        child: RegistrationScreen(
                          eventPk: event.pk,
                          registrationPk: registration.pk,
                        ),
                      ),
                    );
                  }
                } on ApiException {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Could not register for the event.'),
                    duration: Duration(seconds: 1),
                  ));
                }
                await _registrationsCubit.load(event.pk);
              },
              icon: Icon(Icons.create_outlined),
              label: Text('REGISTER'),
            ),
          ),
        ],
      );
    } else if (event.canCreateRegistration && !event.registrationIsRequired) {
      registrationButton = Column(
        key: ValueKey('register'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await _eventCubit.register(event.pk);
                  await _registrationsCubit.load(event.pk);
                } on ApiException {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Could not register for the event.'),
                    duration: Duration(seconds: 1),
                  ));
                }
              },
              icon: Icon(Icons.check),
              label: Text("I'LL BE THERE"),
            ),
          ),
        ],
      );
    } else if (event.canCancelRegistration && event.registrationIsRequired) {
      registrationButton = Column(
        key: ValueKey('cancel'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () async {
                // TODO: confirmation dialog.
                try {
                  await _eventCubit.cancelRegistration(event.pk);
                  await _registrationsCubit.load(event.pk);
                } on ApiException {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Could not cancel your registration'),
                    duration: Duration(seconds: 1),
                  ));
                }
              },
              icon: Icon(Icons.delete_forever_outlined),
              label: Text('CANCEL REGISTRATION'),
            ),
          ),
        ],
      );
    } else if (event.canCancelRegistration && !event.registrationIsRequired) {
      registrationButton = Column(
        key: ValueKey('cancel'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await _eventCubit.cancelRegistration(event.pk);
                  await _registrationsCubit.load(event.pk);
                } on ApiException {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Could not cancel your registration'),
                    duration: Duration(seconds: 1),
                  ));
                }
              },
              icon: Icon(Icons.clear),
              label: Text("I WON'T BE THERE"),
            ),
          ),
        ],
      );
    }

    Widget? updateButton;
    if (event.canUpdateRegistration && event.isRegistered && event.hasFields) {
      updateButton = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                ThaliaRouterDelegate.of(context).push(
                  MaterialPage(
                    child: RegistrationScreen(
                      eventPk: event.pk,
                      registrationPk: event.userRegistration!.pk,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.build),
              label: Text('UPDATE REGISTRATION'),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // TODO: make padding nice
        // TODO: disclaimers and fine warnings
        AnimatedSize(
          vsync: this,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
          child: AnimatedSwitcher(
            switchInCurve: Curves.ease,
            switchOutCurve: Curves.ease,
            duration: Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: registrationButton ?? SizedBox(height: 0),
          ),
        ),
        AnimatedSize(
          vsync: this,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
          child: AnimatedSwitcher(
            switchInCurve: Curves.ease,
            switchOutCurve: Curves.ease,
            duration: Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: updateButton ?? SizedBox(height: 0),
          ),
        ),
        SizedBox(height: 5),
      ],
    );
  }

  Widget _makeDescription(Event event) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: HtmlWidget(
        event.description,
        onTapUrl: (String url) async {
          if (await canLaunch(url)) {
            launch(url);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Could not open '$url'."),
              duration: Duration(seconds: 1),
            ));
          }
        },
      ),
    );
  }

  SliverPadding _makeRegistrations(DetailState<List<EventRegistration>> state) {
    if (state.isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else if (state.hasException) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        sliver: SliverToBoxAdapter(
          child: Center(child: Text(state.message!)),
        ),
      );
    } else {
      return SliverPadding(
        padding: EdgeInsets.all(10),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (state.result![index].member != null) {
                return MemberTile(
                  member: state.result![index].member!,
                );
              } else {
                return InkWell(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/image/default-avatar.jpg'),
                      Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.bottomLeft,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.0),
                              Colors.black.withOpacity(0.5),
                            ],
                            stops: [0.4, 1.0],
                          ),
                        ),
                        child: Text(
                          state.result![index].name!,
                          style: Theme.of(context).primaryTextTheme.bodyText2,
                        ),
                      )
                    ],
                  ),
                );
              }
            },
            childCount: state.result!.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, DetailState<Event>>(
      bloc: _eventCubit,
      builder: (context, state) {
        if (state.hasException) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.event?.title ?? 'Event')),
            body: RefreshIndicator(
              onRefresh: () async {
                // Await both loads.
                var eventFuture = _eventCubit.load(widget.pk);
                await _registrationsCubit.load(widget.pk);
                await eventFuture;
              },
              child: ErrorScrollView(state.message!),
            ),
          );
        } else if (state.isLoading &&
            widget.event == null &&
            state.result == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Event')),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          final event = (state.result ?? widget.event)!;
          return Scaffold(
            appBar: AppBar(
              title: Text(event.title),
              actions: [
                if (event.userPermissions.manageEvent)
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      ThaliaRouterDelegate.of(context).push(
                        MaterialPage(child: EventAdminScreen(pk: event.pk)),
                      );
                    },
                  ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () => _eventCubit.load(widget.pk),
              child: BlocBuilder<RegistrationsCubit,
                  DetailState<List<EventRegistration>>>(
                bloc: _registrationsCubit,
                builder: (context, state) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _makeMap(event),
                            _makeInfo(event),
                            _makeButtons(event),
                            Divider(),
                            _makeDescription(event),
                            Divider(),
                          ],
                        ),
                      ),
                      _makeRegistrations(state),
                    ],
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}
