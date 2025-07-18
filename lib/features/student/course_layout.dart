import 'package:flutter/material.dart';
import '../../config/theme.dart';

enum CourseTab { all, ongoing, completed }

class CourseLayout extends StatefulWidget {
  final String title;
  final Widget Function(CourseTab selectedTab) bodyBuilder;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CourseLayout({
    super.key,
    required this.title,
    required this.bodyBuilder,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  State<CourseLayout> createState() => _CourseLayoutState();
}

class _CourseLayoutState extends State<CourseLayout> {
  CourseTab _selectedTab = CourseTab.all;

  void _onTabSelected(CourseTab tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBar(
                  title: widget.title,
                  showBackButton: widget.showBackButton,
                  onBackPressed: widget.onBackPressed,
                ),
                const SizedBox(height: 16),
                const SearchBox(),
                const SizedBox(height: 20),
                FilterTabs(
                  selectedTab: _selectedTab,
                  onTabSelected: _onTabSelected,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: widget.bodyBuilder(_selectedTab),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const TopBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (showBackButton) ...[
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class SearchBox extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const SearchBox({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText ?? 'Search for ...',
                border: InputBorder.none,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.search,
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class FilterTabs extends StatelessWidget {
  final CourseTab selectedTab;
  final ValueChanged<CourseTab> onTabSelected;

  const FilterTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  String _getTabLabel(CourseTab tab) {
    switch (tab) {
      case CourseTab.all:
        return 'All';
      case CourseTab.ongoing:
        return 'Ongoing';
      case CourseTab.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: CourseTab.values.map((tab) {
          final isSelected = selectedTab == tab;
          return Padding(
            padding: EdgeInsets.only(
              right: tab != CourseTab.values.last ? 12 : 0,
            ),
            child: GestureDetector(
              onTap: () => onTabSelected(tab),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : AppTheme.accentLight,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    _getTabLabel(tab),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected 
                          ? theme.colorScheme.onPrimary 
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Example usage widgets for different tab content
class AllCoursesContent extends StatelessWidget {
  const AllCoursesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('All Courses Content'),
    );
  }
}

class OngoingCoursesContent extends StatelessWidget {
  const OngoingCoursesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Ongoing Courses Content'),
    );
  }
}

class CompletedCoursesContent extends StatelessWidget {
  const CompletedCoursesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Completed Courses Content'),
    );
  }
}
