import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sociale_vote/domain/poll/entities/poll_result.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

/// Widget di presentazione che mostra i risultati di un poll
/// (percentuali per opzione) utilizzando un grafico a barre.
///
/// Input:
/// - [result]: [PollResult] di dominio, già aggregato.
class PollResultChart extends StatelessWidget {
  final PollResult result;

  const PollResultChart({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    if (result.optionResults.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final maxPercentage = _computeMaxPercentage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.pollResult_title(result.totalVotes),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxPercentage > 0 ? maxPercentage : 100.0,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
              ),
              borderData: FlBorderData(
                show: false,
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 20,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}%',
                        style: theme.textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= result.optionResults.length) {
                        return const SizedBox.shrink();
                      }
                      final option = result.optionResults[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          option.label,
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: _buildBarGroups(theme),
            ),
          ),
        ),
      ],
    );
  }

  double _computeMaxPercentage() {
    if (result.optionResults.isEmpty) {
      return 0.0;
    }

    final max = result.optionResults
        .map((e) => e.percentage)
        .fold<double>(0.0, (prev, value) => value > prev ? value : prev);

    // per evitare grafico troppo compresso, arrotondiamo in alto
    if (max <= 0) return 0.0;
    if (max <= 25) return 25;
    if (max <= 50) return 50;
    if (max <= 75) return 75;
    return 100;
  }

  List<BarChartGroupData> _buildBarGroups(ThemeData theme) {
    return List.generate(result.optionResults.length, (index) {
      final option = result.optionResults[index];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: option.percentage,
            width: 18,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            // Usiamo il primary color del tema per le barre.
            color: theme.colorScheme.primary,
          ),
        ],
        showingTooltipIndicators: const [0],
      );
    });
  }
}