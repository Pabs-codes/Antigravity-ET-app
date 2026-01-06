import 'package:flutter/material.dart';

class EditCategoryDialog extends StatefulWidget {
  final String categoryId;
  final String name;
  final double currentLimit;
  final Function(double) onSave;

  const EditCategoryDialog({
    super.key, 
    required this.categoryId, 
    required this.name,
    required this.currentLimit,
    required this.onSave,
  });

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentLimit.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Budget for ${widget.name}'),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Monthly Limit'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final val = double.tryParse(_controller.text);
            if (val != null) {
              widget.onSave(val);
              Navigator.pop(context);
            }
          }, 
          child: const Text('Save')
        ),
      ],
    );
  }
}
