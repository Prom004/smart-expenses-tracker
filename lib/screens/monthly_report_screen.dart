import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/database_provider.dart';
import '../models/theme_provider.dart';
import 'package:intl/intl.dart';
import '../widgets/monthly_expense_chart.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({Key? key}) : super(key: key);
  static const name = '/monthly_report';

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  Map<String, double> _monthlyTotals = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthlyReport();
  }

  Future<void> _loadMonthlyReport() async {
    final userId = Provider.of<ThemeProvider>(context, listen: false).currentUser?.id;
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final expenses = await dbProvider.fetchAllExpenses(userId);

    Map<String, double> monthlyTotals = {};

    for (var exp in expenses) {
      String monthKey = DateFormat('yyyy-MM').format(exp.date);
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + exp.amount;
    }

    setState(() {
      _monthlyTotals = monthlyTotals;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Expense Report'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _monthlyTotals.isEmpty
              ? const Center(child: Text('No expenses found.'))
              : Column(
                  children: [
                    MonthlyExpenseChart(monthlyTotals: _monthlyTotals),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _monthlyTotals.length,
                        itemBuilder: (context, index) {
                          String monthKey = _monthlyTotals.keys.elementAt(index);
                          double total = _monthlyTotals[monthKey]!;
                          DateTime monthDate = DateFormat('yyyy-MM').parse(monthKey);
                          String monthLabel = DateFormat('MMMM yyyy').format(monthDate);
                          return ListTile(
                            title: Text(monthLabel),
                            trailing: Text('\$${total.toStringAsFixed(2)}'),
                          );
                        },
                ),
    );
  }
  }
