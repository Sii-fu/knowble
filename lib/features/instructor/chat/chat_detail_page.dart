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
  final FocusNode _textFieldFocus = FocusNode();
  bool _sending = false;
  RealtimeChannel? _realtimeChannel;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initChat();
    
    // Listen for focus changes to handle keyboard appearance
    _textFieldFocus.addListener(() {
      if (_textFieldFocus.hasFocus) {
        // When keyboard appears, scroll to bottom after a short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToBottom();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _textFieldFocus.dispose();
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
    _scrollToBottom(animate: false); // Instant scroll when loading messages
  }

  void _subscribeToRealtime() {
  final userId = _currentUserId;
  if (userId == null) return;

  _realtimeChannel = Supabase.instance.client
      .channel('realtime:public:chats') // ✅ Fix this line!
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'chats',
        callback: (payload) {
          final newMsg = payload.newRecord;

          // print("📡 New realtime message received: $newMsg");

          if (newMsg['course_id'] == widget.courseId &&
              (newMsg['sender_id'] == userId || newMsg['receiver_id'] == userId)) {
            setState(() {
              _messages.add(Map<String, dynamic>.from(newMsg));
            });
            _scrollToBottom();
          }
        },
      )
      .subscribe();
}


  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animate) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          // Instant scroll without animation
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
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
      
      // Keep focus on text field after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_textFieldFocus);
      });
      
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
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppTheme.instructorPrimary,
          foregroundColor: AppTheme.surfaceWhite,
          elevation: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: widget.profileImage != null ? NetworkImage(widget.profileImage!) : null,
                backgroundColor: AppTheme.surfaceWhite,
                child: widget.profileImage == null ? Icon(Icons.person, color: AppTheme.instructorPrimary) : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.instructorName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.surfaceWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.courseCode,
                    style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.surfaceWhite),
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
                            backgroundColor: AppTheme.instructorAccent,
                            child: Text(initials, style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.instructorPrimary)),
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
                        focusNode: _textFieldFocus,
                        enabled: !_sending,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 241, 249, 255),
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
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.instructorPrimary),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: AppTheme.instructorPrimary),
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
    final bubbleColor = isMe ? AppTheme.instructorAccent : AppTheme.surfaceWhite;
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
                    child: Text(sender!, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.instructorPrimary)),
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
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.instructorPrimary),
          ),
        ],
      ),
    );
  }
}
