import 'package:appflowy_board/appflowy_board.dart';
import 'package:project_route_p/ui/cl_theme.dart';
import 'package:project_route_p/ui/widgets/kanban/task.model.dart';
import 'package:flutter/material.dart';

import '../../layout/constants/sizes.constant.dart';
import 'kanban_card.dart';

class Kanban extends StatefulWidget {
  const Kanban({super.key, this.groupsData = const []});

  final List<KanbanTaskItem> groupsData;

  @override
  State<Kanban> createState() => _KanbanState();
}

class _KanbanState extends State<Kanban> {
  AppFlowyBoardController boardController = AppFlowyBoardController(
    onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
      print(fromGroupId);
      print(fromIndex);
      print(toGroupId);
      print(toIndex);
    },
    onMoveGroupItem: (groupId, fromIndex, toIndex) {
      print(groupId);
      print(fromIndex);
      print(toIndex);
    },
    onMoveGroupItemToGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
      print(fromGroupId);
      print(fromIndex);
      print(toGroupId);
      print(toIndex);
    },
  );
  final boardScrollController = AppFlowyBoardScrollController();

  @override
  void initState() {
    boardController.addGroup(
      AppFlowyGroupData(
        id: "1",
        // name: 'In Progress',
        name: "Da Fare",
        items: [...widget.groupsData.take(1)],
      ),
    );
    boardController.addGroup(
      AppFlowyGroupData(
        id: "2",
        // name: 'In Progress',
        name: "In corso",
        items: [...widget.groupsData.skip(3)],
      ),
    );
    boardController.addGroup(
      AppFlowyGroupData(
        id: "3",
        // name: 'In Progress',
        name: "Completate",
        items: [...widget.groupsData.skip(2)],
      ),
    );
    boardController.addGroup(
      AppFlowyGroupData(
        id: "4",
        // name: 'In Progress',
        name: "Annullate",
        items: [...widget.groupsData.skip(1)],
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppFlowyBoard(
      controller: boardController,
      boardScrollController: boardScrollController,
      cardBuilder: (context, group, kanbanItem) {
        final item = kanbanItem as KanbanTaskItem;
        return AppFlowyGroupCard(
          key: ObjectKey(item),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: KanbanCard(
            taskItem: item,
            onActionSelect: (value) {
              return switch (value) {
                'View' => _handleViewTask(context, item),
                'Delete' => _handleDeleteTask(
                    context,
                    group: group,
                    item: item,
                  ),
                _ => null,
              };
            },
          ),
        );
      },
      groupConstraints: const BoxConstraints.tightFor(width: 375),
      config: AppFlowyBoardConfig(
        groupBackgroundColor: CLTheme.of(context).secondary.withOpacity(Sizes.opacity),
        groupMargin: EdgeInsets.symmetric(horizontal: 12),
        cardMargin: EdgeInsets.all(20),
        groupBodyPadding: EdgeInsets.all(12),
      ),
      headerBuilder: (context, groupData) => _buildGroupHeader(
        context,
        groupData,
      ),
      trailing: Padding(
        padding: const EdgeInsetsDirectional.only(start: 24),
        child: ElevatedButton.icon(
          onPressed: () async {
            final result = await showDialog<AppFlowyGroupData<Color>?>(
              context: context,
              builder: (context) => Container(),
            );

            if (result != null) {
              boardController.addGroup(result);
            }
          },
          icon: const Icon(Icons.add_circle_outline_outlined),
          //label: const Text('Add New Board'),
          label: Padding(
            padding: EdgeInsets.all(22),
            child: Text("Aggiungi nuova board", style: CLTheme.of(context).bodyText),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            fixedSize: const Size.fromWidth(372),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(Sizes.borderRadius), topRight: Radius.circular(Sizes.borderRadius)),
            ),
            backgroundColor: CLTheme.of(context).secondaryBackground,
            foregroundColor: CLTheme.of(context).primaryText,
          ),
        ),
      ),
    );
  }

  void _handleViewTask(BuildContext context, KanbanTaskItem item) async {
    await showDialog(
      context: context,
      builder: (context) => Container(),
    );
  }

  void _handleDeleteTask(
    BuildContext context, {
    required AppFlowyGroupData group,
    required KanbanTaskItem item,
  }) async {
    return boardController.removeGroupItem(
      group.id,
      item.id,
    );
  }

  Widget _buildGroupHeader(
    BuildContext context,
    AppFlowyGroupData groupData,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: CLTheme.of(context).secondaryBackground,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: CLTheme.of(context).primary,
              width: 2,
            ),
          ),
        ),
        padding: const EdgeInsetsDirectional.symmetric(vertical: 4, horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(groupData.headerData.groupName, style: CLTheme.of(context).heading4),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      return boardController.removeGroup(groupData.id);
                    },
                    icon: const Icon(Icons.delete),
                    color: CLTheme.of(context).secondaryText,
                  ),
                  IconButton(
                    onPressed: () async {
                      final result = await showDialog<KanbanTaskItem?>(
                        context: context,
                        builder: (context) => Container(),
                      );

                      if (result != null) {
                        boardController.addGroupItem(groupData.id, result);
                      }
                    },
                    icon: const Icon(Icons.add),
                    color: CLTheme.of(context).secondaryText,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
