import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/setting_cubit.dart';
import 'package:reaxit/blocs/theme_bloc.dart';
import 'package:reaxit/models/push_notification_category.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';
import 'package:reaxit/config.dart' as config;
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
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
                  Text('THEME', style: textTheme.caption),
                  const _ThemeModeCard(),
                  const SizedBox(height: 8),
                  Text('NOTIFICATIONS', style: textTheme.caption),
                  Center(child: Text(state.message!)),
                  const SizedBox(height: 8),
                  Text('ABOUT', style: textTheme.caption),
                  const _AboutCard(),
                ],
              ),
            );
          } else if (state.isLoading && state.categories == null) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('THEME', style: textTheme.caption),
                const _ThemeModeCard(),
                const SizedBox(height: 8),
                Text('NOTIFICATIONS', style: textTheme.caption),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                const SizedBox(height: 8),
                Text('ABOUT', style: textTheme.caption),
                const _AboutCard(),
              ],
            );
          } else {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('THEME', style: textTheme.caption),
                const _ThemeModeCard(),
                const SizedBox(height: 8),
                Text('NOTIFICATIONS', style: textTheme.caption),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ListTile.divideTiles(
                      context: context,
                      tiles: [
                        for (final category in state.categories!)
                          _NotificationSettingTile(
                            category: category,
                            enabled: state.device!.receiveCategory.contains(
                              category.key,
                            ),
                          ),
                      ],
                    ).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Text('ABOUT', style: textTheme.caption),
                const _AboutCard(),
              ],
            );
          }
        },
      ),
    );
  }
}

class _NotificationSettingTile extends StatefulWidget {
  final PushNotificationCategory category;
  final bool enabled;

  _NotificationSettingTile({
    required this.category,
    required this.enabled,
  }) : super(key: ValueKey(category.key));

  @override
  __NotificationSettingTileState createState() =>
      __NotificationSettingTileState();
}

class __NotificationSettingTileState extends State<_NotificationSettingTile> {
  late bool enabled;
  @override
  void initState() {
    super.initState();
    enabled = widget.enabled;
  }

  @override
  void didUpdateWidget(covariant _NotificationSettingTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    enabled = widget.enabled;
  }

  @override
  Widget build(BuildContext context) {
    Widget? subtitle;
    if (widget.category.description.isNotEmpty) {
      subtitle = Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          widget.category.description,
          maxLines: 2,
        ),
      );
    }

    if (widget.category.key == 'general') {
      // The general category is always enabled and can't be disabled.
      return SwitchListTile(
        value: true,
        onChanged: null,
        title: Text(widget.category.name.toUpperCase()),
        subtitle: subtitle,
      );
    }
    return SwitchListTile(
      value: enabled,
      onChanged: (value) async {
        final oldValue = enabled;
        try {
          setState(() => enabled = value);
          await BlocProvider.of<SettingsCubit>(context).setSetting(
            widget.category.key,
            value,
          );
        } on ApiException {
          setState(() => enabled = oldValue);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not change your notification settings.'),
          ));
        }
      },
      title: Text(widget.category.name.toUpperCase()),
      subtitle: subtitle,
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
                      ? 'assets/img/logo-black.png'
                      : 'assets/img/logo-white.png',
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
            OutlinedButton.icon(
              onPressed: () async {
                await launch(
                  config.changelogUri.toString(),
                  forceSafariVC: false,
                  forceWebView: false,
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('CHANGELOG'),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                await launch(
                  config.feedbackUri.toString(),
                  forceSafariVC: false,
                  forceWebView: false,
                );
              },
              icon: const Icon(Icons.bug_report_outlined),
              label: const Text('FEEDBACK'),
            ),
            OutlinedButton.icon(
              onPressed: () => showLicensePage(
                context: context,
                applicationVersion: config.versionNumber,
                applicationIcon: Builder(builder: (context) {
                  return Image.asset(
                    Theme.of(context).brightness == Brightness.light
                        ? 'assets/img/logo-black.png'
                        : 'assets/img/logo-white.png',
                    width: 80,
                  );
                }),
              ),
              label: const Text('VIEW LICENSES'),
              icon: const Icon(Icons.info_outline),
            )
          ],
        ),
      ),
    );
  }
}
