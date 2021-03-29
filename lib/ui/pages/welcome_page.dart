import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/router/router.dart';
import 'package:reaxit/ui/menu_drawer.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: MenuDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Welcome page'),
            ElevatedButton(
              onPressed: () {
                AutoRouter.of(context).pushPath('/members/5');
              },
              child: Text('to 5'),
            ),
            ElevatedButton(
              onPressed: () async {
                await AutoRouter.of(context).replaceAll([LoginRoute()]);
                BlocProvider.of<AuthBloc>(context, listen: false).add(
                  LogOutAuthEvent(),
                );
              },
              child: Text('log out'),
            )
          ],
        ),
      ),
    );
  }
}
