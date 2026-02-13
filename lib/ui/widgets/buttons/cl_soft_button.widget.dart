import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_confirm_dialog.dart';

class CLSoftButton extends StatefulWidget {
  final Color color;
  final String text;
  final Function() onTap;
  final BuildContext context;
  final IconAlignment iconAlignment;
  final IconData? iconData;
  final List<List<dynamic>>? hugeIcon;
  final double? width;
  final bool needConfirmation;
  final String? confirmationMessage;

  const CLSoftButton({
    super.key,
    required this.color,
    required this.text,
    required this.onTap,
    required this.context,
    required this.iconAlignment,
    this.needConfirmation = false,
    this.confirmationMessage,
    this.iconData,
    this.hugeIcon,
    this.width,
  });

  factory CLSoftButton.primary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    List<List<dynamic>>? hugeIcon,
    double? width,
  }) {
    return CLSoftButton(
      text: text,
      color: CLTheme.of(context).primary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
    );
  }

  factory CLSoftButton.secondary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    List<List<dynamic>>? hugeIcon,
    double? width,
  }) {
    return CLSoftButton(
      text: text,
      color: CLTheme.of(context).secondary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
    );
  }

  // Factory method per Success button
  factory CLSoftButton.success({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    List<List<dynamic>>? hugeIcon,
    double? width,
  }) {
    return CLSoftButton(
      text: text,
      color: CLTheme.of(context).success,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
    );
  }

  // Factory method per Info button
  factory CLSoftButton.info({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    List<List<dynamic>>? hugeIcon,
    double? width,
  }) {
    return CLSoftButton(
      text: text,
      color: CLTheme.of(context).info,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
    );
  }

  // Factory method per Warning button
  factory CLSoftButton.warning({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    List<List<dynamic>>? hugeIcon,
    double? width,
  }) {
    return CLSoftButton(
      text: text,
      color: CLTheme.of(context).warning,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
    );
  }

  // Factory method per Danger button
  factory CLSoftButton.danger({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    List<List<dynamic>>? hugeIcon,
    double? width,
  }) {
    return CLSoftButton(
      text: text,
      color: CLTheme.of(context).danger,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
    );
  }

  @override
  State<CLSoftButton> createState() => _CLSoftButtonState();
}

class _CLSoftButtonState extends State<CLSoftButton> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: ElevatedButton.icon(
        iconAlignment: widget.iconAlignment,
        icon:
            loading
                ? SizedBox.square(dimension: 16, child: CircularProgressIndicator(color: widget.color, strokeWidth: 2))
                : widget.hugeIcon != null
                ? HugeIcon(icon: widget.hugeIcon!, color: widget.color, size: Sizes.small)
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
                        if (mounted) {
                          setState(() {
                            loading = false;
                          });
                        }
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
              if (mounted) {
                setState(() {
                  loading = false;
                });
              }
            } else {
              widget.onTap();
            }
          }
        },
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          foregroundColor: widget.color,
          backgroundColor: widget.color.withValues(alpha: Sizes.opacity),
          textStyle: CLTheme.of(context).bodyText,
          padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
          elevation: 0,
        ),
        label: Text(widget.text, style: CLTheme.of(context).bodyText.merge(TextStyle(color: widget.color))),
      ),
    );
  }

  bool isAsync(Function function) {
    return function is Future Function();
  }
}
