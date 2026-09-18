import 'package:flutter/material.dart';
import 'package:riyo_app/riyo_theme.dart';

/// Notification Detail Screen — X-style detail view for a single notification
class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final title = notification['title'] as String? ?? 'Notification';
    final content = notification['content'] as String? ?? '';
    final dateStr = notification['date'] as String? ?? '';
    final type = notification['type'] as String? ?? 'notice';
    final icon =
        notification['icon'] as IconData? ?? Icons.notifications_outlined;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(RiyoTheme.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(RiyoTheme.space5),
              decoration: BoxDecoration(
                color: RiyoTheme.gray900,
                borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
                border: Border.all(color: RiyoTheme.gray700, width: 0.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: RiyoTheme.gray800,
                    child: Icon(icon, color: RiyoTheme.white, size: 28),
                  ),
                  const SizedBox(width: RiyoTheme.space4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: RiyoTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: RiyoTheme.space2),
                        _TypeBadge(type: type),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: RiyoTheme.space5),

            // Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(RiyoTheme.space5),
              decoration: BoxDecoration(
                color: RiyoTheme.gray900,
                borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
                border: Border.all(color: RiyoTheme.gray700, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Message',
                    style: RiyoTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: RiyoTheme.space3),
                  Text(
                    content,
                    style: RiyoTheme.bodyLarge.copyWith(
                      color: RiyoTheme.gray300,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: RiyoTheme.space5),

            // Metadata
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(RiyoTheme.space5),
              decoration: BoxDecoration(
                color: RiyoTheme.gray900,
                borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
                border: Border.all(color: RiyoTheme.gray700, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: RiyoTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: RiyoTheme.space4),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Received',
                    value: _formatDate(dateStr),
                  ),
                  const SizedBox(height: RiyoTheme.space3),
                  _InfoRow(
                    icon: Icons.category_rounded,
                    label: 'Category',
                    value: _typeLabel(type),
                  ),
                  if (type == 'mention') ...[
                    const SizedBox(height: RiyoTheme.space3),
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'From',
                      value: notification['sender'] as String? ?? 'System',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: RiyoTheme.space8),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays > 7) {
        return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays > 0) {
        return '${diff.inDays}d ago at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h ago';
      } else {
        return '${diff.inMinutes}m ago';
      }
    } catch (_) {
      return dateStr;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'notice':
        return 'School Notice';
      case 'mention':
        return 'Mention';
      case 'exam':
        return 'Exam Result';
      case 'attendance':
        return 'Attendance Alert';
      case 'fee':
        return 'Fee Reminder';
      case 'homework':
        return 'Homework';
      default:
        return type.capitalize();
    }
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      'notice' => ('School Notice', RiyoTheme.gray400),
      'mention' => ('Mention', const Color(0xFF1DA1F2)),
      'exam' => ('Exam Result', const Color(0xFF00BA7C)),
      'attendance' => ('Attendance', const Color(0xFFFFB300)),
      'fee' => ('Fee', const Color(0xFFFF6B6B)),
      'homework' => ('Homework', const Color(0xFF1DA1F2)),
      _ => (type.capitalize(), RiyoTheme.gray400),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RiyoTheme.space3,
        vertical: RiyoTheme.space1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: RiyoTheme.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: RiyoTheme.space3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: RiyoTheme.gray800,
            borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
          ),
          child: Icon(icon, color: RiyoTheme.gray400, size: 20),
        ),
        const SizedBox(width: RiyoTheme.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: RiyoTheme.labelSmall.copyWith(color: RiyoTheme.gray500),
              ),
              const SizedBox(height: 2),
              Text(value, style: RiyoTheme.bodyMedium),
            ],
          ),
        ),
      ],
    ),
  );
}

extension StringExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
