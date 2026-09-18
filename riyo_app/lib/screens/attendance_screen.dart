import 'package:flutter/material.dart';
import 'package:riyo_app/riyo_api.dart';
import 'package:riyo_app/riyo_theme.dart';
import 'package:riyo_app/state_widgets.dart';

/// Attendance Screen — Monthly attendance view
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Map<String, dynamic>? _attendance;
  Object? _error;
  bool _loading = true;
  String _selectedMonth = '';

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().toString().substring(0, 7); // YYYY-MM
    _loadAttendance();
  }

  Future<void> _loadAttendance({bool refresh = false}) async {
    if (refresh) setState(() => _loading = true);
    try {
      final res = await RiyoApi.instance.attendance(_selectedMonth);
      if (mounted) {
        setState(() {
          _attendance = res['attendance'] as Map<String, dynamic>?;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: _pickMonth,
            tooltip: 'Select Month',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadAttendance(refresh: true),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: XRefreshIndicator(
        onRefresh: () => _loadAttendance(refresh: true),
        child: StateBody<Map<String, dynamic>?>(
          loading: _loading,
          error: _error,
          data: _attendance,
          isEmpty: (d) => d == null || (d['records'] as List?)?.isEmpty ?? true,
          onRetry: _loadAttendance,
          skeleton: ListView.builder(
            padding: const EdgeInsets.only(top: RiyoTheme.space2),
            itemCount: 4,
            itemBuilder: (_, __) => const _AttendanceSkeleton(),
          ),
          emptyTitle: 'No attendance records',
          emptyMessage: 'Attendance for $_selectedMonth will appear here.',
          emptyIcon: Icons.calendar_today_outlined,
          builder: (attendance) {
            final records = (attendance?['records'] as List?) ?? [];
            final summary = attendance?['summary'] as Map<String, dynamic>?;

            return ListView(
              padding: const EdgeInsets.only(
                top: RiyoTheme.space2,
                bottom: RiyoTheme.space8,
              ),
              children: [
                if (summary != null) _buildSummary(summary),
                const SizedBox(height: RiyoTheme.space4),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RiyoTheme.space4,
                  ),
                  child: Text('Daily Records', style: RiyoTheme.titleMedium),
                ),
                const SizedBox(height: RiyoTheme.space2),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: RiyoTheme.gray700),
                  itemBuilder: (context, index) =>
                      _AttendanceRecordTile(record: records[index]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse('$_selectedMonth-01') ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Month',
    );
    if (picked != null && mounted) {
      final monthStr =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
      if (monthStr != _selectedMonth) {
        setState(() => _selectedMonth = monthStr);
        _loadAttendance();
      }
    }
  }

  Widget _buildSummary(Map<String, dynamic> summary) {
    final present = summary['present'] as int? ?? 0;
    final absent = summary['absent'] as int? ?? 0;
    final late = summary['late'] as int? ?? 0;
    final total = present + absent + late;
    final percentage = total > 0
        ? (present / total * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      margin: const EdgeInsets.all(RiyoTheme.space4),
      padding: const EdgeInsets.all(RiyoTheme.space5),
      decoration: BoxDecoration(
        color: RiyoTheme.gray900,
        borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
        border: Border.all(color: RiyoTheme.gray700, width: 0.5),
      ),
      child: Column(
        children: [
          Text('Attendance Summary', style: RiyoTheme.titleMedium),
          const SizedBox(height: RiyoTheme.space5),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF00BA7C),
                  label: 'Present',
                  value: '$present',
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.cancel_rounded,
                  color: const Color(0xFFEF4444),
                  label: 'Absent',
                  value: '$absent',
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.access_time_rounded,
                  color: const Color(0xFFFFB300),
                  label: 'Late',
                  value: '$late',
                ),
              ),
            ],
          ),
          const SizedBox(height: RiyoTheme.space4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RiyoTheme.space4,
              vertical: RiyoTheme.space3,
            ),
            decoration: BoxDecoration(
              color: RiyoTheme.gray800,
              borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
              border: Border.all(color: RiyoTheme.gray700, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Attendance Rate', style: RiyoTheme.bodyMedium),
                Text(
                  '$percentage%',
                  style: RiyoTheme.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00BA7C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _StatItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(height: RiyoTheme.space2),
      Text(
        value,
        style: RiyoTheme.headlineMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      Text(
        label,
        style: RiyoTheme.labelSmall.copyWith(color: RiyoTheme.gray400),
      ),
    ],
  );
}

class _AttendanceRecordTile extends StatelessWidget {
  final Map<String, dynamic> record;
  const _AttendanceRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final dateStr = record['date'] as String? ?? '';
    final status = record['status'] as String? ?? 'P';
    final checkIn = record['check_in'] as String?;
    final checkOut = record['check_out'] as String?;

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'P':
        statusColor = const Color(0xFF00BA7C);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'A':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel_rounded;
        break;
      case 'L':
        statusColor = const Color(0xFFFFB300);
        statusIcon = Icons.access_time_rounded;
        break;
      default:
        statusColor = RiyoTheme.gray500;
        statusIcon = Icons.help_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: RiyoTheme.space4,
        vertical: RiyoTheme.space1,
      ),
      padding: const EdgeInsets.all(RiyoTheme.space4),
      decoration: BoxDecoration(
        color: RiyoTheme.gray900,
        borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
        border: Border.all(color: RiyoTheme.gray700, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: RiyoTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(dateStr), style: RiyoTheme.titleMedium),
                if (checkIn != null || checkOut != null) ...[
                  const SizedBox(height: RiyoTheme.space1),
                  Row(
                    children: [
                      if (checkIn != null) ...[
                        Icon(
                          Icons.login_rounded,
                          size: 14,
                          color: RiyoTheme.gray500,
                        ),
                        const SizedBox(width: RiyoTheme.space1),
                        Text(
                          checkIn!,
                          style: RiyoTheme.labelMedium.copyWith(
                            color: RiyoTheme.gray400,
                          ),
                        ),
                        const SizedBox(width: RiyoTheme.space3),
                      ],
                      if (checkOut != null) ...[
                        Icon(
                          Icons.logout_rounded,
                          size: 14,
                          color: RiyoTheme.gray500,
                        ),
                        const SizedBox(width: RiyoTheme.space1),
                        Text(
                          checkOut!,
                          style: RiyoTheme.labelMedium.copyWith(
                            color: RiyoTheme.gray400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: RiyoTheme.space2,
                  vertical: RiyoTheme.space1,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                ),
                child: Text(
                  status,
                  style: RiyoTheme.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _AttendanceSkeleton extends StatelessWidget {
  const _AttendanceSkeleton();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(
      horizontal: RiyoTheme.space4,
      vertical: RiyoTheme.space2,
    ),
    padding: const EdgeInsets.all(RiyoTheme.space4),
    decoration: BoxDecoration(
      color: RiyoTheme.gray900,
      borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
      border: Border.all(color: RiyoTheme.gray700, width: 0.5),
    ),
    child: Row(
      children: [
        SkeletonLoader(
          width: 48,
          height: 48,
          borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
        ),
        const SizedBox(width: RiyoTheme.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLoader(
                width: 80,
                height: 18,
                borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
              ),
              const SizedBox(height: RiyoTheme.space2),
              SkeletonLoader(
                width: 120,
                height: 14,
                borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
