import 'package:flutter/material.dart';
import 'package:maxi_flutter_widgets/src/extensions/build_context_extensions.dart';

class MaxiFlex extends StatelessWidget {
  final List<Widget> children;
  final double rowFrom;
  final double spacing;

  final CrossAxisAlignment rowCrossAxisAlignment;
  final MainAxisAlignment rowMainAxisAlignment;

  final CrossAxisAlignment columnCrossAxisAlignment;
  final MainAxisAlignment columnMainAxisAlignment;

  final bool reverseRow;
  final bool reverseColumn;

  final bool useScreenSize;

  final bool expandColumn;
  final bool expandRow;

  const MaxiFlex({
    super.key,
    required this.rowFrom,
    required this.children,
    this.useScreenSize = true,
    this.expandColumn = false,
    this.expandRow = false,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.columnCrossAxisAlignment = CrossAxisAlignment.stretch,
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.reverseRow = false,
    this.reverseColumn = false,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (useScreenSize) {
      return _createFlex(context: context, width: context.screenWidth);
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          if (width.isInfinite) {
            if (constraints.minWidth.isInfinite) {
              width = context.screenWidth;
            }
            width = constraints.minWidth;
          }

          return _createFlex(context: context, width: width);
        },
      );
    }
  }

  Flex _createFlex({required BuildContext context, required double width}) {
    return Flex(
      direction: width < rowFrom ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: width < rowFrom ? columnCrossAxisAlignment : rowCrossAxisAlignment,
      mainAxisAlignment: width < rowFrom ? columnMainAxisAlignment : rowMainAxisAlignment,
      mainAxisSize: width < rowFrom ? (expandColumn ? MainAxisSize.max : MainAxisSize.min) : (expandRow ? MainAxisSize.max : MainAxisSize.min),
      spacing: spacing,
      children: width < rowFrom ? (reverseColumn ? children.reversed.toList() : children) : (reverseRow ? children.reversed.toList() : children),
    );
  }
}
