import 'package:flutter/material.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_confirm_dialog.dart';

class CLOutlineButton extends StatefulWidget {
  final Color color;
  final String text;
  final Function() onTap;
  final BuildContext context;
  final IconAlignment iconAlignment;
  final IconData? iconData;
  final double? width;
  final bool needConfirmation;
  final String? confirmationMessage;

  const CLOutlineButton(
      {super.key,
        required this.color,
        required this.text,
        required this.onTap,
        required this.context,
        required this.iconAlignment,
        this.iconData,
        this.needConfirmation = false,
        this.confirmationMessage,
        this.width});

  factory CLOutlineButton.primary(
      {required String text,
        required Function() onTap,
        required BuildContext context,
        IconAlignment iconAlignment = IconAlignment.start,
        bool needConfirmation = false,
        String? confirmationMessage,
        IconData? icon,
        double? width}) {
    return CLOutlineButton(
      text: text,
      color: CLTheme.of(context).primary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  factory CLOutlineButton.secondary(
      {required String text,
        required Function() onTap,
        required BuildContext context,
        IconAlignment iconAlignment = IconAlignment.start,
        bool needConfirmation = false,
        String? confirmationMessage,
        IconData? icon,
        double? width}) {
    return CLOutlineButton(
      text: text,
      color: CLTheme.of(context).secondary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  // Factory method per Success button
  factory CLOutlineButton.success(
      {required String text,
        required Function() onTap,
        required BuildContext context,
        IconAlignment iconAlignment = IconAlignment.start,
        bool needConfirmation = false,
        String? confirmationMessage,
        IconData? icon,
        double? width}) {
    return CLOutlineButton(
      text: text,
      color: CLTheme.of(context).success,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  // Factory method per Info button
  factory CLOutlineButton.info(
      {required String text,
        required Function() onTap,
        required BuildContext context,
        IconAlignment iconAlignment = IconAlignment.start,
        bool needConfirmation = false,
        String? confirmationMessage,
        IconData? icon,
        double? width}) {
    return CLOutlineButton(
      text: text,
      color: CLTheme.of(context).info,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  // Factory method per Warning button
  factory CLOutlineButton.warning(
      {required String text,
        required Function() onTap,
        required BuildContext context,
        IconAlignment iconAlignment = IconAlignment.start,
        bool needConfirmation = false,
        String? confirmationMessage,
        IconData? icon,
        double? width}) {
    return CLOutlineButton(
      text: text,
      color: CLTheme.of(context).warning,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  // Factory method per Danger button
  factory CLOutlineButton.danger(
      {required String text,
        required Function() onTap,
        required BuildContext context,
        IconAlignment iconAlignment = IconAlignment.start,
        bool needConfirmation = false,
        String? confirmationMessage,
        IconData? icon,
        double? width}) {
    return CLOutlineButton(
      text: text,
      color: CLTheme.of(context).danger,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  @override
  State<CLOutlineButton> createState() => _CLOutlineButtonState();
}

class _CLOutlineButtonState extends State<CLOutlineButton> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(

      width: widget.width,
      child: OutlinedButton.icon(
        iconAlignment: widget.iconAlignment,
        icon: loading
            ? SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(
            color: widget.color,
            strokeWidth: 2,
          ),
        )
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
                    ));
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
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: widget.color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.borderRadius),
          ),
        ),
        label: Text(
          widget.text,
          style: CLTheme.of(context).bodyText.merge(TextStyle(color: widget.color)),
        ),
      ),
    );
  }

  bool isAsync(Function function) {
    return function is Future Function();
  }
}
