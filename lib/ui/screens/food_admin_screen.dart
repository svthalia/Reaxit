import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets.dart';

class FoodAdminScreen extends StatefulWidget {
  final int pk;

  FoodAdminScreen({required this.pk}) : super(key: ValueKey(pk));

  @override
  State<FoodAdminScreen> createState() => _FoodAdminScreenState();
}

class _FoodAdminScreenState extends State<FoodAdminScreen> {
  Filter<AdminFoodOrder> _filter = MultipleFilter(
    [
      MapFilter<PaymentType?, AdminFoodOrder>(
          map: {
            for (PaymentType value in PaymentType.values) value: true,
            null: true,
          },
          title: 'Payment type',
          asString: (item) => item?.toString() ?? 'Not paid',
          toKey: (item) => item.payment?.type),
    ],
  );

  _SortOrder _sortOrder = _SortOrder.none;

  void _updateSortOrder(_SortOrder? order) {
    setState(() {
      _sortOrder = order ?? _SortOrder.none;
    });
  }

  void _showPaymentFilter() async {
    final Filter<AdminFoodOrder>? results = await showDialog(
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

  void _opensearch(BuildContext context) async {
    final adminCubit = BlocProvider.of<FoodAdminCubit>(context);
    final searchCubit = FoodAdminCubit(
      RepositoryProvider.of<ApiRepository>(context),
      foodEventPk: widget.pk,
    );

    await showSearch(
      context: context,
      delegate: FoodAdminSearchDelegate(searchCubit),
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
      create: (context) => FoodAdminCubit(
        RepositoryProvider.of<ApiRepository>(context),
        foodEventPk: widget.pk,
      )..load(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: const Text('ORDERS'),
              collapsingActions: [
                IconAppbarAction(
                  'SEACH',
                  Icons.search,
                  () => _opensearch(context),
                ),
                SortButton<_SortOrder>(
                  _SortOrder.values.map((e) => e.asSortItem()).toList(),
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
                await BlocProvider.of<FoodAdminCubit>(context).load();
              },
              child: BlocBuilder<FoodAdminCubit, FoodAdminState>(
                builder: (context, state) {
                  switch (state) {
                    case (ErrorState estate):
                      return ErrorScrollView(estate.message);
                    case (LoadingState _):
                      return const Center(child: CircularProgressIndicator());
                    case (ResultState<List<AdminFoodOrder>> rstate):
                      List<AdminFoodOrder> filtered = rstate.result
                          .where(_filter.passes)
                          .sorted(_sortOrder.compare)
                          .toList();

                      return Scrollbar(
                        child: ListView.separated(
                          key: const PageStorageKey('food-admin'),
                          itemBuilder: (context, index) => _OrderTile(
                            order: filtered[index],
                          ),
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
  final AdminFoodOrder order;

  _OrderTile({required this.order}) : super(key: ValueKey(order.pk));

  @override
  __OderTileState createState() => __OderTileState();
}

class __OderTileState extends State<_OrderTile> {
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final name = order.member?.fullName ?? order.name!;

    late Widget paymentDropdown;
    if (order.isPaid && order.payment!.type == PaymentType.tpayPayment) {
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
        value: order.payment!.type,
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
        value: order.payment?.type,
        onChanged: (value) async {
          final messenger = ScaffoldMessenger.of(context);
          try {
            await BlocProvider.of<FoodAdminCubit>(context).setPayment(
              orderPk: order.pk,
              paymentType: value,
            );
          } on ApiException {
            messenger.showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                value != null
                    ? "Could not mark $name's order as paid."
                    : "Could not mark $name's order as not paid.",
              ),
            ));
          }
        },
      );
    }

    return ListTile(
      horizontalTitleGap: 8,
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        order.product.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '€${order.product.price}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(width: 16),
          paymentDropdown,
        ],
      ),
    );
  }
}

class FoodAdminSearchDelegate extends SearchDelegate {
  final FoodAdminCubit _adminCubit;

  FoodAdminSearchDelegate(this._adminCubit);

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
      child: BlocBuilder<FoodAdminCubit, FoodAdminState>(
        builder: (context, state) {
          switch (state) {
            case (ErrorState state):
              return ErrorScrollView(state.message);
            case (LoadingState _):
              return const SizedBox.shrink();
            case (ResultState<List<AdminFoodOrder>> rstate):
              return ListView.separated(
                key: const PageStorageKey('food-admin-search'),
                itemBuilder: (context, index) => _OrderTile(
                  order: rstate.result[index],
                ),
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
      child: BlocBuilder<FoodAdminCubit, FoodAdminState>(
        builder: (context, state) {
          if (state is ErrorState) {
            return ErrorScrollView(state.message!);
          } else if (state is LoadingState) {
            return const SizedBox.shrink();
          } else {
            return ListView.separated(
              key: const PageStorageKey('food-admin-search'),
              itemBuilder: (context, index) => _OrderTile(
                order: state.result![index],
              ),
              separatorBuilder: (_, __) => const Divider(),
              itemCount: state.result!.length,
            );
          }
        },
      ),
    );
  }
}

enum _SortOrder {
  none(text: 'None', icon: Icons.cancel, compare: equal),
  payedUp(text: 'Paid', icon: Icons.keyboard_arrow_up, compare: cmpPaid),
  payedDown(text: 'Paid', icon: Icons.keyboard_arrow_down, compare: cmpPaid_2),
  nameUp(text: 'Name', icon: Icons.keyboard_arrow_up, compare: cmpName),
  nameDown(text: 'Name', icon: Icons.keyboard_arrow_down, compare: cmpName_2),
  productUp(
      text: 'Product', icon: Icons.keyboard_arrow_up, compare: cmpProduct),
  productDown(
      text: 'Product', icon: Icons.keyboard_arrow_down, compare: cmpProduct_2);

  final String text;
  final IconData? icon;
  final int Function(AdminFoodOrder, AdminFoodOrder) compare;

  const _SortOrder({required this.text, this.icon, required this.compare});

  SortItem<_SortOrder> asSortItem() {
    return SortItem(this, text, icon);
  }

  static int equal(AdminFoodOrder e1, AdminFoodOrder e2) {
    return 0;
  }

  static int cmpPaid(AdminFoodOrder e1, AdminFoodOrder e2) {
    if (e1.isPaid) {
      return -1;
    }
    if (e2.isPaid) {
      return 1;
    }
    return 0;
  }

  static int cmpPaid_2(AdminFoodOrder e1, AdminFoodOrder e2) =>
      -cmpPaid(e1, e2);

  static int cmpName(AdminFoodOrder e1, AdminFoodOrder e2) {
    if (e1.name == null) {
      return -1;
    }
    if (e2.name == null) {
      return 1;
    }
    return e1.name!.compareTo(e2.name!);
  }

  static int cmpName_2(AdminFoodOrder e1, AdminFoodOrder e2) =>
      -cmpName(e1, e2);

  static int cmpProduct(AdminFoodOrder e1, AdminFoodOrder e2) {
    return e1.product.name.compareTo(e2.product.name);
  }

  static int cmpProduct_2(AdminFoodOrder e1, AdminFoodOrder e2) =>
      -cmpName(e1, e2);
}
