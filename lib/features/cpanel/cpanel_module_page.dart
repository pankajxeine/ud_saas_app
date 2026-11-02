import 'package:flutter/material.dart' hide Theme;
import 'package:ud_sass_app/core/navigation/app_navigation.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import '../../core/api/rest_api.dart';
import '../../core/config/environment.dart';
import '../../core/widgets/common/common_widgets.dart';
import 'cpanel_catalog.dart';
import 'cpanel_data_helpers.dart';
import 'widgets/cpanel_widgets.dart';

class CpanelModulePage extends StatefulWidget {
  const CpanelModulePage({super.key, required this.moduleSlug});

  final String moduleSlug;

  @override
  State<CpanelModulePage> createState() => _CpanelModulePageState();
}

class _CpanelModulePageState extends State<CpanelModulePage> {
  static const _pageSize = 20;
  final _searchController = TextEditingController();
  int _page = 1;
  int? _total;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _rows = const [];

  CpanelFeature? get _feature {
    final category = _category;
    if (category == null) return null;
    for (final group in category.groups) {
      for (final feature in group.features) {
        if (feature.slug == widget.moduleSlug) return feature;
      }
    }
    return null;
  }

  CpanelCategory? get _category {
    for (final category in cpanelCategories) {
      if (category.groups.any(
        (group) =>
            group.features.any((feature) => feature.slug == widget.moduleSlug),
      )) {
        return category;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (_feature case final feature? when !feature.sensitive) {
      _loadPage();
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPage() async {
    final feature = _feature;
    if (feature == null || feature.sensitive) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await RestApi(baseUrl: ProfileConstants.api)
          .get<dynamic>(
            feature.endpoint,
            queryParams: {'page': _page, 'limit': _pageSize},
          );
      final result = parseCpanelRows(response);
      if (!mounted) return;
      setState(() {
        _rows = result.rows;
        _total = result.total;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final feature = _feature;
    final category = _category;
    if (feature == null || category == null) {
      return const AppNotFoundPage(title: 'Module not found');
    }

    return AppPageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CpanelBreadcrumb(category: category, current: feature.title),
          const SizedBox(height: 18),
          AppPageHeading(
            eyebrow: category.title.toUpperCase(),
            title: feature.title,
            description: feature.description,
            icon: feature.icon,
            accent: category.accent,
            trailing: Button(
              variant: ButtonVariant.outline,
              onPressed: () => context.go(category.path),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, size: 18),
                  SizedBox(width: 8),
                  Text('Back to category'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (feature.sensitive)
            CpanelSensitiveNotice(feature: feature)
          else
            CpanelModuleDataPanel(
              feature: feature,
              loading: _loading,
              error: _error,
              rows: _filteredRows,
              total: _total,
              page: _page,
              pageSize: _pageSize,
              searchController: _searchController,
              onSearchChanged: () => setState(() {}),
              onPrevious: _page > 1 ? () => _changePage(_page - 1) : null,
              onNext: _canAdvance ? () => _changePage(_page + 1) : null,
              onRetry: _loadPage,
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredRows {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _rows;
    return _rows
        .where(
          (row) => row.values.any(
            (value) => value.toString().toLowerCase().contains(query),
          ),
        )
        .toList();
  }

  bool get _canAdvance =>
      _total == null ? _rows.length == _pageSize : _page * _pageSize < _total!;

  Future<void> _changePage(int nextPage) async {
    setState(() => _page = nextPage);
    await _loadPage();
  }
}
