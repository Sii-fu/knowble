import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';



class StudentProfileService {
  final supabase = Supabase.instance.client;
  final uuid = const Uuid();

  Future<Map<String, dynamic>?> fetchStudentProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final response = await supabase
        .from('users')
        .select('*')
        .eq('id', user.id)
        .single();
    return response as Map<String, dynamic>?;
  }

  Future<void> updateProfile({
    required String name,
    String? profilePictureUrl,
    String? bio,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    
    await supabase.from('users').update({
      'name': name,
      'profile_pic': profilePictureUrl,
      'bio': bio,
    }).eq('id', user.id);
  }

  Future<void> updateUserField(String field, dynamic value) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    
    await supabase.from('users').update({
      field: value,
    }).eq('id', user.id);
  }

  Future<String?> uploadProfilePicture(Uint8List bytes, String fileName) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    try {
      // Upload to Supabase Storage
      await supabase.storage
          .from('profiles')
          .uploadBinary(fileName, bytes);
      
      // Get public URL
      final imageUrl = supabase.storage
          .from('profiles')
          .getPublicUrl(fileName);
      
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}