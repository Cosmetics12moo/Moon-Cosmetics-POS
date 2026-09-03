import 'package:flutter/material.dart';
class DashboardScreen extends StatelessWidget { const DashboardScreen({super.key});
 @override Widget build(BuildContext c)=>GridView.count(crossAxisCount:4,padding:const EdgeInsets.all(20),crossAxisSpacing:16,mainAxisSpacing:16,children:[_card(c,'Today Sales','Rs. 0',Icons.point_of_sale),_card(c,'Purchases','Rs. 0',Icons.local_shipping),_card(c,'Receivable','Rs. 0',Icons.account_balance_wallet),_card(c,'Low Stock','0',Icons.warning_amber),_card(c,'Products','0',Icons.inventory_2),_card(c,'Customers','0',Icons.people),_card(c,'Vendors','0',Icons.store),_card(c,'Net Profit','Rs. 0',Icons.trending_up)]);
 }
 Widget _card(BuildContext c,String t,String v,IconData i)=>Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(i,size:30),const Spacer(),Text(t),Text(v,style:Theme.of(c).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.bold))])));
}
