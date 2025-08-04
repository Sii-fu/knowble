import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import 'chatbot/chatbotpage.dart';

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;
  const PDFViewerPage({required this.pdfUrl, required this.title, super.key});

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? localPath;
  bool isLoading = true;
  String? errorMsg;
  int? pages = 0;
  int? currentPage = 0;
  PDFViewController? _pdfViewController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPdfFromUrl();
  }

  Future<void> _loadPdfFromUrl() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${widget.title.replaceAll(' ', '_')}.pdf');
        await file.writeAsBytes(response.bodyBytes, flush: true);
        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMsg = 'Failed to load PDF from URL.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Error loading PDF: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final url = Uri.parse(widget.pdfUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
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

  void _searchInPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search is not supported in this PDF viewer.')),
    );
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatBotPage()));
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search in PDF...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchInPdf,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
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
                              filePath: localPath!,
                              enableSwipe: true,
                              swipeHorizontal: false,
                              autoSpacing: true,
                              pageFling: true,
                              onRender: (pages) {
                                setState(() {
                                  this.pages = pages;
                                });
                              },
                              onError: (error) {
                                setState(() {
                                  errorMsg = 'Failed to load PDF: $error';
                                });
                              },
                              onPageError: (page, error) {
                                setState(() {
                                  errorMsg = 'Error on page $page: $error';
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
          ],
        ),
      ),
    );
  }
}
