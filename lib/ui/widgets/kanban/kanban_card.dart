import 'package:project_route_p/ui/cl_theme.dart';
import 'package:project_route_p/ui/widgets/kanban/task.model.dart';
import 'package:project_route_p/ui/widgets/kanban/task_header.widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../layout/constants/sizes.constant.dart';

class KanbanCard extends StatefulWidget {
  const KanbanCard({
    super.key,
    required this.taskItem,
    this.onActionSelect,
  });

  final KanbanTaskItem taskItem;
  final void Function(String value)? onActionSelect;

  @override
  State<KanbanCard> createState() => _KanbanCardState();
}

class _KanbanCardState extends State<KanbanCard> {
  bool isHovering = false;

  void changeHoverState(bool value) {
    return setState(() => isHovering = value);
  }

  double calculateTimeElapsedPercentage(DateTime startDate, DateTime endDate) {
    DateTime now = DateTime.now();

    if (now.isBefore(startDate)) now = startDate;
    if (now.isAfter(endDate)) now = endDate;

    Duration totalDuration = endDate.difference(startDate);
    Duration elapsedTime = now.difference(startDate);

    double percentageElapsed = elapsedTime.inMilliseconds / totalDuration.inMilliseconds;

    return percentageElapsed.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completionInPercent = calculateTimeElapsedPercentage(
      widget.taskItem.startDate,
      widget.taskItem.endDate,
    );

    final hoursDifference = widget.taskItem.endDate.difference(DateTime.now()).inHours;
    final daysLeft = (hoursDifference / 24).floor() + ((hoursDifference % 24) > 1 ? 1 : 0);

    return MouseRegion(
      onEnter: (event) => changeHoverState(true),
      onExit: (event) => changeHoverState(false),
      cursor: SystemMouseCursors.click,
      child: Material(
        color: CLTheme.of(context).secondaryBackground,
        elevation: isHovering ? 4.75 : 0,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        AvatarWidget(
                          initialsOnly: true,
                          fullName: widget.taskItem.title,
                          avatarShape: AvatarShape.roundedRectangle,
                          backgroundColor: CLTheme.of(context).primary,
                          foregroundColor: Colors.black,
                        ),
                        const SizedBox(width: 12),
                        Text(widget.taskItem.title, style: CLTheme.of(context).title)
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    tooltip: "",
                    color: CLTheme.of(context).secondaryBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
                    offset: const Offset(0, 30),
                    itemBuilder: (context) => {
                      "Mostra": Icons.remove_red_eye_rounded,
                      "Modifica": FontAwesomeIcons.copy,
                      "Cancella": Icons.delete,
                    }
                        .entries
                        .map(
                          (e) => PopupMenuItem(
                            value: e.key,
                            child: ListTile(
                              title: Text(
                                e.key,
                                style: CLTheme.of(context).bodyText,
                              ),
                              leading: Icon(
                                e.value,
                                size: Sizes.medium,
                                color: CLTheme.of(context).secondaryText,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onSelected: widget.onActionSelect,
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Task Description
              Text(
                widget.taskItem.description,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(height: 16),

              // Dates
              Row(
                children: [
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        //text: 'Start date\n',
                        text: 'Data Inizio\n',
                        children: [
                          TextSpan(
                            text: DateFormat("dd-mm-yyyy").format(
                              widget.taskItem.startDate,
                            ),
                            style: theme.textTheme.labelLarge,
                          ),
                        ],
                      ),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.checkboxTheme.side?.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16 * 2),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        //text: 'End date\n',
                        text: 'Data fine\n',
                        children: [
                          TextSpan(
                            text: DateFormat("dd-mm-yyyy").format(
                              widget.taskItem.endDate,
                            ),
                            style: theme.textTheme.labelLarge,
                          ),
                        ],
                      ),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.checkboxTheme.side?.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress Indicator
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(completionInPercent * 100).toStringAsFixed(2)}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                minHeight: 10,
                borderRadius: BorderRadius.circular(30),
                value: completionInPercent,
              ),
              const SizedBox(height: 16),

              // Assigned Employees
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  /* Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Assegnato a",
                          //'Assigned to',
                          style: CLTheme.of(context).smallLabel,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 28,
                          width: double.maxFinite,
                          alignment: Alignment.centerRight,
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: List.generate(
                              widget.taskItem.users.length >= 4 ? 4 : widget.taskItem.users.length,
                              (index) {
                                final _image = widget.taskItem.users[index].imagePath;
                                final _initialOnly = index >= 3;
                                return Positioned(
                                  left: (index * 16).toDouble(),
                                  child: AvatarWidget(
                                    size: const Size.square(28),
                                    avatarShape: AvatarShape.circle,
                                    imagePath: _initialOnly ? null : _image,
                                    fullName: _initialOnly ? '+ ${widget.taskItem.users.length - 3}' : null,
                                    initialsOnly: _initialOnly,
                                    backgroundColor: _initialOnly ? Colors.white : null,
                                    foregroundColor: _initialOnly ? _theme.checkboxTheme.side?.color : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),*/
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: CLTheme.of(context).warning.withOpacity(0.20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 16,
                          color: CLTheme.of(context).warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          //'$_daysLeft ${_daysLeft <= 1 ? 'day' : 'days'} left',
                          '$daysLeft ${daysLeft <= 1 ? "giorno" : "giorni"} sinistra',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: CLTheme.of(context).warning,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
