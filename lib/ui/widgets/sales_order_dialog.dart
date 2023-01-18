import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/ui/widgets.dart';

class SalesOrderDialog extends StatefulWidget {
  final String pk;

  SalesOrderDialog({required this.pk}) : super(key: ValueKey(pk));

  @override
  State<SalesOrderDialog> createState() => _SalesOrderDialogState();
}

class _SalesOrderDialogState extends State<SalesOrderDialog> {
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
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<SalesOrderCubit, SalesOrderState>(
      bloc: _salesOrderCubit,
      builder: (context, orderState) {
        late final Widget content;
        late final Widget payButton;

        if (orderState is ResultState) {
          final order = orderState.result!;

          if (order.numItems == 0) {
            content = Text(
              'The order is empty.',
              style: textTheme.bodyText2,
            );
          } else {
            content = Text(
              order.orderDescription,
              style: textTheme.bodyText2,
            );
          }

          if (order.totalAmount == '0.00') {
            payButton = const SizedBox.shrink();
          } else if (!order.tpayAllowed) {
            payButton = const SizedBox.shrink();
          } else {
            payButton = TPayButton(
              onPay: _paySalesOrder,
              confirmationMessage: 'Are you sure you want '
                  'to pay €${order.totalAmount} for your '
                  'order of ${order.orderDescription}?',
              failureMessage: 'Could not pay your order.',
              successMessage: 'Paid your order with Thalia Pay.',
              amount: order.totalAmount,
            );
          }
        } else if (orderState is ErrorState) {
          content = Text(
            orderState.message!,
            style: textTheme.bodyText2,
          );
          payButton = const SizedBox.shrink();
        } else {
          content = const Center(child: CircularProgressIndicator());
          payButton = const SizedBox.shrink();
        }

        return AlertDialog(
          title: const Text('Your order'),
          content: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [content],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(
                context,
                rootNavigator: true,
              ).pop(),
              icon: const Icon(Icons.clear),
              label: const Text('CLOSE'),
            ),
            AnimatedSize(
              curve: Curves.ease,
              duration: const Duration(milliseconds: 200),
              child: payButton,
            ),
          ],
        );
      },
    );
  }

  Future<void> _paySalesOrder() async {
    await _salesOrderCubit.paySalesOrder(widget.pk);
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }
}
