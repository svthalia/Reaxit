import 'package:flutter/material.dart';

class CalendarEventCard extends StatelessWidget {
  final String _title;
  final String _start_time;
  final String _end_time;
  final String _location;
  final bool _registered;

  CalendarEventCard(this._title, this._start_time, this._end_time, this._location, this._registered);


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(1), color: this._registered ? Color(0xFFE62272) : Colors.grey,),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(this._title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(this._start_time + ' - ' + this._end_time + ' | ' + this._location, style: TextStyle(color: Colors.white)),
        ],
      )
    );
  }
}