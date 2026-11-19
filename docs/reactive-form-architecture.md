# Reactive Form Architecture

This document explains how consumers can use the metadata-driven reactive form system in `lib/core/forms`.

The form system separates form definition, control creation, validation, and rendering. A consumer supplies an `EntityMeta` object directly or converts a JSON Schema into `EntityMeta`; `AppReactiveForm` then creates and renders the form automatically.

## Architecture

```text
JSON Schema / metadata JSON
          |
          v
field_meta_helper.dart
          |
          v
EntityMeta + FieldMeta
          |
          v
EntityFormControlFactory
          |
          v
Reactive FormGroup / FormControl / FormArray
          |
          v
AppReactiveForm
          |
          +--> EntityFormRenderer
          +--> EntityFormGroup
          +--> EntityFormArray
          +--> EntityFieldWidgetRegistry
          +--> EntityValidationFactory
```

### Main components

| Component | Responsibility |
| --- | --- |
| `EntityMeta` | Describes an entity, its fields, layout mode, and sections. |
| `FieldMeta` | Describes one field, its type, widget, options, nested fields, and validation rules. |
| `entityMetaFromJsonSchema` | Converts a JSON Schema object into `EntityMeta`. |
| `EntityFormControlFactory` | Creates nested `FormGroup`, `FormControl`, and `FormArray` controls. |
| `AppReactiveForm` | Consumer-facing form widget. It creates the form, renders it, validates it, and submits values. |
| `EntityFieldWidgetRegistry` | Maps widget names such as `text`, `select`, `multiselect`, and `reference` to Flutter widgets. |
| `EntityCustomValidatorRegistry` | Registers application-specific synchronous and asynchronous validators. |
| `EntityValidationFactory` | Converts configured validation rules into `reactive_forms` validators. |

## Consumer setup

Import the generic form and the JSON Schema converter:

```dart
import 'package:flutter/material.dart';
import 'package:ud_sass_app/core/forms/app_reactive_form.dart';
import 'package:ud_sass_app/core/forms/helper/field_meta_helper.dart';
import 'package:ud_sass_app/core/forms/models/entity_meta.dart';

class AccountFormPage extends StatelessWidget {
  const AccountFormPage({super.key});

  static final EntityMeta meta = entityMetaFromJsonSchema(accountSchema);

  @override
  Widget build(BuildContext context) {
    return AppReactiveForm(
      meta: meta,
      mode: EntityMode.create,
      onSubmit: (data) async {
        // Send `data` to the API.
        debugPrint(data.toString());
      },
    );
  }
}
```

`AppReactiveForm` accepts:

- `meta`: required `EntityMeta` definition.
- `mode`: `create`, `edit`, or `view`.
- `initialData`: API data used to initialize controls.
- `registry`: optional field widget registry override.
- `customValidators`: optional custom validator registry.
- `onSubmit`: callback receiving the validated form value.

## JSON Schema format

The converter supports standard JSON Schema types and application UI extensions.

```dart
const accountSchema = <String, dynamic>{
  'title': 'Account',
  'type': 'object',
  'layout': {
    'mode': 'tabs', // basic, tabs, or stepper
    'sections': [
      {
        'id': 'general',
        'title': 'General',
        'fields': ['name', 'email'],
      },
      {
        'id': 'contacts',
        'title': 'Contacts',
        'fields': ['contacts'],
      },
    ],
  },
  'properties': {
    'name': {
      'title': 'Account Name',
      'type': 'string',
      'widget': 'text',
      'minLength': 2,
      'maxLength': 100,
    },
    'email': {
      'title': 'Email',
      'type': 'string',
      'format': 'email',
      'widget': 'email',
    },
    'contacts': {
      'title': 'Contacts',
      'type': 'array',
      'widget': 'array',
      'minItems': 1,
      'items': {
        'type': 'object',
        'properties': {
          'firstName': {'type': 'string', 'title': 'First name'},
          'phone': {'type': 'string', 'title': 'Phone'},
        },
        'required': ['firstName'],
      },
    },
  },
  'required': ['name', 'email'],
};
```

### Supported JSON Schema mappings

| JSON Schema | Form behavior |
| --- | --- |
| `string` | Text control |
| `string` + `format: email` | Email validation |
| `string` + `format: date-time` | Date control |
| `integer` / `number` | Numeric control |
| `boolean` | Switch/checkbox control |
| `object` | Nested group/card |
| `array` with object items | Repeating group array |
| `array` with enum items | Multiselect control |
| `enum` | Select options |
| `const` | Equals validation |
| `anyOf` | OR-composed validation |
| `minLength`, `maxLength`, `pattern` | String validators |
| `minimum`, `maximum` | Numeric validators |
| `minItems`, `maxItems` | Array length validators |
| `uniqueItems` | Unique array item validation |

## Field metadata shape

When metadata is already available instead of JSON Schema, consumers can construct `FieldMeta` or use the metadata JSON parser.

```json
{
  "name": "account_id",
  "label": "Account Id",
  "type": "text",
  "format": "string",
  "widget": "reference",
  "reference": {
    "table": "crm_account",
    "column": "account_id",
    "lookup": {
      "endpoint": "/crm_account",
      "strategy": "remote",
      "valueField": "account_id",
      "displayField": "name"
    }
  },
  "validationRules": {
    "required": true
  },
  "visibility": {
    "show": ["create", "edit", "table", "detail"],
    "required": ["create", "edit"],
    "readOnly": []
  }
}
```

`reference` fields use the select renderer by default. Applications that need remote lookup behavior should override the `reference` widget builder and load options from the configured endpoint.

## Form layouts

### Basic layout

```dart
const layout = {
  'mode': 'basic',
};
```

