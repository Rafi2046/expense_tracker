import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/dashboard/widgets/daily_distribution_chart.dart';
import 'package:expense_tracker/features/dashboard/widgets/financial_health_banner.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_summary_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_transaction_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_trend_chart.dart';
import 'package:expense_tracker/features/dashboard/widgets/quarterly_trend_chart.dart';
import 'package:expense_tracker/features/dashboard/widgets/time_frame_selector.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_container_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_list_container.dart';
import 'package:expense_tracker/features/dashboard/widgets/weekly_trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IncomeInsightsScreen extends StatefulWidget {
  const IncomeInsightsScreen({super.key});

  @override
  State<IncomeInsightsScreen> createState() => _IncomeInsightsScreenState();
}

class _IncomeInsightsScreenState extends State<IncomeInsightsScreen> {
  String _selectedTimeFrame = 'Monthly';
  final List<String> _timeFrames = ['Daily', 'Weekly', 'Monthly', 'Quarterly'];

  // Monthly data
  final List<ChartData> _chartData = [
    ChartData('JAN', 4200),
    ChartData('FEB', 4800),
    ChartData('MAR', 5100),
    ChartData('APR', 5800),
    ChartData('MAY', 5500),
    ChartData('JUN', 8420, isCurrent: true),
    ChartData('JUL', 6400),
    ChartData('AUG', 5800),
    ChartData('SEP', 7200),
    ChartData('OCT', 6900),
    ChartData('NOV', 7400),
    ChartData('DEC', 7900),
  ];

  // Daily data
  final List<DailyChartData> _dailyChartData = [
    DailyChartData('00:00', 10),
    DailyChartData(' ', 8),
    DailyChartData('  ', 6),
    DailyChartData('06:00', 12),
    DailyChartData('   ', 30),
    DailyChartData('    ', 45),
    DailyChartData('12:00', 55, isHighlighted: true),
    DailyChartData('     ', 25),
    DailyChartData('      ', 15),
    DailyChartData('18:00', 20),
    DailyChartData('       ', 10),
    DailyChartData('23:59', 5),
  ];

  // Weekly data
  final List<WeeklyChartData> _weeklyChartData = [
    WeeklyChartData('Mon', 120),
    WeeklyChartData('Tue', 250),
    WeeklyChartData('Wed', 480, isHighlighted: true),
    WeeklyChartData('Thu', 310),
    WeeklyChartData('Fri', 200),
    WeeklyChartData('Sat', 150),
    WeeklyChartData('Sun', 340),
  ];

  // Quarterly data
  final List<QuarterlyChartData> _quarterlyChartData = [
    QuarterlyChartData('JUL', 6400),
    QuarterlyChartData('AUG', 5800),
    QuarterlyChartData('SEP', 7200, isHighlighted: true),
  ];

