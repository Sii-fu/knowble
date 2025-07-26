import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import '../../config/theme.dart';
import '../student/chatbot/chatbotpage.dart';

class PDFViewerPage extends StatelessWidget {
  final String pdfUrl;
  final String title;
  const PDFViewerPage({required this.pdfUrl, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _searchController = TextEditingController();
    final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
    final PdfViewerController _pdfController = PdfViewerController();
    ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
    ValueNotifier<String?> errorMsg = ValueNotifier<String?>(null);

    Future<void> _downloadPdf(BuildContext context) async {
      try {
        // For web: open the PDF in a new tab (browser will handle download)
        // For mobile/desktop: download to device
        if (Theme.of(context).platform == TargetPlatform.android ||
            Theme.of(context).platform == TargetPlatform.iOS) {
          // Mobile: download to device using url_launcher
          // ignore: deprecated_member_use
          if (await canLaunch(pdfUrl)) {
            await launch(pdfUrl);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not launch PDF URL.')),
            );
          }
        } else {
          // Web/desktop: open in new tab
          // ignore: undefined_prefixed_name
          // ignore: avoid_web_libraries_in_flutter
          html.window.open(pdfUrl, '_blank');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download PDF: $e')),
        );
      }
    }
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 1,
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadPdf(context),
            tooltip: 'Download PDF',
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatBotPage()),
              );
            },
            tooltip: 'Ask AI Assistant',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search in PDF...',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              if (_searchController.text.isNotEmpty) {
                                _pdfController.searchText(_searchController.text);
                              }
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: isLoading,
                builder: (context, loading, _) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: errorMsg,
                    builder: (context, error, __) {
                      if (loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (error != null) {
                        return Center(
                          child: Text(
                            error,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return SfPdfViewer.network(
                        pdfUrl,
                        key: _pdfViewerKey,
                        controller: _pdfController,
                        canShowScrollHead: true,
                        canShowScrollStatus: true,
                        enableTextSelection: true,
                        canShowPaginationDialog: true,
                        onDocumentLoaded: (_) => isLoading.value = false,
                        onDocumentLoadFailed: (details) {
                          isLoading.value = false;
                          errorMsg.value = 'Failed to load PDF.\n${details.error}';
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
