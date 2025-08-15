import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme_instructor.dart';
import '../../core/services/instructor/profile.dart';
import 'instructor_settings_page.dart';

class InstructorProfilePage extends StatefulWidget {
  const InstructorProfilePage({super.key});

  @override
  State<InstructorProfilePage> createState() => _InstructorProfilePageState();
}

class _InstructorProfilePageState extends State<InstructorProfilePage> {
  final InstructorProfileService _profileService = InstructorProfileService();
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
      final response = await _profileService.fetchInstructorProfile();
      
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
        backgroundColor: AppThemeInstructor.surfaceWhite,
        title: Text(
          'Edit Name',
          style: AppThemeInstructor.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppThemeInstructor.textPrimary,
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
            color: AppThemeInstructor.textPrimary,
          ),
          autofocus: true,  
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppThemeInstructor.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeInstructor.primaryBlue,
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
        backgroundColor: AppThemeInstructor.surfaceWhite,
        title: Text(
          'Edit Bio',
          style: AppThemeInstructor.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppThemeInstructor.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: bioController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Bio',
            hintText: 'Tell us about your teaching experience...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          style: TextStyle(
            color: AppThemeInstructor.textPrimary,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppThemeInstructor.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, bioController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeInstructor.primaryBlue,
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

  Future<void> _editPhone() async {
    final TextEditingController phoneController = TextEditingController(
      text: _userProfile?['phone'] ?? '',
    );
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeInstructor.surfaceWhite,
        title: Text(
          'Edit Phone Number',
          style: AppThemeInstructor.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppThemeInstructor.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          style: TextStyle(
            color: AppThemeInstructor.textPrimary,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppThemeInstructor.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, phoneController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeInstructor.primaryBlue,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result != _userProfile?['phone']) {
      await _updateUserField('phone', result);
    }
  }

  Future<void> _editExperience() async {
    final TextEditingController experienceController = TextEditingController(
      text: _userProfile?['experience_years']?.toString() ?? '',
    );
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeInstructor.surfaceWhite,
        title: Text(
          'Edit Teaching Experience',
          style: AppThemeInstructor.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppThemeInstructor.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: experienceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Years of Experience',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          style: TextStyle(
            color: AppThemeInstructor.textPrimary,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppThemeInstructor.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, experienceController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeInstructor.primaryBlue,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final years = int.tryParse(result);
      if (years != null && years != _userProfile?['experience_years']) {
        await _updateUserField('experience_years', years);
      }
    }
  }

  Future<void> _editSpecialization() async {
    // Handle array conversion for display
    String currentSpecialization = '';
    if (_userProfile?['specialization'] is List) {
      currentSpecialization = (_userProfile!['specialization'] as List).join(', ');
    } else if (_userProfile?['specialization'] is String) {
      currentSpecialization = _userProfile!['specialization'];
    }
    
    final TextEditingController specializationController = TextEditingController(
      text: currentSpecialization,
    );
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeInstructor.surfaceWhite,
        title: Text(
          'Edit Specialization',
          style: AppThemeInstructor.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppThemeInstructor.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: specializationController,
          decoration: InputDecoration(
            labelText: 'Specialization',
            hintText: 'e.g., Computer Science, Mathematics, Design',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          style: TextStyle(
            color: AppThemeInstructor.textPrimary,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppThemeInstructor.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, specializationController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeInstructor.primaryBlue,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result != currentSpecialization) {
      await _updateUserField('specialization', result);
    }
  }

  Future<void> _editEducation() async {
    final TextEditingController educationController = TextEditingController(
      text: _userProfile?['education'] ?? '',
    );
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeInstructor.surfaceWhite,
        title: Text(
          'Edit Education',
          style: AppThemeInstructor.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppThemeInstructor.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: educationController,
          decoration: InputDecoration(
            labelText: 'Education Degree',
            hintText: 'e.g., Master of Computer Science',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          style: TextStyle(
            color: AppThemeInstructor.textPrimary,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppThemeInstructor.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, educationController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeInstructor.primaryBlue,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result != _userProfile?['education']) {
      await _updateUserField('education', result);
    }
  }

  Future<void> _editLocation() async {
    final TextEditingController locationController = TextEditingController(
      text: _userProfile?['location'] ?? '',
    );
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeInstructor.surfaceWhite,
        title: Text(
          'Edit Location',
          style: AppThemeInstructor.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppThemeInstructor.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: locationController,
          decoration: InputDecoration(
            labelText: 'Current Location',
            hintText: 'e.g., New York, USA',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          style: TextStyle(
            color: AppThemeInstructor.textPrimary,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppThemeInstructor.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, locationController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeInstructor.primaryBlue,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result != _userProfile?['location']) {
      await _updateUserField('location', result);
    }
  }

  Future<void> _updateUserField(String field, dynamic value) async {
    try {
      await _profileService.updateInstructorField(field, value);
      
      if (mounted) {
        setState(() {
          _userProfile![field] = value;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$field updated successfully'),
            backgroundColor: AppThemeInstructor.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update $field: $e'),
            backgroundColor: AppThemeInstructor.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _isLoading = true;
        });
        
        final imageUrl = await _profileService.uploadProfilePicture(image);
        
        if (mounted) {
          setState(() {
            _userProfile!['profile_picture_url'] = imageUrl;
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile picture updated successfully'),
              backgroundColor: AppThemeInstructor.successGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: AppThemeInstructor.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
  final theme = AppThemeInstructor.lightTheme;
    
    if (_isLoading) {
      return Theme(
        data: theme,
        child: Scaffold(
          backgroundColor: AppThemeInstructor.backgroundLight,
          body: Center(
            child: CircularProgressIndicator(
              color: AppThemeInstructor.primaryBlue,
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Theme(
        data: theme,
        child: Scaffold(
          backgroundColor: AppThemeInstructor.backgroundLight,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppThemeInstructor.errorRed,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchUserProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeInstructor.primaryBlue,
                  ),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppThemeInstructor.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: AppThemeInstructor.surfaceWhite,
          foregroundColor: AppThemeInstructor.textPrimary,
          elevation: 0.5,
          shadowColor: AppThemeInstructor.shadowLight,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: AppThemeInstructor.primaryBlue),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InstructorSettingsPage(),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: AppThemeInstructor.backgroundLight,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppThemeInstructor.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppThemeInstructor.borderSubtle,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemeInstructor.shadowLight.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppThemeInstructor.accentLight,
                            backgroundImage: _userProfile?['profile_picture_url'] != null
                                ? NetworkImage(_userProfile!['profile_picture_url'])
                                : null,
                            child: _userProfile?['profile_picture_url'] == null
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppThemeInstructor.primaryBlue,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppThemeInstructor.primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppThemeInstructor.surfaceWhite,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: AppThemeInstructor.surfaceWhite,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        _userProfile?['name'] ?? 'Instructor Name',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppThemeInstructor.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Specialization
                      Text(
                        _userProfile?['specialization'] != null
                            ? (_userProfile!['specialization'] is List
                                ? (_userProfile!['specialization'] as List).join(', ')
                                : _userProfile!['specialization'].toString())
                            : 'Add your specialization',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppThemeInstructor.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Bio
                      if (_userProfile?['bio'] != null && _userProfile!['bio'].toString().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppThemeInstructor.accentLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _userProfile!['bio'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppThemeInstructor.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Profile Information Card
                Container(
                  decoration: BoxDecoration(
                    color: AppThemeInstructor.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppThemeInstructor.borderSubtle,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemeInstructor.shadowLight.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Profile Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppThemeInstructor.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _buildInfoItem(
                        icon: Icons.person,
                        title: 'Full Name',
                        value: _userProfile?['name'] ?? 'Not set',
                        onEdit: _editName,
                      ),
                      _buildInfoItem(
                        icon: Icons.description,
                        title: 'Bio',
                        value: _userProfile?['bio'] ?? 'Add your bio',
                        onEdit: _editBio,
                      ),
                      _buildInfoItem(
                        icon: Icons.phone,
                        title: 'Phone Number',
                        value: _userProfile?['phone'] ?? 'Not set',
                        onEdit: _editPhone,
                      ),
                      _buildInfoItem(
                        icon: Icons.school,
                        title: 'Specialization',
                        value: _userProfile?['specialization'] != null
                            ? (_userProfile!['specialization'] is List
                                ? (_userProfile!['specialization'] as List).join(', ')
                                : _userProfile!['specialization'].toString())
                            : 'Not set',
                        onEdit: _editSpecialization,
                      ),
                      _buildInfoItem(
                        icon: Icons.work,
                        title: 'Experience',
                        value: _userProfile?['experience_years'] != null 
                            ? '${_userProfile!['experience_years']} years'
                            : 'Not set',
                        onEdit: _editExperience,
                      ),
                      _buildInfoItem(
                        icon: Icons.book,
                        title: 'Education',
                        value: _userProfile?['education'] ?? 'Not set',
                        onEdit: _editEducation,
                      ),
                      _buildInfoItem(
                        icon: Icons.location_on,
                        title: 'Location',
                        value: _userProfile?['location'] ?? 'Not set',
                        onEdit: _editLocation,
                      ),
                      _buildInfoItem(
                        icon: Icons.verified,
                        title: 'Verification Status',
                        value: _userProfile?['verification_status'] ?? 'Pending',
                        onEdit: null, // No editing for verification status
                      ),
                      _buildInfoItem(
                        icon: Icons.calendar_today,
                        title: 'Joined',
                        value: _formatDate(_userProfile?['created_at']),
                        onEdit: null, // No editing for created date
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _logout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeInstructor.errorRed,
                      foregroundColor: AppThemeInstructor.surfaceWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'LOG OUT',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppThemeInstructor.surfaceWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onEdit,
  }) {
    final theme = AppThemeInstructor.lightTheme;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppThemeInstructor.accentLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppThemeInstructor.primaryBlue,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppThemeInstructor.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: AppThemeInstructor.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: onEdit != null
          ? IconButton(
              icon: Icon(
                Icons.edit,
                color: AppThemeInstructor.primaryBlue,
                size: 20,
              ),
              onPressed: onEdit,
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
