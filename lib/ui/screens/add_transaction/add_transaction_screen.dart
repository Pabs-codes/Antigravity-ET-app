import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/transaction_provider.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../../data/models/category_model.dart';
import 'package:google_fonts/google_fonts.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType? initialType;

  const AddTransactionScreen({super.key, this.initialType});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  String _title = '';
  double _amount = 0.0;
  TransactionType _type = TransactionType.expense;
  String? _categoryId;
  DateTime _selectedDate = DateTime.now();
  String _note = '';

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _type = widget.initialType!;
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final categories = provider.categories;

    final typeString = _type == TransactionType.expense ? 'expense' : 'income';
    final filteredCategories = categories.where((cat) => cat.type == typeString).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Add Transaction', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Premium Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1a1f2c), Color(0xFF121212)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // 2. Decorative Blurred Orbs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF9b87f5).withOpacity(0.3),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7E57C2).withOpacity(0.2),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Type Selector (Expense / Income)
                        _buildTypeSelector(),
                        const SizedBox(height: 30),

                        // Glass Container for Form
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Amount Input
                                  Text(
                                    'Enter Amount',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      hintText: '\$0.00',
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.white38,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      border: InputBorder.none,
                                      prefixStyle: GoogleFonts.poppins(
                                        color: _type == TransactionType.expense ? const Color(0xFFCF6679) : const Color(0xFF4CAF50),
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'Enter amount';
                                      if (double.tryParse(val) == null) return 'Invalid number';
                                      return null;
                                    },
                                    onSaved: (val) => _amount = double.parse(val!),
                                  ),
                                  const SizedBox(height: 30),

                                  // Title Input
                                  _buildGlassInput(
                                    label: 'Title',
                                    icon: Icons.title_rounded,
                                    onSaved: (val) => _title = val!,
                                    validator: (val) => val == null || val.isEmpty ? 'Enter a title' : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Category Dropdown
                                  _buildGlassDropdown(filteredCategories, typeString),
                                  const SizedBox(height: 16),

                                  // Date Picker
                                  _buildGlassDatePicker(),
                                  const SizedBox(height: 16),

                                  // Note Input
                                  _buildGlassInput(
                                    label: 'Note (Optional)',
                                    icon: Icons.notes_rounded,
                                    maxLines: 2,
                                    onSaved: (val) => _note = val ?? '',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Submit Button
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9b87f5),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFF9b87f5).withOpacity(0.5),
                          ),
                          child: Text(
                            'Save Transaction',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTypeButton(TransactionType.expense, 'Expense')),
          Expanded(child: _buildTypeButton(TransactionType.income, 'Income')),
        ],
      ),
    );
  }

  Widget _buildTypeButton(TransactionType type, String label) {
    final isSelected = _type == type;
    final color = type == TransactionType.expense ? const Color(0xFFCF6679) : const Color(0xFF4CAF50);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _type = type;
          _categoryId = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color.withOpacity(0.5)) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? color : Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassInput({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFF9b87f5).withOpacity(0.5)),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildGlassDropdown(List<CategoryModel> categories, String typeString) {
    return DropdownButtonFormField<String>(
      value: _categoryId,
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.category_rounded, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: const Color(0xFF1a1f2c),
      style: const TextStyle(color: Colors.white),
      items: [
        ...categories.map((cat) {
          return DropdownMenuItem(
            value: cat.id, 
            child: Row(
              children: [
                Icon(IconData(int.tryParse(cat.iconCode) ?? 0xe57f, fontFamily: 'MaterialIcons'), color: Color(cat.colorValue)), 
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
              Icon(Icons.add_circle_outline, color: Color(0xFF9b87f5)),
              SizedBox(width: 8),
              Text('Add new category +', style: TextStyle(color: Color(0xFF9b87f5), fontWeight: FontWeight.bold)),
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
      validator: (val) {
         if (val == null || val == 'add_new_custom_category') return 'Select a category';
         return null;
      },
    );
  }

  Widget _buildGlassDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: Colors.white70),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Date', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(
                  DateFormat.yMMMd().format(_selectedDate),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF9b87f5), 
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E), 
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.9),
                title: const Text('Add Category', style: TextStyle(color: Colors.white)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       TextField(
                         controller: nameController,
                         style: const TextStyle(color: Colors.white),
                         decoration: const InputDecoration(
                           labelText: 'Category Name', 
                           labelStyle: TextStyle(color: Colors.white70),
                           enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                           focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF9b87f5))),
                         ),
                       ),
                       const SizedBox(height: 20),
                       const Text('Select Color', style: TextStyle(color: Colors.white70)),
                       const SizedBox(height: 10),
                       Wrap(
                         spacing: 12,
                         runSpacing: 12,
                         children: [
                           0xFFF44336, 0xFFE91E63, 0xFF9C27B0, 0xFF673AB7,
                           0xFF3F51B5, 0xFF2196F3, 0xFF009688, 0xFF4CAF50,
                           0xFFFFC107, 0xFFFF9800, 0xFFFF5722, 0xFF795548, 0xFF607D8B
                         ].map((color) => GestureDetector(
                           onTap: () => setDialogState(() => selectedColor = color),
                           child: Container(
                             width: 36, height: 36,
                             decoration: BoxDecoration(
                               color: Color(color),
                               shape: BoxShape.circle,
                               border: selectedColor == color ? Border.all(width: 3, color: Colors.white) : null,
                               boxShadow: [
                                 BoxShadow(
                                   color: Color(color).withOpacity(0.4),
                                   blurRadius: 8,
                                   offset: const Offset(0, 2),
                                 )
                               ]
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
                    child: const Text('Cancel', style: TextStyle(color: Colors.white70))
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
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF9b87f5),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
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
