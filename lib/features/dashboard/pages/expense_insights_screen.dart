import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/expense_breakdown_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/expense_categories_breakdown_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/expense_time_frame_selector.dart';
import 'package:expense_tracker/features/dashboard/widgets/expense_trend_chart_card.dart';
import 'package:flutter/material.dart';

class ExpenseInsightsScreen extends StatefulWidget {
  const ExpenseInsightsScreen({super.key});

  @override
  State<ExpenseInsightsScreen> createState() => _ExpenseInsightsScreenState();
}

class _ExpenseInsightsScreenState extends State<ExpenseInsightsScreen> {
  String _selectedTimeFrame = 'Daily';
  final List<String> _timeFrames = ['Daily', 'Weekly', 'Monthly', 'Quarterly'];

  // Mock data definitions

  // 1. Daily Mock Data
  final List<ExpenseChartData> _dailyChartData = [
    ExpenseChartData('Jun 09', 500, isHighlighted: true),
    ExpenseChartData('Jun 10', 0),
    ExpenseChartData('Jun 11', 0),
    ExpenseChartData('Jun 12', 0),
    ExpenseChartData('Jun 13', 0),
    ExpenseChartData('Jun 14', 0),
    ExpenseChartData('Jun 15', 0),
  ];

  // 2. Weekly Mock Data
  final List<ExpenseChartData> _weeklyChartData = [
    ExpenseChartData('May 03 - 09', 0),
    ExpenseChartData('May 10 - 16', 8100, isHighlighted: true),
    ExpenseChartData('May 17 - 23', 4300, isHighlighted: true),
    ExpenseChartData('May 24 - 30', 1500, isHighlighted: true),
    ExpenseChartData('May 31 - 06', 0),
    ExpenseChartData('Jun 07 - 13', 400, isHighlighted: true),
    ExpenseChartData('Jun 14 - 20', 0),
  ];

  // 3. Monthly Mock Data
  final List<ExpenseChartData> _monthlyChartData = [
    ExpenseChartData('Jul', 0),
    ExpenseChartData('Aug', 0),
    ExpenseChartData('Sep', 0),
    ExpenseChartData('Oct', 0),
    ExpenseChartData('Nov', 0),
    ExpenseChartData('Dec', 0),
    ExpenseChartData('Jan', 0),
    ExpenseChartData('Feb', 0),
    ExpenseChartData('Mar', 0),
    ExpenseChartData('Apr', 0),
    ExpenseChartData('May', 14053, isHighlighted: true),
    ExpenseChartData('Jun', 500, isHighlighted: true),
  ];

  final List<CategoryBreakdownItem> _monthlyCategories = [
    CategoryBreakdownItem(
      name: 'Medicine',
      amount: 500,
      color: const Color(0xFF2EBD85),
    ),
  ];

  // 4. Quarterly Mock Data
  final List<ExpenseChartData> _quarterlyChartData = [
    ExpenseChartData('Jul - Sep', 0),
    ExpenseChartData('Oct - Dec', 0),
    ExpenseChartData('Jan - Mar', 0),
    ExpenseChartData('Apr - Jun', 14553, isHighlighted: true),
  ];

  final List<CategoryBreakdownItem> _quarterlyCategories = [
    CategoryBreakdownItem(
      name: 'Association Payment',
      amount: 5000,
      color: const Color(0xFF2EBD85),
    ),
    CategoryBreakdownItem(
      name: 'Online Shopping',
      amount: 3000,
      color: const Color(0xFFFFC107),
    ),
    CategoryBreakdownItem(
      name: 'Loan Paid',
      amount: 2400,
      color: const Color(0xFFF06292),
    ),
    CategoryBreakdownItem(
      name: 'Food',
      amount: 1420,
      color: const Color(0xFF5C6BC0),
    ),
    CategoryBreakdownItem(
      name: 'Medicine',
      amount: 1328,
      color: const Color(0xFFAB47BC),
    ),
    CategoryBreakdownItem(
      name: 'Physical Shopping',
      amount: 625,
      color: const Color(0xFFD1C4E9),
    ),
    CategoryBreakdownItem(
      name: 'Coke',
      amount: 410,
      color: const Color(0xFFE91E63),
    ),
    CategoryBreakdownItem(
      name: 'Rickshaw Rental',
      amount: 240,
      color: const Color(0xFF26C6DA),
    ),
    CategoryBreakdownItem(
      name: 'General',
      amount: 100,
      color: const Color(0xFF42A5F5),
    ),
    CategoryBreakdownItem(
      name: 'Dan Sadga',
      amount: 20,
      color: const Color(0xFF26A69A),
    ),
    CategoryBreakdownItem(
      name: 'Bus Rental',
      amount: 10,
      color: const Color(0xFFD4E157),
    ),
  ];

  List<ExpenseBreakdownItem> get _quarterlyBreakdowns => [
    ExpenseBreakdownItem(
      title: 'Cash',
      subtitle: '21 transactions',
      amount: '${context.currencySymbol} 14,553',
      icon: Icons.payments_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Expense Insights',
          style: AppTextStyles.insightsHeaderTitle,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE0E0E0),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeframe selector (toggles between Daily, Weekly, Monthly, Quarterly)
              ExpenseTimeFrameSelector(
                timeFrames: _timeFrames,
                selectedTimeFrame: _selectedTimeFrame,
                onTimeFrameChanged: (tf) {
                  setState(() {
                    _selectedTimeFrame = tf;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Trend Chart Card dependent on timeframe
              if (_selectedTimeFrame == 'Daily')
                ExpenseTrendChartCard(
                  timeFrame: 'Daily',
                  title: 'Expense (Today)',
                  amount: '${context.currencySymbol} 0',
                  chartData: _dailyChartData,
                )
              else if (_selectedTimeFrame == 'Weekly')
                ExpenseTrendChartCard(
                  timeFrame: 'Weekly',
                  title: 'Expense (This Week)',
                  amount: '${context.currencySymbol} 0',
                  trendPercentage: '100.0% This Week',
                  chartData: _weeklyChartData,
                )
              else if (_selectedTimeFrame == 'Monthly')
                ExpenseTrendChartCard(
                  timeFrame: 'Monthly',
                  title: 'Expense (June)',
                  amount: '${context.currencySymbol} 500',
                  trendPercentage: '96.44% This Month',
                  chartData: _monthlyChartData,
                )
              else if (_selectedTimeFrame == 'Quarterly')
                ExpenseTrendChartCard(
                  timeFrame: 'Quarterly',
                  chartData: _quarterlyChartData,
                ),

              // Category Breakdown Card (only for Monthly and Quarterly)
              if (_selectedTimeFrame == 'Monthly') ...[
                const SizedBox(height: 20),
                ExpenseCategoriesBreakdownCard(
                  suffixText: '(This Month)',
                  totalAmount: '${context.currencySymbol} 500',
                  categories: _monthlyCategories,
                ),
              ] else if (_selectedTimeFrame == 'Quarterly') ...[
                const SizedBox(height: 20),
                ExpenseCategoriesBreakdownCard(
                  suffixText: '(This Quarter)',
                  totalAmount: '${context.currencySymbol} 14,553',
                  categories: _quarterlyCategories,
                ),
              ],

              // Expense Breakdown Card (only for Quarterly)
              if (_selectedTimeFrame == 'Quarterly') ...[
                const SizedBox(height: 20),
                ExpenseBreakdownCard(
                  suffixText: '(This Quarter)',
                  items: _quarterlyBreakdowns,
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
