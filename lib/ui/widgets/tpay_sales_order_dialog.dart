import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/payment_user_cubit.dart';
import 'package:reaxit/blocs/sales_order_cubit.dart';

class TPaySalesOrderDialog extends StatefulWidget {
  final String pk;

  TPaySalesOrderDialog({required this.pk}) : super(key: ValueKey(pk));

  @override
  _TPaySalesOrderDialogState createState() => _TPaySalesOrderDialogState();
}

class _TPaySalesOrderDialogState extends State<TPaySalesOrderDialog>
    with TickerProviderStateMixin {
  late final SalesOrderCubit _salesOrderCubit;

  @override
  void initState() {
    _salesOrderCubit = SalesOrderCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load(widget.pk);
    super.initState();
  }

  @override
  void dispose() {
    _salesOrderCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentUserCubit, PaymentUserState>(
      builder: (context, paymentUserState) {
        return BlocBuilder<SalesOrderCubit, SalesOrderState>(
          bloc: _salesOrderCubit,
          builder: (context, orderState) {
            late Widget content;
            late Widget payButton;
            if (paymentUserState.result == null) {
              // PaymentUser loading or exception.
              payButton = ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.euro),
                label: const Text('THALIA PAY'),
              );
            } else if (!paymentUserState.result!.tpayAllowed) {
              payButton = payButton = ElevatedButton.icon(
                // TPay is not allowed.
                onPressed: null,
                icon: const Icon(Icons.euro),
                label: const Text('THALIA PAY'),
              );
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
                    label: const Text('THALIA PAY'),
                  ),
                ),
              );
            } else if (orderState.hasException) {
              // Order can't be loaded.
              payButton = ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.euro),
                label: const Text('THALIA PAY'),
              );
            } else if (orderState.isLoading) {
              // Order is loading
              payButton = ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.euro),
                label: const Text('THALIA PAY'),
              );
            } else {
              // TPay can be used.
              final order = orderState.result!;
              payButton = ElevatedButton.icon(
                onPressed: _paySalesOrder,
                icon: const Icon(Icons.euro),
                label: Text('THALIA PAY: €${order.amount}'),
              );
            }

            if (orderState.hasException) {
              content = Text(
                orderState.message!,
                style: Theme.of(context).textTheme.bodyText2,
              );
              payButton = ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.euro),
                label: const Text('THALIA PAY'),
              );
            } else if (orderState.isLoading) {
              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: const [CircularProgressIndicator()],
              );
            } else {
              final order = orderState.result!;

              // TODO: Handle already paid, under-age, etc. Waiting for
              //  https://github.com/svthalia/concrexit/issues/1785.
              content = Text(
                'Are you sure you want to pay '
                '€${order.amount} for ${order.notes}?',
                style: Theme.of(context).textTheme.bodyText2,
              );
            }

            return AlertDialog(
              title: const Text('Pay for order'),
              content: AnimatedSize(
                vsync: this,
                duration: const Duration(milliseconds: 300),
                child: content,
              ),
              actions: [
                TextButton.icon(
                  onPressed: () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(),
                  icon: const Icon(Icons.clear),
                  label: const Text('CANCEL'),
                ),
                AnimatedSize(
                  vsync: this,
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 200),
                  child: payButton,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _paySalesOrder() async {
    try {
      await _salesOrderCubit.paySalesOrder(widget.pk);
      Navigator.of(context, rootNavigator: true).pop();
      // TODO: Confirmation animation.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Payed you order with Thalia Pay.'),
      ));
    } on ApiException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not pay your order.'),
      ));
    }
  }
}
