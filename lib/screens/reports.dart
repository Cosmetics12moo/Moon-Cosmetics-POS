import 'package:flutter/material.dart';
class ReportsScreen extends StatelessWidget { const ReportsScreen({super.key});
 @override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(20),children:[_r(c,'Sales Report',Icons.point_of_sale),_r(c,'Purchase Report',Icons.shopping_cart),_r(c,'Stock / Batch / Expiry',Icons.inventory),_r(c,'Vendor Ledger',Icons.store),_r(c,'Customer Ledger',Icons.people),_r(c,'Profit & Loss',Icons.analytics),_r(c,'Expenses',Icons.payments),_r(c,'Audit Log',Icons.security)]);
 Widget _r(BuildContext c,String t,IconData i)=>Card(child:ListTile(leading:Icon(i),title:Text(t),subtitle:const Text('Date range, filters, totals and export/print'),trailing:const Icon(Icons.chevron_right),onTap:(){}));
}
