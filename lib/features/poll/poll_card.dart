import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sociale_vote/features/poll/domain/entities/poll_entity.dart';

class PollCard extends StatefulWidget {
  final PollEntity poll;
  final VoidCallback? onTap;
  final Function({required String optionId})? onVote;
  final String? errorMessage;

  const PollCard({
    super.key,
    required this.poll,
    this.onTap,
    this.onVote,
    this.errorMessage,
  });

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final end = widget.poll.configuration.endDate;
    if (end == null) return;

    final diff = end.difference(DateTime.now());

    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isClosed =>
      widget.poll.isClosed || widget.poll.isExpired || _remaining.inSeconds == 0;

  bool get _canVote => !_isClosed && !widget.poll.userHasVoted;

  bool _isUserChoice(String optionId) {
    return widget.poll.userSelectedOptionIds?.contains(optionId) ?? false;
  }

  List<Color> get _colors => const [
        Color(0xFF4F8CFF),
        Color(0xFFFF6B4A),
        Color(0xFF00C2A8),
        Color(0xFFFF8A3D),
        Color(0xFFFF4D6D),
        Color(0xFF2DD4BF),
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(22),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Text(
                widget.poll.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              _buildPieChart(),
              const SizedBox(height: 24),
              _buildResults(),
              if (_canVote) ...[
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),
                ...widget.poll.options.map((option) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => widget.onVote?.call(optionId: option.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2430),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          option.label,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 20),
              _buildFooter(),
              if (widget.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 65,
              pieTouchData: PieTouchData(enabled: false),
              sections: List.generate(
                widget.poll.options.length,
                (index) {
                  final option = widget.poll.options[index];

                  final isUserChoice = _isUserChoice(option.id);

                  return PieChartSectionData(
                    value: option.votes.toDouble(),
                    color: _colors[index % _colors.length],
                    radius: isUserChoice ? 90 : 80,
                    title: '',
                  );
                },
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isClosed)
                const Text(
                  'CHIUSA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                )
              else
                Text(
                  '${_remaining.inMinutes} min',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C2A8),
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                '${widget.poll.totalVotes} voti',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      children: List.generate(
        widget.poll.options.length,
        (index) {
          final option = widget.poll.options[index];

          final percentage = widget.poll.getOptionPercentage(option.votes);

          final color = _colors[index % _colors.length];

          final isUserChoice = _isUserChoice(option.id);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: isUserChoice ? color : Colors.white,
                          fontWeight:
                              isUserChoice ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: const Color(0xFF1F2632),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.public,
          size: 18,
          color: Colors.white54,
        ),
        const SizedBox(width: 6),
        const Text(
          'VOTAZIONE CIVICA',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
          ),
        ),
        const Spacer(),
        _StatusChip(isClosed: _isClosed),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        const Icon(
          Icons.people_outline,
          size: 14,
          color: Colors.white38,
        ),
        const SizedBox(width: 6),
        Text(
          '${widget.poll.totalVotes} partecipanti',
          style: const TextStyle(
            color: Colors.white38,
          ),
        ),
        const Spacer(),
        if (widget.poll.userHasVoted)
          const Text(
            'Hai votato',
            style: TextStyle(
              color: Color(0xFF4F8CFF),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isClosed;

  const _StatusChip({required this.isClosed});

  @override
  Widget build(BuildContext context) {
    final color = isClosed ? Colors.redAccent : const Color(0xFF00C2A8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        isClosed ? 'CHIUSA' : 'APERTA',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}