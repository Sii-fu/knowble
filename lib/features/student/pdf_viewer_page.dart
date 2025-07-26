import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../student/chatbot/chatbotpage.dart';


class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;
  const PDFViewerPage({required this.pdfUrl, required this.title, super.key});

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  bool isLoading = true;
  String? errorMsg;
  int? pages = 0;
  int? currentPage = 0;
  PDFViewController? _pdfViewController;
  final TextEditingController _searchController = TextEditingController();


  Future<void> _downloadPdf(BuildContext context) async {
    try {
      if (await canLaunchUrl(Uri.parse(widget.pdfUrl))) {
        await launchUrl(Uri.parse(widget.pdfUrl), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch PDF URL.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 1,
        title: Text(widget.title, style: const TextStyle(color: AppTheme.textPrimary)),
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMsg != null
                ? Center(
                    child: Text(
                      errorMsg!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Stack(
                    children: [
                      PDFView(
                        filePath: widget.pdfUrl,
                        enableSwipe: true,
                        swipeHorizontal: false,
                        autoSpacing: true,
                        pageFling: true,
                        onRender: (pages) {
                          setState(() {
                            this.pages = pages;
                            isLoading = false;
                          });
                        },
                        onError: (error) {
                          setState(() {
                            errorMsg = 'Failed to load PDF.\n$error';
                            isLoading = false;
                          });
                        },
                        onPageError: (page, error) {
                          setState(() {
                            errorMsg = 'Error on page $page: $error';
                            isLoading = false;
                          });
                        },
                        onViewCreated: (controller) {
                          _pdfViewController = controller;
                        },
                        onPageChanged: (page, total) {
                          setState(() {
                            currentPage = page;
                            pages = total;
                          });
                        },
                      ),
                      if (pages != null && currentPage != null)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Page ${currentPage! + 1} / $pages',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
