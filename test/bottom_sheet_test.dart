// Copyright (c) 2019-present,  SurfStudio LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:ui';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:bottom_sheet/src/widgets/flexible_bottom_sheet_scroll_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surf_lint_rules/surf_lint_rules.dart';

import 'test_utils.dart';

void main() {
  const listViewKey = Key('ListView');

  late BuildContext savedContext;

  final app = MaterialApp(
    home: Builder(
      builder: (context) {
        savedContext = context;
        return const Scaffold();
      },
    ),
  );

  Future<void> showBottomSheet({
    bool? isCollapsible,
    bool? isDismissible,
    double? minHeight,
    double? initHeight,
    double? maxHeight,
    List<double>? anchors,
  }) {
    return showFlexibleBottomSheet<void>(
      minHeight: minHeight ?? 0,
      initHeight: initHeight ?? 0.5,
      maxHeight: maxHeight ?? 0.8,
      context: savedContext,
      isCollapsible: isCollapsible ?? true,
      isDismissible: isDismissible ?? true,
      builder: (context, controller, offset) {
        return ListView(
          key: listViewKey,
          controller: controller,
          children: _listWidgets,
        );
      },
      anchors: anchors ?? [0, 0.5, 0.8],
    );
  }

  double getFractionalHeight(WidgetTester tester) {
    final screenHeight = tester.getSize(find.byType(MaterialApp)).height;
    final headOffset = tester.getTopLeft(find.byKey(listViewKey));

    return (screenHeight - headOffset.dy) / screenHeight;
  }

  group(
    'FlexibleBottomSheet',
    () {
      testWidgets(
        'FlexibleBottomSheet builds normally and contains all the necessary widgets',
        (tester) async {
          await tester.pumpWidget(
            makeTestableWidget(
              FlexibleBottomSheet(),
            ),
          );

          expect(() => FlexibleBottomSheet, returnsNormally);

          final flexibleScrollNotifier = find.byType(FlexibleScrollNotifier);
          expect(flexibleScrollNotifier, findsOneWidget);

          final flexibleDraggableScrollableSheet =
              find.byType(FlexibleDraggableScrollableSheet);
          expect(flexibleDraggableScrollableSheet, findsOneWidget);
        },
      );

      testWidgets('Tap on the BottomSheet should not close it', (tester) async {
        await tester.pumpWidget(app);

        unawaited(showBottomSheet());

        await tester.pumpAndSettle();
        expect(find.byType(FlexibleBottomSheet), findsOneWidget);

        await tester.tap(find.byType(FlexibleBottomSheet));
        await tester.pumpAndSettle();
        expect(find.byType(FlexibleBottomSheet), findsOneWidget);
      });

      testWidgets(
        'Tap above BottomSheet should have correct behaviour',
        (tester) async {
          await tester.pumpWidget(app);

          unawaited(showBottomSheet(
            isDismissible: defaultBoolTestVariant.currentValue,
          ));

          await tester.pumpAndSettle();
          expect(find.byType(FlexibleBottomSheet), findsOneWidget);

          await tester.tapAt(const Offset(20.0, 20.0));
          await tester.pumpAndSettle();
          expect(
            find.byType(FlexibleBottomSheet),
            defaultBoolTestVariant.currentValue!
                ? findsNothing
                : findsOneWidget,
          );
        },
        variant: defaultBoolTestVariant,
      );

      testWidgets(
        'Swipe down should have behaviour by isCollapsible property',
        (tester) async {
          await tester.pumpWidget(app);

          unawaited(showBottomSheet(
            isCollapsible: defaultBoolTestVariant.currentValue,
          ));
          await tester.pumpAndSettle();

          expect(find.byType(FlexibleBottomSheet), findsOneWidget);

          await tester.drag(
            find.byType(
              FlexibleBottomSheet,
              skipOffstage: false,
            ),
            const Offset(0.0, 300.0),
          );
          await tester.pumpAndSettle();

          expect(
            find.byType(FlexibleBottomSheet),
            defaultBoolTestVariant.currentValue!
                ? findsNothing
                : findsOneWidget,
          );
        },
        variant: defaultBoolTestVariant,
      );

      testWidgets(
        'Scroll more than available space should make bottom sheet max height',
        (tester) async {
          await tester.pumpWidget(app);

          unawaited(showBottomSheet(isCollapsible: false));
          await tester.pumpAndSettle();

          expect(find.byType(FlexibleBottomSheet), findsOneWidget);

          await tester.drag(
            find.byType(FlexibleBottomSheet),
            const Offset(0, -800),
          );

          await tester.pumpAndSettle();

          final fractionalHeight = getFractionalHeight(tester);

          expect(fractionalHeight, moreOrLessEquals(0.8));
        },
      );

      group('Anchors', () {
        testWidgets(
          'Anchors must be correct',
          (tester) async {
            await tester.pumpWidget(app);

            unawaited(showBottomSheet(
              maxHeight: _anchorsTestVariants.currentValue!.maxHeight,
              minHeight: _anchorsTestVariants.currentValue!.minHeight,
              anchors: _anchorsTestVariants.currentValue!.anchors,
              isCollapsible: _anchorsTestVariants.currentValue!.isCollapsible,
            ));
            await tester.pumpAndSettle();

            expect(
              tester.takeException(),
              _anchorsTestVariants.currentValue!.matcher,
            );
          },
          variant: _anchorsTestVariants,
        );

        testWidgets(
          'Drag bottom sheet with anchors should have correct behaviour',
          (tester) async {
            final offset = _dragAnchorsVariants.currentValue!.offset;
            final expectedResult =
                _dragAnchorsVariants.currentValue!.expectedResult;

            await tester.pumpWidget(app);

            unawaited(showBottomSheet(anchors: [0.2, 0.5, 0.8]));
            await tester.pumpAndSettle();

            expect(find.byKey(listViewKey), findsOneWidget);

            await tester.drag(
              find.byType(
                FlexibleBottomSheet,
              ),
              offset,
            );
            await tester.pumpAndSettle();

            expect(find.byType(FlexibleBottomSheet), findsOneWidget);

            final fractionalHeight = getFractionalHeight(tester);

            expect(fractionalHeight, moreOrLessEquals(expectedResult));
          },
          variant: _dragAnchorsVariants,
        );

        testWidgets(
          'Drag bottom sheet from the last anchor down should close it',
          (tester) async {
            await tester.pumpWidget(app);

            unawaited(showBottomSheet(
              anchors: [0.2, 0.5, 0.8],
            ));

            await tester.pumpAndSettle();

            expect(find.byKey(listViewKey), findsOneWidget);

            await tester.drag(
              find.byKey(listViewKey),
              const Offset(0, 38),
            );
            await tester.pumpAndSettle();

            expect(find.byKey(listViewKey), findsOneWidget);

            final fractionalHeight = getFractionalHeight(tester);

            expect(fractionalHeight, moreOrLessEquals(0.2));

            await tester.drag(
              find.byKey(listViewKey),
              const Offset(0, 40),
            );

            await tester.pumpAndSettle();

            expect(find.byKey(listViewKey), findsNothing);
          },
        );
      });
    },
  );
}

