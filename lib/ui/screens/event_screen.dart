import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/calendar_cubit.dart';
import 'package:reaxit/blocs/event_cubit.dart';
import 'package:reaxit/blocs/payment_user_cubit.dart';
import 'package:reaxit/blocs/registrations_cubit.dart';
import 'package:reaxit/blocs/welcome_cubit.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/payment.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/cached_image.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/ui/widgets/member_tile.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reaxit/config.dart' as config;

class EventScreen extends StatefulWidget {
  final int pk;
  final Event? event;

  EventScreen({required this.pk, this.event}) : super(key: ValueKey(pk));

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  static final dateTimeFormatter = DateFormat('E d MMM y, HH:mm');

  late ScrollController _controller;

  late final EventCubit _eventCubit;
  late final RegistrationsCubit _registrationsCubit;

  @override
  void initState() {
    final api = RepositoryProvider.of<ApiRepository>(context);
    _eventCubit = EventCubit(api, eventPk: widget.pk)..load();
    _registrationsCubit = RegistrationsCubit(api, eventPk: widget.pk)..load();
    _controller = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      // Only request loading more if that's not already happening.
      if (!_registrationsCubit.state.isLoadingMore) {
        _registrationsCubit.more();
      }
    }
  }

  @override
  void dispose() {
    _eventCubit.close();
    _registrationsCubit.close();
    super.dispose();
  }

  Widget _makeMap(Event event) {
    return Stack(
      fit: StackFit.loose,
      children: [
        CachedImage(
          imageUrl: event.mapsUrl,
          placeholder: 'assets/img/map_placeholder.png',
          fit: BoxFit.cover,
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Uri url = Theme.of(context).platform == TargetPlatform.iOS
                    ? Uri(
                        scheme: 'maps',
                        queryParameters: {'daddr': event.location})
                    : Uri(
                        scheme: 'https',
                        host: 'maps.google.com',
                        path: 'maps',
                        queryParameters: {'daddr': event.location},
                      );
                launch(
                  url.toString(),
                  forceSafariVC: false,
                  forceWebView: false,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Create all info of an event until the description, including buttons.
  Widget _makeEventInfo(Event event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _makeBasicEventInfo(event),
          if (event.registrationIsRequired)
            _makeRequiredRegistrationInfo(event)
          else if (event.registrationIsOptional)
            _makeOptionalRegistrationInfo(event)
          else
            _makeNoRegistrationInfo(event),
          if (event.hasFoodEvent) _makeFoodButton(event),
        ],
      ),
    );
  }

  /// Create the title, start, end, location and price of an event.
  Widget _makeBasicEventInfo(Event event) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          event.title.toUpperCase(),
          style: textTheme.headline6,
        ),
        const Divider(height: 24),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FROM', style: textTheme.caption),
                  const SizedBox(height: 4),
                  Text(
                    dateTimeFormatter.format(event.start.toLocal()),
                    style: textTheme.subtitle2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('UNTIL', style: textTheme.caption),
                  const SizedBox(height: 4),
                  Text(
                    dateTimeFormatter.format(event.end.toLocal()),
                    style: textTheme.subtitle2,
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LOCATION', style: textTheme.caption),
                  const SizedBox(height: 4),
                  Text(
                    event.location,
                    style: textTheme.subtitle2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PRICE', style: textTheme.caption),
                  const SizedBox(height: 4),
                  Text(
                    '€${event.price}',
                    style: textTheme.subtitle2,
                  ),
                ],
              ),
            )
          ],
        ),
        const Divider(height: 24),
      ],
    );
  }

  // Create the info for events with required registration.
  Widget _makeRequiredRegistrationInfo(Event event) {
    assert(event.registrationIsRequired);
    final textTheme = Theme.of(context).textTheme;
    final dataStyle = textTheme.bodyText2!.apply(fontSizeDelta: -1);
    final labelStyle = textTheme.bodyText2!.apply(
      fontWeightDelta: 2,
      fontSizeDelta: -1,
    );

    final textSpans = <TextSpan>[];
    Widget registrationButton = const SizedBox.shrink();
    Widget updateButton = const SizedBox.shrink();

    if (event.canCreateRegistration) {
      if (event.reachedMaxParticipants) {
        registrationButton = _makeJoinQueueButton(event);
      } else {
        registrationButton = _makeCreateRegistrationButton(event);
      }
    } else if (event.canCancelRegistration) {
      if (event.cancelDeadlinePassed()) {
        // Cancel too late message, cancel button with fine warning.
        textSpans.add(TextSpan(
          text: event.cancelTooLateMessage,
        ));
        final text = 'The deadline has passed, are you sure you want '
            'to cancel your registration and pay the estimated full costs of '
            '€${event.fine}? You will not be able to undo this!';
        registrationButton = _makeCancelRegistrationButton(event, text);
      } else {
        // Cancel button.
        const text = 'Are you sure you want to cancel your registration?';
        registrationButton = _makeCancelRegistrationButton(event, text);
      }
    }

    if (event.canUpdateRegistration) {
      updateButton = _makeUpdateButton(event);
    }

    if (event.canCreateRegistration || !event.isRegistered) {
      if (!event.registrationStarted()) {
        // Registration will open ....
        final registrationStart = dateTimeFormatter.format(
          event.registrationStart!.toLocal(),
        );
        textSpans.add(TextSpan(
          text: 'Registration will open $registrationStart. ',
        ));
      } else if (event.registrationIsOpen()) {
        // Terms and conditions, register button.
        textSpans.add(_makeTermsAndConditions(event));
      } else if (event.registrationClosed()) {
        // Registration is no longer possible.
        textSpans.add(const TextSpan(
          text: 'Registration is not possible anymore. ',
        ));
      }
    } else {
      final registration = event.registration!;
      if (registration.isLateCancellation) {
        // Your registration is cancelled after the deadline.
        textSpans.add(const TextSpan(
          text: 'Your registration is cancelled after the deadline. ',
        ));
      } else if (registration.isCancelled) {
        // Your registration is cancelled.
        textSpans.add(const TextSpan(
          text: 'Your registration is cancelled. ',
        ));
      } else if (registration.isInQueue) {
        // Queue position.
        textSpans.add(TextSpan(
          text: 'Queue position ${registration.queuePosition}. ',
        ));
      } else if (registration.isInvited) {
        // You are registered.
        textSpans.add(const TextSpan(
          text: 'You are registered. ',
        ));
        if (event.paymentIsRequired) {
          if (registration.isPaid) {
            if (registration.payment!.type == PaymentType.tpayPayment) {
              // You are paying with Thalia Pay.
              textSpans.add(const TextSpan(
                text: 'You are paying with Thalia Pay. ',
              ));
            } else {
              // You have paid.
              textSpans.add(const TextSpan(
                text: 'You have paid. ',
              ));
            }
          } else {
            // You have not paid yet.
            textSpans.add(const TextSpan(
              text: 'You have not paid yet. ',
            ));
          }
        }
        if (event.hasEnded()) {
          if (registration.present ?? true) {
            // You were present.
            textSpans.add(const TextSpan(
              text: 'You were present. ',
            ));
          } else {
            // You were not present.
            textSpans.add(const TextSpan(
              text: 'You were not present. ',
            ));
          }
        }
      }
    }

    return BlocBuilder<PaymentUserCubit, PaymentUserState>(
      builder: (context, paymentUserState) {
        late Widget paymentButton;
        if (event.isInvited &&
            event.paymentIsRequired &&
            !event.registration!.isPaid) {
          paymentButton = _makePaymentButton(event, paymentUserState);
        } else {
          paymentButton = const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (event.registrationStart!.isAfter(DateTime.now())) ...[
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: Text('Registration start:', style: labelStyle),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    fit: FlexFit.tight,
                    child: Text(
                      dateTimeFormatter
                          .format(event.registrationStart!.toLocal()),
                      style: dataStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: Text('Registration deadline:', style: labelStyle),
                ),
                const SizedBox(width: 8),
                Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                    dateTimeFormatter.format(event.registrationEnd!.toLocal()),
                    style: dataStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: Text('Cancellation deadline:', style: labelStyle),
                ),
                const SizedBox(width: 8),
                Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                    dateTimeFormatter.format(event.cancelDeadline!.toLocal()),
                    style: dataStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: Text('Number of registrations:', style: labelStyle),
                ),
                const SizedBox(width: 8),
                Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                    event.maxParticipants == null
                        ? '${event.numParticipants} registrations'
                        : '${event.numParticipants} registrations '
                            '(${event.maxParticipants} max)',
                    style: dataStyle,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text.rich(
              TextSpan(children: textSpans),
              style: dataStyle,
            ),
            const SizedBox(height: 4),
            registrationButton,
            updateButton,
            paymentButton,
          ],
        );
      },
    );
  }

  // Create the info for events with optional registration.
  Widget _makeOptionalRegistrationInfo(Event event) {
    assert(event.registrationIsOptional);
    final textTheme = Theme.of(context).textTheme;
    final dataStyle = textTheme.bodyText2!.apply(fontSizeDelta: -1);

    final textSpans = <TextSpan>[];
    Widget registrationButton = const SizedBox.shrink();
    if (event.canCancelRegistration) {
      registrationButton = _makeIWontBeThereButton(event);
    }

    if (event.isInvited) {
      textSpans.add(const TextSpan(text: 'You are registered. '));
    } else if (event.canCreateRegistration) {
      textSpans.add(const TextSpan(
        text: 'Even though registration is not required for this event, you '
            'can still register to give an indication of who will be there, as '
            'well as mark the event as "registered" in your calendar. ',
      ));
      registrationButton = _makeIllBeThereButton(event);
    }

    if (event.noRegistrationMessage?.isNotEmpty ?? false) {
      textSpans.add(TextSpan(text: event.noRegistrationMessage));
    } else {
      textSpans.add(const TextSpan(text: 'No registration required.'));
    }

    Widget updateButton = const SizedBox.shrink();
    if (event.canUpdateRegistration) {
      updateButton = _makeUpdateButton(event);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(children: textSpans),
          style: dataStyle,
        ),
        const SizedBox(height: 4),
        registrationButton,
        updateButton,
      ],
    );
  }

  // Create the info for events without registration.
  Widget _makeNoRegistrationInfo(Event event) {
    assert(!event.registrationIsOptional && !event.registrationIsRequired);
    final textTheme = Theme.of(context).textTheme;
    final dataStyle = textTheme.bodyText2!.apply(fontSizeDelta: -1);

    final textSpans = <TextSpan>[];
    if (event.noRegistrationMessage?.isNotEmpty ?? false) {
      textSpans.add(TextSpan(text: event.noRegistrationMessage));
    } else {
      textSpans.add(const TextSpan(text: 'No registration required.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(children: textSpans),
          style: dataStyle,
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _makeIllBeThereButton(Event event) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          await _eventCubit.register();
          await _registrationsCubit.load();
          BlocProvider.of<CalendarCubit>(context).load();
        } on ApiException {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not register for the event.'),
          ));
        }
      },
      icon: const Icon(Icons.check),
      label: const Text("I'LL BE THERE"),
    );
  }

  Widget _makeIWontBeThereButton(Event event) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          await _eventCubit.cancelRegistration(
            registrationPk: event.registration!.pk,
          );
          await _registrationsCubit.load();
          BlocProvider.of<CalendarCubit>(context).load();
        } on ApiException {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not cancel your registration.'),
          ));
        }
      },
      icon: const Icon(Icons.clear),
      label: const Text("I WON'T BE THERE"),
    );
  }

  Widget _makeCreateRegistrationButton(Event event) {
    return ElevatedButton.icon(
      onPressed: () async {
        var confirmed = !event.cancelDeadlinePassed();
        if (!confirmed) {
          confirmed = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Register'),
                    content: Text(
                      'Are you sure you want to register? The '
                      'cancellation deadline has already passed.',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    actions: [
                      TextButton.icon(
                        onPressed: () => Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop(false),
                        icon: const Icon(Icons.clear),
                        label: const Text('NO'),
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
              ) ??
              false;
        }

        if (confirmed) {
          try {
            final registration = await _eventCubit.register();
            if (event.hasFields) {
              context.pushNamed(
                'event-registration',
                params: {'eventPk': event.pk.toString()},
                extra: registration,
              );
            }
            BlocProvider.of<CalendarCubit>(context).load();
          } on ApiException {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Could not register for the event.'),
            ));
          }
          await _registrationsCubit.load();
        }
      },
      icon: const Icon(Icons.create_outlined),
      label: const Text('REGISTER'),
    );
  }

  Widget _makeJoinQueueButton(Event event) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          final registration = await _eventCubit.register();
          if (event.hasFields) {
            context.pushNamed(
              'event-registration',
              params: {'eventPk': event.pk.toString()},
              extra: registration,
            );
          }
          BlocProvider.of<CalendarCubit>(context).load();
        } on ApiException {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not join the waiting list for the event.'),
          ));
        }
        await _registrationsCubit.load();
      },
      icon: const Icon(Icons.create_outlined),
      label: const Text('JOIN QUEUE'),
    );
  }

  Widget _makeCancelRegistrationButton(Event event, String warningText) {
    return ElevatedButton.icon(
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Cancel registration'),
              content: Text(
                warningText,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              actions: [
                TextButton.icon(
                  onPressed: () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(false),
                  icon: const Icon(Icons.clear),
                  label: const Text('NO'),
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
            await _eventCubit.cancelRegistration(
              registrationPk: event.registration!.pk,
            );
          } on ApiException {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Could not cancel your registration.'),
            ));
          }
        }
        await _registrationsCubit.load();
        BlocProvider.of<CalendarCubit>(context).load();
        await BlocProvider.of<WelcomeCubit>(context).load();
      },
      icon: const Icon(Icons.delete_forever_outlined),
      label: const Text('CANCEL REGISTRATION'),
    );
  }

  Widget _makeUpdateButton(Event event) {
    return ElevatedButton.icon(
      onPressed: () => context.pushNamed(
        'event-registration',
        params: {'eventPk': event.pk.toString()},
        extra: event.registration,
      ),
      icon: const Icon(Icons.build),
      label: const Text('UPDATE REGISTRATION'),
    );
  }

  Widget _makeFoodButton(Event event) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.pushNamed('food', extra: event),
        icon: const Icon(Icons.local_pizza),
        label: const Text('ORDER FOOD'),
      ),
    );
  }

  Widget _makePaymentButton(Event event, PaymentUserState paymentUserState) {
    if (paymentUserState.result == null) {
      // PaymentUser loading or exception.
      return const SizedBox.shrink();
    } else if (!paymentUserState.result!.tpayAllowed) {
      // TPay is not allowed.
      return const SizedBox.shrink();
    } else if (!event.registration!.tpayAllowed) {
      // TPay is not allowed.
      return const SizedBox.shrink();
    } else if (!paymentUserState.result!.tpayEnabled) {
      // TPay is not enabled.
      return SizedBox(
        key: const ValueKey('enable'),
        width: double.infinity,
        child: Tooltip(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(8),
          message: 'To start using Thalia Pay, sign '
              'a direct debit mandate on the website.',
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.euro),
            label: Text('THALIA PAY: €${event.price}'),
          ),
        ),
      );
    } else {
      // TPay can be used.
      return SizedBox(
        key: const ValueKey('pay'),
        width: double.infinity,
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
                  registrationPk: event.registration!.pk,
                );
              } on ApiException {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Could not pay your order.'),
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.euro),
          label: Text('THALIA PAY: €${event.price}'),
        ),
      );
    }
  }

  TextSpan _makeTermsAndConditions(Event event) {
    const url = config.termsAndConditionsUrl;
    return TextSpan(
      children: [
        const TextSpan(
          text: 'By registering, you confirm that you have read the ',
        ),
        TextSpan(
          text: 'terms and conditions',
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              try {
                await launch(
                  url,
                  forceSafariVC: false,
                  forceWebView: false,
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Could not open "$url".'),
                ));
              }
            },
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        const TextSpan(
          text: ', that you understand them and '
              'that you agree to be bound by them.',
        ),
      ],
    );
  }

  Widget _makeDescription(Event event) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      child: HtmlWidget(
        event.description,
        onTapUrl: (String url) async {
          try {
            await launch(
              url,
              forceSafariVC: false,
              forceWebView: false,
            );
          } catch (_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Could not open "$url".'),
            ));
          }
          return true;
        },
      ),
    );
  }

  SliverPadding _makeRegistrationsHeader(RegistrationsState state) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16),
      sliver: SliverToBoxAdapter(
        child: Text(
          'REGISTRATIONS',
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    );
  }

  SliverPadding _makeRegistrations(RegistrationsState state) {
    if (state.isLoading && state.results.isEmpty) {
      return const SliverPadding(
        padding: EdgeInsets.all(16),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else if (state.hasException) {
      return SliverPadding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
        sliver: SliverToBoxAdapter(child: Text(state.message!)),
      );
    } else {
      return SliverPadding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (state.results[index].member != null) {
                return MemberTile(
                  member: state.results[index].member!,
                );
              } else {
                return DefaultMemberTile(
                  name: state.results[index].name!,
                );
              }
            },
            childCount: state.results.length,
          ),
        ),
      );
    }
  }

  Widget _makeShareEventButton(int pk) {
    return IconButton(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryIconTheme.color,
      icon: Icon(
        Theme.of(context).platform == TargetPlatform.iOS
            ? Icons.ios_share
            : Icons.share,
      ),
      onPressed: () async {
        try {
          await Share.share('https://${config.apiHost}/events/$pk/');
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Could not share the event.'),
          ));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, EventState>(
      bloc: _eventCubit,
      builder: (context, state) {
        if (state.hasException) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text(widget.event?.title.toUpperCase() ?? 'EVENT'),
              actions: [_makeShareEventButton(widget.pk)],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                // Await both loads.
                var eventFuture = _eventCubit.load();
                await _registrationsCubit.load();
                await eventFuture;
              },
              child: ErrorScrollView(state.message!),
            ),
          );
        } else if (state.isLoading &&
            widget.event == null &&
            state.result == null) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: const Text('EVENT'),
              actions: [_makeShareEventButton(widget.pk)],
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else {
          final event = (state.result ?? widget.event)!;
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text(event.title.toUpperCase()),
              actions: [
                _makeShareEventButton(widget.pk),
                if (event.userPermissions.manageEvent)
                  IconButton(
                    padding: const EdgeInsets.all(16),
                    icon: const Icon(Icons.settings),
                    onPressed: () => context.pushNamed(
                      'event-admin',
                      params: {'eventPk': event.pk.toString()},
                    ),
                  ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () => _eventCubit.load(),
              child: BlocBuilder<RegistrationsCubit, RegistrationsState>(
                bloc: _registrationsCubit,
                builder: (context, listState) {
                  return Scrollbar(
                    controller: _controller,
                    child: CustomScrollView(
                      controller: _controller,
                      key: const PageStorageKey('event'),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _makeMap(event),
                              const Divider(height: 0),
                              _makeEventInfo(event),
                              const Divider(),
                              _makeDescription(event),
                            ],
                          ),
                        ),
                        if (event.registrationIsOptional ||
                            event.registrationIsRequired) ...[
                          const SliverToBoxAdapter(child: Divider()),
                          _makeRegistrationsHeader(listState),
                          _makeRegistrations(listState),
                          if (listState.isLoadingMore)
                            const SliverPadding(
                              padding: EdgeInsets.all(8),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate.fixed([
                                  Center(child: CircularProgressIndicator()),
                                ]),
                              ),
                            ),
                        ],
                      ],
                    ),
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
