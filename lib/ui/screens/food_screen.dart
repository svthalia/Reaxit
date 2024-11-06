import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets.dart';

class FoodScreen extends StatefulWidget {
  /// The pk that of the [FoodEvent] to show.
  /// If null, the current food event is found and used.
  final int? pk;

  /// The [Event] to which the [FoodEvent] belongs.
  final Event? event;

  FoodScreen({this.pk, this.event}) : super(key: ValueKey(pk));

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

// TODO: This is not actually statefull, make StatelessWidget
class _FoodScreenState extends State<FoodScreen> {
  late final FoodCubit _foodCubit;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    _foodCubit = FoodCubit(
      RepositoryProvider.of<ApiRepository>(context),
      foodEventPk: widget.pk,
    )..load();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _foodCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _foodCubit,
      child: BlocConsumer<FoodCubit, FoodState>(
        listenWhen: (previous, current) => previous == current,
        listener: (context, state) {
          _controller.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        },
        builder: (context, state) => switch (state) {
          ErrorFoodState(message: var message) => Scaffold(
              appBar: ThaliaAppBar(
                title: const Text('ORDER FOOD'),
              ),
              body: RefreshIndicator(
                onRefresh: () => _foodCubit.load(),
                child: ErrorScrollView(message),
              ),
            ),
          LoadingFoodState(oldState: null) => Scaffold(
              appBar: ThaliaAppBar(
                title: const Text('ORDER FOOD'),
              ),
              body: const Center(child: CircularProgressIndicator()),
            ),
          LoadedFoodState(foodEvent: var foodEvent, products: var products) ||
          LoadingFoodState(
            oldState: LoadedFoodState(
              foodEvent: var foodEvent,
              products: var products
            )
          ) =>
            Scaffold(
              appBar: ThaliaAppBar(
                title: const Text('ORDER FOOD'),
                collapsingActions: [
                  IconAppbarAction(
                    'ADMIN',
                    Icons.settings,
                    () => context.pushNamed(
                      'food-admin',
                      extra: foodEvent.pk,
                    ),
                    tooltip: 'food admin',
                  )
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () => _foodCubit.load(),
                child: ListView(
                  key: const PageStorageKey('food'),
                  controller: _controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    EventInfo(foodEvent),
                    OrderInfo(foodEvent, _foodCubit),
                    const Divider(),
                    Card(
                      child: Column(
                        children: ListTile.divideTiles(
                          context: context,
                          tiles: [
                            for (final product in products)
                              _ProductTile(product)
                          ],
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '${widget.product.name} ',
                style: Theme.of(context).textTheme.titleMedium!,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Text.rich(
                TextSpan(
                  text: ' €${widget.product.price}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      subtitle: widget.product.description.isNotEmpty
          ? Text(widget.product.description)
          : null,
      trailing: BlocBuilder<FoodCubit, FoodState>(
        builder: (context, state) => switch (state) {
          LoadedFoodState(foodEvent: var foodEvent, products: _) =>
            ElevatedButton(
              onPressed: foodEvent.canOrder()
                  ? () {
                      if (foodEvent.hasOrder) {
                        _changeOrder(foodEvent);
                      } else {
                        _placeOrder(foodEvent);
                      }
                    }
                  : null,
              child: const Icon(Icons.shopping_bag),
            ),
          _ => const ElevatedButton(
              onPressed: null,
              child: Icon(Icons.shopping_bag),
            )
        },
      ),
    );
  }

  Future<void> _placeOrder(FoodEvent foodEvent) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await BlocProvider.of<FoodCubit>(context).placeOrder(
        productPk: widget.product.pk,
      );
    } on ApiException {
      messenger.showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Could not place your order.'),
      ));
    }
  }

  Future<void> _changeOrder(FoodEvent foodEvent) async {
    final messenger = ScaffoldMessenger.of(context);
    final foodCubit = BlocProvider.of<FoodCubit>(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change order'),
          content: Text(
            'Are you sure you want to change your order?',
            style: Theme.of(context).textTheme.bodyMedium,
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
        await foodCubit.changeOrder(
          productPk: widget.product.pk,
        );
      } on ApiException {
        messenger.showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Could not change your order.'),
        ));
      }
    }
  }
}

class OrderInfo extends StatelessWidget {
  final FoodCubit _foodCubit;

  final FoodEvent foodEvent;

  const OrderInfo(this.foodEvent, this._foodCubit);

  void cancelOrder(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel order'),
          content: Text(
            'Are you sure you want to cancel your order?',
            style: Theme.of(context).textTheme.bodyMedium,
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
        await _foodCubit.cancelOrder();
      } on ApiException {
        messenger.showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Could not cancel your order.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget orderInfo = switch (foodEvent.order) {
      null => const SizedBox.shrink(),
      var order => Card(
          child: Column(
            children: [
              PayedCheckmark(order),
              PayedInfo(_foodCubit, foodEvent, order, cancelOrder)
            ],
          ),
        ),
    };
    return AnimatedSize(
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
        child: orderInfo,
      ),
    );
  }
}

class PayedCheckmark extends StatelessWidget {
  final FoodOrder order;

  const PayedCheckmark(this.order);

  @override
  Widget build(BuildContext context) {
    Widget icon = order.isPaid
        ? Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade400,
          )
        : Icon(
            Icons.highlight_off,
            color: Colors.red.shade900,
          );
    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: order.isPaid ? Colors.green.shade200 : Colors.red.shade700,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(32),
        child: FittedBox(
          fit: BoxFit.contain,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: icon,
          ),
        ),
      ),
    );
  }
}

