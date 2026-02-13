import 'package:flutter/material.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_confirm_dialog.dart';

class CLActionText extends StatefulWidget {
  final Color color;
  final String text;
  final Function() onTap;
  final BuildContext context;
  final IconData? iconData;
  final double? width;
  final bool needConfirmation;
  final String? confirmationMessage;
  final Color? foregroundColor;
  final Color? hoverColor;
  final bool enableHover;

  const CLActionText({
    super.key,
    required this.color,
    required this.text,
    required this.onTap,
    required this.context,
    this.iconData,
    this.needConfirmation = false,
    this.confirmationMessage,
    this.width,
    this.foregroundColor,
    this.hoverColor = Colors.green,
    this.enableHover = false,
  });

  // Factory method per Success button
  factory CLActionText.primary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    IconData? icon,
    Color? foregroundColor,
    Color? hoverColor,
    bool enableHover = false,
    double? width,
  }) {
    return CLActionText(
      text: text,
      color: CLTheme.of(context).primary,
      onTap: onTap,
      context: context,
      iconData: icon,
      width: width,
      enableHover: enableHover,
      hoverColor: hoverColor,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  // Factory method per Success button
  factory CLActionText.secondary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    IconData? icon,
    Color? hoverColor,
    Color? foregroundColor,
    bool enableHover = false,
    double? width,
  }) {
    return CLActionText(
      enableHover: enableHover,
      text: text,
      color: CLTheme.of(context).secondary,
      onTap: onTap,
      context: context,
      hoverColor: hoverColor,
      iconData: icon,
      width: width,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  // Factory method per Success button
  factory CLActionText.success({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    Color? foregroundColor,
    Color? hoverColor,
    bool enableHover = false,
    IconData? icon,
    double? width,
  }) {
    return CLActionText(
      enableHover: enableHover,
      text: text,
      color: CLTheme.of(context).success,
      onTap: onTap,
      context: context,
      iconData: icon,
      foregroundColor: foregroundColor,
      width: width,
      hoverColor: hoverColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  // Factory method per Info button
  factory CLActionText.info({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    Color? hoverColor,
    Color? foregroundColor,
    bool enableHover = false,
    IconData? icon,
    double? width,
  }) {
    return CLActionText(
      enableHover: enableHover,
      text: text,
      color: CLTheme.of(context).info,
      context: context,
      onTap: onTap,
      iconData: icon,
      foregroundColor: foregroundColor,
      width: width,
      hoverColor: hoverColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  // Factory method per Warning button
  factory CLActionText.warning({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    bool enableHover = false,
    String? confirmationMessage,
    Color? hoverColor,
    Color? foregroundColor,
    IconData? icon,
    double? width,
  }) {
    return CLActionText(
      enableHover: enableHover,
      context: context,
      text: text,
      color: CLTheme.of(context).warning,
      onTap: onTap,
      iconData: icon,
      hoverColor: hoverColor,
      width: width,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  // Factory method per Danger button
  factory CLActionText.danger({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    Color? foregroundColor,
    Color? hoverColor,
    bool enableHover = false,
    IconData? icon,
    double? width,
  }) {
    return CLActionText(
      enableHover: enableHover,
      context: context,
      text: text,
      color: CLTheme.of(context).danger,
      onTap: onTap,
      iconData: icon,
      hoverColor: hoverColor,
      width: width,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  @override
  State<CLActionText> createState() => _CLActionTextState();
}

class _CLActionTextState extends State<CLActionText> {
  bool loading = false;
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: MouseRegion(
        onEnter: (hover) {
          widget.enableHover
              ? setState(() {
                isHovering = true;
              })
              : null;
        },
        onExit: (hover) {
          widget.enableHover
              ? setState(() {
                isHovering = false;
              })
              : null;
        },
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: Row(
            children: [
              loading
                  ? SizedBox.square(dimension: 16, child: CircularProgressIndicator(color: widget.color, strokeWidth: 2))
                  : widget.iconData != null
                  ? Icon(widget.iconData, color: widget.color, size: Sizes.medium)
                  : SizedBox.shrink(),
              loading ? SizedBox(width: 6) : SizedBox.shrink(),
              Expanded(
                child: Text(
                  widget.text,
                  style: CLTheme.of(context).bodyText.merge(TextStyle(color: isHovering ? widget.hoverColor : widget.color)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          onTap: () async {
            if (widget.needConfirmation) {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: ConfirmationDialog(
                      confirmationMessage: widget.confirmationMessage,
                      onTap: () async {
                        if (isAsync(widget.onTap)) {
                          setState(() {
                            loading = true;
                          });
                          await widget.onTap();
                          setState(() {
                            loading = false;
                          });
                        } else {
                          widget.onTap();
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              );
            } else {
              if (isAsync(widget.onTap)) {
                setState(() {
                  loading = true;
                });
                await widget.onTap();
                setState(() {
                  loading = false;
                });
              } else {
                widget.onTap();
              }
            }
          },
        ),
      ),
    );
  }

  bool isAsync(Function function) {
    return function is Future Function();
  }
}
