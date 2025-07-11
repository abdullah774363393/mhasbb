// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// استيراد الشاشات المكتملة التي سيتم التنقل إليها
import 'package:mhasbb/screens/login_screen.dart';
import 'package:mhasbb/screens/sales_invoices_screen.dart';
import 'package:mhasbb/screens/inventory_screen.dart';
import 'package:mhasbb/screens/purchase_invoices_screen.dart';
import 'package:mhasbb/screens/suppliers_screen.dart';
import 'package:mhasbb/screens/customers_screen.dart';
import 'package:mhasbb/screens/account_statement_screen.dart';
import 'package:mhasbb/screens/reports_screen.dart';
import 'package:mhasbb/screens/vouchers_screen.dart';
import 'package:mhasbb/screens/add_edit_return_invoice_screen.dart';
import 'package:mhasbb/screens/notes_screen.dart'; // استيراد شاشة الملاحظات
import 'package:mhasbb/main.dart'; // لاستخدام PlaceholderScreen
// ⭐⭐ أضف استيراد شاشة الآلة الحاسبة هنا
import 'package:mhasbb/screens/calculator_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_password');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateToSection(BuildContext context, String sectionName) {
    switch (sectionName) {
      case 'فواتير البيع':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesInvoicesScreen()));
        break;
      case 'فواتير الشراء':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PurchaseInvoicesScreen()));
        break;
      case 'المخزون':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryScreen()));
        break;
      case 'الموردين':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SuppliersScreen()));
        break;
      case 'العملاء':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomersScreen()));
        break;
      case 'كشف الحساب':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountStatementScreen()));
        break;
      case 'التقارير':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsScreen()));
        break;
      case 'سندات الصرف والقبض':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const VouchersScreen()));
        break;
      case 'المرتجعات':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditReturnInvoiceScreen()));
        break;
      case 'الملاحظات':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NotesScreen()));
        break;
      // ⭐⭐ أضف توجيه شاشة الآلة الحاسبة هنا
      case 'الآلة الحاسبة':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculatorScreen()));
        break;
      case 'الضريبة':
      case 'الإعدادات':
        Navigator.push(context, MaterialPageRoute(builder: (context) => PlaceholderScreen(title: sectionName)));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشاشة الرئيسية'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildSectionCard(context, 'فواتير البيع', Icons.receipt, Colors.blueAccent),
            _buildSectionCard(context, 'فواتير الشراء', Icons.shopping_cart, Colors.green),
            _buildSectionCard(context, 'المخزون', Icons.inventory_2, Colors.teal),
            _buildSectionCard(context, 'العملاء', Icons.people, Colors.orange),
            _buildSectionCard(context, 'الموردين', Icons.local_shipping, Colors.purple),
            _buildSectionCard(context, 'كشف الحساب', Icons.account_balance_wallet, Colors.redAccent),
            _buildSectionCard(context, 'التقارير', Icons.bar_chart, Colors.brown),
            _buildSectionCard(context, 'سندات الصرف والقبض', Icons.receipt_long, Colors.deepOrange),
            _buildSectionCard(context, 'المرتجعات', Icons.assignment_return, Colors.indigoAccent),
            _buildSectionCard(context, 'الملاحظات', Icons.note_alt, Colors.amber),
            // ⭐⭐ أضف بطاقة الآلة الحاسبة هنا
            _buildSectionCard(context, 'الآلة الحاسبة', Icons.calculate, Colors.blueGrey),
            _buildSectionCard(context, 'الضريبة', Icons.calculate, Colors.lime),
            _buildSectionCard(context, 'الإعدادات', Icons.settings, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _navigateToSection(context, title),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
