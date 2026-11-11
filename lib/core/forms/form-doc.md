# Reactive Shadcn Form Engine

## 1. Overview

The Reactive Shadcn Form Engine is a reusable, metadata-driven form system built on:

- Flutter
- `reactive_forms`
- Dashcn/Shadcn UI components
- JSON or API-driven field metadata

The goal is to create a single form engine that can be used throughout the application.

Examples:

- Login
- Users
- Orders
- Products
- Customers
- Admin
- Metadata Modules
- Dynamic SaaS modules

Instead of manually creating a separate `FormGroup` and UI for every entity, forms are generated from `EntityMeta` and `FieldMeta`.

---

# 2. Architecture

Recommended structure:

```text
lib/
│
├── core/
│   └── widgets/
│       └── reactive_shadcn_form/
│           │
│           ├── entity_meta.dart
│           ├── entity_reactive_form.dart
│           ├── entity_form_field_factory.dart
│           ├── entity_form_grid.dart
│           ├── entity_staggered_form_grid.dart
│           │
│           ├── reactive_field_layout.dart
│           ├── reactive_shadcn_error.dart
│           ├── control_extensions.dart
│           │
│           └── fields/
│               ├── app_text_field.dart
│               ├── app_number_field.dart
│               ├── app_boolean_field.dart
│               ├── app_select_field.dart
│               ├── app_multiselect_field.dart
│               ├── app_date_field.dart
│               ├── app_date_range_field.dart
│               └── app_slider_field.dart
│
├── features/
│   ├── users/
│   ├── orders/
│   ├── products/
│   └── metadata/
│
└── ...
```

The main architecture is:

```text
JSON / API Schema
        │
        ▼
EntityMeta
        │
        ▼
FieldMeta
        │
        ▼
FormGroup
        │
        ▼
EntityReactiveForm
        │
        ▼
EntityFormGrid
        │
        ▼
EntityFormFieldFactory
        │
        ▼
Individual Field Widgets
        │
        ▼
Dashcn UI Components
```

---

# 3. Core Models

## 3.1 EntityMeta

`EntityMeta` represents the complete entity form.

Example:

```dart
final userMeta = EntityMeta(
  entityName: 'User',
  fields: [
    // Fields
  ],
);
```

It contains:

```dart
class EntityMeta {
  const EntityMeta({
    required this.entityName,
    required this.fields,
  });

  final String entityName;
  final List<FieldMeta<dynamic>> fields;
}
```

---

## 3.2 FieldMeta

Every form field is represented by `FieldMeta`.

Example:

```dart
FieldMeta<String>(
  name: 'email',
  label: 'Email',
  type: EntityFieldType.email,
  placeholder: 'Enter email',
  validationRules: {
    'required': true,
    'email': true,
  },
)
```

The important properties are:

| Property | Purpose |
|---|---|
| `name` | Form control name |
| `label` | Field label |
| `type` | Field type |
| `initialValue` | Default value |
| `editable` | Can user modify field |
| `placeholder` | Input placeholder |
| `validationRules` | Validation configuration |
| `options` | Select/dropdown options |
| `colSpan` | Responsive grid width |
| `rowSpan` | Grid vertical height |
| `features` | UI features |
| `visibleWhen` | Conditional visibility |
| `enabledWhen` | Conditional enable state |

---

# 4. Supported Field Types

```dart
enum EntityFieldType {
  text,
  email,
  password,
  phone,
  number,
  currency,
  boolean,
  date,
  dateRange,
  select,
  multiselect,
  textarea,
  slider,
}
```

## Field mapping

| Field Type | Widget |
|---|---|
| `text` | `AppTextField` |
| `email` | `AppTextField` |
| `password` | `AppTextField` |
| `phone` | `AppTextField` |
| `number` | `AppNumberField` |
| `currency` | `AppNumberField` |
| `boolean` | `AppBooleanField` |
| `date` | `AppDateField` |
| `dateRange` | `AppDateRangeField` |
| `select` | `AppSelectField` |
| `multiselect` | `AppMultiSelectField` |
| `textarea` | `AppTextField` |
| `slider` | `AppSliderField` |

---

# 5. Creating Forms

## 5.1 Create Mode

For creating a new record:

```dart
final form = meta.toFormGroup(
  mode: EntityMode.create,
);
```

The form uses:

```text
FieldMeta.initialValue
```

Example metadata:

```json
{
  "name": "status",
  "label": "Status",
  "type": "select",
  "initialValue": "active"
}
```

Result:

```text
status = active
```

---

## 5.2 Edit Mode

For editing an existing record:

```dart
final form = meta.toFormGroup(
  mode: EntityMode.edit,
  initialData: apiData,
);
```

