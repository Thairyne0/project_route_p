part of 'paged_datatable.dart';

class _PagedDataTableBoxed<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final WidgetBuilder? noItemsFoundBuilder;
  final ErrorBuilder? errorBuilder;
  final double width;
  final CustomRowBuilder<TResult> customRowBuilder;
  final List<TableAction<TResult>> tableActions;
  final List<TableAction<TResult>> Function(TResult item)? actionsBuilder;
  final Function(TResult)? onItemTap;
  final bool isInSnippet;
  final bool rowsSelectable;
  final Function(TResult)? actionsTitle;

  const _PagedDataTableBoxed(this.rowsSelectable, this.onItemTap, this.isInSnippet, this.customRowBuilder, this.noItemsFoundBuilder, this.errorBuilder,
      this.width, this.actionsTitle, this.tableActions, this.actionsBuilder);

  @override
  Widget build(BuildContext context) {
    final theme = PagedDataTableTheme.of(context);

    return Selector<_PagedDataTableState<TKey, TResultId, TResult>, int>(
      selector: (context, model) => model._rowsChange,
      builder: (context, _, child) {
        var state = context.read<_PagedDataTableState<TKey, TResultId, TResult>>();
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: state.tableState == _TableState.loading ? .3 : 1,
          child: DefaultTextStyle(overflow: TextOverflow.ellipsis, style: theme.rowsTextStyle, child: _build(context, state, theme)),
        );
      },
    );
  }

  Widget _build(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state, PagedDataTableThemeData theme) {
    if (state._rowsState.isEmpty && state.tableState == _TableState.displaying) {
      return noItemsFoundBuilder?.call(context) ??
          const Center(child: Padding(padding: EdgeInsets.only(top: 25.0, bottom: 15.0), child: Text("Nessun item trovato")));
    }
    if (state.tableState == _TableState.error) {
      return errorBuilder?.call(state.currentError!) ??
          Center(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("An error ocurred.\n${state.currentError}", textAlign: TextAlign.center),
          ));
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: state._rowsState.length,
      shrinkWrap: true,
      itemBuilder: (context, index) => ChangeNotifierProvider<_PagedDataTableRowState<TResultId, TResult>>.value(
        value: state._rowsState[index],
        child: Consumer<_PagedDataTableRowState<TResultId, TResult>>(
          builder: (context, model, child) {
            if (customRowBuilder.shouldUse(context, model.item)) {
              return SizedBox(
                height: theme.configuration.rowHeight,
                child: customRowBuilder.builder(context, model.item),
              );
            }
            return !this.isInSnippet
                ? IntrinsicHeight(
                    child: Container(
                      padding: const EdgeInsets.all(Sizes.padding - 5),
                      margin: EdgeInsets.only(top: Sizes.padding),
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? theme.rowColors![0] : theme.rowColors![1],
                        borderRadius: BorderRadius.circular(Sizes.borderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: CLTheme.of(context).alternate,
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...state.columns.asMap().entries.map((entry) {
                                  final column = entry.value;
                                  final index = entry.key;
                                  Widget item = column.buildCell(model.item, model.index);

                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: column.title),
                                          item is Text
                                              ? Expanded(
                                                  child: Text(
                                                  item.data.toString(),
                                                  style: item.style ?? CLTheme.of(context).bodyText,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.end,
                                                ))
                                              : Expanded(child: Align(alignment: Alignment.centerRight, child: item))
                                        ],
                                      ),
                                      if (index < state.columns.length - 1)
                                        Divider(
                                          thickness: 1,
                                          color: CLTheme.of(context).alternate,
                                        )
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (rowsSelectable)
                                  Transform.translate(
                                    offset: Offset(6, -6), // Sposta il Checkbox verso l'alto
                                    child: _RowSelectorCheckbox(
                                      isSelected: model._isSelected,
                                      setSelected: (newValue) {
                                        if (newValue) {
                                          state.selectRow(model.itemId);
                                        } else {
                                          state.unselectRow(model.itemId);
                                        }
                                      },
                                    ),
                                  ),
                                GestureDetector(
                                  onTapDown: (details) {
                                    final actionsList = actionsBuilder?.call(model.item) ?? tableActions;
                                    if (actionsList.isNotEmpty) {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return CLContainer(
                                            title: actionsTitle?.call(model.item) ?? "Azioni",
                                            child: Padding(
                                              padding: const EdgeInsets.all(Sizes.padding),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                padding: EdgeInsets.zero,
                                                itemCount: actionsList.length,
                                                itemBuilder: (context, index) {
                                                  return GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context).pop();
                                                        actionsList[index].onTap(model.item);
                                                      },
                                                      child: actionsList[index].content);
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Center(
                                      child: Icon(
                                        Icons.more_vert,
                                        color: CLTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox.shrink()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.all(Sizes.padding),
                    decoration: BoxDecoration(
                        color: index % 2 == 0 ? theme.rowColors![0] : theme.rowColors![1],
                        border: index < state._rowsState.length - 1
                            ? Border(
                                bottom: BorderSide(
                                  color: Colors.grey, // Colore del bordo
                                  width: 1.0, // Spessore del bordo
                                ),
                              )
                            : null),
                    width: 52,
                    // Consider removing this fixed width if it's not needed
                    child: Ink(
                      padding: EdgeInsets.zero,
                      color: model._isSelected ? Theme.of(context).primaryColorLight : null,
                      child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onItemTap != null ? () => onItemTap!(model.item) : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ...state.columns.asMap().entries.map(
                                      (entry) {
                                        final column = entry.value;
                                        final index = entry.key;
                                        return Column(
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                    width: column.sizeFactor == null ? state._nullSizeFactorColumnsWidth : width * 0.3, child: column.title),
                                                SizedBox(
                                                    width: column.sizeFactor == null ? state._nullSizeFactorColumnsWidth : width * 0.6,
                                                    child: column.buildCell(model.item, model.index)),
                                              ],
                                            ),
                                            if (index < state.columns.length - 1) // Verifica se non è l'ultima colonna
                                              Divider(
                                                thickness: 1,
                                                color: CLTheme.of(context).alternate,
                                              )
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTapDown: (details) {
                                  final actionsList = actionsBuilder?.call(model.item) ?? tableActions;
                                  if (actionsList.isNotEmpty) {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return CLContainer(
                                          title: "Azioni su ",
                                          child: Padding(
                                            padding: const EdgeInsets.all(Sizes.padding),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              itemCount: actionsList.length,
                                              itemBuilder: (context, index) {
                                                return actionsList[index].content;
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Icon(
                                    Icons.more_vert,
                                    color: CLTheme.of(context).primary,
                                  ),
                                ),
                              )
                            ],
                          )),
                    ));
          },
        ),
      ),
    );
  }
}
