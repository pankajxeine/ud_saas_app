import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/rest_api.dart';

enum CrudScreen { list, create, edit, details }

class CrudApiOperation {
  const CrudApiOperation({required this.name, required this.path});

  final String name;
  final String path;
}

class CrudApiConfig {
  const CrudApiConfig(this.operations);

  final Map<String, CrudApiOperation> operations;

  factory CrudApiConfig.fromJson(dynamic value) {
    final result = <String, CrudApiOperation>{};
    if (value is List) {
      for (final item in value.whereType<Map>()) {
        final json = Map<String, dynamic>.from(item);
        final name = json['operation']?.toString();
        final path = json['path']?.toString();
        if (name != null && path != null && path.isNotEmpty) {
          result[name] = CrudApiOperation(name: name, path: path);
        }
      }
    }
    return CrudApiConfig(result);
  }

  CrudApiOperation? operator [](String name) => operations[name];
}

abstract interface class CrudRepository {
  Future<List<Map<String, dynamic>>> fetchAll({Map<String, dynamic>? query});
  Future<Map<String, dynamic>> fetchById(String id);
  Future<Map<String, dynamic>> create(Map<String, dynamic> data);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

class RestCrudRepository implements CrudRepository {
  RestCrudRepository({
    required String baseUrl,
    required Map<String, dynamic> schemaJson,
    RestApi? api,
  }) : _api = api ?? RestApi(baseUrl: baseUrl),
       _config = CrudApiConfig.fromJson(schemaJson['api']),
       _primaryKey = schemaJson['primaryKey']?.toString() ?? 'id';

  final RestApi _api;
  final CrudApiConfig _config;
  final String _primaryKey;

  String _path(String operation, [String? id]) {
    final config = _config[operation];
    if (config == null) throw StateError('Missing "$operation" API operation.');
    var path = config.path;
    if (id != null) {
      final encoded = Uri.encodeComponent(id);
      path = path
          .replaceAll('{$_primaryKey}', encoded)
          .replaceAll('{id}', encoded)
          .replaceAll(':id', encoded)
          .replaceAll(':$_primaryKey', encoded);
    }
    return path;
  }

  dynamic _body(dynamic value) {
    if (value is Map && value['data'] != null) return value['data'];
    if (value is Map && value['body'] != null) return value['body'];
    return value;
  }

  Map<String, dynamic> _map(dynamic value) =>
      Map<String, dynamic>.from(_body(value) as Map);

