import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/purchase_repository.dart';

class PurchaseLine {
  String productId = '';
  String productName = '';
  int quantity = 1;
  double purchaseCost = 0;
  double tradeOffer = 0;
  double purchaseDiscount = 0;
  double salePrice = 0;

  double get gross => quantity * purchaseCost;
  double get discountAmount => gross * purchaseDiscount / 100;
  double get net => gross - discountAmount;
}

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final repo = PurchaseRepository();
  final vendor = TextEditingController();
  final bill = TextEditingController();
  final paid = TextEditingController(text: '0');
  final bd = TextEditingController(text: '0');
  final exp = TextEditingController(text: '0');

  DateTime date = DateTime.now();
  String? accountId;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> accounts = [];
  final lines = <PurchaseLine>[PurchaseLine()];
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in [vendor, bill, paid, bd, exp]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      products = await repo.products();
      accounts = await repo.accounts();
      if (accounts.isNotEmpty) {
        accountId = accounts.first['id'].toString();
      }
    } catch (e) {
      _snack('Database: $e');
    }
    if (mounted) {
      setState(() => loading = false);
    }
  }

  double _number(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '').trim()) ?? 0;
  }

  double get subtotal => lines.fold(0, (sum, line) => sum + line.gross);
  double get productDiscount =>
      lines.fold(0, (sum, line) => sum + line.discountAmount);
  double get afterProductDiscount => subtotal - productDiscount;
  double get billDiscountAmount => afterProductDiscount * _number(bd) / 100;
  double get expensesAmount =>
      (afterProductDiscount - billDiscountAmount) * _number(exp) / 100;
  double get total =>
      afterProductDiscount - billDiscountAmount + expensesAmount;
  double get balance => total - _number(paid);

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      border: const OutlineInputBorder(),
    );
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _save() async {
    if (accountId == null) {
      _snack('Payment Account منتخب کریں۔');
      return;
    }

    if (lines.any((line) => line.productId.isEmpty || line.quantity <= 0)) {
      _snack('ہر لائن میں Product اور Quantity درج کریں۔');
      return;
    }

    setState(() => saving = true);

    try {
      await repo.save(
        vendorName: vendor.text,
        billNumber: bill.text,
        accountId: accountId!,
        date: date,
        billDiscountPercent: _number(bd),
        expensesPercent: _number(exp),
        paidAmount: _number(paid),
        lines: lines
            .map(
              (line) => PurchaseLineInput(
                productId: line.productId,
                quantity: line.quantity,
                purchaseCost: line.purchaseCost,
                tradeOfferPercent: line.tradeOffer,
                purchaseDiscountPercent: line.purchaseDiscount,
                salePrice: line.salePrice,
              ),
            )
            .toList(),
      );

      _snack(
        'Purchase saved successfully. Stock, vendor ledger, account and batch updated.',
      );
      _clear();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  void _clear() {
    vendor.clear();
    bill.clear();
    paid.text = '0';
    bd.text = '0';
    exp.text = '0';
    date = DateTime.now();
    lines
      ..clear()
      ..add(PurchaseLine());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Purchase / Vendor Bill',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _previousBills(context),
                icon: const Icon(Icons.history),
                label: const Text('Previous Bills'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _vendorHistory(context),
                icon: const Icon(Icons.person_search),
                label: const Text('Vendor History'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: vendor,
                      decoration: _decoration('Vendor *'),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: TextField(
                      controller: bill,
                      decoration: _decoration('Bill Number *'),
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    child: InputDecorator(
                      decoration: _decoration('Date'),
                      child: InkWell(
                        onTap: _pickDate,
                        child: Text(DateFormat('dd-MM-yyyy').format(date)),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 230,
                    child: DropdownButtonFormField<String>(
                      initialValue: accountId,
                      decoration: _decoration('Payment Account *'),
                      items: accounts
                          .map(
                            (account) => DropdownMenuItem<String>(
                              value: account['id'].toString(),
                              child: Text(account['name'].toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => accountId = value),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Product')),
                        DataColumn(label: Text('Qty')),
                        DataColumn(label: Text('Purchase Cost')),
                        DataColumn(label: Text('Trade Offer %')),
                        DataColumn(label: Text('Purchase Discount %')),
                        DataColumn(label: Text('Sale Cost')),
                        DataColumn(label: Text('Net')),
                        DataColumn(label: Text('')),
                      ],
                      rows: List.generate(lines.length, _row),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () => setState(() => lines.add(PurchaseLine())),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Invoice Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 210,
                        child: TextField(
                          controller: bd,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: _decoration('Bill Discount %'),
                        ),
                      ),
                      SizedBox(
                        width: 210,
                        child: TextField(
                          controller: exp,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: _decoration('Expenses %'),
                        ),
                      ),
                      SizedBox(
                        width: 210,
                        child: TextField(
                          controller: paid,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: _decoration('Paid Amount'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 380,
                      child: Column(
                        children: [
                          _sum('Subtotal', subtotal),
                          _sum('Product Discount', productDiscount),
                          _sum('Bill Discount', billDiscountAmount),
                          _sum('Expenses', expensesAmount),
                          const Divider(),
                          _sum('Total Amount', total, true),
                          _sum('Paid Amount', _number(paid)),
                          _sum('Balance', balance, true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: saving ? null : _clear,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: saving ? null : _save,
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(saving ? 'Saving...' : 'Save Purchase'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DataRow _row(int index) {
    final line = lines[index];
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 250,
            child: DropdownButton<String>(
              isExpanded: true,
              value: line.productId.isEmpty ? null : line.productId,
              hint: const Text('Select product'),
              items: products
                  .map(
                    (product) => DropdownMenuItem<String>(
                      value: product['id'].toString(),
                      child: Text(
                        '${product['name']}${product['brand'] == null ? '' : ' — ${product['brand']}'}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  line.productId = value;
                  final product = products.firstWhere(
                    (item) => item['id'].toString() == value,
                  );
                  line.productName = product['name'].toString();
                  line.purchaseCost =
                      (product['purchase_price'] as num?)?.toDouble() ?? 0;
                  line.salePrice =
                      (product['retail_price'] as num?)?.toDouble() ?? 0;
                });
              },
            ),
          ),
        ),
        DataCell(_numField(line.quantity.toString(), (value) {
          setState(() => line.quantity = int.tryParse(value) ?? 0);
        })),
        DataCell(_numField(line.purchaseCost.toStringAsFixed(2), (value) {
          setState(() => line.purchaseCost = double.tryParse(value) ?? 0);
        })),
        DataCell(_numField(line.tradeOffer.toStringAsFixed(2), (value) {
          setState(() => line.tradeOffer = double.tryParse(value) ?? 0);
        })),
        DataCell(_numField(line.purchaseDiscount.toStringAsFixed(2), (value) {
          setState(() => line.purchaseDiscount = double.tryParse(value) ?? 0);
        })),
        DataCell(_numField(line.salePrice.toStringAsFixed(2), (value) {
          setState(() => line.salePrice = double.tryParse(value) ?? 0);
        })),
        DataCell(
          Text(
            'Rs. ${line.net.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(
          IconButton(
            onPressed: lines.length == 1
                ? null
                : () => setState(() => lines.removeAt(index)),
            icon: const Icon(Icons.delete_outline),
          ),
        ),
      ],
    );
  }

  Widget _numField(String initial, void Function(String) callback) {
    return SizedBox(
      width: 125,
      child: TextFormField(
        initialValue: initial,
        onChanged: callback,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _sum(String label, double value, [bool strong = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight:
                    strong ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            'Rs. ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: strong ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (selected != null && mounted) {
      setState(() => date = selected);
    }
  }

  Future<void> _previousBills(BuildContext context) async {
    final rows = await repo.previousBills(vendor.text);
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          vendor.text.isEmpty
              ? 'Previous Bills'
              : 'Previous Bills — ${vendor.text}',
        ),
        content: SizedBox(
          width: 780,
          height: 430,
          child: rows.isEmpty
              ? const Center(child: Text('No previous bills found.'))
              : ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    return ListTile(
                      title: Text(
                        '${row['bill_number'] ?? '—'}  •  ${row['vendor'] ?? ''}',
                      ),
                      subtitle: Text(
                        '${DateFormat('dd-MM-yyyy').format(DateTime.parse(row['date'].toString()))}  |  '
                        'Total Rs. ${row['total_amount']}  |  '
                        'Paid Rs. ${row['paid_amount']}  |  '
                        'Balance Rs. ${row['balance_amount']}',
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _vendorHistory(BuildContext context) async {
    final summary = await repo.vendorSummary(vendor.text);
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Vendor History — ${summary['name']}'),
        content: SizedBox(
          width: 700,
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Opening Balance: Rs. ${summary['opening_balance']}'),
              Text('Total Purchases: Rs. ${summary['purchases']}'),
              Text('Total Paid: Rs. ${summary['paid']}'),
              Text('Current Balance: Rs. ${summary['balance']}'),
              const SizedBox(height: 18),
              const Text(
                'Previous Bills can be opened from “Previous Bills”.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
