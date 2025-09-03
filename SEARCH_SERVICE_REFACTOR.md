# Search Service Refactor

## Overview
The search service has been refactored to use the new `course_search_view` database view for improved performance and cleaner code.

## Database View
The `course_search_view` aggregates data from multiple tables:
- `courses` (main table)
- `users` (for instructor names)
- `course_reviews` (for avg_rating and students_count)
- `course_tags` + `tags` (for tag names array)

## Key Changes

### 1. **Simplified Query Structure**
- **Before**: Complex joins with nested selects and client-side aggregation
- **After**: Simple `SELECT *` from `course_search_view`

### 2. **Server-Side Filtering**
All filters are now applied in the SQL query:
- Text search: `title.ilike.%query%,description.ilike.%query%`
- Tag filtering: `tags.contains([tagName])`
- Price filters: `price.gte(min)`, `price.lte(max)`, `is_paid.eq(false)`
- Duration filters: `duration_days.gte(min)`, `duration_days.lte(max)`
- Rating filter: `avg_rating.gte(minRating)` ✨ **NEW!**

### 3. **Accurate Sorting & Pagination**
- **Before**: Rating sort was client-side, pagination was inaccurate for rating filters
- **After**: All sorting (including rating) happens server-side with accurate pagination

### 4. **Performance Improvements**
- No client-side aggregation of reviews
- No nested loops processing tags
- Single query execution per search
- Reduced data transfer

## Usage Examples

```dart
final searchService = SearchService();

// Text search with rating filter (now server-side!)
final courses = await searchService.searchCourses(
  query: 'flutter',
  minRating: 4.0,
  sortBy: 'rating',
  limit: 10,
);

// Tag-based search
final courses = await searchService.searchCourses(
  tagId: 'programming-tag-id',
  sortBy: 'newest',
);

// Price range with duration filter
final courses = await searchService.searchCourses(
  minPrice: 50.0,
  maxPrice: 200.0,
  durationMin: 30,
  sortBy: 'price_low',
);
```

## Methods Updated

1. **`searchCourses()`** - Complete rewrite using `course_search_view`
2. **`getCourseById()`** - Now uses the view for consistency
3. **`getCategoriesWithCounts()`** - Improved efficiency with better error handling

## Testing

Run the tests to verify the Course model works correctly:

```bash
flutter test test/search_service_test.dart
```

## Migration Notes

- Ensure the `course_search_view` is created in your database
- The view includes only visible reviews (`is_visible = true`)
- Tags are returned as a PostgreSQL array, automatically handled by Supabase
- All aggregated fields (avg_rating, students_count) are pre-computed

## Benefits

✅ **Better Performance**: Single query vs multiple joins  
✅ **Accurate Pagination**: Server-side filtering and sorting  
✅ **Cleaner Code**: No manual aggregation logic  
✅ **Consistent Results**: Same data structure for search and single course fetch  
✅ **Server-Side Rating Filter**: No more client-side filtering causing incomplete pages
