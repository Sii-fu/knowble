import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/theme.dart';

class ChatDetailPage extends StatefulWidget {
  final String courseId;
  final String receiverId;
  final String instructorName;
  final String courseCode;
  final String? profileImage;

  const ChatDetailPage({
    super.key,
    required this.courseId,
    required this.receiverId,
    required this.instructorName,
    required this.courseCode,
    this.profileImage,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  RealtimeChannel? _realtimeChannel;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _initChat() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    _currentUserId = userId;
    await _loadMessages();
    _subscribeToRealtime();
  }

  Future<void> _loadMessages() async {
    final userId = _currentUserId;
    if (userId == null) return;
    final data = await Supabase.instance.client
        .from('chats')
        .select()
        .eq('course_id', widget.courseId)
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('timestamp', ascending: true);
    setState(() {
      _messages = List<Map<String, dynamic>>.from(data);
    });
    _scrollToBottom();
  }

  void _subscribeToRealtime() {
    final userId = _currentUserId;
    if (userId == null) return;
    _realtimeChannel = Supabase.instance.client.channel('public:chats')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'chats',
        callback: (payload) {
          final newMsg = payload.newRecord;
          if (newMsg['course_id'] == widget.courseId &&
              (newMsg['sender_id'] == userId || newMsg['receiver_id'] == userId)) {
            setState(() {
              _messages.add(Map<String, dynamic>.from(newMsg));
            });
            _scrollToBottom();
          }
        },
      )
      ..subscribe();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending || _currentUserId == null) return;
    setState(() { _sending = true; });
    try {
      
      await Supabase.instance.client.from('chats').insert({
        'course_id': widget.courseId,
        'sender_id': _currentUserId,
        'receiver_id': widget.receiverId,
        'message': text,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _loadMessages(); // reload messages
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: ${e.toString()}')),
      );
    } finally {
      setState(() { _sending = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          elevation: theme.appBarTheme.elevation,
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: widget.profileImage != null ? NetworkImage(widget.profileImage!) : null,
                backgroundColor: AppTheme.accentLight,
                child: widget.profileImage == null ? Icon(Icons.person, color: AppTheme.primaryTeal) : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.instructorName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.courseCode,
                    style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.primaryTeal),
                  ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg['sender_id'] == _currentUserId;
                  final senderName = isMe ? 'You' : widget.instructorName;
                  final initials = senderName.isNotEmpty ? senderName.trim().split(' ').map((e) => e[0]).take(2).join() : '';
                  final dt = DateTime.tryParse(msg['timestamp'] ?? '') ?? DateTime.now();
                  return Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isMe)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppTheme.accentLight,
                            child: Text(initials, style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.primaryTeal)),
                          ),
                        ),
                      Flexible(
                        child: ChatBubble(
                          text: msg['message'] ?? '',
                          isMe: isMe,
                          timestamp: dt,
                          sender: senderName,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              color: AppTheme.surfaceWhite,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !_sending,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: AppTheme.accentLight,
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
                    _sending
                        ? const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: AppTheme.primaryTeal),
                            onPressed: _sendMessage,
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String? sender;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.sender,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? AppTheme.accentLight : AppTheme.surfaceWhite;
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
                  color: AppTheme.shadowLight,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: align,
              children: [
                if (!isMe && sender != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(sender!, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primaryTeal)),
                  ),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            timeago.format(timestamp),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primaryTeal),
          ),
        ],
      ),
    );
  }
}
