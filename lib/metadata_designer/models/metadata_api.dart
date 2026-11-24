import 'api_operation.dart';

class MetadataApi {
  final List<ApiOperationOption> operations;

  const MetadataApi({this.operations = const []});

  /// Parse API operation JSON array.
  factory MetadataApi.fromJson(List<dynamic> json) {
    return MetadataApi(
      operations: json
          .whereType<Map>()
          .map(
            (item) =>
                ApiOperationOption.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  /// Find an operation by its operation key.
  ApiOperationOption? getOperation(String operation) {
    for (final item in operations) {
      if (item.operation == operation) {
        return item;
      }
    }

    return null;
  }

  /// Add or replace an operation.
  MetadataApi updateOperation(ApiOperationOption operation) {
    final updated = [...operations];

    final index = updated.indexWhere(
      (item) => item.operation == operation.operation,
    );

    if (index >= 0) {
      updated[index] = operation;
    } else {
      updated.add(operation);
    }

    return copyWith(operations: updated);
  }

  /// Remove an operation.
  MetadataApi removeOperation(String operation) {
    return copyWith(
      operations: operations
          .where((item) => item.operation != operation)
          .toList(),
    );
  }

  /// Enable or disable an operation.
  MetadataApi toggleOperation(String operation, {required bool enabled}) {
    final existing = getOperation(operation);

    if (existing == null) return this;

    return updateOperation(existing.copyWith(enabled: enabled));
  }

  /// Immutable copy.
  MetadataApi copyWith({List<ApiOperationOption>? operations}) {
    return MetadataApi(operations: operations ?? this.operations);
  }

  /// Serialize directly to JSON array.
  List<Map<String, dynamic>> toJson() {
    return operations.map((item) => item.toJson()).toList();
  }

  /// Create default CRUD operations for an entity.
  factory MetadataApi.empty({required String entity}) {
    return MetadataApi(
      operations: ApiOperationOptions.defaults.map((option) {
        return ApiOperationOption.fromCatalog(option: option, entity: entity);
      }).toList(),
    );
  }

  /// Create metadata using selected catalog operations.
  factory MetadataApi.fromCatalog({
    required String entity,
    required List<String> selectedOperations,
  }) {
    final selected = ApiOperationOptions.all.where(
      (option) => selectedOperations.contains(option.operation),
    );

    return MetadataApi(
      operations: selected.map((option) {
        return ApiOperationOption.fromCatalog(option: option, entity: entity);
      }).toList(),
    );
  }

  /// Check whether an operation is configured and enabled.
  bool isEnabled(String operation) {
    return getOperation(operation)?.enabled ?? false;
  }

  /// Return enabled operations only.
  List<ApiOperationOption> get enabledOperations {
    return operations.where((item) => item.enabled).toList();
  }
}
