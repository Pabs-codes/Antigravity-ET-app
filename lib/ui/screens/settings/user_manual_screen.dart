import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserManualScreen extends StatefulWidget {
  const UserManualScreen({super.key});

  @override
  State<UserManualScreen> createState() => _UserManualScreenState();
}

class _UserManualScreenState extends State<UserManualScreen> with SingleTickerProviderStateMixin {
  final List<ManualSection> _sections = [
    ManualSection(
      title: 'Getting Started',
      icon: Icons.start_rounded,
      content: 'Welcome to your new Financial Companion.\n\n'
          'This app helps you track your income and expenses with ease. '
          'Start by adding your first transaction from the Dashboard.',
    ),
    ManualSection(
      title: 'Adding Transactions',
      icon: Icons.add_circle_outline_rounded,
      content: '1. Tap the "Add" button on the Dashboard.\n'
          '2. Enter the amount, title, and choose a category.\n'
          '3. Select "Expense" or "Income" using the toggle.\n'
          '4. Pick a date and add optional notes.\n'
          '5. Tap "Save Transaction".',
    ),
    ManualSection(
      title: 'Managing Categories',
      icon: Icons.category_outlined,
      content: 'You can create custom categories to organize your finances better.\n\n'
          '• Go to Settings > Add New Category.\n'
          '• Or select "Add new category +" directly from the transaction form.\n'
          '• Custom categories are automatically assigned to the current transaction type.',
    ),
    ManualSection(
      title: 'Viewing History',
      icon: Icons.history_rounded,
      content: 'Tap "History" on the Dashboard or "View All" to see your full transaction log.\n\n'
          '• Use the Filter icon to search by Date Range or Category.\n'
          '• Tap a transaction to see more details (coming soon).',
    ),
    ManualSection(
      title: 'Exporting Data',
      icon: Icons.file_download_outlined,
      content: 'Need a backup? Go to Settings > Export to CSV to save your data to a spreadsheet compatible with Excel or Google Sheets.',
    ),
    ManualSection(
      title: 'Security',
      icon: Icons.security_rounded,
      content: 'Protect your data with Biometric Authentication.\n\n'
          'Enable it in Settings to require Fingerprint or Face ID when opening the app.',
    ),
  ];

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent for modal effect overlay
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1a1f2c).withOpacity(0.98), const Color(0xFF121212).withOpacity(0.98)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Custom Draggable Handle for Modal feel
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'User Manual',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                   return AnimatedBuilder(
                     animation: _controller,
                     builder: (context, child) {
                       final delay = index * 0.1;
                       final slide = CurvedAnimation(
                         parent: _controller,
                         curve: Interval(delay, delay + 0.4, curve: Curves.easeOut),
                       );
                       return Opacity(
                         opacity: slide.value,
                         child: Transform.translate(
                           offset: Offset(0, 50 * (1 - slide.value)),
                           child: child,
                         ),
                       );
                     },
                     child: _buildSectionCard(_sections[index], index),
                   );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(ManualSection section, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9b87f5).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(section.icon, color: const Color(0xFF9b87f5), size: 24),
              ),
              title: Text(
                section.title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              iconColor: Colors.white70,
              collapsedIconColor: Colors.white70,
              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Text(
                  section.content,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ManualSection {
  final String title;
  final IconData icon;
  final String content;

  ManualSection({required this.title, required this.icon, required this.content});
}