class _DragAnchorTestScenario {
  final Offset offset;
  final double expectedResult;

  _DragAnchorTestScenario(
    this.offset,
    this.expectedResult,
  );
}

final ValueVariant<_DragAnchorTestScenario> _dragAnchorsVariants =
    ValueVariant<_DragAnchorTestScenario>(
  {
    // When scrolling down 35, the bottom sheet should be 0.5.
    _DragAnchorTestScenario(const Offset(0, 35), 0.5),
    // When scrolling down 38, the bottom sheet should be 0.2.
    _DragAnchorTestScenario(const Offset(0, 38), 0.2),
    // When scrolling down -35, the bottom sheet should be 0.5.
    _DragAnchorTestScenario(const Offset(0, -35), 0.5),
    // When scrolling down -38, the bottom sheet should be 0.8.
    _DragAnchorTestScenario(const Offset(0, -38), 0.8),
  },
);

final _listWidgets = [
  Container(
    height: 200,
    width: double.infinity,
    color: Colors.red,
  ),
  Container(
    height: 200,
    width: double.infinity,
    color: Colors.black,
  ),
  Container(
    height: 200,
    width: double.infinity,
    color: Colors.green,
  ),
  Container(
    height: 200,
    width: double.infinity,
    color: Colors.blue,
  ),
];

class _AnchorsTestScenario {
  final List<double> anchors;
  final double maxHeight;
  final double? minHeight;
  final bool isCollapsible;
  final Matcher matcher;

  _AnchorsTestScenario({
    required this.anchors,
    required this.maxHeight,
    required this.matcher,
    this.minHeight,
    this.isCollapsible = true,
  });
}

final ValueVariant<_AnchorsTestScenario> _anchorsTestVariants =
    ValueVariant<_AnchorsTestScenario>(
  {
    _AnchorsTestScenario(
      anchors: [0.2, 0.5, 1],
      maxHeight: 1,
      matcher: isNull,
    ),
    _AnchorsTestScenario(
      anchors: [0.2, 0.5, 1],
      maxHeight: 0.8,
      matcher: isInstanceOf<AssertionError>(),
    ),
    _AnchorsTestScenario(
      anchors: [0.2, 0.5, 1],
      maxHeight: 1,
      minHeight: 0.3,
      isCollapsible: false,
      matcher: isInstanceOf<AssertionError>(),
    ),
  },
);
