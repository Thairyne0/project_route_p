part of 'paged_datatable.dart';

class _PagedDataTableFilterTab<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final List<Widget> mainMenus;
  final List<TableExtraMenu> extraMenus;
  final Widget? header;
  final bool rowsSelectable;
  final ModelIdGetter<TResultId, TResult> idGetter;
  final Future Function({Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy})? downloadPage;
  final String? downloadButtonText;
  final IconData? downloadButtonIcon;
  final bool isFilterBarRounded;

  const _PagedDataTableFilterTab(
    this.mainMenus,
    this.extraMenus,
    this.header,
    this.rowsSelectable,
    this.idGetter,
    this.downloadPage,
    this.downloadButtonText,
    this.downloadButtonIcon,
    this.isFilterBarRounded,
  );

  @override
  Widget build(BuildContext context) {
    var theme = PagedDataTableTheme.of(context);
    final GlobalKey buttonKey = GlobalKey();
    final GlobalKey buttonExtraMenuKey = GlobalKey();
    return Consumer<_PagedDataTableState<TKey, TResultId, TResult>>(
      builder: (context, state, _) {
        Widget child = Container(
          decoration: BoxDecoration(
            color: CLTheme.of(context).primaryBackground,
            borderRadius:
                isFilterBarRounded
                    ? BorderRadius.only(topLeft: Radius.circular(Sizes.borderRadius), topRight: Radius.circular(Sizes.borderRadius))
                    : null,
          ),
          padding: EdgeInsets.all(ResponsiveBreakpoints.of(context).isDesktop ? Sizes.padding : 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Main menus a sinistra
              if (mainMenus.isNotEmpty) ...mainMenus,
              if (mainMenus.isNotEmpty) SizedBox(width: Sizes.padding),
              // Icona filtri a sinistra (dopo i main menus, solo se ci sono filtri extra)
              if (state.filters.entries.where((element) => element.value._filter.isMainFilter == false).isNotEmpty)
                Tooltip(
                  message: "Mostra tutti i filtri",
                  child: MouseRegion(
                    cursor: state.tableState == _TableState.loading ? SystemMouseCursors.basic : SystemMouseCursors.click,
                    child: IconButton(
                      key: buttonKey,
                      icon: HugeIcon(icon: HugeIcons.strokeRoundedFilterHorizontal, color: CLTheme.of(context).primaryText, size: Sizes.medium),
                      onPressed:
                          state.tableState == _TableState.loading
                              ? null
                              : () {
                                if (ResponsiveBreakpoints.of(context).isDesktop) {
                                  final RenderBox renderBox = buttonKey.currentContext!.findRenderObject() as RenderBox;
                                  final position = renderBox.localToGlobal(Offset.zero);
                                  _showFilterOverlayDesktopFromPosition(context, state, buttonKey, position);
                                } else {
                                  _showFilterOverlayMobile(context, state);
                                }
                              },
                    ),
                  ),
                ),

              // Spacer
              if (ResponsiveBreakpoints.of(context).isDesktop) const Spacer() else const SizedBox(width: Sizes.padding),

              // Download button
              if (this.downloadPage != null) ...[
                CLButton.secondary(
                  text: this.downloadButtonText ?? "Download",
                  icon: this.downloadButtonIcon,
                  onTap: () async {
                    await state._dispatchDownloadCallback();
                  },
                  context: context,
                ),
                const SizedBox(width: Sizes.padding),
              ],

              // Header custom
              if (header != null) ...[Flexible(child: header!), const SizedBox(width: Sizes.padding)],

              // Campo di ricerca a destra (larghezza fissa a 1/4 dello schermo)
              if (state.filters.isNotEmpty && state.filters.entries.where((element) => element.value._filter.isMainFilter == true).isNotEmpty)
                SizedBox(
                  width: MediaQuery.of(context).size.width / 4,
                  child:
                      state.filters.entries.where((element) => element.value._filter.isMainFilter == true).map((entry) {
                        TextTableFilter mainFilter = entry.value._filter as TextTableFilter;
                        mainFilter.onChange = (String value) {
                          entry.value.value = value;
                          if (value.isEmpty) {
                            state.removeFilter(mainFilter.id);
                          } else {
                            state.applyFilters();
                          }
                        };
                        return mainFilter.buildPicker(context, entry.value);
                      }).first,
                ),

              // Extra menu
              if (extraMenus.isNotEmpty)
                IconButton(
                  key: buttonExtraMenuKey,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  padding: const EdgeInsets.only(left: 16),
                  icon: Icon(Icons.more_vert, color: theme.buttonsColor),
                  onPressed: () async {
                    _showExtraMenuOverlay(context, state, buttonExtraMenuKey);
                  },
                ),

              // Checkbox (solo mobile)
              if (rowsSelectable && !ResponsiveBreakpoints.of(context).isDesktop)
                Transform.translate(
                  offset: Offset(6, 0),
                  child: Selector<_PagedDataTableState<TKey, TResultId, TResult>, int>(
                    selector: (context, model) => model._rowsSelectionChange,
                    builder: (context, value, _) {
                      return HookBuilder(
                        builder: (context) {
                          return Checkbox(
                            value:
                                state.selectedRows.isEmpty
                                    ? false
                                    : state._items.every((item) => state.selectedRows.containsKey(idGetter(item)))
                                    ? true
                                    : false,
                            tristate: false,
                            hoverColor: Colors.transparent,
                            overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
                            activeColor: CLTheme.of(context).secondary,
                            onChanged: (newValue) {
                              switch (newValue) {
                                case true:
                                  state.selectAllRows();
                                  break;
                                case false:
                                  state.unselectAllRows();
                                  break;
                                case null:
                                  state.unselectAllRows();
                                  break;
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
        if (theme.headerBackgroundColor != null) {
          child = DecoratedBox(decoration: BoxDecoration(color: theme.headerBackgroundColor), child: child);
        }
        if (theme.chipTheme != null) {
          child = ChipTheme(data: theme.chipTheme!, child: child);
        }
        if (theme.filtersHeaderTextStyle != null) {
          child = DefaultTextStyle(style: theme.filtersHeaderTextStyle!, child: child);
        }
        return child;
      },
    );
  }

  Future<void> _showExtraMenuOverlay(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state, GlobalKey buttonExtraMenuKey) async {
    final RenderBox renderBox = buttonExtraMenuKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    if (ResponsiveBreakpoints.of(context).isDesktop) {
      await showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return Stack(
            children: <Widget>[
              Positioned(
                left: MediaQuery.of(context).size.width - 362,
                top: position.dy + 50,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(Sizes.padding),
                    width: 320.0,
                    decoration: BoxDecoration(
                      color: CLTheme.of(context).secondaryBackground,
                      boxShadow: [BoxShadow(color: CLTheme.of(context).alternate, spreadRadius: 3, blurRadius: 5, offset: const Offset(0, 0))],
                      borderRadius: BorderRadius.circular(Sizes.padding),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Azioni generali", style: CLTheme.of(context).bodyLabel),
                        Divider(thickness: 1.0, color: CLTheme.of(context).alternate),
                        ...extraMenus.map(
                          (menu) => GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              menu.onTap();
                            },
                            child: menu.content,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      await showModalBottomSheet(
        context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(Sizes.padding),
            decoration: BoxDecoration(
              color: CLTheme.of(context).secondaryBackground,
              boxShadow: [BoxShadow(color: CLTheme.of(context).alternate, spreadRadius: 3, blurRadius: 5, offset: const Offset(0, 0))],
              borderRadius: BorderRadius.circular(Sizes.padding),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Azioni generali", style: CLTheme.of(context).bodyLabel),
                Divider(thickness: 1.0, color: CLTheme.of(context).alternate),
                ...extraMenus.map(
                  (menu) => GestureDetector(
                    onTap: () {
                      menu.onTap.call();
                      Navigator.of(context).pop();
                    },
                    child: menu.content,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _showFilterOverlayDesktopFromPosition(
    BuildContext context,
    _PagedDataTableState<TKey, TResultId, TResult> state,
    GlobalKey buttonKey,
    Offset position,
  ) async {
    final RenderBox renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox;
    final screenWidth = MediaQuery.of(context).size.width;
    final menuWidth = (MediaQuery.of(context).size.width / 3);
    double dx = position.dx;
    if (dx + menuWidth > screenWidth) {
      dx = screenWidth - menuWidth;
    }
    var rect = RelativeRect.fromLTRB(dx, position.dy + renderBox.size.height, 0, 0);
    await showDialog(
      context: context,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => _FiltersDialog<TKey, TResultId, TResult>(rect: rect, state: state),
    );
  }

  Future<void> _showFilterOverlayMobile(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FiltersDialogBoxed<TKey, TResultId, TResult>(rect: RelativeRect.fromLTRB(10, 0, 0, 0), state: state),
    );
  }
}

class _FiltersDialogBoxed<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final RelativeRect rect;
  final _PagedDataTableState<TKey, TResultId, TResult> state;

  _FiltersDialogBoxed({required this.rect, required this.state});

  BaseTableColumn<TResult>? selectedColumn;
  bool descending = false;

  @override
  Widget build(BuildContext context) {
    List<Map<BaseTableColumn<TResult>?, bool>> items = [];
    state.columns.where((column) => column.sortable == true).map((column) {
      items.add({column: true});
      items.add({column: false});
    }).toList();
    return CLContainer(
      height: MediaQuery.of(context).size.height * 0.67,
      title: "Filtri di ricerca",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.padding),
                child: Column(
                  children: [
                    CLDropdown<Map<BaseTableColumn<TResult>?, bool>>.singleSync(
                      hint: 'Ordina per',
                      items: items,
                      valueToShow: (item) {
                        if (item.values.toList()[0]) {
                          return "\${item.keys.toList()[0]!.title.toString()} - Discendente";
                        } else {
                          return "\${item.keys.toList()[0]!.title.toString()} - Ascendente";
                        }
                      },
                      itemBuilder: (context, item) {
                        if (item.values.toList()[0]) {
                          return Text("\${item.keys.toList()[0]!.title.toString()} - Discendente");
                        } else {
                          return Text("\${item.keys.toList()[0]!.title.toString()} - Ascendente");
                        }
                      },
                      onSelectItem: (item) {
                        if (item != null) {
                          selectedColumn = item.keys.toList()[0];
                          descending = item.values.toList()[0];
                          return item.keys.toList()[0]?.id == state._sortModel?._columnId;
                        }
                      },
                    ),
                    Form(
                      key: state.filtersFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children:
                            state.filters.entries
                                .where((filter) => filter.value._filter.isMainFilter == false)
                                .where((element) => element.value._filter.visible)
                                .map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: entry.value._filter.buildPicker(context, entry.value),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Sizes.padding),
            child: Row(
              children: [
                CLButton(
                  textStyle: CLTheme.of(context).bodyText,
                  iconAlignment: IconAlignment.start,
                  backgroundColor: CLTheme.of(context).primaryBackground,
                  text: "Ripristina",
                  onTap: () {
                    Navigator.pop(context);
                    state.resetFilterSort();
                  },
                  context: context,
                ),
                const Spacer(),
                CLButton.primary(
                  text: "Applica",
                  onTap: () {
                    state.filtersFormKey.currentState!.save();
                    Navigator.pop(context);
                    state.applyFilters(columnId: selectedColumn?.id!, descending: descending);
                  },
                  context: context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersDialog<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final RelativeRect rect;
  final _PagedDataTableState<TKey, TResultId, TResult> state;

  const _FiltersDialog({required this.rect, required this.state});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        Positioned(
          top: rect.top,
          left: rect.left + 18,
          child: CLContainer(
            contentPadding: const EdgeInsets.all(Sizes.padding),
            showShadow: true,
            width: MediaQuery.of(context).size.width / 3,
            title: "Filtra con...",
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Form(
                    key: state.filtersFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...state.filters.entries
                            .where((element) => element.value._filter.visible && element.value._filter.isMainFilter == false)
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: entry.value._filter.buildPicker(context, entry.value),
                              ),
                            ),
                      ],
                    ),
                  ),
                  SizedBox(height: Sizes.padding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CLButton(
                        textStyle: CLTheme.of(context).bodyText,
                        iconAlignment: IconAlignment.start,
                        backgroundColor: CLTheme.of(context).primaryBackground,
                        text: "Ripristina",
                        onTap: () {
                          Navigator.pop(context);
                          state.resetFilterSort();
                        },
                        context: context,
                      ),
                      CLButton.primary(
                        text: "Applica",
                        onTap: () {
                          state.filtersFormKey.currentState!.save();
                          Navigator.pop(context);
                          state.applyFilters();
                        },
                        context: context,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
