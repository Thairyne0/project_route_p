import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    this.fullName,
    this.imagePath,
    this.fit = BoxFit.contain,
    this.avatarShape = AvatarShape.circle,
    this.isActive,
    this.initialsOnly = false,
    this.initialsStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.radius,
    this.size = const Size.square(44),
  }) : assert(
  isActive == null || avatarShape == AvatarShape.circle,
  'isActive can be only used in circle shape',
  );

  final String? fullName;
  final String? imagePath;
  final BoxFit fit;
  final AvatarShape avatarShape;
  final bool? isActive;
  final bool initialsOnly;
  final TextStyle? initialsStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadiusGeometry? radius;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null;

    final circleShape = Container(
      constraints: BoxConstraints.tight(size!),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: isActive == null
            ? null
            : Border.all(
          color: Colors.white,
          width: 1.75,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: initialsOnly
          ? _buildInitials(context)
          : hasImage
          ? _buildImage(context)
          : null,
    );

    final circleShapeWithIndicator = ConstrainedBox(
      constraints: BoxConstraints.tight(size!),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;

          return Stack(
            children: [
              circleShape,
              Positioned(
                bottom: 0,
                right: size.width * 0.10,
                child: Container(
                  height: size.width * 0.20,
                  width: size.width * 0.20,
                  decoration: BoxDecoration(
                    color:
                    isActive == true ? Colors.green : Colors.grey.shade600,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.25,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );

    final roundedRectangleShape = Container(
      constraints: BoxConstraints.tight(size!),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: radius ?? BorderRadius.circular(8),
        color: backgroundColor,
      ),
      child: initialsOnly
          ? _buildInitials(context)
          : hasImage
          ? _buildImage(context)
          : null,
    );

    final roundedRectangleTiltedShape = Transform.rotate(
      angle: 45 * (3.1416 / 180),
      child: Container(
        constraints: BoxConstraints.tight(size!),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: radius ?? BorderRadius.circular(8),
          color: backgroundColor,
        ),
        child: Transform.rotate(
          angle: -45 * (3.1416 / 180),
          alignment: Alignment.center,
          child: Transform.scale(
            scale: 1.325,
            child: initialsOnly
                ? _buildInitials(context)
                : hasImage
                ? _buildImage(
              context,
              height: double.maxFinite,
              width: double.maxFinite,
            )
                : null,
          ),
        ),
      ),
    );

    return switch (avatarShape) {
      AvatarShape.circle =>
      isActive == null ? circleShape : circleShapeWithIndicator,
      AvatarShape.roundedRectangle => roundedRectangleShape,
      AvatarShape.roundedRectangleTilted => roundedRectangleTiltedShape,
    };
  }

  Widget _buildImage(
      BuildContext context, {
        double? height,
        double? width,
      }) {
    return const Placeholder();
  }

  Widget _buildInitials(BuildContext context) {
    final theme = Theme.of(context);
    const String fallbackInitial = 'N/A';

    final nameParts = fullName?.split(' ') ?? [];

    String initials = '';
    if (nameParts.isNotEmpty) {
      initials = nameParts
          .where((part) => part.isNotEmpty)
          .map((part) => part[0])
          .take(2)
          .join();
    }

    if (initials.isEmpty) {
      initials = fallbackInitial;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        return Center(
          child: Text(
            initials.toUpperCase(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: foregroundColor,
              fontSize: size.width * 0.28,
            ),
          ),
        );
      },
    );
  }
}

enum AvatarShape {
  circle,
  roundedRectangle,
  roundedRectangleTilted;
}
