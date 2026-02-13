import 'package:flutter/material.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../cl_container.widget.dart';
import 'cl_tab_item.model.dart';

class CLTabView extends StatefulWidget {
  final List<CLTabItem> clTabItems;
  final bool indicator;
  final String? title;
  final bool showDivider;

  const CLTabView({
    super.key,
    required this.clTabItems,
    this.title,
    this.indicator = false,
    this.showDivider = false,
  });

  @override
  State<CLTabView> createState() => _CLTabViewState();
}

class _CLTabViewState extends State<CLTabView> with SingleTickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: widget.clTabItems.length, vsync: this,animationDuration: Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    return CLContainer(
      title: widget.title,
      child: DefaultTabController(
        length: widget.clTabItems.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              splashBorderRadius: BorderRadius.circular(Sizes.borderRadius),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              indicatorSize: TabBarIndicatorSize.tab,
              controller: tabController,
              indicatorColor: CLTheme.of(context).primary,
              indicatorWeight: 2.0,
              dividerColor: widget.showDivider ? CLTheme.of(context).alternate : Colors.transparent,
              unselectedLabelColor: CLTheme.of(context).secondaryText,
              labelStyle: CLTheme.of(context).bodyLabel.merge(TextStyle(color: widget.indicator ? Colors.white : CLTheme.of(context).primary)),
              onTap: (_) {
                setState(() {});
              },
              indicator: widget.indicator
                  ? BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: tabController.index == 0 && widget.title == null ? const Radius.circular(Sizes.borderRadius) : Radius.zero,
                  topRight: tabController.index == widget.clTabItems.length - 1 && widget.title == null
                      ? const Radius.circular(Sizes.borderRadius)
                      : Radius.zero,
                ),
                color: CLTheme.of(context).primary,
              )
                  : null,
              tabs: widget.clTabItems.map((tab) {
                return Tab(
                  text: tab.tabName,
                );
              }).toList(),
            ),
            // Utilizziamo IndexedStack per gestire il contenuto delle tab
            IndexedStack(
              index: tabController.index,
              children: List.generate(widget.clTabItems.length, (index) {
                return Visibility(
                  visible: tabController.index == index,
                  child: Column(
                    children: [
                      widget.clTabItems[index].tabContent,
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
