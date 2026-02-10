import 'package:flutter/foundation.dart';
import 'package:pdfrx/pdfrx.dart';

/// Holds the loaded PDF document, book name, current page index,
/// selected pages (contain table), and skipped pages (no table).
class PdfState extends ChangeNotifier {
  PdfState({
    required this.document,
    required this.bookName,
  }) : _currentPageIndex = 0 {
    _selectedPages = {};
    _skippedPages = {};
  }

  final PdfDocument document;
  final String bookName;

  int _currentPageIndex;
  late Set<int> _selectedPages;
  late Set<int> _skippedPages;

  int get pageCount => document.pages.length;
  int get currentPageIndex => _currentPageIndex;
  int get currentPageNumber => _currentPageIndex + 1;

  Set<int> get selectedPages => Set<int>.from(_selectedPages);
  Set<int> get skippedPages => Set<int>.from(_skippedPages);

  PdfPage get currentPage => document.pages[_currentPageIndex];

  bool get canGoPrevious => _currentPageIndex > 0;
  bool get canGoNext => _currentPageIndex < pageCount - 1;

  bool isSelected(int pageNumber) => _selectedPages.contains(pageNumber);
  bool isSkipped(int pageNumber) => _skippedPages.contains(pageNumber);

  void goToPage(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= pageCount) return;
    _currentPageIndex = pageIndex;
    notifyListeners();
  }

  void nextPage() {
    if (canGoNext) {
      _currentPageIndex++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (canGoPrevious) {
      _currentPageIndex--;
      notifyListeners();
    }
  }

  /// Mark current page as containing a table (add to selection).
  void selectCurrentPage() {
    final n = currentPageNumber;
    _selectedPages.add(n);
    _skippedPages.remove(n);
    notifyListeners();
  }

  /// Mark current page as not containing a table (skip).
  void skipCurrentPage() {
    final n = currentPageNumber;
    _skippedPages.add(n);
    _selectedPages.remove(n);
    notifyListeners();
  }

  /// Remove a page from selection (e.g. from the right panel).
  void deselectPage(int pageNumber) {
    _selectedPages.remove(pageNumber);
    notifyListeners();
  }

  /// Re-add a previously skipped page to selection.
  void reAddPage(int pageNumber) {
    _selectedPages.add(pageNumber);
    _skippedPages.remove(pageNumber);
    notifyListeners();
  }

  /// Sorted list of selected page numbers for export order.
  List<int> get selectedPagesSorted => _selectedPages.toList()..sort();
}
