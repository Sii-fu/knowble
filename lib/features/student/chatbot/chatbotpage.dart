import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme.dart';
  import '../../../core/services/gemini/chatbot.dart';
import '../../../core/config/api_config.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String? _selectedOption;
  
  // Initialize Gemini service
  late final GeminiService _geminiService;

  @override
  void initState() {
    super.initState();
    
    // Initialize Gemini service
    _geminiService = GeminiService();

    // Add welcome message
//     _messages.add(
//       ChatMessage(
//         message: """# 🤖 Welcome to Your AI Study Assistant!
// ## What I Can Help With:

// Just ask me anything about your studies! 📖✨
//         """,
//         isUser: false,
//         timestamp: DateTime.now(),
//       ),
//     );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    final selectedPrefix = _selectedOption;
    _messageController.clear();
    
    // Clear selected option after sending
    setState(() {
      _selectedOption = null;
    });

    // Add user message
    setState(() {
      _messages.add(
        ChatMessage(
          message: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      // Get AI response from Gemini
      String aiResponse;
      
      // Check if user has selected a specific option for better context
      if (selectedPrefix != null) {
        // Determine subject based on the selected option
        // aiResponse = await _geminiService.generateContentWithFallback(selectedPrefix, userMessage);
        aiResponse = await _geminiService.generateContentWithFallback( userMessage);
      } else {
        // Use general educational prompt with fallback
        aiResponse = await _geminiService.generateContentWithFallback(userMessage);
      }

      // Add AI response
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              message: aiResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      // Handle errors gracefully
      print('Error generating response: $e');

      setState(() {
        _messages.add(
          ChatMessage(
            message: 'Sorry, something went wrong. Please try again.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isTyping = false;
      });

      _scrollToBottom();
    }
  }



  void _selectOption(String option) {
    setState(() {
      _selectedOption = _selectedOption == option ? null : option;
    });
    _focusNode.requestFocus();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 1,
        shadowColor: AppTheme.shadowLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.gradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: AppTheme.surfaceWhite,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Study Assistant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  _isTyping ? 'Typing...' : 'Online',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
            onPressed: () {
              // Show options menu
              _showOptionsMenu();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return const TypingIndicator();
                }
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          _buildSuggestionButtons(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildSuggestionButtons() {
    if (_isTyping) return const SizedBox.shrink();
    
    // Get context-aware suggestions based on the last bot message
    final suggestions = _getContextualSuggestions();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick options:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                final prefix = suggestion['prefix'] as String;
                final isSelected = _selectedOption == prefix;
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          suggestion['icon'] as IconData,
                          size: 16,
                          color: isSelected ? Colors.white : AppTheme.primaryTeal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          suggestion['text'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) => _selectOption(prefix),
                    selectedColor: AppTheme.primaryTeal,
                    backgroundColor: AppTheme.accentLight,
                    side: BorderSide(
                      color: isSelected 
                          ? AppTheme.primaryTeal 
                          : AppTheme.primaryTeal.withOpacity(0.3),
                      width: 1,
                    ),
                    elevation: isSelected ? 2 : 0,
                    pressElevation: 4,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getContextualSuggestions() {
    if (_messages.isEmpty) return _getDefaultSuggestions();

    final lastBotMessage = _messages.reversed.firstWhere(
      (msg) => !msg.isUser,
      orElse: () => _messages.first,
    );

    final message = lastBotMessage.message.toLowerCase();

    if (message.contains('math') || message.contains('algebra') || message.contains('equation')) {
      return [
        {'icon': Icons.calculate, 'text': 'Solve', 'prefix': 'Solve this math problem:', 'placeholder': 'e.g. Solve: 2x + 5 = 15'},
        {'icon': Icons.lightbulb_outline, 'text': 'Concept', 'prefix': 'Explain this math concept:', 'placeholder': 'e.g. What is the quadratic formula?'},
        {'icon': Icons.quiz_outlined, 'text': 'Examples', 'prefix': 'Give me examples of', 'placeholder': 'e.g. Polynomial equations'},
        {'icon': Icons.format_list_bulleted, 'text': 'Steps', 'prefix': 'Show me how to solve', 'placeholder': 'e.g. a system of linear equations'},
        {'icon': Icons.auto_awesome, 'text': 'Trick', 'prefix': 'What’s a trick to solve', 'placeholder': 'e.g. factoring quadratic expressions'},
      ];
    } else if (message.contains('science') || message.contains('biology') || message.contains('physics')) {
      return [
        {'icon': Icons.science, 'text': 'Explain', 'prefix': 'Explain this scientific concept:', 'placeholder': 'e.g. How does photosynthesis work?'},
        {'icon': Icons.bolt, 'text': 'Break it down', 'prefix': 'Simplify', 'placeholder': 'e.g. Newton\'s Third Law of Motion'},
        {'icon': Icons.timeline, 'text': 'Process', 'prefix': 'Describe the process of', 'placeholder': 'e.g. Cell division (mitosis)'},
        {'icon': Icons.compare_arrows, 'text': 'Compare', 'prefix': 'Compare and contrast', 'placeholder': 'e.g. Mitosis vs Meiosis'},
        {'icon': Icons.lightbulb, 'text': 'Why?', 'prefix': 'Why does', 'placeholder': 'e.g. Salt dissolve in water?'},
      ];
    } else if (message.contains('history') || message.contains('revolution') || message.contains('war')) {
      return [
        {'icon': Icons.timeline, 'text': 'Timeline', 'prefix': 'Create a timeline for', 'placeholder': 'e.g. Key events of World War II'},
        {'icon': Icons.flag, 'text': 'Event', 'prefix': 'What happened during', 'placeholder': 'e.g. The French Revolution'},
        {'icon': Icons.person, 'text': 'Figure', 'prefix': 'Tell me about', 'placeholder': 'e.g. Napoleon Bonaparte'},
        {'icon': Icons.compare_arrows, 'text': 'Compare', 'prefix': 'Compare', 'placeholder': 'e.g. WWI and WWII'},
        {'icon': Icons.public, 'text': 'Impact', 'prefix': 'What was the impact of', 'placeholder': 'e.g. The Cold War on global politics'},
      ];
    } else if (message.contains('english') || message.contains('literature') || message.contains('poem')) {
      return [
        {'icon': Icons.edit, 'text': 'Analyze', 'prefix': 'Analyze this line:', 'placeholder': 'e.g. "To be or not to be" from Hamlet'},
        {'icon': Icons.format_quote, 'text': 'Theme', 'prefix': 'What is the main theme of', 'placeholder': 'e.g. Romeo and Juliet'},
        {'icon': Icons.create, 'text': 'Essay Help', 'prefix': 'Help me write an essay about', 'placeholder': 'e.g. The role of fate in Macbeth'},
        {'icon': Icons.spellcheck, 'text': 'Grammar', 'prefix': 'Check the grammar:', 'placeholder': 'e.g. This sentence have a mistake.'},
        {'icon': Icons.quiz_outlined, 'text': 'Figurative', 'prefix': 'Give me examples of', 'placeholder': 'e.g. Metaphors in modern poetry'},
      ];
    } else if (message.contains('computer') || message.contains('coding') || message.contains('programming')) {
      return [
        {'icon': Icons.code, 'text': 'Debug', 'prefix': 'What’s wrong with this code?', 'placeholder': 'e.g. for (int i = 0; i <= n; i--)'},
        {'icon': Icons.psychology, 'text': 'Explain', 'prefix': 'Explain this code concept:', 'placeholder': 'e.g. How recursion works in Dart'},
        {'icon': Icons.build, 'text': 'How to', 'prefix': 'How do I build', 'placeholder': 'e.g. A login system in Flutter'},
        {'icon': Icons.compare_arrows, 'text': 'Compare', 'prefix': 'Compare', 'placeholder': 'e.g. Dart and JavaScript differences'},
        {'icon': Icons.quiz_outlined, 'text': 'Examples', 'prefix': 'Show code examples of', 'placeholder': 'e.g. Firebase CRUD in Flutter'},
      ];
    } else if (message.contains('business') || message.contains('marketing') || message.contains('startup')) {
      return [
        {'icon': Icons.trending_up, 'text': 'Strategy', 'prefix': 'What is a good strategy for', 'placeholder': 'e.g. Launching a new SaaS startup'},
        {'icon': Icons.lightbulb_outline, 'text': 'Idea', 'prefix': 'Give me business ideas about', 'placeholder': 'e.g. AI in education'},
        {'icon': Icons.query_stats, 'text': 'Explain', 'prefix': 'Explain this marketing term:', 'placeholder': 'e.g. Conversion rate optimization'},
        {'icon': Icons.compare_arrows, 'text': 'Compare', 'prefix': 'Compare', 'placeholder': 'e.g. B2B vs B2C models'},
        {'icon': Icons.help_outline, 'text': 'Plan', 'prefix': 'Create a business plan for', 'placeholder': 'e.g. A local food delivery app'},
      ];
    }


    return _getDefaultSuggestions();
  }


  List<Map<String, dynamic>> _getDefaultSuggestions() {
   return [
      {'icon': Icons.lightbulb_outline, 'text': 'Explain', 'prefix': 'Explain', 'placeholder': 'e.g. What is machine learning?'},
      {'icon': Icons.format_list_bulleted, 'text': 'Steps', 'prefix': 'Show me step-by-step how to', 'placeholder': 'e.g. Solve a quadratic equation'},
      {'icon': Icons.quiz_outlined, 'text': 'Examples', 'prefix': 'Give me examples of', 'placeholder': 'e.g. Renewable energy sources'},
      {'icon': Icons.psychology, 'text': 'Simplify', 'prefix': 'Explain in simple terms:', 'placeholder': 'e.g. Blockchain technology'},
      {'icon': Icons.calculate, 'text': 'Solve', 'prefix': 'Solve this problem:', 'placeholder': 'e.g. 3x² + 5x - 2 = 0'},
      {'icon': Icons.summarize, 'text': 'Summarize', 'prefix': 'Summarize this:', 'placeholder': 'e.g. The plot of Inception'},
      {'icon': Icons.create, 'text': 'Write', 'prefix': 'Help me write', 'placeholder': 'e.g. A paragraph about climate change'},
      {'icon': Icons.compare_arrows, 'text': 'Compare', 'prefix': 'Compare', 'placeholder': 'e.g. iOS vs Android'},

      // 🆕 Extra Suggestions:
      {'icon': Icons.question_answer, 'text': 'Ask Anything', 'prefix': 'I have a question about', 'placeholder': 'e.g. The stock market'},
      {'icon': Icons.translate, 'text': 'Translate', 'prefix': 'Translate this into English:', 'placeholder': 'e.g. Je suis étudiant'},
      {'icon': Icons.tips_and_updates, 'text': 'Tips', 'prefix': 'Give me tips on', 'placeholder': 'e.g. Time management'},
      {'icon': Icons.edit_note, 'text': 'Improve Writing', 'prefix': 'Make this sound better:', 'placeholder': 'e.g. I went to the shop'},
      {'icon': Icons.light_mode, 'text': 'ELI5', 'prefix': 'Explain like I\'m 5:', 'placeholder': 'e.g. Quantum mechanics'},
      {'icon': Icons.star, 'text': 'Pros & Cons', 'prefix': 'List pros and cons of', 'placeholder': 'e.g. Online learning'},
      {'icon': Icons.extension, 'text': 'Use Cases', 'prefix': 'What are some real-life uses of', 'placeholder': 'e.g. Artificial Intelligence'},
      {'icon': Icons.school, 'text': 'Study Help', 'prefix': 'Help me study', 'placeholder': 'e.g. For my biology test tomorrow'},
    ];

  }


  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(
          top: BorderSide(color: AppTheme.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: _selectedOption != null
                      ? (_getContextualSuggestions().firstWhere(
                          (s) => s['prefix'] == _selectedOption,
                          orElse: () => {'placeholder': 'Ask me anything about your studies...'},
                        )['placeholder'] as String)
                      : 'Ask me anything about your studies...',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(color: AppTheme.textPrimary),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.gradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: AppTheme.surfaceWhite),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.refresh, color: AppTheme.primaryTeal),
              title: const Text('Clear Chat', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _clearChat();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: AppTheme.primaryTeal),
              title: const Text('Help & Tips', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _showHelpDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add(
        ChatMessage(
          message: """# 🤖 Welcome Back!

Chat cleared! I'm ready to help you with your **academic questions** again.

## What I Can Help With:
- 🧮 **Mathematics** - Algebra, geometry, calculus
- 🔬 **Science** - Physics, chemistry, biology  
- 📚 **History** - World events, timelines
- ✍️ **English** - Writing, literature, grammar

Just ask me anything about your studies! 📖✨""",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: const Text('How to use AI Assistant', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Tips for better interactions:\n\n'
          '• Be specific with your questions\n'
          '• Ask for step-by-step explanations\n'
          '• Request examples for better understanding\n'
          '• Feel free to ask follow-up questions\n\n'
          'I can help with subjects like Math, Science, History, Literature, and more!',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!', style: TextStyle(color: AppTheme.primaryTeal)),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.gradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: AppTheme.surfaceWhite,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(              child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? AppTheme.primaryTeal : AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: message.isUser 
                ? Text(
                    message.message,
                    style: const TextStyle(
                      color: AppTheme.surfaceWhite,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  )
                : _buildMarkdownContent(),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppTheme.accentLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.primaryTeal,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMarkdownContent() {
    return MarkdownWidget(
      data: message.message,
      shrinkWrap: true,
      selectable: true,
      config: MarkdownConfig(
        configs: [
          // Customize heading styles
          const H1Config(
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const H2Config(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const H3Config(
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          // Customize paragraph style
          const PConfig(
            textStyle: TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
          // Customize code blocks
          CodeConfig(
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textPrimary,
              fontFamily: 'Courier',
            ),
          ),
          // Customize links
          LinkConfig(
            style: const TextStyle(
              color: AppTheme.primaryTeal,
              decoration: TextDecoration.underline,
            ),
            onTap: (url) async {
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
            },
          ),
          // Customize tables
          const TableConfig(),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppTheme.gradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: AppTheme.surfaceWhite,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.3;
                    final opacity = ((_animationController.value + delay) % 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withOpacity(
                            0.3 + (opacity * 0.7),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
