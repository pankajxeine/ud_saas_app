import 'package:flutter/material.dart';

class FieldSelectorWidget extends StatefulWidget {
  const FieldSelectorWidget({
    super.key,
    required this.fields,
    required this.onChanged,
  });

  final List<String> fields;
  final ValueChanged<List<String>> onChanged;

  @override
  State<FieldSelectorWidget> createState() => _FieldSelectorWidgetState();
}

class _FieldSelectorWidgetState extends State<FieldSelectorWidget> {
  late Set<String> selectedFields;

  @override
  void initState() {
    super.initState();
    selectedFields = widget.fields.toSet();
  }

  void _toggleField(String field, bool? value) {
    setState(() {
      if (value ?? false) {
        selectedFields.add(field);
      } else {
        selectedFields.remove(field);
      }
    });

    widget.onChanged(selectedFields.toList());
  }

  void _selectAll() {
    setState(() {
      selectedFields = widget.fields.toSet();
    });

    widget.onChanged(selectedFields.toList());
  }

  void _clearAll() {
    setState(() {
      selectedFields.clear();
    });

    widget.onChanged([]);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                FilledButton(
                  onPressed: _selectAll,
                  child: const Text('Enable All'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _clearAll,
                  child: const Text('Disable All'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: widget.fields.length,
                itemBuilder: (context, index) {
                  final field = widget.fields[index];

                  return CheckboxListTile(
                    title: Text(field),
                    value: selectedFields.contains(field),
                    onChanged: (value) => _toggleField(field, value),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
