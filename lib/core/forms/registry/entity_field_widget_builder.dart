import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../models/entity_meta.dart';
import '../models/field_meta.dart';

typedef EntityFieldWidgetBuilder =
    Widget Function({
      required BuildContext context,
      required FieldMeta<dynamic> field,
      required FormGroup form,
      required AbstractControl<dynamic> control,
      required EntityMode mode,
    });