Example:

```dart
final apiData = {
  'name': 'Pankaj Kumar',
  'email': 'pankaj@example.com',
  'status': 'active',
};
```

The API data populates the form.

---

## 5.3 View Mode

For displaying a record without allowing changes:

```dart
final form = meta.toFormGroup(
  mode: EntityMode.view,
  initialData: apiData,
);
```

All controls are disabled.

---

# 6. Value Priority

The form engine uses this priority:

```text
initialData
    │
    ▼
FieldMeta.initialValue
    │
    ▼
null
```

Example:

Schema:

```dart
FieldMeta(
  name: 'status',
  initialValue: 'active',
)
```

API data:

```dart
{
  'status': 'inactive'
}
```

Result:

```text
status = inactive
```

API data always overrides schema defaults.

---

# 7. JSON Schema

A complete example:

```json
{
  "entityName": "User",
  "fields": [
    {
      "name": "firstName",
      "label": "First Name",
      "type": "text",
      "placeholder": "Enter first name",
      "validationRules": {
        "required": true,
        "minLength": 2
      },
      "colSpan": {
        "mobile": 12,
        "tablet": 6,
        "desktop": 4
      }
    },
    {
      "name": "email",
      "label": "Email",
      "type": "email",
      "placeholder": "Enter email",
      "validationRules": {
        "required": true,
        "email": true
      },
      "features": {
        "showClearButton": true
      },
      "colSpan": {
        "mobile": 12,
        "tablet": 6,
        "desktop": 4
      }
    },
    {
      "name": "status",
      "label": "Status",
      "type": "select",
      "initialValue": "active",
      "options": [
        {
          "label": "Active",
          "value": "active"
        },
        {
          "label": "Inactive",
          "value": "inactive"
        }
      ],
      "colSpan": {
        "mobile": 12,
        "tablet": 6,
        "desktop": 4
      }
    }
  ]
}
```

---

# 8. Validation Rules

Validation is metadata-driven.

Example:

```json
{
  "validationRules": {
    "required": true,
    "minLength": 3,
    "maxLength": 100
  }
}
```

Supported validation rules:

```text
required
requiredTrue
email
number
min
max
minLength
maxLength
pattern
creditCard
equals
contains
oneOf
mustMatch
```

Example:

```dart
validationRules: {
  'required': true,
  'email': true,
}
```

---

# 9. Form Field Factory

The factory decides which widget to display.

```dart
class EntityFormFieldFactory {
  static Widget build({
    required FieldMeta<dynamic> field,
  }) {
    switch (field.type) {
      case EntityFieldType.text:
      case EntityFieldType.email:
      case EntityFieldType.password:
      case EntityFieldType.phone:
      case EntityFieldType.textarea:
        return AppTextField(field: field);

      case EntityFieldType.number:
      case EntityFieldType.currency:
        return AppNumberField(field: field);

      case EntityFieldType.boolean:
        return AppBooleanField(field: field);

      case EntityFieldType.select:
        return AppSelectField(field: field);

      case EntityFieldType.multiselect:
        return AppMultiSelectField(field: field);

      case EntityFieldType.date:
        return AppDateField(field: field);

      case EntityFieldType.dateRange:
        return AppDateRangeField(field: field);

      case EntityFieldType.slider:
        return AppSliderField(field: field);
    }
  }
}
```

The factory keeps form pages clean.

Pages do not need to know which widget is used for each field.

---

# 10. EntityReactiveForm

The reusable form component should be the main entry point.

Recommended API:

```dart
EntityReactiveForm(
  metadata: userMeta,
  mode: EntityMode.edit,
  initialData: userData,
  onSubmit: (value) {
    // API update
  },
)
```

Recommended properties:

```dart
class EntityReactiveForm extends StatefulWidget {
  const EntityReactiveForm({
    super.key,
    required this.metadata,
    this.mode = EntityMode.create,
    this.initialData,
    this.onSubmit,
    this.submitLabel = 'Save',
  });

  final EntityMeta metadata;
  final EntityMode mode;
  final Map<String, dynamic>? initialData;

  final ValueChanged<Map<String, dynamic>>? onSubmit;

  final String submitLabel;
}
```

---

# 11. Form Lifecycle

The recommended lifecycle is:

```text
Widget created
      │
      ▼
EntityMeta received
      │
      ▼
initialData received
      │
      ▼
toFormGroup()
      │
      ▼
ReactiveForm
      │
      ▼
Field widgets
      │
      ▼
User edits data
      │
      ▼
Reactive validation
      │
      ▼
Submit
      │
      ▼
API request
```

---

# 12. Basic EntityReactiveForm Implementation

