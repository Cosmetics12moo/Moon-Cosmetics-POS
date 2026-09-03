import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _card(context, 'Today Sales', 'Rs. 0', Icons.point_of_sale),
        _card(context, 'Purchases', 'Rs. 0', Icons.local_shipping),
        _card(context, 'Receivable', 'Rs. 0', Icons.account_balance_wallet),
        _card(context, 'Low Stock', '0', Icons.warning_amber),
        _card(context, 'Products', '0', Icons.inventory_2),
        _card(context, 'Customers', '0', Icons.people),
        _card(context, 'Vendors', '0', Icons.store),
        _card(context, 'Net Profit', 'Rs. 0', Icons.trending_up),
      ],
    );
  }

  Widget _card(BuildContext context, String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30),
            const Spacer(),
            Text(title),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
