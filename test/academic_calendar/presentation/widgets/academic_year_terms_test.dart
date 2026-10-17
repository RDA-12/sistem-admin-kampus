import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  final year = academicYearMock;
  final terms = academicTermsMock;

  Future<void> pumpWidget(
    WidgetTester tester, {
    List<AcademicTerm> terms = const [],
    void Function(AcademicTerm)? onTermPressed,
    void Function()? onAddTermPressed,
  }) {
    return tester.pumpWidgetForTest((context) {
      return AcademicYearTerms(
        academicYear: year,
        terms: terms,
        onTermPressed: onTermPressed,
        onAddTermPressed: onAddTermPressed,
      );
    });
  }

  group('AcademicYearTerms', () {
    group('Render', () {
      testWidgets('shows title and add button', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Daftar Semester'), findsOneWidget);
        expect(find.text('Tambah'), findsOneWidget);
      });

      testWidgets('shows empty text when terms is empty', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Belum ada semester'), findsOneWidget);
      });

      testWidgets('shows all terms when terms is not empty', (tester) async {
        await pumpWidget(tester, terms: terms);

        for (final term in terms) {
          expect(find.text(term.name), findsOneWidget);
        }
      });
    });

    group('Interactions', () {
      testWidgets('calls onAddTermPressed when add button is pressed', (
        tester,
      ) async {
        var addPressed = false;
        await pumpWidget(
          tester,
          onAddTermPressed: () {
            addPressed = true;
          },
        );

        final addButton = find.ancestor(
          of: find.text('Tambah'),
          matching: find.byType(AppButton),
        );

        await tester.tap(addButton);
        await tester.pumpAndSettle();

        expect(addPressed, isTrue);
      });

      testWidgets('calls onTermPressed when term is pressed', (tester) async {
        AcademicTerm? pressedTerm;
        await pumpWidget(
          tester,
          terms: terms,
          onTermPressed: (t) {
            pressedTerm = t;
          },
        );

        await tester.tap(find.text(terms.first.name));
        await tester.pumpAndSettle();

        expect(pressedTerm, equals(terms.first));
      });
    });
  });
}
