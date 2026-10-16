import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../faculty/domain/mocks.dart';
import '../../domain/mocks.dart';

void main() {
  final room = roomUIMock;
  late RoomMutationBloc roomMutationBlocMock;
  late FacultiesBloc facultiesBlocMock;

  group('RoomForm', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      roomMutationBlocMock = getIt<RoomMutationBloc>();
      whenListen(
        roomMutationBlocMock,
        Stream.value(const RoomMutationState()),
        initialState: const RoomMutationState(),
      );

      facultiesBlocMock = getIt<FacultiesBloc>();
      whenListen(
        facultiesBlocMock,
        Stream.value(FacultiesLoaded(facultiesMock)),
        initialState: FacultiesLoaded(facultiesMock),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      RoomUI? initial,
      void Function(Room)? onRoomDeleted,
    }) {
      return tester.pumpWidgetForTest(
        (context) => RoomForm(
          initial: initial,
          onRoomDeleted: onRoomDeleted,
        ),
        providerBuilder: (context, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: roomMutationBlocMock,
              ),
              BlocProvider.value(
                value: facultiesBlocMock,
              ),
            ],
            child: child,
          );
        },
      );
    }

    final facultySelectorFinder = find.ancestor(
      of: find.text('Fakultas *'),
      matching: find.byType(FacultySelector),
    );
    Future<void> selectFaculty(WidgetTester tester) async {
      await tester.tap(facultySelectorFinder);
      await tester.pumpAndSettle();
      final firstFinder = find.ancestor(
        of: find.text(facultiesMock.first.name),
        matching: find.byType(CheckboxListTile),
      );
      await tester.ensureVisible(firstFinder);
      await tester.tap(firstFinder);
      await tester.pumpAndSettle();
    }

    final nameFieldFinder = find.ancestor(
      of: find.text('Nama Ruangan *'),
      matching: find.byType(TextFormField),
    );
    final saveButtonFinder = find.ancestor(
      of: find.text('Simpan'),
      matching: find.byType(AppButton),
    );
    final deleteButtonFinder = find.ancestor(
      of: find.text('Hapus'),
      matching: find.byType(AppButton),
    );

    group('Render', () {
      testWidgets('shows Fakultas selector and name fields', (tester) async {
        await pumpWidget(tester);

        expect(facultySelectorFinder, findsOneWidget);
        expect(nameFieldFinder, findsOneWidget);
      });

      testWidgets('shows save button', (tester) async {
        await pumpWidget(tester);

        expect(saveButtonFinder, findsOneWidget);
      });

      testWidgets(
        'shows LoadingIndicator and disable save button when '
        'RoomMutationState isCreating true',
        (tester) async {
          whenListen(
            roomMutationBlocMock,
            Stream.value(const RoomMutationState(isCreating: true)),
          );

          await pumpWidget(tester);
          await tester.pump();

          expect(
            find.descendant(
              of: saveButtonFinder,
              matching: find.byType(LoadingIndicator),
            ),
            findsOneWidget,
          );
          expect(
            tester.widget<AppButton>(saveButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'shows LoadingIndicator on save button and disable it '
        'when RoomMutationState updatingIds contains initial room',
        (tester) async {
          whenListen(
            roomMutationBlocMock,
            Stream.value(RoomMutationState(updatingIds: {room.id})),
          );

          await pumpWidget(tester, initial: room);
          await tester.pump();

          expect(
            find.descendant(
              of: saveButtonFinder,
              matching: find.byType(LoadingIndicator),
            ),
            findsOneWidget,
          );
          expect(tester.widget<AppButton>(saveButtonFinder).onPressed, isNull);
        },
      );

      testWidgets(
        'disable delete button '
        'when RoomMutationState updatingIds contains initial room',
        (tester) async {
          whenListen(
            roomMutationBlocMock,
            Stream.value(RoomMutationState(deletingIds: {room.id})),
          );

          await pumpWidget(tester, initial: room);
          await tester.pump();

          expect(
            tester.widget<AppButton>(deleteButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'disable save button '
        'when RoomMutationState deletingIds contains initial room',
        (tester) async {
          whenListen(
            roomMutationBlocMock,
            Stream.value(RoomMutationState(deletingIds: {room.id})),
          );

          await pumpWidget(tester, initial: room);
          await tester.pump();

          expect(
            tester.widget<AppButton>(saveButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'shows LoadingIndicator on delete button and disable it '
        'when RoomMutationState deletingIds contains initial room',
        (tester) async {
          whenListen(
            roomMutationBlocMock,
            Stream.value(RoomMutationState(deletingIds: {room.id})),
          );

          await pumpWidget(tester, initial: room);
          await tester.pump();

          expect(
            find.descendant(
              of: deleteButtonFinder,
              matching: find.byType(LoadingIndicator),
            ),
            findsOneWidget,
          );
          expect(
            tester.widget<AppButton>(deleteButtonFinder).onPressed,
            isNull,
          );
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'add RoomMutationCreateRequested when initial is null '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester);

          await selectFaculty(tester);
          await tester.enterText(nameFieldFinder, 'Lab Komputer 1');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => roomMutationBlocMock.add(
              RoomMutationCreateRequested(
                facultyId: facultiesMock.first.id,
                name: 'Lab Komputer 1',
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'add RoomMutationUpdateRequested when initial is provided '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester, initial: room);

          await tester.enterText(nameFieldFinder, 'Lab Komputer 2');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => roomMutationBlocMock.add(
              RoomMutationUpdateRequested(
                room: room,
                name: 'Lab Komputer 2',
                facultyId: room.facultyId,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'add RoomMutationDeleteRequested when delete button pressed',
        (tester) async {
          await pumpWidget(tester, initial: room);

          await tester.tap(deleteButtonFinder);
          await tester.pumpAndSettle();
          // Confirm on dialog
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();

          verify(
            () => roomMutationBlocMock.add(
              RoomMutationDeleteRequested(
                room: room,
              ),
            ),
          ).called(1);
        },
      );
    });

    group('Side Effects', () {
      testWidgets('not clear name and selector field when update success', (
        tester,
      ) async {
        final controller = StreamController<RoomMutationState>.broadcast();
        when(() => roomMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester, initial: room);

        await selectFaculty(tester);
        await tester.enterText(nameFieldFinder, 'text');
        await tester.pumpAndSettle();

        expect(find.text(facultiesMock.first.name), findsOneWidget);
        expect(find.text('text'), findsOneWidget);

        controller.add(
          RoomMutationState(
            notice: RoomUpdatedNotice(before: room, after: room),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(facultiesMock.first.name), findsOneWidget);
        expect(find.text('text'), findsOneWidget);
      });

      testWidgets('clear all fields when create success', (tester) async {
        final controller = StreamController<RoomMutationState>.broadcast();
        when(() => roomMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);

        await selectFaculty(tester);
        await tester.enterText(nameFieldFinder, 'Lab Komputer 1');
        await tester.pumpAndSettle();

        expect(find.text(facultiesMock.first.name), findsOneWidget);
        expect(find.text('Lab Komputer 1'), findsOneWidget);

        controller.add(
          RoomMutationState(
            notice: RoomCreatedNotice(room),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(facultiesMock.first.name), findsNothing);
        expect(find.text('Lab Komputer 1'), findsNothing);
      });

      testWidgets(
        'shows success dialog with correct title and message when create '
        'success',
        (tester) async {
          final controller = StreamController<RoomMutationState>.broadcast();
          when(() => roomMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            RoomMutationState(
              notice: RoomCreatedNotice(room),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Ruangan berhasil disimpan'), findsOneWidget);
          expect(
            find.text(
              'Ruangan dengan nama "${room.name}" berhasil disimpan',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows success dialog with correct title and message when update '
        'success',
        (tester) async {
          const updated = Room(
            id: 'id',
            facultyId: 'faculty_1',
            name: 'updated',
          );
          final controller = StreamController<RoomMutationState>.broadcast();
          when(() => roomMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);
          controller.add(
            RoomMutationState(
              notice: RoomUpdatedNotice(before: room, after: updated),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Ruangan "${room.name}" berhasil diperbarui'),
            findsOneWidget,
          );
          expect(
            find.text(
              'Ruangan "${room.name}" berhasil diperbarui '
              'dengan nama "${updated.name}"',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows failed dialog with correct title and message when create failed',
        (tester) async {
          final controller = StreamController<RoomMutationState>.broadcast();
          when(() => roomMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            RoomMutationState(
              notice: RoomMutationFailedNotice(
                type: RoomMutationType.create,
                exception: AppException.test(),
                room: null,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal menyimpan ruangan baru'),
            findsOneWidget,
          );
          expect(
            find.text(AppExceptionCode.internal.message),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows failed dialog with correct title and message when update failed',
        (tester) async {
          final controller = StreamController<RoomMutationState>.broadcast();
          when(() => roomMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            RoomMutationState(
              notice: RoomMutationFailedNotice(
                type: RoomMutationType.update,
                exception: AppException.test(),
                room: room,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal memperbarui ruangan'),
            findsOneWidget,
          );
          expect(
            find.text(AppExceptionCode.internal.message),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows failed dialog with correct title and message when delete failed',
        (tester) async {
          final controller = StreamController<RoomMutationState>.broadcast();
          when(() => roomMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            RoomMutationState(
              notice: RoomMutationFailedNotice(
                type: RoomMutationType.delete,
                exception: AppException.test(),
                room: room,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal menghapus ruangan'),
            findsOneWidget,
          );
          expect(
            find.text(AppExceptionCode.internal.message),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows success dialog and call onRoomDeleted when delete success',
        (tester) async {
          final controller = StreamController<RoomMutationState>.broadcast();
          when(() => roomMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);
          Room? deleted;
          await pumpWidget(
            tester,
            onRoomDeleted: (v) {
              deleted = v;
            },
          );

          controller.add(
            RoomMutationState(
              notice: RoomDeletedNotice(room),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Ruangan berhasil dihapus'), findsOneWidget);
          expect(
            find.text('Ruangan dengan nama "${room.name}" berhasil dihapus'),
            findsOneWidget,
          );

          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();

          expect(deleted, room);
        },
      );
    });
  });
}
