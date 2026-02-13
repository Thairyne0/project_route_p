part of 'paged_datatable.dart';

class _PagedDataTableRows<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final WidgetBuilder? noItemsFoundBuilder;
  final ErrorBuilder? errorBuilder;
  final bool rowsSelectable;
  final double width;
  final CustomRowBuilder<TResult> customRowBuilder;
  final List<TableAction<TResult>> tableActions;
  final List<TableAction<TResult>> Function(TResult item)? actionsBuilder;
  final Function(TResult)? onItemTap;
  final bool isInSnippet;
  final Function(TResult)? actionsTitle;
  final int initialPageSize;
  final bool showShimmerLoading;
  final Widget Function(BuildContext context, TResult item)? expandedRowBuilder;
  final Future<void> Function(TResult item)? onRowExpanded;

  const _PagedDataTableRows(
    this.rowsSelectable,
    this.onItemTap,
    this.isInSnippet,
    this.customRowBuilder,
    this.noItemsFoundBuilder,
    this.errorBuilder,
    this.width,
    this.actionsTitle,
    this.tableActions,
    this.actionsBuilder,
    this.initialPageSize,
    this.showShimmerLoading,
    this.expandedRowBuilder,
    this.onRowExpanded,
  );

  @override
  Widget build(BuildContext context) {
    final theme = PagedDataTableTheme.of(context);

    return Selector<_PagedDataTableState<TKey, TResultId, TResult>, int>(
      selector: (context, model) => model._rowsChange,
      builder: (context, _, child) {
        var state = context.read<_PagedDataTableState<TKey, TResultId, TResult>>();

        // Se loading e non ci sono righe e shimmer è abilitato, mostra shimmer
        if (showShimmerLoading && state.tableState == _TableState.loading && state._rowsState.isEmpty) {
          return _buildShimmerRows(context, state);
        }

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: state.tableState == _TableState.loading ? .3 : 1,
          child: DefaultTextStyle(overflow: TextOverflow.ellipsis, style: theme.rowsTextStyle, child: _build(context, state, theme)),
        );
      },
    );
  }

  Widget _buildShimmerRows(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state) {
    // Calcola il numero di colonne includendo la checkbox se rowsSelectable è true
    final columnsCount = state.columns.length + (rowsSelectable ? 1 : 0);
    return CLShimmerTableRows(rowCount: initialPageSize, rowHeight: 48, columnsCount: columnsCount > 0 ? columnsCount : 4, hasCheckboxColumn: rowsSelectable);
  }

  Widget _build(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state, PagedDataTableThemeData theme) {
    if (state._rowsState.isEmpty && state.tableState == _TableState.displaying) {
      return noItemsFoundBuilder?.call(context) ??
          Center(child: Padding(padding: EdgeInsets.all(Sizes.verticalPadding), child: Text("Nessun elemento trovato", style: CLTheme.of(context).bodyLabel)));
    }

    if (state.tableState == _TableState.error) {
      return errorBuilder?.call(state.currentError!) ??
          Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text("An error ocurred.\n${state.currentError}", textAlign: TextAlign.center)));
    }
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      separatorBuilder: (_, __) => theme.dividerColor == null ? Divider(height: 0, color: CLTheme.of(context).borderColor, thickness: 1) : SizedBox.shrink(),
      itemCount: state._rowsState.length,
      shrinkWrap: true,
      itemBuilder:
          (context, index) => ChangeNotifierProvider<_PagedDataTableRowState<TResultId, TResult>>.value(
            value: state._rowsState[index],
            child: Consumer<_PagedDataTableRowState<TResultId, TResult>>(
              builder: (context, model, child) {
                return _HoverableRow<TKey, TResultId, TResult>(
                  model: model,
                  state: state,
                  rowsSelectable: rowsSelectable,
                  onItemTap: onItemTap,
                  width: width,
                  tableActions: tableActions,
                  actionsBuilder: actionsBuilder,
                  actionsTitle: actionsTitle,
                  expandedRowBuilder: expandedRowBuilder,
                  onRowExpanded: onRowExpanded,
                );
              },
            ),
          ),
    );
  }
}

