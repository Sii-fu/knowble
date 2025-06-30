import 'package:flutter/material.dart';
import 'edit_course_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final String title;
  final String subject;
  final String students;
  final String duration;

  const CourseDetailScreen({
    Key? key,
    required this.title,
    required this.subject,
    required this.students,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Blue header section with illustration
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[600]!,
                  Colors.blue[700]!,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                // Interactive Back button
                Positioned(
                  top: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                // Interactive Close button
                Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                // Mathematical symbols and illustrations
                Positioned(
                  top: 40,
                  left: 40,
                  child: Icon(Icons.add, color: Colors.white.withOpacity(0.3), size: 20),
                ),
                Positioned(
                  top: 60,
                  right: 60,
                  child: Icon(Icons.close, color: Colors.white.withOpacity(0.3), size: 16),
                ),
                Positioned(
                  bottom: 40,
                  left: 30,
                  child: Icon(Icons.percent, color: Colors.white.withOpacity(0.3), size: 18),
                ),
                // Person illustration (using icon as placeholder)
                Positioned(
                  bottom: 20,
                  left: 60,
                  right: 60,
                  child: Icon(
                    Icons.person,
                    color: Colors.white.withOpacity(0.4),
                    size: 80,
                  ),
                ),
                // Calculator illustration
                Positioned(
                  bottom: 30,
                  right: 40,
                  child: Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4),
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              '12345',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 4,
                            children: List.generate(16, (index) {
                              return Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course title and info
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subject,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '10 Chapter',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Description section
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                              'Habitasse dolor etiam sed ante donec quis sapien. '
                              'Malesuada rhoncus nullam eleifend lorem egestas mauris '
                              'massa massa. ',
                        ),
                        TextSpan(
                          text: 'More',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Your Chapter section
                  const Text(
                    'Your Chapter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Chapter list
                  ...chapterList.map((chapter) => ChapterItem(title: chapter)),
                ],
              ),
            ),
          ),
          // Edit Course button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditCourseScreen(
                        courseTitle: title,
                        subject: subject,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Edit Course',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChapterItem extends StatelessWidget {
  final String title;

  const ChapterItem({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Expand chapter functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title chapter expanded')),
              );
            },
            icon: const Icon(
              Icons.add,
              color: Colors.black54,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// Sample chapter data
const List<String> chapterList = [
  'Basic Arithmetic',
  'Solving Math Word Problems',
  'Quiz',
  'Decimals and Fractions',
  'Percent Notation',
  'Real Numbers',
  'Exponential Expressions & Exponents',
  'Radical Expressions',
];