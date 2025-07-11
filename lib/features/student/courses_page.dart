import 'package:flutter/material.dart';
import 'dashboard_page.dart'; // Make sure this file exists

class StudentCoursesPage extends StatelessWidget {
  const StudentCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      bottomNavigationBar: _BottomNavBar(),
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
              Expanded(child: _CourseList()),
            ],
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
    return Row(
      children: const [
        Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
        SizedBox(width: 6),
        Text('My Courses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for ...',
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF006C66),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 20),
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
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF006C66),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Text('Completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE7EEFB),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Text('Ongoing', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CourseList extends StatelessWidget {
  const _CourseList();

  @override
  Widget build(BuildContext context) {
    final courses = [
      {
        'category': 'Graphic Design',
        'title': 'Graphic Design Advanced',
        'rating': '4.2',
        'duration': '2 Hrs 36 Mins',
        'image': 'assets/images/gd1.jpg'
      },
      {
        'category': 'Graphic Design',
        'title': 'Advance Diploma in Gra..',
        'rating': '4.7',
        'duration': '3 Hrs 28 Mins',
        'image': 'assets/images/gd2.jpg'
      },
      {
        'category': 'Digital Marketing',
        'title': 'Setup your Graphic Des..',
        'rating': '4.2',
        'duration': '4 Hrs 05 Mins',
        'image': 'assets/images/dm.jpg'
      },
      {
        'category': 'Web Development',
        'title': 'Web Developer conce..',
        'rating': '4.2',
        'duration': '3 Hrs 45 Mins',
        'image': 'assets/images/web.png'
      },
    ];

    return ListView.separated(
      itemCount: courses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final course = courses[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                  course['image']!,
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
                      Text(course['category']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.orange)),
                      const SizedBox(height: 4),
                      Text(course['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(course['rating']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          Text(course['duration']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('VIEW CERTIFICATE', style: TextStyle(color: Colors.teal.shade800, fontSize: 13, fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF006C66),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StudentDashboardPage()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'MY COURSES'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'INBOX'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'SCHEDULE'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
      ],
    );
  }
}
