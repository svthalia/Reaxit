import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/providers/settings_provider.dart';
import 'package:reaxit/ui/components/menu_drawer.dart';
import 'package:reaxit/models/setting.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  List<Setting> _settings;

  @override
  void didChangeDependencies() {
    _settings = Provider.of<SettingsProvider>(context).settingsList;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      drawer: MenuDrawer(),
      body: Container(
        child: _SettingsCard("Notifications", this._settings),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String _title;
  final List<Setting> _settings;

  _SettingsCard(this._title, this._settings);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Text(this._title),
        Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            color: Colors.grey,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: this._settings.map((s) => _SettingCard(s)).toList(),
          ),
        ),
      ]),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Setting _setting;

  _SettingCard(this._setting);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Column(
            children: [
              Row(
                children: [
                  Text(this._setting.name),
                  Text(this._setting.description),
                ]
              ),
            ]
          ),
          Text("Toggle"),
        ]
      )
    );
  }
}
