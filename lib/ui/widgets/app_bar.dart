import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reaxit/ui/theme.dart';

abstract class AppbarAction {
  Widget asIcon(BuildContext _);
  Widget asMenuItem(BuildContext _);

  const AppbarAction();
}

class IconAppbarAction extends AppbarAction {
  final String text;
  final String tooltip;
  final IconData icon;
  final void Function() onpressed;

  const IconAppbarAction(this.text, this.icon, this.onpressed,
      {String? tooltip})
      : tooltip = tooltip ?? text;

  @override
  Widget asIcon(BuildContext _) {
    return IconButton(
      padding: const EdgeInsets.all(16),
      onPressed: onpressed,
      icon: Icon(icon),
      tooltip: tooltip,
    );
  }

  @override
  Widget asMenuItem(BuildContext _) {
    return TextButton.icon(
      style: ButtonStyle(foregroundColor: MaterialStateColor.resolveWith((states) => Colors.white)),
      onPressed: onpressed,
      label: Text(text),
      icon: Icon(icon),
    );
  }
}

class _IconAction extends StatelessWidget {
  final AppbarAction action;

  const _IconAction(this.action);

  @override
  Widget build(BuildContext context) => action.asIcon(context);
}

class _MenuAction extends StatelessWidget {
  final AppbarAction action;

  const _MenuAction(this.action);

  @override
  Widget build(BuildContext context) => action.asMenuItem(context);
}

class ThaliaAppBar extends AppBar {
  static const defaultIcons = 3;
  static List<Widget> collapse(List<AppbarAction> widgets) {
    if (widgets.length <= defaultIcons) {
      return widgets.map((e) => _IconAction(e)).toList();
    }

    return [
      ...widgets.take(defaultIcons-1).map((item) => _IconAction(item)),
      PopupMenuButton(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        itemBuilder: (BuildContext context) {
          return widgets
              .skip(defaultIcons-1)
              .map((item) => PopupMenuItem(child: _MenuAction(item)))
              .toList();
        },
      ),
    ];
  }

  ThaliaAppBar({
    Widget? title,
    List<AppbarAction> collapsingActions = const [],
    Widget? leading,
    PreferredSizeWidget? bottom,
  }) : super(
          title: title,
          actions: collapse(collapsingActions),
          leading: leading,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          // The bottom decoration only needs to be shown
          // in dark mode, but is invisible in light mode,
          // so we can just leave it there.
          bottom: bottom ??
              PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: magenta),
                    ),
                  ),
                ),
              ),
        );
}
