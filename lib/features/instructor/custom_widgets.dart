import 'package:flutter/material.dart';

class OverviewBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const OverviewBox({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.18),
            child: Icon(icon, color: color, size: 28),
            radius: 22,
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const ActivityItem({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

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
          Text(subtitle, style: const TextStyle(color: Color(0xFF0D47A1))),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
          const Spacer(),
          LinearProgressIndicator(value: progress),
          Text("${(progress * 10).toInt()}/10", style: const TextStyle(color: Color(0xFF0D47A1))),
        ],
      ),
    );
  }
}

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
              radius: 18,
              child: Icon(icon, color: color, size: 22),
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
      subtitle: Text("\u001b[1m$time\u001b[22m \u001b[1m\u001b[22m\u001b[1m•\u001b[22m $category", style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.comment, size: 18),
    );
  }
}
