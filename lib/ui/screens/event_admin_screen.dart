import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/config.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:intl/intl.dart';

class EventAdminScreen extends StatefulWidget {
  final int pk;

  EventAdminScreen({required this.pk}) : super(key: ValueKey(pk));

  @override
  State<EventAdminScreen> createState() => _EventAdminScreenState();
}

class _EventAdminScreenState extends State<EventAdminScreen> {
  static Filter<AdminEventRegistration> _defaultFilter(bool hidePayed) =>
      MultipleFilter(
        [
          MapFilter<PaymentType?, AdminEventRegistration>(
            map: {
              for (PaymentType value in PaymentType.values) value: true,
              null: true,
            },
            title: 'Payment type',
            asString: (item) => item?.toString() ?? 'Not paid',
            toKey: (item) => item.payment?.type,
            disabled: hidePayed,
          ),
          MapFilter<bool, AdminEventRegistration>(
            map: {
              true: true,
              false: true,
            },
            title: 'Presence',
            asString: (item) => item ? 'Is present' : 'Is not present',
            toKey: (item) => item.present,
          ),
        ],
      );

  bool paymentsHidden = true;
  Filter<AdminEventRegistration> _filter = _defaultFilter(true);
  _SortOrder _sortOrder = _SortOrder.nameDown;

  void _resetfilter(bool hidePayed) {
    _filter = _defaultFilter(hidePayed);
  }

