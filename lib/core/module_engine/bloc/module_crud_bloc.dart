import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/module_metadata.dart';
import '../repository/module_record_repository.dart';
import 'module_crud_event.dart';
import 'module_crud_state.dart';

/// Coordinates one module's CRUD session without owning global module state.
///
/// Create one instance per module route or page scope from an immutable
/// metadata snapshot. Records and operation status remain local to this bloc;
/// metadata lifecycle is owned by [ModuleMetadataBloc].
class ModuleCrudBloc extends Bloc<ModuleCrudEvent, ModuleCrudState> {
  ModuleCrudBloc({
    required this.metadata,
    required this.recordRepository,
  }) : super(ModuleCrudState(
          pageSize: metadata.schema.grid?.pageSize ?? 20,
        )) {
    on<ModuleStarted>(_onStarted);
    on<ModuleRefreshRequested>(_onRefresh);
    on<ModuleSearchChanged>(_onSearchChanged);
    on<ModuleFiltersChanged>(_onFiltersChanged);
    on<ModulePageChanged>(_onPageChanged);
    on<ModuleCreateRequested>(_onCreate);
    on<ModuleDetailRequested>(_onDetail);
    on<ModuleEditRequested>(_onEdit);
    on<ModuleFormSubmitted>(_onSubmit);
    on<ModuleDeleteRequested>(_onDelete);
    on<ModuleBackRequested>(_onBack);
  }

  final ModuleMetadata metadata;
  final ModuleRecordRepository recordRepository;
  Timer? _searchDebounce;

  void _onStarted(
    ModuleStarted event,
    Emitter<ModuleCrudState> emit,
  ) async {
    if (event.recordId != null) {
      add(ModuleDetailRequested(event.recordId!));
    } else {
      add(const ModuleRefreshRequested());
    }
  }

  Future<void> _onRefresh(
    ModuleRefreshRequested event,
    Emitter<ModuleCrudState> emit,
  ) async {
    if (state.recordsStatus == ModuleLoadStatus.loading) {
      return;
    }
    emit(state.copyWith(
      recordsStatus: ModuleLoadStatus.loading,
      clearOperationError: true,
    ));
    try {
      final result = await recordRepository.list(
        metadata: metadata,
        page: state.page,
        pageSize: state.pageSize,
        search: state.search,
        filters: state.filters,
      );
      emit(state.copyWith(
        recordsStatus: ModuleLoadStatus.success,
        records: result.items,
        total: result.total,
      ));
    } catch (error) {
      emit(state.copyWith(
        recordsStatus: ModuleLoadStatus.failure,
        operationError: error.toString(),
      ));
    }
  }

  void _onSearchChanged(ModuleSearchChanged event, Emitter<ModuleCrudState> emit) {
    emit(state.copyWith(search: event.query, page: 1));
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!isClosed) add(const ModuleRefreshRequested());
    });
  }

  void _onFiltersChanged(ModuleFiltersChanged event, Emitter<ModuleCrudState> emit) {
    emit(state.copyWith(filters: Map.unmodifiable(event.filters), page: 1));
    add(const ModuleRefreshRequested());
  }

  void _onPageChanged(ModulePageChanged event, Emitter<ModuleCrudState> emit) {
    if (event.page < 1 || event.page == state.page) return;
    emit(state.copyWith(page: event.page));
    add(const ModuleRefreshRequested());
  }

  void _onCreate(ModuleCreateRequested event, Emitter<ModuleCrudState> emit) {
    emit(state.copyWith(
      view: ModuleCrudView.create,
      formData: const {},
      clearSelected: true,
      operation: ModuleOperation.idle,
      clearOperationError: true,
    ));
  }

  Future<void> _onDetail(
    ModuleDetailRequested event,
    Emitter<ModuleCrudState> emit,
  ) async {
    await _loadRecord(event.id, ModuleCrudView.detail, emit);
  }

  Future<void> _onEdit(
    ModuleEditRequested event,
    Emitter<ModuleCrudState> emit,
  ) async {
    await _loadRecord(event.id, ModuleCrudView.edit, emit);
  }

  Future<void> _loadRecord(
    String id,
    ModuleCrudView view,
    Emitter<ModuleCrudState> emit,
  ) async {
    if (state.detailStatus == ModuleLoadStatus.loading) return;
    emit(state.copyWith(detailStatus: ModuleLoadStatus.loading, clearOperationError: true));
    try {
      final record = await recordRepository.detail(metadata: metadata, id: id);
      emit(state.copyWith(
        detailStatus: ModuleLoadStatus.success,
        selected: record,
        formData: record,
        view: view,
      ));
    } catch (error) {
      emit(state.copyWith(
        detailStatus: ModuleLoadStatus.failure,
        operationError: error.toString(),
      ));
    }
  }

  Future<void> _onSubmit(
    ModuleFormSubmitted event,
    Emitter<ModuleCrudState> emit,
  ) async {
    if (state.operation == ModuleOperation.loading) return;
    emit(state.copyWith(
      operation: ModuleOperation.loading,
      formData: Map.unmodifiable(event.data),
      clearOperationError: true,
    ));
    try {
      final id = state.selected?[metadata.primaryKey]?.toString();
      if (state.view == ModuleCrudView.edit && id != null && id.isNotEmpty) {
        await recordRepository.update(metadata: metadata, id: id, data: event.data);
      } else {
        await recordRepository.create(metadata: metadata, data: event.data);
      }
      emit(state.copyWith(operation: ModuleOperation.success));
      add(const ModuleRefreshRequested());
      emit(state.copyWith(view: ModuleCrudView.list));
    } catch (error) {
      emit(state.copyWith(
        operation: ModuleOperation.failure,
        operationError: error.toString(),
      ));
    }
  }

  Future<void> _onDelete(
    ModuleDeleteRequested event,
    Emitter<ModuleCrudState> emit,
  ) async {
    if (state.operation == ModuleOperation.loading) return;
    emit(state.copyWith(operation: ModuleOperation.loading, clearOperationError: true));
    try {
      await recordRepository.delete(metadata: metadata, id: event.id);
      emit(state.copyWith(
        operation: ModuleOperation.success,
        view: ModuleCrudView.list,
        clearSelected: true,
      ));
      add(const ModuleRefreshRequested());
    } catch (error) {
      emit(state.copyWith(
        operation: ModuleOperation.failure,
        operationError: error.toString(),
      ));
    }
  }

  void _onBack(ModuleBackRequested event, Emitter<ModuleCrudState> emit) {
    emit(state.copyWith(
      view: ModuleCrudView.list,
      operation: ModuleOperation.idle,
      clearSelected: true,
      clearOperationError: true,
    ));
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
