import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reaxit/ui/screens.dart';

void main() {
  group('Album', () {
    testWidgets('PageCounter', (WidgetTester tester) async {
      int? likedValue;

      final pageController = PageController(initialPage: 0);
      const pagecount = 5;
      final likedlist = [true, false, true, false, false];
      void onlike(int index) {
        likedValue = index;
      }

      final likecount = [1, 0, -1, 0, 0];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageCounter(
              controler: pageController,
              pagecount: pagecount,
              isliked: likedlist,
              likeToggle: onlike,
              likecount: likecount,
            ),
          ),
        ),
      );

      expect(find.text('0 / 5'), findsOneWidget);
      pageController.jumpToPage(1);
      await tester.pumpAndSettle();
      expect(find.text('1 / 5'), findsOneWidget);
      await tester.tap(find.byTooltip('like photo'));
      expect(likedValue, 1);
      likedValue = null;
    });
  });
}
