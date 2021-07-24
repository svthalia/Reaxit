import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
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
  // TODO: Apply the same changes as done to EventAdmin.
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
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: FoodAdminSearchDelegate(
                        FoodAdminCubit(
                          RepositoryProvider.of<ApiRepository>(context),
                          foodEventPk: widget.pk,
                        ),
                      ),
                    );
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
                    return ListView.separated(
                      itemBuilder: (context, index) => _OrderTile(
                        order: state.result![index],
                      ),
                      separatorBuilder: (_, __) => const Divider(),
                      itemCount: state.result!.length,
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
  final FoodOrder order;

  _OrderTile({required this.order}) : super(key: ValueKey(order.pk));

  @override
  __OderTileState createState() => __OderTileState();
}

class __OderTileState extends State<_OrderTile> {
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final name = order.member?.displayName ?? order.name!;

    late Widget paymentDropdown;
    if (order.isPaid && order.payment!.type == PaymentType.tpayPayment) {
      paymentDropdown = DropdownButton<PaymentType?>(
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
              content: Text(value != null
                  ? "Could not mark $name's order as paid."
                  : "Could not mark $name's order as not paid."),
              duration: const Duration(seconds: 1),
            ));
          }
        },
      );
    }

    return ListTile(
      title: Text(name, maxLines: 1),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
  List<Widget> buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return <Widget>[
        IconButton(
          tooltip: 'Clear search bar',
          icon: const Icon(Icons.delete),
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
    return BlocProvider.value(
      value: _adminCubit..load(search: query),
      child: BlocBuilder<FoodAdminCubit, FoodAdminState>(
        builder: (context, state) {
          if (state.hasException) {
            return ErrorScrollView(state.message!);
          } else if (state.result == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.separated(
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
      value: _adminCubit..load(search: query),
      child: BlocBuilder<FoodAdminCubit, FoodAdminState>(
        builder: (context, state) {
          if (state.hasException) {
            return ErrorScrollView(state.message!);
          } else if (state.result == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.separated(
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
