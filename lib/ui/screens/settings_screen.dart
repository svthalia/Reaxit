import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/setting_cubit.dart';
import 'package:reaxit/blocs/theme_bloc.dart';
import 'package:reaxit/models/push_notification_category.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';
import 'package:reaxit/config.dart' as config;
import 'package:url_launcher/link.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Widget _makeSetting(PushNotificationCategory category, bool enabled) {
    Widget? subtitle;
    if (category.description.isNotEmpty) {
      subtitle = Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          category.description,
          maxLines: 2,
        ),
      );
    }

    if (category.key == 'general') {
      // The general category is always enabled and can't be disabled.
      return SwitchListTile(
        value: true,
        onChanged: null,
        title: Text(category.name.toUpperCase()),
        subtitle: subtitle,
      );
    }
    return SwitchListTile(
      value: enabled,
      onChanged: (value) async {
        try {
          await BlocProvider.of<SettingsCubit>(context).setSetting(
            category.key,
            value,
          );
        } on ApiException {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not change your notification settings.'),
          ));
        }
      },
      title: Text(category.name.toUpperCase()),
      subtitle: subtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: ThaliaAppBar(title: const Text('SETTINGS')),
      drawer: MenuDrawer(),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state.hasException) {
            return RefreshIndicator(
              onRefresh: () => BlocProvider.of<SettingsCubit>(context).load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('About', style: textTheme.caption),
                  const _AboutCard(),
                  const SizedBox(height: 8),
                  Text('Theme', style: textTheme.caption),
                  const _ThemeModeCard(),
                  const SizedBox(height: 8),
                  Text('Notifications', style: textTheme.caption),
                  Center(child: Text(state.message!)),
                ],
              ),
            );
          } else if (state.isLoading && state.categories == null) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('About', style: textTheme.caption),
                const _AboutCard(),
                const SizedBox(height: 8),
                Text('Theme', style: textTheme.caption),
                const _ThemeModeCard(),
                const SizedBox(height: 8),
                Text('Notifications', style: textTheme.caption),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          } else {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('About', style: textTheme.caption),
                const _AboutCard(),
                const SizedBox(height: 8),
                Text('Theme', style: textTheme.caption),
                const _ThemeModeCard(),
                const SizedBox(height: 8),
                Text('Notifications', style: textTheme.caption),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ListTile.divideTiles(
                      context: context,
                      tiles: state.categories!.map(
                        (category) => _makeSetting(
                          category,
                          state.device!.receiveCategory.contains(
                            category.key,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          'COLOR SCHEME',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        trailing: BlocBuilder<ThemeBloc, ThemeMode>(
          builder: (context, themeMode) {
            return DropdownButton(
              value: themeMode,
              style: Theme.of(context).textTheme.bodyText2,
              onChanged: (ThemeMode? newMode) async {
                BlocProvider.of<ThemeBloc>(context).add(
                  ThemeChangeEvent(newMode!),
                );
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Row(
                    children: const [
                      Icon(Icons.wb_sunny_outlined),
                      SizedBox(width: 16),
                      Text('Light')
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Row(
                    children: const [
                      Icon(Icons.settings),
                      SizedBox(width: 16),
                      Text('System default')
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Row(
                    children: const [
                      Icon(Icons.brightness_2_outlined),
                      SizedBox(width: 16),
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

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset(
                  Theme.of(context).brightness == Brightness.light
                      ? 'assets/img/logo-t-zwart.png'
                      : 'assets/img/logo-t-wit.png',
                  width: 80,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ListBody(
                      children: <Widget>[
                        const SizedBox(height: 4),
                        Text(
                          'ThaliApp',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        Text(
                          config.versionNumber,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'There is an app for everything.',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(height: 8),
            Link(
              uri: Uri.parse(
                'https://github.com/svthalia/Reaxit/releases',
              ),
              builder: (context, followLink) => OutlinedButton.icon(
                onPressed: followLink,
                icon: const Icon(Icons.history),
                label: const Text('CHANGELOG'),
              ),
            ),
            Link(
              uri: Uri.parse(
                'https://github.com/svthalia/Reaxit/issues',
              ),
              builder: (context, followLink) => OutlinedButton.icon(
                onPressed: followLink,
                icon: const Icon(Icons.bug_report_outlined),
                label: const Text('FEEDBACK'),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => showLicensePage(context: context),
              label: const Text('VIEW LICENSES'),
              icon: const Icon(Icons.info_outline),
            )
          ],
        ),
      ),
    );
  }
}
