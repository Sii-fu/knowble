import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(
      ChatMessage(
        message: """# 🤖 Welcome to Your AI Study Assistant!

Hello! I'm here to help you with your **academic questions** and make learning easier.

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

    // Combine selected option with user message
    final finalMessage = selectedPrefix != null 
        ? "$selectedPrefix: $userMessage"
        : userMessage;

    // Add user message
    setState(() {
      _messages.add(
        ChatMessage(
          message: finalMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate AI response delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Add AI response (placeholder - replace with actual AI integration)
    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessage(
            message: _generateAIResponse(finalMessage),
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

  String _generateAIResponse(String userMessage) {
    // Enhanced response logic with markdown formatting
    final message = userMessage.toLowerCase();
    
    if (message.contains('math') || message.contains('algebra') || message.contains('calculate')) {
      return """# 🧮 Mathematics Help

I'd be happy to help you with **math**! Here's what I can assist you with:

## Subjects I Cover:
- **Algebra** - Equations, polynomials, factoring
- **Geometry** - Shapes, angles, area, volume
- **Calculus** - Derivatives, integrals, limits
- **Statistics** - Data analysis, probability
- **Trigonometry** - Sin, cos, tan functions

## Example Questions:
> "Solve for x: 2x + 5 = 15"
> "What is the area of a circle with radius 7?"
> "Explain the quadratic formula"

💡 **Tip**: Be specific with your math questions for better help!""";

    } else if (message.contains('science') || message.contains('physics') || message.contains('chemistry') || message.contains('biology')) {
      return """# 🔬 Science Assistance

Science is fascinating! I can help you understand various scientific concepts:

## Areas of Expertise:
### Physics ⚡
- Mechanics, thermodynamics, electromagnetism
- Newton's laws, energy, waves

### Chemistry 🧪  
- Periodic table, chemical reactions
- Acids, bases, organic chemistry

### Biology 🧬
- Cell structure, genetics, evolution
- Human anatomy, ecosystems

## How I Can Help:
- ✅ Explain complex theories
- ✅ Break down experiments
- ✅ Clarify scientific principles
- ✅ Provide study guides

What specific topic interests you?""";

    } else if (message.contains('history')) {
      return """# 📚 History Explorer

History is full of **fascinating stories** and important lessons!

## What I Can Help With:

### Time Periods 🕰️
- Ancient civilizations
- Medieval times  
- Renaissance & Enlightenment
- Modern era

### Key Topics 🌍
- **World Wars** - Causes, events, consequences
- **Revolutions** - American, French, Industrial
- **Empires** - Roman, British, Ottoman
- **Important Figures** - Leaders, inventors, reformers

### Study Support 📖
- Timeline creation
- Cause and effect analysis
- Historical context explanation
- Essay writing tips

*Which period or event would you like to explore?*""";

    } else if (message.contains('english') || message.contains('literature') || message.contains('writing')) {
      return """# ✍️ English & Literature Guide

I'm here to enhance your **English skills**!

## Writing Skills 📝
- **Essay Writing** - Structure, arguments, conclusions
- **Grammar** - Punctuation, sentence structure
- **Creative Writing** - Stories, poems, narratives

## Literature Analysis 📚
- **Poetry** - Metaphors, themes, literary devices
- **Novels** - Character development, plot analysis
- **Drama** - Shakespeare, modern plays

## Communication 💬
- **Public Speaking** - Confidence, clarity
- **Vocabulary** - Word choice, synonyms
- **Reading Comprehension** - Understanding texts

### Quick Tips:
> 1. Always outline before writing
> 2. Read your work aloud
> 3. Use active voice when possible

What aspect of English would you like to work on?""";

    } else if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      return """# 👋 Welcome to Your AI Study Assistant!

Hello there! I'm excited to help you learn and grow academically.

## What I Can Do:
- 📊 **Mathematics** - From basic arithmetic to calculus
- 🔬 **Science** - Physics, chemistry, biology
- 📜 **History** - World events, timelines, analysis  
- ✍️ **English** - Writing, literature, grammar
- 🌍 **Geography** - Countries, capitals, physical features
- 💻 **Computer Science** - Programming, algorithms

## How to Get Started:
1. Ask me a **specific question**
2. Request **step-by-step explanations**
3. Ask for **examples** to clarify concepts
4. Feel free to ask **follow-up questions**

### Example Questions:
> "Explain photosynthesis step by step"
> "Help me solve this algebra problem"
> "What caused World War I?"

*What subject would you like to explore today?* 🚀""";

    } else if (message.contains('help') || message.contains('how') || message.contains('what can you do')) {
      return """# 🤖 How I Can Help You Study

## My Capabilities:

### 📚 **Academic Subjects**
| Subject | What I Cover |
|---------|-------------|
| Math | Algebra, Geometry, Calculus, Statistics |
| Science | Physics, Chemistry, Biology |
| History | World history, timelines, analysis |
| English | Writing, literature, grammar |

### 🎯 **Study Methods**
- **Step-by-step solutions**
- **Concept explanations**
- **Practice problems**
- **Study guides**
- **Memory techniques**

### 💡 **Best Practices**
1. Be **specific** with your questions
2. Ask for **examples** when confused
3. Request **different explanations** if needed
4. Practice with **similar problems**

Ready to learn something new? Just ask me a question! 🌟""";

    } else {
      return """# 🤔 Let's Explore Together!

That's an interesting question! I'm here to help you **learn and understand** various topics.

## To Give You Better Help:
- 🎯 **Be specific** about the subject area
- 📝 **Share the exact problem** you're working on  
- 🔍 **Mention your grade level** if relevant
- ❓ **Ask follow-up questions** freely

## Popular Study Areas:
- 🧮 **Mathematics** - Equations, geometry, calculus
- 🔬 **Sciences** - Physics, chemistry, biology  
- 📚 **Humanities** - History, literature, writing
- 💻 **Technology** - Programming, digital skills

### Quick Examples:
> "Explain the water cycle"
> "How do I factor this polynomial?"
> "What's the theme of Romeo and Juliet?"

*What would you like to learn about today?* ✨""";
    }
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
    // Check if we have previous messages to get context
    if (_messages.isEmpty) {
      return _getDefaultSuggestions();
    }
    
    final lastBotMessage = _messages.reversed
        .firstWhere((msg) => !msg.isUser, orElse: () => _messages.first);
    
    // Return context-aware suggestions based on the last bot response
    if (lastBotMessage.message.toLowerCase().contains('math')) {
      return [
        {'icon': Icons.calculate, 'text': 'Solve', 'prefix': 'Solve this math problem:', 'placeholder': ' 2x + 5 = 15'},
        {'icon': Icons.lightbulb_outline, 'text': 'Explain', 'prefix': 'Explain this concept:', 'placeholder': ' quadratic formula'},
        {'icon': Icons.quiz_outlined, 'text': 'Examples', 'prefix': 'Give me examples of', 'placeholder': ' polynomial equations'},
        {'icon': Icons.format_list_bulleted, 'text': 'Steps', 'prefix': 'Show me step-by-step how to', 'placeholder': ' factor polynomials'},
        {'icon': Icons.help_outline, 'text': 'Practice', 'prefix': 'Give me practice problems for', 'placeholder': ' algebra'},
      ];
    } else if (lastBotMessage.message.toLowerCase().contains('science')) {
      return [
        {'icon': Icons.science, 'text': 'Explain', 'prefix': 'Explain this scientific concept:', 'placeholder': ' photosynthesis'},
        {'icon': Icons.quiz_outlined, 'text': 'Examples', 'prefix': 'Give me examples of', 'placeholder': ' chemical reactions'},
        {'icon': Icons.format_list_bulleted, 'text': 'Process', 'prefix': 'Show me the process of', 'placeholder': ' cellular respiration'},
        {'icon': Icons.psychology, 'text': 'Simplify', 'prefix': 'Explain in simple terms:', 'placeholder': ' DNA structure'},
        {'icon': Icons.compare_arrows, 'text': 'Compare', 'prefix': 'Compare and contrast', 'placeholder': ' mitosis vs meiosis'},
      ];
    } else if (lastBotMessage.message.toLowerCase().contains('history')) {
      return [
        {'icon': Icons.timeline, 'text': 'Timeline', 'prefix': 'Create a timeline for', 'placeholder': ' World War II'},
        {'icon': Icons.person, 'text': 'Biography', 'prefix': 'Tell me about', 'placeholder': ' Napoleon Bonaparte'},
        {'icon': Icons.quiz_outlined, 'text': 'Causes', 'prefix': 'What caused', 'placeholder': ' the French Revolution'},
        {'icon': Icons.compare_arrows, 'text': 'Compare', 'prefix': 'Compare', 'placeholder': ' WWI and WWII'},
        {'icon': Icons.explore, 'text': 'Context', 'prefix': 'Explain the historical context of', 'placeholder': ' the Industrial Revolution'},
      ];
    } else if (lastBotMessage.message.toLowerCase().contains('english') || lastBotMessage.message.toLowerCase().contains('literature')) {
      return [
        {'icon': Icons.edit, 'text': 'Analyze', 'prefix': 'Analyze this text:', 'placeholder': ' "To be or not to be"'},
        {'icon': Icons.format_quote, 'text': 'Theme', 'prefix': 'What is the main theme of', 'placeholder': ' Romeo and Juliet'},
        {'icon': Icons.create, 'text': 'Write', 'prefix': 'Help me write', 'placeholder': ' an essay about'},
        {'icon': Icons.spellcheck, 'text': 'Grammar', 'prefix': 'Check the grammar:', 'placeholder': ' [paste your text]'},
        {'icon': Icons.quiz_outlined, 'text': 'Examples', 'prefix': 'Give me examples of', 'placeholder': ' metaphors'},
      ];
    }
    
    return _getDefaultSuggestions();
  }

  List<Map<String, dynamic>> _getDefaultSuggestions() {
    return [
      {'icon': Icons.lightbulb_outline, 'text': 'Explain', 'prefix': 'Explain', 'placeholder': ' [your topic]'},
      {'icon': Icons.format_list_bulleted, 'text': 'Step-by-step', 'prefix': 'Show me step-by-step how to', 'placeholder': ' [your task]'},
      {'icon': Icons.quiz_outlined, 'text': 'Examples', 'prefix': 'Give me examples of', 'placeholder': ' [your topic]'},
      {'icon': Icons.psychology, 'text': 'Simplify', 'prefix': 'Explain in simple terms', 'placeholder': ' [complex topic]'},
      {'icon': Icons.calculate, 'text': 'Solve', 'prefix': 'Solve this problem:', 'placeholder': ' [your problem]'},
      {'icon': Icons.summarize, 'text': 'Summarize', 'prefix': 'Summarize', 'placeholder': ' [your text/topic]'},
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
                      ? "Type your message..."
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const H2Config(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const H3Config(
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          // Customize paragraph style
          const PConfig(
            textStyle: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
          // Customize code blocks
          CodeConfig(
            style: const TextStyle(
              fontSize: 13,
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
