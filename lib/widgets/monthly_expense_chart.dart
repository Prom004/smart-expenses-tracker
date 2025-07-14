import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MonthlyExpenseChart extends StatelessWidget {
  final Map<String, double> monthlyTotals;
  const MonthlyExpenseChart({Key? key, required this.monthlyTotals}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (monthlyTotals.isEmpty) {
      return const Center(child: Text('No data for chart'));
    }

    final sortedKeys = monthlyTotals.keys.toList()..sort();
    final maxY = monthlyTotals.values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          barGroups: [
            for (int i = 0; i < sortedKeys.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: monthlyTotals[sortedKeys[i]]!,
                    width: 20,
                    borderRadius: BorderRadius.zero,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= sortedKeys.length) {
                    return const SizedBox.shrink();
                  }
                  DateTime monthDate = DateFormat('yyyy-MM').parse(sortedKeys[value.toInt()]);
                  String label = DateFormat('MMM yy').format(monthDate);
                  return Text(label, style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
