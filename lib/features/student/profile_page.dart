import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../core/services/student/profile.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final StudentProfileService _profileService = StudentProfileService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _profileService.fetchStudentProfile();
      
      if (!mounted) return;
      
      if (response != null) {
        setState(() {
          _userProfile = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No profile data found';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load profile data';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not specified';
    try {
      final date = DateTime.parse(dateString);
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  // Edit functionality methods
  Future<void> _editName() async {
    final TextEditingController nameController = TextEditingController(
      text: _userProfile?['name'] ?? '',
      
    );
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: Text(
          'Edit Name',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          style: TextStyle(
            color: AppTheme.textPrimary, // Change this to your desired color
          ),
          autofocus: true,  
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != _userProfile?['name']) {
      await _updateUserField('name', result);
    }
  }

  Future<void> _editBio() async {
    final TextEditingController bioController = TextEditingController(
      text: _userProfile?['bio'] ?? '',
    );
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: Text(
          'Edit Bio',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: bioController,
          decoration: InputDecoration(
            labelText: 'About Me',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Tell us about yourself...',
          ),
          style: TextStyle(
            color: AppTheme.textPrimary,
          ),
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, bioController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result != _userProfile?['bio']) {
      await _updateUserField('bio', result);
    }
  }

  Future<void> _editProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: Text(
          'Update Profile Picture',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppTheme.primaryTeal),
              title: Text(
                'Take Photo',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppTheme.primaryTeal),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            if (_userProfile?['profile_pic'] != null)
              ListTile(
                leading: Icon(Icons.delete, color: AppTheme.errorRed),
                title: Text(
                  'Remove Picture',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );

    if (result != null) {
      if (result == 'remove') {
        await _updateUserField('profile_pic', null);
      } else {
        final ImageSource source = result == 'camera' 
            ? ImageSource.camera 
            : ImageSource.gallery;
        
        try {
          final XFile? image = await picker.pickImage(
            source: source,
            maxWidth: 512,
            maxHeight: 512,
            imageQuality: 80,
          );
          
          if (image != null) {
            await _uploadProfilePicture(image);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error picking image: $e')),
            );
          }
        }
      }
    }
  }

  Future<void> _uploadProfilePicture(XFile imageFile) async {
    if (!mounted) return;
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      final fileName = 'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload using service
      final imageUrl = await _profileService.uploadProfilePicture(bytes, fileName);
      
      // Update profile in database using service
      await _profileService.updateUserField('profile_pic', imageUrl);
      
      // Refresh profile data
      await _fetchUserProfile();
      
      if (mounted) Navigator.pop(context); // Close loading dialog
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
  }

  Future<void> _updateUserField(String field, dynamic value) async {
    if (!mounted) return;
    
    try {
      await _profileService.updateUserField(field, value);

      // Refresh profile data
      await _fetchUserProfile();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${field.replaceFirst(field[0], field[0].toUpperCase())} updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating $field: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'My Account',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: AppTheme.surfaceWhite,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0.5,
          shadowColor: AppTheme.shadowLight,
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: AppTheme.primaryTeal),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              tooltip: 'Settings',
            ),
            IconButton(
              icon: Icon(Icons.logout, color: AppTheme.errorRed),
              onPressed: () => _logout(context),
              tooltip: 'Log Out',
            ),
          ],
        ),
        backgroundColor: AppTheme.backgroundLight,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.errorRed,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchUserProfile,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: AppTheme.accentLight,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primaryTeal,
                                    width: 2,
                                  ),
                                ),
                                child: _userProfile?['profile_pic'] != null
                                    ? ClipOval(
                                        child: Image.network(
                                          _userProfile!['profile_pic'],
                                          width: 96,
                                          height: 96,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              size: 32,
                                              color: AppTheme.primaryTeal,
                                            );
                                          },
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                                strokeWidth: 2,
                                                color: AppTheme.primaryTeal,
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 32,
                                        color: AppTheme.primaryTeal,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _editProfilePicture,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryTeal,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.surfaceWhite,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: AppTheme.surfaceWhite,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _userProfile?['name'] ?? 'Unknown User',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _editName,
                              child: Icon(
                                Icons.edit,
                                size: 20,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          Supabase.instance.client.auth.currentUser?.email ?? 'No email',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildInfoCard("Personal Details", {
                          "Full name": _userProfile?['name'] ?? 'Not specified',
                          // "Date of Birth": _formatDate(_userProfile?['date_of_birth']),
                          // "Gender": _userProfile?['gender'] ?? 'Not specified',
                          // "Nationality": _userProfile?['nationality'] ?? 'Not specified',
                          // "Address": _userProfile?['address'] ?? 'Not specified',
                          // "Phone Number": _userProfile?['phone_number'] ?? 'Not specified',
                          "Email": Supabase.instance.client.auth.currentUser?.email ?? 'No email',
                        }),

                        const SizedBox(height: 16),

                        _buildBioCard(),

                        const SizedBox(height: 16),

                        _buildInfoCard("Account Details", {
                          "Display Name": _userProfile?['username'] ?? 'Not set',
                          "Account Created": _formatDate(_userProfile?['created_at']),
                          // "Last Login": _formatDate(_userProfile?['updated_at']),
                          // "Membership Status": _formatMembershipStatus(_userProfile?['role']),
                          "Account Verification": _userProfile?['email_verified'] == true ? "✅ Verified" : "❌ Not Verified",
                          "Language Preference": _userProfile?['language'] ?? 'English',
                        }),

                        const SizedBox(height: 24),

                        // Log out button at the bottom
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _logout(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorRed,
                              foregroundColor: AppTheme.surfaceWhite,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              'Log Out',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.surfaceWhite,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildInfoCard(String title, Map<String, String> infoMap) {
    final theme = AppTheme.lightTheme;
    return Card(
      color: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      elevation: 2,
      shadowColor: AppTheme.shadowLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...infoMap.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        entry.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBioCard() {
    final theme = AppTheme.lightTheme;
    final bio = _userProfile?['bio'] ?? '';
    
    return Card(
      color: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      elevation: 2,
      shadowColor: AppTheme.shadowLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: AppTheme.primaryTeal,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'About Me',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _editBio,
                  child: Icon(
                    Icons.edit,
                    size: 18,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.borderSubtle,
                  width: 1,
                ),
              ),
              child: Text(
                bio.isEmpty 
                    ? 'No bio available. Tell us about yourself!' 
                    : bio,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: bio.isEmpty 
                      ? AppTheme.textSecondary 
                      : AppTheme.textPrimary,
                  fontStyle: bio.isEmpty 
                      ? FontStyle.italic 
                      : FontStyle.normal,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