  List<Map<String, dynamic>> _list(dynamic value) {
    final body = _body(value);
    final list = body is List
        ? body
        : body is Map
        ? (body['items'] ?? body['results'] ?? body['rows'])
        : null;
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAll({Map<String, dynamic>? query}) async {
    final response = await _api.requestWithResponse<dynamic>(
      endpointPath: _path('list'),
      method: 'GET',
      queryParams: query,
    );
    return _list(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchById(String id) async {
    final response = await _api.requestWithResponse<dynamic>(
      endpointPath: _path('detail', id),
      method: 'GET',
    );
    return _map(response.data);
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _api.requestWithResponse<dynamic>(
      endpointPath: _path('create'),
      method: 'POST',
      body: data,
    );
    return _map(response.data);
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    final response = await _api.requestWithResponse<dynamic>(
      endpointPath: _path('update', id),
      method: 'PUT',
      body: data,
    );
    return _map(response.data);
  }

  @override
  Future<void> delete(String id) async {
    await _api.requestWithResponse<dynamic>(
      endpointPath: _path('delete', id),
      method: 'DELETE',
    );
  }
}

sealed class CrudEvent {
  const CrudEvent();
}

class CrudLoad extends CrudEvent {
  const CrudLoad();
}

class CrudOpen extends CrudEvent {
  const CrudOpen(this.id);
  final String id;
}

class CrudStartCreate extends CrudEvent {
  const CrudStartCreate();
}

class CrudStartEdit extends CrudEvent {
  const CrudStartEdit(this.record);
  final Map<String, dynamic> record;
}

class CrudSave extends CrudEvent {
  const CrudSave(this.data);
  final Map<String, dynamic> data;
}

class CrudDelete extends CrudEvent {
  const CrudDelete(this.id);
  final String id;
}

class CrudBackToList extends CrudEvent {
  const CrudBackToList();
}

class CrudState {
  const CrudState({
    this.screen = CrudScreen.list,
    this.records = const [],
    this.selected,
    this.editing,
    this.loading = false,
    this.saving = false,
    this.deleting = false,
    this.error,
  });

  final CrudScreen screen;
  final List<Map<String, dynamic>> records;
  final Map<String, dynamic>? selected;
  final Map<String, dynamic>? editing;
  final bool loading;
  final bool saving;
  final bool deleting;
  final String? error;

  CrudState copyWith({
    CrudScreen? screen,
    List<Map<String, dynamic>>? records,
    Map<String, dynamic>? selected,
    Map<String, dynamic>? editing,
    bool? loading,
    bool? saving,
    bool? deleting,
    String? error,
    bool clearSelected = false,
    bool clearEditing = false,
  }) => CrudState(
    screen: screen ?? this.screen,
    records: records ?? this.records,
    selected: clearSelected ? null : selected ?? this.selected,
    editing: clearEditing ? null : editing ?? this.editing,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    deleting: deleting ?? this.deleting,
    error: error,
  );
}

class CrudBloc extends Bloc<CrudEvent, CrudState> {
  CrudBloc({required CrudRepository repository, this.primaryKey = 'id'})
      : _repository = repository,
        super(const CrudState()) {
    on<CrudLoad>((event, emit) async {
      emit(state.copyWith(loading: true, error: null));
      try {
        final records = await _repository.fetchAll();
        emit(state.copyWith(loading: false, records: records));
      } catch (error) {
        emit(state.copyWith(loading: false, error: error.toString()));
      }
    });
    on<CrudOpen>((event, emit) async {
      emit(state.copyWith(loading: true, error: null));
      try {
        final record = await _repository.fetchById(event.id);
        emit(state.copyWith(loading: false, screen: CrudScreen.details, selected: record));
      } catch (error) {
        emit(state.copyWith(loading: false, error: error.toString()));
      }
    });
    on<CrudStartCreate>((event, emit) => emit(state.copyWith(
      screen: CrudScreen.create,
      clearEditing: true,
      clearSelected: true,
      error: null,
    )));
    on<CrudStartEdit>((event, emit) => emit(state.copyWith(
      screen: CrudScreen.edit,
      editing: event.record,
      error: null,
    )));
    on<CrudBackToList>((event, emit) => emit(state.copyWith(
      screen: CrudScreen.list,
      clearEditing: true,
      clearSelected: true,
    )));
    on<CrudSave>((event, emit) async {
      emit(state.copyWith(saving: true, error: null));
      try {
        final id = state.editing?[primaryKey]?.toString();
        if (state.screen == CrudScreen.edit && id != null && id.isNotEmpty) {
          await _repository.update(id, event.data);
        } else {
          await _repository.create(event.data);
        }
        final records = await _repository.fetchAll();
        emit(state.copyWith(
          saving: false,
          screen: CrudScreen.list,
          records: records,
          clearEditing: true,
        ));
      } catch (error) {
        emit(state.copyWith(saving: false, error: error.toString()));
      }
    });
    on<CrudDelete>((event, emit) async {
      emit(state.copyWith(deleting: true, error: null));
      try {
        await _repository.delete(event.id);
        final records = await _repository.fetchAll();
        emit(state.copyWith(
          deleting: false,
          screen: CrudScreen.list,
          records: records,
          clearSelected: true,
        ));
      } catch (error) {
        emit(state.copyWith(deleting: false, error: error.toString()));
      }
    });
  }

  final CrudRepository _repository;
  final String primaryKey;
}
