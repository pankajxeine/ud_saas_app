import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/module_metadata.dart';
import '../repository/module_metadata_repository.dart';

enum ModuleMetadataStatus { initial, loading, success, failure }

class ModuleMetadataState {
  const ModuleMetadataState({
    this.status = ModuleMetadataStatus.initial,
    this.metadata,
    this.error,
  });

  final ModuleMetadataStatus status;
  final ModuleMetadata? metadata;
  final String? error;
}

/// Loads one module definition. CRUD records and operation state live in a
/// separate [ModuleCrudBloc].
class ModuleMetadataBloc extends Cubit<ModuleMetadataState> {
  ModuleMetadataBloc({required this.moduleId, required this.repository})
      : super(const ModuleMetadataState());

  final String moduleId;
  final ModuleMetadataRepository repository;

  Future<void> load() async {
    if (state.status == ModuleMetadataStatus.loading ||
        state.status == ModuleMetadataStatus.success) {
      return;
    }
    emit(const ModuleMetadataState(status: ModuleMetadataStatus.loading));
    try {
      emit(ModuleMetadataState(
        status: ModuleMetadataStatus.success,
        metadata: await repository.get(moduleId),
      ));
    } catch (error) {
      emit(ModuleMetadataState(
        status: ModuleMetadataStatus.failure,
        error: error.toString(),
      ));
    }
  }

  Future<void> retry() async {
    emit(const ModuleMetadataState());
    await load();
  }
}
