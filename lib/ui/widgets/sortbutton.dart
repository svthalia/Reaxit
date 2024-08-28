import 'package:flutter/material.dart';

import 'app_bar.dart';

class SortItem<T> {
  final T value;
  final String text;
  final IconData? icon;

  const SortItem(this.value, this.text, this.icon);
}

class SortButton<T> extends StatelessWidget implements AppbarAction {
  final void Function(T?) callback;
  final List<SortItem<T>> items;

  const SortButton(this.items, this.callback);

  Widget _build(BuildContext context, bool issub) {
    MenuController controller = MenuController();

    // IconButton
    return MenuAnchor(
      alignmentOffset: const Offset(0, -1),
      controller: controller,
      menuChildren: items
          .map((item) => MenuItemButton(
                child: Row(
                  children: [
                    if (item.icon != null) Icon(item.icon!),
                    Text(item.text.toUpperCase()),
                  ],
                ),
                onPressed: () => callback(item.value),
              ))
          .toList(),
      child: issub
          ? MenuItemButton(
              closeOnActivate: false,
              style: ButtonStyle(
                  textStyle: WidgetStateTextStyle.resolveWith(
                      (states) => Theme.of(context).textTheme.labelLarge!)),
              onPressed: controller.open,
              leadingIcon: const Icon(Icons.sort),
              child: const Text('SORT'),
            )
          : IconButton(
              onPressed: controller.open, icon: const Icon(Icons.sort)),
    );
  }

  @override
  Widget build(BuildContext context) => asIcon(context);

  @override
  Widget asIcon(BuildContext context) => _build(context, false);

  @override
  Widget asMenuItem(BuildContext context, _) => _build(context, true);
}
