# YouTube Video Player Integration

This document describes the new YouTube video player integration for the Knowble app, which allows students to watch YouTube videos with custom controls and quiz integration.

## Features

### 🎥 Video Player Features
- **YouTube Video Playback**: Supports any YouTube video URL
- **Custom Controls**: Play/pause, seek, rewind/forward 10 seconds
- **Playback Speed Control**: 0.25x to 2x speed options
- **Fullscreen Support**: Toggle fullscreen mode with orientation control
- **Progress Tracking**: Visual progress bar with time display
- **Error Handling**: Graceful handling of invalid URLs and loading errors

### 📝 Quiz Integration
- **Automatic Triggers**: Quizzes can be triggered at specific video progress points (25%, 50%, 75%)
- **Manual Quiz Access**: Students can manually take quizzes via the "Take Quiz" button
- **Pause on Quiz**: Video automatically pauses when quiz overlay appears
- **Result Feedback**: Visual feedback for quiz completion and results
- **Resume Playback**: Video resumes after successful quiz completion

### 🤖 AI Assistant Integration
- **Content-Aware**: AI assistant has access to the current video content
- **Course Context**: Integrated with course and section information
- **Easy Access**: Direct button to open AI chat while watching videos

## Implementation Details

### Files Created/Modified

1. **`lib/features/student/video_player_page.dart`** - Main video player page
2. **`lib/features/student/quiz/video_quiz_overlay.dart`** - Quiz overlay component
3. **`lib/features/demo/video_player_demo.dart`** - Demo page for testing
4. **`lib/core/services/student/course_services.dart`** - Added assessment fetching
5. **`lib/data/models/assessment.dart`** - Updated to include sectionId
6. **`lib/features/student/courses_lessons.dart`** - Added video content support
7. **`pubspec.yaml`** - Added youtube_player_flutter package

### Dependencies Added
```yaml
youtube_player_flutter: ^8.1.2
```

## Usage

### In Course Content
When content type is `'video'` or `'youtube'`, the system will automatically route to the video player page:

```dart
// Content type examples in database:
{
  "type": "video",
  "url": "https://www.youtube.com/watch?v=VIDEO_ID",
  "title": "Lesson Title",
  "section_id": "section_uuid"
}
```

### Video Player Controls
- **Play/Pause**: Tap the center play button or use custom controls
- **Seek**: Drag the progress slider or use 10s rewind/forward buttons
- **Speed**: Tap the speed icon to select playback rate (0.25x - 2x)
- **Fullscreen**: Tap fullscreen icon to toggle fullscreen mode
- **Quiz**: Tap "Take Quiz" button to manually trigger quiz
- **AI Assistant**: Tap "AI Assistant" for content-related help

### Quiz System
1. Quizzes are fetched from the `assessments` table based on `section_id`
2. Automatic triggers can be configured at video progress milestones
3. Quiz overlay appears with animated entrance
4. Students must complete quiz to continue video
5. Results are shown before returning to video playback

## Database Schema Support

The video player integrates with existing database tables:

### Contents Table
```sql
CREATE TABLE contents (
  id uuid PRIMARY KEY,
  section_id uuid REFERENCES sections(id),
  type varchar, -- 'video', 'pdf', 'youtube'
  title text,
  url text, -- YouTube URL for video content
  order integer
);
```

### Assessments Table
```sql
CREATE TABLE assessments (
  id uuid PRIMARY KEY,
  section_id uuid REFERENCES sections(id),
  title text,
  type varchar,
  total_marks integer
);
```

## Testing

### Demo Page
A demo page is available at `lib/features/demo/video_player_demo.dart` with sample YouTube videos for testing all features.

### Sample Video URLs
- Flutter Basics: `https://www.youtube.com/watch?v=1ukSR1GRtMU`
- Dart Programming: `https://www.youtube.com/watch?v=Ej_Pcr4uC2Q`
- Widget Deep Dive: `https://www.youtube.com/watch?v=wE7khGHVkYY`

## Error Handling

### Invalid URLs
- Detects invalid YouTube URLs and shows error message
- Graceful fallback with "Go Back" option

### Network Issues
- Loading indicators during video initialization
- Error messages for connectivity problems

### Quiz Errors
- Fallback message when no quizzes are available
- Graceful handling of quiz loading failures

## Future Enhancements

### Potential Improvements
1. **Video Progress Tracking**: Save and resume video progress
2. **Offline Support**: Download videos for offline viewing
3. **Captions/Subtitles**: Enhanced caption support
4. **Note Taking**: In-video note taking functionality
5. **Social Features**: Video comments and discussions
6. **Analytics**: Video watch time and engagement metrics

### Quiz Enhancements
1. **Question Types**: Support for multiple question types
2. **Adaptive Quizzes**: Dynamic quiz difficulty based on performance
3. **Detailed Results**: Show correct answers and explanations
4. **Progress Requirements**: Require minimum quiz scores to proceed

## Integration with Existing System

### Course Navigation
The video player integrates seamlessly with the existing course structure:
- Maintains course and section context
- Preserves navigation state
- Supports back navigation to course content

### AI Chatbot Integration
- Content ID and course ID are passed to chatbot
- AI can reference current video content in responses
- Seamless transition between video and chat

### User Experience
- Consistent UI/UX with existing app design
- Uses established theme colors and typography
- Maintains app navigation patterns

## Troubleshooting

### Common Issues
1. **Video won't load**: Check YouTube URL format and network connectivity
2. **Fullscreen not working**: Ensure proper orientation permissions
3. **Quiz not showing**: Verify assessments exist for the section
4. **Controls not responsive**: Check for UI state conflicts

### Debug Information
- Console logging for video state changes
- Error logging for failed operations
- Network request logging for troubleshooting