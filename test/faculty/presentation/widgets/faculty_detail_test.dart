import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../program/domain/mocks.dart';
import '../../../room/domain/mocks.dart';
import '../../domain/mocks.dart';

void main() {
  late FacultyDetailBloc facultyDetailBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    facultyDetailBlocMock = getIt<FacultyDetailBloc>();
    whenListen(
      facultyDetailBlocMock,
      Stream.value(
        FacultyDetailLoaded(
          faculty: facultyMock,
          programs: programsMock,
          rooms: roomsMock,
        ),
      ),
      initialState: FacultyDetailLoaded(
        faculty: facultyMock,
        programs: programsMock,
        rooms: roomsMock,
      ),
    );

    whenListen(
      getIt<FacultyMutationBloc>(),
      Stream.value(const FacultyMutationState()),
      initialState: const FacultyMutationState(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onRetryPressed,
    void Function(Faculty)? onFacultyDeleted,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return FacultyDetail(
          onRetryPressed: onRetryPressed,
          onFacultyDeleted: onFacultyDeleted,
        );
      },
      providerBuilder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: facultyDetailBlocMock,
            ),
            BlocProvider.value(
              value: getIt<FacultyMutationBloc>(),
            ),
          ],
          child: child,
        );
      },
    );
  }

  group('FacultyDetail', () {
    group('Render', () {
      testWidgets(
        'shows FacultyForm with correct faculty '
        'when state is loaded',
        (tester) async {
          await pumpWidget(tester);

          final finder = find.byType(FacultyForm);
          expect(finder, findsOneWidget);
          final widget = tester.widget<FacultyForm>(finder);
          expect(widget.initial, facultyMock);
        },
      );

      testWidgets(
        'shows FacultyPrograms with correct programs '
        'when state is loaded',
        (tester) async {
          await pumpWidget(tester);

          expect(find.text('Daftar Program Studi'), findsOneWidget);
          final finder = find.byType(FacultyPrograms);
          expect(finder, findsOneWidget);
          final widget = tester.widget<FacultyPrograms>(finder);
          expect(widget.programs, programsMock);
        },
      );

      testWidgets(
        'shows FacultyRooms with correct rooms '
        'when state is loaded',
        (tester) async {
          await pumpWidget(tester);

          await tester.drag(
            find.byType(FacultyDetail),
            const Offset(0, -500),
          );
          await tester.pumpAndSettle();

          expect(find.text('Daftar Ruangan'), findsOneWidget);
          final finder = find.byType(FacultyRooms);
          expect(finder, findsOneWidget);
          final widget = tester.widget<FacultyRooms>(finder);
          expect(widget.rooms, roomsMock);
        },
      );

      testWidgets(
        'shows LoadingIndicator when state is loading',
        (tester) async {
          whenListen(
            facultyDetailBlocMock,
            Stream.value(const LoadingFacultyDetail()),
            initialState: const LoadingFacultyDetail(),
          );

          await pumpWidget(tester);

          expect(find.byType(LoadingIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'shows AppExceptionBox when state is failed',
        (tester) async {
          whenListen(
            facultyDetailBlocMock,
            Stream.value(
              FacultyDetailLoadFailed(exception: AppException.test()),
            ),
            initialState: FacultyDetailLoadFailed(
              exception: AppException.test(),
            ),
          );

          await pumpWidget(tester);

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.title, 'Gagal mengambil data fakultas');
          expect(widget.exception, AppException.test());
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'calls onRetryPressed when state is failed '
        'and retry button is pressed',
        (tester) async {
          whenListen(
            facultyDetailBlocMock,
            Stream.value(
              FacultyDetailLoadFailed(exception: AppException.test()),
            ),
            initialState: FacultyDetailLoadFailed(
              exception: AppException.test(),
            ),
          );
          var pressed = false;
          await pumpWidget(
            tester,
            onRetryPressed: () {
              pressed = true;
            },
          );

          await tester.tap(
            find.descendant(
              of: find.byType(AppExceptionBox),
              matching: find.byType(AppButton),
            ),
          );

          expect(pressed, isTrue);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'calls onFacultyDeleted '
        'when FacultyDetail fires onFacultyDeleted callback',
        (tester) async {
          Faculty? deleted;

          await pumpWidget(
            tester,
            onFacultyDeleted: (v) {
              deleted = v;
            },
          );

          final finder = find.byType(FacultyForm);
          expect(finder, findsOneWidget);
          final widget = tester.widget<FacultyForm>(finder);
          widget.onFacultyDeleted!(facultyMock);

          expect(deleted, facultyMock);
        },
      );
    });
  });
}
