import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../../config/theme.dart';
import '../../../core/services/gemini/chatbot.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String? _selectedOption;
  
  // Initialize Gemini service
  late final GeminiService _geminiService;
  
  // Animation controllers for Gemini-style effects
  late AnimationController _backgroundAnimationController;
  late AnimationController _floatingElementsController;
  late AnimationController _messageAnimationController;
  late AnimationController _thinkingAnimationController;
  
  late Animation<double> _backgroundAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize Gemini service
    _geminiService = GeminiService();
    
    // Initialize animation controllers
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _floatingElementsController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
    
    _messageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _thinkingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Initialize animations
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingElementsController,
      curve: Curves.easeInOut,
    ));

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
    _backgroundAnimationController.dispose();
    _floatingElementsController.dispose();
    _messageAnimationController.dispose();
    _thinkingAnimationController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();
    
    // Clear selected option after sending
    setState(() {
      _selectedOption = null;
    });

    // Add user message with animation
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

    // Start thinking animation
    _thinkingAnimationController.repeat();

    // Animate new message
    _messageAnimationController.forward().then((_) {
      _messageAnimationController.reset();
    });

    _scrollToBottom();

    try {
      // Get AI response from Gemini
      final aiResponse = await _geminiService.generateContentWithFallback(userMessage, _selectedOption ?? '');

      // Stop thinking animation
      _thinkingAnimationController.stop();
      _thinkingAnimationController.reset();

      // Add AI response with animation
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              message: aiResponse,
              isUser: false,
              timestamp: DateTime.now(),
              isTyping: true, // Enable typewriter effect
            ),
          );
          _isTyping = false;
        });
        
        // Animate AI response
        _messageAnimationController.forward().then((_) {
          _messageAnimationController.reset();
        });
        
        _scrollToBottom();
      }
    } catch (e) {
      // Stop thinking animation on error
      _thinkingAnimationController.stop();
      _thinkingAnimationController.reset();
      
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

  // Refined animated background with subtle Gemini-style gradients
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                // Very subtle color shifts for professional look
                Color.lerp(
                  const Color(0xFFFAFAFA),
                  const Color(0xFFF5F7FA),
                  _backgroundAnimation.value * 0.3,
                )!,
                Color.lerp(
                  const Color(0xFFFFFFFE),
                  const Color(0xFFF8FAFB),
                  (_backgroundAnimation.value + 0.5) % 1.0 * 0.2,
                )!,
                Color.lerp(
                  const Color(0xFFFDFDFD),
                  const Color(0xFFF6F8FA),
                  (_backgroundAnimation.value + 0.3) % 1.0 * 0.25,
                )!,
              ],
              stops: [
                0.0,
                0.5 + (_backgroundAnimation.value * 0.1),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  // Subtle floating gradient elements
  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // First floating element - very subtle
            Positioned(
              top: 80 + (math.sin(_floatingAnimation.value * 2 * math.pi) * 15),
              right: 60 + (math.cos(_floatingAnimation.value * 2 * math.pi) * 10),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryTeal.withOpacity(0.03),
                      AppTheme.primaryTeal.withOpacity(0.005),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Second floating element
            Positioned(
              bottom: 150 + (math.cos(_floatingAnimation.value * 1.5 * math.pi) * 20),
              left: 40 + (math.sin(_floatingAnimation.value * 1.5 * math.pi) * 15),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF9C27B0).withOpacity(0.025),
                      const Color(0xFF9C27B0).withOpacity(0.003),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Gradient app bar with glassmorphism effect
  Widget _buildGradientAppBar() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.surfaceWhite.withOpacity(0.95),
            AppTheme.surfaceWhite.withOpacity(0.8),
            AppTheme.surfaceWhite.withOpacity(0.0),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryTeal,
                            AppTheme.primaryTeal.withOpacity(0.8),
                            const Color(0xFF9C27B0).withOpacity(0.6),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryTeal.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppTheme.surfaceWhite,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                AppTheme.primaryTeal,
                                const Color(0xFF9C27B0),
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'AI Study Assistant',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.surfaceWhite,
                              ),
                            ),
                          ),
                          Text(
                            _isTyping ? 'Thinking...' : 'Ready to help',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
                  onPressed: _showOptionsMenu,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced message input with gradient effects
  Widget _buildGradientMessageInput() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceWhite.withOpacity(0.95),
            AppTheme.surfaceWhite.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: _selectedOption != null
                    ? (_getContextualSuggestions().firstWhere(
                        (s) => s['text'] == _selectedOption,
                        orElse: () => {'placeholder': 'Ask me anything about your studies...'},
                      )['placeholder'] as String)
                    : 'Ask me anything about your studies...',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryTeal,
                  const Color(0xFF9C27B0).withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryTeal.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
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
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(),
          
          // Floating gradient elements
          _buildFloatingElements(),
          
          // Main content
          Column(
            children: [
              _buildGradientAppBar(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return const GeminiThinkingIndicator();
                    }
                    return ChatBubble(message: _messages[index]);
                  },
                ),
              ),
              _buildSuggestionButtons(),
              _buildGradientMessageInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionButtons() {
    if (_isTyping) return const SizedBox.shrink();
    
    // Get context-aware suggestions based on the last bot message
    final suggestions = _getContextualSuggestions();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppTheme.primaryTeal.withOpacity(0.8),
                const Color(0xFF9C27B0).withOpacity(0.6),
              ],
            ).createShader(bounds),
            child: const Text(
              'Quick suggestions:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.surfaceWhite,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                final text = suggestion['text'] as String;
                final isSelected = _selectedOption == text;
                
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                AppTheme.primaryTeal,
                                const Color(0xFF9C27B0).withOpacity(0.8),
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                AppTheme.surfaceWhite,
                                AppTheme.accentLight.withOpacity(0.5),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected 
                              ? AppTheme.primaryTeal.withOpacity(0.3)
                              : AppTheme.shadowLight.withOpacity(0.1),
                          blurRadius: isSelected ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: isSelected 
                            ? Colors.transparent
                            : AppTheme.primaryTeal.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectOption(text),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                suggestion['icon'] as IconData,
                                size: 18,
                                color: isSelected 
                                    ? AppTheme.surfaceWhite 
                                    : AppTheme.primaryTeal,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                text,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected 
                                      ? AppTheme.surfaceWhite 
                                      : AppTheme.primaryTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
      {'icon': Icons.calculate, 'text': 'Solve', 'placeholder': 'e.g. Solve: 2x + 5 = 15'},
      {'icon': Icons.lightbulb_outline, 'text': 'Concept', 'placeholder': 'e.g. What is the quadratic formula?'},
      {'icon': Icons.quiz_outlined, 'text': 'Examples', 'placeholder': 'e.g. Polynomial equations'},
      {'icon': Icons.format_list_bulleted, 'text': 'Steps', 'placeholder': 'e.g. a system of linear equations'},
      {'icon': Icons.auto_awesome, 'text': 'Trick', 'placeholder': 'e.g. factoring quadratic expressions'},
      ];
    } else if (message.contains('science') || message.contains('biology') || message.contains('physics')) {
      return [
      {'icon': Icons.science, 'text': 'Explain', 'placeholder': 'e.g. How does photosynthesis work?'},
      {'icon': Icons.bolt, 'text': 'Break it down', 'placeholder': 'e.g. Newton\'s Third Law of Motion'},
      {'icon': Icons.timeline, 'text': 'Process', 'placeholder': 'e.g. Cell division (mitosis)'},
      {'icon': Icons.compare_arrows, 'text': 'Compare', 'placeholder': 'e.g. Mitosis vs Meiosis'},
      {'icon': Icons.lightbulb, 'text': 'Why?', 'placeholder': 'e.g. Salt dissolve in water?'},
      ];
    } else if (message.contains('history') || message.contains('revolution') || message.contains('war')) {
      return [
      {'icon': Icons.timeline, 'text': 'Timeline', 'placeholder': 'e.g. Key events of World War II'},
      {'icon': Icons.flag, 'text': 'Event', 'placeholder': 'e.g. The French Revolution'},
      {'icon': Icons.person, 'text': 'Figure', 'placeholder': 'e.g. Napoleon Bonaparte'},
      {'icon': Icons.compare_arrows, 'text': 'Compare', 'placeholder': 'e.g. WWI and WWII'},
      {'icon': Icons.public, 'text': 'Impact', 'placeholder': 'e.g. The Cold War on global politics'},
      ];
    } else if (message.contains('english') || message.contains('literature') || message.contains('poem')) {
      return [
      {'icon': Icons.edit, 'text': 'Analyze', 'placeholder': 'e.g. "To be or not to be" from Hamlet'},
      {'icon': Icons.format_quote, 'text': 'Theme', 'placeholder': 'e.g. Romeo and Juliet'},
      {'icon': Icons.create, 'text': 'Essay Help', 'placeholder': 'e.g. The role of fate in Macbeth'},
      {'icon': Icons.spellcheck, 'text': 'Grammar', 'placeholder': 'e.g. This sentence have a mistake.'},
      {'icon': Icons.quiz_outlined, 'text': 'Figurative', 'placeholder': 'e.g. Metaphors in modern poetry'},
      ];
    } else if (message.contains('computer') || message.contains('coding') || message.contains('programming')) {
      return [
      {'icon': Icons.code, 'text': 'Debug', 'placeholder': 'e.g. for (int i = 0; i <= n; i--)'},
      {'icon': Icons.psychology, 'text': 'Explain', 'placeholder': 'e.g. How recursion works in Dart'},
      {'icon': Icons.build, 'text': 'How to', 'placeholder': 'e.g. A login system in Flutter'},
      {'icon': Icons.compare_arrows, 'text': 'Compare', 'placeholder': 'e.g. Dart and JavaScript differences'},
      {'icon': Icons.quiz_outlined, 'text': 'Examples', 'placeholder': 'e.g. Firebase CRUD in Flutter'},
      ];
    } else if (message.contains('business') || message.contains('marketing') || message.contains('startup')) {
      return [
      {'icon': Icons.trending_up, 'text': 'Strategy', 'placeholder': 'e.g. Launching a new SaaS startup'},
      {'icon': Icons.lightbulb_outline, 'text': 'Idea', 'placeholder': 'e.g. AI in education'},
      {'icon': Icons.query_stats, 'text': 'Explain', 'placeholder': 'e.g. Conversion rate optimization'},
      {'icon': Icons.compare_arrows, 'text': 'Compare', 'placeholder': 'e.g. B2B vs B2C models'},
      {'icon': Icons.help_outline, 'text': 'Plan', 'placeholder': 'e.g. A local food delivery app'},
      ];
    }
    return _getDefaultSuggestions();
  }


  List<Map<String, dynamic>> _getDefaultSuggestions() {
   return [
      {'icon': Icons.lightbulb_outline, 'text': 'Explain', 'placeholder': 'e.g. What is machine learning?'},
      {'icon': Icons.format_list_bulleted, 'text': 'Steps', 'placeholder': 'e.g. Solve a quadratic equation'},
      {'icon': Icons.quiz_outlined, 'text': 'Examples', 'placeholder': 'e.g. Renewable energy sources'},
      {'icon': Icons.psychology, 'text': 'Simplify', 'placeholder': 'e.g. Blockchain technology'},
      {'icon': Icons.calculate, 'text': 'Solve', 'placeholder': 'e.g. 3x² + 5x - 2 = 0'},
      {'icon': Icons.summarize, 'text': 'Summarize', 'placeholder': 'e.g. The plot of Inception'},
      {'icon': Icons.create, 'text': 'Write', 'placeholder': 'e.g. A paragraph about climate change'},
      {'icon': Icons.compare_arrows, 'text': 'Compare', 'placeholder': 'e.g. iOS vs Android'},

      // 🆕 Extra Suggestions:
      {'icon': Icons.question_answer, 'text': 'Ask Anything', 'placeholder': 'e.g. The stock market'},
      {'icon': Icons.translate, 'text': 'Translate', 'placeholder': 'e.g. Je suis étudiant'},
      {'icon': Icons.tips_and_updates, 'text': 'Tips', 'placeholder': 'e.g. Time management'},
      {'icon': Icons.edit_note, 'text': 'Improve Writing', 'placeholder': 'e.g. I went to the shop'},
      {'icon': Icons.light_mode, 'text': 'ELI5', 'placeholder': 'e.g. Quantum mechanics'},
      {'icon': Icons.star, 'text': 'Pros & Cons', 'placeholder': 'e.g. Online learning'},
      {'icon': Icons.extension, 'text': 'Use Cases', 'placeholder': 'e.g. Artificial Intelligence'},
      {'icon': Icons.school, 'text': 'Study Help', 'placeholder': 'e.g. For my biology test tomorrow'},
    ];

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
  final bool isTyping;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.isTyping = false,
  });
}

