import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/blocs/sales_admin_cubit.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/payment_override.dart';

class SalesAdminScreen extends StatefulWidget {
  final int pk;

  SalesAdminScreen({required this.pk}) : super(key: ValueKey(pk));

  @override
  State<SalesAdminScreen> createState() => _SalesAdminScreenState();
}

class _SalesAdminScreenState extends State<SalesAdminScreen> {
  Filter<ListSalesOrder> _filter = MultipleFilter([
    MapFilter<PaymentType?, ListSalesOrder>(
      map: {
        for (PaymentType value in PaymentType.values) value: true,
        null: true,
      },
      title: 'Payment type',
      asString: (item) => item?.toString() ?? 'Not paid',
      toKey: (item) => item.payment?.type,
    ),
  ]);

  SortOrder _sortOrder = SortOrder.none;

  void _updateSortOrder(SortOrder? order) {
    setState(() {
      _sortOrder = order ?? SortOrder.none;
    });
  }

  void _showPaymentFilter() async {
    final Filter<ListSalesOrder>? results = await showDialog(
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

  // TODO: fully implemented, blocked on https://github.com/svthalia/Reaxit/issues/551
  // ignore: unused_element
  void _opensearch(BuildContext context) async {
    final adminCubit = BlocProvider.of<SalesAdminCubit>(context);
    final searchCubit = SalesAdminCubit(
      RepositoryProvider.of<ApiRepository>(context),
      shiftPk: widget.pk,
    );

    await showSearch(
      context: context,
      delegate: SalesAdminSearchDelegate(searchCubit),
    );

    searchCubit.close();

    // After the search dialog closes, refresh the results,
    // since the search screen may have changed stuff through
    // its own FoodAdminCubit, that do not show up in the cubit
    // for the FoodAdminScreen until a refresh.
    adminCubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => SalesAdminCubit(
            RepositoryProvider.of<ApiRepository>(context),
            shiftPk: widget.pk,
          )..load(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: const Text('ORDERS'),
              collapsingActions: [
                // TODO: fully implemented, blocked on https://github.com/svthalia/Reaxit/issues/551
                // IconAppbarAction(
                //   'SEACH',
                //   Icons.search,
                //   () => _opensearch(context),
                // ),
                SortButton<SortOrder>(
                  SortOrder.values.map((e) => e.asSortItem()).toList(),
                  _updateSortOrder,
                ),
                IconAppbarAction(
                  'FILTER',
                  Icons.filter_alt_rounded,
                  _showPaymentFilter,
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await BlocProvider.of<SalesAdminCubit>(context).load();
              },
              child: BlocBuilder<SalesAdminCubit, SalesAdminState>(
                builder: (context, state) {
                  switch (state) {
                    case ErrorState(message: var message):
                      return ErrorScrollView(message);
                    case LoadingState _:
                      return const Center(child: CircularProgressIndicator());
                    case ResultState(result: var result):
                      List<ListSalesOrder> filtered =
                          result
                              .where(_filter.passes)
                              .sorted(_sortOrder.compare)
                              .toList();

                      return Scrollbar(
                        child: ListView.separated(
                          key: const PageStorageKey('food-admin'),
                          itemBuilder:
                              (context, index) =>
                                  _OrderTile(order: filtered[index]),
                          separatorBuilder: (_, __) => const Divider(),
                          itemCount: filtered.length,
                        ),
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

class _OrderTile extends StatefulWidget {
  final ListSalesOrder order;

  _OrderTile({required this.order}) : super(key: ValueKey(order.pk));

  @override
  __OderTileState createState() => __OderTileState();
}

class __OderTileState extends State<_OrderTile> {
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final name = order.name ?? 'Not assigned to user';

    late Widget paymentDropdown;
    if (order.isPaid && order.payment!.type == PaymentType.tpayPayment) {
      paymentDropdown = PaymentOverrideDropdown(
        cardSupported: true,
        tpSupported: true,
        cashSupported: true,
        wireSupported: true,
        type: order.payment!.type,
      );
    } else {
      paymentDropdown = PaymentOverrideDropdown(
        cardSupported: true,
        cashSupported: true,
        wireSupported: true,
        type: order.payment?.type,
        onChanged: (value) async {
          final messenger = ScaffoldMessenger.of(context);
          try {
            await BlocProvider.of<SalesAdminCubit>(
              context,
            ).setPayment(orderPk: order.pk, paymentType: value);
          } on ApiException {
            messenger.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  value != null
                      ? "Could not mark $name's order as paid."
                      : "Could not mark $name's order as not paid.",
                ),
              ),
            );
          }
        },
      );
    }

    return ListTile(
      horizontalTitleGap: 8,
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        children: order.items.map((item) => OrderItemtRow(item)).toList(),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '€${order.totalAmount}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(width: 16),
          paymentDropdown,
        ],
      ),
    );
  }
}

class OrderItemtRow extends StatelessWidget {
  final MinSalesOrderItem item;

  const OrderItemtRow(this.item);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(item.product, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text('${item.amount}x', maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class SalesAdminSearchDelegate extends SearchDelegate {
  final SalesAdminCubit _adminCubit;

  SalesAdminSearchDelegate(this._adminCubit);

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
        ),
      ];
    } else {
      return [];
    }
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    return BlocProvider.value(
      value: _adminCubit..search(query),
      child: BlocBuilder<SalesAdminCubit, SalesAdminState>(
        builder: (context, state) {
          switch (state) {
            case (ErrorState state):
              return ErrorScrollView(state.message);
            case (LoadingState _):
              return const SizedBox.shrink();
            case (ResultState<List<ListSalesOrder>> rstate):
              return ListView.separated(
                key: const PageStorageKey('food-admin-search'),
                itemBuilder:
                    (context, index) => _OrderTile(order: rstate.result[index]),
                separatorBuilder: (_, __) => const Divider(),
                itemCount: rstate.result.length,
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
      child: BlocBuilder<SalesAdminCubit, SalesAdminState>(
        builder:
            (context, state) => switch (state) {
              ErrorState(message: var message) => ErrorScrollView(message),
              LoadingState _ => const SizedBox.shrink(),
              ResultState(result: var result) => ListView.separated(
                key: const PageStorageKey('food-admin-search'),
                itemBuilder:
                    (context, index) => _OrderTile(order: result[index]),
                separatorBuilder: (_, __) => const Divider(),
                itemCount: result.length,
              ),
            },
      ),
    );
  }
}

enum SortOrder {
  none(text: 'None', icon: Icons.cancel, compare: equal),
  payedUp(text: 'Paid', icon: Icons.keyboard_arrow_up, compare: cmpPaid),
  payedDown(text: 'Paid', icon: Icons.keyboard_arrow_down, compare: cmpPaid_2),
  nameUp(text: 'Name', icon: Icons.keyboard_arrow_up, compare: cmpName),
  nameDown(text: 'Name', icon: Icons.keyboard_arrow_down, compare: cmpName_2);

  final String text;
  final IconData? icon;
  final int Function(ListSalesOrder, ListSalesOrder) compare;

  const SortOrder({required this.text, this.icon, required this.compare});

  SortItem<SortOrder> asSortItem() {
    return SortItem(this, text, icon);
  }

  static int equal(ListSalesOrder e1, ListSalesOrder e2) {
    return 0;
  }

  static int cmpPaid(ListSalesOrder e1, ListSalesOrder e2) {
    if (e1.isPaid) {
      return -1;
    }
    if (e2.isPaid) {
      return 1;
    }
    return 0;
  }

  static int cmpPaid_2(ListSalesOrder e1, ListSalesOrder e2) =>
      -cmpPaid(e1, e2);

  static int cmpName(ListSalesOrder e1, ListSalesOrder e2) {
    if (e1.name == null) {
      return -1;
    }
    if (e2.name == null) {
      return 1;
    }
    return e1.name!.compareTo(e2.name!);
  }

  static int cmpName_2(ListSalesOrder e1, ListSalesOrder e2) =>
      -cmpName(e1, e2);
}
