# Feedback System Implementation

This document describes the complete feedback system implementation for the Knowble app using direct Supabase integration.

## Overview

The feedback system allows users to submit feedback and issues to administrators, with proper categorization, status tracking, and user authentication. The implementation uses Supabase Flutter client directly without needing separate API endpoints.

## Database Structure

### Table: `feedback_issues`

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key (auto-generated) |
| `user_id` | UUID | Foreign key to users table (NOT NULL) |
| `user_role` | TEXT | User role at submission time |
| `type` | TEXT | Feedback type (Bug Report, Feature Request, etc.) |
| `category` | TEXT | Feedback category (UI, Content, Performance, etc.) |
| `message` | TEXT | The feedback message content |
| `status` | TEXT | Current status (submitted, in_review, in_progress, resolved, closed) |
| `submitted_at` | TIMESTAMPTZ | When feedback was submitted |
| `resolved_at` | TIMESTAMPTZ | When feedback was resolved (nullable) |
| `admin_notes` | TEXT | Notes added by administrators (nullable) |

## Database Setup

1. Run the SQL commands in your Supabase SQL Editor:
   ```sql
   -- File: feedback_system_setup.sql
   -- Contains table creation and RLS policies
   ```

2. The script will create:
   - `feedback_issues` table with proper constraints
   - Row Level Security (RLS) policies
   - Proper user permissions

## Flutter Service Integration

### FeedbackService Class

The `FeedbackService` class provides methods for:

- `submitFeedback()` - Submit new feedback
- `getFeedbackHistory()` - Get user's feedback history
- `getFeedbackStats()` - Get feedback statistics
- `getCurrentUserInfo()` - Get current user information
- `canSubmitFeedback()` - Check rate limiting

### Usage Example

```dart
// Create service instance
final feedbackService = FeedbackService();

// Submit feedback
final errorMessage = await feedbackService.submitFeedback(
  type: 'Bug Report',
  category: 'User Interface',
  message: 'Button not working properly',
);

if (errorMessage == null) {
  // Success
  print('Feedback submitted successfully');
} else {
  // Error
  print('Error: $errorMessage');
}

// Get feedback history
final feedbackList = await feedbackService.getFeedbackHistory(
  limit: 20,
  status: 'submitted',
);

// Get user stats
final stats = await feedbackService.getFeedbackStats();
print('Total feedback: ${stats.values.fold(0, (a, b) => a + b)}');
```

### Feedback Model

The `Feedback` model represents the feedback data structure with methods for:

- `fromMap()` - Create from database response
- `toMap()` - Convert to database format
- `formattedSubmittedAt` - Get formatted date
- `isResolved` - Check if feedback is resolved
- `statusColor` - Get status color for UI
- `priority` - Get feedback priority level

## Security Features

### Row Level Security (RLS)
- Users can only view/edit their own feedback
- Admins can view/edit all feedback
- Automatic user_id validation

### Rate Limiting
- Users can only submit feedback once every 5 minutes
- Prevents spam and abuse

### Input Validation
- Required fields validation
- Message length limits
- Type and category validation

## Feedback Types and Categories

### Available Types:
- Bug Report
- Feature Request  
- General Feedback
- User Experience
- Performance Issue
- Content Issue
- Other

### Available Categories:
- User Interface
- Course Content
- Video Quality
- Audio Quality
- Navigation
- Performance
- Mobile App
- Web Platform
- Instructor Tools
- Student Experience
- Payment & Billing
- Technical Support
- Other

## Status Workflow

1. **submitted** - Initial status when feedback is created
2. **in_review** - Admin is reviewing the feedback
3. **in_progress** - Admin is working on resolving the issue
4. **resolved** - Issue has been fixed/addressed
5. **closed** - Feedback is closed (no further action needed)

## Error Handling

The system handles various error scenarios:

- Authentication errors
- Authorization errors 
- Validation errors
- Rate limiting
- Database errors
- Network timeouts

## Admin Management

For admin functionality, you can create additional methods in the service or create a separate admin service that:

- Fetches all feedback with user details
- Updates feedback status and admin notes
- Filters feedback by status, type, category

Example admin queries:
```dart
// Get all feedback (admin only)
final adminQuery = supabase
    .from('feedback_issues')
    .select('*, users(name, email)')
    .order('submitted_at', ascending: false);

// Update feedback status
await supabase
    .from('feedback_issues')
    .update({
      'status': 'resolved',
      'admin_notes': 'Fixed in version 1.2.0',
      'resolved_at': DateTime.now().toIso8601String(),
    })
    .eq('id', feedbackId);
```

## Performance Optimizations

- Efficient RLS policies
- Proper error handling and logging
- Rate limiting to prevent abuse
- Pagination for large result sets

## Integration Checklist

- [x] Run SQL setup script in Supabase
- [x] Create FeedbackService in Flutter app
- [x] Create Feedback model
- [x] Update feedback form to use service
- [x] Test feedback submission flow
- [ ] Create admin interface (optional)
- [ ] Test rate limiting
- [ ] Verify RLS policies work correctly

## Troubleshooting

### Common Issues:

1. **Authentication Error**: Ensure user is logged in
2. **Rate Limiting**: Wait 5 minutes between submissions
3. **Permission Denied**: Check RLS policies and user authentication
4. **Database Connection**: Verify Supabase connection settings

### Debug Mode:
Enable debug logging in the Flutter service by checking the console output for detailed error messages.

## Support

For issues with the feedback system implementation, check:
1. Supabase logs for database errors
2. Flutter console for client errors  
3. Network connectivity and authentication status
