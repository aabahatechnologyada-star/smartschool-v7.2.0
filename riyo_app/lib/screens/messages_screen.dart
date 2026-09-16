import 'package:flutter/material.dart';
import 'package:riyo_app/riyo_api.dart';
import 'package:riyo_app/riyo_theme.dart';
import 'package:riyo_app/state_widgets.dart';

/// Messages/Chat screen — X-style DM list
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations({bool refresh = false}) async {
    if (refresh) setState(() => _loading = true);
    try {
      // Mock conversations for now - in real app would come from chat API
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          _conversations = [
            {
              'id': '1',
              'name': 'Class Teacher',
              'role': 'Teacher',
              'lastMessage': 'Homework for tomorrow: Page 45-47',
              'time': DateTime.now().subtract(const Duration(minutes: 30)),
              'unread': 2,
              'online': true,
            },
            {
              'id': '2',
              'name': 'School Admin',
              'role': 'Administration',
              'lastMessage': 'Fee payment reminder for this month',
              'time': DateTime.now().subtract(const Duration(hours: 3)),
              'unread': 1,
              'online': false,
            },
            {
              'id': '3',
              'name': 'Parent Group',
              'role': 'Group • 12 members',
              'lastMessage': 'PTA meeting scheduled for Friday',
              'time': DateTime.now().subtract(const Duration(days: 1)),
              'unread': 0,
              'online': false,
            },
            {
              'id': '4',
              'name': 'Exam Coordinator',
              'role': 'Examinations',
              'lastMessage': 'Admit cards available for download',
              'time': DateTime.now().subtract(const Duration(days: 2)),
              'unread': 0,
              'online': true,
            },
          ];
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
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, size: 26),
            onPressed: () {},
            tooltip: 'New message',
          ),
          const SizedBox(width: RiyoTheme.space2),
        ],
      ),
      body: XRefreshIndicator(
        onRefresh: () => _loadConversations(refresh: true),
        child: StateBody<List<Map<String, dynamic>>>(
          loading: _loading,
          error: _error,
          data: _conversations,
          isEmpty: (d) => d.isEmpty,
          onRetry: _loadConversations,
          skeleton: ListView.builder(
            padding: const EdgeInsets.only(top: RiyoTheme.space2),
            itemCount: 5,
            itemBuilder: (_, __) => const _ConversationTileSkeleton(),
          ),
          emptyTitle: 'No messages yet',
          emptyMessage: 'Start a conversation with teachers or classmates.',
          emptyIcon: Icons.chat_bubble_outline_rounded,
          builder: (conversations) => ListView.builder(
            padding: const EdgeInsets.only(top: RiyoTheme.space2, bottom: RiyoTheme.space8),
            itemCount: conversations.length,
            itemBuilder: (context, index) =>
                _ConversationTile(conversation: conversations[index]),
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Map<String, dynamic> conversation;
  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final unread = conversation['unread'] as int;
    final online = conversation['online'] as bool;
    final time = conversation['time'] as DateTime;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: RiyoTheme.space4,
        vertical: RiyoTheme.space1,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to chat detail
          },
          borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(RiyoTheme.space3),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: RiyoTheme.gray800,
                      child: Text(
                        conversation['name'][0],
                        style: RiyoTheme.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (online)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: RiyoTheme.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: RiyoTheme.black, width: 2),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF00BA7C),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                  ],
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
                              conversation['name'] as String,
                              style: RiyoTheme.titleMedium.copyWith(
                                fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(time),
                            style: RiyoTheme.labelSmall.copyWith(
                              color: unread > 0 ? RiyoTheme.white : RiyoTheme.gray500,
                              fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: RiyoTheme.space1),
                      Row(
                        children: [
                          Text(
                            conversation['role'] as String,
                            style: RiyoTheme.labelSmall.copyWith(color: RiyoTheme.gray500),
                          ),
                          const SizedBox(width: RiyoTheme.space2),
                          Expanded(
                            child: Text(
                              conversation['lastMessage'] as String,
                              style: RiyoTheme.bodyMedium.copyWith(
                                color: unread > 0 ? RiyoTheme.gray300 : RiyoTheme.gray400,
                                fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (unread > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RiyoTheme.space2,
                      vertical: RiyoTheme.space1,
                    ),
                    decoration: BoxDecoration(
                      color: RiyoTheme.white,
                      borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: RiyoTheme.labelSmall.copyWith(
                        color: RiyoTheme.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 7) {
      return '${time.day}/${time.month}/${time.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inMinutes}m';
    }
  }
}

class _ConversationTileSkeleton extends StatelessWidget {
  const _ConversationTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: RiyoTheme.space4,
        vertical: RiyoTheme.space1,
      ),
      padding: const EdgeInsets.all(RiyoTheme.space3),
      child: Row(
        children: [
          SkeletonLoader(
            width: 52,
            height: 52,
            borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
          ),
          const SizedBox(width: RiyoTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonLoader(width: 100, height: 18, borderRadius: BorderRadius.circular(RiyoTheme.radiusFull)),
                    const Spacer(),
                    SkeletonLoader(width: 40, height: 12, borderRadius: BorderRadius.circular(RiyoTheme.radiusFull)),
                  ],
                ),
                const SizedBox(height: RiyoTheme.space2),
                Row(
                  children: [
                    SkeletonLoader(width: 80, height: 12, borderRadius: BorderRadius.circular(RiyoTheme.radiusFull)),
                    const SizedBox(width: RiyoTheme.space3),
                    SkeletonLoader(width: 200, height: 14, borderRadius: BorderRadius.circular(RiyoTheme.radiusFull)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}