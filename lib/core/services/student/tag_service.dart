import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/tag.dart';
import '../../../data/models/student_tag.dart';

class TagService {
  final _client = Supabase.instance.client;

  /// Fetch all tags from the tags table
  Future<List<Tag>> fetchAllTags() async {
    try {
      final response = await _client
          .from('tags')
          .select()
          .order('name', ascending: true);

      final data = response as List<dynamic>? ?? [];
      return data
          .map((tag) => Tag.fromMap(tag as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching tags: $e');
      return [];
    }
  }

  /// Fetch tags by category
  Future<List<Tag>> fetchTagsByCategory(String category) async {
    try {
      final response = await _client
          .from('tags')
          .select()
          .eq('category', category)
          .order('name', ascending: true);

      final data = response as List<dynamic>? ?? [];
      return data
          .map((tag) => Tag.fromMap(tag as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching tags by category: $e');
      return [];
    }
  }

  /// Save student interests (tags) to student_tags table
  Future<bool> saveStudentInterests(
    String studentId,
    List<String> tagIds,
  ) async {
    try {
      // First, remove existing interests for this student
      await _client.from('student_tags').delete().eq('student_id', studentId);

      // Then insert new interests
      final studentTags = tagIds
          .map((tagId) => {'student_id': studentId, 'tag_id': tagId})
          .toList();

      await _client.from('student_tags').insert(studentTags);

      return true;
    } catch (e) {
      print('Error saving student interests: $e');
      return false;
    }
  }

  /// Fetch student's selected interests
  Future<List<StudentTag>> fetchStudentInterests(String studentId) async {
    try {
      final response = await _client
          .from('student_tags')
          .select()
          .eq('student_id', studentId);

      final data = response as List<dynamic>? ?? [];
      return data
          .map(
            (studentTag) =>
                StudentTag.fromMap(studentTag as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error fetching student interests: $e');
      return [];
    }
  }

  /// Fetch student's selected interests with tag details
  Future<List<Tag>> fetchStudentInterestTags(String studentId) async {
    try {
      final response = await _client
          .from('student_tags')
          .select('tag_id, tags(*)')
          .eq('student_id', studentId);

      final data = response as List<dynamic>? ?? [];
      return data
          .map((item) => Tag.fromMap(item['tags'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching student interest tags: $e');
      return [];
    }
  }

  /// Get students who are interested in specific tags (for recommendation system)
  Future<List<String>> getStudentsByTags(List<String> tagIds) async {
    try {
      final response = await _client
          .from('student_tags')
          .select('student_id')
          .inFilter('tag_id', tagIds);

      final data = response as List<dynamic>? ?? [];
      return data
          .map((item) => item['student_id'] as String)
          .toSet() // Remove duplicates
          .toList();
    } catch (e) {
      print('Error fetching students by tags: $e');
      return [];
    }
  }

  /// Check if a student is interested in a specific tag
  Future<bool> isStudentInterestedInTag(String studentId, String tagId) async {
    try {
      final response = await _client
          .from('student_tags')
          .select('student_id')
          .eq('student_id', studentId)
          .eq('tag_id', tagId)
          .limit(1);

      final data = response as List<dynamic>? ?? [];
      return data.isNotEmpty;
    } catch (e) {
      print('Error checking student interest: $e');
      return false;
    }
  }
}
