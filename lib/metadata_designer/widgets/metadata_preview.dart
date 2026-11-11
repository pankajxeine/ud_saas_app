import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/selectable/selectable.dart';
import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_state.dart';

class MetadataPreview extends StatelessWidget {
  const MetadataPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataBloc, MetadataState>(
      builder: (context, state) {
        final prettyJson = const JsonEncoder.withIndent(
          '  ',
        ).convert(state.metadata);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              prettyJson,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }
}
