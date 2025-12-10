import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class UsageChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> usageHistory;

  const UsageChartWidget({
    super.key,
    required this.usageHistory,
  });

  @override
  State<UsageChartWidget> createState() => _UsageChartWidgetState();
}

class _UsageChartWidgetState extends State<UsageChartWidget> {
  bool _showMinutes = true;

  Map<String, int> _calculateDailyData() {
    final Map<String, int> dailyData = {};

    for (final record in widget.usageHistory) {
      final date = DateTime.parse(record['created_at'] as String);
      final dateKey = DateFormat('dd MMM').format(date);
      final usageType = record['usage_type'] as String;

      if (_showMinutes && usageType == 'call') {
        final duration = record['duration_seconds'] as int? ?? 0;
        final minutes = (duration / 60).ceil();
        dailyData[dateKey] = (dailyData[dateKey] ?? 0) + minutes;
      } else if (!_showMinutes && usageType == 'sms') {
        dailyData[dateKey] = (dailyData[dateKey] ?? 0) + 1;
      }
    }

    return dailyData;
  }

  @override
  Widget build(BuildContext context) {
    final dailyData = _calculateDailyData();
    final dates = dailyData.keys.toList();
    final values = dailyData.values.toList();

    if (dates.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'Geen gegevens beschikbaar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gebruikstrend',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Minuten'),
                      icon: Icon(Icons.phone, size: 16),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('SMS'),
                      icon: Icon(Icons.message, size: 16),
                    ),
                  ],
                  selected: {_showMinutes},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _showMinutes = newSelection.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[200]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < dates.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                dates[index],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  minX: 0,
                  maxX: (dates.length - 1).toDouble(),
                  minY: 0,
                  maxY: values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        values.length,
                        (index) =>
                            FlSpot(index.toDouble(), values[index].toDouble()),
                      ),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: _showMinutes
                            ? [Colors.blue, Colors.blue[700]!]
                            : [Colors.green, Colors.green[700]!],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: _showMinutes
                              ? [
                                  Colors.blue.withAlpha(77),
                                  Colors.blue.withAlpha(26),
                                ]
                              : [
                                  Colors.green.withAlpha(77),
                                  Colors.green.withAlpha(26),
                                ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
