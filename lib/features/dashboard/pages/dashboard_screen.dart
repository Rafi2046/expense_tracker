import 'package:expense_tracker/core/widgets/common_widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBarWidget(title: 'Ledger',)
        ],
      )
    );
  }
}
