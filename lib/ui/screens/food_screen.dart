import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/food_cubit.dart';
import 'package:reaxit/blocs/payment_user_cubit.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/food_event.dart';
import 'package:reaxit/models/product.dart';
import 'package:reaxit/ui/router.dart';
import 'package:reaxit/ui/screens/food_admin_screen.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';

class FoodScreen extends StatefulWidget {
  /// The pk that of the [FoodEvent] to show.
  final int pk;

  /// The [Event] to which the [FoodEvent] belongs.
  final Event? event;

  FoodScreen({required this.pk, this.event}) : super(key: ValueKey(pk));

  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> with TickerProviderStateMixin {
  static final timeFormatter = DateFormat('HH:mm');

  late final FoodCubit _foodCubit;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    _foodCubit = FoodCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load(widget.pk);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _foodCubit.close();
    super.dispose();
  }

  Widget _makeEventInfo(FoodEvent foodEvent) {
    var start = timeFormatter.format(foodEvent.start);
    var end = timeFormatter.format(foodEvent.end);

    Text subtitle;
    if (!foodEvent.hasStarted()) {
      subtitle = Text('It will be possible to order from $start.');
    } else if (foodEvent.hasEnded()) {
      subtitle = Text('It was possible to order until $end.');
    } else {
      subtitle = Text('You can order until $end.');
    }

    return Column(
      children: [
        Text(
          foodEvent.title,
          style: Theme.of(context).textTheme.headline5,
          textAlign: TextAlign.center,
        ),
        subtitle,
      ],
    );
  }

  Widget _makeOrderInfo(FoodEvent foodEvent) {
    return BlocBuilder<PaymentUserCubit, PaymentUserState>(
      builder: (context, paymentUserState) {
        Widget? orderCard;
        if (foodEvent.hasOrder) {
          var order = foodEvent.order!;

          // Whether at least one button is shown, so a divider is needed.
          var addDivider = false;

          late Widget cancelButton;
          if (foodEvent.canChangeOrder()) {
            addDivider = true;
            cancelButton = SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Cancel order'),
                        content: Text(
                          'Are you sure you want to cancel your order?',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        actions: [
                          TextButton.icon(
                            onPressed: () => Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pop(false),
                            icon: const Icon(Icons.clear),
                            label: const Text('No'),
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
                      await _foodCubit.cancelOrder(foodEvent.pk);
                    } on ApiException {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Could not cancel your order.'),
                      ));
                    }
                  }
                },
                icon: const Icon(Icons.cancel),
                label: const Text('CANCEL ORDER'),
              ),
            );
          } else {
            cancelButton = const SizedBox.shrink();
          }

