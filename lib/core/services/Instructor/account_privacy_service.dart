import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPrivacyService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Change the current user's password.
  ///
  /// This method attempts to re-authenticate the user using their current
  /// password (to ensure the credential is valid), then updates the password
  /// to [newPassword]. Returns a map with { success: bool, message: String }.
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null || user.email == null) {
      return {'success': false, 'message': 'Not signed in.'};
    }

    try {
      // Re-authenticate by signing in with email + current password.
      final signInRes = await supabase.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      if (signInRes.session == null) {
        return {'success': false, 'message': 'Current password is incorrect.'};
      }

      // Update the user's password
      final updateRes = await supabase.auth.updateUser(UserAttributes(password: newPassword));
      if (updateRes.user == null) {
        return {'success': false, 'message': 'Failed to update password.'};
      }

      return {'success': true, 'message': 'Password updated successfully.'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Delete account data for the current user (best-effort from client).
  ///
  /// Note: The authenticated user record in Supabase Auth cannot be deleted
  /// from the client without a service role key. This method will attempt to
  /// call a server-side RPC named `delete_user_account` if available. If the
  /// RPC is not present or fails, it will try a best-effort delete of common
  /// user-owned rows (profiles, courses, enrollments). Finally it signs the
  /// user out. Returns { success: bool, message: String }.
  Future<Map<String, dynamic>> deleteAccount() async {
    final user = supabase.auth.currentUser;
    if (user == null) return {'success': false, 'message': 'Not signed in.'};

    try {
      // Prefer server-side RPC if available (recommended for full cleanup)
      try {
        final rpcRes = await supabase.rpc('delete_user_account', params: {'user_id': user.id});
        // If RPC executed without throwing, assume success when result is non-null
        if (rpcRes != null) {
          await supabase.auth.signOut();
          return {'success': true, 'message': 'Account deleted (server).'};
        }
      } catch (_) {
        // RPC not available or failed; fall back to client-side cleanup
      }

      // Best-effort cleanup: delete relational rows owned by the user
      // Profiles
      await supabase.from('profiles').delete().eq('id', user.id);
      // Courses where the user is the instructor
      await supabase.from('courses').delete().eq('instructor_id', user.id);
      // Enrollments by this user
      await supabase.from('enrollments').delete().eq('user_id', user.id);
      // Assessments created by the instructor (if applicable)
      await supabase.from('assessments').delete().eq('instructor_id', user.id);

      // Sign out the user locally. Deleting the Auth user itself requires a
      // server-side call with a service role key.
      await supabase.auth.signOut();

      return {
        'success': true,
        'message': 'Local account data deleted. To remove the Auth user completely, run a server-side delete or contact support.'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
