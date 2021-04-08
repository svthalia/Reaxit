import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/event_list_bloc.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';

class CalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar')),
      drawer: MenuDrawer(),
      body: BlocBuilder<EventListBloc, EventListState>(
        builder: (context, listState) {
          print(listState);
          if (listState.hasException) {
            // TODO: proper error screen
            return Text(listState.message!);
          } else {
            return ListView.builder(
              // TODO: change this to the expected number? without breaking if we havent loaded those yet.
              itemCount: listState.results.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(listState.results[index].title),
              ),
            );
          }
        },
      ),
    );
  }
}
