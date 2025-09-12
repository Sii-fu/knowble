import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationInstructorService {
	final supabase = Supabase.instance.client;

	/// Fetch notifications for the current logged-in user (instructor).
	Future<List<Map<String, dynamic>>> fetchNotifications({int? limit}) async {
		try {
			final user = supabase.auth.currentUser;
			if (user == null) return [];
			dynamic q = supabase.from('notification').select('*').eq('user_id', user.id).order('created_at', ascending: false);
			if (limit != null) q = q.limit(limit);
			final resp = await q;
			return List.from(resp as List? ?? []).cast<Map<String, dynamic>>();
		} catch (e) {
			print('fetchNotifications error: $e');
			return [];
		}
	}

	/// Given a notification id, resolve to the most likely course review by:
	/// - reading notification.navigate (expected to contain course_id)
	/// - finding reviews in course_reviews with matching course_id
	/// - picking the review whose created_at is closest to the notification.created_at
	/// Returns null if no matching review found.
	/// Resolve a notification to the matching course review by strict equality:
	/// - Ensure the notification belongs to the currently logged-in user
	/// - Treat `notification.navigate` as the string form of `course_id`
	/// - Query `course_reviews` WHERE course_id = navigate and return the latest review (by created_at)
	/// - Also return the notification row, student and course rows
	Future<Map<String, dynamic>?> resolveNotificationToClosestReview(dynamic notificationId) async {
		try {
			// notification.id column is bigint in DB; accept String or int from caller
			dynamic qId = notificationId;
			if (notificationId is String) {
				// try to parse to int, fallback to original string if parsing fails
				final parsed = int.tryParse(notificationId);
				if (parsed != null) qId = parsed;
			}
			final user = supabase.auth.currentUser;
			if (user == null) return null;

			// Fetch the notification and ensure it belongs to current user
			final n = await supabase
				.from('notification')
				.select('id, user_id, navigate, created_at')
				.eq('id', qId)
				.maybeSingle();
			if (n == null) return null;
			if ((n['user_id'] as String?)?.toLowerCase() != user.id.toLowerCase()) return null;

			final navigate = (n['navigate'] as String?)?.trim() ?? '';
			if (navigate.isEmpty) return null;

			// Strict match: notification.navigate (text) == course_reviews.course_id (uuid stored as text)
			final reviewsResp = await supabase
				.from('course_reviews')
				.select('id, course_id, student_id, rating, review_text, created_at, is_visible')
				.eq('course_id', navigate)
				.order('created_at', ascending: false)
				.limit(1);

			final reviews = List.from(reviewsResp as List? ?? []).cast<Map<String, dynamic>>();
			if (reviews.isEmpty) return null;

			final chosen = reviews.first;

			// select all columns to avoid errors if schema differs (eg. full_name vs name)
			final student = await supabase.from('users').select('*').eq('id', chosen['student_id']).maybeSingle();
			final course = await supabase.from('courses').select('*').eq('id', chosen['course_id']).maybeSingle();

			return {
				'notification': n,
				'review': chosen,
				'student': student,
				'course': course,
			};
		} catch (e) {
			print('resolveNotificationToClosestReview error: $e');
			return null;
		}
	}


}

