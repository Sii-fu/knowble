import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FB),
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
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
                );
              },
            ),
            // Dots indicator and navigation button at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: size.height * 0.08,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DotsIndicator(
                    currentIndex: _currentPage,
                    count: _pages.length,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: _NavigationButton(
                      isLastPage: _currentPage == _pages.length - 1,
                      onPressed: _onNext,
                    ),
                  ),
                ],
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

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.isLastPage,
    required this.onSkip,
    required this.onNext,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Skip button
          Align(
            alignment: Alignment.topRight,
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
          ),
          SizedBox(height: size.height * 0.04),
          // Illustration (use Image.asset for gif as well)
          SizedBox(
            height: size.height * 0.35,
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          SizedBox(height: size.height * 0.06),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF22223B),
              fontFamily: 'Jost',
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16.0,
              color: Color(0xFF6C757D),
              fontFamily: 'Jost',
            ),
          ),
          const Spacer(),
        ],
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
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 14 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF087E8B) : const Color(0xFFD1E3EA),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final bool isLastPage;
  final VoidCallback onPressed;
  const _NavigationButton({required this.isLastPage, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (isLastPage) {
      return SizedBox(
        width: 180,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: const Color(0xFF087E8B),
            elevation: 4,
          ),
          onPressed: onPressed,
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
              Icon(Icons.arrow_forward, color: Colors.white, size: 24),
            ],
          ),
        ),
      );
    } else {
      return SizedBox(
        width: 64,
        height: 64,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: const Color(0xFF087E8B),
            elevation: 4,
          ),
          onPressed: onPressed,
          child: const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
        ),
      );
    }
  }
}
