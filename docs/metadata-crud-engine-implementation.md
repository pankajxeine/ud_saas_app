# Metadata-Driven CRUD Engine

## Purpose

The application stores module definitions in the metadata service. A module definition describes the entity, fields, API operations, permissions, validation, rules, list layout, form layout, and detail layout.

The Flutter client uses that definition to generate common CRUD experiences:

- data table and search
- create and edit forms
- detail/view page
- create, read, update, and delete operations
- permission-aware actions
- metadata-driven validation and field rendering

The implementation is located in:

```
lib/core/module_engine/
```

It reuses the existing metadata models, reactive forms, `AppDataTable`, theme, and REST client.

## Architecture

```
ModuleCrudPage(moduleId)
        |
        v
ModuleMetadataBloc
        |
        +-- ModuleMetadataRepository
        |       |
        |       +-- tenant-scoped memory cache
        |       +-- in-flight request coalescing
        |       +-- metadata API
        |
        v
Immutable ModuleMetadata snapshot
        |
        v
ModuleCrudBloc -------------- ModuleRecordRepository
        |                              |
        |                              +-- list
        |                              +-- detail
        |                              +-- create
        |                              +-- update
        |                              +-- delete
        v
Generic CRUD widgets
        |
        +-- AppDataTable
        +-- AppReactiveForm
        +-- generic detail view
```

### Design rules

1. Metadata is loaded once and reused.
2. Metadata is treated as an immutable runtime snapshot.
3. Metadata lifecycle and CRUD state are separate concerns.
4. One CRUD bloc is created per module route/session, not globally.
5. Repositories do not import or depend on widgets.
6. Renderers use field type and metadata, never module names.
7. Server-side authorization remains authoritative.

## Directory structure

```
lib/core/module_engine/
├── bloc/
│   ├── module_crud_bloc.dart
│   ├── module_crud_event.dart
│   ├── module_crud_state.dart
│   └── module_metadata_bloc.dart
├── models/
│   ├── module_metadata.dart
│   └── presentation_models.dart
├── repository/
│   ├── module_metadata_repository.dart
│   └── module_record_repository.dart
├── utils/
│   └── metadata_presentation_mapper.dart
├── widgets/
│   └── module_crud_page.dart
└── module_engine.dart
```

## Metadata contract

The server should return a published module version. The client converts the response to the existing `MetaModule`, `MetaModuleVersion`, and `MetadataSchema` models, then wraps it in `ModuleMetadata`.

Example:

```json
{
  "module_id": "contacts",
  "module_code": "crm_contact",
  "module_name": "Contacts",
  "current_version": 3,
  "is_active": true,
  "meta_module_version": [
    {
      "version_no": 3,
      "publication_status": "published",
      "schema_json": {
        "entity": "contact",
        "title": "Contacts",
        "primaryKey": "id",
        "api": [
          {
            "operation": "list",
            "path": "/contacts",
            "enabled": true,
            "permission": "crm.contact.list"
          },
          {
            "operation": "detail",
            "path": "/contacts/:id",
            "enabled": true,
            "permission": "crm.contact.view"
          },
          {
            "operation": "create",
            "path": "/contacts",
            "enabled": true,
            "permission": "crm.contact.create"
          },
          {
            "operation": "update",
            "path": "/contacts/:id",
            "enabled": true,
            "permission": "crm.contact.update"
          },
          {
            "operation": "delete",
            "path": "/contacts/:id",
            "enabled": true,
            "permission": "crm.contact.delete"
          }
        ],
        "grid": {
          "pageSize": 25,
          "defaultSort": {
            "fields": ["created_at"],
            "direction": "desc"
          }
        },
        "fields": [
          {
            "name": "id",
            "label": "ID",
            "type": "string",
            "readOnly": true,
            "visibility": {"show": ["table", "detail"]}
          },
          {
            "name": "name",
            "label": "Name",
            "type": "string",
            "visibility": {"show": ["table", "detail", "create", "edit"]},
            "validations": {"required": true, "minLength": 2}
          },
          {
            "name": "email",
            "label": "Email",
            "type": "email",
            "visibility": {"show": ["table", "detail", "create", "edit"]},
            "validations": {"required": true, "email": true}
          },
          {
            "name": "status",
            "label": "Status",
            "type": "string",
            "widget": "select",
            "visibility": {"show": ["table", "detail", "create", "edit"]},
            "options": [
              {"value": "active", "label": "Active"},
              {"value": "inactive", "label": "Inactive"}
            ]
          }
        ],
        "search": {
          "quickSearch": ["name", "email"],
          "filters": [{"field": "status", "label": "Status"}]
        }
      }
    }
  ]
}
```

