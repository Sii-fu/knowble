import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_detail_page.dart';
import '../../../config/theme_instructor.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  Map<String, List<dynamic>> _groupedChats = {};
  bool _loading = true;
  String? _error;
  String _search = '';

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
      final chats = response as List<dynamic>?;
      final Map<String, List<dynamic>> grouped = {};
      if (chats != null) {
        for (final chat in chats) {
          final courseTitle = chat['course_title'] as String? ?? 'Unknown Course';
          grouped.putIfAbsent(courseTitle, () => []); 
          grouped[courseTitle]!.add(chat);
        }
      }
      setState(() { _groupedChats = grouped; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
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
    final theme = AppThemeInstructor.lightTheme;
    final filtered = _search.isEmpty
        ? _groupedChats
        : _groupedChats.map((k, v) => MapEntry(k, v.where((c) {
              final name = (c['instructor_name'] ?? '').toString().toLowerCase();
              final lastMsg = (c['last_message'] ?? '').toString().toLowerCase();
              return name.contains(_search.toLowerCase()) || lastMsg.contains(_search.toLowerCase());
            }).toList()))
          ..removeWhere((key, value) => value.isEmpty);

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: AppThemeInstructor.backgroundLight,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppThemeInstructor.surfaceWhite,
          titleSpacing: 20,
          title: const Text('Chats'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchChats,
              tooltip: 'Refresh',
            ),
            const SizedBox(width: 4)
          ],
        ),
        body: Column(
          children: [
            // Search + Stats Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, size: 20),
                      hintText: 'Search instructor or message',
                      filled: true,
                      fillColor: AppThemeInstructor.surfaceWhite,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppThemeInstructor.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppThemeInstructor.borderSubtle),
                      ),
                    ),
                    onChanged: (v){ setState(()=> _search = v); },
                  ),
                  ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('Error: $_error', style: TextStyle(color: AppThemeInstructor.errorRed)))
                      : filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No messages yet',
                                style: theme.textTheme.bodyMedium?.copyWith(color: AppThemeInstructor.textSecondary),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: filtered.keys.length,
                              itemBuilder: (context, courseIndex) {
                                final courseTitle = filtered.keys.elementAt(courseIndex);
                                final courseChats = filtered[courseTitle]!;
                                return _courseSection(courseTitle, courseChats);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseSection(String courseTitle, List<dynamic> courseChats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemeInstructor.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school, size: 18, color: AppThemeInstructor.primaryBlue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  courseTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemeInstructor.accentLight,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '${courseChats.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...courseChats.map((chat) => _chatTile(chat)).toList(),
      ],
    );
  }

  Widget _chatTile(dynamic chat) {
    final courseId = chat['course_id'] as String?;
    final instructorId = chat['instructor_id'] as String?;
    final instructorName = chat['instructor_name'] as String? ?? '';
    final profileImage = chat['instructor_profile_url'] as String?;
    final lastMessage = chat['last_message'] as String? ?? '';
    final lastTimestamp = chat['last_timestamp'] as String?;
    final dt = lastTimestamp != null ? DateTime.tryParse(lastTimestamp) : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppThemeInstructor.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeInstructor.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppThemeInstructor.shadowLight.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
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
                  courseCode: chat['course_title'] ?? '',
                  profileImage: profileImage,
                ),
              ),
            );
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppThemeInstructor.accentLight,
              backgroundImage: (profileImage != null && profileImage.isNotEmpty) ? NetworkImage(profileImage) : null,
              child: (profileImage == null || profileImage.isEmpty)
                  ? const Icon(Icons.person, color: AppThemeInstructor.primaryBlue)
                  : null,
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppThemeInstructor.successGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppThemeInstructor.surfaceWhite, width: 1.5),
                ),
              ),
            )
          ],
        ),
        title: Text(
          instructorName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppThemeInstructor.textSecondary, fontSize: 13),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTimestamp(dt),
              style: TextStyle(color: AppThemeInstructor.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            // Placeholder for unread badge (if implementing later)
          ],
        ),
      ),
    );
  }

  Widget _quickStat(String value, String label, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color ?? AppThemeInstructor.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppThemeInstructor.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
