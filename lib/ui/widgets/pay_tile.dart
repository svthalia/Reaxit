import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/payment.dart';

class PayTile extends StatefulWidget {
  final Payment payment;

  const PayTile({super.key, required this.payment});

  @override
  State<StatefulWidget> createState() => _PayTileState();
}

class _PayTileState extends State<PayTile> with SingleTickerProviderStateMixin {
  static final timeFormatter = DateFormat('E d MMM y, HH:mm');

  late bool _isExpanded;

  @override
  void initState() {
    _isExpanded = false;
    super.initState();
  }

  void _onTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
            child: ListTile(
          onTap: _onTap,
          title: Text(
            timeFormatter.format(widget.payment.createdAt.toLocal()),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            widget.payment.topic,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '€ ${widget.payment.amount}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _isExpanded
              ? Card(
                  child: ListTile(
                    title: Text(
                      widget.payment.notes ?? 'No notes provided',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