The server must return only a tenant-authorized module and published version. The client must never use metadata from an untrusted tenant or unpublished version for production CRUD screens.

## Metadata lifecycle and caching

`ModuleMetadataRepository` uses `ModuleMetadataCache`:

```
get(tenantId, moduleId)
        |
        +-- cached value? return it
        |
        +-- request already running? await same Future
        |
        +-- call metadata API once
        |
        +-- normalize to ModuleMetadata
        +-- cache by tenantId + moduleId
        +-- return immutable snapshot
```

The cache key must include tenant scope:

```
{tenantId}:{moduleId}
```

Never use only `moduleId` as a cache key in a multi-tenant application.

Invalidate metadata after publishing a new version:

```dart
metadataRepository.invalidate(moduleId);
```

The current implementation is an application-session cache. Persistent caching can be added later using the existing storage layer, but a persisted value must include tenant ID, module ID, version, and schema hash.

## Metadata bloc

`ModuleMetadataBloc` owns only metadata loading status:

```dart
enum ModuleMetadataStatus { initial, loading, success, failure }

class ModuleMetadataState {
  final ModuleMetadataStatus status;
  final ModuleMetadata? metadata;
  final String? error;
}
```

It does not own records, form values, or CRUD operation progress.

The bloc avoids duplicate requests by ignoring `load()` while loading or after successful completion. The repository cache additionally coalesces concurrent requests from separate route instances.

## CRUD bloc

`ModuleCrudBloc` is created after metadata succeeds:

```dart
ModuleCrudBloc(
  metadata: metadata,
  recordRepository: recordRepository,
)
```

It owns:

- records and total count
- current page and page size
- search and filters
- selected record
- create/edit form data
- detail loading state
- operation status and errors
- current CRUD view

It does not call the metadata API.

### Events

```dart
ModuleStarted(recordId: optionalId)
ModuleRefreshRequested()
ModuleSearchChanged(query)
ModuleFiltersChanged(filters)
ModulePageChanged(page)
ModuleCreateRequested()
ModuleDetailRequested(id)
ModuleEditRequested(id)
ModuleFormSubmitted(data)
ModuleDeleteRequested(id)
ModuleBackRequested()
```

### Operation status

```dart
enum ModuleOperation { idle, loading, success, failure }
```

The table selects records independently from operation status. A save/delete progress change therefore does not rebuild the entire table.

## Repository design

Record access is defined by `ModuleRecordRepository`:

```dart
abstract interface class ModuleRecordRepository {
  Future<ModulePageResult> list({
    required ModuleMetadata metadata,
    required int page,
    required int pageSize,
    String? search,
    Map<String, dynamic> filters,
  });

  Future<Map<String, dynamic>> detail({
    required ModuleMetadata metadata,
    required String id,
  });

  Future<Map<String, dynamic>> create({
    required ModuleMetadata metadata,
    required Map<String, dynamic> data,
  });

  Future<Map<String, dynamic>> update({
    required ModuleMetadata metadata,
    required String id,
    required Map<String, dynamic> data,
  });

  Future<void> delete({
    required ModuleMetadata metadata,
    required String id,
  });
}
```

The REST implementation resolves operation paths from metadata and supports `:id`, `{id}`, and `{primaryKey}` placeholders.

Repositories must not trust a tenant ID supplied by the UI. The server must derive tenant access from the authenticated identity and independently verify:

- tenant membership
- module permission
- operation permission
- record ownership or tenant scope
- field-level write permissions

The client-side tenant header is a request scope hint, not an authorization mechanism.

## Presentation mapping

`MetadataPresentationMapper` converts runtime metadata into renderer-neutral models:

```dart
final table = MetadataPresentationMapper.table(
  metadata: metadata,
  records: state.records,
);

final form = MetadataPresentationMapper.form(metadata);
final view = MetadataPresentationMapper.view(metadata);
```

### Table model

Only fields with `showInTable == true` and fields that are not write-only are converted to columns. Rows are copied into unmodifiable maps.

### Form model

The form mapper creates the JSON shape consumed by the existing `entityMetaFromJson()` and `AppReactiveForm` pipeline. This preserves the existing reactive form controls, validators, sections, and theme.

