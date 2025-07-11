// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart'; // تأكد من أن هذا هو الاستيراد الصحيح

// استيراد الشاشات الرئيسية والتنقل
import 'package:mhasbb/screens/home_screen.dart';
import 'package:mhasbb/screens/login_screen.dart';
import 'package:mhasbb/screens/sales_invoices_screen.dart';
import 'package:mhasbb/screens/add_edit_invoice_screen.dart';
import 'package:mhasbb/screens/inventory_screen.dart';
import 'package:mhasbb/screens/purchase_invoices_screen.dart';
import 'package:mhasbb/screens/add_edit_purchase_invoice_screen.dart';
import 'package:mhasbb/screens/suppliers_screen.dart';
import 'package:mhasbb/screens/add_edit_supplier_screen.dart';
import 'package:mhasbb/screens/customers_screen.dart';
import 'package:mhasbb/screens/account_statement_screen.dart';
import 'package:mhasbb/screens/reports_screen.dart';
import 'package:mhasbb/screens/vouchers_screen.dart';
import 'package:mhasbb/screens/add_edit_voucher_screen.dart';
import 'package:mhasbb/screens/add_edit_return_invoice_screen.dart';
import 'package:mhasbb/screens/notes_screen.dart';
// ⭐⭐ أضف استيراد شاشة الآلة الحاسبة هنا
import 'package:mhasbb/screens/calculator_screen.dart';


// استيراد موديلات Hive
import 'package:mhasbb/models/item.dart';
import 'package:mhasbb/models/customer.dart';
import 'package:mhasbb/models/invoice_item.dart';
import 'package:mhasbb/models/invoice.dart';
import 'package:mhasbb/models/supplier.dart';
import 'package:mhasbb/models/voucher.dart';
import 'package:mhasbb/models/voucher_type.dart';
import 'package:mhasbb/models/payment_method.dart';

// ---
late SharedPreferences prefs;

// شاشة وهمية للميزات غير المكتملة
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'هذه شاشة $title',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    prefs = await SharedPreferences.getInstance();

    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    // تسجيل جميع محولات (adapters) Hive لموديلات البيانات
    Hive.registerAdapter(InvoiceTypeAdapter());
    Hive.registerAdapter(ItemAdapter());
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(InvoiceItemAdapter());
    Hive.registerAdapter(InvoiceAdapter());
    Hive.registerAdapter(SupplierAdapter());
    Hive.registerAdapter(VoucherTypeAdapter());
    Hive.registerAdapter(VoucherAdapter());
    Hive.registerAdapter(PaymentMethodAdapter());

    // فتح جميع صناديق Hive (Boxes)
    await Hive.openBox<Item>('items_box');
    await Hive.openBox<Customer>('customers_box');
    await Hive.openBox<Invoice>('invoices_box');
    await Hive.openBox<Supplier>('suppliers_box');
    await Hive.openBox<Voucher>('vouchers_box');

    print('✅ App Initialization Complete: SharedPreferences, Hive, and Hive Boxes are ready.');
  } catch (e, stacktrace) {
    print('❌ Critical Error during App Initialization: $e');
    print('Stacktrace: $stacktrace');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق إدارة المبيعات والمخزون',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.indigo),
          floatingLabelStyle: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: TextTheme(
          titleLarge: TextStyle(color: Colors.indigo[800], fontSize: 24, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(color: Colors.black54, fontSize: 16),
          labelLarge: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      home: FutureBuilder<bool>(
        future: _checkPasswordStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              ),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('حدث خطأ: ${snapshot.error}'),
              ),
            );
          }
          return snapshot.data == true ? const HomeScreen() : const LoginScreen();
        },
      ),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/sales_invoices': (context) => const SalesInvoicesScreen(),
        '/add_edit_invoice': (context) => const AddEditInvoiceScreen(),
        '/inventory': (context) => const InventoryScreen(),
        '/purchase_invoices': (context) => const PurchaseInvoicesScreen(),
        '/add_edit_purchase_invoice': (context) => const AddEditPurchaseInvoiceScreen(invoice: null),
        '/customers': (context) => const CustomersScreen(),
        '/suppliers': (context) => const SuppliersScreen(),
        '/add_edit_supplier': (context) => const AddEditSupplierScreen(),
        '/accounts': (context) => const AccountStatementScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/vouchers': (context) => const VouchersScreen(),
        '/add_edit_voucher': (context) => const AddEditVoucherScreen(),
        '/add_edit_return_invoice': (context) => const AddEditReturnInvoiceScreen(),
        '/notes': (context) => const NotesScreen(),
        '/calculator': (context) => const CalculatorScreen(), // ⭐⭐ مسار شاشة الآلة الحاسبة
        '/tax': (context) => const PlaceholderScreen(title: 'الضريبة'),
        '/settings': (context) => const PlaceholderScreen(title: 'الإعدادات'),
      },
    );
  }

  Future<bool> _checkPasswordStatus() async {
    final storedPassword = prefs.getString('app_password');
    return storedPassword != null && storedPassword.isNotEmpty;
  }
}
