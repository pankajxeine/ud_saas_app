import 'package:flutter/material.dart';

import '../../core/widgets/data_table/data_table.dart';
import '../models/metadata_field.dart';
import '../models/metadata_schema.dart';

/// Material 3 / Trina table driven by a metadata schema and API records.
class MetadataDataTable extends StatefulWidget {
  const MetadataDataTable({
    super.key,
    required this.schemaJson,
    required this.rows,
    this.title,
    this.subtitle,
    this.onRowTap,
    this.onRowEdit,
  });

  final Map<String, dynamic> schemaJson;
  final List<Map<String, dynamic>> rows;
  final String? title;
  final String? subtitle;
  final void Function(Map<String, dynamic> row)? onRowTap;
  final void Function(Map<String, dynamic> row)? onRowEdit;

  @override
  State<MetadataDataTable> createState() => _MetadataDataTableState();
}

class _MetadataDataTableState extends State<MetadataDataTable> {
  late final TextEditingController _searchController;
  final Map<String, TextEditingController> _filterControllers = {};
  final Map<String, bool?> _boolFilters = {};
  bool _searchExpanded = false;
  bool _filtersExpanded = false;
  String? _selectedSearchField;
  int _page = 1;

  static const _allSearchFields = '__all_search_fields__';

  MetadataSchema get schema => MetadataSchema.fromJson(widget.schemaJson);

  List<String> get quickSearchFields => _list(schema.search['quickSearch']);

