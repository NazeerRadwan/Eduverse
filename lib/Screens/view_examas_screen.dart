import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  int _currentIndex = 2;

  final List<QuizItem> quizzes = [
    QuizItem(
      title: 'Quiz 9',
      subtitle: 'Present continuous',
      status: QuizStatus.notStarted,
      time: '8:25 am',
    ),
    QuizItem(
      title: 'Quiz 1',
      subtitle: 'Present continuous',
      status: QuizStatus.start,
      time: '8:25 - 9:45',
    ),
    QuizItem(
      title: 'Quiz 1',
      subtitle: 'Present continuous',
      status: QuizStatus.endedWithLabelEnded,
      time: '8:25 - 9:45',
    ),
    QuizItem(
      title: 'Quiz 1',
      subtitle: 'Present continuous',
      status: QuizStatus.endedWithLabelLeft,
      time: '8:25 - 9:45',
    ),
    QuizItem(
      title: 'Quiz 1',
      subtitle: 'Present continuous',
      status: QuizStatus.ended,
      time: '8:25 - 9:45',
    ),
    QuizItem(
      title: 'Quiz 1',
      subtitle: 'Present continuous',
      status: QuizStatus.ended,
      time: '8:25 - 9:45',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 106),
          child: const Text(
            'Quizzes',
            style: TextStyle(
              color: Color(0xFF002E8A),
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: quizzes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = quizzes[index];
          return _QuizCard(item: item);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          // Navigate accordingly in a real app
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            label: 'Lectures',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined, color: Color(0xFF002E8A)),
            label: 'Quizzes',
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({required this.item});

  final QuizItem item;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(item.status, Theme.of(context).colorScheme);
    final statusText = _statusText(item.status);

    return Card(
      //color: Theme.of(context).cardColor,
      //color: Color(0xFF002E8A).withOpacity(0.2),
      clipBehavior: Clip.antiAlias,
      elevation: 0.8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: item.status == QuizStatus.start ? () {} : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.menu_book, color: Color(0xFF002E8A)),
              ),
              const SizedBox(width: 12),
              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + status chip
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        _StatusChip(text: statusText, colors: colors),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),

                        // color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.time,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),

                    if (item.status == QuizStatus.start) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EnglishExamScreen(),
                              ),
                            );
                            // Start quiz action
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF002E8A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text, required this.colors});

  final String text;
  final _StatusColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.foreground.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class QuizItem {
  final String title;
  final String subtitle;
  final QuizStatus status;
  final String time;

  QuizItem({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.time,
  });
}

enum QuizStatus {
  notStarted,
  start,
  ended,
  endedWithLabelEnded,
  endedWithLabelLeft,
}

class _StatusColors {
  final Color background;
  final Color foreground;

  const _StatusColors(this.background, this.foreground);
}

String _statusText(QuizStatus status) {
  switch (status) {
    case QuizStatus.notStarted:
      return 'Not started';
    case QuizStatus.start:
      return 'Start';
    case QuizStatus.ended:
      return 'Ended';
    case QuizStatus.endedWithLabelEnded:
      return 'Ended';
    case QuizStatus.endedWithLabelLeft:
      return 'Left';
  }
}

_StatusColors _statusColors(QuizStatus status, ColorScheme scheme) {
  switch (status) {
    case QuizStatus.notStarted:
      return _StatusColors(
        scheme.primary.withOpacity(0.12),
        Colors.grey.shade700,
      );
    case QuizStatus.start:
      return _StatusColors(scheme.primary.withOpacity(0.12), Color(0xFF002E8A));
    case QuizStatus.ended:
      return _StatusColors(scheme.primary.withOpacity(0.12), Colors.grey[600]!);
    case QuizStatus.endedWithLabelEnded:
      return _StatusColors(scheme.primary.withOpacity(0.12), Colors.grey[600]!);
    case QuizStatus.endedWithLabelLeft:
      return _StatusColors(scheme.primary.withOpacity(0.12), Colors.grey[600]!);
  }
}

// Helpers to construct the special ended labels
extension QuizStatusX on QuizStatus {
  static QuizStatus endedWithLabel(String label) {
    switch (label.toLowerCase()) {
      case 'left':
        return QuizStatus.endedWithLabelLeft;
      case 'ended':
      default:
        return QuizStatus.endedWithLabelEnded;
    }
  }
}
