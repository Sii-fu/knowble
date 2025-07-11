import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'chat_detail_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      {
        'instructorName': 'Dr. Alice Smith',
        'courseCode': 'CS101',
        'lastMessage': 'Please review the assignment details and let me know if you have questions.',
        'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 2)),
        'profileImage': null,
      },
      {
        'instructorName': 'Prof. John Doe',
        'courseCode': 'MATH202',
        'lastMessage': 'Great job on the quiz! See you in class tomorrow.',
        'lastMessageTime': DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
        'profileImage': null,
      },
      {
        'instructorName': 'Ms. Emily Lee',
        'courseCode': 'ENG303',
        'lastMessage': 'Don’t forget to submit your essay by Friday.',
        'lastMessageTime': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        'profileImage': null,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: const Color(0xFFB39DDB), // Light purple
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF3EFFF), // Very light purple background
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        itemCount: chats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ChatCard(
            instructorName: chat['instructorName'] as String,
            courseCode: chat['courseCode'] as String,
            lastMessage: chat['lastMessage'] as String,
            lastMessageTime: chat['lastMessageTime'] as DateTime,
            profileImage: chat['profileImage'] as String?,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatDetailPage()),
              );
            },
          );
        },
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  final String instructorName;
  final String courseCode;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? profileImage;
  final VoidCallback onTap;

  const ChatCard({
    super.key,
    required this.instructorName,
    required this.courseCode,
    required this.lastMessage,
    required this.lastMessageTime,
    this.profileImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Card(
        elevation: 3,
        color: const Color(0xFFEDE7F6), // Light purple card background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: profileImage != null
                    ? NetworkImage(profileImage!)
                    : null,
                child: profileImage == null
                    ? const Icon(Icons.person, size: 28, color: Color(0xFF9575CD))
                    : null,
                backgroundColor: const Color(0xFFD1C4E9), // Lighter purple for avatar bg
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            instructorName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF512DA8), // Deep purple text
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1C4E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            courseCode,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF512DA8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lastMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5E35B1), // Medium purple
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                timeago.format(lastMessageTime),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF9575CD), // Light purple
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
