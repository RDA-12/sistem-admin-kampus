import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late LecturersBloc lecturersBlocMock;

  group('LecturersList', () {
    final createButtonFinder = find.ancestor(
      of: find.text('Buat baru'),
      matching: find.byType(AppButton),
    );

    setUpAll(initializeMockDependencies);

    setUp(() {
      lecturersBlocMock = getIt<LecturersBloc>();
      whenListen(
        lecturersBlocMock,
        Stream.value(LecturersLoaded(lecturersUIMock)),
        initialState: LecturersLoaded(lecturersUIMock),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      void Function(Lecturer)? onPressed,
      void Function()? onCreatePressed,
      String? selectedId,
    }) {
      return tester.pumpWidgetForTest(
        (context) {
          return LecturersList(
            selectedId: selectedId,
            onPressed: onPressed,
            onCreatePressed: onCreatePressed,
          );
        },
        providerBuilder: (context, child) {
          return BlocProvider.value(
            value: lecturersBlocMock,
            child: child,
          );
        },
      );
    }

    tearDown(() {
      reset(lecturersBlocMock);
    });

    group('Render', () {
      testWidgets('shows all lecturers when state is loaded', (tester) async {
        await pumpWidget(tester);

        for (final lecturer in lecturersUIMock) {
          final lecturerFinder = find.ancestor(
            of: find.text(lecturer.name),
            matching: find.byType(LecturerListTile),
          );
          await tester.ensureVisible(lecturerFinder);
          await tester.pumpAndSettle();
        }
      });

      testWidgets('shows LoadingIndicator when state is loading/initial', (
        tester,
      ) async {
        final controller = StreamController<LecturersState>.broadcast();
        when(() => lecturersBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);
        controller.add(const LecturersInitial());
        await tester.pump();

        expect(find.byType(LoadingIndicator), findsOneWidget);

        controller.add(const LoadingLecturers());
        await tester.pump();

        expect(find.byType(LoadingIndicator), findsOneWidget);
      });

      testWidgets(
        'shows AppExceptionBox when state is failure',
        (tester) async {
          whenListen(
            lecturersBlocMock,
            Stream.value(LecturersFailure(AppException.test())),
            initialState: LecturersFailure(AppException.test()),
          );

          await pumpWidget(tester);
          await tester.pumpAndSettle();

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.exception, AppException.test());
          expect(widget.title, 'Gagal mengambil data dosen');
        },
      );

      testWidgets('shows create button', (tester) async {
        await pumpWidget(tester);

        expect(createButtonFinder, findsOneWidget);
      });

      testWidgets('shows selected LecturerListTile', (tester) async {
        await pumpWidget(tester, selectedId: lecturersUIMock.first.id);

        for (final lecturer in lecturersUIMock) {
          final finder = find.ancestor(
            of: find.text(lecturer.name),
            matching: find.byType(LecturerListTile),
          );
          await tester.ensureVisible(finder);
          final widget = tester.widget<LecturerListTile>(finder);
          expect(widget.selected, lecturer.id == lecturersUIMock.first.id);
        }
      });
    });

    group('Interactions', () {
      testWidgets(
        'calls onPressed with correct data '
        'when one of lecturers is pressed',
        (tester) async {
          Lecturer? pressedLecturer;
          await pumpWidget(
            tester,
            onPressed: (v) {
              pressedLecturer = v;
            },
          );

          final lecturerFinder = find.text(lecturersUIMock.first.name);
          await tester.ensureVisible(lecturerFinder);
          await tester.pumpAndSettle();
          await tester.tap(lecturerFinder);

          expect(pressedLecturer, lecturersUIMock.first);
        },
      );

      testWidgets(
        'calls onCreatePressed when create button is pressed',
        (tester) async {
          var pressed = false;
          await pumpWidget(
            tester,
            onCreatePressed: () {
              pressed = true;
            },
          );

          await tester.tap(createButtonFinder);

          expect(pressed, isTrue);
        },
      );
    });
  });
}
