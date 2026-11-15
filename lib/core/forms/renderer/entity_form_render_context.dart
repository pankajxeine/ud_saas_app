import 'package:reactive_forms/reactive_forms.dart';

import '../models/entity_meta.dart';
import '../registry/entity_field_widget_registry.dart';

class EntityFormRenderContext {
  const EntityFormRenderContext({required this.mode, required this.registry});

  final EntityMode mode;
  final EntityFieldWidgetRegistry registry;
}
