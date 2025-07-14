import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'chatbot/chatbotpage.dart';

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
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios, 
                      color: AppTheme.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Lessons',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
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
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '3D Design Illustration',
                          hintStyle: TextStyle(color: AppTheme.textSecondary),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.search, color: AppTheme.surfaceWhite, size: 20),
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
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            section['totalTime'] as String,
                            style: const TextStyle(
                              color: AppTheme.primaryTeal, 
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...items.map((lesson) => Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.shadowLight,
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
                                  backgroundColor: AppTheme.accentLight,
                                  child: Text(
                                    lesson['number'],
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lesson['title'],
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        lesson['duration'],
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.play_circle_fill, 
                                    color: AppTheme.primaryTeal, 
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    // Play video logic
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.picture_as_pdf_outlined, 
                                    color: AppTheme.errorRed, 
                                    size: 26,
                                  ),
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
                color: AppTheme.surfaceWhite,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
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
                      color: AppTheme.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_outlined, 
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: AppTheme.gradient,
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          // TODO: Implement restart course logic
                        },
                        icon: const Icon(Icons.refresh, color: AppTheme.surfaceWhite),
                        label: const Text(
                          'Start Course Again',
                          style: TextStyle(
                            color: AppTheme.surfaceWhite, 
                            fontWeight: FontWeight.w600,
                          ),
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
              floatingActionButton: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatBotPage(),
                    ),
                  );
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: AppTheme.surfaceWhite,
                  size: 28,
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
    );
  }
}