  void _showPaymentFilter() async {
    final Filter<AdminEventRegistration>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectPopup(
          filter: _filter.clone(),
          title: 'Filter registrations',
        );
      },
    );
    if (results != null) {
      setState(() {
        _filter = results;
      });
    }
  }

  void _showQRCode(EventAdminCubit cubit) async {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SafeArea(
          child: BlocBuilder<EventAdminCubit, EventAdminState>(
            bloc: cubit,
            builder: (context, state) {
              final theme = Theme.of(context);
              if (state.event != null) {
                final host = Config.of(context).host;
                final pk = state.event!.pk;
                final token = state.event!.markPresentUrlToken;
                final url = 'https://$host/events/$pk/mark-present/$token';
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Scan to mark yourself present.',
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    QrImageView(
                      data: url,
                      padding: const EdgeInsets.all(24),
                      backgroundColor: Colors.grey[50]!,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: RotatedBox(
                        quarterTurns: 2,
                        child: Text(
                          'Scan to mark yourself present.',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    )
                  ],
                );
              } else if (state.isLoading) {
                return const AspectRatio(
                  aspectRatio: 1,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else {
                return AspectRatio(
                  aspectRatio: 1,
                  child: Center(child: Text(state.message!)),
                );
              }
            },
          ),
        );
      },
    );
  }

  void _openSearch(BuildContext context) async {
    final adminCubit = BlocProvider.of<EventAdminCubit>(context);
    // TODO: check if we need this second cubit!.
    final searchCubit = EventAdminCubit(
      RepositoryProvider.of<ApiRepository>(context),
      eventPk: widget.pk,
    );

    await showSearch(
      context: context,
      delegate: EventAdminSearchDelegate(searchCubit),
    );

    searchCubit.close();

    // After the search dialog closes, refresh the results,
    // since the search screen may have changed stuff through
    // its own EventAdminCubit, that do not show up in the cubit
    // for the EventAdminScreen until a refresh.
    adminCubit.loadRegistrations();
  }

  Widget _resetfilterMessage() {
    return ErrorCenter([
      const Text('No results that match the filter',
          textAlign: TextAlign.center),
      TextButton(
          onPressed: () => setState(() {
                _resetfilter(paymentsHidden);
              }),
          child: const Text('Reset filter'))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventAdminCubit(
        RepositoryProvider.of<ApiRepository>(context),
        eventPk: widget.pk,
      )..load(),
      child: Builder(
        builder: (context) {
          return DefaultTabController(
            length: 3,
            initialIndex: 1,
            child: BlocBuilder<EventAdminCubit, EventAdminState>(
              builder: (context, state) {
                late final Widget body;
                if (state.hasException) {
                  body = ErrorScrollView(state.exception!);
                } else if (state.isLoading) {
                  body = const Center(child: CircularProgressIndicator());
                } else {
                  // If payment is required, but they are also hidden (or vise-versa)
                  if (paymentsHidden == state.event!.paymentIsRequired) {
                    paymentsHidden = !state.event!.paymentIsRequired;
                    _resetfilter(paymentsHidden);
                  }
                  List<AdminEventRegistration> filteredRegistrations = state
                      .registrations
                      .where(_filter.passes)
                      .sorted(_sortOrder.compare)
                      .toList();
                  List<AdminEventRegistration> filteredCancels = state
                      .cancelledRegistrations
                      .where(_filter.passes)
                      .sorted(_sortOrder.compare)
                      .toList();
                  List<AdminEventRegistration> filteredQueue = state
                      .queuedRegistrations
                      .where(_filter.passes)
                      .sorted(_sortOrder.compare)
                      .toList();

                  body = TabBarView(
                    children: [
                      if (state.queuedMessage != null)
                        ErrorCenter([
                          Text(state.queuedMessage!,
                              textAlign: TextAlign.center)
                        ])
                      else if (filteredQueue.isEmpty)
                        _resetfilterMessage()
                      else
                        Scrollbar(
                          child: ListView.separated(
                            key: const PageStorageKey('event-admin'),
                            itemBuilder: (context, index) =>
                                _QueuedRegistrationTile(
                              registration: filteredQueue[index],
                            ),
                            separatorBuilder: (_, __) => const Divider(),
                            itemCount: filteredQueue.length,
                          ),
                        ),
                      if (state.message != null)
                        ErrorCenter(
                            [Text(state.message!, textAlign: TextAlign.center)])
                      else if (filteredRegistrations.isEmpty)
                        _resetfilterMessage()
                      else
                        Scrollbar(
                          child: ListView.separated(
                            key: const PageStorageKey('event-admin'),
                            itemBuilder: (context, index) => _RegistrationTile(
                              registration: filteredRegistrations[index],
                              requiresPayment: state.event!.paymentIsRequired,
                            ),
                            separatorBuilder: (_, __) => const Divider(),
                            itemCount: filteredRegistrations.length,
                          ),
                        ),
                      if (state.cancelledMessage != null)
                        ErrorCenter([
                          Text(state.cancelledMessage!,
                              textAlign: TextAlign.center)
                        ])
                      else if (filteredCancels.isEmpty)
                        _resetfilterMessage()
                      else
                        Scrollbar(
                          child: ListView.separated(
                            key: const PageStorageKey('event-admin'),
                            itemBuilder: (context, index) =>
                                _CancelledRegistrationTile(
                              registration: filteredCancels[index],
                            ),
                            separatorBuilder: (_, __) => const Divider(),
                            itemCount: filteredCancels.length,
                          ),
                        ),
                    ],
                  );
                }
                return Scaffold(
                  appBar: ThaliaAppBar(
                    title: const Text('REGISTRATIONS'),
                    collapsingActions: [
                      IconAppbarAction(
                        'QR Code',
                        Icons.qr_code,
                        () => _showQRCode(
                            BlocProvider.of<EventAdminCubit>(context)),
                        tooltip: 'Show presence QR code',
                      ),
                      IconAppbarAction(
                        'SEARCH',
                        Icons.search,
                        () => _openSearch(context),
                      ),
                      SortButton<_SortOrder>(
                        _SortOrder.values
                            .whereNot((element) =>
                                paymentsHidden && element.isPayment())
                            .map((e) => e.asSortItem())
                            .toList(),
                        (p0) => setState(() {
                          _sortOrder = p0 ?? _SortOrder.nameDown;
                        }),
                      ),
                      IconAppbarAction(
                        'Filter',
                        Icons.filter_alt_rounded,
                        _showPaymentFilter,
                        tooltip: 'Filter registrations',
                      ),
                    ],
                    bottom: TabBar(
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      tabs: const [
                        Tab(text: 'Queued'),
                        Tab(text: 'Registered'),
                        Tab(text: 'Cancelled'),
                      ],
                    ),
                  ),
                  body: RefreshIndicator(
                    onRefresh: () async {
                      await BlocProvider.of<EventAdminCubit>(
                        context,
                      ).loadRegistrations();
                    },
                    child: body,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _QueuedRegistrationTile extends StatelessWidget {
  final AdminEventRegistration registration;

  const _QueuedRegistrationTile({
    required this.registration,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: 8,
      title: Text(
        registration.member?.fullName ?? registration.name!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Queue position: ${registration.queuePosition!.toString()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CancelledRegistrationTile extends StatelessWidget {
  final AdminEventRegistration registration;

  const _CancelledRegistrationTile({
    required this.registration,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: 8,
      title: Text(
        registration.member?.fullName ?? registration.name!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Cancelled on: ${DateFormat('dd/MM, HH:mm').format(registration.dateCancelled!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _RegistrationTile extends StatefulWidget {
  final AdminEventRegistration registration;
  final bool requiresPayment;

  _RegistrationTile({
    required this.registration,
    required this.requiresPayment,
  }) : super(key: ValueKey(registration.pk));

  @override
  __RegistrationTileState createState() => __RegistrationTileState();
}

class __RegistrationTileState extends State<_RegistrationTile> {
  late bool present;
  @override
  void initState() {
    super.initState();
    present = widget.registration.present;
  }

  @override
  void didUpdateWidget(covariant _RegistrationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    present = widget.registration.present;
  }

  @override
  Widget build(BuildContext context) {
    final registration = widget.registration;
    final name = registration.member?.fullName ?? registration.name!;

    final presentCheckbox = Checkbox(
      visualDensity: VisualDensity.compact,
      value: present,
      onChanged: (value) async {
        final oldValue = present;
        final messenger = ScaffoldMessenger.of(context);
        try {
          setState(() => present = value!);
          await BlocProvider.of<EventAdminCubit>(context).setPresent(
            registrationPk: registration.pk,
            present: value!,
          );
        } on ApiException {
          setState(() => present = oldValue);
          messenger.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(value!
                ? 'Could not mark $name as present.'
                : 'Could not mark $name as not present.'),
          ));
        }
      },
    );

    late Widget paymentDropdown;
    if (widget.requiresPayment) {
      if (registration.isPaid &&
          registration.payment!.type == PaymentType.tpayPayment) {
        paymentDropdown = DropdownButton<PaymentType?>(
          style: Theme.of(context).textTheme.bodyMedium,
          items: const [
            DropdownMenuItem(
              value: PaymentType.tpayPayment,
              child: Text('Thalia Pay'),
            ),
            DropdownMenuItem(
              value: PaymentType.cardPayment,
              child: Text('Card payment'),
            ),
            DropdownMenuItem(
              value: PaymentType.cashPayment,
              child: Text('Cash payment'),
            ),
            DropdownMenuItem(
              value: PaymentType.wirePayment,
              child: Text('Wire payment'),
            ),
            DropdownMenuItem(
              value: null,
              child: Text('Not paid'),
            ),
          ],
          value: registration.payment!.type,
          onChanged: null,
        );
      } else {
        paymentDropdown = DropdownButton<PaymentType?>(
          style: Theme.of(context).textTheme.bodyMedium,
          items: const [
            DropdownMenuItem(
              value: PaymentType.cardPayment,
              child: Text('Card payment'),
            ),
            DropdownMenuItem(
              value: PaymentType.cashPayment,
              child: Text('Cash payment'),
            ),
            DropdownMenuItem(
              value: PaymentType.wirePayment,
              child: Text('Wire payment'),
            ),
            DropdownMenuItem(
              value: null,
              child: Text('Not paid'),
            ),
          ],
          value: registration.payment?.type,
          onChanged: (value) async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await BlocProvider.of<EventAdminCubit>(context).setPayment(
                registrationPk: registration.pk,
                paymentType: value,
              );
            } on ApiException {
              messenger.showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(value != null
                    ? 'Could not mark $name as paid.'
                    : 'Could not mark $name as not paid.'),
              ));
            }
          },
        );
      }
    } else {
      paymentDropdown = const SizedBox.shrink();
    }

    return ListTile(
      horizontalTitleGap: 8,
      title: Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Present:',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          presentCheckbox,
          paymentDropdown,
        ],
      ),
    );
  }
}

class EventAdminSearchDelegate extends SearchDelegate {
  final EventAdminCubit _adminCubit;

  EventAdminSearchDelegate(this._adminCubit);

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
    return BlocProvider.value(
      value: _adminCubit..search(query),
      child: BlocBuilder<EventAdminCubit, EventAdminState>(
        builder: (context, state) {
          if (state.hasException) {
            return ErrorScrollView(state.message!);
          } else {
            return ListView.separated(
              key: const PageStorageKey('event-admin-search'),
              itemBuilder: (context, index) => _RegistrationTile(
                registration: state.registrations[index],
                requiresPayment: state.event!.paymentIsRequired,
              ),
              separatorBuilder: (_, __) => const Divider(),
              itemCount: state.registrations.length,
            );
          }
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return BlocProvider.value(
      value: _adminCubit..search(query),
      child: BlocBuilder<EventAdminCubit, EventAdminState>(
        builder: (context, state) {
          if (state.hasException) {
            return ErrorScrollView(state.message!);
          } else {
            return ListView.separated(
              key: const PageStorageKey('event-admin-search'),
              itemBuilder: (context, index) => _RegistrationTile(
                registration: state.registrations[index],
                requiresPayment: state.event!.paymentIsRequired,
              ),
              separatorBuilder: (_, __) => const Divider(),
              itemCount: state.registrations.length,
            );
          }
        },
      ),
    );
  }
}

enum _SortOrder {
  none(text: 'None', icon: Icons.close, compare: equal),
  payedUp(text: 'Paid', icon: Icons.keyboard_arrow_up, compare: cmpPaid),
  payedDown(text: 'Paid', icon: Icons.keyboard_arrow_down, compare: cmpPaid_2),
  presentUp(
      text: 'Present', icon: Icons.keyboard_arrow_up, compare: cmpPresent),
  presentDown(
      text: 'Present', icon: Icons.keyboard_arrow_down, compare: cmpPresent_2),
  nameUp(text: 'Name', icon: Icons.keyboard_arrow_up, compare: cmpName),
  nameDown(text: 'Name', icon: Icons.keyboard_arrow_down, compare: cmpName_2);

  final String text;
  final IconData? icon;
  final int Function(AdminEventRegistration, AdminEventRegistration) compare;

  const _SortOrder({required this.text, this.icon, required this.compare});

  SortItem<_SortOrder> asSortItem() {
    return SortItem(this, text, icon);
  }

  bool isPayment() {
    return this == _SortOrder.payedUp || this == _SortOrder.payedDown;
  }

  static int equal(AdminEventRegistration e1, AdminEventRegistration e2) {
    return 0;
  }

  static int cmpPaid(AdminEventRegistration e1, AdminEventRegistration e2) {
    if (e1.isPaid) {
      return -1;
    }
    if (e2.isPaid) {
      return 1;
    }
    return 0;
  }

  static int cmpPaid_2(AdminEventRegistration e1, AdminEventRegistration e2) =>
      -cmpPaid(e1, e2);

  static int cmpPresent(AdminEventRegistration e1, AdminEventRegistration e2) {
    if (e1.present) {
      return -1;
    }
    if (e2.present) {
      return 1;
    }
    return 0;
  }

  static int cmpPresent_2(
          AdminEventRegistration e1, AdminEventRegistration e2) =>
      -cmpPresent(e1, e2);

  static int cmpName(AdminEventRegistration e1, AdminEventRegistration e2) =>
      (e2.member?.fullName ?? e2.name!)
          .compareTo(e1.member?.fullName ?? e1.name!);

  static int cmpName_2(AdminEventRegistration e1, AdminEventRegistration e2) =>
      -cmpName(e1, e2);
}
