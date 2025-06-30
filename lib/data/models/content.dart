// content.dart
// Content model for Knowble, matching the contents table in the database.

enum ContentType { video, pdf, link }

class Content {
  final String id;
  final String sectionId;
  final ContentType type;
  final String title;
  final String url;
  final int order;

  Content({
    required this.id,
    required this.sectionId,
    required this.type,
    required this.title,
    required this.url,
    required this.order,
  });
}
