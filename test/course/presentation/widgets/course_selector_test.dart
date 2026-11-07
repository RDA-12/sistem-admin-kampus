import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/course.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late CourseSelectorController controller;
  late CoursesBloc coursesBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    coursesBlocMock = getIt<CoursesBloc>();
    whenListen(
      coursesBlocMock,
      Stream.value(CoursesLoaded(coursesUIMock)),
      initialState: CoursesLoaded(coursesUIMock),
    );

    controller = CourseSelectorController();
  });

  tearDown(() {
    reset(coursesBlocMock);
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    String? label,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return CourseSelector(
          label: label ?? 'Label',
          controller: controller,
        );
      },
      providerBuilder: (context, child) {
        return BlocProvider.value(
          value: coursesBlocMock,
          child: child,
        );
      },
    );
  }

  Future<void> openSelector(
    WidgetTester tester, {
    bool pumpOnly = false,
  }) async {
    await tester.tap(find.byType(AppFormField));
    if (pumpOnly) {
      await tester.pump();
    } else {
      await tester.pumpAndSettle();
    }
  }

  group('CourseSelectorController', () {
    test('sets itemAsString to (it) => it.name on initial', () {
      final ctrl = CourseSelectorController(initial: coursesMock.first);

      expect(ctrl.selected, coursesMock.first);
      expect(ctrl.textEditingController.text, coursesMock.first.name);
    });

    test('sets itemAsString to (it) => it.name when selected is changed', () {
      controller.selected = coursesMock.first;

      expect(controller.textEditingController.text, coursesMock.first.name);
    });
  });

  group('CourseSelector', () {
    group('Render', () {
      testWidgets('configures AppSelector correctly', (tester) async {
        await pumpWidget(tester, label: 'Custom Course');

        final appSelectorFinder = find.byType(AppSelector<Course>);
        expect(appSelectorFinder, findsOneWidget);

        final appSelector = tester.widget<AppSelector<Course>>(
          appSelectorFinder,
        );
        expect(appSelector.label, 'Custom Course');
        expect(appSelector.dialogTitle, 'Pilih Mata Kuliah');
        expect(appSelector.controller, controller);
      });

      testWidgets(
        'shows LoadingIndicator on dialog when state is loading',
        (tester) async {
          whenListen(
            coursesBlocMock,
            Stream.value(const LoadingCourses()),
            initialState: const LoadingCourses(),
          );
          await pumpWidget(tester);

          await openSelector(tester, pumpOnly: true);

          expect(find.byType(LoadingIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'shows AppExceptionBox on dialog when state is failed',
        (tester) async {
          whenListen(
            coursesBlocMock,
            Stream.value(CoursesFailure(AppException.test())),
            initialState: CoursesFailure(AppException.test()),
          );
          await pumpWidget(tester);

          await openSelector(tester);

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.exception, AppException.test());
        },
      );

      testWidgets(
        'ensures options showed to users is the name of Course',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          for (final c in coursesMock) {
            final finder = find.ancestor(
              of: find.text(c.name),
              matching: find.byType(CheckboxListTile),
            );
            await tester.ensureVisible(finder);
            expect(finder, findsOneWidget);
          }
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'triggers CoursesSubscriptionRequested when selector is pressed',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          verify(
            () => coursesBlocMock.add(
              const CoursesSubscriptionRequested(),
            ),
          ).called(1);
        },
      );
    });
  });
}