All fields are displayed in one card. Groups and arrays render as nested sections inside that card.

### Tabs

```dart
const layout = {
  'mode': 'tabs',
  'sections': [
    {'id': 'profile', 'title': 'Profile', 'fields': ['name', 'email']},
    {'id': 'settings', 'title': 'Settings', 'fields': ['enabled']},
  ],
};
```

### Stepper

```dart
const layout = {
  'mode': 'stepper',
  'sections': [
    {'id': 'profile', 'title': 'Profile', 'fields': ['name', 'email']},
    {'id': 'address', 'title': 'Address', 'fields': ['address']},
  ],
};
```

Sections can contain primitive fields, groups, or arrays. The form remains one reactive `FormGroup`, so validation and submission work consistently across layouts.

## Create, edit, and view forms

### Create

```dart
AppReactiveForm(
  meta: AccountFormPage.meta,
  mode: EntityMode.create,
  onSubmit: createAccount,
)
```

### Edit

```dart
AppReactiveForm(
  meta: AccountFormPage.meta,
  mode: EntityMode.edit,
  initialData: accountFromApi,
  onSubmit: updateAccount,
)
```

### View

```dart
AppReactiveForm(
  meta: AccountFormPage.meta,
  mode: EntityMode.view,
  initialData: accountFromApi,
)
```

In view mode controls are disabled and the save action is hidden. Field-level `editable` configuration can also disable an individual field.

## Groups and arrays

An object property creates a nested `FormGroup`:

```dart
'address': {
  'type': 'object',
  'title': 'Address',
  'properties': {
    'city': {'type': 'string'},
    'postalCode': {'type': 'string'},
  },
}
```

An array of objects creates a repeating group section:

```dart
'contacts': {
  'type': 'array',
  'items': {
    'type': 'object',
    'properties': {
      'name': {'type': 'string'},
      'email': {'type': 'string', 'format': 'email'},
    },
  },
}
```

An array of primitive values renders repeatable primitive controls. An array whose items contain `enum` values becomes a multiselect field.

## Built-in validation

The validation factory supports:

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
composeOR
```

Example:

```dart
const fieldSchema = {
  'type': 'string',
  'format': 'email',
  'minLength': 8,
  'pattern': r'.+@example\.com$',
};
```

The root `required` list is converted into the `required` validator for child fields.

## Custom synchronous validators

Register custom validators once and pass the registry to `AppReactiveForm`.

```dart
final validators = EntityCustomValidatorRegistry()
  ..register('reservedName', (rule) {
    return Validators.delegate((control) {
      const reserved = {'admin', 'root'};
      final value = control.value?.toString().toLowerCase();

      if (value != null && reserved.contains(value)) {
        return {'reservedName': true};
      }

      return null;
    });
  });
```

Declare the validator in JSON Schema:

```dart
'x-validators': [
  {
    'type': 'custom',
    'name': 'reservedName',
    'message': 'This name is not available.',
  },
],
```

Use it in the form:

```dart
AppReactiveForm(
  meta: meta,
  customValidators: validators,
)
```

## Custom asynchronous validators

```dart
class UniqueEmailValidator extends AsyncValidator<dynamic> {
  @override
  Future<Map<String, dynamic>?> validate(
    AbstractControl<dynamic> control,
  ) async {
    final email = control.value?.toString();
    if (email == null || email.isEmpty) return null;

    final exists = await accountApi.emailExists(email);
    return exists ? {'emailTaken': true} : null;
  }
}

final validators = EntityCustomValidatorRegistry()
  ..registerAsync('uniqueEmail', (rule) => UniqueEmailValidator());
```

Schema declaration:

```dart
'x-asyncValidators': [
  {
    'type': 'custom',
    'name': 'uniqueEmail',
  },
],
```

Async validators are attached to the generated `FormControl` and participate in normal form validity.

## Custom widgets

Override a widget builder when a field needs application-specific behavior, such as a remote reference selector.

```dart
final registry = EntityFieldWidgetRegistry(
  builders: {
    'reference': ({context, field, form, control, mode}) {
      return RemoteReferenceField(
        field: field,
        control: control,
      );
    },
  },
);

AppReactiveForm(
  meta: meta,
  registry: registry,
)
```

The builder receives the field metadata, parent form, control, and current form mode.

## Submission behavior

When Save is pressed:

1. All controls are marked as touched.
2. Synchronous and asynchronous validators are evaluated.
3. Invalid forms remain visible and display validation messages.
4. `onSubmit` is called only when the form is valid.
5. The callback receives a nested `Map<String, dynamic>` matching the schema.

Example submitted value:

```json
{
  "name": "Acme",
  "email": "owner@acme.com",
  "contacts": [
    {
      "name": "Jane",
      "email": "jane@acme.com"
    }
  ]
}
```

## Recommended consumer pattern

Keep the schema and validator registration outside the widget build method. Create the metadata once, provide API data through `initialData`, and keep API calls inside `onSubmit` or an application service.

```dart
class CustomerEditor extends StatelessWidget {
  CustomerEditor({super.key, this.customer});

  final Map<String, dynamic>? customer;
  static final meta = entityMetaFromJsonSchema(customerSchema);

  @override
  Widget build(BuildContext context) {
    return AppReactiveForm(
      meta: meta,
      mode: customer == null ? EntityMode.create : EntityMode.edit,
      initialData: customer,
      onSubmit: (value) async {
        if (customer == null) {
          await customerRepository.create(value);
        } else {
          await customerRepository.update(value);
        }
      },
    );
  }
}
```

This keeps consumers independent from individual `FormControl` and `FormArray` construction while still allowing custom widgets and validators when domain-specific behavior is required.