          late Widget payButton;
          if (order.isPaid) {
            payButton = const SizedBox.shrink();
          } else if (paymentUserState.result == null) {
            // PaymentUser loading or exception.
            payButton = const SizedBox.shrink();
          } else if (!paymentUserState.result!.tpayAllowed) {
            // TPay is not allowed.
            payButton = const SizedBox.shrink();
          } else if (!order.tpayAllowed) {
            // TPay is not allowed.
            payButton = const SizedBox.shrink();
          } else if (!paymentUserState.result!.tpayEnabled) {
            // TPay is not enabled.
            payButton = SizedBox(
              key: const ValueKey('enable'),
              width: double.infinity,
              child: Tooltip(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(8),
                message: 'To start using Thalia Pay, sign '
                    'a direct debit mandate on the website.',
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.euro),
                  label: Text('THALIA PAY: €${order.product.price}'),
                ),
              ),
            );
          } else {
            // TPay can be used.
            addDivider = true;
            payButton = SizedBox(
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
                          'Are you sure you want to pay '
                          '€${order.product.price} for your '
                          '"${order.product.name}"?',
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
                      await _foodCubit.thaliaPayOrder(
                        eventPk: foodEvent.pk,
                        orderPk: order.pk,
                      );
                    } on ApiException {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Could not pay your order.'),
                      ));
                    }
                  }
                },
                icon: const Icon(Icons.euro),
                label: Text('THALIA PAY: €${order.product.price}'),
              ),
            );
          }

          orderCard = Card(
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(40),
                    color: order.isPaid
                        ? Colors.green.shade200
                        : Colors.red.shade700,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: order.isPaid
                            ? Icon(
                                Icons.check_circle_outline,
                                color: Colors.green.shade400,
                              )
                            : Icon(
                                Icons.highlight_off,
                                color: Colors.red.shade900,
                              ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            order.product.name,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text(
                            order.isPaid
                                ? 'has been paid'
                                : 'not yet paid: €${order.product.price}',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
                      if (order.product.description.isNotEmpty) ...[
                        const Divider(),
                        Text(order.product.description),
                      ],
                      AnimatedSize(
                        vsync: this,
                        curve: Curves.ease,
                        duration: const Duration(milliseconds: 200),
                        child: AnimatedSwitcher(
                          switchInCurve: Curves.ease,
                          switchOutCurve: Curves.ease,
                          duration: const Duration(milliseconds: 200),
                          child: addDivider
                              ? const Divider()
                              : const SizedBox.shrink(),
                        ),
                      ),
                      AnimatedSize(
                        vsync: this,
                        curve: Curves.ease,
                        duration: const Duration(milliseconds: 200),
                        child: AnimatedSwitcher(
                          switchInCurve: Curves.ease,
                          switchOutCurve: Curves.ease,
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: cancelButton,
                        ),
                      ),
                      AnimatedSize(
                        vsync: this,
                        curve: Curves.ease,
                        duration: const Duration(milliseconds: 200),
                        child: AnimatedSwitcher(
                          switchInCurve: Curves.ease,
                          switchOutCurve: Curves.ease,
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: payButton,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return AnimatedSize(
          vsync: this,
          curve: Curves.ease,
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            switchInCurve: Curves.ease,
            switchOutCurve: Curves.ease,
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: orderCard ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _foodCubit,
      child: BlocConsumer<FoodCubit, FoodState>(
        listenWhen: (previous, current) {
          if (previous.foodEvent != null && current.foodEvent != null) {
            if (current.foodEvent!.hasOrder) {
              return previous.foodEvent!.order != current.foodEvent!.order;
            }
          }
          return false;
        },
        listener: (context, state) {
          _controller.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        },
        builder: (context, state) {
          if (state.hasException) {
            return Scaffold(
              appBar: ThaliaAppBar(
                title: const Text('ORDER FOOD'),
              ),
              body: RefreshIndicator(
                onRefresh: () => _foodCubit.load(widget.pk),
                child: ErrorScrollView(state.message!),
              ),
            );
          } else if (state.isLoading &&
              (state.foodEvent == null || state.products == null)) {
            return Scaffold(
              appBar: ThaliaAppBar(
                title: const Text('ORDER FOOD'),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else {
            final foodEvent = state.foodEvent!;
            final products = state.products;
            return Scaffold(
              appBar: ThaliaAppBar(
                title: const Text('ORDER FOOD'),
                actions: [
                  if (foodEvent.canManage)
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        ThaliaRouterDelegate.of(context).push(
                          MaterialPage(
                            child: FoodAdminScreen(pk: foodEvent.pk),
                          ),
                        );
                      },
                    ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () => _foodCubit.load(widget.pk),
                child: ListView(
                  controller: _controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  children: [
                    _makeEventInfo(foodEvent),
                    _makeOrderInfo(foodEvent),
                    const Divider(),
                    Card(
                      child: Column(
                        children: ListTile.divideTiles(
                          context: context,
                          tiles: [
                            for (final product in products!)
                              _ProductTile(product)
                          ],
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _ProductTile extends StatefulWidget {
  final Product product;

  _ProductTile(this.product) : super(key: ValueKey(product.pk));

  @override
  __ProductTileState createState() => __ProductTileState();
}

class __ProductTileState extends State<_ProductTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: 4,
      leading: const Icon(Icons.local_pizza),
      title: Row(
        children: [
          Text(widget.product.name),
          const SizedBox(width: 5),
          Text(
            '€${widget.product.price}',
            style: Theme.of(context).textTheme.caption!.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
      subtitle: widget.product.description.isNotEmpty
          ? Text(widget.product.description)
          : null,
      trailing: BlocBuilder<FoodCubit, FoodState>(
        buildWhen: (previous, current) => current.foodEvent != null,
        builder: (context, state) {
          return ElevatedButton(
            onPressed: state.foodEvent!.canOrder()
                ? () {
                    if (state.foodEvent!.hasOrder) {
                      _changeOrder(state.foodEvent!);
                    } else {
                      _placeOrder(state.foodEvent!);
                    }
                  }
                : null,
            child: const Icon(Icons.shopping_bag),
          );
        },
      ),
    );
  }

  Future<void> _placeOrder(FoodEvent foodEvent) async {
    try {
      await BlocProvider.of<FoodCubit>(context).placeOrder(
        eventPk: foodEvent.pk,
        productPk: widget.product.pk,
      );
    } on ApiException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Could not place your order.'),
      ));
    }
  }

  Future<void> _changeOrder(FoodEvent foodEvent) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change order'),
          content: Text(
            'Are you sure you want to change your order?',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(
                context,
                rootNavigator: true,
              ).pop(false),
              icon: const Icon(Icons.clear),
              label: const Text('No'),
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
        await BlocProvider.of<FoodCubit>(context).changeOrder(
          eventPk: foodEvent.pk,
          productPk: widget.product.pk,
        );
      } on ApiException {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Could not change your order.'),
        ));
      }
    }
  }
}
