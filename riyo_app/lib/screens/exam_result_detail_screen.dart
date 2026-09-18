import 'package:flutter/material.dart';
import 'package:riyo_app/riyo_api.dart';
import 'package:riyo_app/riyo_theme.dart';
import 'package:riyo_app/state_widgets.dart';

/// Exam Result Detail Screen — X-style detail view for a single exam result
class ExamResultDetailScreen extends StatelessWidget {
  final Map<String, dynamic> examResult;
  final String session;
  final String className;

  const ExamResultDetailScreen({
    super.key,
    required this.examResult,
    required this.session,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    final examGroup = examResult['exam_group'] as String? ?? 'Exam';
    final percentage = (examResult['percentage'] as num?)?.toDouble() ?? 0.0;
    final grade = examResult['grade'] as String? ?? '—';
    final rank = examResult['rank'] as String? ?? '—';
    final totalStudents = examResult['total_students'] as int? ?? 0;
    final subjects = (examResult['subjects'] as List?) ?? [];
    final teacherRemarks = examResult['teacher_remarks'] as String? ?? '';
    final examDate = examResult['date'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(examGroup),
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
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () {},
            tooltip: 'More',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(percentage, grade, rank, totalStudents),
          ),
          if (teacherRemarks.isNotEmpty)
            SliverToBoxAdapter(child: _buildTeacherRemarks(teacherRemarks)),
          SliverToBoxAdapter(child: _buildSubjectsSection(subjects)),
          SliverToBoxAdapter(
            child: _buildExamInfo(examGroup, session, className, examDate),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: RiyoTheme.space8)),
        ],
      ),
    );
  }

  Widget _buildHeader(
    double percentage,
    String grade,
    String rank,
    int totalStudents,
  ) {
    return Container(
      margin: const EdgeInsets.all(RiyoTheme.space4),
      padding: const EdgeInsets.all(RiyoTheme.space6),
      decoration: BoxDecoration(
        color: RiyoTheme.gray900,
        borderRadius: BorderRadius.circular(RiyoTheme.radiusXl),
        border: Border.all(color: RiyoTheme.gray700, width: 0.5),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  backgroundColor: RiyoTheme.gray800,
                  valueColor: AlwaysStoppedAnimation<Color>(_gradeColor(grade)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    percentage.toStringAsFixed(1),
                    style: RiyoTheme.displayLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '%',
                    style: RiyoTheme.titleLarge.copyWith(
                      color: RiyoTheme.gray400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: RiyoTheme.space4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RiyoTheme.space6,
              vertical: RiyoTheme.space2,
            ),
            decoration: BoxDecoration(
              color: _gradeColor(grade).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
              border: Border.all(
                color: _gradeColor(grade).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Grade $grade',
              style: RiyoTheme.titleMedium.copyWith(
                color: _gradeColor(grade),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: RiyoTheme.space4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.leaderboard_rounded,
                size: 18,
                color: RiyoTheme.gray500,
              ),
              const SizedBox(width: RiyoTheme.space2),
              Text(
                'Rank: $rank${totalStudents > 0 ? ' out of $totalStudents' : ''}',
                style: RiyoTheme.bodyMedium.copyWith(color: RiyoTheme.gray400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherRemarks(String remarks) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        RiyoTheme.space4,
        0,
        RiyoTheme.space4,
        RiyoTheme.space4,
      ),
      padding: const EdgeInsets.all(RiyoTheme.space5),
      decoration: BoxDecoration(
        color: RiyoTheme.gray900,
        borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
        border: Border.all(
          color: RiyoTheme.gray700.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 20,
                color: RiyoTheme.gray500,
              ),
              const SizedBox(width: RiyoTheme.space2),
              Text(
                'Teacher Remarks',
                style: RiyoTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: RiyoTheme.space3),
          Text(
            remarks,
            style: RiyoTheme.bodyMedium.copyWith(
              color: RiyoTheme.gray300,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsSection(List<dynamic> subjects) {
    if (subjects.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(
        RiyoTheme.space4,
        0,
        RiyoTheme.space4,
        RiyoTheme.space4,
      ),
      decoration: BoxDecoration(
        color: RiyoTheme.gray900,
        borderRadius: BorderRadius.circular(RiyoTheme.radiusXl),
        border: Border.all(color: RiyoTheme.gray700, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(RiyoTheme.space5),
            child: Row(
              children: [
                Icon(
                  Icons.assessment_rounded,
                  size: 22,
                  color: RiyoTheme.white,
                ),
                const SizedBox(width: RiyoTheme.space3),
                Text(
                  'Subject-wise Marks',
                  style: RiyoTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: RiyoTheme.gray700,
            indent: RiyoTheme.space5,
            endIndent: RiyoTheme.space5,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: RiyoTheme.space2),
            itemCount: subjects.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              thickness: 0.5,
              color: RiyoTheme.gray700,
              indent: RiyoTheme.space5,
              endIndent: RiyoTheme.space5,
            ),
            itemBuilder: (context, index) {
              final sub = subjects[index] as Map<String, dynamic>;
              final subjectName = sub['subject'] as String? ?? 'Subject';
              final obtained =
                  sub['get_marks'] ??
                  sub['obtained_marks'] ??
                  sub['marks_obtained'];
              final maxMarks = sub['max_marks'] ?? sub['total_marks'] ?? 100;
              final subjectGrade = sub['grade'] as String? ?? '';
              final obtainedNum = (obtained is num)
                  ? obtained.toInt()
                  : int.tryParse(obtained.toString()) ?? 0;
              final maxNum = (maxMarks is num)
                  ? maxMarks.toInt()
                  : int.tryParse(maxMarks.toString()) ?? 100;
              final percent = maxNum > 0 ? (obtainedNum / maxNum * 100) : 0.0;

              return _SubjectTile(
                subjectName: subjectName,
                obtainedNum: obtainedNum,
                maxNum: maxNum,
                percent: percent,
                subjectGrade: subjectGrade,
                gradeColor: _gradeColor(subjectGrade),
                percentColor: _percentageColor(percent),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExamInfo(
    String examGroup,
    String session,
    String className,
    String examDate,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        RiyoTheme.space4,
        0,
        RiyoTheme.space4,
        RiyoTheme.space4,
      ),
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
            'Exam Information',
            style: RiyoTheme.titleMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: RiyoTheme.space4),
          _InfoRow(
            icon: Icons.assignment_rounded,
            label: 'Exam',
            value: examGroup,
          ),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Session',
            value: session,
          ),
          _InfoRow(icon: Icons.class_rounded, label: 'Class', value: className),
          if (examDate.isNotEmpty)
            _InfoRow(
              icon: Icons.event_rounded,
              label: 'Date',
              value: _formatDate(examDate),
            ),
        ],
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
        return const Color(0xFF00BA7C);
      case 'B+':
      case 'B':
        return const Color(0xFF1DA1F2);
      case 'C+':
      case 'C':
        return const Color(0xFFFFB300);
      case 'D':
        return const Color(0xFFFF6B6B);
      case 'F':
        return const Color(0xFFEF4444);
      default:
        return RiyoTheme.gray500;
    }
  }

  Color _percentageColor(double percent) {
    if (percent >= 90) return const Color(0xFF00BA7C);
    if (percent >= 75) return const Color(0xFF1DA1F2);
    if (percent >= 60) return const Color(0xFFFFB300);
    if (percent >= 40) return const Color(0xFFFF6B6B);
    return const Color(0xFFEF4444);
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

class _SubjectTile extends StatelessWidget {
  final String subjectName;
  final int obtainedNum;
  final int maxNum;
  final double percent;
  final String subjectGrade;
  final Color gradeColor;
  final Color percentColor;

  const _SubjectTile({
    required this.subjectName,
    required this.obtainedNum,
    required this.maxNum,
    required this.percent,
    required this.subjectGrade,
    required this.gradeColor,
    required this.percentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: RiyoTheme.space5,
        vertical: RiyoTheme.space3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subjectName,
                  style: RiyoTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (subjectGrade.isNotEmpty) ...[
                const SizedBox(width: RiyoTheme.space3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RiyoTheme.space3,
                    vertical: RiyoTheme.space1,
                  ),
                  decoration: BoxDecoration(
                    color: gradeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
                    border: Border.all(
                      color: gradeColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    subjectGrade,
                    style: RiyoTheme.labelMedium.copyWith(
                      color: gradeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: RiyoTheme.space3),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: RiyoTheme.gray800,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: (percent / 100).clamp(0.0, 1.0),
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: percentColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: RiyoTheme.space2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$obtainedNum / $maxNum',
                          style: RiyoTheme.labelMedium.copyWith(
                            color: RiyoTheme.gray400,
                          ),
                        ),
                        Text(
                          '${percent.toStringAsFixed(1)}%',
                          style: RiyoTheme.labelMedium.copyWith(
                            color: percentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
