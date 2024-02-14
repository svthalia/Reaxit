import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/tosti/blocs/shift_cubit.dart';
import 'package:reaxit/tosti/models.dart';
import 'package:reaxit/tosti/tosti_api_repository.dart';
import 'package:reaxit/ui/widgets.dart';

class TostiShiftScreen extends StatelessWidget {
  const TostiShiftScreen({required this.id, required this.api});

  final TostiApiRepository api;
  final int id;

  static final timeFormatter = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RepositoryProvider.value(
      value: api,
      child: Scaffold(
        appBar: ThaliaAppBar(title: const Text('ORDER TOSTI')),
        body: BlocProvider(
          create: (context) => TostiShiftCubit(api)..load(id),
          child: BlocBuilder<TostiShiftCubit, TostiShiftState>(
            builder: (context, state) {
              final cubit = BlocProvider.of<TostiShiftCubit>(context);

              if (state.hasException) {
                return RefreshIndicator(
                  onRefresh: () => cubit.load(id),
                  child: ErrorScrollView(state.message!),
                );
              } else if (state.shift == null ||
                  state.user == null ||
                  state.products == null ||
                  state.orders == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                final shift = state.shift!;
                final time = '${timeFormatter.format(shift.start.toLocal())}'
                    ' - ${timeFormatter.format(shift.end.toLocal())}';

                final header = SliverToBoxAdapter(
                  child: Material(
                    type: MaterialType.canvas,
                    elevation: Theme.of(context).cardTheme.elevation ?? 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                shift.venue.venue.name.toUpperCase(),
                                style: textTheme.titleLarge,
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('TIME',
                                            style: textTheme.bodySmall),
                                        const SizedBox(height: 4),
                                        Text(time, style: textTheme.titleSmall),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'CAPACITY',
                                          style: textTheme.bodySmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${shift.amountOfOrders}'
                                          ' / ${shift.maxOrdersTotal}',
                                          style: textTheme.titleSmall,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text('AT YOUR SERVICE',
                                  style: textTheme.bodySmall),
                              const SizedBox(height: 4),
                              Text(
                                shift.assignees.isNotEmpty
                                    ? shift.assignees
                                        .map((e) => e.displayName)
                                        .join(', ')
                                    : '-',
                                style: textTheme.titleSmall,
                              ),
                              const Divider(height: 24),
                              if (shift.canOrder)
                                Text(
                                  'PLACE YOUR ORDER',
                                  style: textTheme.bodySmall,
                                )
                              else
                                const Text(
                                  'This shift does not accept '
                                  'orders at this moment.',
                                ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                        if (shift.canOrder)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _OrderButtons(
                              shift: shift,
                              user: state.user!,
                              products: state.products!,
                              orders: state.orders!,
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );

                late final Widget orderList;
                if (state.orders!.isEmpty) {
                  orderList = const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'There are no orders yet.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  orderList = SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final int itemIndex = index ~/ 2;
                        if (index.isEven) {
                          return _OrderTile(
                            index: itemIndex,
                            order: state.orders![itemIndex],
                          );
                        } else {
                          return const Divider(height: 0);
                        }
                      },
                      childCount: state.orders!.length * 2,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => cubit.load(id),
                  child: CustomScrollView(
                    slivers: [header, orderList],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _OrderButtons extends StatelessWidget {
  const _OrderButtons({
    required this.shift,
    required this.user,
    required this.products,
    required this.orders,
  });

  final TostiShift shift;
  final TostiUser user;
  final List<TostiProduct> products;
  final List<TostiOrder> orders;

  @override
  Widget build(BuildContext context) {
    final userOrders = orders.where((o) => o.user?.id == user.id);
    final restrictedUserOrders = userOrders.where(
      (o) => !o.product.ignoreShiftRestrictions,
    );

    final buttons = products.map<Widget>((product) {
      String? tooltip;
      if (shift.maxOrdersTotal == shift.amountOfOrders) {
        tooltip = 'This shift is full.';
      } else if (restrictedUserOrders.length >= shift.maxOrdersPerUser) {
        tooltip = 'Max. orders in this shift reached.';
      } else {
        final userProductOrders = userOrders.where(
          (o) => o.product.id == product.id,
        );
        if (product.maxAllowedPerShift != null &&
            userProductOrders.length >= product.maxAllowedPerShift!) {
          tooltip = 'Max. orders for this product reached.';
        }
      }

      if (tooltip != null) {
        return Padding(
          key: ValueKey(product.id),
          padding: const EdgeInsets.only(left: 16),
          child: Tooltip(
            message: tooltip,
            child: ElevatedButton(
              onPressed: null,
              child: Text('${product.name} (€${product.currentPrice})'),
            ),
          ),
        );
      } else {
        return Padding(
          key: ValueKey(product.id),
          padding: const EdgeInsets.only(left: 16),
          child: ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await BlocProvider.of<TostiShiftCubit>(
                  context,
                ).order(shift.id, product);
              } on ApiException catch (_) {
                messenger.showSnackBar(const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Could not place your order.'),
                ));
              }
            },
            child: Text('${product.name} (€${product.currentPrice})'),
          ),
        );
      }
    }).toList();

    return Row(children: buttons + [const SizedBox(width: 16)]);
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.index,
    required this.order,
  });

  final int index;
  final TostiOrder order;

  @override
  Widget build(BuildContext context) {
    late final String statusText;
    late final Color statusColor;
    if (order.ready && order.paid) {
      statusText = 'Done';
      statusColor = Colors.green;
    } else if (order.ready) {
      statusText = 'Done';
      statusColor = Colors.yellow;
    } else if (order.paid) {
      statusText = 'Processing';
      statusColor = Colors.yellow;
    } else {
      statusColor = Colors.red;
      statusText = 'Not paid';
    }

    return ListTile(
      dense: true,
      title: Text(
        '${order.product.name.toUpperCase()} (€${order.orderPrice})',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: order.user != null
          ? Text(
              order.user!.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      leading: Text('${index + 1}.'),
      minLeadingWidth: 24,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(statusText, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 8.0),
          Container(
            width: 16.0,
            height: 16.0,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ],
      ),
    );
  }
}
