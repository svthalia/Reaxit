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
        final Widget content = switch (orderState) {
          ErrorState(message: var messsage) => Text(
            messsage,
            style: textTheme.bodyMedium,
          ),
          LoadingState _ => const Center(child: CircularProgressIndicator()),
          ResultState(result: var order) when order.numItems == 0 => Text(
            'The order is empty.',
            style: textTheme.bodyMedium,
          ),
          ResultState(result: var order) => Text(
            order.orderDescription,
            style: textTheme.bodyMedium,
          ),
        };
        late final Widget payButton = switch (orderState) {
          ErrorState _ => const SizedBox.shrink(),
          LoadingState _ => const SizedBox.shrink(),
          ResultState(result: var order)
              when order.totalAmount == '0.00' || !order.tpayAllowed =>
            const SizedBox.shrink(),
          ResultState(result: var order) => TPayButton(
            onPay: _paySalesOrder,
            confirmationMessage:
                'Are you sure you want '
                'to pay €${order.totalAmount} for your '
                'order of ${order.orderDescription}?',
            failureMessage: 'Could not pay your order.',
            successMessage: 'Paid your order with Thalia Pay.',
            amount: order.totalAmount,
          ),
        };

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
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
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
