import 'package:flutter/material.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../../config/theme_instructor.dart';
import '../../core/services/Instructor/edit_course_service.dart';

class EditCourseScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final String subject;

  const EditCourseScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.subject,
  });

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  Map<String, dynamic>? _courseBannerInfo;
  final EditCourseService _service = EditCourseService();
  Map<String, dynamic>? _originalCourse;
  bool _isSaving = false;
  
  // Course basic info controllers
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseDescriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationDaysController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<String> _tagSuggestions = [];
  Timer? _tagDebounce;

  // Dynamic chapters and lessons structure
  final List<ChapterData> _chapters = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing course data
    _courseNameController.text = widget.courseTitle;
    _tagController.text = widget.subject;
    
    // Initialize with default structure
    _addNewChapter();
    
    // Initialize lesson data with existing content
    if (_chapters.isNotEmpty && _chapters[0].lessons.isNotEmpty) {
      _chapters[0].lessons[0].titleController.text = 'How to Use Exponential Notation';
      if (_chapters[0].lessons.length > 1) {
        _chapters[0].lessons[1].titleController.text = 'Scientific Notation: Definition and Examples';
      }
      if (_chapters[0].lessons.length > 2) {
        _chapters[0].lessons[2].titleController.text = 'Simplifying and Solving Exponential Expressions';
      }
      if (_chapters[0].lessons.length > 3) {
        _chapters[0].lessons[3].titleController.text = 'Exponential Expressions & The Order of Operations';
      }
    }
    
    _tagController.addListener(_onTagChanged);

    // Load real course data from backend and populate fields
    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    try {
      final data = await _service.fetchCourseDetail(widget.courseId);
      if (data == null) return;

  // keep original snapshot for change detection
  _originalCourse = Map<String, dynamic>.from(data);

      setState(() {
        _courseNameController.text = data['title'] ?? widget.courseTitle;
        _courseDescriptionController.text = data['description'] ?? '';
        _priceController.text = (data['price'] ?? '').toString();
        _durationDaysController.text = (data['duration_days'] ?? '').toString();
        // tags/subject: keep existing widget.subject if backend doesn't provide
        _tagController.text = widget.subject;

  // Populate chapters and lessons
        _chapters.clear();
        final chapters = List.from(data['chapters'] as List? ?? []);
        for (final ch in chapters) {
          final chapter = ChapterData();
          chapter.nameController.text = ch['title'] ?? '';
          // store remote IDs if present
          if (ch['id'] != null) chapter.remoteId = ch['id'] as String;
          chapter.lessons.clear();
          final lessons = List.from(ch['lessons'] as List? ?? []);
          for (final ls in lessons) {
            final lesson = LessonData();
            lesson.titleController.text = ls['title'] ?? '';
            lesson.descriptionController.text = ls['description'] ?? '';
            if (ls['id'] != null) lesson.remoteId = ls['id'] as String;

            // map first PDF/content if present
            final contents = List.from(ls['contents'] as List? ?? []);
            if (contents.isNotEmpty) {
              final first = contents.first as Map<String, dynamic>;
              lesson.pdfFile = {
                'name': first['title'] ?? '',
                'url': first['url'] ?? '',
                'remoteId': first['id'] ?? null,
              };
            }

            chapter.lessons.add(lesson);
          }
          _chapters.add(chapter);
        }
      });
    } catch (e) {
      debugPrint('Failed to load course details: $e');
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    // show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 12),
              Text('Course is updating...'),
            ],
          ),
        ),
      ),
    );

    try {
      final orig = _originalCourse ?? {};
      // course-level updates
      final title = _courseNameController.text.trim();
      final desc = _courseDescriptionController.text.trim();
      final price = double.tryParse(_priceController.text.trim());
      final duration = int.tryParse(_durationDaysController.text.trim());

      final bool needCourseUpdate = title != (orig['title'] ?? '') || desc != (orig['description'] ?? '') ||
          (price != null && price != (orig['price'] ?? 0)) || (duration != null && duration != (orig['duration_days'] ?? 0));

      if (needCourseUpdate) {
        await _service.updateCourseBasic(
          courseId: widget.courseId,
          title: title,
          description: desc,
          price: price,
          durationDays: duration,
        );
      }

      // modules / sections / contents updates: only existing (with remoteId)
      final origChapters = List.from(orig['chapters'] as List? ?? []);
      for (int i = 0; i < _chapters.length; i++) {
        final ch = _chapters[i];
        final chTitle = ch.nameController.text.trim();
        if (ch.remoteId != null) {
          // find original chapter map safely
          Map<String, dynamic>? origCh;
          for (final c in origChapters) {
            if (c is Map && c['id'] == ch.remoteId) {
              origCh = Map<String, dynamic>.from(c);
              break;
            }
          }
          if (origCh != null && chTitle != (origCh['title'] ?? '')) {
            await _service.updateModule(moduleId: ch.remoteId!, title: chTitle);
          }
        } else {
          // create new module
          final newId = await _service.createModule(courseId: widget.courseId, title: chTitle, order: i);
          if (newId != null) ch.remoteId = newId;
        }

        // build original lessons list for this chapter (if any) in a null-safe way
        final origLessons = <dynamic>[];
        if (ch.remoteId != null) {
          for (final c in origChapters) {
            if (c is Map && c['id'] == ch.remoteId) {
              origLessons.addAll(List.from((c['lessons'] as List? ?? [])));
              break;
            }
          }
        }

        for (int j = 0; j < ch.lessons.length; j++) {
          final ls = ch.lessons[j];
          final lsTitle = ls.titleController.text.trim();
          final lsDesc = ls.descriptionController.text.trim();
          if (ls.remoteId != null) {
            Map<String, dynamic>? origLs;
            for (final l in origLessons) {
              if (l is Map && l['id'] == ls.remoteId) {
                origLs = Map<String, dynamic>.from(l);
                break;
              }
            }
            if (origLs != null && (lsTitle != (origLs['title'] ?? '') || lsDesc != (origLs['description'] ?? ''))) {
              await _service.updateSection(sectionId: ls.remoteId!, title: lsTitle, description: lsDesc);
            }
          } else {
            // create new section under module
            final moduleId = ch.remoteId;
            if (moduleId != null) {
              final newSectionId = await _service.createSection(moduleId: moduleId, title: lsTitle, description: lsDesc, order: j);
              if (newSectionId != null) ls.remoteId = newSectionId;
            }
          }

          // contents (only handle pdfFile for now)
          if (ls.pdfFile != null) {
            final contentRemote = ls.pdfFile!['remoteId'];
            final contentTitle = ls.pdfFile!['name'] ?? '';
            final contentUrl = ls.pdfFile!['url'] ?? '';
            if (contentRemote != null) {
              // find the original lesson entry and its contents safely
              Map<String, dynamic>? origLessonMap;
              for (final l in origLessons) {
                if (l is Map && l['id'] == ls.remoteId) {
                  origLessonMap = Map<String, dynamic>.from(l);
                  break;
                }
              }
              final origContents = origLessonMap != null ? List.from(origLessonMap['contents'] as List? ?? []) : <dynamic>[];
              Map<String, dynamic>? found;
              for (final c in origContents) {
                if (c is Map && c['id'] == contentRemote) {
                  found = Map<String, dynamic>.from(c);
                  break;
                }
              }
              if (found != null && (contentTitle != (found['title'] ?? '') || contentUrl != (found['url'] ?? ''))) {
                await _service.updateContent(contentId: contentRemote, title: contentTitle, url: contentUrl);
              }
            } else {
              // create content (we need section id)
              if (ls.remoteId != null) {
                final newContentId = await _service.createContent(sectionId: ls.remoteId!, type: 'pdf', url: contentUrl, order: 0, title: contentTitle);
                if (newContentId != null) ls.pdfFile!['remoteId'] = newContentId;
              }
            }
          }
        }
      }

      // close loading
      if (mounted) Navigator.of(context).pop();
      setState(() => _isSaving = false);
      _showSuccessDialog('Course updated successfully');
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseDescriptionController.dispose();
    _priceController.dispose();
    _durationDaysController.dispose();
    _tagController.dispose();
    
    // Dispose all chapters and lessons
    for (var chapter in _chapters) {
      chapter.dispose();
    }
    _tagDebounce?.cancel();
    _tagController.removeListener(_onTagChanged);
    
    super.dispose();
  }

  void _onTagChanged() {
    final value = _tagController.text.trim();
    _tagDebounce?.cancel();
    _tagDebounce = Timer(const Duration(milliseconds: 300), () async {
      if (value.isEmpty) {
        setState(() => _tagSuggestions.clear());
        return;
      }
      // Here you would fetch tag suggestions from your service
      // For now, using static suggestions
      final tags = ['Mathematics', 'Science', 'Physics', 'Chemistry', 'Biology'];
      setState(() {
        _tagSuggestions
          ..clear()
          ..addAll(tags.where((tag) => tag.toLowerCase().contains(value.toLowerCase())));
      });
    });
  }

  // Dynamic chapter and lesson management
  void _addNewChapter() {
    setState(() {
      _chapters.add(ChapterData());
    });
  }

  LessonData _createNewLesson() {
    return LessonData();
  }

  void _addLessonToChapter(int chapterIndex) {
    setState(() {
      _chapters[chapterIndex].lessons.add(_createNewLesson());
    });
  }

  void _removeChapter(int chapterIndex) {
    if (_chapters.length > 1) {
      setState(() {
        _chapters[chapterIndex].dispose();
        _chapters.removeAt(chapterIndex);
      });
    }
  }

  void _removeLesson(int chapterIndex, int lessonIndex) {
    if (_chapters[chapterIndex].lessons.length > 1) {
      setState(() {
        _chapters[chapterIndex].lessons[lessonIndex].dispose();
        _chapters[chapterIndex].lessons.removeAt(lessonIndex);
      });
    }
  }

  // File upload functions
  Future<void> _handleBannerUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      setState(() {
        final info = <String, dynamic>{'name': file.name};
        if (kIsWeb) {
          info['bytes'] = file.bytes;
        } else {
          info['path'] = file.path;
        }
        _courseBannerInfo = info;
      });
    }
  }

  Future<void> _handlePdfUpload(int chapterIndex, int lessonIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, 
      allowedExtensions: ['pdf']
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      Map<String, dynamic> pdfInfo = {
        'name': file.name,
      };
      if (kIsWeb) {
        pdfInfo['bytes'] = file.bytes;
      } else {
        pdfInfo['path'] = file.path;
      }
      setState(() {
        _chapters[chapterIndex].lessons[lessonIndex].pdfFile = pdfInfo;
      });
      // _showSuccessDialog('PDF uploaded successfully!');
    }
  }

  Future<void> _handleVideoUpload(int chapterIndex, int lessonIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      Map<String, dynamic> videoInfo = {
        'name': file.name,
      };
      if (kIsWeb) {
        videoInfo['bytes'] = file.bytes;
      } else {
        videoInfo['path'] = file.path;
      }
      setState(() {
        _chapters[chapterIndex].lessons[lessonIndex].videoFile = videoInfo;
      });
      // _showSuccessDialog('Video uploaded successfully!');
    }
  }

  void _showSuccessDialog([String message = 'Course updated successfully!']) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppThemeInstructor.surfaceWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppThemeInstructor.shadowLight.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppThemeInstructor.primaryBlue, AppThemeInstructor.successGreen.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Saved Successfully',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppThemeInstructor.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppThemeInstructor.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemeInstructor.primaryBlue, AppThemeInstructor.successGreen.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Go back to course detail
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeInstructor.lightTheme;
    
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: AppThemeInstructor.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppThemeInstructor.surfaceWhite,
          elevation: 0,
          titleSpacing: 0,
          leading: Container(
            margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: AppThemeInstructor.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppThemeInstructor.textPrimary, size: 18),
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.only(left: 4),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              'Edit Course',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppThemeInstructor.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Information Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppThemeInstructor.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppThemeInstructor.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemeInstructor.shadowLight.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppThemeInstructor.primaryBlue.withOpacity(0.1), AppThemeInstructor.successGreen.withOpacity(0.1)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              color: AppThemeInstructor.primaryBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Course Information',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppThemeInstructor.textPrimary,
                                ),
                              ),
                              Text(
                                'Edit your course details',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppThemeInstructor.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      _buildModernTextField(
                        controller: _courseNameController,
                        label: 'Course Name',
                        hint: 'Enter an engaging course title',
                        icon: Icons.title_outlined,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildModernTextField(
                        controller: _courseDescriptionController,
                        label: 'Description',
                        hint: 'Describe what students will learn',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernTextField(
                              controller: _priceController,
                              label: 'Price',
                              hint: '0.00',
                              icon: Icons.attach_money_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildModernTextField(
                              controller: _durationDaysController,
                              label: 'Duration (days)',
                              hint: '30',
                              icon: Icons.schedule_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      _buildModernTextField(
                        controller: _tagController,
                        label: 'Category Tag',
                        hint: 'e.g., Mathematics, Science',
                        icon: Icons.tag_outlined,
                      ),
                      const SizedBox(height: 8),
                      if (_tagSuggestions.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tagSuggestions.map((s) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _tagController.text = s;
                                _tagSuggestions.clear();
                              });
                            },
                            child: Chip(label: Text(s)),
                          )).toList(),
                        ),
                        const SizedBox(height: 8),
                      ] else
                        const SizedBox(height: 8),
                      // Course banner upload
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _handleBannerUpload,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppThemeInstructor.primaryBlue,
                                      AppThemeInstructor.successGreen.withOpacity(0.8),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppThemeInstructor.primaryBlue.withOpacity(0.18),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        _courseBannerInfo != null
                                            ? 'Banner Selected: ${_courseBannerInfo!['name'] ?? ''}'
                                            : 'Upload Course Banner',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          letterSpacing: 0.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Dynamic Chapters Section
                for (int chapterIndex = 0; chapterIndex < _chapters.length; chapterIndex++) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppThemeInstructor.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppThemeInstructor.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: AppThemeInstructor.shadowLight.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chapter Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppThemeInstructor.primaryBlue.withOpacity(0.1), AppThemeInstructor.successGreen.withOpacity(0.1)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.book_outlined,
                                color: AppThemeInstructor.primaryBlue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chapter ${chapterIndex + 1}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppThemeInstructor.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Edit chapter details and lessons',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppThemeInstructor.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_chapters.length > 1)
                              IconButton(
                                onPressed: () => _removeChapter(chapterIndex),
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.shade400,
                                  size: 20,
                                ),
                                tooltip: 'Remove Chapter',
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Chapter Name Field
                        _buildModernTextField(
                          controller: _chapters[chapterIndex].nameController,
                          label: 'Chapter Name',
                          hint: 'Enter chapter title',
                          icon: Icons.title_outlined,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Lessons Header
                        Row(
                          children: [
                            Icon(
                              Icons.playlist_play_outlined,
                              color: AppThemeInstructor.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lessons',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppThemeInstructor.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_chapters[chapterIndex].lessons.length} lesson${_chapters[chapterIndex].lessons.length != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppThemeInstructor.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Dynamic Lessons
                        for (int lessonIndex = 0; lessonIndex < _chapters[chapterIndex].lessons.length; lessonIndex++) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppThemeInstructor.backgroundLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppThemeInstructor.borderSubtle),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Lesson Header
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppThemeInstructor.primaryBlue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${lessonIndex + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Lesson ${lessonIndex + 1}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppThemeInstructor.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (_chapters[chapterIndex].lessons.length > 1)
                                      IconButton(
                                        onPressed: () => _removeLesson(chapterIndex, lessonIndex),
                                        icon: Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.red.shade400,
                                          size: 18,
                                        ),
                                        tooltip: 'Remove Lesson',
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Lesson Title
                                _buildCompactTextField(
                                  controller: _chapters[chapterIndex].lessons[lessonIndex].titleController,
                                  hint: 'Lesson title',
                                  icon: Icons.play_lesson_outlined,
                                ),
                                const SizedBox(height: 12),
                                
                                // Lesson Description
                                _buildCompactTextField(
                                  controller: _chapters[chapterIndex].lessons[lessonIndex].descriptionController,
                                  hint: 'Lesson description (optional)',
                                  icon: Icons.notes_outlined,
                                ),
                                const SizedBox(height: 16),
                                
                                // File Upload Section
                                Row(
                                  children: [
                                    // PDF Upload
                                    Expanded(
                                      child: _buildFileUploadCard(
                                        onTap: () => _handlePdfUpload(chapterIndex, lessonIndex),
                                        fileInfo: _chapters[chapterIndex].lessons[lessonIndex].pdfFile,
                                        fileType: 'PDF',
                                        icon: Icons.picture_as_pdf,
                                        color: Colors.red.shade400,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Video Upload
                                    Expanded(
                                      child: _buildFileUploadCard(
                                        onTap: () => _handleVideoUpload(chapterIndex, lessonIndex),
                                        fileInfo: _chapters[chapterIndex].lessons[lessonIndex].videoFile,
                                        fileType: 'Video',
                                        icon: Icons.videocam_outlined,
                                        color: Colors.blue.shade400,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),
                                // Assessment Section (per-lesson)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppThemeInstructor.surfaceWhite,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppThemeInstructor.borderSubtle),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Assessment',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppThemeInstructor.textPrimary,
                                            ),
                                          ),
                                          // Toggle AI quiz generator (checkbox)
                                          Row(
                                            children: [
                                              const Text('AI quiz generator', style: TextStyle(fontSize: 12)),
                                              const SizedBox(width: 8),
                                              Checkbox(
                                                value: _chapters[chapterIndex].lessons[lessonIndex].aiAssessmentEnabled,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _chapters[chapterIndex].lessons[lessonIndex].aiAssessmentEnabled = val ?? false;
                                                    // when enabling AI, clear manual questions
                                                    if (_chapters[chapterIndex].lessons[lessonIndex].aiAssessmentEnabled) {
                                                      _chapters[chapterIndex].lessons[lessonIndex].manualQuestions.clear();
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // If AI is enabled, show a short explanation and hide manual options
                                      if (_chapters[chapterIndex].lessons[lessonIndex].aiAssessmentEnabled) ...[
                                        Text(
                                          'AI will generate a short quiz for this lesson.',
                                          style: TextStyle(color: AppThemeInstructor.textSecondary, fontSize: 12),
                                        ),
                                        const SizedBox(height: 8),
                                        // Quick-select options for number of quizzes (5, 10, 15)
                                        Row(
                                          children: [
                                            Text('Number of quizzes:', style: TextStyle(color: AppThemeInstructor.textPrimary, fontSize: 13)),
                                            const SizedBox(width: 12),
                                            Wrap(
                                              spacing: 8,
                                              children: [5, 10, 15].map((count) {
                                                final selected = _chapters[chapterIndex].lessons[lessonIndex].aiQuizCount == count;
                                                return ChoiceChip(
                                                  label: Text('$count'),
                                                  selected: selected,
                                                  onSelected: (sel) {
                                                    if (sel) {
                                                      setState(() {
                                                        _chapters[chapterIndex].lessons[lessonIndex].aiQuizCount = count;
                                                      });
                                                    }
                                                  },
                                                  selectedColor: AppThemeInstructor.primaryBlue.withOpacity(0.12),
                                                  backgroundColor: AppThemeInstructor.backgroundLight,
                                                  labelStyle: TextStyle(color: selected ? AppThemeInstructor.primaryBlue : AppThemeInstructor.textPrimary),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ] else ...[
                                        // Manual questions area
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Add questions', style: TextStyle(color: AppThemeInstructor.textPrimary, fontWeight: FontWeight.w600)),
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _chapters[chapterIndex].lessons[lessonIndex].manualQuestions.add(ManualQuestion());
                                                    });
                                                  },
                                                  icon: const Icon(Icons.add, size: 20),
                                                  tooltip: 'Add question',
                                                ),
                                              ],
                                            ),

                                            // List of manual questions
                                            for (int qIndex = 0; qIndex < _chapters[chapterIndex].lessons[lessonIndex].manualQuestions.length; qIndex++) ...[
                                              Container(
                                                margin: const EdgeInsets.only(top: 8, bottom: 8),
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: AppThemeInstructor.backgroundLight,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: AppThemeInstructor.borderSubtle),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        // Question text on its own line to reduce congestion
                                                        TextField(
                                                          controller: _chapters[chapterIndex].lessons[lessonIndex].manualQuestions[qIndex].questionController,
                                                          decoration: InputDecoration(
                                                            hintText: 'Question text',
                                                            hintStyle: TextStyle(color: AppThemeInstructor.textSecondary),
                                                            border: InputBorder.none,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        // Marks input and delete button on a second row
                                                        Row(
                                                          children: [
                                                            // Make marks field expand to fill space before the delete icon
                                                            Expanded(
                                                              child: TextField(
                                                                controller: _chapters[chapterIndex].lessons[lessonIndex].manualQuestions[qIndex].marksController,
                                                                keyboardType: TextInputType.number,
                                                                decoration: InputDecoration(
                                                                  hintText: 'Marks',
                                                                  hintStyle: TextStyle(color: AppThemeInstructor.textSecondary),
                                                                  border: InputBorder.none,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  _chapters[chapterIndex].lessons[lessonIndex].manualQuestions[qIndex].dispose();
                                                                  _chapters[chapterIndex].lessons[lessonIndex].manualQuestions.removeAt(qIndex);
                                                                });
                                                              },
                                                              icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 18),
                                                              tooltip: 'Remove question',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        // Add Lesson Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppThemeInstructor.primaryBlue.withOpacity(0.3),
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => _addLessonToChapter(chapterIndex),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: AppThemeInstructor.primaryBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add Lesson',
                                    style: TextStyle(
                                      color: AppThemeInstructor.primaryBlue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Add Chapter Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppThemeInstructor.primaryBlue.withOpacity(0.1),
                        AppThemeInstructor.successGreen.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppThemeInstructor.primaryBlue.withOpacity(0.3)),
                  ),
                  child: InkWell(
                    onTap: _addNewChapter,
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppThemeInstructor.primaryBlue, AppThemeInstructor.successGreen],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Add New Chapter',
                          style: TextStyle(
                            color: AppThemeInstructor.primaryBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create another chapter for your course',
                          style: TextStyle(
                            color: AppThemeInstructor.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Save Change Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppThemeInstructor.primaryBlue, AppThemeInstructor.successGreen.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemeInstructor.primaryBlue.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isSaving) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                        if (!_isSaving) const Icon(
                          Icons.save_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSaving ? 'Saving...' : 'Save Changes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for modern text fields
  Widget _buildModernTextField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppThemeInstructor.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppThemeInstructor.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemeInstructor.borderSubtle),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 16,
              color: AppThemeInstructor.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppThemeInstructor.textSecondary,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: AppThemeInstructor.textSecondary,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppThemeInstructor.textSecondary),
        prefixIcon: Icon(icon, color: AppThemeInstructor.textSecondary, size: 18),
        filled: true,
        fillColor: AppThemeInstructor.surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppThemeInstructor.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppThemeInstructor.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppThemeInstructor.primaryBlue),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildFileUploadCard({
    required VoidCallback onTap,
    required Map<String, dynamic>? fileInfo,
    required String fileType,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              fileInfo != null 
                ? '${fileInfo['name'] ?? 'Selected'}'
                : 'Upload $fileType',
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

}

  // Data model classes for comprehensive course editing
class ManualQuestion {
  late TextEditingController questionController;
  late TextEditingController marksController;

  ManualQuestion() {
    questionController = TextEditingController();
    marksController = TextEditingController();
  }

  void dispose() {
    questionController.dispose();
    marksController.dispose();
  }
}

class LessonData {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  Map<String, dynamic>? pdfFile;
  Map<String, dynamic>? videoFile;
  String? remoteId;
  bool aiAssessmentEnabled;
  int aiQuizCount;
  List<ManualQuestion> manualQuestions;

  LessonData({
    this.aiAssessmentEnabled = false,
    this.aiQuizCount = 5,
  }) : manualQuestions = [] {
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    for (var question in manualQuestions) {
      question.dispose();
    }
  }
}

class ChapterData {
  late TextEditingController nameController;
  List<LessonData> lessons;
  String? remoteId;

  ChapterData() : lessons = [] {
    nameController = TextEditingController();
    // Add one default lesson
    lessons.add(LessonData());
  }

  void dispose() {
    nameController.dispose();
    for (var lesson in lessons) {
      lesson.dispose();
    }
  }
}
