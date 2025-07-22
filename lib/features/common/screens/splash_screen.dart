import 'package:flutter/material.dart';
import 'package:knowble_app/config/theme.dart';
import 'package:knowble_app/core/services/auth_manager.dart';

/// SplashScreen - Entry point of the app that shows logo animation and navigates to onboarding
/// Called from AppRoutes as the initial route ('/')
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startNavigationTimer();
  }

  /// Sets up logo animations and starts them
  /// Called from initState to initialize the splash screen animations
  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start logo animation
    _logoAnimationController.forward();
  }

  /// Starts a timer to navigate to onboarding after animation completes
  /// Called from initState to handle navigation timing
  void _startNavigationTimer() {
    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (mounted) {
        // After animation, check auth and route based on user role
        await AuthManager.handleInitialAuth(context);
      }
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: _buildSplashContent(constraints),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds the main splash screen content with logo and title
  /// Called from build method to display the splash screen UI
  Widget _buildSplashContent(BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedLogo(screenWidth),
                SizedBox(height: screenHeight * 0.04),
                _buildAppTitle(),
                SizedBox(height: screenHeight * 0.02),
                _buildSubtitle(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLoadingIndicator(screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.02),
                _buildLoadingText(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the animated logo widget using the logo 1 image
  /// Called from _buildSplashContent to display the app logo with scale and fade animations
  Widget _buildAnimatedLogo(double screenWidth) {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Opacity(
            opacity: _logoFadeAnimation.value,
            child: Container(
              width: screenWidth * 0.25,
              height: screenWidth * 0.25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                child: Image.asset(
                  'assets/images/logo 1.png',
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.25,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppTitle() {
    return AnimatedBuilder(
      animation: _logoFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _logoFadeAnimation.value,
          child: Text(
            'Knowble',
            style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontFamily: 'Jost',
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _logoFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _logoFadeAnimation.value * 0.8,
          child: Text(
            'Your Smart Learning Companion',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w400,
              fontFamily: 'Jost',
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator(double screenWidth, double screenHeight) {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Container(
          width: screenWidth * 0.6,
          height: screenHeight * 0.008,
          decoration: BoxDecoration(
            color: AppTheme.borderSubtle,
            borderRadius: BorderRadius.circular(screenHeight * 0.01),
          ),
          child: Stack(
            children: [
              Container(
                width: screenWidth * 0.6 * _logoAnimationController.value,
                height: screenHeight * 0.008,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal,
                  borderRadius: BorderRadius.circular(screenHeight * 0.01),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingText() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _logoAnimationController.value,
          child: Text(
            'Initializing...',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
