import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/theme.dart';

class InstructorProfilePage extends StatefulWidget {
  final String instructorId;
  final String instructorName;
  final String? profileImage;
  final String? courseId;

  const InstructorProfilePage({
    super.key,
    required this.instructorId,
    required this.instructorName,
    this.profileImage,
    this.courseId,
  });

  @override
  State<InstructorProfilePage> createState() => _InstructorProfilePageState();
}

class _InstructorProfilePageState extends State<InstructorProfilePage> {
  Map<String, dynamic>? _instructor;
  Map<String, dynamic>? _instructorInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInstructor();
  }

  Future<void> _loadInstructor() async {
    setState(() => _loading = true);
    try {
      final userData = await Supabase.instance.client
          .from('users')
          .select('id, name, email, profile_pic, bio, is_verified')
          .eq('id', widget.instructorId)
          .maybeSingle();

      // fetch instructor_info row if present
      final infoData = await Supabase.instance.client
          .from('instructor_info')
          .select('phone_number, education_degree, teaching_experience, current_location, subject_expertise, bio, cv_file_name, cv_file_path, verification_status, submitted_at, verified_at')
          .eq('user_id', widget.instructorId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _instructor = userData; // maybeSingle returns Map<String,dynamic> or null
          _instructorInfo = infoData; // may be null if instructor hasn't submitted profile
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _instructor = null;
          _loading = false;
        });
      }
      debugPrint('Failed to load instructor: $e');
    }
  }

  Future<void> _reportInstructor() async {
  final TextEditingController _reasonController = TextEditingController();

  final result = await showDialog<bool?>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white, // white bg
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // softer look
      ),
      title: Text(
        'Report Instructor',
        style: TextStyle(
          color: AppTheme.primaryTeal, // teal title
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please describe the issue. Our team will review the report.', style: TextStyle(color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            maxLines: 4,
            style: TextStyle(color: AppTheme.textPrimary),
            cursorColor: AppTheme.textPrimary,
            decoration: InputDecoration(
              hintText: 'Reason for reporting...',
              hintStyle: TextStyle(color: AppTheme.textPrimary.withOpacity(0.7)),
              filled: true,
              fillColor: AppTheme.accentLight, // subtle gray fill
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryTeal),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryTeal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            final reason = _reasonController.text.trim();
            if (reason.isEmpty) return; // keep dialog open
            Navigator.of(context).pop(true);
          },
          child: const Text('Send Report'),
        ),
      ],
    ),
  );

  if (result != true) return;

  // ... keep your existing DB insert logic ...

    final reason = _reasonController.text.trim();
    final reporterId = Supabase.instance.client.auth.currentUser?.id;
    if (reporterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to report.')));
      return;
    }

    try {
      // Try to get the reporting user's role (fallback to 'student')
      String userRole = 'student';
      try {
        final userData = await Supabase.instance.client
            .from('users')
            .select('role')
            .eq('id', reporterId)
            .maybeSingle();
        if (userData != null && userData['role'] != null) {
          userRole = userData['role'] as String;
        }
      } catch (_) {
        // ignore and keep fallback
      }

      // Insert into feedback_issues table according to the provided schema
      await Supabase.instance.client.from('feedback_issues').insert({
        'user_id': reporterId,
        'user_role': userRole,
        'type': 'report', // set the type to report as requested
        'category': 'chat', // set category to chat for these reports
        'message': reason,
        // status and submitted_at default are handled by the DB
      });

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted. Thank you.')));
    } catch (e) {
      debugPrint('Failed to submit report: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit report.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
  final name = _instructor?['name'] ?? widget.instructorName;
  final email = _instructor?['email'] ?? '';
  final bio = _instructor?['bio'] ?? '';
  final verified = _instructor?['is_verified'] == true;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis)
        ),
    body: _loading
      ? Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: widget.profileImage != null ? NetworkImage(widget.profileImage!) : null,
                          backgroundColor: AppTheme.accentLight,
                          child: widget.profileImage == null ? Icon(Icons.person, color: AppTheme.primaryTeal, size: 36) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(email, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                              const SizedBox(height: 6),
                              if (verified)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.verified, size: 14, color: AppTheme.primaryTeal), const SizedBox(width: 6), const Text('Verified')]),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('About', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(bio.isNotEmpty ? bio : 'No biography provided.', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 18),
                    if (_instructorInfo != null) ...[
                      Text('Profile Details', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_instructorInfo?['phone_number'] != null)
                                  Text('Phone: ${_instructorInfo!['phone_number']}', style: theme.textTheme.bodyMedium),
                                if (_instructorInfo?['education_degree'] != null)
                                  Text('Degree: ${_instructorInfo!['education_degree']}', style: theme.textTheme.bodyMedium),
                                if (_instructorInfo?['teaching_experience'] != null)
                                  Text('Experience: ${_instructorInfo!['teaching_experience']} years', style: theme.textTheme.bodyMedium),
                                if (_instructorInfo?['current_location'] != null)
                                  Text('Location: ${_instructorInfo!['current_location']}', style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                        if (_instructorInfo?['subject_expertise'] != null)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List<Widget>.from(
                          (_instructorInfo!['subject_expertise'] as List).map(
                            (s) => Chip(
                            label: Text(s.toString(), style: TextStyle(color: AppTheme.textPrimary)),
                            backgroundColor: AppTheme.accentLight,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: AppTheme.primaryTeal, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            ),
                          ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (_instructorInfo?['bio'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Instructor Bio', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(_instructorInfo!['bio'] ?? '', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      const SizedBox(height: 8),
                      if (_instructorInfo?['submitted_at'] != null)
                        Text('Submitted: ${_instructorInfo!['submitted_at']}', style: theme.textTheme.bodySmall),
                      if (_instructorInfo?['verified_at'] != null)
                        Text('Verified at: ${_instructorInfo!['verified_at']}', style: theme.textTheme.bodySmall),
                    ] else ...[
                      const SizedBox(height: 8),
                      Text('No instructor profile submitted yet.', style: theme.textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: _reportInstructor,
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('Report Instructor'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
