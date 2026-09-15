import 'package:flutter/material.dart';
import 'riyo_api.dart';
import 'riyo_theme.dart';
import 'state_widgets.dart';

/// Search/Discover screen — X-style explore with tabs
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String _query = '';
  List<Map<String, dynamic>> _results = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_query.trim().isEmpty) return;
    setState(() => _searching = true);
    try {
      // Simulate search - in real app would call backend search endpoints
      await Future.delayed(const Duration(milliseconds: 500));
      // Mock results for now
      setState(() {
        _results = [
          {'type': 'student', 'name': 'John Doe', 'class': '10-A', 'admission': 'STU001'},
          {'type': 'notice', 'title': 'Exam Schedule', 'date': '2024-01-15'},
          {'type': 'homework', 'subject': 'Mathematics', 'due': '2024-01-20'},
        ];
        _searching = false;
      });
    } catch (_) {
      setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  RiyoTheme.space4, 0, RiyoTheme.space4, RiyoTheme.space3),
                child: TextField(
                  controller: _searchController,
                  style: RiyoTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search students, notices, homework...',
                    hintStyle: RiyoTheme.bodyMedium.copyWith(color: RiyoTheme.gray500),
                    prefixIcon: const Icon(Icons.search_rounded, color: RiyoTheme.gray500),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: RiyoTheme.gray500),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                                _results.clear();
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: RiyoTheme.gray800,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                  onSubmitted: (_) => _search(),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Top'),
                  Tab(text: 'Latest'),
                  Tab(text: 'People'),
                ],
                indicatorWeight: 3,
                labelStyle: RiyoTheme.labelLarge,
                unselectedLabelStyle: RiyoTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResultsTab(),
          _buildResultsTab(),
          _buildPeopleTab(),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    if (_query.isEmpty) {
      return _buildExploreView();
    }
    if (_searching) {
      return const LoadingView(message: 'Searching...');
    }
    if (_results.isEmpty) {
      return EmptyView(
        icon: Icons.search_off_rounded,
        title: 'No results for "$_query"',
        message: 'Try different keywords or check spelling.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(RiyoTheme.space4),
      itemCount: _results.length,
      itemBuilder: (context, index) => _SearchResultTile(item: _results[index]),
    );
  }

  Widget _buildExploreView() {
    return ListView(
      padding: const EdgeInsets.all(RiyoTheme.space4),
      children: [
        Text('Explore', style: RiyoTheme.headlineMedium),
        const SizedBox(height: RiyoTheme.space4),
        _ExploreCard(
          icon: Icons.assessment_outlined,
          title: 'Exam Results',
          subtitle: 'View published results',
          onTap: () {},
        ),
        const SizedBox(height: RiyoTheme.space3),
        _ExploreCard(
          icon: Icons.assignment_outlined,
          title: 'Homework',
          subtitle: 'Pending assignments',
          onTap: () {},
        ),
        const SizedBox(height: RiyoTheme.space3),
        _ExploreCard(
          icon: Icons.campaign_outlined,
          title: 'Notices',
          subtitle: 'School announcements',
          onTap: () {},
        ),
        const SizedBox(height: RiyoTheme.space3),
        _ExploreCard(
          icon: Icons.attach_money_outlined,
          title: 'Fees',
          subtitle: 'Payment status & dues',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildPeopleTab() {
    return ListView(
      padding: const EdgeInsets.all(RiyoTheme.space4),
      children: [
        Text('Classmates', style: RiyoTheme.headlineMedium),
        const SizedBox(height: RiyoTheme.space4),
        ...List.generate(5, (index) => _PeopleTile(
          name: 'Student ${index + 1}',
          className: 'Class ${10 + (index % 3)} - ${['A', 'B', 'C'][index % 3]}',
          isOnline: index % 2 == 0,
        )),
      ],
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExploreCard({
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
      child: Container(
        padding: const EdgeInsets.all(RiyoTheme.space4),
        decoration: BoxDecoration(
          color: RiyoTheme.gray900,
          borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
          border: Border.all(color: RiyoTheme.gray700, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: RiyoTheme.gray800,
                borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
              ),
              child: Icon(icon, color: RiyoTheme.white, size: 24),
            ),
            const SizedBox(width: RiyoTheme.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: RiyoTheme.titleMedium),
                  const SizedBox(height: RiyoTheme.space1),
                  Text(subtitle, style: RiyoTheme.bodyMedium.copyWith(color: RiyoTheme.gray400)),
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

class _SearchResultTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const _SearchResultTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final type = item['type'] as String;
    IconData icon;
    switch (type) {
      case 'student':
        icon = Icons.person_outline_rounded;
        break;
      case 'notice':
        icon = Icons.campaign_outlined;
        break;
      case 'homework':
        icon = Icons.assignment_outlined;
        break;
      default:
        icon = Icons.article_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: RiyoTheme.space2),
      decoration: BoxDecoration(
        color: RiyoTheme.gray900,
        borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
        border: Border.all(color: RiyoTheme.gray700, width: 0.5),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: RiyoTheme.gray800,
          child: Icon(icon, color: RiyoTheme.white),
        ),
        title: Text(item['name'] ?? item['title'] ?? '', style: RiyoTheme.titleMedium),
        subtitle: Text(
          item['class'] ?? item['subject'] ?? item['date'] ?? '',
          style: RiyoTheme.bodyMedium.copyWith(color: RiyoTheme.gray400),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: RiyoTheme.gray500),
        onTap: () {},
      ),
    );
  }
}

class _PeopleTile extends StatelessWidget {
  final String name;
  final String className;
  final bool isOnline;

  const _PeopleTile({
    required this.name,
    required this.className,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: RiyoTheme.space2),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: RiyoTheme.gray800,
                child: Text(
                  name[0],
                  style: RiyoTheme.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: RiyoTheme.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: RiyoTheme.black, width: 2),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00BA7C), // Green for online
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: RiyoTheme.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: RiyoTheme.titleMedium),
                Text(className, style: RiyoTheme.labelMedium.copyWith(color: RiyoTheme.gray400)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Follow'),
          ),
        ],
      ),
    );
  }
}