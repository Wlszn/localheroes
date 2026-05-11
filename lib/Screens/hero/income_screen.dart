import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Controllers/task_controller.dart';
import '../../Models/task_model.dart';
import 'dart:ui' as ui;

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController _taskController = TaskController();

    return StreamBuilder<List<TaskModel>>(
      stream: _taskController.getHeroCompletedTasks(),
      builder: (context, snapshot) {
        final completedTasks = snapshot.data ?? [];
        final assignedStream = _taskController.getHeroAssignedTasks();

        return StreamBuilder<List<TaskModel>>(
          stream: assignedStream,
          builder: (context, assignedSnap) {
            final assignedTasks = assignedSnap.data ?? [];
            return _IncomeBody(
              completedTasks: completedTasks,
              assignedTasks: assignedTasks,
              isLoading: snapshot.connectionState == ConnectionState.waiting,
            );
          },
        );
      },
    );
  }
}

class _IncomeBody extends StatelessWidget {
  final List<TaskModel> completedTasks;
  final List<TaskModel> assignedTasks;
  final bool isLoading;

  const _IncomeBody({
    required this.completedTasks,
    required this.assignedTasks,
    required this.isLoading,
  });

  // ── Computed stats ────────────────────────────────────────────────────────

  double get totalEarnings => completedTasks.fold(0, (sum, t) => sum + t.price);

  double get thisMonthEarnings {
    final now = DateTime.now();
    return completedTasks
        .where(
          (t) =>
              t.completedAt != null &&
              t.completedAt!.year == now.year &&
              t.completedAt!.month == now.month,
        )
        .fold(0, (sum, t) => sum + t.price);
  }

  double get lastMonthEarnings {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    return completedTasks
        .where(
          (t) =>
              t.completedAt != null &&
              t.completedAt!.year == lastMonth.year &&
              t.completedAt!.month == lastMonth.month,
        )
        .fold(0, (sum, t) => sum + t.price);
  }

  double get thisWeekEarnings {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return completedTasks
        .where(
          (t) => t.completedAt != null && t.completedAt!.isAfter(weekStart),
        )
        .fold(0, (sum, t) => sum + t.price);
  }

  int get thisWeekJobs {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return completedTasks
        .where(
          (t) => t.completedAt != null && t.completedAt!.isAfter(weekStart),
        )
        .length;
  }

  double get pendingEarnings =>
      assignedTasks.fold(0, (sum, t) => sum + t.price);

  String get monthOverMonthText {
    if (lastMonthEarnings == 0) {
      return thisMonthEarnings > 0
          ? 'First earnings this month!'
          : 'No data yet';
    }
    final pct =
        ((thisMonthEarnings - lastMonthEarnings) / lastMonthEarnings * 100)
            .toStringAsFixed(1);
    final sign = thisMonthEarnings >= lastMonthEarnings ? '+' : '';
    return '$sign$pct% from last month';
  }

  /// Returns daily earnings for the last 7 weeks (one data point per week)
  List<double> get weeklyTrend {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final weekStart = now.subtract(
        Duration(days: now.weekday - 1 + (6 - i) * 7),
      );
      final weekEnd = weekStart.add(const Duration(days: 7));
      return completedTasks
          .where(
            (t) =>
                t.completedAt != null &&
                t.completedAt!.isAfter(weekStart) &&
                t.completedAt!.isBefore(weekEnd),
          )
          .fold<double>(0, (sum, t) => sum + t.price);
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                'This Month',
                                '\$${thisMonthEarnings.toStringAsFixed(0)}',
                                monthOverMonthText,
                                isPositive:
                                    thisMonthEarnings >= lastMonthEarnings,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                'This Week',
                                '\$${thisWeekEarnings.toStringAsFixed(0)}',
                                '$thisWeekJobs job${thisWeekJobs != 1 ? 's' : ''} completed',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _statCard(
                          'Pending',
                          '\$${pendingEarnings.toStringAsFixed(0)}',
                          '${assignedTasks.length} active job${assignedTasks.length != 1 ? 's' : ''}',
                        ),
                        const SizedBox(height: 20),
                        _trendCard(),
                        const SizedBox(height: 20),
                        _transactionsCard(),
                        const SizedBox(height: 20),
                        _balanceCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00A63E), Color(0xFF155DFC)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earnings Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Track your income and growth',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF23B6A8), Color(0xFF268DE8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Earnings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${totalEarnings.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  completedTasks.isEmpty
                      ? 'Complete tasks to start earning'
                      : '${completedTasks.length} task${completedTasks.length != 1 ? 's' : ''} completed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String title,
    String amount,
    String subtitle, {
    bool isPositive = true,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 28),
          Text(
            amount,
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: subtitle.startsWith('+') || isPositive
                  ? Colors.green
                  : Colors.redAccent,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendCard() {
    final trend = weeklyTrend;
    final maxVal = trend.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings Trend (Last 7 Weeks)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Weekly earnings based on completed tasks',
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: maxVal == 0
                ? const Center(
                    child: Text(
                      'Complete tasks to see your trend',
                      style: TextStyle(color: Colors.black38, fontSize: 13),
                    ),
                  )
                : CustomPaint(
                    painter: _EarningsChartPainter(trend),
                    child: Container(),
                  ),
          ),
          const SizedBox(height: 12),
          // Week labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final now = DateTime.now();
              final weekStart = now.subtract(
                Duration(days: now.weekday - 1 + (6 - i) * 7),
              );
              return Text(
                DateFormat('M/d').format(weekStart),
                style: const TextStyle(fontSize: 10, color: Colors.black45),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _transactionsCard() {
    final recent = [...completedTasks]
      ..sort(
        (a, b) => (b.completedAt ?? b.createdAt).compareTo(
          a.completedAt ?? a.createdAt,
        ),
      );
    final display = recent.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (display.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No completed tasks yet',
                  style: TextStyle(color: Colors.black38, fontSize: 13),
                ),
              ),
            )
          else
            ...display.map((t) {
              final dateStr = t.completedAt != null
                  ? DateFormat('M/d/yyyy').format(t.completedAt!)
                  : DateFormat('M/d/yyyy').format(t.createdAt);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 17,
                      backgroundColor: Color(0xFFDCFCE7),
                      child: Text(
                        '\$',
                        style: TextStyle(
                          color: Color(0xFF16A34A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+\$${t.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Color(0xFF00A63E),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Completed',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Balance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${thisMonthEarnings.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF155DFC),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF155DFC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Withdraw Funds'),
          ),
        ],
      ),
    );
  }
}

// ── Chart painter ─────────────────────────────────────────────────────────────

class _EarningsChartPainter extends CustomPainter {
  final List<double> data;

  _EarningsChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return;

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2563EB).withOpacity(0.18),
          const Color(0xFF2563EB).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Data points
    final points = List.generate(data.length, (i) {
      final x = size.width * i / (data.length - 1);
      final y = size.height - (data[i] / maxVal) * size.height * 0.85 - 8;
      return Offset(x, y);
    });

    // Fill area
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, linePaint);

    // Dots + value labels
    final textStyle = const TextStyle(
      color: Color(0xFF2563EB),
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5, dotPaint);
      if (data[i] > 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: '\$${data[i].toStringAsFixed(0)}',
            style: textStyle,
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(points[i].dx - tp.width / 2, points[i].dy - 18),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EarningsChartPainter old) => old.data != data;
}
