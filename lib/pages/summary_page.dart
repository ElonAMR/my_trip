import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/budget.dart';

class SummaryPage extends StatelessWidget {
  final List<Activity> activities;
  final List<BudgetCategory> categories;

  const SummaryPage({
    super.key,
    required this.activities,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // פעילות קרובה שעדיין לא בוצעה
    final upcoming = (activities
        .where((a) => !a.done && a.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime)))
        .cast<Activity?>()
        .firstOrNull;

    // סטטוס פעילויות
    final totalActs = activities.length;
    final doneActs = activities.where((a) => a.done).length;
    final actsProgress = totalActs == 0 ? 0.0 : doneActs / totalActs;

    // תקציב כולל
    final totalPlanned = categories.fold<double>(0, (s, c) => s + c.planned);
    final totalActual  = categories.fold<double>(0, (s, c) => s + c.actual);
    final gap          = totalPlanned - totalActual;
    final budgetProgress = totalPlanned <= 0 ? 0.0 : (totalActual / totalPlanned).clamp(0, 1);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // פעילות קרובה
          _Card(
            title: 'הפעילות הקרובה',
            child: upcoming == null
                ? const Text('אין פעילות קרובה')
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(upcoming!.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                if (upcoming!.description != null &&
                    upcoming!.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(upcoming!.description!),
                  ),
                const SizedBox(height: 6),
                Text(_fmtDateTime(upcoming!.dateTime),
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          // סטטוס פעילויות
          _Card(
            title: 'סטטוס פעילויות',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('הושלמו: $doneActs מתוך $totalActs'),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: actsProgress),
              ],
            ),
          ),

          // תקציב כולל
          _Card(
            title: 'תקציב – סיכום כללי',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('סה״כ מתוכנן: ${_money(totalPlanned)} ₪'),
                Text('סה״כ בפועל:  ${_money(totalActual)} ₪'),
                const SizedBox(height: 4),
                Text(
                  'פער: ${_money(gap)} ₪',
                  style: TextStyle(
                    color: gap >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: budgetProgress),
              ],
            ),
          ),

          // קטגוריות – מתוכנן מול בפועל
          if (categories.isNotEmpty)
            _Card(
              title: 'תקציב לפי קטגוריות',
              child: Column(
                children: [
                  for (final c in categories) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text('${_money(c.actual)} / ${_money(c.planned)} ₪'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: c.planned <= 0
                          ? 0
                          : (c.actual / c.planned).clamp(0, 1),
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _fmtDateTime(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year}  $hh:$mi';
  }

  static String _money(double v) => v.toStringAsFixed(2);
}

/// כרטיס בסיסי לשימוש חוזר
class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
