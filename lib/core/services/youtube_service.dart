// youtube_service.dart
// Service class for YouTube API backend integration
// Handles authentication, video uploads, and communication with Node.js backend

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class YouTubeService {
  // Backend configuration - update this to match your deployment
  static const String _baseUrl = 'http://localhost:3000/api';
  
  // Singleton pattern for service
  static final YouTubeService _instance = YouTubeService._internal();
  factory YouTubeService() => _instance;
  YouTubeService._internal();

  // Authentication state
  bool _isAuthenticated = false;
  String? _lastAuthError;

  /// Check if user is authenticated with YouTube
  bool get isAuthenticated => _isAuthenticated;
  String? get lastAuthError => _lastAuthError;

  /// Since backend uses fixed Google account, no user authentication needed
  /// This method is kept for compatibility but always returns success
  Future<Map<String, dynamic>> initiateAuthentication() async {
    // With fixed account backend, no user auth needed
    return {
      'success': true,
      'message': 'Backend uses fixed Google account - no user authentication required',
      'skipAuth': true
    };
  }

  /// Check authentication status with backend
  /// Since the backend uses a fixed Google account, this checks if the backend auth is working
  Future<Map<String, dynamic>> checkAuthenticationStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/videos/test-auth'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isAuthenticated = data['success'] == true;
        _lastAuthError = null;
        
        return {
          'success': true,
          'authenticated': _isAuthenticated,
          'channel': data['channel'] ?? {},
          'message': data['message'] ?? 'Authentication successful',
        };
      } else {
        _isAuthenticated = false;
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'authenticated': false,
          'error': errorData['error'] ?? 'Authentication test failed',
          'message': errorData['message'] ?? 'Backend authentication not configured'
        };
      }
    } catch (e) {
      _isAuthenticated = false;
      _lastAuthError = e.toString();
      return {
        'success': false,
        'authenticated': false,
        'error': 'Network error: $e'
      };
    }
  }

  /// Upload video to YouTube via backend
  /// Returns video ID and URL on success
  Future<Map<String, dynamic>> uploadVideo({
    required Map<String, dynamic> videoFile,
    required String title,
    String description = '',
    String tags = 'knowble,education',
    String privacy = 'unlisted',
    Function(double)? onProgress,
  }) async {
    try {
      // Check authentication first
      final authStatus = await checkAuthenticationStatus();
      if (!authStatus['authenticated']) {
        return {
          'success': false,
          'error': 'Authentication required',
          'message': 'Please authenticate with Google first',
          'requiresAuth': true
        };
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/videos/upload'),
      );

      // Add video file
      if (kIsWeb && videoFile['bytes'] != null) {
        // Web: use bytes
        request.files.add(
          http.MultipartFile.fromBytes(
            'video',
            videoFile['bytes'] as Uint8List,
            filename: videoFile['name'] as String,
          ),
        );
      } else if (!kIsWeb && videoFile['path'] != null) {
        // Mobile/Desktop: use file path
        request.files.add(
          await http.MultipartFile.fromPath(
            'video',
            videoFile['path'] as String,
            filename: videoFile['name'] as String,
          ),
        );
      } else {
        return {
          'success': false,
          'error': 'Invalid video file',
          'message': 'Video file path or bytes not available'
        };
      }

      // Add metadata
      request.fields.addAll({
        'title': title,
        'description': description,
        'tags': tags,
        'privacy': privacy,
      });

      // Send request with progress tracking
      final streamedResponse = await request.send();
      
      // Track upload progress (basic implementation)
      if (onProgress != null) {
        // Note: HTTP package doesn't provide built-in progress tracking
        // This is a placeholder - for real progress, you'd need to use dio package
        onProgress(1.0); // Indicate completion when response received
      }

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          return {
            'success': true,
            'videoId': data['data']['videoId'],
            'videoUrl': data['data']['videoUrl'],
            'title': data['data']['title'],
            'publishedAt': data['data']['publishedAt'],
            'privacyStatus': data['data']['privacyStatus'],
            'thumbnails': data['data']['thumbnails'],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Upload failed',
            'message': data['message'] ?? 'Unknown error occurred'
          };
        }
      } else if (response.statusCode == 401) {
        _isAuthenticated = false;
        return {
          'success': false,
          'error': 'Authentication expired',
          'message': 'Please re-authenticate with Google',
          'requiresAuth': true
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Upload failed',
          'message': errorData['message'] ?? 'HTTP ${response.statusCode}',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Upload error: $e',
        'message': 'Network or file processing error occurred'
      };
    }
  }

  /// Get video details by ID
  Future<Map<String, dynamic>> getVideoDetails(String videoId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/videos/$videoId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'video': data['data']
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get video details'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e'
      };
    }
  }

  /// Get user's uploaded videos
  Future<Map<String, dynamic>> getUserVideos() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/videos'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'videos': data['data']['videos'],
          'channel': data['data']['channel']
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get videos'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e'
      };
    }
  }

  /// Logout and clear authentication
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      _isAuthenticated = false;
      _lastAuthError = null;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Logged out successfully'
        };
      } else {
        return {
          'success': false,
          'error': 'Logout failed'
        };
      }
    } catch (e) {
      // Even if network fails, clear local auth state
      return {
        'success': true,
        'message': 'Logged out locally (network error: $e)'
      };
    }
  }

  /// Test backend connectivity
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl.replaceAll('/api', '')}/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Backend connection successful',
          'serverInfo': data
        };
      } else {
        return {
          'success': false,
          'error': 'Backend server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Cannot connect to backend: $e',
        'details': 'Make sure the server is running on $_baseUrl'
      };
    }
  }
}
