// instructor_info_service.dart
// Service for managing instructor information in Supabase

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/instructor_info.dart';

class InstructorInfoService {
  static final SupabaseClient _client = Supabase.instance.client;
  static const String _bucketName =
      'instructor-info'; 
  static const String _tableName = 'instructor_info';

  /// Upload CV file to Supabase storage
  static Future<String> uploadCVFile(
    String userId,
    File file,
    String fileName,
  ) async {
    try {
      print(
        '[DEBUG] uploadCVFile called for userId: '
        '[33m$userId[0m, fileName: [33m$fileName[0m',
      );
      // Generate unique file path: instructors/userId/timestamp_fileName
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = fileName.split('.').last;
      final uniqueFileName = '${timestamp}_cv.$fileExtension';
      final filePath =
          'instructors/$userId/$uniqueFileName'; // Fixed path structure

      // Upload file to storage (following course service pattern)
      print(
        '[DEBUG] Uploading file to Supabase storage at path: [33m$filePath[0m',
      );
      await _client.storage
          .from(_bucketName)
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));
      print('[DEBUG] File uploaded successfully to: [32m$filePath[0m');

      return filePath;
    } catch (e) {
      print('[ERROR] uploadCVFile failed: [31m$e[0m');
      throw Exception('Failed to upload CV file: $e');
    }
  }

  /// Upload CV file using bytes (for web compatibility)
  static Future<String> uploadCVFileFromBytes(
    String userId,
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      print(
        '[DEBUG] uploadCVFileFromBytes called for userId: '
        '[33m$userId[0m, fileName: [33m$fileName[0m, bytes length: [33m${fileBytes.length}[0m',
      );
      // Generate unique file path: instructors/userId/timestamp_fileName
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = fileName.split('.').last;
      final uniqueFileName = '${timestamp}_cv.$fileExtension';
      final filePath =
          'instructors/$userId/$uniqueFileName'; // Fixed path structure

      // Upload file bytes to storage (following course service pattern)
      print(
        '[DEBUG] Uploading file bytes to Supabase storage at path: [33m$filePath[0m',
      );
      await _client.storage
          .from(_bucketName)
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );
      print('[DEBUG] File bytes uploaded successfully to: [32m$filePath[0m');

      return filePath;
    } catch (e) {
      print('[ERROR] uploadCVFileFromBytes failed: [31m$e[0m');
      throw Exception('Failed to upload CV file from bytes: $e');
    }
  }

  /// Create new instructor info record
  static Future<InstructorInfo> createInstructorInfo(
    InstructorInfo instructorInfo,
  ) async {
    try {
      print(
        '[DEBUG] createInstructorInfo called for userId: [33m${instructorInfo.userId}[0m',
      );
      final response = await _client
          .from(_tableName)
          .insert(instructorInfo.toInsertJson())
          .select()
          .single();
      print('[DEBUG] Instructor info created: [32m$response[0m');

      return InstructorInfo.fromJson(response);
    } catch (e) {
      print('[ERROR] createInstructorInfo failed: [31m$e[0m');
      throw Exception('Failed to create instructor info: $e');
    }
  }

  /// Get instructor info by user ID
  static Future<InstructorInfo?> getInstructorInfoByUserId(
    String userId,
  ) async {
    try {
      print(
        '[DEBUG] getInstructorInfoByUserId called for userId: [33m$userId[0m',
      );
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      print('[DEBUG] getInstructorInfoByUserId response: [32m$response[0m');

      return response != null ? InstructorInfo.fromJson(response) : null;
    } catch (e) {
      print('[ERROR] getInstructorInfoByUserId failed: [31m$e[0m');
      throw Exception('Failed to get instructor info: $e');
    }
  }

  /// Update instructor info
  static Future<InstructorInfo> updateInstructorInfo(
    String instructorInfoId,
    InstructorInfo updatedInfo,
  ) async {
    try {
      print(
        '[DEBUG] updateInstructorInfo called for id: [33m$instructorInfoId[0m',
      );
      final response = await _client
          .from(_tableName)
          .update(updatedInfo.toInsertJson())
          .eq('id', instructorInfoId)
          .select()
          .single();
      print('[DEBUG] Instructor info updated: [32m$response[0m');

      return InstructorInfo.fromJson(response);
    } catch (e) {
      print('[ERROR] updateInstructorInfo failed: [31m$e[0m');
      throw Exception('Failed to update instructor info: $e');
    }
  }

  /// Update verification status (typically used by admin)
  static Future<InstructorInfo> updateVerificationStatus(
    String instructorInfoId,
    String status,
  ) async {
    try {
      print(
        '[DEBUG] updateVerificationStatus called for id: [33m$instructorInfoId[0m, status: [33m$status[0m',
      );
      final updates = {'verification_status': status};

      // Add verified_at timestamp if status is 'verified'
      if (status == 'verified') {
        updates['verified_at'] = DateTime.now().toIso8601String();
      }

      final response = await _client
          .from(_tableName)
          .update(updates)
          .eq('id', instructorInfoId)
          .select()
          .single();
      print('[DEBUG] Verification status updated: [32m$response[0m');

      return InstructorInfo.fromJson(response);
    } catch (e) {
      print('[ERROR] updateVerificationStatus failed: [31m$e[0m');
      throw Exception('Failed to update verification status: $e');
    }
  }

  /// Get all instructor info records (for admin use)
  static Future<List<InstructorInfo>> getAllInstructorInfo({
    String? verificationStatus,
    int? limit,
    int? offset,
  }) async {
    try {
      print(
        '[DEBUG] getAllInstructorInfo called, verificationStatus: [33m$verificationStatus[0m, limit: [33m$limit[0m, offset: [33m$offset[0m',
      );
      var query = _client.from(_tableName).select();

      // Apply filters first
      if (verificationStatus != null) {
        query = query.eq('verification_status', verificationStatus);
      }

      // Apply ordering and pagination
      var orderedQuery = query.order('submitted_at', ascending: false);

      if (limit != null) {
        orderedQuery = orderedQuery.limit(limit);
      }

      if (offset != null) {
        orderedQuery = orderedQuery.range(offset, offset + (limit ?? 50) - 1);
      }

      final response = await orderedQuery;
      print('[DEBUG] getAllInstructorInfo response: [32m$response[0m');

      return (response as List)
          .map((json) => InstructorInfo.fromJson(json))
          .toList();
    } catch (e) {
      print('[ERROR] getAllInstructorInfo failed: [31m$e[0m');
      throw Exception('Failed to get instructor info list: $e');
    }
  }

  /// Get CV file download URL
  static Future<String> getCVDownloadUrl(String filePath) async {
    try {
      print('[DEBUG] getCVDownloadUrl called for filePath: [33m$filePath[0m');
      return await _client.storage
          .from(_bucketName)
          .createSignedUrl(filePath, 3600); // 1 hour expiry
    } catch (e) {
      print('[ERROR] getCVDownloadUrl failed: [31m$e[0m');
      throw Exception('Failed to get CV download URL: $e');
    }
  }

  /// Delete CV file from storage
  static Future<void> deleteCVFile(String filePath) async {
    try {
      print('[DEBUG] deleteCVFile called for filePath: [33m$filePath[0m');
      await _client.storage.from(_bucketName).remove([filePath]);
      print('[DEBUG] CV file deleted: [32m$filePath[0m');
    } catch (e) {
      print('[ERROR] deleteCVFile failed: [31m$e[0m');
      throw Exception('Failed to delete CV file: $e');
    }
  }

  /// Submit instructor profile (creates new record with file upload)
  static Future<InstructorInfo> submitInstructorProfile({
    required String userId,
    required String phoneNumber,
    required String educationDegree,
    required int teachingExperience,
    String? currentLocation,
    required List<String> subjectExpertise,
    required String bio,
    File? cvFile,
    Uint8List? cvFileBytes,
    required String cvFileName,
  }) async {
    try {
      print(
        '[DEBUG] submitInstructorProfile called for userId: [33m$userId[0m, cvFileName: [33m$cvFileName[0m',
      );
      // 1. Upload CV file first
      String cvFilePath;
      if (kIsWeb && cvFileBytes != null) {
        print('[DEBUG] Web platform detected, uploading CV using bytes');
        // Web platform: upload using bytes
        cvFilePath = await uploadCVFileFromBytes(
          userId,
          cvFileBytes,
          cvFileName,
        );
      } else if (!kIsWeb && cvFile != null) {
        print(
          '[DEBUG] Mobile/Desktop platform detected, uploading CV using File object',
        );
        // Mobile platform: upload using File object
        cvFilePath = await uploadCVFile(userId, cvFile, cvFileName);
      } else {
        print('[ERROR] No CV file provided for profile submission');
        throw Exception('CV file is required for profile submission');
      }

      // 2. Create instructor info record
      print('[DEBUG] Creating instructor info record');
      final instructorInfo = InstructorInfo(
        userId: userId,
        phoneNumber: phoneNumber,
        educationDegree: educationDegree,
        teachingExperience: teachingExperience,
        currentLocation: currentLocation,
        subjectExpertise: subjectExpertise,
        bio: bio,
        cvFileName: cvFileName,
        cvFilePath: cvFilePath,
        verificationStatus: 'pending',
      );

      return await createInstructorInfo(instructorInfo);
    } catch (e) {
      print('[ERROR] submitInstructorProfile failed: [31m$e[0m');
      throw Exception('Failed to submit instructor profile: $e');
    }
  }

  /// Update instructor profile with new CV file (optional)
  static Future<InstructorInfo> updateInstructorProfile({
    required String instructorInfoId,
    required String userId,
    required String phoneNumber,
    required String educationDegree,
    required int teachingExperience,
    String? currentLocation,
    required List<String> subjectExpertise,
    required String bio,
    File? newCvFile,
    Uint8List? newCvFileBytes,
    String? newCvFileName,
    String? existingCvFilePath,
  }) async {
    try {
      print(
        '[DEBUG] updateInstructorProfile called for id: [33m$instructorInfoId[0m, userId: [33m$userId[0m',
      );
      String cvFilePath = existingCvFilePath ?? '';
      String cvFileName = newCvFileName ?? '';

      // Upload new CV file if provided
      if (newCvFileName != null) {
        print('[DEBUG] New CV file provided, deleting old file if exists');
        // Delete old file if exists
        if (existingCvFilePath != null && existingCvFilePath.isNotEmpty) {
          try {
            await deleteCVFile(existingCvFilePath);
          } catch (e) {
            // Continue even if deletion fails
            print('Warning: Failed to delete old CV file: $e');
          }
        }

        // Upload new file based on platform
        if (kIsWeb && newCvFileBytes != null) {
          print('[DEBUG] Web platform detected, uploading new CV using bytes');
          // Web platform: upload using bytes
          cvFilePath = await uploadCVFileFromBytes(
            userId,
            newCvFileBytes,
            newCvFileName,
          );
        } else if (!kIsWeb && newCvFile != null) {
          print(
            '[DEBUG] Mobile/Desktop platform detected, uploading new CV using File object',
          );
          // Mobile platform: upload using File object
          cvFilePath = await uploadCVFile(userId, newCvFile, newCvFileName);
        } else {
          print('[ERROR] No CV file provided for profile update');
          throw Exception('CV file is required for profile update');
        }
        cvFileName = newCvFileName;
      } else if (existingCvFilePath != null) {
        cvFilePath = existingCvFilePath;
        // Extract filename from path if not provided
        if (newCvFileName == null) {
          cvFileName = existingCvFilePath.split('/').last;
        }
      }

      // Update instructor info record
      print('[DEBUG] Updating instructor info record');
      final updatedInfo = InstructorInfo(
        userId: userId,
        phoneNumber: phoneNumber,
        educationDegree: educationDegree,
        teachingExperience: teachingExperience,
        currentLocation: currentLocation,
        subjectExpertise: subjectExpertise,
        bio: bio,
        cvFileName: cvFileName,
        cvFilePath: cvFilePath,
        verificationStatus: 'pending', // Reset to pending when updated
      );

      return await updateInstructorInfo(instructorInfoId, updatedInfo);
    } catch (e) {
      print('[ERROR] updateInstructorProfile failed: [31m$e[0m');
      throw Exception('Failed to update instructor profile: $e');
    }
  }

  /// Check if user has submitted instructor info
  static Future<bool> hasSubmittedProfile(String userId) async {
    try {
      print('[DEBUG] hasSubmittedProfile called for userId: [33m$userId[0m');
      final info = await getInstructorInfoByUserId(userId);
      print('[DEBUG] hasSubmittedProfile result: [32m${info != null}[0m');
      return info != null;
    } catch (e) {
      print('[ERROR] hasSubmittedProfile failed: [31m$e[0m');
      return false;
    }
  }

  /// Get instructor verification statistics (for admin dashboard)
  static Future<Map<String, int>> getVerificationStats() async {
    try {
      print('[DEBUG] getVerificationStats called');
      final response = await _client
          .from(_tableName)
          .select('verification_status');

      final stats = <String, int>{
        'pending': 0,
        'under_review': 0,
        'verified': 0,
        'rejected': 0,
      };

      for (final item in response) {
        final status = item['verification_status'] as String;
        stats[status] = (stats[status] ?? 0) + 1;
      }

      print('[DEBUG] getVerificationStats result: [32m$stats[0m');
      return stats;
    } catch (e) {
      print('[ERROR] getVerificationStats failed: [31m$e[0m');
      throw Exception('Failed to get verification stats: $e');
    }
  }
}