  List<Map<String, dynamic>> get filters {
    final raw = schema.search['filters'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) => item['field']?.toString().isNotEmpty == true)
        .toList();
  }

  List<String> _list(dynamic value) => value is List
      ? value.map((item) => item.toString()).toList()
      : <String>[];

  List<MetadataField> get visibleFields => schema.fields
      .where((field) => field.showInTable)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _syncFilterControllers();
    _selectedSearchField = quickSearchFields.firstOrNull;
  }

  @override
  void didUpdateWidget(covariant MetadataDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFilterControllers();
    if (_selectedSearchField != _allSearchFields &&
        !quickSearchFields.contains(_selectedSearchField)) {
      _selectedSearchField = quickSearchFields.firstOrNull;
    }
  }

  void _syncFilterControllers() {
    final names = filters.map((filter) => filter['field'].toString()).toSet();
    for (final name in names) {
      _filterControllers.putIfAbsent(name, TextEditingController.new);
    }
    for (final name in _filterControllers.keys
        .where((name) => !names.contains(name))
        .toList()) {
      _filterControllers.remove(name)?.dispose();
      _boolFilters.remove(name);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final controller in _filterControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _value(dynamic value) => value is bool
      ? (value ? 'true' : 'false')
      : (value is Map || value is Iterable ? value.toString() : '${value ?? ''}');

  List<Map<String, dynamic>> get filteredRows {
    final query = _searchController.text.trim().toLowerCase();
    final result = widget.rows.where((row) {
      final searchFields = _selectedSearchField == _allSearchFields
          ? quickSearchFields
          : (_selectedSearchField == null ? const <String>[] : [_selectedSearchField!]);
      if (query.isNotEmpty &&
          !searchFields.any(
            (field) => _value(row[field]).toLowerCase().contains(query),
          )) {
        return false;
      }
      for (final filter in filters) {
        final name = filter['field'].toString();
        final field = schema.fields.where((item) => item.name == name).firstOrNull;
        final value = row[name];
        if (field?.type == 'boolean') {
          final expected = _boolFilters[name];
          if (expected != null && value != expected) return false;
        } else {
          final text = _filterControllers[name]?.text.trim().toLowerCase() ?? '';
          if (text.isNotEmpty && !_value(value).toLowerCase().contains(text)) {
            return false;
          }
        }
      }
      return true;
    }).toList();

    final sort = schema.grid?.defaultSort;
    final sortField = sort?.fields.firstOrNull;
    if (sortField != null) {
      final descending = sort?.direction.toLowerCase() == 'desc';
      result.sort((left, right) {
        final comparison = _value(left[sortField])
            .toLowerCase()
            .compareTo(_value(right[sortField]).toLowerCase());
        return descending ? -comparison : comparison;
      });
    }
    return result;
  }

  int get _pageSize => (schema.grid?.pageSize ?? 20).clamp(1, 1000);

  int _pageCount(int total) => total == 0 ? 1 : (total / _pageSize).ceil();

  List<Map<String, dynamic>> _pageRows(List<Map<String, dynamic>> records) {
    final count = _pageCount(records.length);
    final page = _page.clamp(1, count);
    final start = (page - 1) * _pageSize;
    return records.skip(start).take(_pageSize).toList();
  }

  List<TrinaColumn> get columns => visibleFields
      .map(
        (field) => TrinaColumn(
          title: field.label.isEmpty ? field.name : field.label,
          field: field.name,
          type: field.type == 'number' || field.type == 'integer'
              ? TrinaColumnType.number()
              : TrinaColumnType.text(),
          readOnly: true,
        ),
      )
      .toList();

  List<TrinaRow<dynamic>> _rows(List<Map<String, dynamic>> records) => records
      .map(
        (record) => TrinaRow(
          cells: {
            for (final field in visibleFields)
              field.name: TrinaCell(
                value: record[field.name] is bool
                    ? (record[field.name] == true ? 'Yes' : 'No')
                    : record[field.name],
              ),
          },
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final records = filteredRows;
    final pageCount = _pageCount(records.length);
    final page = _page.clamp(1, pageCount);
    final pageRecords = _pageRows(records);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _toolbar(context, resultCount: records.length, page: page, pageCount: pageCount),
        const SizedBox(height: 12),
        Expanded(
          child: AppDataTable(
            title: widget.title,
            subtitle: widget.subtitle ?? '${records.length} records',
            columns: columns,
            rows: _rows(pageRecords),
            paginate: false,
            mobilePageSize: pageRecords.isEmpty ? 1 : pageRecords.length,
            mobilePageSizes: [pageRecords.isEmpty ? 1 : pageRecords.length],
            mobileRowKey: (row) => row.cells[schema.primaryKey ?? 'id']?.value
                .toString() ?? identityHashCode(row).toString(),
            onRowTap: widget.onRowTap == null
                ? null
                : (index) => widget.onRowTap!(pageRecords[index]),
            onRowEdit: widget.onRowEdit == null
                ? null
                : (index) => widget.onRowEdit!(pageRecords[index]),
          ),
        ),
      ],
    );
  }

  Widget _toolbar(
    BuildContext context, {
    required int resultCount,
    required int page,
    required int pageCount,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title ?? 'Records',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        widget.subtitle ?? '$resultCount records',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (!_searchExpanded)
                  IconButton(
                    tooltip: 'Search',
                    onPressed: quickSearchFields.isEmpty
                        ? null
                        : () => setState(() => _searchExpanded = true),
                    icon: const Icon(Icons.search),
                  ),
                IconButton(
                  tooltip: 'Filter',
                  onPressed: filters.isEmpty
                      ? null
                      : () => setState(
                            () => _filtersExpanded = !_filtersExpanded,
                          ),
                  icon: Icon(
                    _filtersExpanded
                        ? Icons.filter_alt
                        : Icons.filter_alt_outlined,
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (_searchExpanded) ...[
              const SizedBox(height: 8),
              _searchBar(context),
            ],
            if (_filtersExpanded && filters.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: filters.map(_filterWidget).toList(),
                ),
              ),
            ],
            const SizedBox(height: 8),
            _paginationHeader(
              context,
              resultCount: resultCount,
              page: page,
              pageCount: pageCount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _paginationHeader(
    BuildContext context, {
    required int resultCount,
    required int page,
    required int pageCount,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          resultCount == 0
              ? 'No records'
              : 'Page $page of $pageCount · $resultCount records',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Previous page',
          onPressed: page > 1
              ? () => setState(() => _page = page - 1)
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed: page < pageCount
              ? () => setState(() => _page = page + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _searchBar(BuildContext context) {
    final fields = <String>[
      _allSearchFields,
      ...quickSearchFields.where((field) => field != _allSearchFields),
    ];
    final selected = fields.contains(_selectedSearchField)
        ? _selectedSearchField
        : fields.first;

    return Row(
      children: [
        SizedBox(
          width: 190,
          child: DropdownButtonFormField<String>(
            initialValue: selected,
            decoration: const InputDecoration(
              labelText: 'Search in',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: fields
                .map(
                  (field) => DropdownMenuItem<String>(
                    value: field,
                    child: Text(
                      field == _allSearchFields ? 'All fields' : field,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedSearchField = value),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            autofocus: true,
            controller: _searchController,
            onChanged: (_) => setState(() => _page = 1),
            onSubmitted: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search ${selected == _allSearchFields ? 'all fields' : selected}',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Close search',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchExpanded = false);
                },
                icon: const Icon(Icons.close),
              ),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterWidget(Map<String, dynamic> filter) {
    final name = filter['field'].toString();
    final field = schema.fields.where((item) => item.name == name).firstOrNull;
    final label = filter['label']?.toString() ?? field?.label ?? name;
    if (field?.type == 'boolean') {
      return SizedBox(
        width: 170,
        child: DropdownButtonFormField<bool?>(
          initialValue: _boolFilters[name],
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem<bool?>(value: null, child: Text('All')),
            DropdownMenuItem<bool?>(value: true, child: Text('Yes')),
            DropdownMenuItem<bool?>(value: false, child: Text('No')),
          ],
          onChanged: (value) => setState(() {
            _boolFilters[name] = value;
            _page = 1;
          }),
        ),
      );
    }
    return SizedBox(
      width: 210,
      child: TextField(
        controller: _filterControllers[name],
        onChanged: (_) => setState(() => _page = 1),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.filter_alt_outlined),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