class PayedInfo extends StatelessWidget {
  final FoodCubit _foodCubit;
  final FoodOrder order;
  final FoodEvent foodEvent;
  final void Function(BuildContext context) cancelOrder;
  const PayedInfo(
      this._foodCubit, this.foodEvent, this.order, this.cancelOrder);

  @override
  Widget build(BuildContext context) {
    final canChangeOrder = foodEvent.canChangeOrder();

    final cancelButton = switch (canChangeOrder) {
      false => const SizedBox.shrink(),
      true => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => cancelOrder(context),
            icon: const Icon(Icons.cancel),
            label: const Text('CANCEL ORDER'),
          ),
        ),
    };
    final hasPayedTile = Row(
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [
        Expanded(
          child: Text(
            order.product.name,
            style: Theme.of(context).textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Text(
          order.isPaid
              ? 'has been paid'
              : 'not yet paid: €${order.product.price}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
    final payButton = switch ((order.isPaid, order.tpayAllowed)) {
      (true, false) => const SizedBox.shrink(key: ValueKey(false)),
      _ => SizedBox(
          width: double.infinity,
          key: const ValueKey(true),
          child: TPayButton(
            onPay: () => _foodCubit.thaliaPayOrder(orderPk: order.pk),
            confirmationMessage: 'Are you sure you '
                'want to pay €${order.product.price} '
                'for your "${order.product.name}"?',
            failureMessage: 'Could not pay your order.',
            successMessage: 'Paid your order with Thalia Pay.',
            amount: order.product.price,
          ),
        ),
    };
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          hasPayedTile,
          if (order.product.description.isNotEmpty) ...[
            const Divider(),
            Text(order.product.description),
          ],
          AnimatedSize(
            curve: Curves.ease,
            duration: const Duration(milliseconds: 200),
            child: AnimatedSwitcher(
              switchInCurve: Curves.ease,
              switchOutCurve: Curves.ease,
              duration: const Duration(milliseconds: 200),
              child: canChangeOrder ? const Divider() : const SizedBox.shrink(),
            ),
          ),
          AnimatedSize(
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
    );
  }
}

class EventInfo extends StatefulWidget {
  final FoodEvent foodEvent;

  const EventInfo(this.foodEvent);

  @override
  State<StatefulWidget> createState() => EventInfoState();
}

class EventInfoState extends State<EventInfo> {
  static final dayTimeFormatter = DateFormat('dd/MM HH:mm');
  static final yearDayTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');
  static final timeFormatter = DateFormat('HH:mm');

  String formatDate(DateTime date) {
    final now = DateTime.now();
    if (now.day == date.day &&
        now.month == date.month &&
        now.year == date.year) {
      return timeFormatter.format(date);
    } else if (now.year == date.year) {
      return dayTimeFormatter.format(date);
    } else {
      return yearDayTimeFormatter.format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = formatDate(widget.foodEvent.start.toLocal());
    final end = formatDate(widget.foodEvent.end.toLocal());
    Text subtitle;
    if (!widget.foodEvent.hasStarted()) {
      Future.delayed(
        widget.foodEvent.start.difference(DateTime.now()),
        () {
          if (mounted) {
            setState(
              () {},
            );
          }
        },
      );

      subtitle = Text('It will be possible to order from $start.');
    } else if (widget.foodEvent.hasEnded()) {
      subtitle = Text('It was possible to order until $end.');
    } else {
      Future.delayed(
        widget.foodEvent.end.difference(DateTime.now()),
        () {
          if (mounted) {
            setState(
              () {},
            );
          }
        },
      );
      subtitle = Text('You can order until $end.');
    }

    return Column(
      children: [
        Text(
          widget.foodEvent.title,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        subtitle,
      ],
    );
  }
}
