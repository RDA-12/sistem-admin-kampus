import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

import '../../program/domain/mocks.dart';

@LazySingleton(as: ILecturerRepository, env: [Environment.test])
class MockLecturerRepository extends Mock implements ILecturerRepository;

@LazySingleton(as: WatchLecturersUseCase, env: [Environment.test])
class MockWatchLecturersUseCase extends Mock implements WatchLecturersUseCase;

@LazySingleton(as: WatchSingleLecturerUseCase, env: [Environment.test])
class MockWatchSingleLecturerUseCase extends Mock
    implements WatchSingleLecturerUseCase;

@LazySingleton(as: CreateLecturerUseCase, env: [Environment.test])
class MockCreateLecturerUseCase extends Mock implements CreateLecturerUseCase;

@LazySingleton(as: UpdateLecturerUseCase, env: [Environment.test])
class MockUpdateLecturerUseCase extends Mock implements UpdateLecturerUseCase;

@LazySingleton(as: DeleteLecturerUseCase, env: [Environment.test])
class MockDeleteLecturerUseCase extends Mock implements DeleteLecturerUseCase;

final lecturersMock = List<Lecturer>.generate(
  5,
  (index) => Lecturer(
    id: '$index',
    programId: 'program_1',
    name: 'Lecturer $index',
    pangkatGolongan: 'III/a',
  ),
);
const lecturerMock = Lecturer(
  id: 'id',
  programId: 'program_1',
  name: 'Lecturer',
  pangkatGolongan: 'III/a',
);
final List<LecturerUI> lecturersUIMock = lecturersMock
    .map(
      (it) => LecturerUI(
        id: it.id,
        programId: programMock.id,
        name: it.name,
        pangkatGolongan: it.pangkatGolongan,
        program: programMock,
      ),
    )
    .toList();
final LecturerUI lecturerUIMock = lecturersUIMock.first;
