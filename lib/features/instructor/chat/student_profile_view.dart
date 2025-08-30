import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/theme.dart';

class StudentProfileView extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String? profileImage;
  final String? courseId;

  const StudentProfileView({
    super.key,
    required this.studentId,
    required this.studentName,
    this.profileImage,
    this.courseId,
  });

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  Map<String, dynamic>? _student;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client
          .from('users')
          .select('id, name, email, profile_pic, bio')
          .eq('id', widget.studentId)
          .maybeSingle();

      if (mounted) setState(() {
        _student = data;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _student = null;
        _loading = false;
      });
      debugPrint('Failed to load student: $e');
    }
  }

  Future<void> _reportStudent() async {
    final TextEditingController _reasonController = TextEditingController();
    final theme = AppTheme.lightTheme;

    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
        title: Text('Report Student', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please describe the issue. Our team will review the report.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Reason for reporting...',
                hintStyle: TextStyle(color: AppTheme.textPrimary.withOpacity(0.7)),
                filled: true,
                fillColor: AppTheme.accentLight,
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
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary))),
          ElevatedButton(
            onPressed: () {
              final reason = _reasonController.text.trim();
              if (reason.isEmpty) return;
              Navigator.of(context).pop(true);
            },
            child: Text('Send Report', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
          ),
        ],
      ),
    );

    if (result != true) return;

    final reason = _reasonController.text.trim();
    final reporterId = Supabase.instance.client.auth.currentUser?.id;
    if (reporterId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to report.')));
      return;
    }

    try {
      String userRole = 'instructor';
      try {
        final userData = await Supabase.instance.client.from('users').select('role').eq('id', reporterId).maybeSingle();
        if (userData != null && userData['role'] != null) userRole = userData['role'] as String;
      } catch (_) {}

      await Supabase.instance.client.from('feedback_issues').insert({
        'user_id': reporterId,
        'user_role': userRole,
        'type': 'report',
        'category': 'chat',
        'message': reason,
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
    final name = _student?['name'] ?? widget.studentName;
    final email = _student?['email'] ?? '';
    final bio = _student?['bio'] ?? '';

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    CircleAvatar(radius: 40, backgroundImage: widget.profileImage != null ? NetworkImage(widget.profileImage!) : null, backgroundColor: AppTheme.accentLight, child: widget.profileImage == null ? Icon(Icons.person, color: AppTheme.primaryTeal, size: 36) : null),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(email, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                    ])),
                  ]),
                  const SizedBox(height: 18),
                  Text('About', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(bio.isNotEmpty ? bio : 'No biography provided.', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _reportStudent,
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Report Student'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
                  ),
                ]),
              ),
              
      ),
    );
  }
}
