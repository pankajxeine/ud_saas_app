// import 'dart:convert';

import 'package:reactive_forms/reactive_forms.dart';
import '../validation/entity_validation_factory.dart';

import 'field_meta.dart';
import 'entity_grid_layout.dart';
import '../factory/entity_form_control_factory.dart';

enum EntityMode { view, edit, create }

enum EntityFormLayoutMode { basic, tabs, stepper }

enum EntityFormStepperOrientation { horizontal, vertical }

EntityFormStepperOrientation parseStepperOrientation(dynamic value) {
  return value?.toString().toLowerCase() == 'vertical'
      ? EntityFormStepperOrientation.vertical
      : EntityFormStepperOrientation.horizontal;
}

EntityFormLayoutMode parseFormLayout(dynamic value) {
  switch (value?.toString().toLowerCase()) {
    case 'tabs':
      return EntityFormLayoutMode.tabs;
    case 'stepper':
      return EntityFormLayoutMode.stepper;
    case 'basic':
    default:
      return EntityFormLayoutMode.basic;
  }
}

class EntityFormSection {
  const EntityFormSection({
    required this.id,
    required this.title,
    this.icon,
    this.permission = const {},
  });

  final String id;
  final String title;
  final String? icon;
  final Map<String, String> permission;

  factory EntityFormSection.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? 'section';
    final rawPermission = json['permission'];
    final permission = rawPermission is Map
        ? rawPermission.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          )
        : {
            'read': '$id.read',
            'edit': '$id.edit',
            'delete': '$id.delete',
            'create': '$id.create',
          };

    return EntityFormSection(
      id: id,
      title: json['title']?.toString() ?? id,
      icon: json['icon']?.toString().trim().isEmpty == true
          ? null
          : json['icon']?.toString().trim(),
      permission: permission,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    if (icon != null && icon!.isNotEmpty) 'icon': icon,
    'permission': permission,
  };
}

class EntityMeta {
  const EntityMeta({
    required this.entityName,
    required this.fields,
    this.layout = const EntityGridLayout(),
    this.formLayout = EntityFormLayoutMode.basic,
    this.stepperOrientation = EntityFormStepperOrientation.horizontal,
    this.sections = const [],
  });

  final String entityName;
  final EntityGridLayout layout;
  final List<FieldMeta<dynamic>> fields;
  final EntityFormLayoutMode formLayout;
  final EntityFormStepperOrientation stepperOrientation;
  final List<EntityFormSection> sections;

  List<FieldMeta<dynamic>> fieldsForSection(String sectionId) {
    return fields
        .where((field) => field.section == sectionId)
        .toList(growable: false);
  }

  /// Creates a Reactive Forms [FormGroup].
  ///
  /// Value priority:
  ///
  /// 1. [initialData] value (Edit/View API data)
  /// 2. [FieldMeta.initialValue] (schema default)
  /// 3. null
  ///
  FormGroup toFormGroup({
    EntityMode mode = EntityMode.create,
    Map<String, dynamic>? initialData,
  }) {
    return EntityFormControlFactory.createFormGroup(
      fields: fields,
      initialData: initialData,
      mode: mode,
      validatorBuilder: (field) {
        return buildValidators(field.validationRules);
      },
    );
  }

