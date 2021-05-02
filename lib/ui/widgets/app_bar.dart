import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/diagnostics.dart';

class ThaliaAppBar extends AppBar {
  ThaliaAppBar({
    Widget? title,
    List<Widget>? actions,
    Widget? leading,
    PreferredSizeWidget? bottom,
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
            preferredSize: bottom?.preferredSize ?? Size.fromHeight(0),
            child: Column(
              children: [
                Container(
                  height: 0,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE62272)),
                    ),
                  ),
                ),
                if (bottom != null) bottom,
              ],
            ),
          ),
        );
}

// class PreferredSizeWrapper extends PreferredSize {
//   PreferredSizeWrapper({required PreferredSizeWidget child})
//       : super(
//             preferredSize: child.preferredSize,
//             child: Column(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(color: Color(0xFFE62272)),
//                     ),
//                   ),
//                 ),
//               ],
//             ));
// }
