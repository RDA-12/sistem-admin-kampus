import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/presentation/bloc/bloc.dart';
import 'package:sistem_admin/faculty/presentation/widgets/widgets.dart';

/// Page to shows faculties data
class FacultiesListPage extends StatelessWidget {
  /// Creates new [FacultiesListPage]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FacultiesBloc>()
        ..add(
          const SubscriptionRequested(),
        ),
      child: Scaffold(
        body: FacultiesList(
          onCreatePressed: () {
            unawaited(const CreateFacultyRoute().push<void>(context));
          },
        ),
      ),
    );
  }
}