  Widget _buildSummaryCard() {
    switch (_selectedTimeFrame) {
      case 'Daily':
        return IncomeSummaryCard(
          label: 'Total Daily Income',
          amount: '\$240.00',
          showDivider: true,
          bottomContent: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vs Yesterday',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.loginSubTitle,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.trending_up, color: AppColors.activeGreen, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '+12.5%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.activeGreen,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case 'Weekly':
        return IncomeSummaryCard(
          label: 'Total Weekly Income',
          amount: '\$1,850.00',
          showDivider: true,
          bottomContent: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avg. Daily',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.loginSubTitle,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                  Text(
                    '\$264.28',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vs Last Week',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.loginSubTitle,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: AppColors.activeGreen, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+12.4%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.activeGreen,
                          fontFamily: GoogleFonts.workSans().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      case 'Quarterly':
        return IncomeSummaryCard(
          label: 'Total Quarterly Income',
          amount: '\$24,560.00',
          percentageText: '+12.4% vs Q2',
          showDivider: true,
          bottomContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Projected Year End',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.loginSubTitle,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                  Text(
                    '\$98,240.00',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: const LinearProgressIndicator(
                  value: 0.25,
                  backgroundColor: Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.activeGreen),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        );
      case 'Monthly':
      default:
        return const IncomeSummaryCard(
          label: 'Total Monthly Income',
          amount: '+\$8,420.00',
          percentageText: '+12.4%',
          compareText: 'vs. last month',
        );
    }
  }

  Widget _buildTimeFrameContent() {
    switch (_selectedTimeFrame) {
      case 'Daily':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DailyDistributionChart(data: _dailyChartData),
            const SizedBox(height: 24),
            TransactionListContainer(
              title: "Today's Income",
              trailing: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: AppTextStyles.viewAllText,
                ),
              ),
              children: const [
                TransactionContainerRow(
                  icon: Icons.work_outline,
                  title: 'Freelance Payment',
                  subtitle: 'Project: Emerald Design System',
                  amount: '+\$180.00',
                  subAmountLabel: '14:32',
                ),
                TransactionContainerRow(
                  icon: Icons.savings_outlined,
                  title: 'Dividend Yield',
                  subtitle: 'Monthly Asset Distribution',
                  amount: '+\$45.50',
                  subAmountLabel: '10:15',
                ),
                TransactionContainerRow(
                  icon: Icons.receipt_long_outlined,
                  title: 'Consultation Fee',
                  subtitle: 'Retainer: Weekly Sync',
                  amount: '+\$14.50',
                  subAmountLabel: '09:00',
                ),
              ],
            ),
          ],
        );
      case 'Weekly':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeeklyTrendChart(data: _weeklyChartData),
            const SizedBox(height: 24),
            TransactionListContainer(
              title: 'Weekly Activity',
              trailing: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: AppTextStyles.viewAllText,
                ),
              ),
              children: const [
                TransactionContainerRow(
                  icon: Icons.work_outline,
                  title: 'Freelance Project Payment',
                  subtitle: 'Oct 24, 2023 • Digital Services',
                  amount: '+\$1,200.00',
                ),
                TransactionContainerRow(
                  icon: Icons.account_balance_outlined,
                  title: 'Dividends Reinvestment',
                  subtitle: 'Oct 22, 2023 • Investment',
                  amount: '+\$450.00',
                ),
                TransactionContainerRow(
                  icon: Icons.receipt_long_outlined,
                  title: 'Consulting Fee',
                  subtitle: 'Oct 20, 2023 • Consultation',
                  amount: '+\$200.00',
                ),
              ],
            ),
          ],
        );
      case 'Quarterly':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuarterlyTrendChart(data: _quarterlyChartData),
            const SizedBox(height: 24),
            TransactionListContainer(
              title: 'Major Quarterly Earnings',
              trailing: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Download PDF\nReport',
                  style: AppTextStyles.viewAllText,
                  textAlign: TextAlign.end,
                ),
              ),
              children: const [
                TransactionContainerRow(
                  icon: Icons.receipt_long_outlined,
                  title: 'Senior Consultant Retainer',
                  subtitle: 'Vertex Global Solutions • Monthly Recurring',
                  amount: '\$15,000.00',
                  subAmountLabel: 'Total for Q3',
                ),
                TransactionContainerRow(
                  icon: Icons.account_balance_outlined,
                  title: 'Stock Portfolio Dividends',
                  subtitle: 'Vanguard Total Stock Market • Distributed Sep 15',
                  amount: '\$4,210.50',
                  subAmountLabel: 'One-time Event',
                ),
                TransactionContainerRow(
                  icon: Icons.work_outline,
                  title: 'UI Audit Freelance',
                  subtitle: 'Fintech Startup X • Project Complete',
                  amount: '\$3,500.00',
                  subAmountLabel: 'Invoice #4402',
                ),
                TransactionContainerRow(
                  icon: Icons.home_work_outlined,
                  title: 'Rental Property Income',
                  subtitle: 'Unit 4B - Oakwood Gardens • Net Profit',
                  amount: '\$1,849.50',
                  subAmountLabel: 'Total for Q3',
                ),
              ],
            ),
          ],
        );
      case 'Monthly':
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IncomeTrendChart(data: _chartData),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Income',
                  style: AppTextStyles.sectionHeaderTitle,
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View All',
                    style: AppTextStyles.viewAllText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                IncomeTransactionRow(
                  icon: Icons.account_balance_outlined,
                  title: 'Monthly Salary',
                  subtitle: 'Oct 24, 2023 • Tech Corp',
                  amount: '+\$5,200.00',
                  status: 'completed',
                ),
                SizedBox(height: 12),
                IncomeTransactionRow(
                  icon: Icons.work_outline_rounded,
                  title: 'Freelance Project',
                  subtitle: 'Oct 20, 2023 • UI Design',
                  amount: '+\$1,850.00',
                  status: 'completed',
                ),
                SizedBox(height: 12),
                IncomeTransactionRow(
                  icon: Icons.show_chart_rounded,
                  title: 'Stock Dividends',
                  subtitle: 'Oct 18, 2023 • Portfolio',
                  amount: '+\$420.00',
                  status: 'completed',
                ),
                SizedBox(height: 12),
                IncomeTransactionRow(
                  icon: Icons.home_work_outlined,
                  title: 'Rental Income',
                  subtitle: 'Oct 15, 2023 • Apt 4B',
                  amount: '+\$950.00',
                  status: 'completed',
                ),
              ],
            ),
          ],
        );
    }
  }

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
          'Income Insights',
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
              // Summary card
              _buildSummaryCard(),
              const SizedBox(height: 20),

              // Timeframe selector
              TimeFrameSelector(
                timeFrames: _timeFrames,
                selectedTimeFrame: _selectedTimeFrame,
                onTimeFrameChanged: (tf) {
                  setState(() {
                    _selectedTimeFrame = tf;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Timeframe-dependent content
              _buildTimeFrameContent(),
              const SizedBox(height: 24),

              // Bottom Banner
              const FinancialHealthBanner(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
