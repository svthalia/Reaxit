import 'package:flutter/material.dart';
import 'package:reaxit/ui/components/menu_drawer.dart';
import 'package:reaxit/ui/components/cardSection/CardSection.dart';


class WelcomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome'),),
      drawer: MenuDrawer(),
      body: Container(
          color: const Color(0xffFAFAFA),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [CardSection([])]
          )
        )
      );
  }
}