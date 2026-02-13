import 'package:flutter/material.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_confirm_dialog.dart';

class CLGhostButton extends StatefulWidget {
  final Color color;
  final String text;
  final ButtonStyle? buttonStyle;
  final Function() onTap;
  final BuildContext context;
  final IconAlignment iconAlignment;
  final IconData? iconData;
  final double? width;
  final bool needConfirmation;
  final String? confirmationMessage;
  final Color? foregroundColor;

  const CLGhostButton({
    super.key,
    required this.color,
    required this.text,
    this.buttonStyle,
    required this.onTap,
    required this.context,
    required this.iconAlignment,
    this.iconData,
    this.needConfirmation = false,
    this.confirmationMessage,
    this.width,
    this.foregroundColor,
  });

  // Factory method per Success button
  factory CLGhostButton.primary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    IconData? icon,
    Color? foregroundColor,
    double? width,
  }) {
    return CLGhostButton(
      text: text,
      color: CLTheme.of(context).primary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      width: width,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  // Factory method per Success button
  factory CLGhostButton.secondary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    IconData? icon,
    Color? foregroundColor,
    double? width,
  }) {
    return CLGhostButton(
      text: text,
      color: CLTheme.of(context).secondary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      width: width,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  // Factory method per Success button
  factory CLGhostButton.success({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    Color? foregroundColor,
    IconData? icon,
    double? width,
  }) {
    return CLGhostButton(
      text: text,
      color: CLTheme.of(context).success,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      foregroundColor: foregroundColor,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  // Factory method per Info button
  factory CLGhostButton.info({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    Color? foregroundColor,
    IconData? icon,
    double? width,
  }) {
    return CLGhostButton(
      text: text,
      color: CLTheme.of(context).info,
      context: context,
      onTap: onTap,
      iconAlignment: iconAlignment,
      iconData: icon,
      foregroundColor: foregroundColor,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  // Factory method per Warning button
  factory CLGhostButton.warning({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    Color? foregroundColor,
    IconData? icon,
    double? width,
  }) {
    return CLGhostButton(
      context: context,
      text: text,
      color: CLTheme.of(context).warning,
      onTap: onTap,
      iconAlignment: iconAlignment,
      iconData: icon,
      width: width,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  // Factory method per Danger button
  factory CLGhostButton.danger({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    Color? foregroundColor,
    IconData? icon,
    double? width,
  }) {
    return CLGhostButton(
      context: context,
      text: text,
      color: CLTheme.of(context).danger,
      onTap: onTap,
      iconAlignment: iconAlignment,
      iconData: icon,
      width: width,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  @override
  State<CLGhostButton> createState() => _CLGhostButtonState();
}

class _CLGhostButtonState extends State<CLGhostButton> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextButton.icon(
        iconAlignment: widget.iconAlignment,
        icon:
            loading
                ? SizedBox.square(dimension: 16, child: CircularProgressIndicator(color: widget.color, strokeWidth: 2))
                : widget.iconData != null
                ? Icon(widget.iconData, color: widget.color, size: Sizes.small)
                : null,
        onPressed: () async {
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
        style:
            widget.buttonStyle ??
            TextButton.styleFrom(
              foregroundColor: widget.foregroundColor ?? widget.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
              elevation: 0,
              // Rimuove l'ombra
            ),
        label: Text(widget.text, style: CLTheme.of(context).bodyText.merge(TextStyle(color: widget.color)), overflow: TextOverflow.ellipsis, maxLines: 1),
      ),
    );
  }

  bool isAsync(Function function) {
    return function is Future Function();
  }
}
