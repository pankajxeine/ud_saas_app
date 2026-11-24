import 'package:flutter/material.dart';

import '../../core/crud/crud_bloc.dart';
import '../../core/widgets/crud/generic_crud_widget.dart';

class GenericCrudDemoPage extends StatefulWidget {
  const GenericCrudDemoPage({super.key});

  @override
  State<GenericCrudDemoPage> createState() => _GenericCrudDemoPageState();
}

class _GenericCrudDemoPageState extends State<GenericCrudDemoPage> {
  late final _DemoCrudRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = _DemoCrudRepository();
  }

  @override
  Widget build(BuildContext context) {
    return GenericCrudWidget(
      title: 'Customers',
      baseUrl: '',
      repository: _repository,
      schemaJson: _customerSchema,
    );
  }
}

const Map<String, dynamic> _customerSchema = {
  'entity': 'customer',
  'title': 'Customers',
  'primaryKey': 'id',
  'grid': {
    'pageSize': 5,
    'defaultSort': {'fields': ['name'], 'direction': 'asc'},
  },
  'search': {
    'quickSearch': ['name', 'email'],
    'filters': [
      {'field': 'active', 'label': 'Active'},
    ],
  },
  'api': [
    {'operation': 'list', 'path': '/customers'},
    {'operation': 'create', 'path': '/customers'},
    {'operation': 'detail', 'path': '/customers/{id}'},
    {'operation': 'update', 'path': '/customers/{id}'},
    {'operation': 'delete', 'path': '/customers/{id}'},
  ],
  'fields': [
    {
      'name': 'id',
      'label': 'ID',
      'type': 'string',
      'readOnly': true,
      'visibility': {'show': ['table', 'detail']},
    },
    {
      'name': 'name',
      'label': 'Name',
      'type': 'string',
      'validationRules': {'required': true, 'minLength': 2},
      'visibility': {'show': ['table', 'detail', 'create', 'edit']},
    },
    {
      'name': 'email',
      'label': 'Email',
      'type': 'string',
      'validationRules': {'required': true, 'email': true},
      'visibility': {'show': ['table', 'detail', 'create', 'edit']},
    },
    {
      'name': 'company',
      'label': 'Company',
      'type': 'string',
      'visibility': {'show': ['table', 'detail', 'create', 'edit']},
    },
    {
      'name': 'active',
      'label': 'Active',
      'type': 'boolean',
      'initialValue': true,
      'visibility': {'show': ['table', 'detail', 'create', 'edit']},
    },
  ],
};

class _DemoCrudRepository implements CrudRepository {
  final List<Map<String, dynamic>> _records = [
    {
      'id': 'CUS-001',
      'name': 'Alice Johnson',
      'email': 'alice@example.com',
      'company': 'Northwind',
      'active': true,
    },
    {
      'id': 'CUS-002',
      'name': 'Bob Smith',
      'email': 'bob@example.com',
      'company': 'Contoso',
      'active': true,
    },
    {
      'id': 'CUS-003',
      'name': 'Charlie Brown',
      'email': 'charlie@example.com',
      'company': 'Adventure Works',
      'active': false,
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchAll({Map<String, dynamic>? query}) async =>
      _records.map(Map<String, dynamic>.from).toList();

  @override
  Future<Map<String, dynamic>> fetchById(String id) async =>
      Map<String, dynamic>.from(
        _records.firstWhere((record) => record['id'] == id),
      );

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final record = {
      ...data,
      'id': 'CUS-${(_records.length + 1).toString().padLeft(3, '0')}',
    };
    _records.add(record);
    return Map<String, dynamic>.from(record);
  }

  @override
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final index = _records.indexWhere((record) => record['id'] == id);
    if (index < 0) throw StateError('Customer not found: $id');
    _records[index] = {..._records[index], ...data, 'id': id};
    return Map<String, dynamic>.from(_records[index]);
  }

  @override
  Future<void> delete(String id) async {
    _records.removeWhere((record) => record['id'] == id);
  }
}
