import 'package:equatable/equatable.dart';

enum ModuleLoadStatus { initial, loading, success, failure }

enum ModuleOperation { idle, loading, success, failure }

enum ModuleCrudView { list, detail, create, edit }

/// Immutable state for one module route/session. Metadata and records are
/// separate so operation changes do not invalidate metadata or table data.
class ModuleCrudState extends Equatable {
  const ModuleCrudState({
    this.recordsStatus = ModuleLoadStatus.initial,
    this.records = const [],
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.search = '',
    this.filters = const {},
    this.selected,
    this.formData = const {},
    this.view = ModuleCrudView.list,
    this.detailStatus = ModuleLoadStatus.initial,
    this.operation = ModuleOperation.idle,
    this.operationError,
    this.fieldErrors = const {},
  });

  final ModuleLoadStatus recordsStatus;
  final List<Map<String, dynamic>> records;
  final int total;
  final int page;
  final int pageSize;
  final String search;
  final Map<String, dynamic> filters;

  final Map<String, dynamic>? selected;
  final Map<String, dynamic> formData;
  final ModuleCrudView view;
  final ModuleLoadStatus detailStatus;

  final ModuleOperation operation;
  final String? operationError;
  final Map<String, String> fieldErrors;

  bool get isBusy =>
      recordsStatus == ModuleLoadStatus.loading ||
      detailStatus == ModuleLoadStatus.loading ||
      operation == ModuleOperation.loading;

  ModuleCrudState copyWith({
    ModuleLoadStatus? recordsStatus,
    List<Map<String, dynamic>>? records,
    int? total,
    int? page,
    int? pageSize,
    String? search,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? selected,
    Map<String, dynamic>? formData,
    ModuleCrudView? view,
    ModuleLoadStatus? detailStatus,
    ModuleOperation? operation,
    String? operationError,
    Map<String, String>? fieldErrors,
    bool clearSelected = false,
    bool clearOperationError = false,
  }) {
    return ModuleCrudState(
      recordsStatus: recordsStatus ?? this.recordsStatus,
      records: records ?? this.records,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      filters: filters ?? this.filters,
      selected: clearSelected ? null : selected ?? this.selected,
      formData: formData ?? this.formData,
      view: view ?? this.view,
      detailStatus: detailStatus ?? this.detailStatus,
      operation: operation ?? this.operation,
      operationError: clearOperationError
          ? null
          : operationError ?? this.operationError,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [
    recordsStatus,
    records,
    total,
    page,
    pageSize,
    search,
    filters,
    selected,
    formData,
    view,
    detailStatus,
    operation,
    operationError,
    fieldErrors,
  ];
}
