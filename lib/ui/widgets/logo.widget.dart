import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoWidget extends StatefulWidget {
  const LogoWidget({super.key, this.logoImagePath, this.height, this.dark = false, this.color});

  final String? logoImagePath;
  final double? height;
  final bool dark;
  final Color? color;

  @override
  State<LogoWidget> createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height ?? 90,
        child:
            widget.dark
                ? SvgPicture.asset("assets/svgs/logo-dark.svg", color: widget.color??Colors.white)
                : SvgPicture.asset("assets/svgs/logo-light.svg", color: widget.color??Colors.white),
    );
  }
}
