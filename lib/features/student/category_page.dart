import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'course_list_page.dart';
import 'search_page.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  // Sample categories data
  final List<CategoryItem> _categories = const [
    CategoryItem('3D Design', Icons.view_in_ar),
    CategoryItem('Web Development', Icons.web),
    CategoryItem('Finance & Accounting', Icons.account_balance),
    CategoryItem('Mobile Development', Icons.smartphone),
    CategoryItem('Graphic Design', Icons.design_services),
    CategoryItem('Data Science', Icons.analytics),
    CategoryItem('Marketing', Icons.campaign),
    CategoryItem('Photography', Icons.camera_alt),
    CategoryItem('Music', Icons.music_note),
    CategoryItem('Business', Icons.business),
    CategoryItem('Art & Design', Icons.palette),
    CategoryItem('Programming', Icons.code),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'All Category',
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
        ),
        backgroundColor: AppTheme.backgroundLight,
        body: Column(
          children: [
            // Search TextField
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.borderSubtle,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchPage(),
                    ),
                  );
                },
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Search for...',
                  hintStyle: TextStyle(color: AppTheme.textSecondary),
                  prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            
            // Categories Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _CategoryCard(
                      category: category,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseListPage(
                              searchQuery: category.name,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryItem category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderSubtle,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.accentLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                category.icon,
                color: AppTheme.primaryTeal,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                category.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryItem {
  final String name;
  final IconData icon;

  const CategoryItem(this.name, this.icon);
}
