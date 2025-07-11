import 'package:flutter/material.dart';
import '../../config/theme.dart';
// import 'courses_page.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        // bottomNavigationBar: const _BottomNavBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const _Header(),
                  const SizedBox(height: 16),
                  const _SearchBar(),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Recent learning'),
                  const SizedBox(height: 12),
                  const _RecentLearning(),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Recommended'),
                  const SizedBox(height: 12),
                  const _RecommendedCourses(),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: "Today's Task"),
                  const SizedBox(height: 12),
                  const _TaskCard(
                    time: '7AM - 8PM',
                    title: 'Go to office',
                    subtitle: 'meeting with client singapure',
                    location: 'Plaza Indonesia',
                  ),
                  const SizedBox(height: 12),
                  const _TaskCard(
                    time: '7AM - 8PM',
                    title: 'Project app baparekraf',
                    subtitle: 'talk to environment',
                    location: 'Pondok indah mall',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, Christina',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('What do you want to learn today?', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
          ],
        ),
        Icon(Icons.notifications_none_rounded, size: 26, color: theme.colorScheme.primary),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Search', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
          )
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _RecentLearning extends StatelessWidget {
  const _RecentLearning();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _CourseCard(
            title: 'High School Algebra I: Help and Review',
            image: 'assets/images/algebra1.jpg',
            progress: 5,
            total: 10,
          ),
          SizedBox(width: 12),
          _CourseCard(
            title: 'Enlargement to Trigonometry',
            image: 'assets/images/trig.jpg',
            progress: 5,
            total: 10,
          ),
        ],
      ),
    );
  }
}

class _RecommendedCourses extends StatelessWidget {
  const _RecommendedCourses();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _RecommendedCard(title: 'Bacterial Biology Overview', lessons: '12 Lessons', duration: '12h 20m', image: 'assets/images/bio1.jpg'),
          SizedBox(width: 12),
          _RecommendedCard(title: 'Mendelian Genetics & Mechanisms of Her...', lessons: '14 Lessons', duration: '18h 20m', image: 'assets/images/bio2.jpg'),
          SizedBox(width: 12),
          _RecommendedCard(title: 'Metabolic Biochemistry for High School', lessons: '12 Lessons', duration: '', image: 'assets/images/bio3.png'),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final String title;
  final String image;
  final int progress;
  final int total;

  const _CourseCard({required this.title, required this.image, required this.progress, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              image,
              width: double.infinity,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress / total, color: theme.colorScheme.primary),
          Align(
            alignment: Alignment.centerRight,
            child: Text("$progress/$total", style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
          )
        ],
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final String title;
  final String lessons;
  final String duration;
  final String image;

  const _RecommendedCard({required this.title, required this.lessons, required this.duration, required this.image});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              image,
              width: double.infinity,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(lessons, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
              const Spacer(),
              if (duration.isNotEmpty) ...[
                Icon(Icons.access_time, size: 12, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(duration, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary))
              ]
            ],
          )
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final String location;

  const _TaskCard({required this.time, required this.title, required this.subtitle, required this.location});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(time, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accentLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(location, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

// class _BottomNavBar extends StatelessWidget {
//   const _BottomNavBar();

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: 0,
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: const Color(0xFF006C66),
//       unselectedItemColor: Colors.grey,
//       onTap: (index) {
//         if (index == 1) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const StudentCoursesPage()),
//           );
//         }
//       },
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
//         BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'MY COURSES'),
//         BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'INBOX'),
//         BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'SCHEDULE'),
//         BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
//       ],
//     );
//   }
// }
