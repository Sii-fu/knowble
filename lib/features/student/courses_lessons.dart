import 'package:flutter/material.dart';

class CourseLessonsPage extends StatelessWidget {
  const CourseLessonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lessons = [
      {
        'section': 'Section 01 - Introduction',
        'totalTime': '25 Mins',
        'items': [
          {'number': '01', 'title': 'Why Using 3D Blender', 'duration': '15 Mins'},
          {'number': '02', 'title': '3D Blender Installation', 'duration': '10 Mins'},
        ],
      },
      {
        'section': 'Section 02 - Graphic Design',
        'totalTime': '125 Mins',
        'items': [
          {'number': '03', 'title': 'Take a Look Blender Interface', 'duration': '20 Mins'},
          {'number': '04', 'title': 'The Basic of 3D Modelling', 'duration': '25 Mins'},
          {'number': '05', 'title': 'Shading and Lighting', 'duration': '36 Mins'},
        ],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_ios),
                  const SizedBox(width: 6),
                  Text(
                    'Lessons',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: '3D Design Illustration',
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
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final section = lessons[index];
                  final items = section['items'] as List<dynamic>;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            section['section'] as String,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            section['totalTime'] as String,
                            style: const TextStyle(color: Color(0xFF007C77), fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...items.map((lesson) => Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(0xFFEAF3FF),
                                  child: Text(
                                    lesson['number'],
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lesson['title'],
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        lesson['duration'],
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.play_circle_fill, color: Colors.teal, size: 28),
                                  onPressed: () {
                                    // Play video logic
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.deepOrange, size: 26),
                                  onPressed: () {
                                    // Open PDF logic
                                  },
                                ),
                              ],
                            ),
                          ))
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF3FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.assignment_turned_in_outlined, color: Colors.teal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF009688), Color(0xFF006C66)],
                        ),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          // TODO: Implement restart course logic
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text(
                          'Start Course Again',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
