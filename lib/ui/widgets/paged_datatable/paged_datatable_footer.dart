part of 'paged_datatable.dart';

class _PagedDataTableFooter<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final PagedDataTableThemeData themeData;

  const _PagedDataTableFooter({required this.themeData});

  @override
  Widget build(BuildContext context) {
    return Consumer<_PagedDataTableState<TKey, TResultId, TResult>>(
      builder: (context, state, child) {
        Widget child = Padding(
          padding: const EdgeInsets.symmetric(vertical: Sizes.padding, horizontal: Sizes.padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Pulsanti per elementi per pagina
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Elementi per pagina:', style: themeData.footerTextStyle ?? CLTheme.of(context).bodyText),
                  const SizedBox(width: Sizes.padding),
                  ...(themeData.configuration.pageSizes ?? [5, 25, 50, 100]).map((pageSize) {
                    final isSelected = state._pageSize == pageSize;
                    return Padding(
                      padding: const EdgeInsets.only(right: Sizes.padding / 2),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (!isSelected) {
                              state.setPageSize(pageSize);
                            }
                          },
                          borderRadius: BorderRadius.circular(Sizes.borderRadius),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding / 1.5),
                            decoration: BoxDecoration(
                              color: isSelected ? CLTheme.of(context).borderColor : CLTheme.of(context).primaryBackground,
                              borderRadius: BorderRadius.circular(Sizes.borderRadius),
                            ),
                            child: Text(
                              pageSize.toString(),
                              style: (themeData.footerTextStyle ?? CLTheme.of(context).bodyText).override(
                                color: CLTheme.of(context).primaryText,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(width: Sizes.padding),
                  Text('Totale: ${state.totalElement} elementi', style: themeData.footerTextStyle ?? CLTheme.of(context).bodyText),
                ],
              ),
              // Navigazione pagine
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CLButton(
                    context: context,
                    text: '',
                    backgroundColor: CLTheme.of(context).primaryBackground,
                    iconAlignment: IconAlignment.start,
                    hugeIcon: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      color:
                          (state.hasPreviousPage && state.tableState != _TableState.loading)
                              ? CLTheme.of(context).primaryText
                              : CLTheme.of(context).secondaryText,
                      size: Sizes.medium,
                    ),
                    onTap: (state.hasPreviousPage && state.tableState != _TableState.loading) ? state.previousPage : () {},
                  ),
                  const SizedBox(width: Sizes.padding),
                  Text('${state.currentPage + 1}', style: themeData.footerTextStyle ?? CLTheme.of(context).bodyText),
                  const SizedBox(width: Sizes.padding),
                  CLButton(
                    context: context,
                    text: '',
                    backgroundColor: CLTheme.of(context).primaryBackground,
                    iconAlignment: IconAlignment.start,
                    hugeIcon: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color:
                          (state.hasNextPage && state.tableState != _TableState.loading)
                              ? CLTheme.of(context).primaryText
                              : CLTheme.of(context).secondaryText,
                      size: Sizes.medium,
                    ),
                    onTap: (state.hasNextPage && state.tableState != _TableState.loading) ? state.nextPage : () {},
                  ),
                ],
              ),
            ],
          ),
        );

        if (themeData.headerBackgroundColor != null) {
          child = DecoratedBox(decoration: BoxDecoration(color: themeData.headerBackgroundColor), child: child);
        }

        if (themeData.footerTextStyle != null) {
          child = DefaultTextStyle(style: themeData.footerTextStyle!, child: child);
        }

        return child;
      },
    );
  }
}
