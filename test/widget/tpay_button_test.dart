import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets.dart';

import '../mocks.mocks.dart';

void main() {
//   group('TPayButton', () {
//     testWidgets('can be used to pay', (WidgetTester tester) async {
//       final payCompleter = Completer<void>();

//       final paymentUserCubit = MockPaymentUserCubit();
//       final streamController = StreamController<PaymentUserState>.broadcast()
//         ..stream.listen((state) {
//           when(paymentUserCubit.state).thenReturn(state);
//         })
//         ..add(const LoadingState())
//         ..add(const ResultState(
//           PaymentUser('0.00', true, true),
//         ));

//       when(paymentUserCubit.load()).thenAnswer((_) => Future.value(null));
//       when(paymentUserCubit.stream).thenAnswer((_) => streamController.stream);

//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: BlocProvider<PaymentUserCubit>.value(
//               value: paymentUserCubit,
//               child: TPayButton(
//                 amount: '13.37',
//                 successMessage: 'Nice!',
//                 confirmationMessage: 'Are you sure?',
//                 failureMessage: ':(',
//                 onPay: () async => payCompleter.complete(),
//               ),
//             ),
//           ),
//         ),
//       );

//       expect(payCompleter.isCompleted, false);
//       expect(find.text('THALIA PAY: €13.37'), findsOneWidget);

//       await tester.tap(find.text('THALIA PAY: €13.37'));
//       await tester.pumpAndSettle();

//       expect(payCompleter.isCompleted, false);
//       expect(find.text('Are you sure?'), findsOneWidget);
//       expect(find.text('YES'), findsOneWidget);

//       await tester.tap(find.text('YES'));
//       await tester.pumpAndSettle();

//       expect(payCompleter.isCompleted, true);
//       expect(find.text('Nice!'), findsOneWidget);
//       expect(find.text('Are you sure?'), findsNothing);
//     });

//     testWidgets('can be cancelled', (WidgetTester tester) async {
//       final payCompleter = Completer<void>();

//       final paymentUserCubit = MockPaymentUserCubit();
//       final streamController = StreamController<PaymentUserState>.broadcast()
//         ..stream.listen((state) {
//           when(paymentUserCubit.state).thenReturn(state);
//         })
//         ..add(const LoadingState())
//         ..add(const ResultState(
//           PaymentUser('0.00', true, true),
//         ));

//       when(paymentUserCubit.load()).thenAnswer((_) => Future.value(null));
//       when(paymentUserCubit.stream).thenAnswer((_) => streamController.stream);

//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: BlocProvider<PaymentUserCubit>.value(
//               value: paymentUserCubit,
//               child: TPayButton(
//                 amount: '13.37',
//                 successMessage: 'Nice!',
//                 confirmationMessage: 'Are you sure?',
//                 failureMessage: ':(',
//                 onPay: () async => payCompleter.complete(),
//               ),
//             ),
//           ),
//         ),
//       );

//       expect(payCompleter.isCompleted, false);
//       expect(find.text('THALIA PAY: €13.37'), findsOneWidget);

//       await tester.tap(find.text('THALIA PAY: €13.37'));
//       await tester.pumpAndSettle();

//       expect(payCompleter.isCompleted, false);
//       expect(find.text('Are you sure?'), findsOneWidget);
//       expect(find.text('CANCEL'), findsOneWidget);

//       await tester.tap(find.text('CANCEL'));
//       await tester.pumpAndSettle();
//       expect(payCompleter.isCompleted, false);
//       expect(find.text('Nice!'), findsNothing);
//       expect(find.text('Are you sure?'), findsNothing);
//     });

//     testWidgets('displays snackbar on exception', (WidgetTester tester) async {
//       final paymentUserCubit = MockPaymentUserCubit();
//       final streamController = StreamController<PaymentUserState>.broadcast()
//         ..stream.listen((state) {
//           when(paymentUserCubit.state).thenReturn(state);
//         })
//         ..add(const LoadingState())
//         ..add(const ResultState(
//           PaymentUser('0.00', true, true),
//         ));

//       when(paymentUserCubit.load()).thenAnswer((_) => Future.value(null));
//       when(paymentUserCubit.stream).thenAnswer((_) => streamController.stream);

//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: BlocProvider<PaymentUserCubit>.value(
//               value: paymentUserCubit,
//               child: TPayButton(
//                 amount: '13.37',
//                 successMessage: 'Nice!',
//                 confirmationMessage: 'Are you sure?',
//                 failureMessage: ':(',
//                 onPay: () async {
//                   throw ApiException.unknownError;
//                 },
//               ),
//             ),
//           ),
//         ),
//       );

//       await tester.tap(find.text('THALIA PAY: €13.37'));
//       await tester.pumpAndSettle();
//       await tester.tap(find.text('YES'));
//       await tester.pumpAndSettle();

//       expect(find.text(':('), findsOneWidget);
//     });

//     testWidgets('provides tooltips when disabled', (WidgetTester tester) async {
//       final paymentUserCubit = MockPaymentUserCubit();
//       final streamController = StreamController<PaymentUserState>.broadcast()
//         ..stream.listen((state) {
//           when(paymentUserCubit.state).thenReturn(state);
//         })
//         ..add(const LoadingState())
//         ..add(const ResultState(
//           PaymentUser('0.00', false, false),
//         ));

//       when(paymentUserCubit.load()).thenAnswer((_) => Future.value(null));
//       when(paymentUserCubit.stream).thenAnswer((_) => streamController.stream);

//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: BlocProvider<PaymentUserCubit>.value(
//               value: paymentUserCubit,
//               child: TPayButton(
//                 amount: '13.37',
//                 successMessage: 'Nice!',
//                 confirmationMessage: 'Are you sure?',
//                 failureMessage: ':(',
//                 onPay: () async {
//                   throw ApiException.unknownError;
//                 },
//               ),
//             ),
//           ),
//         ),
//       );

//       await tester.tap(find.text('THALIA PAY: €13.37'));
//       await tester.pumpAndSettle();
//       expect(find.text('Confirm payment'), findsNothing);
//       expect(
//         find.byTooltip('You are not allowed to use Thalia Pay.'),
//         findsOneWidget,
//       );

//       streamController.add(const ResultState(
//         PaymentUser('0.00', true, false),
//       ));
//       await tester.pumpAndSettle();

//       await tester.tap(find.text('THALIA PAY: €13.37'));
//       await tester.pumpAndSettle();
//       expect(find.text('Confirm payment'), findsNothing);
//       await tester.longPress(find.textContaining('THALIA PAY'));
//       await tester.pumpAndSettle();
//       expect(find.textContaining('direct debit mandate'), findsOneWidget);

//       streamController.add(const LoadingState());
//       await tester.pumpAndSettle();
//       await tester.tap(find.text('THALIA PAY: €13.37'));
//       await tester.pumpAndSettle();
//       expect(find.text('Confirm payment'), findsNothing);

//       streamController.add(const ErrorState('An unknown error occurred.'));
//       await tester.pumpAndSettle();
//       await tester.tap(find.text('THALIA PAY: €13.37'));
//       await tester.pumpAndSettle();
//       expect(find.text('Confirm payment'), findsNothing);
//     });
//   });
}
