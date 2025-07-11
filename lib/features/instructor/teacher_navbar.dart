// teacher_navbar.dart

import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.home_outlined,
      Icons.menu_book_outlined,
      Icons.chat_bubble_outline,
      Icons.person_outline,
    ];

    final labels = ["HOME", "COURSES", "INBOX", "PROFILE"];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(color: Color(0xFFF8FAFD)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (index) {
          final isActive = currentIndex == index;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: isActive
                    ? BoxDecoration(
                        color: Colors.teal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icons[index],
                      color: isActive ? Colors.teal : Colors.black87,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isActive ? Colors.teal : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isActive)
                      Container(
                        height: 4,
                        width: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    else
                      const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
