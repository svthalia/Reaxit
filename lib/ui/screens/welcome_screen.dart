
import 'package:flutter/material.dart';
import 'package:reaxit/ui/components/menu_drawer.dart';
import 'package:reaxit/ui/components/card_section.dart';
import 'package:reaxit/ui/components/event_detail_card.dart';
import '../components/event_detail_card.dart';

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
            children: [
              EventDetailCard("Evenement titel", "18:30", "19:30", "Huygens", "Dit is een beschrijving", false),
              EventDetailCard("Evenement titel", "18:30", "19:30", "Huygens", "Dit is een beschrijving", true),
            ]
          )
        )
      );
  }
}