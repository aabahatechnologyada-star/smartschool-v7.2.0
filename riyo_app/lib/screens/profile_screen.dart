import 'package:flutter/material.dart';
import 'package:riyo_app/riyo_api.dart';
import 'package:riyo_app/riyo_theme.dart';
import 'package:riyo_app/state_widgets.dart';

/// Profile screen — X-style profile with tabs
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Map<String, dynamic>? _profile;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile({bool refresh = false}) async {
    if (refresh) setState(() => _loading = true);
    try {
      final res = await RiyoApi.instance.profile();
      if (mounted) {
        setState(() {
          _profile = res['student'] as Map<String, dynamic>?;
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
    final student = _profile;

    return Scaffold(
      body: XRefreshIndicator(
        onRefresh: () => _loadProfile(refresh: true),
        child: StateBody<Map<String, dynamic>?>(
          loading: _loading,
          error: _error,
          data: student,
          isEmpty: (d) => d == null,
          onRetry: _loadProfile,
          skeleton: _ProfileSkeleton(),
          emptyTitle: 'Unable to load profile',
          emptyMessage: 'Please try again later.',
          emptyIcon: Icons.person_off_outlined,
          builder: (student) => _ProfileView(
            student: student,
            tabController: _tabController,
            onRefresh: _loadProfile,
          ),
        ),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final Map<String, dynamic> student;
  final TabController tabController;
  final Future<void> Function() onRefresh;

  const _ProfileView({
    required this.student,
    required this.tabController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final name = '${student['firstname'] ?? ''} ${student['lastname'] ?? ''}'
        .trim();
    final admissionNo = student['admission_no'] ?? '';
    final className = student['class'] ?? '';
    final section = student['section'] ?? '';
    final gender = student['gender'] ?? '';

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          stretch: true,
          backgroundColor: RiyoTheme.black,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [RiyoTheme.gray900, RiyoTheme.gray800],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      RiyoTheme.space6,
                      0,
                      RiyoTheme.space6,
                      RiyoTheme.space6,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: RiyoTheme.gray800,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: RiyoTheme.displayLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: RiyoTheme.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: RiyoTheme.space4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                name.isNotEmpty ? name : 'Student',
                                style: RiyoTheme.displayMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: RiyoTheme.space1),
                              Row(
                                children: [
                                  if (admissionNo.isNotEmpty) ...[
                                    Text(
                                      admissionNo,
                                      style: RiyoTheme.labelMedium.copyWith(
                                        color: RiyoTheme.gray400,
                                      ),
                                    ),
                                    const SizedBox(width: RiyoTheme.space3),
                                  ],
                                  if (className.isNotEmpty ||
                                      section.isNotEmpty) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: RiyoTheme.space3,
                                        vertical: RiyoTheme.space1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: RiyoTheme.gray800,
                                        borderRadius: BorderRadius.circular(
                                          RiyoTheme.radiusFull,
                                        ),
                                        border: Border.all(
                                          color: RiyoTheme.gray700,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        '$className${section.isNotEmpty ? ' - $section' : ''}',
                                        style: RiyoTheme.labelMedium,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: tabController,
              tabs: const [
                Tab(text: 'Posts'),
                Tab(text: 'Media'),
                Tab(text: 'Likes'),
              ],
              indicatorWeight: 3,
              labelStyle: RiyoTheme.labelLarge,
              unselectedLabelStyle: RiyoTheme.labelLarge,
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: tabController,
        children: [_buildPostsTab(), _buildMediaTab(), _buildLikesTab()],
      ),
    );
  }

  Widget _buildPostsTab() {
    final name = '${student['firstname'] ?? ''} ${student['lastname'] ?? ''}'
        .trim();
    final admissionNo = student['admission_no'] ?? '';
    final className = student['class'] ?? '';
    final section = student['section'] ?? '';
    final gender = student['gender'] ?? '';

    return ListView(
      padding: const EdgeInsets.only(
        top: RiyoTheme.space2,
        bottom: RiyoTheme.space8,
      ),
      children: [
        _StatRow(
          stats: [
            _StatItem(
              label: 'Attendance',
              value: '95%',
              icon: Icons.check_circle_outline_rounded,
            ),
            _StatItem(
              label: 'Fee Status',
              value: 'Paid',
              icon: Icons.attach_money_outlined,
            ),
            _StatItem(
              label: 'Exams',
              value: '12',
              icon: Icons.assessment_outlined,
            ),
          ],
        ),
        const Divider(height: 1, thickness: 0.5, color: RiyoTheme.gray700),
        _ProfileSection(
          title: 'Academic Info',
          children: [
            _InfoRow(
              icon: Icons.class_outlined,
              label: 'Class',
              value: '$className - $section',
            ),
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'Admission No',
              value: admissionNo,
            ),
            _InfoRow(
              icon: Icons.person_outline_rounded,
              label: 'Gender',
              value: gender,
            ),
          ],
        ),
        const SizedBox(height: RiyoTheme.space4),
        _ProfileSection(
          title: 'Quick Actions',
          children: [
            _ActionTile(
              icon: Icons.assessment_outlined,
              title: 'Exam Results',
              subtitle: 'View all published results',
              onTap: () {
                Navigator.pushNamed(context, '/exam-results');
              },
            ),
            _ActionTile(
              icon: Icons.check_circle_outlined,
              title: 'Attendance',
              subtitle: 'Detailed attendance record',
              onTap: () {
                Navigator.pushNamed(context, '/attendance');
              },
            ),
            _ActionTile(
              icon: Icons.attach_money_outlined,
              title: 'Fees',
              subtitle: 'Payment history & dues',
              onTap: () {},
            ),
            _ActionTile(
              icon: Icons.assignment_outlined,
              title: 'Homework',
              subtitle: 'Pending & completed tasks',
              onTap: () {},
            ),
            _ActionTile(
              icon: Icons.campaign_outlined,
              title: 'Notices',
              subtitle: 'School announcements',
              onTap: () {},
            ),
            _ActionTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'App preferences & account',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: RiyoTheme.space6),
        Text(
          'Riyo v7.2.0',
          style: RiyoTheme.labelSmall.copyWith(color: RiyoTheme.gray500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: RiyoTheme.space2),
      ],
    );
  }

  Widget _buildMediaTab() {
    return EmptyView(
      icon: Icons.photo_library_outlined,
      title: 'No media yet',
      message: 'Photos and videos you share will appear here.',
    );
  }

  Widget _buildLikesTab() {
    return EmptyView(
      icon: Icons.favorite_border_rounded,
      title: 'No likes yet',
      message: 'Posts you like will appear here.',
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: RiyoTheme.black, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _StatRow extends StatelessWidget {
  final List<_StatItem> stats;
  const _StatRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: RiyoTheme.space4,
        vertical: RiyoTheme.space4,
      ),
      child: Row(
        children: stats
            .map((stat) => Expanded(child: _StatItemWidget(item: stat)))
            .toList(),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _StatItemWidget extends StatelessWidget {
  final _StatItem item;
  const _StatItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(item.icon, color: RiyoTheme.gray400, size: 24),
        const SizedBox(height: RiyoTheme.space2),
        Text(
          item.value,
          style: RiyoTheme.headlineMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: RiyoTheme.space1),
        Text(
          item.label,
          style: RiyoTheme.labelMedium.copyWith(color: RiyoTheme.gray400),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            RiyoTheme.space4,
            0,
            RiyoTheme.space4,
            RiyoTheme.space3,
          ),
          child: Text(title, style: RiyoTheme.titleMedium),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: RiyoTheme.space4),
          decoration: BoxDecoration(
            color: RiyoTheme.gray900,
            borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
            border: Border.all(color: RiyoTheme.gray700, width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(RiyoTheme.space4),
      child: Row(
        children: [
          Icon(icon, color: RiyoTheme.gray400, size: 22),
          const SizedBox(width: RiyoTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: RiyoTheme.labelSmall.copyWith(
                    color: RiyoTheme.gray500,
                  ),
                ),
                Text(value, style: RiyoTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(RiyoTheme.space4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: RiyoTheme.gray800,
                borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
              ),
              child: Icon(icon, color: RiyoTheme.white, size: 22),
            ),
            const SizedBox(width: RiyoTheme.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: RiyoTheme.titleMedium),
                  Text(
                    subtitle,
                    style: RiyoTheme.labelSmall.copyWith(
                      color: RiyoTheme.gray400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: RiyoTheme.gray500),
          ],
        ),
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: RiyoTheme.space8),
      children: [
        Container(height: 220, color: RiyoTheme.gray900),
        Padding(
          padding: const EdgeInsets.all(RiyoTheme.space4),
          child: Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Column(
                  children: [
                    SkeletonLoader(
                      width: 24,
                      height: 24,
                      borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                    ),
                    const SizedBox(height: RiyoTheme.space2),
                    SkeletonLoader(
                      width: 60,
                      height: 28,
                      borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                    ),
                    const SizedBox(height: RiyoTheme.space1),
                    SkeletonLoader(
                      width: 80,
                      height: 12,
                      borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1, thickness: 0.5, color: RiyoTheme.gray700),
        const SizedBox(height: RiyoTheme.space4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: RiyoTheme.space4),
          child: SkeletonLoader(
            width: 120,
            height: 18,
            borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
          ),
        ),
        const SizedBox(height: RiyoTheme.space3),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: RiyoTheme.space4),
          decoration: BoxDecoration(
            color: RiyoTheme.gray900,
            borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
            border: Border.all(color: RiyoTheme.gray700, width: 0.5),
          ),
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.all(RiyoTheme.space4),
                child: Row(
                  children: [
                    SkeletonLoader(
                      width: 22,
                      height: 22,
                      borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                    ),
                    const SizedBox(width: RiyoTheme.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLoader(
                            width: 60,
                            height: 10,
                            borderRadius: BorderRadius.circular(
                              RiyoTheme.radiusFull,
                            ),
                          ),
                          const SizedBox(height: RiyoTheme.space1),
                          SkeletonLoader(
                            width: 100,
                            height: 14,
                            borderRadius: BorderRadius.circular(
                              RiyoTheme.radiusFull,
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
        ),
      ],
    );
  }
}
