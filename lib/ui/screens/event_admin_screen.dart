import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/models/registration.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/events_provider.dart';
import 'package:reaxit/ui/components/network_search_delegate.dart';

class EventAdminScreen extends StatefulWidget {
  final int pk;

  EventAdminScreen(this.pk);

  @override
  _EventAdminScreenState createState() => _EventAdminScreenState();
}

class _EventAdminScreenState extends State<EventAdminScreen> {
  bool _loading = false;
  ApiException _error;
  List<Registration> _registrationList;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    _loading = true;
    refresh();
  }

  Future<void> refresh() async {
    List<Registration> registrations;
    try {
      registrations = await Provider.of<EventsProvider>(context, listen: false)
          .getEventRegistrations(widget.pk);
      _error = null;
    } on ApiException catch (error) {
      _error = error;
    }
    setState(() {
      _registrationList = registrations;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: filter/other FAB?
      appBar: AppBar(
        title: Text("Registrations"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: "Search for registrations",
            onPressed: () => showSearch(
              context: context,
              delegate: NetworkSearchDelegate<EventsProvider>(
                search: (events, query) =>
                    events.searchRegistrations(_registrationList, query),
                resultBuilder: (context, events, registrationList) {
                  return ListView.builder(
                    itemCount: registrationList.length,
                    itemBuilder: (context, index) => _RegistrationTile(
                      // Using a ValueKey for the search results means that
                      // server-side changes don't propagate to the search
                      // result's tiles, but fixes a problem where the payment
                      // dropdown closes on losing keyboard focus, immediately
                      // after opening it.
                      key: ValueKey(registrationList[index].pk),
                      registration: registrationList[index],
                      refresh: refresh,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (_loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (_error != null) {
            return RefreshIndicator(
              onRefresh: refresh,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    height: 100,
                    margin: const EdgeInsets.all(10),
                    child: Image.asset(
                      'assets/img/sad_cloud.png',
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Text(
                    _errorText(_error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            if (_registrationList.length == 0) {
              return RefreshIndicator(
                onRefresh: refresh,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      height: 100,
                      margin: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/img/sad_cloud.png',
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    Text(
                      "No registrations yet...",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else {
              return RefreshIndicator(
                onRefresh: refresh,
                child: ListView.builder(
                  itemCount: _registrationList.length,
                  itemBuilder: (context, index) {
                    return _RegistrationTile(
                      // ObjectKey makes sure we create a new card after
                      // refreshing. That way, changes from the api are
                      // propagated to the _RegistrationTiles.
                      key: ObjectKey(_registrationList[index]),
                      registration: _registrationList[index],
                      refresh: refresh,
                    );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class _RegistrationTile extends StatefulWidget {
  final Function() refresh;
  final Registration registration;

  const _RegistrationTile({
    Key key,
    this.refresh,
    this.registration,
  }) : super(key: key);

  @override
  __RegistrationTileState createState() =>
      __RegistrationTileState(registration);
}

class __RegistrationTileState extends State<_RegistrationTile> {
  Registration registration;

  __RegistrationTileState(this.registration);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(registration.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Present:", style: Theme.of(context).textTheme.caption),
              Checkbox(
                value: registration.present,
                onChanged: (value) async {
                  bool oldValue = registration.present;
                  setState(() => registration.present = value);
                  try {
                    await Provider.of<EventsProvider>(context, listen: false)
                        .setPresent(registration, value);
                  } on ApiException {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? "Couldn't mark ${registration.name} as present"
                              : "Couldn't mark ${registration.name} as not present",
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    setState(() => registration.present = oldValue);
                  }
                  widget.refresh();
                },
              ),
              SizedBox(width: 15),
              registration.payment == "tpay_payment"
                  ? DropdownButton(
                      items: [DropdownMenuItem(child: Text("Thalia Pay"))],
                      value: registration.payment,
                      onChanged: null,
                    )
                  : DropdownButton(
                      value: registration.payment,
                      onChanged: (payment) async {
                        String oldPayment = registration.payment;
                        setState(() => registration.payment = payment);
                        try {
                          await Provider.of<EventsProvider>(context,
                                  listen: false)
                              .payRegistration(registration, payment);
                        } on ApiException {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                (payment == "no_payment")
                                    ? "Couldn't mark ${registration.name}'s registration as not paid..."
                                    : "Couldn't mark ${registration.name}'s registration as paid...",
                              ),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          // Restore the state on failure, so that there is no
                          // incorrect information shown if there's no reload
                          // after a failure (as is the case in search).
                          setState(() => registration.payment = oldPayment);
                        }
                        widget.refresh();
                      },
                      items: [
                        DropdownMenuItem(
                          value: "no_payment",
                          child: Text("Not paid"),
                        ),
                        DropdownMenuItem(
                          value: "cash_payment",
                          child: Text("Cash"),
                        ),
                        DropdownMenuItem(
                          value: "card_payment",
                          child: Text("Card"),
                        ),
                      ],
                    ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}

// TODO: make an ErrorScreen widget.
String _errorText(ApiException error) {
  switch (error) {
    case ApiException.noInternet:
      return 'Not connected to the internet.';
    case ApiException.notAllowed:
      return 'You are not authorized.';
    case ApiException.notFound:
      return 'Not found.';
    case ApiException.notLoggedIn:
      return 'You are not logged in.';
    default:
      return 'An unknown error occured.';
  }
}
