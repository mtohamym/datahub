import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_saver/file_saver.dart';
import 'package:image/image.dart' as img;
import 'package:pdfrx/pdfrx.dart';

import '../models/pdf_state.dart';

class ExportService {
  ExportService._();

  /// Renders selected pages to JPEG, packs them into a ZIP, and triggers download.
  static Future<void> exportSelectedPagesAsZip({
    required PdfState state,
    void Function(int current, int total)? onProgress,
  }) async {
    final bookName = _sanitizeFileName(state.bookName);
    final pageNumbers = state.selectedPagesSorted;
    final total = pageNumbers.length;
    if (total == 0) return;

    final archive = Archive();
    int current = 0;

    for (final pageNumber in pageNumbers) {
      onProgress?.call(++current, total);
      final page = state.document.pages[pageNumber - 1];
      final pdfImage = await page.render(
        fullWidth: page.width * 2,
        fullHeight: page.height * 2,
      );
      if (pdfImage == null) continue;
      try {
        final image = pdfImage.createImageNF();
        final jpegBytes = Uint8List.fromList(img.encodeJpg(image, quality: 90));
        final fileName = '${bookName}_page_$pageNumber.jpeg';
        archive.addFile(ArchiveFile(fileName, jpegBytes.length, jpegBytes));
      } finally {
        pdfImage.dispose();
      }
    }

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes.isEmpty) return;

    final zipName = '${bookName}_selected_pages.zip';
    await FileSaver.instance.saveFile(
      name: zipName,
      bytes: Uint8List.fromList(zipBytes),
      fileExtension: 'zip',
      mimeType: MimeType.zip,
    );
  }

  static String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[^\w\s\-.]'), '_').replaceAll(RegExp(r'\s+'), '_');
  }
}
