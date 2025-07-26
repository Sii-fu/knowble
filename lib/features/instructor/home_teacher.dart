import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'custom_widgets.dart';
// Make sure this is the stateless navbar with currentIndex and onTap
import 'course_screen.dart'; // Import the CourseScreen

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CourseScreen()),
      );
    }
    // Add logic to change views if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, Samuel',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications_none, color: Colors.grey),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  hintText: "Search",
                ),
              ),
            ),

            // Lesson Progress
            const Text("Lesson Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  LessonCard(
                    title: "High School Algebra I: Help and Review",
                    subtitle: "Mathematics",
                    progress: 0.5,
                  ),
                  LessonCard(
                    title: "Enlargement to Trigonometry",
                    subtitle: "Mathematics",
                    progress: 0.5,
                  ),
                ],
              ),
            ),

            // Statistics
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Statistic", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  items: const [DropdownMenuItem(value: "Month", child: Text("Month"))],
                  onChanged: (value) {},
                  value: "Month",
                ),
              ],
            ),
            const SizedBox(height: 8),
            const StatisticCard(),

            // Revenue
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Revenue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  items: const [DropdownMenuItem(value: "2020", child: Text("2020"))],
                  onChanged: (value) {},
                  value: "2020",
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 0),
                        FlSpot(1, 5),
                        FlSpot(2, 15),
                        FlSpot(3, 8),
                        FlSpot(4, 18),
                        FlSpot(5, 15.2),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),

            // Latest News
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Latest News", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("See all", style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 8),
            const NewsTile(
              category: "Biology",
              title: "The Effects of Temperature on Enzyme Activity and Biology",
              time: "1 hour ago",
            ),
            const NewsTile(
              category: "Mathematics",
              title: "How to Work Out a Percentage Using a Calculator",
              time: "24 August 2020",
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      
    );
  }
}

// Lesson Card Widget
class LessonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;

  const LessonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          LinearProgressIndicator(value: progress),
          Text("${(progress * 10).toInt()}/10"),
        ],
      ),
    );
  }
}

// Statistic Card
class StatisticCard extends StatelessWidget {
  const StatisticCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statBox(
            icon: Icons.menu_book_rounded,
            title: "Your Course",
            value: "23 Lesson",
            color: Colors.blue,
            bgColor: Colors.blue.withOpacity(0.1),
          ),
          _statBox(
            icon: Icons.people_alt_rounded,
            title: "Your Audience",
            value: "10,458",
            color: Colors.red,
            bgColor: Colors.red.withOpacity(0.1),
            change: "-23.47%",
          ),
          _statBox(
            icon: Icons.access_time_rounded,
            title: "Watch Time",
            value: "35 min",
            color: Colors.green,
            bgColor: Colors.green.withOpacity(0.1),
            change: "+23.47%",
          ),
          _statBox(
            icon: Icons.star_rounded,
            title: "Reviews",
            value: "20,254",
            color: Colors.amber[800]!,
            bgColor: Colors.amber.withOpacity(0.1),
            change: "+23.47%",
          ),
        ],
      ),
    );
  }

  Widget _statBox({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color bgColor,
    String? change,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 22),
              radius: 18,
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            if (change != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  change,
                  style: TextStyle(
                    color: change.startsWith('+') ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// News Tile
class NewsTile extends StatelessWidget {
  final String category;
  final String title;
  final String time;

  const NewsTile({
    super.key,
    required this.category,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(width: 50, height: 50, color: Colors.grey.shade300),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text("[1m$time[22m [1m[22m[1m•[22m $category", style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.comment, size: 18),
    );
  }
}
