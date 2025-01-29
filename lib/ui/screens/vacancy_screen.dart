// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
// import 'package:go_router/go_router.dart';
// import 'package:reaxit/api/api_repository.dart';
// import 'package:reaxit/blocs.dart';
// import 'package:reaxit/models.dart';
// import 'package:reaxit/models/vacancie.dart';
// import 'package:reaxit/routes.dart';
// import 'package:reaxit/ui/widgets.dart';
// import 'package:url_launcher/url_launcher.dart';

// class VacancyScreen extends StatelessWidget {
//   final Vacancie vacancy;

//   // By PK
//   final int? pk;

//   // Default: by PK
//   const VacancyScreen({
//     super.key,
//     required this.vacancy,
//     required this.pk,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // We don't use a cubit here, as it simplified the whole setup.
//     // No need to create a cubit for a single group
//     return Scrollbar(
//       child: Hero(
//         tag: 'vacancy:${vacancy.pk}',
//         child: Card(
//           child: Column(
//             children: [
//               Text(vacancy.title),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
