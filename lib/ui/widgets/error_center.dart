import 'package:flutter/material.dart';

class ErrorCenter extends StatelessWidget {
  final List<Widget> children;

  const ErrorCenter(this.children, {super.key});
  ErrorCenter.fromMessage(String message, {super.key})
    : children = [Text(message, textAlign: TextAlign.center)];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 100,
              margin: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/img/sad-cloud.png',
                fit: BoxFit.fitHeight,
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
