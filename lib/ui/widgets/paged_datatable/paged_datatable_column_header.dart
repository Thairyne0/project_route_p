part of 'paged_datatable.dart';

class _PagedDataTableHeaderRow<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final bool rowsSelectable;
  final double width;
  final ModelIdGetter<TResultId, TResult> idGetter;

  const _PagedDataTableHeaderRow(this.rowsSelectable, this.width, this.idGetter);

  @override
  Widget build(BuildContext context) {
    var theme = PagedDataTableTheme.of(context);

    Widget child = Container(
      decoration: BoxDecoration(
        color: CLTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Sizes.borderRadius),
          topRight: Radius.circular(Sizes.borderRadius)
        ),
      ),
      height: theme.configuration.columnsHeaderHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          /* COLUMNS */
          Selector<_PagedDataTableState<TKey, TResultId, TResult>, int>(
              selector: (context, state) => state._sortChange,
              builder: (context, isSorted, child) {
                var state = context.read<_PagedDataTableState<TKey, TResultId, TResult>>();
                return Padding(
                  padding: EdgeInsets.only(left: rowsSelectable ? Sizes.padding : 0),
                  child: Row(children: [
                    if (rowsSelectable)
                      Selector<_PagedDataTableState<TKey, TResultId, TResult>, int>(
                          selector: (context, model) => model._rowsSelectionChange,
                          builder: (context, value, child) {
                            return Padding(
                              padding: EdgeInsets.zero,
                              child: SizedBox(
                                width: Sizes.padding,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Checkbox(
                                    value: state.selectedRows.isEmpty
                                        ? false
                                        : state._items.every((item) => state.selectedRows.containsKey(idGetter(item)))
                                            ? true
                                            : false,
                                    tristate: false,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    hoverColor: Colors.transparent,
                                    overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
                                    activeColor: CLTheme.of(context).primary,
                                    checkColor: Colors.white,
                                    side: WidgetStateBorderSide.resolveWith(
                                      (states) => BorderSide(
                                        color: states.contains(WidgetState.selected)
                                            ? CLTheme.of(context).primary
                                            : CLTheme.of(context).borderColor,
                                        width: 1,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
                                    ),
                                    onChanged: (newValue) {
                                      switch (newValue) {
                                        case true:
                                          state.selectAllRows();
                                          break;
                                        case false:
                                          state.unselectAllRows();
                                          break;
                                        case null:
                                          if (state.selectedRows.length == state._items.length) {
                                            state.unselectAllRows();
                                          }
                                          break;
                                      }
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),
                    ...state.columns.map((column) {
                      Widget child = MouseRegion(
                        cursor: column.sortable ? SystemMouseCursors.click : SystemMouseCursors.basic,
                        child: GestureDetector(
                          onTap: column.sortable
                              ? () {
                                  state.swapSortBy(column.id!);
                                }
                              : null,
                          child: Row(
                            mainAxisAlignment: column.isNumeric ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              Flexible(child: column.title),
                              if (state.hasSortModel && state._sortModel!.columnId == column.id) ...[
                                const SizedBox(width: 8),
                                state._sortModel!._descending
                                    ? Icon(
                                        Icons.arrow_drop_up_outlined,
                                        size: Sizes.large,
                                        color: CLTheme.of(context).primary,
                                      )
                                    : Icon(Icons.arrow_drop_down_outlined, size: Sizes.large, color: CLTheme.of(context).primary),
                              ],
                            ],
                          ),
                        ),
                      );

                      child = Container(
                          padding: EdgeInsets.symmetric(horizontal: Sizes.padding),
                          width: column.sizeFactor == null ? state._nullSizeFactorColumnsWidth : width * column.sizeFactor!,
                          child: child);
                      return child;
                    }),
                  ]),
                );
              }),

          /* LOADING INDICATOR */
          Positioned(
              bottom: 0,
              width: MediaQuery.of(context).size.width,
              child: Selector<_PagedDataTableState<TKey, TResultId, TResult>, _TableState>(
                  selector: (context, state) => state._state,
                  builder: (context, tableState, child) {
                    return AnimatedOpacity(
                        opacity: tableState == _TableState.loading ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: LinearProgressIndicator(color: CLTheme.of(context).primary));
                  })),
        ],
      ),
    );

    if (theme.headerBackgroundColor != null) {
      child = DecoratedBox(
        decoration: BoxDecoration(color: theme.headerBackgroundColor),
        child: child,
      );
    }

    if (theme.headerTextStyle != null) {
      child = DefaultTextStyle(
        style: theme.headerTextStyle!,
        child: child,
      );
    }

    return child;
  }
}
