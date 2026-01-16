import 'package:flutter/material.dart';

class MaxiScrollView extends StatefulWidget {
  final Axis scrollDirection;
  final Widget child;
  final double scrollSpace;

  final double? thickness;
  final Radius? radius;
  final bool expand;

  final double verticalScrollPadding;
  final double horizontalScrollPadding;

  final void Function(ScrollController)? onScrollCreated;

  const MaxiScrollView({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.scrollSpace = 0,
    this.onScrollCreated,
    this.thickness,
    this.radius,
    this.expand = false,
    this.horizontalScrollPadding = 10.0,
    this.verticalScrollPadding = 10.0,
  });

  @override
  State<MaxiScrollView> createState() => _MaxiScrollViewState();
}

class _MaxiScrollViewState extends State<MaxiScrollView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.onScrollCreated != null) {
      widget.onScrollCreated!(_scrollController);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: widget.thickness,
      radius: widget.radius,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          scrollDirection: widget.scrollDirection,
          controller: _scrollController,
          child: Padding(
            padding: EdgeInsets.only(right: widget.scrollDirection == Axis.vertical ? widget.verticalScrollPadding : 0, bottom: widget.scrollDirection == Axis.horizontal ? widget.horizontalScrollPadding : 0),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
