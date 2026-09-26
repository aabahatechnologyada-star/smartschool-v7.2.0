import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riyo_app/riyo_api.dart';
import 'package:riyo_app/riyo_theme.dart';
import 'package:riyo_app/state_widgets.dart';

/// Notifications screen — X-style notification timeline
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Map<String, dynamic>> _allNotifications = [];
  List<Map<String, dynamic>> _mentionsNotifications = [];
  bool _loading = true;
  Object? _error;
  Set<String> _readIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReadState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReadState() async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = prefs.getStringList('notification_read_ids') ?? [];
    if (mounted) {
      setState(() => _readIds = readIds.toSet());
    }
  }

  Future<void> _saveReadState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notification_read_ids', _readIds.toList());
  }

  bool _isRead(String id) => _readIds.contains(id);

  Future<void> _markAsRead(String id) async {
    if (!_readIds.contains(id)) {
      _readIds.add(id);
      await _saveReadState();
      if (mounted) setState(() {});
    }
  }

  Future<void> _markAllAsRead() async {
    final allIds = [
      ..._allNotifications.map((n) => n['id'] as String),
      ..._mentionsNotifications.map((n) => n['id'] as String),
    ];
    _readIds.addAll(allIds);
    await _saveReadState();
    if (mounted) setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) setState(() => _loading = true);
    try {
      // Fetch notices from API as notifications
      final noticesRes = await RiyoApi.instance.notices();
      final notices = (noticesRes['notices'] as List?) ?? [];

      final items = notices
          .map<Map<String, dynamic>>(
            (notice) => {
              'id': notice['title'],
              'type': 'notice',
              'title': notice['title'],
              'content': notice['message'],
              'date': notice['date'],
              'icon': Icons.campaign_outlined,
            },
          )
          .toList();

      // Add some mock mentions/notifications for demo
      final mentions = [
        {
          'id': 'mention_1',
          'type': 'mention',
          'title': 'Class Teacher',
          'content': 'Homework assigned: "Chapter 5 Exercises" due tomorrow',
          'date': DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
          'icon': Icons.assignment_outlined,
        },
        {
          'id': 'mention_2',
          'type': 'mention',
          'title': 'Exam Department',
          'content': 'Your exam result for "Mid Term" is published',
          'date': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'icon': Icons.assessment_outlined,
        },
      ];

      if (mounted) {
        setState(() {
          _allNotifications = items;
          _mentionsNotifications = mentions;
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
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Mentions'),
          ],
          indicatorWeight: 3,
          labelStyle: RiyoTheme.labelLarge,
          unselectedLabelStyle: RiyoTheme.labelLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, size: 24),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
          const SizedBox(width: RiyoTheme.space2),
        ],
      ),
      body: XRefreshIndicator(
        onRefresh: () => _loadNotifications(refresh: true),
        child: StateBody<List<Map<String, dynamic>>>(
          loading: _loading,
          error: _error,
          data: _allNotifications,
          isEmpty: (d) => d.isEmpty,
          onRetry: _loadNotifications,
          skeleton: ListView.builder(
            padding: const EdgeInsets.only(top: RiyoTheme.space2),
            itemCount: 5,
            itemBuilder: (_, __) => const _NotificationTileSkeleton(),
          ),
          emptyTitle: 'No notifications yet',
          emptyMessage: 'School updates will appear here.',
          emptyIcon: Icons.notifications_none_rounded,
          builder: (items) => TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationList(_allNotifications),
              _buildNotificationList(_mentionsNotifications),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<Map<String, dynamic>> notifications) {
    if (notifications.isEmpty) {
      return EmptyView(
        icon: Icons.notifications_none_rounded,
        title: 'No notifications',
        message: 'You\'re all caught up!',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(
        top: RiyoTheme.space2,
        bottom: RiyoTheme.space8,
      ),
      itemCount: notifications.length,
      itemBuilder: (context, index) => _NotificationTile(
        notification: notifications[index],
        isRead: _isRead(notifications[index]['id'] as String),
        onTap: () {
          final notif = notifications[index];
          _markAsRead(notif['id'] as String);
          Navigator.pushNamed(
            context,
            '/notification-detail',
            arguments: notif,
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = notification['date'] as String;
    final read = isRead;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: RiyoTheme.space4,
        vertical: RiyoTheme.space1,
      ),
      decoration: BoxDecoration(
        color: read
            ? Colors.transparent
            : RiyoTheme.gray900.withOpacity(0.5),
        borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
        border: Border.all(
          color: read ? Colors.transparent : RiyoTheme.gray700,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(RiyoTheme.space4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: RiyoTheme.gray800,
                  child: Icon(
                    notification['icon'] as IconData,
                    color: RiyoTheme.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: RiyoTheme.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] as String,
                              style: RiyoTheme.titleMedium.copyWith(
                                fontWeight: read
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!read)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: RiyoTheme.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: RiyoTheme.space1),
                      Text(
                        notification['content'] as String,
                        style: RiyoTheme.bodyMedium.copyWith(
                          color: read ? RiyoTheme.gray400 : RiyoTheme.gray300,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: RiyoTheme.space2),
                      Text(
                        _formatDate(dateStr),
                        style: RiyoTheme.labelSmall.copyWith(
                          color: RiyoTheme.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        return '${date.day}/${date.month}/${date.year}';
      } else if (diff.inDays > 0) {
        return '${diff.inDays}d';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h';
      } else {
        return '${diff.inMinutes}m';
      }
    } catch (_) {
      return dateStr;
    }
  }
}

class _NotificationTileSkeleton extends StatelessWidget {
  const _NotificationTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: RiyoTheme.space4,
        vertical: RiyoTheme.space1,
      ),
      padding: const EdgeInsets.all(RiyoTheme.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
          ),
          const SizedBox(width: RiyoTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: 120,
                  height: 18,
                  borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                ),
                const SizedBox(height: RiyoTheme.space2),
                SkeletonLoader(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                ),
                const SizedBox(height: RiyoTheme.space1),
                SkeletonLoader(
                  width: 160,
                  height: 16,
                  borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                ),
                const SizedBox(height: RiyoTheme.space2),
                SkeletonLoader(
                  width: 60,
                  height: 12,
                  borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
