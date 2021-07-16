import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/event_admin_cubit.dart';
import 'package:reaxit/models/event_registration.dart';
import 'package:reaxit/models/payment.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';

class EventAdminScreen extends StatefulWidget {
  final int pk;

  EventAdminScreen({required this.pk}) : super(key: ValueKey(pk));

  @override
  _EventAdminScreenState createState() => _EventAdminScreenState();
}

class _EventAdminScreenState extends State<EventAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventAdminCubit(
        RepositoryProvider.of<ApiRepository>(context),
        eventPk: widget.pk,
      )..load(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text('REGISTRATIONS'),
              actions: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: EventAdminSearchDelegate(
                        EventAdminCubit(
                          RepositoryProvider.of<ApiRepository>(context),
                          eventPk: widget.pk,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await BlocProvider.of<EventAdminCubit>(context).load();
              },
              child: BlocBuilder<EventAdminCubit, EventAdminState>(
                builder: (context, state) {
                  if (state.hasException) {
                    return ErrorScrollView(state.message!);
                  } else if (state.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.separated(
                      itemBuilder: (context, index) => _RegistrationTile(
                        registration: state.registrations![index],
                        requiresPayment: state.event!.paymentIsRequired,
                      ),
                      separatorBuilder: (_, __) => const Divider(),
                      itemCount: state.registrations!.length,
                    );
                  }
                },
              ),
            ),
          );
        },
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
    final name = registration.member?.displayName ?? registration.name!;

    final presentCheckbox = Checkbox(
      value: present,
      onChanged: (value) async {
        final oldValue = present;
        try {
          setState(() => present = value!);
          await BlocProvider.of<EventAdminCubit>(context).setPresent(
            registrationPk: registration.pk,
            present: value!,
          );
        } on ApiException {
          setState(() => present = oldValue);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value!
                ? 'Could not mark $name as present.'
                : 'Could not mark $name as not present.'),
            duration: Duration(seconds: 1),
          ));
        }
      },
    );

    late Widget paymentDropdown;
    if (widget.requiresPayment) {
      if (registration.isPaid &&
          registration.payment!.type == PaymentType.tpayPayment) {
        paymentDropdown = DropdownButton<PaymentType?>(
          items: [
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
          items: [
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
            try {
              await BlocProvider.of<EventAdminCubit>(context).setPayment(
                registrationPk: registration.pk,
                paymentType: value,
              );
            } on ApiException {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(value != null
                    ? 'Could not mark $name as paid.'
                    : 'Could not mark $name as not paid.'),
                duration: Duration(seconds: 1),
              ));
            }
          },
        );
      }
    } else {
      paymentDropdown = const SizedBox.shrink();
    }

    return ListTile(
      title: Text(name, maxLines: 1),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Present:',
            style: Theme.of(context).textTheme.caption,
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
  List<Widget> buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return <Widget>[
        IconButton(
          tooltip: 'Clear search bar',
          icon: Icon(Icons.delete),
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
    return CloseButton(
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return BlocBuilder<EventAdminCubit, EventAdminState>(
      bloc: _adminCubit..load(search: query),
      builder: (context, state) {
        if (state.hasException) {
          return ErrorScrollView(state.message!);
        } else if (state.registrations == null) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.separated(
            itemBuilder: (context, index) => _RegistrationTile(
              registration: state.registrations![index],
              requiresPayment: state.event!.paymentIsRequired,
            ),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: state.registrations!.length,
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return BlocBuilder<EventAdminCubit, EventAdminState>(
      bloc: _adminCubit..load(search: query),
      builder: (context, state) {
        if (state.hasException) {
          return ErrorScrollView(state.message!);
        } else if (state.registrations == null) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.separated(
            itemBuilder: (context, index) => _RegistrationTile(
              registration: state.registrations![index],
              requiresPayment: state.event!.paymentIsRequired,
            ),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: state.registrations!.length,
          );
        }
      },
    );
  }
}