  AbstractControl<dynamic> _createControl(
    FieldMeta<dynamic> field,
    dynamic value, {
    required EntityMode mode,
  }) {
    final validators = buildValidators(field.validationRules);

    // ============================================================
    // NESTED OBJECT
    // JSON Object -> FormGroup
    // ============================================================
    if (field.type == EntityFieldType.group) {
      final groupData = value is Map
          ? Map<String, dynamic>.from(value)
          : <String, dynamic>{};

      final group = _createNestedFormGroup(
        field.fields,
        initialData: groupData,
        mode: mode,
      );

      if (mode == EntityMode.view || !field.editable) {
        group.markAsDisabled();
      }

      return group;
    }

    // ============================================================
    // ARRAY
    // JSON Array -> FormArray
    // ============================================================
    if (field.type == EntityFieldType.array) {
      final values = value is Iterable ? value.toList() : <dynamic>[];

      final controls = values.map((item) {
        // For now generic array item support.
        //
        // Later you can support:
        // field.itemMeta
        // field.itemType
        return FormControl<dynamic>(value: item);
      }).toList();

      final array = FormArray<dynamic>(controls);

      if (mode == EntityMode.view || !field.editable) {
        array.markAsDisabled();
      }

      return array;
    }

    // ============================================================
    // PRIMITIVE FIELD TYPES
    // ============================================================

    final normalizedValue = _normalizeFieldValue(field: field, value: value);

    final AbstractControl<dynamic> control;

    switch (field.type) {
      // ----------------------------------------------------------
      // String controls
      // ----------------------------------------------------------
      case EntityFieldType.text:
      case EntityFieldType.email:
      case EntityFieldType.password:
      case EntityFieldType.phone:
      case EntityFieldType.textarea:
      case EntityFieldType.select:
        control = FormControl<String>(
          value: normalizedValue as String?,
          validators: validators,
        );
        break;

      // ----------------------------------------------------------
      // Number controls
      // ----------------------------------------------------------
      case EntityFieldType.number:
      case EntityFieldType.currency:
        control = FormControl<num>(
          value: normalizedValue as num?,
          validators: validators,
        );
        break;

      // ----------------------------------------------------------
      // Boolean
      // ----------------------------------------------------------
      case EntityFieldType.boolean:
        control = FormControl<bool>(
          value: normalizedValue as bool? ?? false,
          validators: validators,
        );
        break;

      // ----------------------------------------------------------
      // Multi-select
      // ----------------------------------------------------------
      case EntityFieldType.multiselect:
        control = FormControl<List<String>>(
          value: normalizedValue is Iterable
              ? normalizedValue.map((e) => e.toString()).toList()
              : <String>[],
          validators: validators,
        );
        break;

      // ----------------------------------------------------------
      // Date / Time
      // ----------------------------------------------------------
      case EntityFieldType.time:
      case EntityFieldType.date:
        control = FormControl<DateTime>(
          value: normalizedValue as DateTime?,
          validators: validators,
        );
        break;

      // ----------------------------------------------------------
      // Date range
      // ----------------------------------------------------------
      case EntityFieldType.dateRange:
        control = FormControl<dynamic>(
          value: normalizedValue,
          validators: validators,
        );
        break;

      // ----------------------------------------------------------
      // Slider
      // ----------------------------------------------------------
      case EntityFieldType.slider:
        control = FormControl<double>(
          value: normalizedValue as double?,
          validators: validators,
        );
        break;

      // These are already handled above.
      case EntityFieldType.group:
      case EntityFieldType.custom:
      case EntityFieldType.array:
        throw StateError(
          'Container field type ${field.type} '
          'must be handled before the primitive switch.',
        );
    }

    // ============================================================
    // APPLY MODE / EDITABLE STATE
    // ============================================================
    if (mode == EntityMode.view || !field.editable) {
      control.markAsDisabled();
    }

    return control;
  }

  FormGroup _createNestedFormGroup(
    List<FieldMeta<dynamic>> fields, {
    required EntityMode mode,
    Map<String, dynamic>? initialData,
  }) {
    final controls = <String, AbstractControl<dynamic>>{};

    for (final field in fields) {
      final value = initialData != null && initialData.containsKey(field.name)
          ? initialData[field.name]
          : field.initialValue;

      controls[field.name] = _createControl(field, value, mode: mode);
    }

    return FormGroup(controls);
  }

  /// Normalizes API data to a suitable value for the field type.
  dynamic _normalizeFieldValue({
    required FieldMeta<dynamic> field,
    dynamic value,
  }) {
    if (value == null) {
      return null;
    }

    switch (field.type) {
      // ==========================================================
      // String
      // ==========================================================
      case EntityFieldType.text:
      case EntityFieldType.email:
      case EntityFieldType.password:
      case EntityFieldType.phone:
      case EntityFieldType.textarea:
        return value.toString();

      // ==========================================================
      // Select
      // Keep original value because select might use
      // String, int, or object identifiers.
      // ==========================================================
      case EntityFieldType.select:
        return value;

      // ==========================================================
      // Number
      // ==========================================================
      case EntityFieldType.number:
      case EntityFieldType.currency:
        if (value is num) {
          return value;
        }

        return num.tryParse(value.toString());

      // ==========================================================
      // Boolean
      // ==========================================================
      case EntityFieldType.boolean:
        if (value is bool) {
          return value;
        }

        final normalized = value.toString().trim().toLowerCase();

        return normalized == 'true' || normalized == '1';

      // ==========================================================
      // Slider
      // ==========================================================
      case EntityFieldType.slider:
        if (value is num) {
          return value.toDouble();
        }

        return double.tryParse(value.toString());

      // ==========================================================
      // Multi-select
      // ==========================================================
      case EntityFieldType.multiselect:
        if (value is Iterable) {
          return value.map((item) => item.toString()).toList();
        }

        return <String>[];

      // ==========================================================
      // Date / Time
      // ==========================================================
      case EntityFieldType.time:
      case EntityFieldType.date:
        if (value is DateTime) {
          return value;
        }

        return DateTime.tryParse(value.toString());

      // ==========================================================
      // Date Range
      // ==========================================================
      case EntityFieldType.dateRange:
        return value;

      // ==========================================================
      // Containers are handled separately.
      // ==========================================================
      case EntityFieldType.group:
      case EntityFieldType.array:
        return value;
      case EntityFieldType.custom:
        return value;
    }
  }
}
