import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'review_screen.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  static String _sanitizeBookName(String filename) {
    if (filename.toLowerCase().endsWith('.pdf')) {
      return filename.substring(0, filename.length - 4);
    }
    return filename;
  }

  Future<void> _pickAndOpenPdf(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (context.mounted && result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final name = result.files.single.name;
      final bookName = _sanitizeBookName(name);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ReviewScreen(
            pdfBytes: bytes,
            bookName: bookName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'DataHub',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a PDF to extract pages that contain tables',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => _pickAndOpenPdf(context),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Choose PDF file'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
