import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/payment.dart';

class PayTile extends StatelessWidget {
  final Payment payment;
  static final timeFormatter = DateFormat('E d MMM y, HH:mm');

  const PayTile({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
          child: ListTile(
        title: Text(
          timeFormatter.format(payment.createdAt.toLocal()),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          payment.topic,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '€ ${payment.amount}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      )),
    );
  }
}
