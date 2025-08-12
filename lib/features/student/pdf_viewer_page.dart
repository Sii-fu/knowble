import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String? extractedText; // Store extracted PDF text content
  bool isExtractingText = false;

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
        
        // Extract text content from PDF
        _extractTextFromPdf(response.bodyBytes);
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

  Future<void> _extractTextFromPdf(List<int> pdfBytes) async {
    try {
      setState(() {
        isExtractingText = true;
      });
      
      // Load the PDF document from bytes
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      
      // Extract text from all pages (for full document context)
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();
      
      // Clean up the extracted text (remove extra whitespace, etc.)
      final cleanedText = text
          .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple whitespaces with single space
          .replaceAll(RegExp(r'\n+'), '\n') // Replace multiple newlines with single newline
          .trim();
      
      setState(() {
        extractedText = cleanedText;
        isExtractingText = false;
      });
      
      // Dispose the document
      document.dispose();
    } catch (e) {
      print('Error extracting text from PDF: $e');
      setState(() {
        isExtractingText = false;
      });
    }
  }

  // Extract text from current page only
  Future<String?> _extractCurrentPageText() async {
    if (localPath == null || currentPage == null) return null;
    
    try {
      // Read the PDF file
      final file = File(localPath!);
      final bytes = await file.readAsBytes();
      
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      if (currentPage! < document.pages.count) {
        // Extract text from current page only
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        final String pageText = extractor.extractText(startPageIndex: currentPage!, endPageIndex: currentPage!);
        
        // Clean up the extracted text
        final cleanedText = pageText
            .replaceAll(RegExp(r'\s+'), ' ')
            .replaceAll(RegExp(r'\n+'), '\n')
            .trim();
        
        document.dispose();
        return cleanedText;
      }
      
      document.dispose();
      return null;
    } catch (e) {
      print('Error extracting current page text: $e');
      return null;
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
            icon: isExtractingText 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chat_bubble_outline),
            onPressed: isExtractingText ? null : () async {
              // Extract text from current page only
              final currentPageText = await _extractCurrentPageText();
              
              // DEBUG: Print actual parameters being sent to ChatBot
              print('📄 PDF VIEWER → CHATBOT PARAMETERS (CURRENT PAGE ONLY):');
              print('courseTitle parameter: "PDF Document"');
              print('courseDescription parameter: "Currently viewing: ${widget.title} - Page ${(currentPage ?? 0) + 1}"');
              if (currentPageText != null && currentPageText.isNotEmpty) {
                print('pdfContents[0][textContent] parameter (current page): "${currentPageText.length > 200 ? "${currentPageText.substring(0, 200)}..." : currentPageText}"');
                print('Current page textContent length: ${currentPageText.length} characters');
              } else {
                print('pdfContents[0][textContent] parameter: null (current page has no text)');
              }
              print('════════════════════════════════════════');
              
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => ChatBotPage(
                    courseTitle: 'PDF Document',
                    courseDescription: 'Currently viewing: ${widget.title} - Page ${(currentPage ?? 0) + 1}',
                    pdfContents: [
                      {
                        'title': '${widget.title} - Page ${(currentPage ?? 0) + 1}',
                        'url': widget.pdfUrl,
                        'textContent': currentPageText, // Include only current page text
                      }
                    ],
                  ),
                ),
              );
            },
            tooltip: isExtractingText 
                ? 'Extracting text...' 
                : 'Ask AI about current page',
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
                                // Controller not needed for basic functionality
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
                            // Text extraction status indicator
                            if (isExtractingText)
                              Positioned(
                                bottom: 60,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryTeal.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Extracting text...',
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (extractedText != null && !isExtractingText)
                              Positioned(
                                bottom: 60,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        'Text ready for AI (current page)',
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
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