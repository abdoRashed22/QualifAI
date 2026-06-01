import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/injection.dart';

class FileViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const FileViewerScreen({
    super.key,
    required this.fileUrl,
    required this.fileName,
  });

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  PdfController? _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  /// Fetch PDF bytes via Dio (already in your project — no new dependency needed)
  bool get _isPdf =>
      widget.fileUrl.split('?').first.toLowerCase().endsWith('.pdf');

  Future<Uint8List> _fetchBytes(String url) async {
    final response = await sl<Dio>().get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    return Uint8List.fromList(response.data ?? []);
  }

  Future<void> _initPdf() async {
    if (!_isPdf) {
      if (mounted) {
        setState(() {
          _error =
              'تنسيق الملف غير مدعوم للعرض داخل التطبيق. الرجاء تحميل الملف أو فتحه خارجياً.';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      _pdfController = PdfController(
        // openData accepts FutureOr<Uint8List> — Future<Uint8List> from Dio works perfectly
        document: PdfDocument.openData(_fetchBytes(widget.fileUrl)),
      );

      // pageListenable is the correct way to observe page changes in pdfx
      _pdfController!.pageListenable.addListener(() {
        if (mounted) {
          setState(() {
            _currentPage = _pdfController!.pageListenable.value;
          });
        }
      });

      final doc = await _pdfController!.document;
      if (mounted) {
        setState(() {
          _totalPages = doc.pagesCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.fileName),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(
                        'خطأ في تحميل الملف',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          _error ?? 'حدث خطأ غير معروف',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      if (!_isPdf) ...[
                        SizedBox(height: 20.h),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              final uri = Uri.parse(widget.fileUrl);
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            } catch (_) {
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'لا يمكن فتح الملف خارجياً. حاول تحميله من شاشة الملف.'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('فتح الملف خارجياً'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: PdfView(
                        controller: _pdfController!,
                        builders: PdfViewBuilders<DefaultBuilderOptions>(
                          options: const DefaultBuilderOptions(),
                          documentLoaderBuilder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                          pageLoaderBuilder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                          // _pageBuilder now correctly returns PhotoViewGalleryPageOptions
                          pageBuilder: _pageBuilder,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 12.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border:
                            Border(top: BorderSide(color: Colors.grey[300]!)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الصفحة $_currentPage من $_totalPages',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _currentPage > 1
                                    ? () => _pdfController!.previousPage(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          curve: Curves.easeOut,
                                        )
                                    : null,
                                icon: const Icon(Icons.arrow_back),
                                tooltip: 'الصفحة السابقة',
                              ),
                              IconButton(
                                onPressed: _currentPage < _totalPages
                                    ? () => _pdfController!.nextPage(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          curve: Curves.easeIn,
                                        )
                                    : null,
                                icon: const Icon(Icons.arrow_forward),
                                tooltip: 'الصفحة التالية',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  // PdfViewPageBuilder typedef = PhotoViewGalleryPageOptions Function(
  //   BuildContext, Future<PdfPageImage>, int, PdfDocument)
  // Must return PhotoViewGalleryPageOptions — NOT Widget
  static PhotoViewGalleryPageOptions _pageBuilder(
    BuildContext context,
    Future<PdfPageImage> pageImage,
    int index,
    PdfDocument document,
  ) {
    return PhotoViewGalleryPageOptions(
      imageProvider: PdfPageImageProvider(
        pageImage,
        index,
        document.id,
      ),
      minScale: PhotoViewComputedScale.contained * 1.0,
      maxScale: PhotoViewComputedScale.contained * 3.0,
      initialScale: PhotoViewComputedScale.contained * 1.0,
    );
  }
}
