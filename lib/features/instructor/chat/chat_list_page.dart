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
  Map<String, List<dynamic>> _groupedChats = {};
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
      
      // Group chats by course title
      final chats = response as List<dynamic>?;
      final Map<String, List<dynamic>> grouped = {};
      
      if (chats != null) {
        for (final chat in chats) {
          final courseTitle = chat['course_title'] as String? ?? 'Unknown Course';
          if (!grouped.containsKey(courseTitle)) {
            grouped[courseTitle] = [];
          }
          grouped[courseTitle]!.add(chat);
        }
      }
      
      setState(() {
        _groupedChats = grouped;
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
          backgroundColor: AppTheme.instructorPrimary,
          foregroundColor: AppTheme.surfaceWhite,
          elevation: 0,
        ),
        backgroundColor: AppTheme.instructorbg,
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.instructorPrimary))
            : _error != null
                ? Center(child: Text('Error: $_error', style: TextStyle(color: AppTheme.errorRed)))
                : _groupedChats.isEmpty
                    ? Center(child: Text('No messages yet', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        itemCount: _groupedChats.keys.length,
                        itemBuilder: (context, courseIndex) {
                          final courseTitle = _groupedChats.keys.elementAt(courseIndex);
                          final courseChats = _groupedChats[courseTitle]!;
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Course Header
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.instructorPrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.school, color: AppTheme.surfaceWhite, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        courseTitle,
                                        style: const TextStyle(
                                          color: AppTheme.surfaceWhite,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceWhite.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${courseChats.length}',
                                        style: const TextStyle(
                                          color: AppTheme.surfaceWhite,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Chats for this course
                              ...courseChats.asMap().entries.map((entry) {
                                final chat = entry.value;
                                final courseId = chat['course_id'] as String?;
                                final instructorId = chat['instructor_id'] as String?;
                                final instructorName = chat['instructor_name'] as String? ?? '';
                                final profileImage = chat['instructor_profile_url'] as String?;
                                final lastMessage = chat['last_message'] as String? ?? '';
                                final lastTimestamp = chat['last_timestamp'] as String?;
                                final dt = lastTimestamp != null ? DateTime.tryParse(lastTimestamp) : null;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppTheme.instructorAccent,
                                      backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                                          ? NetworkImage(profileImage)
                                          : null,
                                      child: (profileImage == null || profileImage.isEmpty)
                                          ? Icon(Icons.person, color: AppTheme.instructorPrimary)
                                          : null,
                                    ),
                                    title: Text(
                                      instructorName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: AppTheme.instructorPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text(
                                      lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    trailing: Text(
                                      _formatTimestamp(dt),
                                      style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.instructorPrimary),
                                    ),
                                    onTap: () {
                                      final user = Supabase.instance.client.auth.currentUser;
                                      if (user == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Session expired. Please log in again.')),
                                        );
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
                                  ),
                                );
                              }),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
      ),
    );
  }
}
  