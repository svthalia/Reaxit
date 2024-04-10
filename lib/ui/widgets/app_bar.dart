import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reaxit/ui/theme.dart';

abstract class AppbarAction {
  Widget asIcon(BuildContext _);
  Widget asMenuItem(BuildContext context, Function() callback);

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
  Widget asMenuItem(BuildContext context, Function() callback) {
    return MenuItemButton(
      style: ButtonStyle(
          textStyle: MaterialStateTextStyle.resolveWith(
              (states) => Theme.of(context).textTheme.labelLarge!)),
      onPressed: () {
        onpressed();
        callback();
      },
      leadingIcon: Icon(icon),
      child: Text(text),
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
  final Function() callback;
  const _MenuAction(this.action, this.callback);

  @override
  Widget build(BuildContext context) => action.asMenuItem(context, callback);
}

class ThaliaAppBar extends AppBar {
  static const defaultIcons = 3;

  static List<Widget> collapse(List<AppbarAction> widgets) {
    if (widgets.length <= defaultIcons) {
      return widgets.map((e) => _IconAction(e)).toList();
    }

    MenuController controller = MenuController();
    return [
      ...widgets.take(defaultIcons - 1).map((item) => _IconAction(item)),
      MenuAnchor(
        alignmentOffset: const Offset(0, -1),
        controller: controller,
        menuChildren: widgets
            .skip(defaultIcons - 1)
            .map(
              (item) => _MenuAction(item, controller.close),
            )
            .toList(),
        child: IconButton(
          onPressed: controller.open,
          icon: const Icon(Icons.more_vert),
        ),
      )
    ];
  }

  ThaliaAppBar({
    super.title,
    List<AppbarAction> collapsingActions = const [],
    super.leading,
    PreferredSizeWidget? bottom,
  }) : super(
          actions: collapse(collapsingActions),
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
