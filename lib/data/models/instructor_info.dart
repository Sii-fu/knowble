// instructor_info.dart
// Model for instructor information matching the instructor_info table in Supabase

class InstructorInfo {
  final String? id;
  final String userId;
  final String phoneNumber;
  final String educationDegree;
  final int teachingExperience;
  final String? currentLocation;
  final List<String> subjectExpertise;
  final String bio;
  final String cvFileName;
  final String cvFilePath;
  final String verificationStatus;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InstructorInfo({
    this.id,
    required this.userId,
    required this.phoneNumber,
    required this.educationDegree,
    required this.teachingExperience,
    this.currentLocation,
    required this.subjectExpertise,
    required this.bio,
    required this.cvFileName,
    required this.cvFilePath,
    this.verificationStatus = 'pending',
    this.submittedAt,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor for creating InstructorInfo from JSON
  factory InstructorInfo.fromJson(Map<String, dynamic> json) {
    return InstructorInfo(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      phoneNumber: json['phone_number'] as String,
      educationDegree: json['education_degree'] as String,
      teachingExperience: json['teaching_experience'] as int,
      currentLocation: json['current_location'] as String?,
      subjectExpertise: List<String>.from(json['subject_expertise'] ?? []),
      bio: json['bio'] as String,
      cvFileName: json['cv_file_name'] as String,
      cvFilePath: json['cv_file_path'] as String,
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Convert InstructorInfo to JSON for Supabase insertion
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'phone_number': phoneNumber,
      'education_degree': educationDegree,
      'teaching_experience': teachingExperience,
      if (currentLocation != null) 'current_location': currentLocation,
      'subject_expertise': subjectExpertise,
      'bio': bio,
      'cv_file_name': cvFileName,
      'cv_file_path': cvFilePath,
      'verification_status': verificationStatus,
      if (submittedAt != null) 'submitted_at': submittedAt!.toIso8601String(),
      if (verifiedAt != null) 'verified_at': verifiedAt!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Convert to JSON for insertion (excludes id, timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'phone_number': phoneNumber,
      'education_degree': educationDegree,
      'teaching_experience': teachingExperience,
      if (currentLocation != null) 'current_location': currentLocation,
      'subject_expertise': subjectExpertise,
      'bio': bio,
      'cv_file_name': cvFileName,
      'cv_file_path': cvFilePath,
      'verification_status': verificationStatus,
    };
  }

  // Copy with method for updates
  InstructorInfo copyWith({
    String? id,
    String? userId,
    String? phoneNumber,
    String? educationDegree,
    int? teachingExperience,
    String? currentLocation,
    List<String>? subjectExpertise,
    String? bio,
    String? cvFileName,
    String? cvFilePath,
    String? verificationStatus,
    DateTime? submittedAt,
    DateTime? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InstructorInfo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      educationDegree: educationDegree ?? this.educationDegree,
      teachingExperience: teachingExperience ?? this.teachingExperience,
      currentLocation: currentLocation ?? this.currentLocation,
      subjectExpertise: subjectExpertise ?? this.subjectExpertise,
      bio: bio ?? this.bio,
      cvFileName: cvFileName ?? this.cvFileName,
      cvFilePath: cvFilePath ?? this.cvFilePath,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'InstructorInfo{id: $id, userId: $userId, phoneNumber: $phoneNumber, educationDegree: $educationDegree, teachingExperience: $teachingExperience, verificationStatus: $verificationStatus}';
  }
}
