import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/setting_cubit.dart';
import 'package:reaxit/blocs/theme_bloc.dart';
import 'package:reaxit/models/category.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';

class SettingsScreen extends StatefulWidget {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(title: Text('SETTINGS')),
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
    _settingCubit = SettingsCubit(RepositoryProvider.of<ApiRepository>(context))
      ..load();
    super.initState();
  }

  Widget _makeSetting(Category category, bool enabled) {
    if (category.key == 'general') {
      // The general category is always enabled (and can't be disabled)
      return SwitchListTile(
        value: true,
        onChanged: null,
        title: Text(category.name),
        subtitle:
            category.description.isNotEmpty ? Text(category.description) : null,
      );
    }
    return SwitchListTile(
      value: enabled,
      onChanged: (value) {
        _settingCubit.setSetting(category.key, value);
      },
      title: Text(category.name),
      subtitle:
          category.description.isNotEmpty ? Text(category.description) : null,
    );
  }

  Widget _makeNotificationSettings() {
    return BlocBuilder<SettingsCubit, SettingState>(
        bloc: _settingCubit,
        builder: (context, state) {
          if (state.hasException) {
            return RefreshIndicator(
              onRefresh: () async {
                var settingFuture = _settingCubit.load();
                await settingFuture;
              },
              child: Center(child: Text(state.message!)),
            );
          } else if (state.isLoading && state.categories == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Card(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ListTile.divideTiles(
                context: context,
                tiles: _settingCubit.state.categories!.map((category) =>
                    _makeSetting(
                        category,
                        _settingCubit.state.device!.receiveCategory
                            .contains(category.key))),
              ).toList(),
            ));
          }
        });
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
