import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/components/input.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';

import '../models/metadata_module_version.dart';

class MetadataJsonEditor extends StatefulWidget {
  const MetadataJsonEditor({super.key});

  @override
  State<MetadataJsonEditor> createState() => _MetadataJsonEditorState();
}

class _MetadataJsonEditorState extends State<MetadataJsonEditor> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadFromBloc();
    });
  }

  void _loadFromBloc() {
    final metadata = context.read<MetadataBloc>().state.metadata;

    _controller.text = const JsonEncoder.withIndent('  ').convert(metadata);
  }

  void _applyJson() {
    try {
      final decoded = jsonDecode(_controller.text);

      if (decoded is! Map) {
        setState(() {
          _error = 'Root JSON value must be an object.';
        });
        return;
      }

      // final metadata = Map<String, dynamic>.from(decoded);
      final metadataVersion = MetaModuleVersion.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      context.read<MetadataBloc>().add(ReplaceMetadata(metadataVersion));

      setState(() {
        _error = null;
      });
    } on FormatException catch (error) {
      setState(() {
        _error = error.message;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MetadataBloc, MetadataState>(
      listenWhen: (previous, current) => previous.metadata != current.metadata,
      listener: (context, state) {
        // Do not overwrite in-progress JSON editing when another
        // editor changes metadata. Use Reload to refresh explicitly.
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'JSON editor',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              Button(
                variant: ButtonVariant.outline,
                onPressed: _loadFromBloc,
                child: const Text('Reload'),
              ),
              const SizedBox(width: 8),
              Button(onPressed: _applyJson, child: const Text('Apply JSON')),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Edit the complete module metadata document.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFFB91C1C)),
              ),
            ),
          Expanded(
            child: Input(
              controller: _controller,
              expands: true,
              minLines: null,
              maxLines: null,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
