import 'package:flutter/material.dart';
import '../../config/theme.dart';

class FilterPage extends StatefulWidget {
  final Map<String, dynamic>? currentFilters;

  const FilterPage({
    super.key,
    this.currentFilters,
  });

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  Map<String, List<String>> _selectedFilters = {
    'subcategories': [],
    'levels': [],
    'price': [],
  };

  final Map<String, List<String>> _filterOptions = {
    'subcategories': [
      '3D Design',
      'Web Development',
      '3D Animation',
      'Graphic Design',
      'UI/UX Design',
      'Mobile Development',
      'Digital Marketing',
      'Photography',
    ],
    'levels': [
      'All Levels',
      'Beginners',
      'Intermediate',
      'Advanced',
    ],
    'price': [
      'Paid',
      'Free',
    ],
  };

  @override
  void initState() {
    super.initState();
    if (widget.currentFilters != null) {
      _selectedFilters = Map<String, List<String>>.from(
        widget.currentFilters!.map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Filter',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: AppTheme.surfaceWhite,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0.5,
          shadowColor: AppTheme.shadowLight,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: _clearAllFilters,
              child: Text(
                'Clear',
                style: TextStyle(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.backgroundLight,
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _FilterSection(
                    title: 'SubCategories',
                    options: _filterOptions['subcategories']!,
                    selectedOptions: _selectedFilters['subcategories']!,
                    onChanged: (selected) {
                      setState(() {
                        _selectedFilters['subcategories'] = selected;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'Levels',
                    options: _filterOptions['levels']!,
                    selectedOptions: _selectedFilters['levels']!,
                    onChanged: (selected) {
                      setState(() {
                        _selectedFilters['levels'] = selected;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'Price',
                    options: _filterOptions['price']!,
                    selectedOptions: _selectedFilters['price']!,
                    onChanged: (selected) {
                      setState(() {
                        _selectedFilters['price'] = selected;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // Apply Filters Button
            Container(
              padding: const EdgeInsets.all(16),
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
                  child: Text(
                    'Apply Filters',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.surfaceWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilters = {
        'subcategories': [],
        'levels': [],
        'price': [],
      };
    });
  }

  void _applyFilters() {
    Navigator.pop(context, _selectedFilters);
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<String> selectedOptions;
  final Function(List<String>) onChanged;

  const _FilterSection({
    required this.title,
    required this.options,
    required this.selectedOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderSubtle,
              width: 1,
            ),
          ),
          child: Column(
            children: options.map((option) {
              final isSelected = selectedOptions.contains(option);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (bool? value) {
                  List<String> updatedSelection = List.from(selectedOptions);
                  if (value == true) {
                    updatedSelection.add(option);
                  } else {
                    updatedSelection.remove(option);
                  }
                  onChanged(updatedSelection);
                },
                title: Text(
                  option,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                activeColor: AppTheme.primaryTeal,
                checkColor: AppTheme.surfaceWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
