import 'package:flutter/material.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';

class FoodAdminScreen extends StatefulWidget {
  final int pk;

  FoodAdminScreen({required this.pk}) : super(key: ValueKey(pk));

  @override
  _FoodAdminScreenState createState() => _FoodAdminScreenState();
}

class _FoodAdminScreenState extends State<FoodAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(),
      body: Center(
        child: Text('Food admin ${widget.pk}'),
      ),
    );
  }
}
