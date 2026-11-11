import 'dart:convert';

import 'package:flutter/material.dart' hide DataTable, Scaffold;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/core/api/rest_api.dart';
import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/core/widgets/components/loading.dart';
import 'package:ud_sass_app/core/widgets/data_table/data_table.dart'
    as app_table;
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/components/scaffold.dart' as app_scaffold;

sealed class ConsentTableBlocEvent {}

final class LoadConsentTableEvent extends ConsentTableBlocEvent {}

sealed class ConsentTableBlocState {}

final class ConsentTableBlocInitial extends ConsentTableBlocState {}

final class ConsentTableBlocLoading extends ConsentTableBlocState {}

final class ConsentTableBlocLoaded extends ConsentTableBlocState {
  ConsentTableBlocLoaded(this.rows);
  final List<Map<String, dynamic>> rows;
}

final class ConsentTableBlocFailure extends ConsentTableBlocState {
  ConsentTableBlocFailure(this.message);
  final String message;
}

class ConsentTableBloc
    extends Bloc<ConsentTableBlocEvent, ConsentTableBlocState> {
  ConsentTableBloc({required this.api, required this.endpoint})
    : super(ConsentTableBlocInitial()) {
    on<LoadConsentTableEvent>(_load);
  }

  final RestApi api;
  final String endpoint;

  Future<void> _load(
    LoadConsentTableEvent event,
    Emitter<ConsentTableBlocState> emit,
  ) async {
    emit(ConsentTableBlocLoading());
    try {
      final response = await api.get<dynamic>(endpoint);
      emit(ConsentTableBlocLoaded(_parseRows(response)));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(ConsentTableBlocFailure(error.toString()));
    }
  }
}

List<Map<String, dynamic>> _parseRows(dynamic response) {
  dynamic records = response;
  while (records is Map && records.containsKey('data')) {
    records = records['data'];
  }
  if (records is! List) {
    throw const FormatException(
      'List API response must be an array or a data envelope',
    );
  }
  return records
      .map((record) {
        if (record is! Map) {
          throw const FormatException(
            'List API response contains a non-object record',
          );
        }
        return Map<String, dynamic>.from(record);
      })
      .toList(growable: false);
}

class ConsentTablePage extends StatelessWidget {
  const ConsentTablePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<ConsentTableBloc>(
    create: (_) => ConsentTableBloc(
      api: RestApi(baseUrl: ProfileConstants.api.toString()),
      endpoint: "/consent",
    )..add(LoadConsentTableEvent()),
    child: app_scaffold.Scaffold(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<ConsentTableBloc, ConsentTableBlocState>(
          builder: (context, state) {
            if (state is ConsentTableBlocLoading ||
                state is ConsentTableBlocInitial) {
              return const Center(child: Loading());
            }
            if (state is ConsentTableBlocFailure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    Button(
                      onPressed: () => context.read<ConsentTableBloc>().add(
                        LoadConsentTableEvent(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is ConsentTableBlocLoaded) {
              final columns = <app_table.TrinaColumn>[
                app_table.TrinaColumn(
                  title: "Record Code",
                  field: "record_code",
                  type: app_table.TrinaColumnType.text(),
                ),
                app_table.TrinaColumn(
                  title: "Consent Id",
                  field: "consent_id",
                  type: app_table.TrinaColumnType.text(),
                ),
                app_table.TrinaColumn(
                  title: "Subject Type",
                  field: "subject_type",
                  type: app_table.TrinaColumnType.text(),
                ),
                app_table.TrinaColumn(
                  title: "Subject Id",
                  field: "subject_id",
                  type: app_table.TrinaColumnType.text(),
                ),
                app_table.TrinaColumn(
                  title: "Purpose",
                  field: "purpose",
                  type: app_table.TrinaColumnType.text(),
                ),
                app_table.TrinaColumn(
                  title: "Granted",
                  field: "granted",
                  type: app_table.TrinaColumnType.text(),
                ),
                app_table.TrinaColumn(
                  title: "Source",
                  field: "source",
                  type: app_table.TrinaColumnType.text(),
                ),
                app_table.TrinaColumn(
                  title: "Policy Version",
                  field: "policy_version",
                  type: app_table.TrinaColumnType.text(),
                ),
                app_table.TrinaColumn(
                  title: "Evidence Ref",
                  field: "evidence_ref",
                  type: app_table.TrinaColumnType.text(),
                ),
                app_table.TrinaColumn(
                  title: "Captured At",
                  field: "captured_at",
                  type: app_table.TrinaColumnType.text(),
                ),
                app_table.TrinaColumn(
                  title: "Withdrawn At",
                  field: "withdrawn_at",
                  type: app_table.TrinaColumnType.text(),
                ),
              ];
              final rows = state.rows
                  .map((record) {
                    return app_table.TrinaRow<dynamic>(
                      cells: <String, app_table.TrinaCell>{
                        "record_code": app_table.TrinaCell(
                          value: _displayCell(record["record_code"], "string"),
                        ),
                        "consent_id": app_table.TrinaCell(
                          value: _displayCell(record["consent_id"], "uuid"),
                        ),
                        "subject_type": app_table.TrinaCell(
                          value: _displayCell(record["subject_type"], "string"),
                        ),
                        "subject_id": app_table.TrinaCell(
                          value: _displayCell(record["subject_id"], "uuid"),
                        ),
                        "purpose": app_table.TrinaCell(
                          value: _displayCell(record["purpose"], "string"),
                        ),
                        "granted": app_table.TrinaCell(
                          value: _displayCell(record["granted"], "boolean"),
                        ),
                        "source": app_table.TrinaCell(
                          value: _displayCell(record["source"], "string"),
                        ),
                        "policy_version": app_table.TrinaCell(
                          value: _displayCell(
                            record["policy_version"],
                            "string",
                          ),
                        ),
                        "evidence_ref": app_table.TrinaCell(
                          value: _displayCell(record["evidence_ref"], "string"),
                        ),
                        "captured_at": app_table.TrinaCell(
                          value: _displayCell(
                            record["captured_at"],
                            "datetime",
                          ),
                        ),
                        "withdrawn_at": app_table.TrinaCell(
                          value: _displayCell(
                            record["withdrawn_at"],
                            "datetime",
                          ),
                        ),
                      },
                    );
                  })
                  .toList(growable: false);
              return app_table.DataTable(
                title: "Consent",
                columns: columns,
                rows: rows,
                mobileRowKey: (row) =>
                    row.cells["consent_id"]?.value.toString() ?? '',
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
}

dynamic _displayCell(dynamic value, String type) {
  if (value == null) return '-';
  if (type == 'integer' || type == 'number') {
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? value.toString();
  }
  if (type == 'boolean') {
    if (value == true) return 'Yes';
    if (value == false) return 'No';
  }
  if (value is Map || value is List) return jsonEncode(value);
  return value.toString();
}
