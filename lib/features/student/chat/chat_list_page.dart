import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_detail_page.dart';
import '../../../config/theme.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<dynamic>? _chats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not logged in');
      final response = await Supabase.instance.client.rpc('get_student_chats', params: {'student_uuid': userId});
      if (!mounted) return;
      setState(() {
        _chats = response as List<dynamic>?;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return timeago.format(dt, locale: 'en_short');
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          elevation: theme.appBarTheme.elevation,
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error', style: TextStyle(color: AppTheme.errorRed)))
                : (_chats == null || _chats!.isEmpty)
                    ? Center(child: Text('No messages yet', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        itemCount: _chats!.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final chat = _chats![index];
                          final courseId = chat['course_id'] as String?;
                          final instructorId = chat['instructor_id'] as String?;
                          final courseTitle = chat['course_title'] as String? ?? '';
                          final instructorName = chat['instructor_name'] as String? ?? '';
                          final profileImage = chat['instructor_profile_url'] as String?;
                          final lastMessage = chat['last_message'] as String? ?? '';
                          final lastTimestamp = chat['last_timestamp'] as String?;
                          final dt = lastTimestamp != null ? DateTime.tryParse(lastTimestamp) : null;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.accentLight,
                              backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                                  ? NetworkImage(profileImage)
                                  : null,
                              child: (profileImage == null || profileImage.isEmpty)
                                  ? Icon(Icons.person, color: AppTheme.primaryTeal)
                                  : null,
                            ),
                            title: Text(
                              instructorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryTeal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  courseTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                                ),
                                Text(
                                  lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            trailing: Text(
                              _formatTimestamp(dt),
                              style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.primaryTeal),
                            ),
                            onTap: () {
                              final user = Supabase.instance.client.auth.currentUser;
                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Session expired. Please log in again.')),
                                );
                                // Optionally, redirect to login page here
                                return;
                              }
                              if (courseId != null && instructorId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatDetailPage(
                                      courseId: courseId,
                                      receiverId: instructorId,
                                      instructorName: instructorName,
                                      courseCode: courseTitle,
                                      profileImage: profileImage,
                                    ),
                                  ),
                                );
                              }
                            },
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            tileColor: AppTheme.surfaceWhite,
                          );
                        },
                      ),
      ),
    );
  }
}
