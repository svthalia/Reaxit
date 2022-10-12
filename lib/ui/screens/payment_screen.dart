import 'package:flutter/material.dart';
import 'package:reaxit/ui/widgets.dart';

class PayScreen extends StatefulWidget {
  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(
        title: const Text('THALIA PAY'),
        actions: [],
      ),
      drawer: MenuDrawer(),
    );
  }
}
