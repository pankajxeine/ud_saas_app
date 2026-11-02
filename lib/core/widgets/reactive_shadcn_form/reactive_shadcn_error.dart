import 'package:flutter/material.dart' hide Theme;
import 'package:reactive_forms/reactive_forms.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';

class ReactiveShadcnError extends StatelessWidget {
  const ReactiveShadcnError({super.key, required this.control, this.message});

  final AbstractControl<dynamic> control;
  final String? message;

  @override
  Widget build(BuildContext context) {
    print("error message $message");
    if (!control.touched || !control.hasErrors) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 2),
      child: Text(
        message != null && message!.isNotEmpty
            ? message!
            : control.errors.keys.first,
        style: TextStyle(color: Theme.of(context).colors.destructive),
      ),
    );
  }
}
