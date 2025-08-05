import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../widgets/custom_icon_widget.dart';

class SearchFilterWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(List<String>) onFiltersChanged;
  final List<String> activeFilters;

  const SearchFilterWidget({
    super.key,
    required this.onSearchChanged,
    required this.onFiltersChanged,
    required this.activeFilters,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _availableFilters = [
    'Complaint',
    'Bug',
    'Feature Request',
    'General Feedback',
    'Course',
    'Payment',
    'Instructor',
    'App UI',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search feedback...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'search',
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                GestureDetector(
                  onTap: _toggleExpansion,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: widget.activeFilters.isNotEmpty
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'filter_list',
                          size: 20,
                          color: widget.activeFilters.isNotEmpty
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        if (widget.activeFilters.isNotEmpty) ...[
                          SizedBox(width: 1.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 1.5.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${widget.activeFilters.length}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizeTransition(
            sizeFactor: _animation,
            child: Container(
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    height: 1,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Filter by Category',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: _availableFilters.map((filter) {
                      final isActive = widget.activeFilters.contains(filter);
                      return FilterChip(
                        label: Text(filter),
                        selected: isActive,
                        onSelected: (selected) {
                          final newFilters = List<String>.from(
                            widget.activeFilters,
                          );
                          selected
                              ? newFilters.add(filter)
                              : newFilters.remove(filter);
                          widget.onFiltersChanged(newFilters);
                        },
                        selectedColor: theme.colorScheme.primary.withValues(
                          alpha: 0.2,
                        ),
                        checkmarkColor: theme.colorScheme.primary,
                        labelStyle: theme.textTheme.labelSmall?.copyWith(
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        side: BorderSide(
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                      );
                    }).toList(),
                  ),
                  if (widget.activeFilters.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    TextButton.icon(
                      onPressed: () => widget.onFiltersChanged([]),
                      icon: CustomIconWidget(
                        iconName: 'clear',
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        'Clear All Filters',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
