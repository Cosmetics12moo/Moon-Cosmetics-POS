import 'package:flutter/material.dart';
import 'screens/dashboard.dart';
import 'screens/pos.dart';
import 'screens/products.dart';
import 'screens/categories.dart';
import 'screens/purchases.dart';
import 'screens/reports.dart';
import 'screens/settings.dart';

class MoonCosmeticsApp extends StatelessWidget {
  const MoonCosmeticsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Moon Cosmetics & Beauty Shop',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.pink),
    home: const PosShell(),
  );
}

class PosShell extends StatefulWidget {
  const PosShell({super.key});
  @override State<PosShell> createState() => _PosShellState();
}
class _PosShellState extends State<PosShell> {
  int index = 0;
  static const labels = ['Dashboard','POS / Sales','Products','Categories','Purchases','Reports','Settings'];
  static const icons = [Icons.dashboard_outlined,Icons.point_of_sale_outlined,Icons.inventory_2_outlined,Icons.category_outlined,Icons.local_shipping_outlined,Icons.assessment_outlined,Icons.settings_outlined];
  final pages = const [DashboardScreen(),PosScreen(),ProductsScreen(),CategoriesScreen(),PurchasesScreen(),ReportsScreen(),SettingsScreen()];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(labels[index])),
    drawer: Drawer(child: SafeArea(child: Column(children: [const SizedBox(height:12), Image(image: AssetImage('assets/moon_logo.png'),height:90), const Padding(padding: EdgeInsets.all(8), child: Text('Moon Cosmetics & Beauty Shop',style: TextStyle(fontWeight: FontWeight.bold))), const Divider(), for(int i=0;i<labels.length;i++) ListTile(selected:index==i,leading:Icon(icons[i]),title:Text(labels[i]),onTap:(){setState(()=>index=i);Navigator.pop(context);})]))),
    body: pages[index],
  );
}
