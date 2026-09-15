import 'package:flutter/material.dart';
import 'riyo_api.dart';
import 'riyo_theme.dart';
import 'state_widgets.dart';

/// Home feed screen — X-style chronological feed of school content
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});
  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  List<Map<String, dynamic>> _feedItems = [];
  Object? _error;
  bool _loading = true;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFeed();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Could implement pagination here
    }
  }

  Future<void> _loadFeed({bool refresh = false}) async {
    if (refresh) {
      setState(() => _loading = true);
    }
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        api.notices(),
        api.dashboard(),
        api.examResults(),
      ]);

      final notices = (results[0]['notices'] as List?) ?? [];
      final dashboard = results[1];
      final examResults = (results[2]['sessions'] as List?) ?? [];

      // Build unified feed items
      final items = <Map<String, dynamic>>[];

      // Add notices as feed cards
      for (final notice in notices) {
        items.add({
          'type': 'notice',
          'id': notice['title'],
          'title': notice['title'],
          'content': notice['message'],
          'date': notice['date'],
          'icon': Icons.campaign_outlined,
        });
      }

      // Add exam results as feed cards
      for (final session in examResults) {
        for (final group in (session['exam_groups'] as List?) ?? []) {
          items.add({
            'type': 'exam_result',
            'id': '${session['session']}_${group['exam_group']}',
            'title': group['exam_group'],
            'subtitle': '${session['session']} · ${session['class']}',
            'percentage': group['percentage'],
            'grade': group['grade'],
            'subjects': group['subjects'],
            'icon': Icons.assessment_outlined,
          });
        }
      }

      // Sort by date (newest first) - simplified for now
      items.sort((a, b) => 0); // Keep order as fetched

      if (mounted) {
        setState(() {
          _feedItems = items;
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
        title: Image.asset('assets/riyo_logo_small.png', height: 28),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 26),
            onPressed: () {},
            tooltip: 'Settings',
          ),
          const SizedBox(width: RiyoTheme.space2),
        ],
      ),
      body: XRefreshIndicator(
        onRefresh: () => _loadFeed(refresh: true),
        child: StateBody<List<Map<String, dynamic>>>(
          loading: _loading,
          error: _error,
          data: _feedItems,
          isEmpty: (d) => d.isEmpty,
          onRetry: _loadFeed,
          skeleton: ListView.builder(
            padding: const EdgeInsets.only(top: RiyoTheme.space2),
            itemCount: 4,
            itemBuilder: (_, __) => const FeedCardSkeleton(),
          ),
          emptyTitle: 'No updates yet',
          emptyMessage: 'School announcements and results will appear here.',
          emptyIcon: Icons.article_outlined,
          builder: (items) => ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: RiyoTheme.space2, bottom: RiyoTheme.space8),
            itemCount: items.length,
            itemBuilder: (context, index) => _FeedCard(item: items[index]),
          ),
        ),
      ),
    );
  }
}

/// Individual feed card — X-style tweet card adapted for school content
class _FeedCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _FeedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final type = item['type'] as String;
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: RiyoTheme.space4,
        vertical: RiyoTheme.space2,
      ),
      decoration: BoxDecoration(
        color: RiyoTheme.gray900,
        borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
        border: Border.all(color: RiyoTheme.gray700, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(RiyoTheme.space4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: RiyoTheme.gray800,
                  child: Icon(
                    item['icon'] as IconData,
                    color: RiyoTheme.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: RiyoTheme.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: RiyoTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item['subtitle'] != null)
                        Text(
                          item['subtitle'] as String,
                          style: RiyoTheme.labelMedium.copyWith(color: RiyoTheme.gray400),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (item['date'] != null)
                  Text(
                    _formatDate(item['date'] as String),
                    style: RiyoTheme.labelSmall.copyWith(color: RiyoTheme.gray500),
                  ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RiyoTheme.space4),
            child: _buildContent(type),
          ),
          
          // Divider
          const Divider(height: 1, indent: 56, endIndent: 0),
          
          // Action bar
          _ActionBar(item: item),
        ],
      ),
    );
  }

  Widget _buildContent(String type) {
    switch (type) {
      case 'notice':
        return Padding(
          padding: const EdgeInsets.only(bottom: RiyoTheme.space3),
          child: Text(
            item['content'] as String,
            style: RiyoTheme.bodyLarge,
          ),
        );
      case 'exam_result':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['percentage'] != null) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RiyoTheme.space3,
                      vertical: RiyoTheme.space1,
                    ),
                    decoration: BoxDecoration(
                      color: RiyoTheme.gray800,
                      borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                      border: Border.all(color: RiyoTheme.gray700, width: 0.5),
                    ),
                    child: Text(
                      '${item['percentage']}%',
                      style: RiyoTheme.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: RiyoTheme.space2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RiyoTheme.space3,
                      vertical: RiyoTheme.space1,
                    ),
                    decoration: BoxDecoration(
                      color: RiyoTheme.gray800,
                      borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                      border: Border.all(color: RiyoTheme.gray700, width: 0.5),
                    ),
                    child: Text(
                      'Grade ${item['grade']}',
                      style: RiyoTheme.labelMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RiyoTheme.space3),
            ],
            if (item['subjects'] != null) ...[
              Wrap(
                spacing: RiyoTheme.space2,
                runSpacing: RiyoTheme.space2,
                children: (item['subjects'] as List).take(4).map<Widget>((sub) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RiyoTheme.space3,
                      vertical: RiyoTheme.space1,
                    ),
                    decoration: BoxDecoration(
                      color: RiyoTheme.gray800,
                      borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                      border: Border.all(color: RiyoTheme.gray700, width: 0.5),
                    ),
                    child: Text(
                      '${sub['subject']}: ${sub['get_marks'] ?? '-'}/${sub['max_marks'] ?? '-'}',
                      style: RiyoTheme.labelSmall,
                    ),
                  );
                }).toList(),
              ),
              if ((item['subjects'] as List).length > 4)
                Padding(
                  padding: const EdgeInsets.only(top: RiyoTheme.space2),
                  child: Text(
                    '+ ${(item['subjects'] as List).length - 4} more subjects',
                    style: RiyoTheme.labelSmall.copyWith(color: RiyoTheme.gray400),
                  ),
                ),
            ],
            const SizedBox(height: RiyoTheme.space2),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
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

/// Action bar at bottom of feed card (like X's reply/retweet/like/share)
class _ActionBar extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ActionBar({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: RiyoTheme.space3,
        vertical: RiyoTheme.space2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Discuss',
            onTap: () {},
          ),
          _ActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () {},
          ),
          _ActionButton(
            icon: Icons.bookmark_border_rounded,
            label: 'Save',
            onTap: () {},
          ),
          _ActionButton(
            icon: Icons.more_horiz_rounded,
            label: '',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RiyoTheme.space3,
          vertical: RiyoTheme.space2,
        ),
        child: label.isEmpty
            ? Icon(icon, color: RiyoTheme.gray400, size: 24)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: RiyoTheme.gray400, size: 20),
                  const SizedBox(width: RiyoTheme.space1),
                  Text(label, style: RiyoTheme.labelMedium.copyWith(color: RiyoTheme.gray400)),
                ],
              ),
      ),
    );
  }
}