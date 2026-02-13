import 'package:flutter/material.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_confirm_dialog.dart';

class CLButton extends StatefulWidget {
  final Color? backgroundColor;
  final String text;
  final Function() onTap;
  final BuildContext context;
  final IconAlignment iconAlignment;
  final IconData? iconData;
  final double? width;
  final bool needConfirmation;
  final double? iconSize;
  final String? confirmationMessage;
  final TextStyle? textStyle;
  final Color? iconColor;
  final Widget? hugeIcon;

  const CLButton({
    super.key,
    this.backgroundColor,
    required this.text,
    required this.onTap,
    required this.context,
    required this.iconAlignment,
    this.iconData,
    this.needConfirmation = false,
    this.confirmationMessage,
    this.iconSize,
    this.width,
    this.textStyle,
    this.iconColor,
    this.hugeIcon,
  });

  factory CLButton.primary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? iconSize,
    double? width,
    TextStyle? textStyle,
    Color? iconColor,
    Widget? hugeIcon,
  }) {
    return CLButton(
      text: text,
      backgroundColor: CLTheme.of(context).primary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      width: width,
      iconSize: iconSize,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      textStyle: textStyle,
      iconColor: iconColor,
      hugeIcon: hugeIcon,
    );
  }

  factory CLButton.secondary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? iconSize,
    double? width,
    TextStyle? textStyle,
    Color? iconColor,
    Widget? hugeIcon,
  }) {
    return CLButton(
      text: text,
      backgroundColor: CLTheme.of(context).secondary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      iconSize: iconSize,
      width: width,
      textStyle: textStyle,
      iconColor: iconColor,
      hugeIcon: hugeIcon,
    );
  }

  // Factory method per Success button
  factory CLButton.success({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    double? iconSize,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? width,
    TextStyle? textStyle,
    Color? iconColor,
    Widget? hugeIcon,
  }) {
    return CLButton(
      text: text,
      backgroundColor: CLTheme.of(context).success,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      needConfirmation: needConfirmation,
      confirmationMessage: confirmationMessage,
      iconSize: iconSize,
      width: width,
      textStyle: textStyle,
      iconColor: iconColor,
      hugeIcon: hugeIcon,
    );
  }

  // Factory method per Info button
  factory CLButton.info({
    required String text,
    required Function() onTap,
    required BuildContext context,
    double? iconSize,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? width,
    TextStyle? textStyle,
    Color? iconColor,
    Widget? hugeIcon,
  }) {
    return CLButton(
      text: text,
      backgroundColor: CLTheme.of(context).info,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      needConfirmation: needConfirmation,
      confirmationMessage: confirmationMessage,
      iconSize: iconSize,
      width: width,
      textStyle: textStyle,
      iconColor: iconColor,
      hugeIcon: hugeIcon,
    );
  }

  // Factory method per Warning button
  factory CLButton.warning({
    required String text,
    required Function() onTap,
    required BuildContext context,
    double? iconSize,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? width,
    TextStyle? textStyle,
    Color? iconColor,
    Widget? hugeIcon,
  }) {
    return CLButton(
      text: text,
      backgroundColor: CLTheme.of(context).warning,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconSize: iconSize,
      iconData: icon,
      needConfirmation: needConfirmation,
      confirmationMessage: confirmationMessage,
      width: width,
      textStyle: textStyle,
      iconColor: iconColor,
      hugeIcon: hugeIcon,
    );
  }

  // Factory method per Danger button
  factory CLButton.danger({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    double? iconSize,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? width,
    TextStyle? textStyle,
    Color? iconColor,
    Widget? hugeIcon,
  }) {
    return CLButton(
      text: text,
      backgroundColor: CLTheme.of(context).danger,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      width: width,
      iconSize: iconSize,
      textStyle: textStyle,
      iconColor: iconColor,
      hugeIcon: hugeIcon,
    );
  }

  @override
  State<CLButton> createState() => _CLButtonState();
}

class _CLButtonState extends State<CLButton> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(splashColor: Colors.transparent, highlightColor: Colors.transparent),
      child: SizedBox(
        width: widget.width,
        child:
            widget.text.isNotEmpty
                ? ElevatedButton.icon(
                  iconAlignment: widget.iconAlignment,
                  icon:
                      loading
                          ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : widget.hugeIcon ??
                              (widget.iconData != null
                                  ? Icon(widget.iconData, color: widget.iconColor ?? Colors.white, size: widget.iconSize ?? Sizes.small)
                                  : null),
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
                        if (mounted) {
                          setState(() {
                            loading = true;
                          });
                        }
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
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding)),
                    backgroundColor: WidgetStateProperty.all(widget.backgroundColor ?? CLTheme.of(context).primary),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius))),
                    elevation: WidgetStateProperty.all(0),
                    shadowColor: WidgetStateProperty.all(Colors.transparent),
                    overlayColor: WidgetStateProperty.all(Colors.black.withValues(alpha: 0.1)),
                    splashFactory: NoSplash.splashFactory,
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  label: Text(widget.text, style: widget.textStyle ?? CLTheme.of(context).bodyText.copyWith(color: Colors.white)),
                )
                : IconButton(
                  color: widget.backgroundColor ?? CLTheme.of(context).primary,
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(0),
                    shadowColor: WidgetStateProperty.all(Colors.transparent),
                    backgroundColor: WidgetStateProperty.all(widget.backgroundColor ?? CLTheme.of(context).primary),
                    overlayColor: WidgetStateProperty.all(Colors.black.withValues(alpha: 0.1)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius))),
                    splashFactory: NoSplash.splashFactory,
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  onPressed: () async {
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
                  },
                  icon:
                      loading
                          ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : widget.hugeIcon ??
                              (widget.iconData != null
                                  ? Icon(widget.iconData, color: widget.iconColor ?? Colors.white, size: Sizes.medium)
                                  : const SizedBox.shrink()),
                ),
      ),
    );
  }

  bool isAsync(Function function) {
    return function is Future Function();
  }
}
