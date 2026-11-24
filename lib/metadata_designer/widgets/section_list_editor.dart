import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ud_sass_app/core/forms/forms.dart';
import 'package:ud_sass_app/core/forms/helper/entity_meta_helper.dart';
import 'package:ud_sass_app/core/forms/models/entity_meta.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../models/metadata_sections.dart';

class SectionsEditor extends StatefulWidget {
  const SectionsEditor({
    super.key,
    this.sections = const [],
    this.mode = EntityMode.edit,
  });

  final List<MetadataSection> sections;
  final EntityMode mode;

  static const Map<String, dynamic> _schema = {
    'name': 'section',
    'label': 'Section',
    'type': 'group',
    'fields': [
      {
        'name': 'id',
        'label': 'Section Id',
        'type': 'text',
        'widget': 'text',
        'required': true,
      },
      {
        'name': 'title',
        'label': 'Title',
        'type': 'text',
        'widget': 'text',
        'required': true,
      },
      {
        'name': 'icon',
        'label': 'Icon name',
        'type': 'text',
        'widget': 'text',
        'placeholder': 'home, person, settings...',
      },
      {
        'name': 'permission',
        'label': 'Permissions',
        'type': 'group',
        'fields': [
          {'name': 'read', 'label': 'Read permission', 'type': 'text'},
          {'name': 'create', 'label': 'Create permission', 'type': 'text'},
          {'name': 'update', 'label': 'Update permission', 'type': 'text'},
          {'name': 'delete', 'label': 'Delete permission', 'type': 'text'},
        ],
      },
    ],
  };

  static final EntityMeta metadata = entityMetaFromJson(_schema);

  @override
  State<SectionsEditor> createState() => _SectionsEditorState();
}

class _SectionsEditorState extends State<SectionsEditor> {
  static const _newSectionKey = '__new_section__';

  late List<MetadataSection> _currentSections;
  String? _selectedSectionKey;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _setSections(widget.sections);
  }

  @override
  void didUpdateWidget(covariant SectionsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sections != widget.sections) _setSections(widget.sections);
  }

  void _setSections(List<MetadataSection> sections) {
    final previousSelection = _selectedSectionKey;
    _currentSections = List<MetadataSection>.from(sections);
    _isCreating = false;
    _selectedSectionKey =
        _currentSections.any((section) => section.id == previousSelection)
        ? previousSelection
        : (_currentSections.isNotEmpty ? _currentSections.first.id : null);
  }

  MetadataSection? get _selectedSection {
    if (_isCreating || _selectedSectionKey == null) return null;
    for (final section in _currentSections) {
      if (section.id == _selectedSectionKey) return section;
    }
    return null;
  }

  Map<String, dynamic> get _initialData => _isCreating
      ? {
          'id': '',
          'title': '',
          'icon': '',
          'permission': {'read': '', 'create': '', 'update': '', 'delete': ''},
        }
      : (_selectedSection?.toJson() ?? {});

  void _addSection() {
    setState(() {
      _isCreating = true;
      _selectedSectionKey = _newSectionKey;
    });
  }

  Future<void> _saveSection(Map<String, dynamic> formData) async {
    final section = MetadataSection.fromJson(formData);
    if (section.id.isEmpty) return;

    final updatedSections = List<MetadataSection>.from(_currentSections);
    if (_isCreating) {
      updatedSections.add(section);
    } else {
      final index = updatedSections.indexWhere(
        (item) => item.id == _selectedSectionKey,
      );
      if (index < 0) return;
      updatedSections[index] = section;
    }

    setState(() {
      _currentSections = updatedSections;
      _isCreating = false;
      _selectedSectionKey = section.id;
    });

    if (!mounted) return;
    context.read<MetadataBloc>().add(
      UpdateRootProperty(
        'sections',
        _currentSections.map((item) => item.toJson()).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSection = _isCreating || _selectedSection != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              return Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _isCreating ? null : _selectedSectionKey,
                      hint: const Text('Select section'),
                      items: _currentSections
                          .map(
                            (section) => DropdownMenuItem<String>(
                              value: section.id,
                              child: Text(
                                section.title.isEmpty
                                    ? section.id
                                    : section.title,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedSectionKey = value;
                          _isCreating = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isMobile)
                    IconButton.filled(
                      onPressed: _addSection,
                      tooltip: 'Add section',
                      icon: const Icon(Icons.add),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _addSection,
                      icon: const Icon(Icons.add),
                      label: const Text('Add section'),
                    ),
                ],
              );
            },
          ),
        ),
        const Divider(),
        Expanded(
          child: hasSection
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: AppReactiveForm(
                    key: ValueKey(
                      'section-$_selectedSectionKey-${jsonEncode(_initialData)}',
                    ),
                    meta: SectionsEditor.metadata,
                    mode: _isCreating ? EntityMode.create : widget.mode,
                    initialData: _initialData,
                    onSubmit: _saveSection,
                  ),
                )
              : const Center(child: Text('No sections available')),
        ),
      ],
    );
  }
}

// Backwards-compatible name for existing callers.
class SectionListEditor extends SectionsEditor {
  const SectionListEditor({super.key, super.sections, super.mode});
}
