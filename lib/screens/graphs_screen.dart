import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/block.dart';
import '../theme.dart';

class GraphsScreen extends StatelessWidget {
  final Block block;
  final List<dynamic> logs;

  const GraphsScreen({super.key, required this.block, required this.logs});

  List<FlSpot> _buildSpots() {
    final sorted = List<dynamic>.from(logs)
      ..sort((a, b) => a['log_date'].compareTo(b['log_date']));

    final spots = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      final log = sorted[i];
      final responses = log['responses'] as List? ?? [];
      for (final r in responses) {
        if (r['question_text'] == 'Pain Scale') {
          final val = double.tryParse(r['response_value'] ?? '0') ?? 0;
          spots.add(FlSpot(i.toDouble(), val));
          break;
        }
      }
    }
    return spots;
  }

  List<BarChartGroupData> _buildBars() {
    final Map<int, int> weekCounts = {};
    for (final log in logs) {
      final date = DateTime.parse(log['log_date']);
      final week = date.difference(DateTime(date.year)).inDays ~/ 7;
      weekCounts[week] = (weekCounts[week] ?? 0) + 1;
    }
    return weekCounts.entries.map((e) => BarChartGroupData(
      x: e.key,
      barRods: [
        BarChartRodData(
          toY: e.value.toDouble(),
          color: AppColors.primary,
          width: 16,
        ),
      ],
    )).toList();
  }

  @override
  @override
  Widget build(BuildContext ctx) {
    final spots = block.blockType == 'pain' ? _buildSpots() : <FlSpot>[];
    final bars = _buildBars();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('${block.name} Graphs'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (block.blockType == 'pain') ...[
              const Text('Pain Trend',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: spots.isEmpty
                    ? const Center(child: Text('Not enough data'))
                    : LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 10,
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppColors.primary,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.15),
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, _) =>
                              Text(v.toInt().toString()),
                        ),
                      ),
                      bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
            const Text('Weekly Frequency',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: bars.isEmpty
                  ? const Center(child: Text('Not enough data'))
                  : BarChart(
                BarChartData(
                  barGroups: bars,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, _) =>
                            Text(v.toInt().toString()),
                      ),
                    ),
                    bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
