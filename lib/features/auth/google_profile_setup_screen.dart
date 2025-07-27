import 'package:flutter/material.dart';
import 'package:knowble_app/config/theme.dart';
import 'package:knowble_app/core/services/google_auth_service.dart';
import 'package:knowble_app/core/services/auth_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleProfileSetupScreen extends StatefulWidget {
  final User googleUser;

  const GoogleProfileSetupScreen({super.key, required this.googleUser});

  @override
  State<GoogleProfileSetupScreen> createState() =>
      _GoogleProfileSetupScreenState();
}

class _GoogleProfileSetupScreenState extends State<GoogleProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  String? _selectedUserType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the name if available from Google
    _fullNameController.text =
        widget.googleUser.userMetadata?['full_name'] ??
        widget.googleUser.userMetadata?['name'] ??
        '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.05),

              // Header Section
              Center(
                child: Column(
                  children: [
                    // Logo or Icon
                    Container(
                      width: screenWidth * 0.2,
                      height: screenWidth * 0.2,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal,
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Icon(
                        Icons.person_add,
                        color: AppTheme.surfaceWhite,
                        size: screenWidth * 0.1,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    Text(
                      'Complete Your Profile',
                      style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Welcome to Knowble! Let\'s personalize your experience.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // User Info Display
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: AppTheme.primaryTeal,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google Account',
                            style: TextStyle(
                              fontFamily: 'Jost',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.googleUser.email ?? 'No email',
                            style: TextStyle(
                              fontFamily: 'Jost',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.verified, color: Colors.green, size: 20),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Form Section
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name Field
                    TextFormField(
                      controller: _fullNameController,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontFamily: 'Jost',
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        filled: true,
                        fillColor: AppTheme.surfaceWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryTeal),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // User Type Selection
                    Text(
                      'I am a...',
                      style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // User Type Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildUserTypeCard(
                            'Student',
                            Icons.school_outlined,
                            'Learn and explore courses',
                            _selectedUserType == 'Student',
                            () => setState(() => _selectedUserType = 'Student'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildUserTypeCard(
                            'Instructor',
                            Icons.person_outline,
                            'Create and teach courses',
                            _selectedUserType == 'Instructor',
                            () => setState(
                              () => _selectedUserType = 'Instructor',
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // Complete Profile Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleCompleteProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: AppTheme.surfaceWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(
                                color: AppTheme.surfaceWhite,
                                strokeWidth: 2,
                              )
                            : Text(
                                'Complete Profile',
                                style: TextStyle(
                                  fontFamily: 'Jost',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(
    String title,
    IconData icon,
    String description,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryTeal.withOpacity(0.1)
              : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryTeal : Colors.grey[600],
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Jost',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryTeal : AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Jost',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCompleteProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select whether you are a Student or Instructor',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user profile in database
      final success = await GoogleAuthService.createUserProfile(
        userId: widget.googleUser.id,
        email: widget.googleUser.email!,
        fullName: _fullNameController.text.trim(),
        role: _selectedUserType!,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate based on user type using AuthManager
          await AuthManager.handleInitialAuth(context, fromLogin: true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create profile. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