### View model

Only fields with `showInDetail == true` and fields that are not write-only are shown in the generated detail page.

## Generic CRUD page

```dart
ModuleCrudPage(
  moduleId: 'contacts',
  metadataRepository: moduleMetadataRepository,
  recordRepository: RestModuleRecordRepository(
    api: RestApi.global(),
    tenantId: currentTenantId,
  ),
)
```

The page flow is:

```
metadata loading
        |
        +-- error -> retry state
        |
        +-- success -> create ModuleCrudBloc
                              |
                              +-- list
                              +-- detail
                              +-- create
                              +-- edit
```

## Rebuild strategy

Use `BlocSelector` for narrow state slices:

```dart
BlocSelector<ModuleCrudBloc, ModuleCrudState, ModuleCrudView>(
  selector: (state) => state.view,
  builder: (context, view) => ...,
)
```

The generated table selects only records and pagination data. The form selects only form data and operation status. Detail view selects only the selected record. Metadata is read from the immutable bloc dependency and does not change during the CRUD session.

Use `buildWhen` for loading/error containers, especially when a status change should not rebuild the content widget.

Avoid rebuilding the entire page for every state change:

```dart
BlocBuilder<ModuleCrudBloc, ModuleCrudState>(
  builder: (_, state) => EntirePage(state: state),
)
```

## Search and server-side filtering

Search events are debounced in `ModuleCrudBloc` for 300 milliseconds. The repository receives the query and filters so the server remains the source of truth for large datasets.

```dart
context.read<ModuleCrudBloc>().add(
  ModuleSearchChanged(value),
);
```

The backend should support a stable request shape:

```
GET /contacts?page=1&pageSize=25&search=alice&status=active
```

Do not download all tenant records to perform client-side filtering unless the metadata explicitly declares the dataset small and safe to cache.

## Permissions and validation

Permissions must be enforced twice:

1. The UI hides or disables unavailable actions.
2. The server rejects unauthorized operations.

Field visibility controls rendering. Field editability controls form state. Neither replaces server-side validation or authorization.

Recommended field permission shape:

```json
{
  "permissions": {
    "view": "crm.contact.email.view",
    "edit": "crm.contact.email.edit"
  }
}
```

Validation should remain in the existing reactive-form layer for synchronous field validation. Server validation errors should be mapped to `fieldErrors` and displayed beside the corresponding field.

Rules should be evaluated separately from validation. Rules can control conditional visibility, enabled/read-only state, required state, calculated values, and dependent reference fields.

## Error and empty states

Every generated page should distinguish:

- metadata loading
- metadata failure
- records loading
- records failure
- empty result set
- detail not found
- validation failure
- mutation failure

An empty result is not an API error. It should provide a useful action such as “Create record” when the user has create permission.

## Example route integration

```dart
GoRoute(
  path: '/modules/:moduleId',
  builder: (context, state) {
    final moduleId = state.pathParameters['moduleId']!;

    return ModuleCrudPage(
      moduleId: moduleId,
      metadataRepository: context.read<ModuleMetadataRepository>(),
      recordRepository: context.read<ModuleRecordRepository>(),
    );
  },
)
```

The route should pass identifiers only. Do not serialize the full metadata document or record into the route.

## Testing checklist

### Metadata

- loading a module twice makes one API request
- different tenants never share a cache entry
- unpublished versions are rejected
- failed metadata requests can be retried
- cache invalidation causes the next request to reload

### CRUD bloc

- list loads once after metadata success
- search is debounced
- duplicate refresh requests are ignored while loading
- create and update select the correct operation
- delete refreshes the current page
- operation failure keeps the current form/table visible
- operation status does not rebuild the table model

### Rendering

- hidden fields are not shown
- read-only fields cannot be edited
- write-only fields do not appear in detail or table views
- empty and error states provide appropriate actions
- field types map to existing form controls

### Security

- every request includes authenticated credentials
- tenant scope is checked on the server
- metadata permissions are not treated as authorization
- direct API calls without permission return 401/403
- record IDs from another tenant cannot be opened or modified

## Extension points

Future additions should be injected rather than hard-coded into module names:

- field renderer registry
- custom validation registry
- permission evaluator
- rule engine
- reference lookup provider
- module-specific action registry
- audit/logging adapter

The engine should remain generic: metadata describes the module, repositories access data, blocs coordinate state, and widgets render state.

