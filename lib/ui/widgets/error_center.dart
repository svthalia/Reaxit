import 'package:flutter/material.dart';

class ErrorCenter extends StatelessWidget {
  final List<Widget> children;

  const ErrorCenter(this.children, {Key? key}) : super(key: key);
  ErrorCenter.fromMessage(String message, {Key? key})
      : children = [Text(message, textAlign: TextAlign.center)],
        super(key: key);

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
