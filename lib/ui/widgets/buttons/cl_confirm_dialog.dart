import 'package:flutter/cupertino.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../cl_container.widget.dart';
import 'cl_button.widget.dart';
import 'cl_ghost_button.widget.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    this.confirmationMessage,
    required this.onTap,
  });

  final String? confirmationMessage;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return CLContainer(
      height: 150,
      width: 500,
      child: Padding(
        padding: const EdgeInsets.all(Sizes.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              confirmationMessage ?? "Sei sicuro di voler effettuare quest'operazione?",
              style: CLTheme.of(context).bodyLabel,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CLGhostButton.danger(
                    width: 150,
                    text: "Annulla",
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    context: context),
                CLButton.primary(width: 150, text: "Conferma", onTap: onTap, context: context),
              ],
            )
          ],
        ),
      ),
    );
  }
}
