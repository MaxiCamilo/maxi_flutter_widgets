import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_widgets/src/containers/maxi_scroll_view.dart';
import 'package:maxi_flutter_widgets/src/extensions/build_context_extensions.dart';

class BodyContainer extends StatelessWidget {
  final Widget? header;
  final Widget child;
  final Widget? footer;

  final double scrollWhen;

  const BodyContainer({super.key, this.header, required this.child, required this.scrollWhen, this.footer});

  @override
  Widget build(BuildContext context) {
    if (context.screenHeigth < scrollWhen) {
      return MaxiScrollView(
        child: Flex(direction: Axis.vertical, mainAxisSize: MainAxisSize.min, children: [if (header != null) header!, child, if (footer != null) footer!]),
      );
    } else {
      return Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (header != null) header!,
          Expanded(child: MaxiScrollView(child: child)),
          if (footer != null) footer!,
        ],
      );
    }
  }
}
