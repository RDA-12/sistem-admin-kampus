import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late FacultyDetailBloc facultyDetailBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    facultyDetailBlocMock = getIt<FacultyDetailBloc>();
    whenListen(
      facultyDetailBlocMock,
      Stream.value(const FacultyDetailLoaded(faculty: facultyMock)),
      initialState: const FacultyDetailLoaded(faculty: facultyMock),
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
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return FacultyDetail(
          onRetryPressed: onRetryPressed,
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
  });
}
