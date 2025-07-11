import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'instructor',
      'text': 'Hello! How can I help you with CS101?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
    },
    {
      'sender': 'student',
      'text': 'Hi! I have a question about the assignment.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 9)),
    },
    {
      'sender': 'instructor',
      'text': 'Sure, go ahead!',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 8)),
    },
    {
      'sender': 'student',
      'text': 'Is it okay to submit a PDF instead of a Word doc?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 7)),
    },
    {
      'sender': 'instructor',
      'text': 'Yes, PDF is perfectly fine.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 6)),
    },
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'student',
        'text': text,
        'timestamp': DateTime.now(),
      });
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final instructorName = 'Dr. Alice Smith';
    final courseCode = 'CS101';
    final profileImage = null;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB39DDB),
        foregroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: profileImage != null ? NetworkImage(profileImage) : null,
              child: profileImage == null ? const Icon(Icons.person, color: Color(0xFF9575CD)) : null,
              backgroundColor: const Color(0xFFD1C4E9),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instructorName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  courseCode,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9575CD)),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF3EFFF),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['sender'] == 'student';
                return ChatBubble(
                  text: msg['text'],
                  isMe: isMe,
                  timestamp: msg['timestamp'],
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: const Color(0xFFF3EFFF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF7E57C2)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? const Color(0xFFD1C4E9) : Colors.white;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );
    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 40 : 8,
        right: isMe ? 8 : 40,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            timeago.format(timestamp),
            style: const TextStyle(fontSize: 11, color: Color(0xFF9575CD)),
          ),
        ],
      ),
    );
  }
}
