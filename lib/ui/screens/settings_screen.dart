import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/providers/notifications_provider.dart';
import 'package:reaxit/providers/theme_mode_provider.dart';
import 'package:reaxit/ui/components/menu_drawer.dart';
import 'package:reaxit/models/setting.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      drawer: MenuDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _ThemeModeCard(),
          Divider(),
          Text(
            "Notifications",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          _SettingsCard(),
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
      child: Consumer<ThemeModeProvider>(
        builder: (context, themeModeProvider, child) {
          return ListTile(
            leading: Icon(Icons.brightness_6_sharp),
            title: Text(
              "Theme mode",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: DropdownButton(
              value: themeModeProvider.themeMode,
              onChanged: (newThemeMode) async {
                themeModeProvider.setThemeMode(newThemeMode);
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined),
                      SizedBox(width: 15),
                      Text("Light")
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 15),
                      Text("System default")
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Row(
                    children: [
                      Icon(Icons.brightness_2_outlined),
                      SizedBox(width: 15),
                      Text("Dark")
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, _notifications, child) {
        return Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ListTile.divideTiles(
              context: context,
              tiles: _notifications.settings
                  .map((setting) => _SettingCard(setting)),
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
      value: Provider.of<NotificationsProvider>(context, listen: false)
          .getNotificatinoSetting(_setting),
      onChanged: (value) {
        Provider.of<NotificationsProvider>(context, listen: false)
            .setNotificationSetting(this._setting, value);
      },
      title: Text(_setting.name),
      subtitle: (_setting.description?.isNotEmpty ?? false)
          ? Text(_setting.description)
          : null,
    );
  }
}
