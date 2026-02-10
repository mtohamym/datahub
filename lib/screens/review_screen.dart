import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../models/pdf_state.dart';
import '../services/export_service.dart';
import '../widgets/page_viewer.dart';
import '../widgets/selected_pages_panel.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    super.key,
    required this.pdfBytes,
    required this.bookName,
  });

  final Uint8List pdfBytes;
  final String bookName;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  PdfState? _state;
  bool _loading = true;
  String? _error;
  bool _isExporting = false;
  int _exportCurrent = 0;
  int _exportTotal = 0;
  late final FocusNode _pageViewerFocusNode;

  @override
  void initState() {
    super.initState();
    _pageViewerFocusNode = FocusNode();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      final document = await PdfDocument.openData(
        widget.pdfBytes,
        sourceName: widget.bookName,
      );
      if (!mounted) {
        document.dispose();
        return;
      }
      setState(() {
        _state = PdfState(document: document, bookName: widget.bookName);
        _loading = false;
        _error = null;
      });
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
      debugPrintStack(stackTrace: st);
    }
  }

  @override
  void dispose() {
    _pageViewerFocusNode.dispose();
    _state?.document.dispose();
    super.dispose();
  }

  Future<void> _exportSelectedPages() async {
    if (_state == null || _state!.selectedPages.isEmpty) return;
    setState(() {
      _isExporting = true;
      _exportTotal = _state!.selectedPages.length;
      _exportCurrent = 0;
    });
    try {
      await ExportService.exportSelectedPagesAsZip(
        state: _state!,
        onProgress: (current, total) {
          if (mounted) {
            setState(() {
              _exportCurrent = current;
              _exportTotal = total;
            });
          }
        },
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.bookName)),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading PDF…'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Failed to load PDF', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final state = _state!;
    return Scaffold(
      appBar: AppBar(
        title: Text(state.bookName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 800;
          if (isNarrow) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 400,
                      child: PageViewer(state: state, focusNode: _pageViewerFocusNode),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    SizedBox(
                      height: 320,
                      child: SelectedPagesPanel(
                        state: state,
                        onExport: _exportSelectedPages,
                        isExporting: _isExporting,
                        exportProgressCurrent: _exportCurrent,
                        exportProgressTotal: _exportTotal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PageViewer(state: state, focusNode: _pageViewerFocusNode),
                ),
              ),
              Container(
                width: 1,
                color: Theme.of(context).dividerColor,
              ),
              SizedBox(
                width: 320,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectedPagesPanel(
                    state: state,
                    onExport: _exportSelectedPages,
                    isExporting: _isExporting,
                    exportProgressCurrent: _exportCurrent,
                    exportProgressTotal: _exportTotal,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
