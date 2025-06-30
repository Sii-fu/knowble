// certificate.dart
// Certificate model for Knowble, matching the certificates table in the database.

enum CertificateStatus { issued, revoked }

class Certificate {
  final String id;
  final String studentId;
  final String courseId;
  final DateTime issuedAt;
  final String certificateUrl;
  final String certNumber;
  final CertificateStatus status;

  Certificate({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.issuedAt,
    required this.certificateUrl,
    required this.certNumber,
    required this.status,
  });
}
