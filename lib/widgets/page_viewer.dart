import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

import '../models/pdf_state.dart';

class PageViewer extends StatelessWidget {
  const PageViewer({
    super.key,
    required this.state,
    required this.focusNode,
  });

  final PdfState state;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Focus(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowRight:
          case LogicalKeyboardKey.pageDown:
            state.nextPage();
            return KeyEventResult.handled;
          case LogicalKeyboardKey.arrowLeft:
          case LogicalKeyboardKey.pageUp:
            state.previousPage();
            return KeyEventResult.handled;
          case LogicalKeyboardKey.enter:
            state.selectCurrentPage();
            if (state.canGoNext) state.nextPage();
            return KeyEventResult.handled;
          case LogicalKeyboardKey.space:
            state.skipCurrentPage();
            if (state.canGoNext) state.nextPage();
            return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          return Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: state.pageCount == 0
                          ? const SizedBox.shrink()
                          : PdfPageView(
                              document: state.document,
                              pageNumber: state.currentPageNumber,
                              alignment: Alignment.center,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Page ${state.currentPageNumber} / ${state.pageCount}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter: contains table · Space: no table · Arrows: previous/next',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: state.canGoPrevious ? state.previousPage : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous (←)',
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () {
                      state.selectCurrentPage();
                      if (state.canGoNext) state.nextPage();
                    },
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Contains table'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      state.skipCurrentPage();
                      if (state.canGoNext) state.nextPage();
                    },
                    icon: const Icon(Icons.skip_next),
                    label: const Text('No table'),
                  ),
                  const SizedBox(width: 16),
                  IconButton.filled(
                    onPressed: state.canGoNext ? state.nextPage : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next (→)',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
