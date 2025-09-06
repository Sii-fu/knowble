# Flutter Integration Examples

This file contains example code for integrating the YouTube API backend with your Flutter app.

## 📱 Flutter Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  file_picker: ^5.5.0
  url_launcher: ^6.2.1
  webview_flutter: ^4.4.2  # For OAuth flow
```

## 🔐 Authentication Flow

### 1. Start Authentication

```dart
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class YouTubeApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Start OAuth flow
  Future<void> authenticateWithGoogle() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/google?format=json'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final authUrl = data['authUrl'];
        
        // Open browser or webview for authentication
        if (await canLaunchUrl(Uri.parse(authUrl))) {
          await launchUrl(Uri.parse(authUrl));
        }
      }
    } catch (e) {
      print('Authentication error: $e');
    }
  }
  
  // Check authentication status
  Future<bool> isAuthenticated() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/status'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['authenticated'] == true;
      }
    } catch (e) {
      print('Status check error: $e');
    }
    return false;
  }
}
```

### 2. WebView Integration (Alternative)

```dart
import 'package:webview_flutter/webview_flutter.dart';

class YouTubeAuthWebView extends StatefulWidget {
  @override
  _YouTubeAuthWebViewState createState() => _YouTubeAuthWebViewState();
}

class _YouTubeAuthWebViewState extends State<YouTubeAuthWebView> {
  late WebViewController controller;
  
  @override
  void initState() {
    super.initState();
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Check if callback URL
            if (request.url.contains('/api/auth/google/callback')) {
              // Handle successful authentication
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('http://localhost:3000/api/auth/google'));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('YouTube Authentication')),
      body: WebViewWidget(controller: controller),
    );
  }
}
```

## 📹 Video Upload

### 1. File Selection and Upload

```dart
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class VideoUploadService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Pick video file
  Future<File?> pickVideoFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      print('File picker error: $e');
    }
    return null;
  }
  
  // Upload video to YouTube
  Future<Map<String, dynamic>?> uploadVideo({
    required File videoFile,
    required String title,
    String description = '',
    String tags = 'knowble,education',
    String privacy = 'private',
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/videos/upload'),
      );
      
      // Add video file
      request.files.add(
        await http.MultipartFile.fromPath(
          'video',
          videoFile.path,
        ),
      );
      
      // Add metadata
      request.fields.addAll({
        'title': title,
        'description': description,
        'tags': tags,
        'privacy': privacy,
      });
      
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
  
  // Get upload progress (if you implement progress tracking)
  Future<void> uploadVideoWithProgress({
    required File videoFile,
    required String title,
    Function(double)? onProgress,
  }) async {
    // Implementation would require stream handling for progress
    // This is a simplified version
    await uploadVideo(videoFile: videoFile, title: title);
  }
}
```

### 2. Complete Upload Widget

```dart
class VideoUploadWidget extends StatefulWidget {
  @override
  _VideoUploadWidgetState createState() => _VideoUploadWidgetState();
}

class _VideoUploadWidgetState extends State<VideoUploadWidget> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final VideoUploadService uploadService = VideoUploadService();
  final YouTubeApiService authService = YouTubeApiService();
  
  File? selectedVideo;
  bool isUploading = false;
  bool isAuthenticated = false;
  
  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }
  
  Future<void> checkAuthStatus() async {
    final authenticated = await authService.isAuthenticated();
    setState(() {
      isAuthenticated = authenticated;
    });
  }
  
  Future<void> selectVideo() async {
    final video = await uploadService.pickVideoFile();
    setState(() {
      selectedVideo = video;
    });
  }
  
  Future<void> authenticate() async {
    await authService.authenticateWithGoogle();
    // Wait for user to complete auth, then check status
    await Future.delayed(Duration(seconds: 2));
    await checkAuthStatus();
  }
  
  Future<void> uploadVideo() async {
    if (selectedVideo == null || titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select video and enter title')),
      );
      return;
    }
    
    setState(() {
      isUploading = true;
    });
    
    try {
      final result = await uploadService.uploadVideo(
        videoFile: selectedVideo!,
        title: titleController.text,
        description: descriptionController.text,
        privacy: 'private',
      );
      
      if (result != null && result['success'] == true) {
        final videoUrl = result['data']['videoUrl'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video uploaded successfully!'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                launchUrl(Uri.parse(videoUrl));
              },
            ),
          ),
        );
        
        // Reset form
        titleController.clear();
        descriptionController.clear();
        setState(() {
          selectedVideo = null;
        });
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
    
    setState(() {
      isUploading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload to YouTube'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Authentication Status
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          isAuthenticated ? Icons.check_circle : Icons.error,
                          color: isAuthenticated ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(
                          isAuthenticated 
                            ? 'Authenticated with YouTube' 
                            : 'Authentication required',
                        ),
                      ],
                    ),
                    if (!isAuthenticated) ...[
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: authenticate,
                        child: Text('Authenticate with Google'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Video Selection
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (selectedVideo == null)
                      ElevatedButton.icon(
                        onPressed: selectVideo,
                        icon: Icon(Icons.video_library),
                        label: Text('Select Video'),
                      )
                    else
                      Column(
                        children: [
                          Icon(Icons.video_file, size: 48, color: Colors.green),
                          SizedBox(height: 8),
                          Text(
                            'Video selected: ${selectedVideo!.path.split('/').last}',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          TextButton(
                            onPressed: selectVideo,
                            child: Text('Change Video'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Video Details
            if (isAuthenticated && selectedVideo != null) ...[
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Video Title *',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
              ),
              
              SizedBox(height: 16),
              
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              
              SizedBox(height: 16),
              
              ElevatedButton(
                onPressed: isUploading ? null : uploadVideo,
                child: isUploading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        ),
                        SizedBox(width: 8),
                        Text('Uploading...'),
                      ],
                    )
                  : Text('Upload to YouTube'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

## 🎯 Usage in Main App

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Knowble YouTube Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoUploadWidget(),
    );
  }
}
```

## 🔧 Configuration

### 1. Update Backend URL

For production, update the `baseUrl` in your services:

```dart
class Config {
  static const String isDevelopment = true;
  static const String developmentUrl = 'http://localhost:3000/api';
  static const String productionUrl = 'https://your-server.com/api';
  
  static String get baseUrl => isDevelopment ? developmentUrl : productionUrl;
}
```

### 2. Handle Network Errors

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
  
  @override
  String toString() => 'ApiException: $message';
}

Future<Map<String, dynamic>> makeApiCall(String endpoint) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        'HTTP ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  } on SocketException {
    throw ApiException('No internet connection');
  } on TimeoutException {
    throw ApiException('Request timeout');
  } catch (e) {
    throw ApiException('Unknown error: $e');
  }
}
```

## 📱 Platform-Specific Notes

### Android

Add internet permission in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS

Add network configuration in `ios/Runner/Info.plist` if needed for HTTP connections:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 🚀 Advanced Features

### 1. Upload Progress Tracking

```dart
// This would require implementing progress tracking on the backend
Stream<double> uploadWithProgress(File videoFile) async* {
  // Implementation would stream progress updates
  // For now, you can simulate progress
  for (int i = 0; i <= 100; i += 10) {
    await Future.delayed(Duration(milliseconds: 500));
    yield i / 100.0;
  }
}
```

### 2. Retry Logic

```dart
Future<T> withRetry<T>(Future<T> Function() operation, {int maxRetries = 3}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await operation();
    } catch (e) {
      if (attempt == maxRetries) rethrow;
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }
  throw Exception('Max retries exceeded');
}
```

This integration guide provides a complete foundation for connecting your Flutter app with the YouTube API backend!
