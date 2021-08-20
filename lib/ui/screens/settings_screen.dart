import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/setting_cubit.dart';
import 'package:reaxit/blocs/theme_bloc.dart';
import 'package:reaxit/models/push_notification_category.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';

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
                  const _ThemeModeCard(),
                  const Divider(),
                  Text(
                    'Notifications',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Center(child: Text(state.message!)),
                ],
              ),
            );
          } else if (state.isLoading && state.categories == null) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _ThemeModeCard(),
                const Divider(),
                Text(
                  'Notifications',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const Center(child: CircularProgressIndicator()),
              ],
            );
          } else {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _ThemeModeCard(),
                const Divider(),
                Text(
                  'Notifications',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Card(
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
      child: ListTile(
        leading: const Icon(Icons.brightness_6_sharp),
        title: Text(
          'Theme',
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
