import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  static final _supabase = Supabase.instance.client;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // For Android: OAuth client ID is configured in build.gradle
    // For Web: clientId would be specified here
  );

  /// Signs in with Google and creates/updates user in Supabase
  static Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      print('🚀 Starting Google Sign-In process...');

      // Step 1: Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ Google Sign-In cancelled by user');
        return GoogleSignInResult(
          success: false,
          message: 'Sign-in cancelled by user',
        );
      }

      print('✅ Google account selected: ${googleUser.email}');

      // Step 2: Get Google authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('❌ Failed to get Google authentication tokens');
        return GoogleSignInResult(
          success: false,
          message: 'Failed to get authentication tokens',
        );
      }

      print('✅ Google authentication tokens obtained');

      // Step 3: Sign in to Supabase with Google tokens
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      if (response.user == null) {
        print('❌ Failed to sign in to Supabase with Google');
        return GoogleSignInResult(
          success: false,
          message: 'Failed to authenticate with our servers',
        );
      }

      print('✅ Supabase authentication successful');
      final user = response.user!;

      // Step 4: Check if user exists in our users table
      final existingUser = await _supabase
          .from('users')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (existingUser == null) {
        print('📝 New user detected, needs profile completion');
        // User doesn't exist in our users table - they need to complete their profile
        return GoogleSignInResult(
          success: true,
          isNewUser: true,
          user: user,
          message: 'Please complete your profile setup',
        );
      } else {
        print('👤 Existing user found, logging in');
        // User exists, they can proceed to dashboard
        return GoogleSignInResult(
          success: true,
          isNewUser: false,
          user: user,
          userRole: existingUser['role'],
          message: 'Welcome back!',
        );
      }
    } catch (e) {
      print('❌ Error during Google Sign-In: $e');
      return GoogleSignInResult(
        success: false,
        message: 'An error occurred during sign-in: ${e.toString()}',
      );
    }
  }

  /// Creates a user profile in our database after Google auth
  static Future<bool> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String role,
  }) async {
    try {
      print('📝 Creating user profile in database...');

      await _supabase.from('users').insert({
        'id': userId,
        'name': fullName,
        'email': email,
        'role': role.toLowerCase(),
        'profile_pic': '',
        'bio': '',
        'is_verified': true, // Google users are automatically verified
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ User profile created successfully');
      return true;
    } catch (e) {
      print('❌ Error creating user profile: $e');
      return false;
    }
  }

  /// Signs out from both Google and Supabase
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
      print('✅ Signed out from both Google and Supabase');
    } catch (e) {
      print('❌ Error during sign out: $e');
    }
  }

  /// Checks if user is currently signed in with Google
  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Gets the currently signed-in Google user
  static GoogleSignInAccount? get currentGoogleUser =>
      _googleSignIn.currentUser;
}

/// Result class for Google Sign-In operations
class GoogleSignInResult {
  final bool success;
  final bool isNewUser;
  final User? user;
  final String? userRole;
  final String message;

  GoogleSignInResult({
    required this.success,
    this.isNewUser = false,
    this.user,
    this.userRole,
    required this.message,
  });
}
