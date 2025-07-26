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
      print('Uploading file: $fileName for user: ${user.id}');
      print('User auth status: ${user.aud}, Role: ${user.role}');
      print('User metadata: ${user.userMetadata}');
      
      dynamic response;
      
      // Upload to content-pdf bucket (same as PDF uploads that work)
      response = await supabase.storage.from('content-pdf').uploadBinary(
        fileName, 
        bytes, 
        fileOptions: const FileOptions(upsert: true)
      );
      
      if (response == null || (response is String && response.isEmpty)) {
        return null;
      }
      
      // Get public URL
      final publicUrl = supabase.storage.from('content-pdf').getPublicUrl(fileName);
      print('Upload successful! Public URL: $publicUrl');
      return publicUrl;
      
    } on StorageException catch (e) {
      if (e.statusCode == 404 && e.message.contains('Bucket not found')) {
        throw Exception(
          'Storage bucket not found. Please create a "content-pdf" bucket in Supabase Storage or contact administrator.'
        );
      } else if (e.statusCode == 403 || e.message.contains('row-level security policy')) {
        throw Exception(
          'Upload permission denied. Run these SQL commands in your Supabase SQL Editor:\n\n'
          '-- Disable RLS temporarily for testing\n'
          'ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;\n\n'
          '-- Or create policy for profilepics bucket\n'
          'CREATE POLICY "profilepics_insert" ON storage.objects\n'
          'FOR INSERT TO authenticated\n'
          'WITH CHECK (bucket_id = \'profilepics\');\n\n'
          'CREATE POLICY "profilepics_select" ON storage.objects\n'
          'FOR SELECT TO authenticated\n'
          'USING (bucket_id = \'profilepics\');'
        );
      } else if (e.message.contains('mime type') || e.message.contains('not supported')) {
        throw Exception(  
          'File type not supported. Error: ${e.message}\n'
          'Make sure your bucket allows image files.'
        );
      } else {
        throw Exception('Storage error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}