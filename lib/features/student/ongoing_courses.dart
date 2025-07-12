import 'package:flutter/material.dart';
import '../../config/theme.dart';

class OngoingCoursesPage extends StatelessWidget {
  const OngoingCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _TopBar(),
                SizedBox(height: 16),
                _SearchBox(),
                SizedBox(height: 20),
                _FilterTabs(),
                SizedBox(height: 20),
                Expanded(child: _OngoingCourseList()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 6),
        Text('My Courses', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for ...',
                border: InputBorder.none,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.search, color: theme.colorScheme.onPrimary, size: 20),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.accentLight,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text('Completed', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text('Ongoing', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}

class _OngoingCourseList extends StatelessWidget {
  const _OngoingCourseList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses = [
      {
        'category': 'UI/UX Design',
        'title': 'Intro to UI/UX Design',
        'duration': '3 Hrs 06 Mins',
        'progress': 93,
        'total': 125,
        'color': Colors.teal,
        'image': 'assets/images/gd1.jpg',
      },
      {
        'category': 'Web Development',
        'title': 'Wordpress website Dev..',
        'duration': '1 Hrs 58 Mins',
        'progress': 12,
        'total': 31,
        'color': Colors.amber,
        'image': 'assets/images/web.png',
      },
      {
        'category': 'UI/UX Design',
        'title': '3D Blender and UI/UX',
        'duration': '2 Hrs 46 Mins',
        'progress': 56,
        'total': 98,
        'color': Colors.redAccent,
        'image': 'assets/images/gd2.jpg',
      },
      {
        'category': 'UX/UI Design',
        'title': 'Learn UX User Persona',
        'duration': '1 Hrs 58 Mins',
        'progress': 0,
        'total': 31,
        'color': Colors.teal,
        'image': 'assets/images/dm.jpg',
      },
    ];

    return ListView.separated(
      itemCount: courses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final course = courses[index];
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 5,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: Image.asset(
                  course['image'] as String,
                  height: 100,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course['category'] as String, style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange)),
                      const SizedBox(height: 4),
                      Text(course['title'] as String, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(course['duration'] as String, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          value: (course['progress'] as int) / (course['total'] as int),
                          valueColor: AlwaysStoppedAnimation<Color>(course['color']! as Color),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('${course['progress']}/${course['total']}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
