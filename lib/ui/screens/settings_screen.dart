import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/push_notifications.dart';
import 'package:reaxit/blocs/setting_cubit.dart';
import 'package:reaxit/blocs/theme_bloc.dart';
import 'package:reaxit/models/setting.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SettingsScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(title: Text('Settings')),
      drawer: MenuDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _ThemeModeCard(),
          Divider(),
          Text(
            'Notifications',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          // _SettingsCard(),
        ],
      ),
    );
  }

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  late final SettingsCubit _settingCubit;

  @override
  void initState() {
    var manager = PushNotificationsManager();
    print(manager);
    final api = RepositoryProvider.of<ApiRepository>(context);
    _settingCubit = SettingsCubit(api)..load();
    super.initState();
  }

  Widget _makeSetting(String receiveCategory) {
    return Text(receiveCategory);
  }

  Widget _makeNotificationSettings() {
    return BlocBuilder<SettingsCubit, SettingState>(
      bloc: _settingCubit,
      builder: (context, state) {
        if (state.hasException) {
          print("Exception");
          return RefreshIndicator(
            onRefresh: () async {
              var settingFuture = _settingCubit.load();
              await settingFuture;
            },
            child: ErrorScrollView(state.message!),
          );
        } else if (state.isLoading && state.result == null) {
          print("Loading");
          print(state.result);
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          print("done");
          print(state.result!.receiveCategory);
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ListTile.divideTiles(
                context: context,
                tiles: ['bla'].map(
                        (setting) => _makeSetting(setting),
                ),
              ).toList(),
            ),
          );
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(title: Text('Settings')),
      drawer: MenuDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _ThemeModeCard(),
          Divider(),
          Text(
            'Notifications',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          _makeNotificationSettings(),
        ],
      ),
    );
  }

}

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.brightness_6_sharp),
        title: Text(
          'Theme mode',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        trailing: BlocBuilder<ThemeBloc, ThemeMode>(
          builder: (context, themeMode) {
            return DropdownButton(
              value: themeMode,
              onChanged: (ThemeMode? newMode) async {
                BlocProvider.of<ThemeBloc>(context).add(
                  ThemeChangeEvent(newMode!),
                );
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined),
                      SizedBox(width: 15),
                      Text('Light')
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 15),
                      Text('System default')
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Row(
                    children: [
                      Icon(Icons.brightness_2_outlined),
                      SizedBox(width: 15),
                      Text('Dark')
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
/*
class _SettingsCard extends StatelessWidget {

  final List<Setting> _settings;

  @override
  void initState() {
    _settingCubit = SettingsCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, notifications, child) {
        return Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ListTile.divideTiles(
              context: context,
              tiles: notifications.settings.map(
                (setting) => _SettingCard(setting),
              ),
            ).toList(),
          ),
        );
      },
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Setting _setting;

  _SettingCard(this._setting);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: Provider.of<NotificationsProvider>(
        context,
        listen: false,
      ).getNotificatinoSetting(_setting),
      onChanged: (value) {
        Provider.of<NotificationsProvider>(
          context,
          listen: false,
        ).setNotificationSetting(_setting, value);
      },
      title: Text(_setting.name),
      subtitle: (_setting.description?.isNotEmpty ?? false)
          ? Text(_setting.description)
          : null,
    );
  }
}*/