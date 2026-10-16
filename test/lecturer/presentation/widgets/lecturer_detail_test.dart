import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../program/domain/mocks.dart';
import '../../domain/mocks.dart';

void main() {
  late LecturerDetailBloc lecturerDetailBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    lecturerDetailBlocMock = getIt<LecturerDetailBloc>();
    whenListen(
      lecturerDetailBlocMock,
      Stream.value(LecturerDetailLoaded(lecturer: lecturerUIMock)),
      initialState: LecturerDetailLoaded(lecturer: lecturerUIMock),
    );

    whenListen(
      getIt<LecturerMutationBloc>(),
      Stream.value(const LecturerMutationState()),
      initialState: const LecturerMutationState(),
    );

    whenListen(
      getIt<ProgramsBloc>(),
      Stream.value(ProgramsLoaded(programsUIMock)),
      initialState: ProgramsLoaded(programsUIMock),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onRetryPressed,
    void Function(Lecturer)? onLecturerDeleted,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return LecturerDetail(
          onRetryPressed: onRetryPressed,
          onLecturerDeleted: onLecturerDeleted,
        );
      },
      providerBuilder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: lecturerDetailBlocMock,
            ),
            BlocProvider.value(
              value: getIt<LecturerMutationBloc>(),
            ),
            BlocProvider.value(
              value: getIt<ProgramsBloc>(),
            ),
          ],
          child: child,
        );
      },
    );
  }

  group('LecturerDetail', () {
    group('Render', () {
      testWidgets(
        'shows LecturerForm with correct lecturer when state is loaded',
        (tester) async {
          await pumpWidget(tester);

          final finder = find.byType(LecturerForm);
          expect(finder, findsOneWidget);
          final widget = tester.widget<LecturerForm>(finder);
          expect(widget.initial, lecturerUIMock);
        },
      );

      testWidgets(
        'shows LoadingIndicator when state is loading',
        (tester) async {
          whenListen(
            lecturerDetailBlocMock,
            Stream.value(const LoadingLecturerDetail()),
            initialState: const LoadingLecturerDetail(),
          );

          await pumpWidget(tester);

          expect(find.byType(LoadingIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'shows AppExceptionBox when state is failed',
        (tester) async {
          whenListen(
            lecturerDetailBlocMock,
            Stream.value(
              LecturerDetailLoadFailed(exception: AppException.test()),
            ),
            initialState: LecturerDetailLoadFailed(
              exception: AppException.test(),
            ),
          );

          await pumpWidget(tester);

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.title, 'Gagal mengambil data dosen');
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
            lecturerDetailBlocMock,
            Stream.value(
              LecturerDetailLoadFailed(exception: AppException.test()),
            ),
            initialState: LecturerDetailLoadFailed(
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
        'calls onLecturerDeleted '
        'when LecturerDetail fires onLecturerDeleted callback',
        (tester) async {
          Lecturer? deleted;

          await pumpWidget(
            tester,
            onLecturerDeleted: (v) {
              deleted = v;
            },
          );

          final finder = find.byType(LecturerForm);
          expect(finder, findsOneWidget);
          final widget = tester.widget<LecturerForm>(finder);
          widget.onLecturerDeleted!(lecturerUIMock);

          expect(deleted, lecturerUIMock);
        },
      );
    });
  });
}
