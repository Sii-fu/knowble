import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class InstructorProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> fetchInstructorProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // First get user data from users table
      final userResponse = await _supabase
          .from('users')
          .select('''
            id,
            name,
            email,
            role,
            profile_pic,
            bio,
            is_verified,
            created_at
          ''')
          .eq('id', user.id)
          .single();

      // Then get instructor-specific data from instructor_info table
      final instructorResponse = await _supabase
          .from('instructor_info')
          .select('''
            id,
            user_id,
            phone_number,
            education_degree,
            teaching_experience,
            current_location,
            subject_expertise,
            cv_file_name,
            cv_file_path,
            verification_status,
            submitted_at,
            verified_at
          ''')
          .eq('user_id', user.id)
          .maybeSingle();

      // Combine the data
      final combinedData = {
        ...userResponse,
        'phone': instructorResponse?['phone_number'],
        'education': instructorResponse?['education_degree'],
        'experience_years': instructorResponse?['teaching_experience'],
        'specialization': instructorResponse?['subject_expertise'],
        'profile_picture_url': userResponse['profile_pic'],
        'location': instructorResponse?['current_location'],
        'cv_file_name': instructorResponse?['cv_file_name'],
        'cv_file_path': instructorResponse?['cv_file_path'],
        'verification_status': instructorResponse?['verification_status'],
        'instructor_submitted_at': instructorResponse?['submitted_at'],
        'instructor_verified_at': instructorResponse?['verified_at'],
      };

      return combinedData;
    } catch (e) {
      throw Exception('Failed to fetch instructor profile: $e');
    }
  }

  Future<void> updateInstructorField(String field, dynamic value) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Determine which table to update based on the field
      if (field == 'name' || field == 'bio' || field == 'profile_picture_url') {
        // Update users table
        final updateData = <String, dynamic>{};
        if (field == 'profile_picture_url') {
          updateData['profile_pic'] = value;
        } else {
          updateData[field] = value;
        }
        
        await _supabase
            .from('users')
            .update(updateData)
            .eq('id', user.id);
      } else {
        // Update instructor_info table
        final updateData = <String, dynamic>{};
        
        // Map field names to database column names
        switch (field) {
          case 'phone':
            updateData['phone_number'] = value;
            break;
          case 'education':
            updateData['education_degree'] = value;
            break;
          case 'experience_years':
            updateData['teaching_experience'] = value;
            break;
          case 'specialization':
            updateData['subject_expertise'] = value is List ? value : [value];
            break;
          case 'location':
            updateData['current_location'] = value;
            break;
          default:
            updateData[field] = value;
        }
        
        // First check if instructor_info record exists
        final existingRecord = await _supabase
            .from('instructor_info')
            .select('id')
            .eq('user_id', user.id)
            .maybeSingle();
            
        if (existingRecord != null) {
          // Update existing record
          await _supabase
              .from('instructor_info')
              .update(updateData)
              .eq('user_id', user.id);
        } else {
          // Create new record
          updateData['user_id'] = user.id;
          await _supabase
              .from('instructor_info')
              .insert(updateData);
        }
      }
    } catch (e) {
      throw Exception('Failed to update $field: $e');
    }
  }

  Future<String> uploadProfilePicture(XFile imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final bytes = await imageFile.readAsBytes();
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      final fileName = 'instructor_${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      
      // Upload to the content-pdf bucket (which we know works)
      await _supabase.storage
          .from('content-pdf')
          .uploadBinary(fileName, bytes);

      // Get the public URL
      final publicUrl = _supabase.storage
          .from('content-pdf')
          .getPublicUrl(fileName);

      // Update the user profile with the new image URL
      await updateInstructorField('profile_picture_url', publicUrl);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  Future<void> createInstructorProfile({
    required String name,
    String? bio,
    String? phone,
    String? education,
    int? experienceYears,
    List<String>? specialization,
    String? location,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Update user table with basic info
      await _supabase.from('users').update({
        'name': name,
        'bio': bio,
      }).eq('id', user.id);

      // Create or update instructor_info record
      final instructorData = {
        'user_id': user.id,
        'phone_number': phone,
        'education_degree': education,
        'teaching_experience': experienceYears,
        'subject_expertise': specialization,
        'current_location': location,
        'submitted_at': DateTime.now().toIso8601String(),
      };

      // Check if record exists
      final existingRecord = await _supabase
          .from('instructor_info')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingRecord != null) {
        await _supabase
            .from('instructor_info')
            .update(instructorData)
            .eq('user_id', user.id);
      } else {
        await _supabase
            .from('instructor_info')
            .insert(instructorData);
      }
    } catch (e) {
      throw Exception('Failed to create instructor profile: $e');
    }
  }

  Future<void> deleteProfilePicture() async {
    try {
      await updateInstructorField('profile_picture_url', null);
    } catch (e) {
      throw Exception('Failed to delete profile picture: $e');
    }
  }
}
