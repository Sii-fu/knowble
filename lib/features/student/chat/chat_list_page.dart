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
      print('================== $userId');
      print('================== $response');
      
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
          title: Text(
            'Messages',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: false,
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _fetchChats,
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh, color: AppTheme.primaryTeal),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: AppTheme.errorRed, size: 40),
                        const SizedBox(height: 8),
                        Text('Error: $_error', style: TextStyle(color: AppTheme.errorRed)),
                        const SizedBox(height: 8),
                        OutlinedButton(onPressed: _fetchChats, child: const Text('Retry')),
                      ],
                    ),
                  )
                : (_chats == null || _chats!.isEmpty)
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline, color: AppTheme.textSecondary, size: 48),
                            const SizedBox(height: 8),
                            Text('No messages yet', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppTheme.primaryTeal,
                        onRefresh: _fetchChats,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          itemCount: _chats!.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final chat = _chats![index] as Map<String, dynamic>;

                            final courseId = chat['course_id'] as String?;
                            final instructorId = chat['instructor_id'] as String?;
                            final courseTitle = chat['course_title'] as String? ?? '';
                            final instructorName = chat['instructor_name'] as String? ?? '';
                            final profileImage = chat['instructor_profile_url'] as String?;
                            final lastMessage = chat['last_message'] as String? ?? '';
                            final lastTimestamp = chat['last_timestamp'] as String?;
                            final dt = lastTimestamp != null ? DateTime.tryParse(lastTimestamp) : null;

                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
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
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.borderSubtle, width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.shadowLight,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: AppTheme.accentLight,
                                      backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                                          ? NetworkImage(profileImage)
                                          : null,
                                      child: (profileImage == null || profileImage.isEmpty)
                                          ? Icon(Icons.person, color: AppTheme.primaryTeal)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  instructorName,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    color: AppTheme.textPrimary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatTimestamp(dt),
                                                style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            courseTitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            lastMessage,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
