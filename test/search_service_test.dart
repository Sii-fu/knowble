import 'package:flutter_test/flutter_test.dart';
import '../lib/core/services/student/search_service.dart';

void main() {
  group('Course Model Tests', () {
    test('Course.fromJson should correctly parse course_search_view data', () {
      final jsonData = {
        'id': '123',
        'title': 'Test Course',
        'description': 'A test course description',
        'instructor_name': 'John Doe',
        'price': 99.99,
        'is_paid': true,
        'duration_days': 30,
        'avg_rating': 4.5,
        'students_count': 150,
        'tags': ['Programming', 'Flutter', 'Mobile'],
        'created_at': '2023-01-01T00:00:00Z',
      };

      final course = Course.fromJson(jsonData);

      expect(course.id, '123');
      expect(course.title, 'Test Course');
      expect(course.description, 'A test course description');
      expect(course.instructorName, 'John Doe');
      expect(course.price, 99.99);
      expect(course.isPaid, true);
      expect(course.durationDays, 30);
      expect(course.avgRating, 4.5);
      expect(course.studentsCount, 150);
      expect(course.tags, ['Programming', 'Flutter', 'Mobile']);
      expect(course.createdAt.year, 2023);
    });

    test('Course.fromJson should handle null/missing fields gracefully', () {
      final jsonData = <String, dynamic>{
        'id': '456',
      };

      final course = Course.fromJson(jsonData);

      expect(course.id, '456');
      expect(course.title, '');
      expect(course.description, '');
      expect(course.instructorName, 'Unknown Instructor');
      expect(course.price, 0.0);
      expect(course.isPaid, false);
      expect(course.durationDays, 0);
      expect(course.avgRating, 0.0);
      expect(course.studentsCount, 0);
      expect(course.tags, []);
    });

    test('Course.toJson should correctly serialize course data', () {
      final course = Course(
        id: '789',
        title: 'Another Course',
        description: 'Another description',
        instructorName: 'Jane Smith',
        price: 149.99,
        isPaid: true,
        durationDays: 45,
        avgRating: 4.8,
        studentsCount: 200,
        tags: ['Web Development', 'JavaScript'],
        createdAt: DateTime(2023, 6, 15),
      );

      final json = course.toJson();

      expect(json['id'], '789');
      expect(json['title'], 'Another Course');
      expect(json['instructor_name'], 'Jane Smith');
      expect(json['price'], 149.99);
      expect(json['is_paid'], true);
      expect(json['duration_days'], 45);
      expect(json['avg_rating'], 4.8);
      expect(json['students_count'], 200);
      expect(json['tags'], ['Web Development', 'JavaScript']);
      expect(json['created_at'], '2023-06-15T00:00:00.000');
    });
  });
}