class _HoverableRow<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatefulWidget {
  final _PagedDataTableRowState<TResultId, TResult> model;
  final _PagedDataTableState<TKey, TResultId, TResult> state;
  final bool rowsSelectable;
  final Function(TResult)? onItemTap;
  final double width;
  final List<TableAction<TResult>> tableActions;
  final List<TableAction<TResult>> Function(TResult item)? actionsBuilder;
  final Function(TResult)? actionsTitle;
  final Widget Function(BuildContext context, TResult item)? expandedRowBuilder;
  final Future<void> Function(TResult item)? onRowExpanded;

  const _HoverableRow({
    required this.model,
    required this.state,
    required this.rowsSelectable,
    required this.onItemTap,
    required this.width,
    required this.tableActions,
    required this.actionsBuilder,
    required this.actionsTitle,
    this.expandedRowBuilder,
    this.onRowExpanded,
  });

  @override
  State<_HoverableRow<TKey, TResultId, TResult>> createState() => _HoverableRowState<TKey, TResultId, TResult>();
}

class _HoverableRowState<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends State<_HoverableRow<TKey, TResultId, TResult>> {
  bool _isHovered = false;
  bool _isDialogOpen = false;
  bool _isExpanded = false;
  bool _isLoadingExpanded = false;

  @override
  Widget build(BuildContext context) {
    GlobalKey iconKey = GlobalKey();
    final model = widget.model;
    final state = widget.state;
    final actions = widget.actionsBuilder?.call(model.item) ?? widget.tableActions;
    final showControls = _isHovered || model._isSelected || _isDialogOpen;
    final hasExpandedBuilder = widget.expandedRowBuilder != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit:
              (_) => setState(() {
                if (!_isDialogOpen) {
                  _isHovered = false;
                }
              }),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              // Se c'è un expandedRowBuilder, gestisci l'espansione
              if (hasExpandedBuilder) {
                if (_isExpanded) {
                  setState(() => _isExpanded = false);
                } else {
                  setState(() {
                    _isExpanded = true;
                    _isLoadingExpanded = true;
                  });
                  if (widget.onRowExpanded != null) {
                    await widget.onRowExpanded!(model.item);
                  }
                  if (mounted) {
                    setState(() => _isLoadingExpanded = false);
                  }
                }
              }
              // Chiama anche onItemTap se definito
              if (widget.onItemTap != null) {
                widget.onItemTap!(model.item);
              }
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              constraints: BoxConstraints(minHeight: 56),
              // Altezza minima fissa
              width: double.infinity,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(color: model._isSelected || _isHovered || _isExpanded ? CLTheme.of(context).alternate.withValues(alpha: 0.5) : null),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Forza tutti i figli ad avere la stessa altezza
                  children: [
                    // Icona di espansione se c'è un expandedRowBuilder
                    if (hasExpandedBuilder)
                      Padding(
                        padding: const EdgeInsets.only(left: Sizes.padding),
                        child: SizedBox(
                          width: 24,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                              size: 20,
                              color: CLTheme.of(context).secondaryText,
                            ),
                          ),
                        ),
                      ),
                    if (widget.rowsSelectable)
                      Padding(
                        padding: const EdgeInsets.only(left: Sizes.padding),
                        child: SizedBox(
                          width: Sizes.padding,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Visibility(
                              visible: showControls,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
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
                          ),
                        ),
                      ),
                    ...state.columns.map(
                      (column) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.verticalPadding),
                        width: column.sizeFactor == null ? state._nullSizeFactorColumnsWidth : widget.width * column.sizeFactor!,
                        child: Align(
                          alignment: column.isNumeric ? Alignment.centerRight : Alignment.centerLeft,
                          child: column.buildCell(model.item, model.index),
                        ),
                      ),
                    ),
                    SizedBox(width: widget.width * (1 - state.columns.fold(0.0, (sum, column) => sum + column.sizeFactor!))),
                    actions.isEmpty
                        ? const SizedBox.shrink()
                        : SizedBox(
                          width: 32,
                          child: Visibility(
                            visible: showControls,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: InkWell(
                              onTap: () async {
                                setState(() => _isDialogOpen = true);
                                final RenderBox renderBox = iconKey.currentContext!.findRenderObject() as RenderBox;
                                final Offset position = renderBox.localToGlobal(Offset.zero);
                                final double screenHeight = MediaQuery.of(context).size.height;
                                bool openUpwards = position.dy + 200 > screenHeight;
                                await showDialog(
                                  context: context,
                                  barrierColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return Stack(
                                      children: <Widget>[
                                        Positioned(
                                          right: 50,
                                          top: !openUpwards ? position.dy + 40 : null,
                                          bottom: openUpwards ? screenHeight - position.dy + 40 - renderBox.size.height : null,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: IntrinsicWidth(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: CLTheme.of(context).secondaryBackground,
                                                  boxShadow: [
                                                    BoxShadow(color: CLTheme.of(context).alternate, spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 0)),
                                                  ],
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: Sizes.padding),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: Sizes.padding),
                                                      child: Text(widget.actionsTitle?.call(model.item) ?? "Azioni", style: CLTheme.of(context).bodyLabel),
                                                    ),
                                                    SizedBox(height: Sizes.padding / 2),
                                                    Divider(color: CLTheme.of(context).borderColor),
                                                    SizedBox(height: Sizes.padding / 2),
                                                    ...actions.asMap().entries.map((entry) {
                                                      final index = entry.key;
                                                      final tableAction = entry.value;

                                                      return InkWell(
                                                        onTap: () {
                                                          Navigator.of(context).pop();
                                                          tableAction.onTap.call(model.item);
                                                        },
                                                        child: Padding(
                                                          padding: EdgeInsets.only(
                                                            left: Sizes.padding,
                                                            right: Sizes.padding,
                                                            bottom: index == actions.length - 1 ? 0 : Sizes.padding,
                                                          ),
                                                          child: tableAction.content,
                                                        ),
                                                      );
                                                    }).toList(),
                                                    SizedBox(height: Sizes.padding),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                setState(() {
                                  _isDialogOpen = false;
                                  _isHovered = false;
                                });
                              },
                              child: Container(
                                key: iconKey,
                                alignment: Alignment.center,
                                child: HugeIcon(icon: HugeIcons.strokeRoundedMoreVerticalCircle01, size: Sizes.medium, color: CLTheme.of(context).primaryText),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Contenuto espanso
        if (_isExpanded && hasExpandedBuilder)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: CLTheme.of(context).secondaryBackground,
              border: Border(left: BorderSide(color: CLTheme.of(context).primary, width: 3)),
            ),
            padding: const EdgeInsets.all(Sizes.padding),
            child:
                _isLoadingExpanded
                    ? Center(child: Padding(padding: const EdgeInsets.all(Sizes.padding), child: CircularProgressIndicator(color: CLTheme.of(context).primary)))
                    : widget.expandedRowBuilder!(context, model.item),
          ),
      ],
    );
  }
}

class _RowSelectorCheckbox<TResultId extends Comparable, TResult extends Object> extends HookWidget {
  final bool isSelected;
  final void Function(bool newValue) setSelected;

  const _RowSelectorCheckbox({required this.isSelected, required this.setSelected});

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: isSelected,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      hoverColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
      activeColor: CLTheme.of(context).primary,
      checkColor: Colors.white,
      side: WidgetStateBorderSide.resolveWith(
        (states) => BorderSide(color: states.contains(WidgetState.selected) ? CLTheme.of(context).primary : CLTheme.of(context).borderColor, width: 1),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
      tristate: false,
      onChanged: (newValue) => setSelected(newValue ?? false),
    );
  }
}
