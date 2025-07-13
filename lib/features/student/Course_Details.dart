import 'package:flutter/material.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/algebra1.jpg', // Replace with actual path
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                const Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.play_arrow, size: 30, color: Colors.black),
                    ),
                  ),
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'High School Algebra I: Help and Review',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mathematics'),
                      Row(
                        children: [
                          Text('5/12'),
                          SizedBox(width: 8),
                          SizedBox(
                            width: 100,
                            child: LinearProgressIndicator(
                              value: 5 / 12,
                              backgroundColor: Color.fromARGB(255, 224, 224, 224),
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Habitasse dolor etiam sed ante donec quis sapien. Malesuada rhoncus nullam eleifend lorem egestas mauris massa massa.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text('More', style: TextStyle(color: Colors.teal)),
                  SizedBox(height: 16),
                  Text('Next Chapter', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Expanded(
              child: ChapterList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    backgroundColor: Colors.teal,
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Start Course',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ChapterList extends StatelessWidget {
  const ChapterList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const ListTile(
          title: Text('Basic Arithmetic'),
          trailing: Icon(Icons.add),
        ),
        const ListTile(
          title: Text('Solving Math Word Problems'),
          trailing: Icon(Icons.remove),
        ),
        LessonTile(title: 'Lesson 1: Solving Word Problems: Steps & Examples'),
        LessonTile(title: 'Lesson 2: Solving Word Problems with Multiple Steps'),
        LessonTile(title: 'Lesson 3: Restating Word Problems Using Words or Images'),
        const ListTile(
          title: Text('Quiz'),
          trailing: Icon(Icons.remove),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Practicing Mixture Problems in Algebra'),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.teal.shade50,
                ),
                child: const Text('Take Quiz'),
              )
            ],
          ),
        ),
        const ListTile(
          title: Text('Decimals and Fractions'),
          trailing: Icon(Icons.add),
        ),
      ],
    );
  }
}

class LessonTile extends StatelessWidget {
  final String title;
  const LessonTile({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32, right: 8),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.play_circle_fill, color: Colors.teal),
    );
  }
}
