import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      imagePath: 'assets/images/online course.png',
      title: 'Learn and Upskill as You Want',
      description: 'Access thousands of courses and learn at your own pace',
    ),
    _OnboardingData(
      imagePath: 'assets/images/teacher chat.png',
      title: 'Direct Connection',
      description:
          'Dive into rich course materials and connect directly with expert teachers for support.',
    ),
    _OnboardingData(
      imagePath: 'assets/images/chatbot gif.gif',
      title: 'AI Learning Assistant',
      description:
          'Get Instant Module Summaries, Practice with Auto-Generated Quizzes, and Ask for Clarifications Anytime',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start initial animations
    _startPageAnimations();
  }

  void _startPageAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _scaleController.reset();

    _fadeController.forward();
    _slideController.forward();

    Future.delayed(const Duration(milliseconds: 150), () {
      _scaleController.forward();
    });
  }

  void _onSkip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: Curves.ease));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    // Reserve consistent space for dots + button overlay
    const double bottomOverlayReserve =
        120; // dots(16) + gap(24) + btn(64) + margin

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FB),
      body: SafeArea(
        child: Stack(
          children: [
            // Content pages with bottom padding to avoid overlap with controls
            Padding(
              padding: const EdgeInsets.only(bottom: bottomOverlayReserve),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  _startPageAnimations();
                },
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return _OnboardingPage(
                    imagePath: data.imagePath,
                    title: data.title,
                    description: data.description,
                    isLastPage: index == _pages.length - 1,
                    onSkip: _onSkip,
                    onNext: _onNext,
                    currentPage: _currentPage,
                    totalPages: _pages.length,
                    fadeAnimation: _fadeAnimation,
                    slideAnimation: _slideAnimation,
                    scaleAnimation: _scaleAnimation,
                    slideController: _slideController,
                    fadeController: _fadeController,
                  );
                },
              ),
            ),

            // Dots indicator and navigation button at the bottom (overlay)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24 + bottomSafe,
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DotsIndicator(
                            currentIndex: _currentPage,
                            count: _pages.length,
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: _NavigationButton(
                                isLastPage: _currentPage == _pages.length - 1,
                                onPressed: _onNext,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String imagePath;
  final String title;
  final String description;
  const _OnboardingData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class _OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final bool isLastPage;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final int currentPage;
  final int totalPages;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> scaleAnimation;
  final AnimationController slideController;
  final AnimationController fadeController;

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.isLastPage,
    required this.onSkip,
    required this.onNext,
    required this.currentPage,
    required this.totalPages,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.scaleAnimation,
    required this.slideController,
    required this.fadeController,
  });

  @override
  Widget build(BuildContext context) {
    // Constrain max content width for larger screens
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: AnimatedBuilder(
                  animation: fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: fadeAnimation,
                      child: TextButton(
                        onPressed: onSkip,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFF087E8B),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Jost',
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              // Illustration with scale and fade animation
              AnimatedBuilder(
                animation: scaleAnimation,
                builder: (context, child) {
                  return ScaleTransition(
                    scale: scaleAnimation,
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.32,
                        child: Hero(
                          tag: 'onboarding_image_$currentPage',
                          child: Image.asset(imagePath, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Title with slide and fade animation
              AnimatedBuilder(
                animation: slideAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: slideAnimation,
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF22223B),
                            fontFamily: 'Jost',
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Description with delayed slide and fade animation
              AnimatedBuilder(
                animation: slideAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: slideController,
                            curve: const Interval(
                              0.3,
                              1.0,
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: fadeController,
                        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFF6C757D),
                            fontFamily: 'Jost',
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Reserve space for bottom overlay controls to keep visual balance
              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int currentIndex;
  final int count;
  const _DotsIndicator({required this.currentIndex, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF087E8B) : const Color(0xFFD1E3EA),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF087E8B).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

class _NavigationButton extends StatefulWidget {
  final bool isLastPage;
  final VoidCallback onPressed;
  const _NavigationButton({required this.isLastPage, required this.onPressed});

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start pulsing animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLastPage) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF087E8B).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                width: 200,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: const Color(0xFF087E8B),
                    elevation: 0,
                  ),
                  onPressed: widget.onPressed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Jost',
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF087E8B).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                width: 64,
                height: 64,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: const Color(0xFF087E8B),
                    elevation: 0,
                  ),
                  onPressed: widget.onPressed,
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
