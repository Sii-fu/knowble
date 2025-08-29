import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/theme.dart';
import 'instructor_profile_page.dart';

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
  bool _hasText = false;
  RealtimeChannel? _realtimeChannel;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initChat();
    // Track whether there's text to enable/disable the send action
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText && mounted) {
        setState(() => _hasText = has);
      }
    });
    
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
    
    if (!mounted) return; // Check if widget is still mounted
    setState(() {
      _messages = List<Map<String, dynamic>>.from(data);
    });
    _scrollToBottom(animate: false); // Instant scroll when loading messages
  }

  void _subscribeToRealtime() {
    final userId = _currentUserId;
    if (userId == null) return;

    _realtimeChannel = Supabase.instance.client
        .channel('realtime:public:chats')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chats',
          callback: (payload) {
            final newMsg = payload.newRecord;

            if (newMsg['course_id'] == widget.courseId &&
                (newMsg['sender_id'] == userId || newMsg['receiver_id'] == userId)) {
              if (!mounted) return; // Check if widget is still mounted
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
    
    if (!mounted) return; // Check if widget is still mounted
    setState(() { _sending = true; });
    
    try {
      await Supabase.instance.client.from('chats').insert({
        'course_id': widget.courseId,
        'sender_id': _currentUserId,
        'receiver_id': widget.receiverId,
        'message': text,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _controller.clear();
      
      // Keep focus on text field after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Check before accessing context
          FocusScope.of(context).requestFocus(_textFieldFocus);
        }
      });
      
    } catch (e) {
      if (mounted) { // Check before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: ${e.toString()}')),
        );
      }
    } finally {
      if (!mounted) return; // Check if widget is still mounted
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
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          elevation: 0,
          titleSpacing: 0,
          title: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => InstructorProfilePage(
                  instructorId: widget.receiverId,
                  instructorName: widget.instructorName,
                  profileImage: widget.profileImage,
                  courseId: widget.courseId,
                ),
              ));
            },
            child: Row(
              children: [
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.profileImage != null ? NetworkImage(widget.profileImage!) : null,
                  backgroundColor: AppTheme.accentLight,
                  child: widget.profileImage == null ? Icon(Icons.person, color: AppTheme.primaryTeal) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.instructorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.courseCode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                itemCount: _messages.length,
        itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg['sender_id'] == _currentUserId;
                  final dt = DateTime.tryParse(msg['timestamp'] ?? '') ?? DateTime.now();
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: ChatBubble(
                      text: msg['message'] ?? '',
                      isMe: isMe,
          timestamp: dt,
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  boxShadow: [
                    BoxShadow(color: AppTheme.shadowLight, blurRadius: 8, offset: const Offset(0, -2)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _textFieldFocus,
                        enabled: !_sending,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          filled: true,
                          fillColor: AppTheme.accentLight,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: AppTheme.borderSubtle, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: AppTheme.borderSubtle, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: AppTheme.primaryTeal, width: 1.2),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: _sending
                                ? const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal),
                                  )
                                : InkWell(
                                    onTap: _hasText && !_sending ? _sendMessage : null,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: _hasText ? AppTheme.primaryTeal : AppTheme.borderSubtle,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.send,
                                        size: 18,
                                        color: _hasText ? AppTheme.surfaceWhite : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                          ),
                          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        ),
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
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

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isMe ? AppTheme.primaryTeal.withValues(alpha: 01.0) : AppTheme.surfaceWhite;
    // final border = isMe ? AppTheme.primaryTeal : AppTheme.borderSubtle;
    final textColor = isMe ? AppTheme.surfaceWhite : AppTheme.textPrimary;
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: align,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                // border: Border.all(color: border, width: 1),
                boxShadow: [
                  BoxShadow(color: AppTheme.shadowLight, blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            timeago.format(timestamp),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
