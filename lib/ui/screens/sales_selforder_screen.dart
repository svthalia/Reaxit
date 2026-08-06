import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/models/shift.dart';
import 'package:reaxit/models/shift_product.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/dialog.dart';

class SelforderScreen extends StatefulWidget {
  /// The pk that of the [SalesShiftCubit] to show.
  /// If null, the current food event is found and used.
  final int shiftpk;

  SelforderScreen({required this.shiftpk}) : super(key: ValueKey(shiftpk));

  @override
  State<SelforderScreen> createState() => _SelforderScreenState();
}

// TODO: This is not actually statefull, make StatelessWidget
class _SelforderScreenState extends State<SelforderScreen> {
  late final SalesShiftCubit _salesCubit;
  SalesOrderCubit? _orderCubit;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    _salesCubit = SalesShiftCubit(
      RepositoryProvider.of<ApiRepository>(context),
      widget.shiftpk,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _salesCubit.close();
    if (_orderCubit != null) {
      _orderCubit!.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _salesCubit,
      child: BlocConsumer<SalesShiftCubit, SalesShiftState>(
        listenWhen: (previous, current) => previous == current,
        listener: (context, state) {
          _controller.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        },
        builder: (context, state) {
          const title = Text('ORDER FOOD');
          switch (state) {
            case ErrorState(message: var message):
              return Scaffold(
                appBar: ThaliaAppBar(title: title),
                body: RefreshIndicator(
                  onRefresh: _salesCubit.reload,
                  child: ErrorScrollView(message),
                ),
              );
            case ResultState(result: ShiftOrder(order: null)) ||
                LoadingResultState(result: ShiftOrder(order: null)):
              return Scaffold(
                appBar: ThaliaAppBar(title: title),
                body: const Center(child: CircularProgressIndicator()),
              );
            case ResultState(result: ShiftOrder(order: final order!)) ||
                LoadingResultState(result: ShiftOrder(order: final order!)):
              if (_orderCubit == null || _orderCubit!.shiftpk != order.shift) {
                if (_orderCubit != null) {
                  _orderCubit!.close();
                }
                _orderCubit = SalesOrderCubit.fromExisting(
                  _salesCubit.api,
                  order,
                );
              }
              return BlocProvider.value(
                value: _orderCubit!,
                child: Scaffold(
                  appBar: ThaliaAppBar(
                    title: const Text('ORDER FOOD'),
                    collapsingActions: [
                      IconAppbarAction(
                        'ADMIN',
                        Icons.settings,
                        () => context.pushNamed(
                          'sales-shift-admin',
                          extra: widget.shiftpk,
                        ),
                        tooltip: 'food admin',
                      ),
                    ],
                  ),
                  body: switch (state) {
                    ErrorState(message: final message) => RefreshIndicator(
                      onRefresh: _salesCubit.reload,
                      child: ErrorScrollView(message),
                    ),
                    LoadingState() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    ResultState(result: ShiftOrder(shift: null)) ||
                    LoadingResultState(
                      result: ShiftOrder(shift: null),
                    ) => RefreshIndicator(
                      onRefresh: () => _salesCubit.reload(),
                      child: ErrorScrollView('Unable to change order.'),
                    ),
                    ResultState(result: ShiftOrder(shift: final shift)) ||
                    LoadingResultState(
                      result: ShiftOrder(shift: final shift),
                    ) => RefreshIndicator(
                      onRefresh: () => _salesCubit.reload(),
                      child: ListView(
                        key: const PageStorageKey('food'),
                        controller: _controller,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        children: [
                          ShiftInfo(shift!),
                          CurrentOrderInfo(shift),
                          const Divider(),
                          Card(
                            child: Column(
                              children:
                                  ListTile.divideTiles(
                                    context: context,
                                    tiles: [
                                      for (final product in shift.products)
                                        _ProductTile(product),
                                    ],
                                  ).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  },
                ),
              );
            case _:
              return Scaffold(
                appBar: ThaliaAppBar(title: title),
                body: const Center(child: CircularProgressIndicator()),
              );
          }
        },
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ShiftListProduct product;

  _ProductTile(this.product) : super(key: ValueKey(product.name));

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
                text: '${product.name} ',
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
                  text: ' €${product.price}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      subtitle: null,
      trailing: AYNStepperView(productName: product.name),
    );
  }
}

class AYNStepperView extends StatelessWidget {
  final String productName;

  const AYNStepperView({super.key, required this.productName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const height = 35.0;

    const leftButtonStyle = ButtonStyle(
      padding: WidgetStatePropertyAll(EdgeInsetsGeometry.fromLTRB(0, 0, 0, 0)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(height / 2),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(height / 2),
            bottomRight: Radius.circular(0),
          ),
        ),
      ),
    );

    const rightButtonStyle = ButtonStyle(
      padding: WidgetStatePropertyAll(EdgeInsetsGeometry.fromLTRB(0, 0, 0, 0)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(height / 2),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(height / 2),
          ),
        ),
      ),
    );

    return BlocBuilder<SalesOrderCubit, SalesOrderState>(
      builder: (context, state) {
        int? count = switch (state) {
          ResultState(result: RemoteOrderState(order: final order)) =>
            order.orderItems
                    .where((i) => i.product == productName)
                    .firstOrNull
                    ?.amount ??
                0,

          ResultState(result: LocalOrderState(items: final items)) =>
            items.where((i) => i.product == productName).firstOrNull?.amount ??
                0,
          _ => 0,
        };
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: height - 5,
              height: height,
              child: ElevatedButton(
                style: leftButtonStyle,
                child: Icon(Icons.remove, color: Colors.white),
                onPressed: () => _subOrder(context),
              ),
            ),
            // TODO: Can this padding be combined??
            Padding(
              padding: EdgeInsetsGeometry.fromSTEB(2, 0, 2, 0),
              child: Container(
                padding: EdgeInsetsGeometry.fromSTEB(5, 0, 5, 0),
                height: height,
                color: theme.colorScheme.primary,
                child: Center(
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Color(0xffffffff),
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: height - 5,
              height: height,
              child: ElevatedButton(
                style: rightButtonStyle,
                child: Icon(Icons.add, color: Colors.white),
                onPressed: () => _incOrder(context),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _incOrder(BuildContext context) async {
    final cubit = BlocProvider.of<SalesOrderCubit>(context);
    cubit.addOrder(productName);
  }

  Future<void> _subOrder(BuildContext context) async {
    final cubit = BlocProvider.of<SalesOrderCubit>(context);
    cubit.subOrder(productName);
  }
}

class CurrentOrderInfo extends StatelessWidget {
  final Shift foodEvent;
  const CurrentOrderInfo(this.foodEvent);

  void cancelOrder(BuildContext context) async {
    final foodcubit = BlocProvider.of<SalesOrderCubit>(context);
    if (foodcubit.isPaid()) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmationDialog(
      context,
      'Cancel order',
      'Are you sure you want to cancel your order?',
    );

    if (confirmed) {
      try {
        await foodcubit.cancelOrder();
      } on ApiException {
        messenger.showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not cancel your order.'),
          ),
        );
      }
    }
  }

  Future<void> _updateOrder(BuildContext context) async {
    final foodcubit = BlocProvider.of<SalesOrderCubit>(context);
    if (foodcubit.isPaid()) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmationDialog(
      context,
      'Update order',
      'Are you sure you want to update your order?',
    );

    if (confirmed) {
      try {
        foodcubit.submit();
      } on ApiException {
        messenger.showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not update your order.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: BlocBuilder<SalesOrderCubit, SalesOrderState>(
          builder:
              (context, state) => Card(
                child: Column(
                  children: [
                    PayedCheckmark(state),
                    PayedInfo(foodEvent, cancelOrder, _updateOrder, state),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

class PayedCheckmark extends StatelessWidget {
  final SalesOrderState state;
  const PayedCheckmark(this.state);

  @override
  Widget build(BuildContext context) {
    final bool isSynced = SalesOrderCubit.checkIfSynced(state);
    final bool isPaid = SalesOrderCubit.checkIfPaid(state);

    if (!isSynced) {
      return Container();
    }

    Widget icon =
        isPaid
            ? Icon(Icons.check_circle_outline, color: Colors.green.shade400)
            : Icon(Icons.highlight_off, color: Colors.red.shade900);
    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: isPaid ? Colors.green.shade200 : Colors.red.shade700,
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
  final Shift shift;
  final void Function(BuildContext context) cancelOrder;
  final void Function(BuildContext context) syncOrder;
  final SalesOrderState state;
  const PayedInfo(this.shift, this.cancelOrder, this.syncOrder, this.state);

  @override
  Widget build(BuildContext context) {
    final canOrder = shift.canOrder();
    final cubit = BlocProvider.of<SalesOrderCubit>(context);
    final bool isSynced = SalesOrderCubit.checkIfSynced(state);
    final bool isPaid = SalesOrderCubit.checkIfPaid(state);

    final cancelButton = switch (canOrder && isSynced) {
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
    // This button shows the next step of the order process
    // If the order hasn't been synced yet it is a sync button,
    // if the order has been synced and tpay is allowed it shows a tpay button
    final nextButton = SizedBox(
      width: double.infinity,
      child: BlocBuilder<SalesOrderCubit, SalesOrderState>(
        builder: (context, state) {
          return switch (state) {
            ResultState(result: LocalOrderState(items: _)) ||
            ResultState(
              result: RemoteOrderState(synced: false),
            ) => ElevatedButton.icon(
              onPressed: () => syncOrder(context),
              icon: const Icon(Icons.sync),
              label: const Text('UPDATE ORDER'),
            ),
            ResultState(result: RemoteOrderState(order: final order)) =>
              switch (order.tpayAllowed) {
                true => TPayButton(
                  onPay: cubit.paySalesOrder,
                  confirmationMessage:
                      'Are you sure you '
                      'want to pay €${order.subtotal} '
                      'for your order?',
                  failureMessage: 'Could not pay your order.',
                  successMessage: 'Paid your order with Thalia Pay.',
                  amount: order.subtotal,
                ),
                _ => const SizedBox.shrink(),
              },
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSize(
            curve: Curves.ease,
            duration: const Duration(milliseconds: 200),
            child: AnimatedSwitcher(
              switchInCurve: Curves.ease,
              switchOutCurve: Curves.ease,
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child:
                  (canOrder && isPaid)
                      ? const Divider()
                      : const SizedBox.shrink(),
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
                return ScaleTransition(scale: animation, child: child);
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
                return ScaleTransition(scale: animation, child: child);
              },
              child: switch ((canOrder, isPaid)) {
                (true, false) => nextButton,
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShiftInfo extends StatefulWidget {
  final Shift foodEvent;

  const ShiftInfo(this.foodEvent);

  @override
  State<StatefulWidget> createState() => ShiftInfoState();
}

class ShiftInfoState extends State<ShiftInfo> {
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

  void scheduleReload() {
    if (!widget.foodEvent.hasStarted()) {
      Future.delayed(widget.foodEvent.start.difference(DateTime.now()), () {
        if (mounted) {
          setState(() {});
        }
      });
    } else if (!widget.foodEvent.hasEnded()) {
      Future.delayed(widget.foodEvent.end.difference(DateTime.now()), () {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = formatDate(widget.foodEvent.start.toLocal());
    final end = formatDate(widget.foodEvent.end.toLocal());
    final Text subtitle = switch ((
      widget.foodEvent.hasStarted(),
      widget.foodEvent.hasEnded(),
    )) {
      (false, _) => Text('It will be possible to order from $start.'),
      (_, false) => Text('You can order until $end.'),
      _ => Text('It was possible to order until $end.'),
    };

    scheduleReload();

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
