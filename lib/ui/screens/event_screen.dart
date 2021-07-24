import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/event_cubit.dart';
import 'package:reaxit/blocs/event_list_bloc.dart';
import 'package:reaxit/blocs/payment_user_cubit.dart';
import 'package:reaxit/blocs/registrations_cubit.dart';
import 'package:reaxit/blocs/welcome_cubit.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/ui/router.dart';
import 'package:reaxit/ui/screens/event_admin_screen.dart';
import 'package:reaxit/ui/screens/registration_screen.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
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

  @override
  void dispose() {
    _eventCubit.close();
    _registrationsCubit.close();
    super.dispose();
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
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 300),
            placeholder: 'assets/img/map_placeholder.png',
            image: event.mapsUrl,
          ),
        ),
      ),
    );
  }

  Widget _makeEventInfo(Event event) {
    // TODO @LCKnol: make info
    return const Text('info');
  }

  Widget _makeRegistrationInfo(Event event) {
    return BlocBuilder<PaymentUserCubit, PaymentUserState>(
      builder: (context, paymentUserState) {
        // TODO: Add disabled versions when registration is not yet or not anymore
        //  possible? Or at least a text that describes this.
        // TODO: Handle being in queue!

        late Widget updateButton;
        // Update registration button.
        if (event.canUpdateRegistration &&
            event.isRegistered &&
            event.hasFields) {
          updateButton = SizedBox(
            key: const ValueKey('update'),
            width: double.infinity,
            child: Padding(
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
                icon: const Icon(Icons.build),
                label: const Text('UPDATE REGISTRATION'),
              ),
            ),
          );
        } else {
          updateButton = const SizedBox.shrink();
        }

        late Widget registrationButton;
        // Create or cancel registration buttons.
        if (event.canCreateRegistration && event.registrationIsRequired) {
          // TODO: Join queue version: `if event.reached_max_participants`.
          // TODO: Confirmation dialog if deregistration deadline has passed.
          registrationButton = SizedBox(
            key: const ValueKey('register'),
            width: double.infinity,
            child: Padding(
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
                    BlocProvider.of<EventListBloc>(context).add(
                      EventListEvent.load(),
                    );
                  } on ApiException {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Could not register for the event.'),
                      duration: Duration(seconds: 1),
                    ));
                  }
                  await _registrationsCubit.load(event.pk);
                },
                icon: const Icon(Icons.create_outlined),
                label: const Text('REGISTER'),
              ),
            ),
          );
        } else if (event.canCreateRegistration &&
            !event.registrationIsRequired) {
          registrationButton = SizedBox(
            key: const ValueKey('register'),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await _eventCubit.register(event.pk);
                    await _registrationsCubit.load(event.pk);
                    BlocProvider.of<EventListBloc>(context).add(
                      EventListEvent.load(),
                    );
                  } on ApiException {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Could not register for the event.'),
                      duration: Duration(seconds: 1),
                    ));
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text("I'LL BE THERE"),
              ),
            ),
          );
        } else if (event.canCancelRegistration &&
            event.registrationIsRequired) {
          // TODO: Confirmation dialog, with money warning text if deadline has passed.
          registrationButton = SizedBox(
            key: const ValueKey('cancel'),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () async {
                  // TODO: The confirmation dialog.
                  try {
                    await _eventCubit.cancelRegistration(
                      eventPk: event.pk,
                      registrationPk: event.userRegistration!.pk,
                    );
                  } on ApiException {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Could not cancel your registration'),
                      duration: Duration(seconds: 1),
                    ));
                  }
                  await _registrationsCubit.load(event.pk);
                  BlocProvider.of<EventListBloc>(context).add(
                    EventListEvent.load(),
                  );
                  await BlocProvider.of<WelcomeCubit>(context).load();
                },
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('CANCEL REGISTRATION'),
              ),
            ),
          );
        } else if (event.canCancelRegistration &&
            !event.registrationIsRequired) {
          registrationButton = SizedBox(
            key: const ValueKey('cancel'),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await _eventCubit.cancelRegistration(
                      eventPk: event.pk,
                      registrationPk: event.userRegistration!.pk,
                    );
                    await _registrationsCubit.load(event.pk);
                    BlocProvider.of<EventListBloc>(context).add(
                      EventListEvent.load(),
                    );
                  } on ApiException {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Could not cancel your registration'),
                      duration: Duration(seconds: 1),
                    ));
                  }
                },
                icon: const Icon(Icons.clear),
                label: const Text("I WON'T BE THERE"),
              ),
            ),
          );
        } else {
          registrationButton = const SizedBox.shrink();
        }

        late Widget registrationInfoText;
        // TODO: Registration-related info text.
        registrationInfoText = const SizedBox.shrink();

        late Widget paymentWidget;
        if (event.isInvited && event.paymentIsRequired) {
          if (event.userRegistration!.isPaid) {
            paymentWidget = const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('You have paid.'),
            );
          } else if (paymentUserState.result == null) {
            // PaymentUser loading or exception.
            paymentWidget = const SizedBox.shrink();
          } else if (!paymentUserState.result!.tpayAllowed) {
            // TPay is not allowed.
            paymentWidget = const SizedBox.shrink();
          } else if (!event.userRegistration!.tpayAllowed) {
            // TPay is not allowed.
            paymentWidget = const SizedBox.shrink();
          } else if (!paymentUserState.result!.tpayEnabled) {
            // TPay is not enabled.
            paymentWidget = SizedBox(
              key: const ValueKey('enable'),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Tooltip(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(8),
                  message: 'To start using Thalia Pay, sign '
                      'a direct debit mandate on the website.',
                  child: ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.euro),
                    label: Text('THALIA PAY: €${event.price}'),
                  ),
                ),
              ),
            );
          } else {
            // TPay can be used.
            paymentWidget = SizedBox(
              key: const ValueKey('pay'),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Confirm payment'),
                          content: Text(
                            'Are you sure you want to pay €${event.price} for '
                            'your registration to "${event.title}"?',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          actions: [
                            TextButton.icon(
                              onPressed: () => Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pop(false),
                              icon: const Icon(Icons.clear),
                              label: const Text('CANCEL'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pop(true),
                              icon: const Icon(Icons.check),
                              label: const Text('YES'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed ?? false) {
                      try {
                        await _eventCubit.thaliaPayRegistration(
                          eventPk: event.pk,
                          registrationPk: event.userRegistration!.pk,
                        );
                      } on ApiException {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not pay your order.'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.euro),
                  label: Text('THALIA PAY: €${event.price}'),
                ),
              ),
            );
          }
        } else {
          paymentWidget = const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: make padding nice
            // TODO: disclaimers and fine warnings
            AnimatedSize(
              vsync: this,
              curve: Curves.ease,
              duration: const Duration(milliseconds: 200),
              child: AnimatedSwitcher(
                switchInCurve: Curves.ease,
                switchOutCurve: Curves.ease,
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: updateButton,
              ),
            ),
            AnimatedSize(
              vsync: this,
              curve: Curves.ease,
              duration: const Duration(milliseconds: 200),
              child: AnimatedSwitcher(
                switchInCurve: Curves.ease,
                switchOutCurve: Curves.ease,
                duration: const Duration(milliseconds: 200),
                // transitionBuilder: (Widget child, Animation<double> animation) {
                //   return ScaleTransition(scale: animation, child: child);
                // },
                child: registrationInfoText,
              ),
            ),
            AnimatedSize(
              vsync: this,
              curve: Curves.ease,
              duration: const Duration(milliseconds: 200),
              child: AnimatedSwitcher(
                switchInCurve: Curves.ease,
                switchOutCurve: Curves.ease,
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: registrationButton,
              ),
            ),
            AnimatedSize(
              vsync: this,
              curve: Curves.ease,
              duration: const Duration(milliseconds: 200),
              child: AnimatedSwitcher(
                switchInCurve: Curves.ease,
                switchOutCurve: Curves.ease,
                duration: const Duration(milliseconds: 200),
                // transitionBuilder: (Widget child, Animation<double> animation) {
                //   return ScaleTransition(scale: animation, child: child);
                // },
                child: paymentWidget,
              ),
            ),
            const SizedBox(height: 5),
          ],
        );
      },
    );
  }

  Widget _makeDescription(Event event) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: HtmlWidget(
        event.description,
        onTapUrl: (String url) async {
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Could not open '$url'."),
              duration: const Duration(seconds: 1),
            ));
          }
        },
      ),
    );
  }

  SliverPadding _makeRegistrations(RegistrationsState state) {
    if (state.isLoading) {
      return const SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 10),
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
        padding: const EdgeInsets.all(10),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            stops: const [0.4, 1.0],
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
    return BlocBuilder<EventCubit, EventState>(
      bloc: _eventCubit,
      builder: (context, state) {
        if (state.hasException) {
          return Scaffold(
            appBar: ThaliaAppBar(title: Text(widget.event?.title ?? 'EVENT')),
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
            appBar: ThaliaAppBar(title: const Text('EVENT')),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          final event = (state.result ?? widget.event)!;
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text(event.title),
              actions: [
                if (event.userPermissions.manageEvent)
                  IconButton(
                    icon: const Icon(Icons.settings),
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
              child: BlocBuilder<RegistrationsCubit, RegistrationsState>(
                bloc: _registrationsCubit,
                builder: (context, state) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _makeMap(event),
                            _makeEventInfo(event),
                            _makeRegistrationInfo(event),
                            const Divider(),
                            _makeDescription(event),
                            const Divider(),
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
