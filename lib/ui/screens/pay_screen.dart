import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/payment_user_cubit.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/pay_tile.dart';

class PayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(
        title: const Text('THALIA PAY'),
      ),
      drawer: MenuDrawer(),
      body: RefreshIndicator(
        onRefresh: () => BlocProvider.of<PaymentUserCubit>(context).load(),
        child: BlocBuilder<PaymentUserCubit, PaymentUserState>(
            builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state.hasException) {
            return ErrorScrollView(state.message!);
          } else {
            return _Body(payments: state.payments!);
          }
        }),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final List<Payment> payments;

  const _Body({
    Key? key,
    required this.payments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: payments.length + 1,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return const _Header();
        } else {
          return PayTile(payment: payments[index - 1]);
        }
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentUserCubit, PaymentUserState>(
      builder: (context, state) {
        final String balance;
        if (state.isLoading) {
          balance = '-';
        } else {
          balance = '€ ${state.user!.tpayBalance}';
        }

        return Material(
          type: MaterialType.card,
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CURRENT BALANCE: $balance',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
