// reminder.dart
// Reminder model for Knowble, matching the reminders table in the database.

class Reminder {
  final String id;                    // Primary key (UUID)
  final String userId;               // User who created the reminder
  final String? courseId;            // Optional course association (made optional)
  final String title;                // Reminder title
  final String? description;         // Optional detailed description
  final DateTime time;               // Start date and time combined
  final DateTime? endTime;           // End date and time combined (optional)
  final String? createdBy;
  final String priority;            // Priority level (e.g., 'High', 'Medium', 'Low')          

  // Constructor with required and optional parameters
  Reminder({
    required this.id,
    required this.userId,
    this.courseId,                   // Made optional since not all tasks need a course
    required this.title,
    this.description,                // Optional description
    required this.time,              // Start date + time (required)
    this.endTime,                    // End date + time (optional for tasks without duration)
    this.createdBy,
    required this.priority,                  // Priority level (optional, defaults to 'Medium')
  });

  // Factory constructor to create Reminder from Supabase response (Map)
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] ?? '',                                    // Get ID or empty string
      userId: map['user_id'] ?? '',                           // Get user ID or empty string
      courseId: map['course_id'],                             // Can be null
      title: map['title'] ?? '',                              // Get title or empty string
      description: map['description'],                        // Can be null
      time: DateTime.parse(map['time']),                      // Parse start date+time string to DateTime
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null, // Parse end date+time if exists
      createdBy: map['created_by'], 
      priority: map['priority'] ?? 'Medium', // Get priority or default to 'Medium'
    );
  }

  // Convert Reminder object to Map for sending to Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,                                              // Include ID for updates
      'user_id': userId,                                     // User who owns this reminder
      'course_id': courseId,                                 // Optional course reference
      'title': title,                                        // Reminder title
      'description': description,                            // Optional description
      'time': time.toIso8601String(),                       // Convert DateTime to ISO string (includes date + time)
      'end_time': endTime?.toIso8601String(),               // Convert end DateTime if exists (includes date + time)
      'created_by': createdBy,   
      'priority': priority               // Priority level with default
    };
  }

  // Create a copy of the reminder with updated fields (for editing)
  Reminder copyWith({
    String? id,
    String? userId,
    String? courseId,
    String? title,
    String? description,
    DateTime? time,
    DateTime? endTime,
    String? createdBy,
    String? priority,                    // Add this parameter
  }) {
    return Reminder(
      id: id ?? this.id,                                     // Use new ID or keep existing
      userId: userId ?? this.userId,                         // Use new user ID or keep existing
      courseId: courseId ?? this.courseId,                   // Use new course ID or keep existing
      title: title ?? this.title,                            // Use new title or keep existing
      description: description ?? this.description,          // Use new description or keep existing
      time: time ?? this.time,                              // Use new time or keep existing
      endTime: endTime ?? this.endTime,                     // Use new end time or keep existing
      createdBy: createdBy ?? this.createdBy,               // Use new createdBy or keep existing
      priority: priority ?? this.priority,                  // Add this line
    );
  }



  // Getter for formatted time display (HH:MM)
  String get formattedStartTime {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Getter for formatted end time display (HH:MM)
  String get formattedEndTime {
    if (endTime == null) return '';
    return '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
  }

  // Getter for formatted date display (Month Day, Year)
  String get formattedDate {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[time.month - 1]} ${time.day}, ${time.year}';
  }

  // Getter for time range display (9:00 AM - 10:30 AM)
  String get timeRange {
    final startTime = formattedStartTime;
    if (endTime == null) return startTime;
    return '$startTime - $formattedEndTime';
  }

  // Check if reminder has a course associated
  bool get hasCourse => courseId != null && courseId!.isNotEmpty;

  // Get duration in minutes (if end time exists)
  int? get durationInMinutes {
    if (endTime == null) return null;
    return endTime!.difference(time).inMinutes;
  }

  // Check if reminder is for today
  bool get isToday {
    final now = DateTime.now();
    return time.year == now.year && time.month == now.month && time.day == now.day;
  }

  // Check if reminder is for a specific date
  bool isOnDate(DateTime date) {
    return time.year == date.year && time.month == date.month && time.day == date.day;
  }

  // Get just the date part (without time)
  DateTime get dateOnly {
    return DateTime(time.year, time.month, time.day);
  }
}
