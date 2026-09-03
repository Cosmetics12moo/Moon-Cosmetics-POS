import 'package:flutter/material.dart';
import '../core/config.dart';
class SettingsScreen extends StatelessWidget { const SettingsScreen({super.key}); @override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(16),children:[Image.asset(PosConfig.logoAsset,height:120),const ListTile(title:Text('Shop Name'),subtitle:Text('Moon Cosmetics & Beauty Shop')),const ListTile(title:Text('Invoice'),subtitle:Text('Logo, shop name, footer and print settings'))]); }
