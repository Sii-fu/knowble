import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'course_list_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _searchHistory = [
    'Graphic Design',
    'Web Development',
    'Photography',
    'Digital Marketing',
    'UI/UX Design',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.surfaceWhite,
          elevation: 0.5,
          shadowColor: AppTheme.shadowLight,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search courses...',
              hintStyle: TextStyle(color: AppTheme.textSecondary),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(Icons.search, color: AppTheme.primaryTeal),
                onPressed: () => _performSearch(),
              ),
            ),
            style: TextStyle(color: AppTheme.textPrimary),
            onSubmitted: (value) => _performSearch(),
          ),
        ),
        backgroundColor: AppTheme.backgroundLight,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Search',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _searchHistory.length,
                  separatorBuilder: (_, __) => Divider(
                    color: AppTheme.borderSubtle,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final searchTerm = _searchHistory[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.history,
                        color: AppTheme.textSecondary,
                      ),
                      title: Text(
                        searchTerm,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchHistory.removeAt(index);
                          });
                        },
                      ),
                      onTap: () {
                        _searchController.text = searchTerm;
                        _performSearch();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      // Add to search history if not already present
      if (!_searchHistory.contains(query)) {
        setState(() {
          _searchHistory.insert(0, query);
        });
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseListPage(searchQuery: query),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
