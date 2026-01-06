import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/transaction_provider.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _title = '';
  double _amount = 0.0;
  TransactionType _type = TransactionType.expense;
  String? _categoryId;
  DateTime _selectedDate = DateTime.now();
  String _note = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final categories = provider.categories; // Ensure categories are loaded

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) => val == null || val.isEmpty ? 'Enter a title' : null,
                onSaved: (val) => _title = val!,
              ),
              const SizedBox(height: 16),
              
              // Amount
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter amount';
                  if (double.tryParse(val) == null) return 'Invalid number';
                  return null;
                },
                onSaved: (val) => _amount = double.parse(val!),
              ),
              const SizedBox(height: 16),
              
              // Type Segmented Button
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(MaterialState.selected)) {
                       return _type == TransactionType.expense ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2);
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.isEmpty 
                  ? [const DropdownMenuItem(value: null, child: Text('No Categories'))]
                  : categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id, 
                      child: Row(
                        children: [
                          Icon(IconData(int.tryParse(cat.iconCode) ?? 0xe57f, fontFamily: 'MaterialIcons')), // default invalid icon handling needed
                          const SizedBox(width: 8),
                          Text(cat.name),
                        ],
                      )
                    );
                  }).toList(),
                onChanged: (val) => setState(() => _categoryId = val),
                 // Basic validation: require category
                validator: (val) => val == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 16),

              // Date Picker
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              
              // Note
              TextFormField(
                decoration: const InputDecoration(labelText: 'Note (Optional)'),
                maxLines: 2,
                onSaved: (val) => _note = val ?? '',
              ),
              const SizedBox(height: 24),

              // Submit Button
              FilledButton(
                onPressed: _submitForm,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Save Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final newTx = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _title,
        amount: _amount,
        date: _selectedDate,
        type: _type,
        categoryId: _categoryId ?? 'uncategorized', // Should enforce category
        note: _note,
      );

      Provider.of<TransactionProvider>(context, listen: false).addTransaction(newTx);
      Navigator.pop(context);
    }
  }
}
