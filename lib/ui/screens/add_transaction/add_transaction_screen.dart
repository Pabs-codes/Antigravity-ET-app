import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/transaction_provider.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../../data/models/category_model.dart';

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

    final typeString = _type == TransactionType.expense ? 'expense' : 'income';
    final filteredCategories = categories.where((cat) => cat.type == typeString).toList();

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
                    _categoryId = null; // Reset category when type changes
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
                items: [
                  ...filteredCategories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id, 
                      child: Row(
                        children: [
                          Icon(IconData(int.tryParse(cat.iconCode) ?? 0xe57f, fontFamily: 'MaterialIcons')), 
                          const SizedBox(width: 8),
                          Text(cat.name),
                        ],
                      )
                    );
                  }).toList(),
                  const DropdownMenuItem(
                    value: 'add_new_custom_category',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Add new category +', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val == 'add_new_custom_category') {
                    _showAddCategoryDialog(typeString);
                  } else {
                    setState(() => _categoryId = val);
                  }
                },
                 // Basic validation: require category
                validator: (val) {
                   if (val == null || val == 'add_new_custom_category') return 'Select a category';
                   return null;
                },
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

  void _showAddCategoryDialog(String type) {
    final nameController = TextEditingController();
    int selectedColor = 0xFF4CAF50;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     TextField(
                       controller: nameController,
                       decoration: const InputDecoration(labelText: 'Category Name', border: OutlineInputBorder()),
                     ),
                     const SizedBox(height: 20),
                     const Text('Select Color'),
                     const SizedBox(height: 10),
                     Wrap(
                       spacing: 10,
                       runSpacing: 10,
                       children: [
                         0xFFF44336, 0xFFE91E63, 0xFF9C27B0, 0xFF673AB7,
                         0xFF3F51B5, 0xFF2196F3, 0xFF009688, 0xFF4CAF50,
                         0xFFFFC107, 0xFFFF9800, 0xFFFF5722, 0xFF795548, 0xFF607D8B
                       ].map((color) => GestureDetector(
                         onTap: () => setDialogState(() => selectedColor = color),
                         child: Container(
                           width: 32, height: 32,
                           decoration: BoxDecoration(
                             color: Color(color),
                             shape: BoxShape.circle,
                             border: selectedColor == color ? Border.all(width: 3, color: Colors.black) : null,
                           ),
                         ),
                       )).toList(),
                     ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('Cancel')
                ),
                FilledButton(
                  onPressed: () async {
                    if (nameController.text.trim().isNotEmpty) {
                      final newCat = CategoryModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        iconCode: '0xeac6', 
                        budgetLimit: 0, 
                        colorValue: selectedColor,
                        type: type, // Use passed type
                      );
                      await Provider.of<TransactionProvider>(context, listen: false).addCategory(newCat); 
                      // Auto select the new category
                      setState(() {
                         _categoryId = newCat.id;
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          }
        );
      }
    );
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