Example:

```dart
class EntityReactiveForm extends StatefulWidget {
  const EntityReactiveForm({
    super.key,
    required this.metadata,
    this.mode = EntityMode.create,
    this.initialData,
    this.onSubmit,
  });

  final EntityMeta metadata;
  final EntityMode mode;
  final Map<String, dynamic>? initialData;

  final ValueChanged<Map<String, dynamic>>? onSubmit;

  @override
  State<EntityReactiveForm> createState() =>
      _EntityReactiveFormState();
}

class _EntityReactiveFormState
    extends State<EntityReactiveForm> {
  late FormGroup _form;

  @override
  void initState() {
    super.initState();

    _form = widget.metadata.toFormGroup(
      mode: widget.mode,
      initialData: widget.initialData,
    );
  }

  @override
  void didUpdateWidget(
    EntityReactiveForm oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.metadata != widget.metadata ||
        oldWidget.initialData != widget.initialData ||
        oldWidget.mode != widget.mode) {
      _form.dispose();

      _form = widget.metadata.toFormGroup(
        mode: widget.mode,
        initialData: widget.initialData,
      );
    }
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: _form,
      child: Column(
        children: [
          EntityFormGrid(
            items: widget.metadata.fields
                .map(
                  (field) => EntityFormGridItem(
                    field: field,
                    child:
                        EntityFormFieldFactory.build(
                      field: field,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
```

---

# 13. Responsive Grid

The recommended grid uses 12 columns.

Example:

```text
Mobile
────────────────────────

[       First Name       ]

[       Last Name        ]

[         Email          ]


Tablet
────────────────────────

[   First Name   ][ Last Name ]

[           Email            ]


Desktop
──────────────────────────────

[ First ][ Last ][ Email ]

[       Description       ]
```

---

# 14. colSpan

Example:

```json
{
  "name": "firstName",
  "colSpan": {
    "mobile": 12,
    "tablet": 6,
    "desktop": 4
  }
}
```

This means:

| Device | Columns |
|---|---:|
| Mobile | 12 |
| Tablet | 6 |
| Desktop | 4 |

---

# 15. rowSpan

Example:

```json
{
  "name": "description",
  "type": "textarea",
  "colSpan": {
    "mobile": 12,
    "tablet": 12,
    "desktop": 6
  },
  "rowSpan": 2
}
```

Recommended use cases:

- Large textarea
- Image uploader
- Rich text editor
- JSON editor
- Metadata editor

For true `rowSpan`, use:

```dart
EntityStaggeredFormGrid
```

For normal forms without vertical spanning, use:

```dart
EntityFormGrid
```

---

# 16. Conditional Visibility

A field can depend on another field.

Example:

```json
{
  "name": "companyName",
  "label": "Company Name",
  "type": "text",
  "visibleWhen": {
    "field": "accountType",
    "equals": "business"
  }
}
```

Result:

```text
Account Type = Individual
→ Company Name hidden

Account Type = Business
→ Company Name visible
```

---

# 17. Conditional Enable

Example:

```json
{
  "name": "discount",
  "label": "Discount",
  "type": "number",
  "enabledWhen": {
    "field": "allowDiscount",
    "equals": true
  }
}
```

Result:

```text
Allow Discount = false
→ Discount disabled

Allow Discount = true
→ Discount enabled
```

---

# 18. Field Features

Your Dashcn input already supports features.

Example:

```json
{
  "name": "email",
  "type": "email",
  "features": {
    "showClearButton": true,
    "showCopyButton": true
  }
}
```

Password:

```json
{
  "name": "password",
  "type": "password"
}
```

Your field implementation automatically adds:

```dart
InputPasswordToggleFeature()
```

---

# 19. Form Submission

Recommended submission flow:

```dart
void submit() {
  _form.markAllAsTouched();

  if (!_form.valid) {
    return;
  }

  final value = _form.value;

  widget.onSubmit?.call(value);
}
```

Usage:

```dart
EntityReactiveForm(
  metadata: userMeta,
  mode: EntityMode.edit,
  initialData: userData,
  onSubmit: (value) {
    context.read<UserBloc>().add(
      UpdateUser(
        userId: userId,
        data: value,
      ),
    );
  },
)
```

---

# 20. BLoC Integration

The form engine should not directly depend on your BLoC.

Correct architecture:

```text
UserBloc
    │
    ▼
UserPage
    │
    ├── loading
    ├── error
    └── data
          │
          ▼
EntityReactiveForm
          │
          ├── metadata
          ├── initialData
          └── onSubmit
                 │
                 ▼
              UserBloc
```

Example:

