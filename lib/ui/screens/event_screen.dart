import 'package:add_2_calendar/add_2_calendar.dart' as add2calendar;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/routes.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/dialog.dart';
import 'package:reaxit/ui/widgets/file_button.dart';
import 'package:reaxit/ui/widgets/paginated_scroll_view.dart';
import 'package:reaxit/ui/widgets/timed_state_enable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reaxit/config.dart';

class EventScreen extends StatefulWidget {
  final String? slug;
  final Event? event;
  final int? pk;

  const EventScreen({this.pk, this.slug, this.event})
    : assert(!(pk == null && slug == null));

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  static final dateTimeFormatter = DateFormat('E d MMM y, HH:mm');

  late final EventCubit _eventCubit;

  @override
  void initState() {
    final api = RepositoryProvider.of<ApiRepository>(context);
    _eventCubit = EventCubit(api, eventPk: widget.pk, eventSlug: widget.slug)
      ..load();
    super.initState();
  }

  @override
  void dispose() {
    _eventCubit.close();
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
                        queryParameters: {'daddr': event.location},
                      )
                    : Uri(
                        scheme: 'https',
                        host: 'maps.google.com',
                        path: 'maps',
                        queryParameters: {'daddr': event.location},
                      );
                launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Create all info of an event until the description, including buttons.
  Widget _makeEventInfo(Event event) {
    // List<ShiftInfo>? shifts = event.shiftSet;
    Iterable<Widget>? selforderShifts;
    // if (shifts != null) {
    //   selforderShifts = shifts.where((shift) => shift).map(
    //     (shift) => TimedEnableButton(
    //       open: shift.start,
    //       close: shift.end,
    //       builder: (context, controler, nextChange) =>
    //           _makeFoodShiftButton(shift, controler, nextChange),
    //     ),
    //   );
    // }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _makeBasicEventInfo(event),
          if (event.registrationIsRequired)
            TimedEnableButton(
              open: event.registrationStart,
              close: event.registrationEnd,
              onClose:
                  _eventCubit.load, // To be sure, testing without wasn't done
              builder: (context, controler, nextChange) =>
                  _makeRequiredRegistrationInfo(event, controler, nextChange),
            )
          else if (event.registrationIsOptional)
            _makeOptionalRegistrationInfo(event)
          else
            _makeNoRegistrationInfo(event),
          if (event.hasFoodEvent) _makeFoodButton(event),

          ...?selforderShifts,
        ],
      ),
    );
  }

  /// Makes a list of clickable organisers.
  Widget _makeOrganiserChildren(Event event) {
    final textTheme = Theme.of(context).textTheme;

    return RichText(
      text: TextSpan(
        children: [
          for (SmallGroup org in event.organisers)
            TextSpan(
              children: [
                if (org != event.organisers[0]) const TextSpan(text: ', '),
                TextSpan(
                  text: org.name,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      context.pushNamed(
                        'group',
                        pathParameters: {'groupPk': org.pk.toString()},
                      );
                    },
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
        ],
        style: textTheme.bodyLarge,
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
        Text(event.title.toUpperCase(), style: textTheme.titleLarge),
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
                  Text('FROM', style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    dateTimeFormatter.format(event.start.toLocal()),
                    style: textTheme.titleSmall,
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
                  Text('UNTIL', style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    dateTimeFormatter.format(event.end.toLocal()),
                    style: textTheme.titleSmall,
                  ),
                ],
              ),
            ),
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
                  Text('LOCATION', style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(event.location, style: textTheme.titleSmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PRICE', style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text('€${event.price}', style: textTheme.titleSmall),
                ],
              ),
            ),
          ],
        ),
        if (event.documents.isNotEmpty) const SizedBox(height: 12),
        if (event.documents.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DOCUMENTS', style: textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (Document doc in event.documents)
                          FileButton(url: doc.url, name: doc.name),
                      ],
                    ),
                  ],
                ),
              ),
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
                  Text('ORGANISERS', style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  _makeOrganiserChildren(event),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 24),
      ],
    );
  }

  // Create the info for events with required registration.
  Widget _makeRequiredRegistrationInfo(
    Event event,
    WidgetStatesController controler,
    DateTime? nextChange,
  ) {
    assert(event.registrationIsRequired);
    final textTheme = Theme.of(context).textTheme;
    final dataStyle = textTheme.bodyMedium!.apply(fontSizeDelta: -1);
    final labelStyle = textTheme.bodyMedium!.apply(
      fontWeightDelta: 2,
      fontSizeDelta: -1,
    );

    final textSpans = <TextSpan>[];
    final registrationStatusText = <TextSpan>[];
    Widget registrationButton = const SizedBox.shrink();

    if ((event.canCreateRegistration || event.createRegistrationWhenOpen) &&
        !event.registrationClosed()) {
      // You can register, or will be as soon as it opens
      registrationButton = TimedIconButton(
        controller: controler,
        onPressed: () =>
            event.reachedMaxParticipants ? joinQueue(event) : register(event),
        nextChange: event.registrationStarted() ? null : nextChange,
        icon: const Icon(Icons.create_outlined),
        labelText: event.reachedMaxParticipants ? 'JOIN QUEUE' : 'REGISTER',
        opensPrefix: 'OPENS IN',
        closesPrefix: 'CLOSES IN',
      );
    } else if (event.canCancelRegistration) {
      // You can cancel (on time or to late)
      if (event.cancelDeadlinePassed() && event.registration!.isInvited) {
        // Cancel too late message, cancel button with fine warning.
        final text =
            'The deadline has passed, are you sure you want '
            'to cancel your registration and pay the estimated full costs of '
            '€${event.fine}? You will not be able to undo this!';
        registrationButton = _makeCancelRegistrationButton(event, text);
      } else {
        // Cancel button.
        const text = 'Are you sure you want to cancel your registration?';
        registrationButton = _makeCancelRegistrationButton(event, text);
      }
    }

    // Cancelled _> should get not able to register message:
    //Your registration for this event is cancelled. Note that you cannot re-register.

    if (event.registrationClosed() && !event.canCancelRegistration) {
      registrationStatusText.add(
        TextSpan(text: 'Registration is not possible anymore.'),
      );
    } else if ((event.canCreateRegistration ||
            event.createRegistrationWhenOpen) &&
        !event.isRegistered) {
      if (!event.registrationStarted()) {
        // Registration will open ....
        final registrationStart = dateTimeFormatter.format(
          event.registrationStart!.toLocal(),
        );
        registrationStatusText.add(
          TextSpan(text: 'Registration will open $registrationStart.'),
        );
      } else if (event.registrationIsOpen()) {
        textSpans.add(_makeTermsAndConditions(event));
        if (event.registration != null) {
          registrationStatusText.add(
            TextSpan(
              text:
                  'Your registration for this event is cancelled. You may still re-register.',
            ),
          );
        } else {
          registrationStatusText.add(TextSpan(text: 'You can register now.'));
        }
      }
    } else if (event.isRegistered) {
      final registration = event.registration!;
      registrationStatusText.add(
        TextSpan(text: 'You are registered for thie event.'),
      );

      if (event.paymentIsRequired) {
        Payment? payment = registration.payment;
        if (payment != null) {
          textSpans.add(
            TextSpan(text: 'You are paying with ${payment.type.toString()}. '),
          );
        } else {
          // You have not paid yet.
          textSpans.add(const TextSpan(text: 'You have not paid yet. '));
        }
      }
      if (event.hasEnded()) {
        if (registration.present ?? true) {
          textSpans.add(const TextSpan(text: 'You were present. '));
        } else {
          textSpans.add(const TextSpan(text: 'You were not present. '));
        }
      }
    } else {
      // We should avoid using the registration status as much as possible.
      // The status is from when we fetched the event, and may not be up-to-date
      // when we build. For example, the event may have opened.
      registrationStatusText.add(TextSpan(text: event.registrationStatus));
    }

    late Widget paymentButton;
    if (event.isInvited &&
        event.paymentIsRequired &&
        !event.registration!.isPaid &&
        event.registration!.tpayAllowed) {
      paymentButton = TPayButton(
        onPay: () async => await _eventCubit.thaliaPayRegistration(
          registrationPk: event.registration!.pk,
        ),
        confirmationMessage:
            'Are you sure you want to pay €${event.price} for '
            'your registration to "${event.title}"?',
        failureMessage: 'Could not pay your registration.',
        successMessage: 'Paid your registration with Thalia Pay.',
        amount: event.price,
      );
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
                  dateTimeFormatter.format(event.registrationStart!.toLocal()),
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
        if (textSpans.isNotEmpty) ...[
          Text.rich(TextSpan(children: textSpans), style: dataStyle),
          const SizedBox(height: 8),
        ],
        Text.rich(
          TextSpan(children: registrationStatusText),
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 4),
        registrationButton,
        if (event.canUpdateRegistration) _makeUpdateButton(event),
        paymentButton,
      ],
    );
  }

  // Create the info for events with optional registration.
  Widget _makeOptionalRegistrationInfo(Event event) {
    // TODO: Add timers and countdowns for this too

    assert(event.registrationIsOptional);
    final textTheme = Theme.of(context).textTheme;
    final dataStyle = textTheme.bodyMedium!.apply(fontSizeDelta: -1);

    final textSpans = <TextSpan>[];
    final registrationStatusText = <TextSpan>[];
    Widget registrationButton = const SizedBox.shrink();
    if (event.canCancelRegistration) {
      registrationButton = _makeIWontBeThereButton(event);
    }

    if (event.isInvited) {
      textSpans.add(
        const TextSpan(
          text:
              'You are registered. This is only an indication that you intend '
              'to be present. Access to the event is not handled by Thalia. ',
        ),
      );
    } else if (event.canCreateRegistration) {
      textSpans.add(
        const TextSpan(
          text:
              'Even though registration is not required for this event, you '
              'can still register to give an indication of who will be there, as '
              'well as mark the event as "registered" in your calendar. ',
        ),
      );
      registrationButton = _makeIllBeThereButton(event);
    }

    if (event.noRegistrationMessage?.isNotEmpty ?? false) {
      final htmlStripped = Bidi.stripHtmlIfNeeded(event.noRegistrationMessage!);
      registrationStatusText.add(TextSpan(text: htmlStripped));
    } else {
      registrationStatusText.add(TextSpan(text: event.registrationStatus));
    }

    Widget updateButton = const SizedBox.shrink();
    if (event.canUpdateRegistration) {
      updateButton = _makeUpdateButton(event);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(TextSpan(children: textSpans), style: dataStyle),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(children: registrationStatusText),
          style: TextStyle(fontStyle: FontStyle.italic),
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
    final dataStyle = textTheme.bodyMedium!.apply(fontSizeDelta: -1);

    final textSpans = <TextSpan>[];
    if (event.noRegistrationMessage?.isNotEmpty ?? false) {
      final htmlStripped = Bidi.stripHtmlIfNeeded(event.noRegistrationMessage!);
      textSpans.add(TextSpan(text: htmlStripped));
    } else {
      textSpans.add(const TextSpan(text: 'No registration required.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(TextSpan(children: textSpans), style: dataStyle),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _makeIllBeThereButton(Event event) {
    return ElevatedButton.icon(
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          final calendarCubit = BlocProvider.of<CalendarCubit>(context);
          await _eventCubit.register();
          await _eventCubit.load();
          calendarCubit.load();
        } on ApiException {
          messenger.showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Could not register for the event.'),
            ),
          );
        }
      },
      icon: const Icon(Icons.check),
      label: const Text("I'LL BE THERE"),
    );
  }

  Widget _makeIWontBeThereButton(Event event) {
    return ElevatedButton.icon(
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          final calendarCubit = BlocProvider.of<CalendarCubit>(context);
          await _eventCubit.cancelRegistration(
            registrationPk: event.registration!.pk,
          );
          await _eventCubit.load();
          calendarCubit.load();
        } on ApiException {
          messenger.showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Could not cancel your registration.'),
            ),
          );
        }
      },
      icon: const Icon(Icons.clear),
      label: const Text("I WON'T BE THERE"),
    );
  }

  void register(Event event) async {
    final messenger = ScaffoldMessenger.of(context);
    final calendarCubit = BlocProvider.of<CalendarCubit>(context);
    final router = GoRouter.of(context);
    var confirmed = !event.cancelDeadlinePassed();
    if (!confirmed) {
      confirmed = await showConfirmationDialog(
        context,
        'Register',
        'Are you sure you want to register? The '
            'cancellation deadline has already passed.',
      );
    }

    if (confirmed) {
      try {
        final registration = await _eventCubit.register();
        if (event.hasFields) {
          router.pushNamed(
            'event-registration',
            pathParameters: {
              'eventPk': event.pk.toString(),
              'registrationPk': registration.pk.toString(),
            },
          );
        }
        calendarCubit.load();
      } on ApiException {
        messenger.showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not register for the event.'),
          ),
        );
      }
      await _eventCubit.load();
    }
  }

  void joinQueue(Event event) async {
    final messenger = ScaffoldMessenger.of(context);
    final calendarCubit = BlocProvider.of<CalendarCubit>(context);
    final router = GoRouter.of(context);
    try {
      final registration = await _eventCubit.register();
      if (event.hasFields) {
        router.pushNamed(
          'event-registration',
          pathParameters: {
            'eventPk': event.pk.toString(),
            'registrationPk': registration.pk.toString(),
          },
        );
      }
      calendarCubit.load();
    } on ApiException {
      messenger.showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Could not join the waiting list for the event.'),
        ),
      );
    }
    await _eventCubit.load();
  }

  Widget _makeCancelRegistrationButton(Event event, String warningText) {
    return ElevatedButton.icon(
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final calendarCubit = BlocProvider.of<CalendarCubit>(context);
        final welcomeCubit = BlocProvider.of<WelcomeCubit>(context);
        final confirmed = await showConfirmationDialog(
          context,
          'Cancel registration',
          warningText,
        );

        if (confirmed) {
          try {
            await _eventCubit.cancelRegistration(
              registrationPk: event.registration!.pk,
            );
          } on ApiException {
            messenger.showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Could not cancel your registration.'),
              ),
            );
          }
        }
        await _eventCubit.load();
        calendarCubit.load();
        await welcomeCubit.load();
      },
      icon: const Icon(Icons.delete_forever_outlined),
      label: const Text('CANCEL REGISTRATION'),
    );
  }

  Widget _makeUpdateButton(Event event) {
    return ElevatedButton.icon(
      onPressed: () => context.pushNamed(
        'event-registration',
        pathParameters: {
          'eventPk': event.pk.toString(),
          'registrationPk': event.registration!.pk.toString(),
        },
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

  // Widget _makeFoodShiftButton(
  //   ShiftInfo shift,
  //   WidgetStatesController controler,
  //   DateTime? nextChange,
  // ) {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: TimedIconButton(
  //       controller: controler,
  //       onPressed: () => context.pushNamed('sales-shift', extra: shift.pk),
  //       icon: const Icon(Icons.local_pizza),
  //       labelText: 'ORDER FOOD (${shift.title})',
  //       opensPrefix: 'ORDER (${shift.title}) IN',
  //       closesPrefix: 'ORDER (${shift.title})',
  //       nextChange: nextChange,
  //     ),
  //   );
  // }

  TextSpan _makeTermsAndConditions(Event event) {
    final url = Config.of(context).termsAndConditionsUrl;
    return TextSpan(
      children: [
        const TextSpan(
          text: 'By registering, you confirm that you have read the ',
        ),
        TextSpan(
          text: 'terms and conditions',
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (_) {
                messenger.showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Could not open "${url.toString()}".'),
                  ),
                );
              }
            },
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        const TextSpan(
          text:
              ', that you understand them and '
              'that you agree to be bound by them.',
        ),
      ],
    );
  }

  Widget _makeDescription(Event event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: HtmlWidget(
        event.description,
        onTapUrl: (String url) async {
          Uri uri = Uri.parse(url);
          if (uri.scheme.isEmpty) uri = uri.replace(scheme: 'https');
          if (isDeepLink(uri)) {
            context.go(Uri(path: uri.path, query: uri.query).toString());
            return true;
          } else {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {
              messenger.showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Could not open "$url".'),
                ),
              );
            }
          }
          return true;
        },
      ),
    );
  }

  SliverPadding _makeRegistrationsHeader() {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16),
      sliver: SliverToBoxAdapter(
        child: Text(
          'REGISTRATIONS',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  SliverPadding _makeRegistrations(List<EventRegistration> registrations) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          if (registrations[index].member != null) {
            return MemberTile(member: registrations[index].member!);
          } else {
            return DefaultMemberTile(name: registrations[index].name!);
          }
        }, childCount: registrations.length),
      ),
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
            ),
            body: ErrorScrollView(state.message!, retry: _eventCubit.load),
          );
        } else if (state.isLoading && widget.event == null) {
          return Scaffold(
            appBar: ThaliaAppBar(title: const Text('EVENT')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else {
          final event = (state.event ?? widget.event)!;

          final api = RepositoryProvider.of<ApiRepository>(context);

          final List<AppbarAction> actions = [
            IconAppbarAction(
              'EXPORT',
              Icons.edit_calendar_outlined,
              () async {
                final exportableEvent = add2calendar.Event(
                  title: event.title,
                  location: event.location,
                  startDate: event.start,
                  endDate: event.end,
                );
                await add2calendar.Add2Calendar.addEvent2Cal(exportableEvent);
              },
              tooltip: 'add event to calendar',
            ),
            IconAppbarAction(
              'SHARE',
              Theme.of(context).platform == TargetPlatform.iOS
                  ? Icons.ios_share
                  : Icons.share,
              () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await SharePlus.instance.share(
                    ShareParams(uri: Uri.tryParse(event.url)),
                  );
                } catch (_) {
                  messenger.showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('Could not share the event.'),
                    ),
                  );
                }
              },
            ),
            if (event.userPermissions.manageEvent)
              IconAppbarAction(
                'EDIT',
                Icons.settings,
                () => context.pushNamed(
                  'event-admin',
                  pathParameters: {'eventPk': event.pk.toString()},
                ),
              ),
          ];

          final slivers = [
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
            const SliverToBoxAdapter(child: Divider()),
            _makeRegistrationsHeader(),
          ];

          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text(event.title.toUpperCase()),
              collapsingActions: actions,
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await _eventCubit.load();
              },
              child: BlocProvider(
                create: (_) => EventListCubit(api, event.pk)..load(),
                lazy: false,
                child: PaginatedScrollView<EventListCubit, EventRegistration>(
                  loadingBuilder: (context) => slivers,
                  errorBuilder: (context, _) => slivers,
                  resultsBuilder: (context, registrations) => [
                    ...slivers,
                    _makeRegistrations(registrations),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
