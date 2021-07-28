import 'package:flutter/material.dart';

class ErrorScrollView extends StatelessWidget {
  final String message;

  const ErrorScrollView(this.message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 100,
          margin: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/img/sad_cloud.png',
            fit: BoxFit.fitHeight,
          ),
        ),
        Text(message, textAlign: TextAlign.center),
      ],
    );
  }
}
