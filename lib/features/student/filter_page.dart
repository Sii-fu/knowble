import 'package:flutter/material.dart';
import '../../config/theme.dart';

class FilterPage extends StatefulWidget {
  final Map<String, dynamic> activeFilters;

  const FilterPage({
    super.key,
    required this.activeFilters,
  });

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late Map<String, dynamic> _filters;
  
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _durations = ['< 5 hours', '5-10 hours', '10-20 hours', '20+ hours'];
  final List<String> _categories = ['Programming', 'Design', 'Mathematics', 'Science', 'Business'];

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.activeFilters);
    
    // Initialize default values if not present
    _filters['level'] ??= '';
    _filters['duration'] ??= '';
    _filters['category'] ??= '';
    _filters['priceRange'] ??= const RangeValues(0, 200);
    _filters['rating'] ??= 0.0;
    _filters['freeOnly'] ??= false;
  }

  void _clearAllFilters() {
    setState(() {
      _filters = {
        'level': '',
        'duration': '',
        'category': '',
        'priceRange': const RangeValues(0, 200),
        'rating': 0.0,
        'freeOnly': false,
      };
    });
  }

  void _applyFilters() {
    // Remove empty filters
    final cleanedFilters = Map<String, dynamic>.from(_filters);
    cleanedFilters.removeWhere((key, value) {
      if (value is String) return value.isEmpty;
      if (value is bool) return !value;
      if (value is double) return value == 0.0;
      return false;
    });
    
    Navigator.pop(context, cleanedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: _clearAllFilters,
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Level Filter
                      _buildSectionTitle('Level'),
                      _buildChipSelection(
                        options: _levels,
                        selectedValue: _filters['level'],
                        onChanged: (value) {
                          setState(() {
                            _filters['level'] = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Category Filter
                      _buildSectionTitle('Category'),
                      _buildChipSelection(
                        options: _categories,
                        selectedValue: _filters['category'],
                        onChanged: (value) {
                          setState(() {
                            _filters['category'] = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Duration Filter
                      _buildSectionTitle('Duration'),
                      _buildChipSelection(
                        options: _durations,
                        selectedValue: _filters['duration'],
                        onChanged: (value) {
                          setState(() {
                            _filters['duration'] = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Price Range Filter
                      _buildSectionTitle('Price Range'),
                      _buildPriceRangeSlider(),
                      const SizedBox(height: 24),

                      // Rating Filter
                      _buildSectionTitle('Minimum Rating'),
                      _buildRatingSlider(),
                      const SizedBox(height: 24),

                      // Free Only Toggle
                      _buildFreeOnlyToggle(),
                      const SizedBox(height: 100), // Extra space for the apply button
                    ],
                  ),
                ),
              ),

              // Apply Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.borderSubtle,
                      width: 1,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: AppTheme.surfaceWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildChipSelection({
    required List<String> options,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return GestureDetector(
          onTap: () {
            onChanged(isSelected ? '' : option);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryTeal : AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.primaryTeal : AppTheme.borderSubtle,
                width: 1,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? AppTheme.surfaceWhite : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeSlider() {
    final RangeValues currentRange = _filters['priceRange'];
    return Column(
      children: [
        RangeSlider(
          values: currentRange,
          min: 0,
          max: 200,
          divisions: 20,
          activeColor: AppTheme.primaryTeal,
          inactiveColor: AppTheme.borderSubtle,
          onChanged: (RangeValues values) {
            setState(() {
              _filters['priceRange'] = values;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${currentRange.start.round()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '\$${currentRange.end.round()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSlider() {
    final double currentRating = _filters['rating'];
    return Column(
      children: [
        Slider(
          value: currentRating,
          min: 0,
          max: 5,
          divisions: 10,
          activeColor: AppTheme.primaryTeal,
          inactiveColor: AppTheme.borderSubtle,
          onChanged: (double value) {
            setState(() {
              _filters['rating'] = value;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppTheme.warningAmber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currentRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '& above',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFreeOnlyToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Free Courses Only',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Show only free courses',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          Switch(
            value: _filters['freeOnly'],
            onChanged: (bool value) {
              setState(() {
                _filters['freeOnly'] = value;
              });
            },
            activeColor: AppTheme.primaryTeal,
          ),
        ],
      ),
    );
  }
}
