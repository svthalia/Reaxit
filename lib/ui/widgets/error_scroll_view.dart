import 'package:flutter/material.dart';

class ErrorScrollView extends StatelessWidget {
  final String message;
  final void Function()? retry;
  final bool? shrinkWrap;

  const ErrorScrollView(this.message, {super.key, this.retry, this.shrinkWrap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          margin: const EdgeInsets.all(12),
          child: Image.asset('assets/img/sad-cloud.png', fit: BoxFit.fitHeight),
        ),
        Text(message, textAlign: TextAlign.center),
        if (retry != null)
          Center(
            child: TextButton(onPressed: retry, child: Text('Retry')),
          ),
      ],
    );
  }
}
