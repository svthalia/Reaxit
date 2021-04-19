import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/blocs/welcome_cubit.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:reaxit/ui/screens/calendar_screen.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/ui/widgets/event_detail_card.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';
import 'package:reaxit/ui/screens/profile_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
      drawer: MenuDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await BlocProvider.of<WelcomeCubit>(context).load();
        },
        child: BlocBuilder<WelcomeCubit, DetailState<List<Event>>>(
          builder: (context, state) {
            if (state.hasException) {
              return ErrorScrollView(state.message!);
            } else {
              return ListView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (state.result != null)
                    ...state.result!.map(
                      (event) => EventDetailCard(event: event),
                    ),
                  TextButton(
                    onPressed: () => ThaliaRouterDelegate.of(context).replace(
                      MaterialPage(child: CalendarScreen()),
                    ),
                    child: Text('SHOW THE ENTIRE AGENDA'),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
