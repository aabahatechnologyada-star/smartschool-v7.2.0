import 'package:flutter/material.dart';
import 'package:riyo_app/riyo_api.dart';
import 'package:riyo_app/riyo_theme.dart';
import 'package:riyo_app/state_widgets.dart';

import 'exam_result_detail_screen.dart';

/// Exam Results List Screen — All published exam results
class ExamResultsScreen extends StatefulWidget {
  const ExamResultsScreen({super.key});
  @override
  State<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen> {
  List<Map<String, dynamic>> _sessions = [];
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults({bool refresh = false}) async {
    if (refresh) setState(() => _loading = true);
    try {
      final res = await RiyoApi.instance.examResults();
      final sessions = (res['sessions'] as List?) ?? [];
      if (mounted) {
        setState(() {
          _sessions = sessions.cast<Map<String, dynamic>>();
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
        title: const Text('Exam Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadResults(refresh: true),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: XRefreshIndicator(
        onRefresh: () => _loadResults(refresh: true),
        child: StateBody<List<Map<String, dynamic>>>(
          loading: _loading,
          error: _error,
          data: _sessions,
          isEmpty: (d) => d.isEmpty,
          onRetry: _loadResults,
          skeleton: ListView.builder(
            padding: const EdgeInsets.only(top: RiyoTheme.space2),
            itemCount: 4,
            itemBuilder: (_, __) => const _ExamSessionSkeleton(),
          ),
          emptyTitle: 'No exam results yet',
          emptyMessage: 'Published exam results will appear here.',
          emptyIcon: Icons.assessment_outlined,
          builder: (sessions) => ListView.builder(
            padding: const EdgeInsets.only(
              top: RiyoTheme.space2,
              bottom: RiyoTheme.space8,
            ),
            itemCount: sessions.length,
            itemBuilder: (context, index) =>
                _SessionCard(session: sessions[index]),
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final sessionName = session['session'] as String? ?? '';
    final className = session['class'] as String? ?? '';
    final examGroups = (session['exam_groups'] as List?) ?? [];

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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: RiyoTheme.gray800,
                    borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
                  ),
                  child: const Icon(
                    Icons.assessment_rounded,
                    color: RiyoTheme.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: RiyoTheme.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sessionName,
                        style: RiyoTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (className.isNotEmpty)
                        Text(
                          className,
                          style: RiyoTheme.labelMedium.copyWith(
                            color: RiyoTheme.gray400,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: RiyoTheme.gray500,
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            indent: 56,
            endIndent: 0,
            color: RiyoTheme.gray700,
          ),
          // Exam groups
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: examGroups.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 56,
              endIndent: 0,
              color: RiyoTheme.gray700,
            ),
            itemBuilder: (context, index) {
              final group = examGroups[index] as Map<String, dynamic>;
              final examGroup = group['exam_group'] as String? ?? '';
              final percentage =
                  (group['percentage'] as num?)?.toDouble() ?? 0.0;
              final grade = group['grade'] as String? ?? '';
              final subjects = (group['subjects'] as List?) ?? [];

              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/exam-result',
                    arguments: {
                      'examResult': {
                        ...group,
                        'exam_group': examGroup,
                        'session': session['session'],
                        'class': session['class'],
                      },
                      'session': session['session'] as String? ?? '',
                      'className': session['class'] as String? ?? '',
                    },
                  );
                },
                borderRadius: BorderRadius.only(
                  bottomLeft: index == examGroups.length - 1
                      ? Radius.circular(RiyoTheme.radiusLg)
                      : Radius.zero,
                  bottomRight: index == examGroups.length - 1
                      ? Radius.circular(RiyoTheme.radiusLg)
                      : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(RiyoTheme.space4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              examGroup,
                              style: RiyoTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (percentage > 0) ...[
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
                                '${percentage.toStringAsFixed(1)}%',
                                style: RiyoTheme.labelLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
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
                                borderRadius: BorderRadius.circular(
                                  RiyoTheme.radiusFull,
                                ),
                                border: Border.all(
                                  color: RiyoTheme.gray700,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                'Grade $grade',
                                style: RiyoTheme.labelMedium,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (subjects.isNotEmpty) ...[
                        const SizedBox(height: RiyoTheme.space3),
                        Wrap(
                          spacing: RiyoTheme.space2,
                          runSpacing: RiyoTheme.space2,
                          children: subjects.take(3).map<Widget>((sub) {
                            return Container(
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
                                '${sub['subject']}: ${sub['get_marks'] ?? '-'}/${sub['max_marks'] ?? '-'}',
                                style: RiyoTheme.labelSmall,
                              ),
                            );
                          }).toList(),
                        ),
                        if (subjects.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: RiyoTheme.space2,
                            ),
                            child: Text(
                              '+ ${subjects.length - 3} more subjects',
                              style: RiyoTheme.labelSmall.copyWith(
                                color: RiyoTheme.gray400,
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: RiyoTheme.space2),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExamSessionSkeleton extends StatelessWidget {
  const _ExamSessionSkeleton();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(
      horizontal: RiyoTheme.space4,
      vertical: RiyoTheme.space2,
    ),
    padding: const EdgeInsets.all(RiyoTheme.space4),
    decoration: BoxDecoration(
      color: RiyoTheme.gray900,
      borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
      border: Border.all(color: RiyoTheme.gray700, width: 0.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SkeletonLoader(
              width: 40,
              height: 40,
              borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
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
                  const SizedBox(height: RiyoTheme.space1),
                  SkeletonLoader(
                    width: 80,
                    height: 14,
                    borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: RiyoTheme.space4),
        SkeletonLoader(
          width: double.infinity,
          height: 18,
          borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
        ),
        const SizedBox(height: RiyoTheme.space2),
        SkeletonLoader(
          width: 200,
          height: 14,
          borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
        ),
        const SizedBox(height: RiyoTheme.space4),
        Row(
          children: List.generate(
            2,
            (i) => SkeletonLoader(
              width: 80,
              height: 28,
              borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
            ),
          ),
        ),
      ],
    ),
  );
}
