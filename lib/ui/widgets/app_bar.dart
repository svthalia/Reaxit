import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThaliaAppBar extends AppBar {
  ThaliaAppBar({
    Widget? title,
    List<Widget>? actions,
    Widget? leading,
  }) : super(
          title: title,
          actions: actions,
          leading: leading,
          centerTitle: true,
          brightness: Brightness.dark,
          // The bottom decoration only needs to be shown
          // in dark mode, but is invisible in light mode,
          // so we can just leave it there.
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE62272)),
                ),
              ),
            ),
          ),
        );
}
