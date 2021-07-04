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
            if (orderState.hasException) {
              content = Text(
                orderState.message!,
                style: Theme.of(context).textTheme.bodyText2,
              );
            } else if (orderState.isLoading) {
              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: [CircularProgressIndicator()],
              );
            } else {
              final payable = orderState.result!;

              // TODO: Handle already paid, under-age, etc. Waiting for
              //  https://github.com/svthalia/concrexit/issues/1785.
              content = Text(
                'Are you sure you want to pay '
                '€${payable.amount} for ${payable.notes}?',
                style: Theme.of(context).textTheme.bodyText2,
              );
            }

            return AlertDialog(
              title: Text('Pay for order'),
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
                  icon: Icon(Icons.clear),
                  label: Text('CANCEL'),
                ),
                ElevatedButton.icon(
                  // TODO: Check user's TPay possibility!
                  onPressed: orderState.result != null &&
                          orderState.result!.tpayAllowed
                      ? _paySalesOrder
                      : null,
                  icon: Icon(Icons.check),
                  label: Text('THALIA PAY'),
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

      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();
      // TODO: Confirmation animation.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payed you order with Thalia Pay.'),
        ),
      );
    } on ApiException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not pay your order.'),
        ),
      );
    }
  }
}
