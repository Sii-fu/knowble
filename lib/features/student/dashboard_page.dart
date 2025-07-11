import 'package:flutter/material.dart';


class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const _BottomNavBar(),
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
                SizedBox(height: 12),
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
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Hi, Christina',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('What do you want to learn today?', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const Icon(Icons.notifications_none_rounded, size: 26),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: Text('Search', style: TextStyle(color: Colors.grey)),
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
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
    return Container(
      width: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
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
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress / total, color: Colors.teal),
          Align(
            alignment: Alignment.centerRight,
            child: Text("$progress/$total", style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
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
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(lessons, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const Spacer(),
              if (duration.isNotEmpty) ...[
                const Icon(Icons.access_time, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(duration, style: const TextStyle(fontSize: 11, color: Colors.grey))
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black87)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.teal),
                  const SizedBox(width: 4),
                  Text(location, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'My Courses'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Inbox'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Schedule'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
