import 'package:flutter/material.dart';
import 'package:reaxit/models/payment.dart';

class PaymentOverrideDropdown extends StatelessWidget {
  final PaymentType? type;
  final ValueChanged<PaymentType?>? onChanged;
  final bool tpSupported;
  final bool cardSupported;
  final bool cashSupported;
  final bool wireSupported;

  const PaymentOverrideDropdown({
    this.type,
    this.onChanged,
    this.tpSupported = false,
    this.cardSupported = false,
    this.cashSupported = false,
    this.wireSupported = false,
  });

  DropdownMenuItem<PaymentType?> getMenuitem(PaymentType type) {
    return DropdownMenuItem(value: type, child: Text(type.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<PaymentType?>(
      style: Theme.of(context).textTheme.bodyMedium,
      items: [
        if (tpSupported) getMenuitem(PaymentType.tpayPayment),
        if (cardSupported) getMenuitem(PaymentType.cardPayment),
        if (cashSupported) getMenuitem(PaymentType.cashPayment),
        if (wireSupported) getMenuitem(PaymentType.wirePayment),
        const DropdownMenuItem(value: null, child: Text('Not paid')),
      ],
      value: type,
      onChanged: onChanged,
    );
  }
}
