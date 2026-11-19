import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final t = Theme.of(context);
    return BlocListener<MetadataBloc, MetadataState>(
      listenWhen: (previous, current) => previous.metadata != current.metadata,
      listener: (context, state) {
        // Do not overwrite in-progress JSON editing when another
        // editor changes metadata. Use Reload to refresh explicitly.
      },
      child: Padding(
        padding: const EdgeInsetsGeometry.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'JSON editor',
                    style: t.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: t.colorScheme.onSurface,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: _loadFromBloc,
                  child: const Text('Reload'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyJson,
                  child: const Text('Apply JSON'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Edit the complete module metadata document.',
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: t.colorScheme.onSurface,
              ),
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
              child: TextField(
                controller: _controller,
                expands: true,
                minLines: null,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'Enter JSON...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
