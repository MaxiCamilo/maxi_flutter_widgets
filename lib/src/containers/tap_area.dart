import 'package:flutter/material.dart';
import 'package:maxi_flutter_widgets/maxi_flutter_widgets.dart';
import 'package:maxi_framework/maxi_framework.dart';

class TapArea extends StatelessWidget {
  final void Function()? onTouch;
  final void Function()? onDoubleTouch;
  final void Function()? onLongSelect;
  final void Function()? onSecondaryTap;
  final Widget child;
  final Color backgroundColor;

  final Color? backgroundColorOnMouseover;
  final Color? backgroundColorOnTouch;
  final Color? backgroundColorOnFocus;
  final Oration? tooltipText;

  const TapArea({
    super.key,
    required this.child,
    this.backgroundColor = Colors.transparent,
    this.onTouch,
    this.onDoubleTouch,
    this.onLongSelect,
    this.onSecondaryTap,
    this.backgroundColorOnMouseover,
    this.backgroundColorOnTouch,
    this.backgroundColorOnFocus,
    this.tooltipText,
  });

  @override
  Widget build(BuildContext context) {
    if (tooltipText == null) {
      return _buildRectangle(context);
    } else {
      return TooltipArea(text: tooltipText!, child: _buildRectangle(context));
    }
  }

  Widget _buildRectangle(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTouch,
        onDoubleTap: onDoubleTouch,
        onLongPress: onLongSelect,
        onSecondaryTap: onSecondaryTap,
        splashColor: backgroundColorOnTouch,
        hoverColor: backgroundColorOnMouseover,
        focusColor: backgroundColorOnFocus ?? backgroundColorOnMouseover,
        child: child,
      ),
    );
  }
}