class ChatBubble extends StatefulWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  String _displayedText = '';
  bool _isTypingComplete = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Start shimmer for AI messages
    if (!widget.message.isUser) {
      _shimmerController.repeat(reverse: true);
      
      // Start typewriter effect for AI messages
      if (widget.message.isTyping) {
        _startTypewriterEffect();
      } else {
        _displayedText = widget.message.message;
        _isTypingComplete = true;
      }
    } else {
      _displayedText = widget.message.message;
      _isTypingComplete = true;
    }
  }

  void _startTypewriterEffect() {
    _displayedText = '';
    final fullText = widget.message.message;
    int currentIndex = 0;
    
    Timer.periodic(const Duration(milliseconds: 5), (timer) {
      if (currentIndex < fullText.length && mounted) {
        setState(() {
          _displayedText = fullText.substring(0, currentIndex + 1);
        });
        currentIndex++;
      } else {
        timer.cancel();
        setState(() {
          _isTypingComplete = true;
        });
        // Stop shimmer when typing is complete
        if (_isTypingComplete) {
          _shimmerController.stop();
        }
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: widget.message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.message.isUser) ...[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryTeal,
                              Color.lerp(AppTheme.primaryTeal, const Color(0xFF9C27B0), _shimmerAnimation.value * 0.3)!,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryTeal.withOpacity(0.3 + (_shimmerAnimation.value * 0.2)),
                              blurRadius: 8 + (_shimmerAnimation.value * 4),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: AppTheme.surfaceWhite,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: widget.message.isUser 
                              ? LinearGradient(
                                  colors: [
                                    AppTheme.primaryTeal,
                                    AppTheme.primaryTeal.withOpacity(0.9),
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    AppTheme.surfaceWhite,
                                    Color.lerp(AppTheme.surfaceWhite, AppTheme.accentLight, _shimmerAnimation.value * 0.1)!,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(20).copyWith(
                            bottomLeft: widget.message.isUser ? const Radius.circular(20) : const Radius.circular(6),
                            bottomRight: widget.message.isUser ? const Radius.circular(6) : const Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.message.isUser 
                                  ? AppTheme.primaryTeal.withOpacity(0.3)
                                  : AppTheme.shadowLight.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                            if (!widget.message.isUser)
                              BoxShadow(
                                color: AppTheme.primaryTeal.withOpacity(0.05 + (_shimmerAnimation.value * 0.05)),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                          ],
                          border: widget.message.isUser 
                              ? null
                              : Border.all(
                                  color: AppTheme.primaryTeal.withOpacity(0.1 + (_shimmerAnimation.value * 0.1)),
                                  width: 1,
                                ),
                        ),
                        child: widget.message.isUser 
                            ? Text(
                                _displayedText,
                                style: const TextStyle(
                                  color: AppTheme.surfaceWhite,
                                  fontSize: 15,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : _buildMarkdownContent(),
                      ),
                    ),
                    if (widget.message.isUser) ...[
                      const SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.accentLight,
                              AppTheme.accentLight.withOpacity(0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryTeal.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppTheme.primaryTeal,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMarkdownContent() {
    return MarkdownWidget(
      data: _displayedText,
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
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animationController, _pulseAnimation]),
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryTeal,
                      Color.lerp(AppTheme.primaryTeal, const Color(0xFF9C27B0), _pulseAnimation.value * 0.3)!,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withOpacity(0.3 + (_pulseAnimation.value * 0.2)),
                      blurRadius: 8 + (_pulseAnimation.value * 6),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.surfaceWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.surfaceWhite,
                      Color.lerp(AppTheme.surfaceWhite, AppTheme.accentLight, _pulseAnimation.value * 0.1)!,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: AppTheme.primaryTeal.withOpacity(0.05 + (_pulseAnimation.value * 0.05)),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: AppTheme.primaryTeal.withOpacity(0.1 + (_pulseAnimation.value * 0.1)),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.3;
                    final opacity = ((_animationController.value + delay) % 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryTeal.withOpacity(0.3 + (opacity * 0.7)),
                              const Color(0xFF9C27B0).withOpacity(0.2 + (opacity * 0.5)),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Enhanced Gemini-style thinking indicator
class GeminiThinkingIndicator extends StatefulWidget {
  final Animation<double>? thinkingAnimation;
  
  const GeminiThinkingIndicator({
    super.key, 
    this.thinkingAnimation,
  });

  @override
  State<GeminiThinkingIndicator> createState() => _GeminiThinkingIndicatorState();
}

class _GeminiThinkingIndicatorState extends State<GeminiThinkingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _shimmerAnimation, widget.thinkingAnimation ?? _pulseAnimation]),
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced AI avatar with thinking animation
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryTeal,
                      Color.lerp(
                        AppTheme.primaryTeal, 
                        const Color(0xFF9C27B0), 
                        _pulseAnimation.value * 0.4
                      )!,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withOpacity(0.2 + (_pulseAnimation.value * 0.3)),
                      blurRadius: 8 + (_pulseAnimation.value * 8),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.auto_awesome,
                        color: AppTheme.surfaceWhite,
                        size: 20,
                      ),
                    ),
                    // Shimmer overlay
                    Positioned.fill(
                      child: ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(-1.0 + _shimmerAnimation.value * 2, 0.0),
                              end: Alignment(-0.5 + _shimmerAnimation.value * 2, 0.0),
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Thinking bubble with animated content
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.surfaceWhite,
                      Color.lerp(
                        AppTheme.surfaceWhite, 
                        AppTheme.accentLight, 
                        _pulseAnimation.value * 0.1
                      )!,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: AppTheme.primaryTeal.withOpacity(0.05 + (_pulseAnimation.value * 0.1)),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: AppTheme.primaryTeal.withOpacity(0.1 + (_pulseAnimation.value * 0.1)),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated thinking dots
                    ...List.generate(3, (index) {
                      final delay = index * 0.3;
                      final opacity = math.sin((_shimmerController.value + delay) * 2 * math.pi).abs();
                      final scale = 0.8 + (opacity * 0.4);
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryTeal.withOpacity(0.4 + (opacity * 0.6)),
                                  const Color(0xFF9C27B0).withOpacity(0.3 + (opacity * 0.4)),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                    
                    const SizedBox(width: 12),
                    
                    // "Thinking..." text with fade animation
                    AnimatedOpacity(
                      opacity: 0.6 + (_pulseAnimation.value * 0.4),
                      duration: const Duration(milliseconds: 200),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            AppTheme.primaryTeal.withOpacity(0.8),
                            const Color(0xFF9C27B0).withOpacity(0.6),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Thinking...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.surfaceWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

