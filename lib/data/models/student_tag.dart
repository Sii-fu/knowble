// student_tag.dart
// StudentTag model for Knowble, matching the student_tags table in the database.

class StudentTag {
  final String studentId;
  final String tagId;

  StudentTag({required this.studentId, required this.tagId});

  factory StudentTag.fromMap(Map<String, dynamic> map) {
    return StudentTag(
      studentId: map['student_id'] as String,
      tagId: map['tag_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'student_id': studentId, 'tag_id': tagId};
  }
}
