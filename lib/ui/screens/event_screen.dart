import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/calendar_cubit.dart';
import 'package:reaxit/blocs/event_cubit.dart';
import 'package:reaxit/blocs/payment_user_cubit.dart';
import 'package:reaxit/blocs/registrations_cubit.dart';
import 'package:reaxit/blocs/welcome_cubit.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/payment.dart';
import 'package:reaxit/ui/router.dart';
import 'package:reaxit/ui/screens/event_admin_screen.dart';
import 'package:reaxit/ui/screens/registration_screen.dart';
import 'package:reaxit/ui/screens/food_screen.dart';
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

class _EventScreenState extends State<EventScreen> {
  static final dateTimeFormatter = DateFormat('d MMM y, HH:mm');

  late final EventCubit _eventCubit;
  late final RegistrationsCubit _registrationsCubit;

  @override
  void initState() {
    final api = RepositoryProvider.of<ApiRepository>(context);
    _eventCubit = EventCubit(api, eventPk: widget.pk)..load();
    _registrationsCubit = RegistrationsCubit(api, eventPk: widget.pk)..load();
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
      builder: (context, followLink) => Stack(
        fit: StackFit.loose,
        children: [
          FadeInImage.assetNetwork(
            fit: BoxFit.fitWidth,
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 300),
            placeholder: 'assets/img/map_placeholder.png',
            image: event.mapsUrl,
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: followLink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Someday: add animations back in.

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          event.title.toUpperCase(),
          style: textTheme.headline6,
        ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('From', style: textTheme.caption),
            Text('Until', style: textTheme.caption)
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                dateTimeFormatter.format(event.start.toLocal()),
                style: textTheme.subtitle2,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                dateTimeFormatter.format(event.end.toLocal()),
                style: textTheme.subtitle2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Location', style: textTheme.caption),
            Text('Price', style: textTheme.caption)
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                event.location,
                style: textTheme.subtitle2,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '€${event.price}',
              style: textTheme.subtitle2,
            ),
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

    if (event.registration == null) {
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
        if (event.canCreateRegistration) {
          if (event.reachedMaxParticipants) {
            registrationButton = _makeJoinQueueButton(event);
          } else {
            registrationButton = _makeCreateRegistrationButton(event);
          }
        }
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
        if (event.canCancelRegistration) {
          if (event.cancelDeadlinePassed()) {
            // Cancellation possible without fine, cancel button.
            textSpans.add(const TextSpan(
              text: 'Cancellation while on the waiting list will not result in '
                  'having to pay a fine. Do note that you will be unable to re-'
                  'register. ',
            ));
          }
          const text = 'Are you sure you want to cancel your registration?';
          registrationButton = _makeCancelRegistrationButton(event, text);
        }
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
        if (event.canCancelRegistration) {
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
      }
    }

    return BlocBuilder<PaymentUserCubit, PaymentUserState>(
      builder: (context, paymentUserState) {
        late Widget updateButton;
        if (event.canUpdateRegistration) {
          updateButton = _makeUpdateButton(event);
        } else {
          updateButton = const SizedBox.shrink();
        }

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
            // const SizedBox(height: 4),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.registrationStart!.isAfter(DateTime.now())) ...[
                      Text(
                        'Registration start:',
                        style: labelStyle,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      'Registration deadline:',
                      style: labelStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cancellation deadline:',
                      style: labelStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Number of registrations:',
                      style: labelStyle,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.registrationStart!.isAfter(DateTime.now())) ...[
                        Text(
                          dateTimeFormatter.format(
                            event.registrationStart!.toLocal(),
                          ),
                          style: dataStyle,
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        dateTimeFormatter
                            .format(event.registrationEnd!.toLocal()),
                        style: dataStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateTimeFormatter
                            .format(event.cancelDeadline!.toLocal()),
                        style: dataStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.maxParticipants == null
                            ? '${event.numParticipants} registrations'
                            : '${event.numParticipants} registrations '
                                '(${event.maxParticipants} max)',
                        style: dataStyle,
                      ),
                    ],
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

    if (event.isInvited) {
      textSpans.add(const TextSpan(text: 'You are registered. '));
      if (event.canCancelRegistration) {
        registrationButton = _makeIWontBeThereButton(event);
      }
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

    late Widget updateButton;
    if (event.canUpdateRegistration) {
      updateButton = _makeUpdateButton(event);
    } else {
      updateButton = const SizedBox.shrink();
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
              ThaliaRouterDelegate.of(context).push(
                TypedMaterialPage(
                  child: RegistrationScreen(
                    eventPk: event.pk,
                    registrationPk: registration.pk,
                  ),
                  name: 'Registration(event: ${event.pk}, '
                      'registration: ${registration.pk})',
                ),
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
            ThaliaRouterDelegate.of(context).push(
              TypedMaterialPage(
                child: RegistrationScreen(
                  eventPk: event.pk,
                  registrationPk: registration.pk,
                ),
                name: 'Registration(event: ${event.pk}, '
                    'registration: ${registration.pk})',
              ),
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
      onPressed: () {
        ThaliaRouterDelegate.of(context).push(
          TypedMaterialPage(
            child: RegistrationScreen(
              eventPk: event.pk,
              registrationPk: event.registration!.pk,
            ),
            name: 'Registration(event: ${event.pk}, '
                'registration: ${event.registration!.pk})',
          ),
        );
      },
      icon: const Icon(Icons.build),
      label: const Text('UPDATE REGISTRATION'),
    );
  }

  Widget _makeFoodButton(Event event) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ThaliaRouterDelegate.of(context).push(
            TypedMaterialPage(
              child: FoodScreen(
                pk: event.foodEvent!,
                event: event,
              ),
              name: 'FoodEvent(${event.foodEvent})',
            ),
          );
        },
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
    const url = 'https://staging.thalia.nu/event-registration-terms/';
    return TextSpan(
      children: [
        const TextSpan(
          text: 'By registering, you confirm that you have read the ',
        ),
        TextSpan(
          text: 'terms and conditions',
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunch(url)) {
                await launch(url, forceSafariVC: false);
              } else {
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
          if (await canLaunch(url)) {
            await launch(url, forceSafariVC: false);
          } else {
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

  Widget _makeRegistrationsHeader() {
    return Padding(
        padding: EdgeInsets.only(left: 16),
        child:
            Text("Registrations", style: Theme.of(context).textTheme.caption));
  }

  SliverPadding _makeRegistrations(RegistrationsState state) {
    if (state.isLoading) {
      return const SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else if (state.hasException) {
      return SliverPadding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        sliver: SliverToBoxAdapter(
          child: Center(child: Text(state.message!)),
        ),
      );
    } else {
      return SliverPadding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
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
            appBar: ThaliaAppBar(
              title: Text(widget.event?.title.toUpperCase() ?? 'EVENT'),
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
            appBar: ThaliaAppBar(title: const Text('EVENT')),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          final event = (state.result ?? widget.event)!;
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text(event.title.toUpperCase()),
              actions: [
                if (event.userPermissions.manageEvent)
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      ThaliaRouterDelegate.of(context).push(
                        TypedMaterialPage(
                          child: EventAdminScreen(pk: event.pk),
                          name: 'EventAdmin(${event.pk})',
                        ),
                      );
                    },
                  ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () => _eventCubit.load(),
              child: BlocBuilder<RegistrationsCubit, RegistrationsState>(
                bloc: _registrationsCubit,
                builder: (context, state) {
                  return CustomScrollView(
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
                            const Divider(),
                            _makeRegistrationsHeader(),
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
