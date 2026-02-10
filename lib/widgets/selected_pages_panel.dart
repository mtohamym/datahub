import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../models/pdf_state.dart';

class SelectedPagesPanel extends StatelessWidget {
  const SelectedPagesPanel({
    super.key,
    required this.state,
    required this.onExport,
    required this.isExporting,
    this.exportProgressCurrent,
    this.exportProgressTotal,
  });

  final PdfState state;
  final VoidCallback onExport;
  final bool isExporting;
  final int? exportProgressCurrent;
  final int? exportProgressTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final selected = state.selectedPagesSorted;
        final skipped = state.skippedPages.toList()..sort();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selected pages (${selected.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  ...selected.map((pageNumber) => _SelectedPageTile(
                        state: state,
                        pageNumber: pageNumber,
                        onRemove: () => state.deselectPage(pageNumber),
                      )),
                  if (skipped.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ExpansionTile(
                      title: Text(
                        'Skipped (${skipped.length}) – tap to re-add',
                        style: theme.textTheme.titleSmall,
                      ),
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: skipped
                              .map((pageNumber) => Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: _SkippedChip(
                                      pageNumber: pageNumber,
                                      onReAdd: () => state.reAddPage(pageNumber),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (isExporting && exportProgressCurrent != null && exportProgressTotal != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Exporting page $exportProgressCurrent of $exportProgressTotal',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            FilledButton.icon(
              onPressed: (selected.isEmpty || isExporting) ? null : onExport,
              icon: isExporting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(isExporting ? 'Exporting…' : 'Export as JPEG (ZIP)'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SelectedPageTile extends StatelessWidget {
  const _SelectedPageTile({
    required this.state,
    required this.pageNumber,
    required this.onRemove,
  });

  final PdfState state;
  final int pageNumber;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: SizedBox(
          width: 48,
          height: 64,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: PdfPageView(
              document: state.document,
              pageNumber: pageNumber,
              alignment: Alignment.center,
            ),
          ),
        ),
        title: Text('Page $pageNumber'),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onRemove,
          tooltip: 'Remove from selection',
        ),
      ),
    );
  }
}

class _SkippedChip extends StatelessWidget {
  const _SkippedChip({
    required this.pageNumber,
    required this.onReAdd,
  });

  final int pageNumber;
  final VoidCallback onReAdd;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text('Page $pageNumber'),
      onPressed: onReAdd,
      avatar: const Icon(Icons.add, size: 18),
    );
  }
}