```dart
BlocBuilder<UserBloc, UserState>(
  builder: (context, state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return EntityReactiveForm(
      metadata: state.formMeta,
      mode: EntityMode.edit,
      initialData: state.userData,
      onSubmit: (data) {
        context.read<UserBloc>().add(
          UpdateUser(
            data: data,
          ),
        );
      },
    );
  },
);
```

The reusable form engine remains independent of:

- BLoC
- Repository
- API
- Database
- Feature modules

---

# 21. Metadata Module Example

For your Metadata Designer:

```dart
EntityReactiveForm(
  metadata: metadataModuleMeta,
  mode: EntityMode.edit,
  initialData: {
    'moduleId': module.moduleId,
    'moduleName': module.name,
    'schema': module.schema,
    'tableName': module.tableName,
  },
  onSubmit: (data) {
    context.read<MetadataBloc>().add(
      UpdateMetadataModule(
        data: data,
      ),
    );
  },
)
```

---

# 22. User Module Example

```dart
EntityReactiveForm(
  metadata: userMeta,
  mode: EntityMode.create,
  onSubmit: (data) {
    context.read<UserBloc>().add(
      CreateUser(data),
    );
  },
)
```

---

# 23. Product Module Example

```dart
EntityReactiveForm(
  metadata: productMeta,
  mode: EntityMode.edit,
  initialData: product.toJson(),
  onSubmit: (data) {
    context.read<ProductBloc>().add(
      UpdateProduct(
        productId: product.id,
        data: data,
      ),
    );
  },
)
```

---

# 24. Important Design Rules

## Rule 1: Pages should not build individual fields

Avoid:

```dart
TextField(...)
TextField(...)
DropdownButton(...)
Checkbox(...)
```

Instead:

```dart
EntityReactiveForm(
  metadata: metadata,
)
```

---

## Rule 2: Field widgets should not know the API

Avoid:

```text
AppTextField
    ↓
API Call
```

Correct:

```text
AppTextField
    ↓
FormControl
    ↓
EntityReactiveForm
    ↓
onSubmit
    ↓
BLoC
    ↓
Repository
    ↓
API
```

---

## Rule 3: BLoC should not contain FormGroup

Avoid:

```text
Bloc
  └── FormGroup
```

Recommended:

```text
Bloc
  └── Metadata/Data

Widget
  └── FormGroup
```

The `FormGroup` belongs to the UI lifecycle and should be disposed with the widget.

---

## Rule 4: Metadata should be reusable

The same metadata can power:

```text
Form
Grid
Details View
Filters
Search
Export
Validation
API Payload
```

This is particularly useful for your metadata-driven SaaS architecture.

---

# 25. Recommended Future Improvements

## Phase 1 — Current

- [x] JSON metadata
- [x] Reactive Forms
- [x] Validation
- [x] Create/Edit/View modes
- [x] Initial API data
- [x] Dashcn fields
- [x] Responsive colSpan
- [x] rowSpan support

## Phase 2 — Recommended Next

- [ ] API option sources
- [ ] Dependent dropdowns
- [ ] Async validation
- [ ] Field-level permissions
- [ ] Sections and tabs
- [ ] Form-level validation
- [ ] Read-only field display
- [ ] File upload

## Phase 3 — Advanced

- [ ] Nested `FormGroup`
- [ ] `FormArray`
- [ ] Repeating sections
- [ ] Address component
- [ ] Rich text editor
- [ ] JSON editor
- [ ] Formula/calculated fields
- [ ] Auto-save
- [ ] Draft support

---

# 26. Recommended Final Flow

```text
                    API / JSON
                        │
                        ▼
                  EntityMeta
                        │
                        ▼
                EntityReactiveForm
                        │
                 ┌──────┴──────┐
                 ▼             ▼
            FormGroup       Form Grid
                 │             │
                 └──────┬──────┘
                        ▼
              Field Widget Factory
                        │
       ┌────────────────┼────────────────┐
       ▼                ▼                ▼
   Text Field       Select Field     Date Field
       │                │                │
       └────────────────┼────────────────┘
                        ▼
                 Reactive Forms
                        │
                        ▼
                  Validation
                        │
                        ▼
                     Submit
                        │
                        ▼
                      BLoC
                        │
                        ▼
                   Repository
                        │
                        ▼
                       API
```

# Final Recommendation

For your application, the main reusable component should always be:

```dart
EntityReactiveForm(
  metadata: meta,
  mode: EntityMode.edit,
  initialData: data,
  onSubmit: onSubmit,
)
```

Everything else should remain internal to the form engine.

This will give your Flutter SaaS a consistent architecture across **Metadata Designer, Users, Orders, Products, Admin, and all future dynamically generated modules**.