// Mock implementations for web platform
class Message {
  late Address from;
  List<String> recipients = [];
  String subject = '';
  String html = '';
}

class Address {
  final String email;
  final String? name;

  Address(this.email, [this.name]);
}

class SmtpServer {
  SmtpServer(
    String host, {
    int? port,
    String? username,
    String? password,
    bool? allowInsecure,
    bool? ssl,
    bool? ignoreBadCertificate,
  });
}

Future<void> send(Message message, SmtpServer server) async {
  // Mock implementation - do nothing on web
  throw UnsupportedError('Email sending not supported on web platform');
}
