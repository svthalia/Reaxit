import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/food_admin_cubit.dart';
import 'package:reaxit/models/food_order.dart';
import 'package:reaxit/models/payment.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';

class FoodAdminScreen extends StatefulWidget {
  final int pk;

  FoodAdminScreen({required this.pk}) : super(key: ValueKey(pk));

  @override
  _FoodAdminScreenState createState() => _FoodAdminScreenState();
}

class _FoodAdminScreenState extends State<FoodAdminScreen> {
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
              actions: [
                IconButton(
                  padding: const EdgeInsets.all(16),
                  icon: const Icon(Icons.search),
                  onPressed: () async {
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
                    BlocProvider.of<FoodAdminCubit>(context).load();
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await BlocProvider.of<FoodAdminCubit>(context).load();
              },
              child: BlocBuilder<FoodAdminCubit, FoodAdminState>(
                builder: (context, state) {
                  if (state.hasException) {
                    return ErrorScrollView(state.message!);
                  } else if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return Scrollbar(
                        child: ListView.separated(
                      key: const PageStorageKey('food-admin'),
                      itemBuilder: (context, index) => _OrderTile(
                        order: state.result![index],
                      ),
                      separatorBuilder: (_, __) => const Divider(),
                      itemCount: state.result!.length,
                    ));
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
        style: Theme.of(context).textTheme.bodyText2,
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
        style: Theme.of(context).textTheme.bodyText2,
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
          try {
            await BlocProvider.of<FoodAdminCubit>(context).setPayment(
              orderPk: order.pk,
              paymentType: value,
            );
          } on ApiException {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
      title: Text(name, maxLines: 1),
      subtitle: Text(order.product.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '€${order.product.price}',
            style: Theme.of(context).textTheme.subtitle2,
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
        headline6: GoogleFonts.openSans(
          textStyle: Theme.of(context).textTheme.headline6,
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
          if (state.hasException) {
            return ErrorScrollView(state.message!);
          } else if (state.isLoading) {
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

  @override
  Widget buildSuggestions(BuildContext context) {
    return BlocProvider.value(
      value: _adminCubit..search(query),
      child: BlocBuilder<FoodAdminCubit, FoodAdminState>(
        builder: (context, state) {
          if (state.hasException) {
            return ErrorScrollView(state.message!);
          } else if (state.isLoading) {
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
