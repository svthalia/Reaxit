import 'package:flutter/material.dart';

class ErrorCenter extends StatelessWidget {
  final String message;

  const ErrorCenter(this.message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              height: 100,
              margin: const EdgeInsets.all(10),
              child: Image.asset(
                'assets/img/sad_cloud.png',
                fit: BoxFit.fitHeight,
              ),
            ),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
