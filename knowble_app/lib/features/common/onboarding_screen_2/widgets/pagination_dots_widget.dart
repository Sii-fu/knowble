import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';

class PaginationDotsWidget extends StatefulWidget {
  final int currentIndex;
  final int totalDots;

  const PaginationDotsWidget({
    super.key,
    required this.currentIndex,
    required this.totalDots,
  });

  @override
  State<PaginationDotsWidget> createState() => _PaginationDotsWidgetState();
}

class _PaginationDotsWidgetState extends State<PaginationDotsWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animateCurrentDot();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.totalDots,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }).toList();
  }

  void _animateCurrentDot() {
    for (int i = 0; i < _controllers.length; i++) {
      if (i == widget.currentIndex) {
        _controllers[i].forward();
      } else {
        _controllers[i].reverse();
      }
    }
  }

  @override
  void didUpdateWidget(PaginationDotsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animateCurrentDot();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.totalDots,
          (index) => _buildDot(index),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final bool isActive = index == widget.currentIndex;

    return AnimatedBuilder(
      animation: _scaleAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimations[index].value,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 1.w),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: isActive ? 8.w : 3.w,
              height: isActive ? 2.h : 1.5.h,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryTeal : AppTheme.borderSubtle,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
