// lib/screens/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mhasbb/models/invoice.dart';
import 'package:mhasbb/models/invoice_item.dart';
import 'package:mhasbb/models/item.dart';

enum ReportType { sales, purchases, inventory }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportType _selectedReportType = ReportType.sales; // التقرير الافتراضي
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  late Box<Invoice> invoicesBox;
  late Box<Item> itemsBox;

  @override
  void initState() {
    super.initState();
    invoicesBox = Hive.box<Invoice>('invoices_box');
    itemsBox = Hive.box<Item>('items_box');
  }

  // --- دوال اختيار التاريخ ---
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  // --- تقرير المبيعات ---
  List<Invoice> _generateSalesReport() {
    return invoicesBox.values
        .where((invoice) =>
            invoice.type == InvoiceType.sale &&
            invoice.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            invoice.date.isBefore(_endDate.add(const Duration(days: 1))))
        .toList()
        .cast<Invoice>()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // --- تقرير المشتريات ---
  List<Invoice> _generatePurchaseReport() {
    return invoicesBox.values
        .where((invoice) =>
            invoice.type == InvoiceType.purchase &&
            invoice.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            invoice.date.isBefore(_endDate.add(const Duration(days: 1))))
        .toList()
        .cast<Invoice>()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // --- تقرير المخزون ---
  List<Item> _generateInventoryReport() {
    // تقرير المخزون ببساطة يعرض جميع الأصناف من صندوق الأصناف
    return itemsBox.values.toList().cast<Item>()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // --- بناء واجهة عرض التقرير المختار ---
  Widget _buildReportContent() {
    final numberFormat = NumberFormat('#,##0.00', 'en_US');

    if (_selectedReportType == ReportType.sales) {
      final salesInvoices = _generateSalesReport();
      double totalSales = salesInvoices.fold(
          0.0,
          (sum, invoice) => sum +
              invoice.items.fold(
                  0.0, (itemSum, item) => itemSum + (item.quantity * item.sellingPrice)));

      if (salesInvoices.isEmpty) {
        return const Center(child: Text('لا توجد مبيعات في الفترة المحددة.'));
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'إجمالي المبيعات: ${numberFormat.format(totalSales)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: salesInvoices.length,
              itemBuilder: (context, index) {
                final invoice = salesInvoices[index];
                final invoiceTotal = invoice.items.fold(
                    0.0, (sum, item) => sum + (item.quantity * item.sellingPrice));
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('رقم الفاتورة: ${invoice.invoiceNumber}',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text('التاريخ: ${DateFormat('yyyy-MM-dd').format(invoice.date)}'),
                        Text('العميل: ${invoice.customerName ?? 'غير محدد'}'),
                        const SizedBox(height: 5),
                        Text('الإجمالي: ${numberFormat.format(invoiceTotal)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else if (_selectedReportType == ReportType.purchases) {
      final purchaseInvoices = _generatePurchaseReport();
      double totalPurchases = purchaseInvoices.fold(
          0.0,
          (sum, invoice) => sum +
              invoice.items.fold(
                  0.0, (itemSum, item) => itemSum + (item.quantity * item.purchasePrice))); // استخدام purchasePrice هنا

      if (purchaseInvoices.isEmpty) {
        return const Center(child: Text('لا توجد مشتريات في الفترة المحددة.'));
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'إجمالي المشتريات: ${numberFormat.format(totalPurchases)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: purchaseInvoices.length,
              itemBuilder: (context, index) {
                final invoice = purchaseInvoices[index];
                final invoiceTotal = invoice.items.fold(
                    0.0, (sum, item) => sum + (item.quantity * item.purchasePrice));
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('رقم الفاتورة: ${invoice.invoiceNumber}',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text('التاريخ: ${DateFormat('yyyy-MM-dd').format(invoice.date)}'),
                        Text('المورد: ${invoice.supplierName ?? 'غير محدد'}'),
                        const SizedBox(height: 5),
                        Text('الإجمالي: ${numberFormat.format(invoiceTotal)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else if (_selectedReportType == ReportType.inventory) {
      final inventoryItems = _generateInventoryReport();
      // حساب القيمة الإجمالية للمخزون
      double totalInventoryValue = inventoryItems.fold(
          0.0, (sum, item) => sum + (item.quantity * item.purchasePrice)); // استخدام purchasePrice لتقييم المخزون

      if (inventoryItems.isEmpty) {
        return const Center(child: Text('المخزون فارغ.'));
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'القيمة الإجمالية للمخزون: ${numberFormat.format(totalInventoryValue)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blue),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: inventoryItems.length,
              itemBuilder: (context, index) {
                final item = inventoryItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الصنف: ${item.name}',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text('الكمية المتوفرة: ${numberFormat.format(item.quantity)} ${item.unit}'),
                        Text('سعر الشراء: ${numberFormat.format(item.purchasePrice)}'),
                        Text('سعر البيع: ${numberFormat.format(item.sellingPrice)}'),
                        Text('القيمة في المخزون: ${numberFormat.format(item.quantity * item.purchasePrice)}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
    return const Center(child: Text('اختر نوع التقرير لعرض البيانات.'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<ReportType>(
                  decoration: const InputDecoration(
                    labelText: 'اختر التقرير',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedReportType,
                  onChanged: (ReportType? newValue) {
                    setState(() {
                      _selectedReportType = newValue!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ReportType.sales,
                      child: Text('تقرير المبيعات'),
                    ),
                    DropdownMenuItem(
                      value: ReportType.purchases,
                      child: Text('تقرير المشتريات'),
                    ),
                    DropdownMenuItem(
                      value: ReportType.inventory,
                      child: Text('تقرير المخزون'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_selectedReportType != ReportType.inventory)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'من تاريخ',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'إلى تاريخ',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(DateFormat('yyyy-MM-dd').format(_endDate)),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // ببساطة نقوم بإعادة بناء الواجهة لتحديث البيانات بناءً على التواريخ المحددة
                    setState(() {});
                  },
                  child: const Text('تحديث التقرير'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ValueListenableBuilder<Box>(
              valueListenable: _selectedReportType == ReportType.inventory
                  ? itemsBox.listenable()
                  : invoicesBox.listenable(),
              builder: (context, box, _) {
                return _buildReportContent();
              },
            ),
          ),
        ],
      ),
    );
  }
}
