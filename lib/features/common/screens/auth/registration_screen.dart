import 'package:flutter/material.dart';
import 'package:knowble_app/config/theme.dart';
import 'package:knowble_app/widgets/registration_user_type_dropdown_widget.dart';
import 'package:knowble_app/widgets/google_signin_button_widget.dart';
import 'package:knowble_app/widgets/terms_checkbox_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  String? _selectedUserType;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 20), // Add bottom padding
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.08),

                    // Logo and Title Section
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: screenWidth * 0.2,
                            height: screenWidth * 0.2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.02,
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/logo 3.png',
                              width: screenWidth * 0.2,
                              height: screenWidth * 0.2,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: screenWidth * 0.2,
                                  height: screenWidth * 0.2,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryTeal,
                                    borderRadius: BorderRadius.circular(
                                      screenWidth * 0.02,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.school,
                                    color: AppTheme.surfaceWhite,
                                    size: screenWidth * 0.1,
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Text(
                            'Getting Started!',
                            style: const TextStyle(
                              fontFamily: 'Jost',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            'Create an account to continue',
                            style: const TextStyle(
                              fontFamily: 'Jost',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // Form Section
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontFamily: 'Jost',
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontFamily: 'Jost',
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontFamily: 'Jost',
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: screenWidth * 0.06,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontFamily: 'Jost',
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: screenWidth * 0.06,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // User Type Dropdown (No Admin option for registration)
                          RegistrationUserTypeDropdownWidget(
                            value: _selectedUserType,
                            onChanged: (value) {
                              setState(() {
                                _selectedUserType = value;
                              });
                            },
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // Terms Checkbox
                          TermsCheckboxWidget(
                            isChecked: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.07,
                            child: ElevatedButton(
                              onPressed: _handleSignUp,
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontFamily: 'Jost',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // Divider with "or"
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppTheme.borderSubtle,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03,
                                ),
                                child: const Text(
                                  'or',
                                  style: TextStyle(
                                    fontFamily: 'Jost',
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppTheme.borderSubtle,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // Google Sign In Button
                          GoogleSigninButtonWidget(
                            onPressed: _handleGoogleSignIn,
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Sign In Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an Account? ',
                                style: TextStyle(
                                  fontFamily: 'Jost',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                                child: const Text(
                                  'SIGN IN',
                                  style: TextStyle(
                                    fontFamily: 'Jost',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to the terms and conditions'),
          ),
        );
        return;
      }
      if (_selectedUserType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a user type')),
        );
        return;
      }

      try {
        // Step 1: Create user in Supabase Auth (auth.users)
        final authResponse = await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final authUserId = authResponse.user?.id;
        if (authUserId != null) {
          try {
            // Step 2: Insert user profile data into custom users table
            // The ID will be the same as the auth user ID for consistency
            await Supabase.instance.client.from('users').insert({
              'id': authUserId, // Use the same ID from auth.users
              'name': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'role': _selectedUserType
                  ?.toLowerCase(), // Convert to lowercase for database
              'profile_pic': '', // Empty for now
              'bio': '', // Empty for now
              'is_verified': false, // Default to false
              'created_at': DateTime.now().toIso8601String(),
            });

            print(
              '✅ User successfully created in both auth.users and users table',
            );
            print('   Auth ID: $authUserId');
            print('   Email: ${_emailController.text.trim()}');
            print('   Role: ${_selectedUserType?.toLowerCase()}');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _selectedUserType?.toLowerCase() == 'student'
                      ? 'Registration successful! Let\'s personalize your learning experience.'
                      : 'Registration successful! Please check your email to verify your account.',
                ),
                backgroundColor: Colors.green,
              ),
            );

            // Route based on user type
            if (_selectedUserType?.toLowerCase() == 'student') {
              Navigator.pushReplacementNamed(context, '/student-interest');
            } else {
              Navigator.pushReplacementNamed(context, '/login');
            }
          } catch (dbError) {
            // If users table insertion fails, we should clean up the auth user
            print('❌ Database insertion failed: $dbError');
            print('🧹 Attempting to clean up auth user...');

            try {
              // Clean up the auth user since we couldn't create the profile
              await Supabase.instance.client.auth.admin.deleteUser(authUserId);
              print('✅ Auth user cleaned up successfully');
            } catch (cleanupError) {
              print('❌ Failed to clean up auth user: $cleanupError');
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Registration failed: Could not create user profile. ${dbError.toString()}',
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
        } else {
          print('❌ Auth signup failed: No user ID returned');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (authError) {
        // Handle authentication errors
        print('❌ Auth signup error: $authError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${authError.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleGoogleSignIn() {
    // Handle Google sign in logic
    print('Google sign in');
  }
}
