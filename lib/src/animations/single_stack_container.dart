import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maxi_framework/maxi_framework.dart';

abstract interface class SingleStackContainerController {
  void updateChild({required Widget newChild});
}

class SingleStackContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final void Function(SingleStackContainerController)? onCreated;

  const SingleStackContainer({super.key, this.duration = const Duration(milliseconds: 250), this.curve = Curves.decelerate, this.onCreated, required this.child});

  @override
  State<StatefulWidget> createState() => _SingleStackContainerState();
}

class _SingleStackContainerState extends State<SingleStackContainer> implements SingleStackContainerController {
  final captureKey = GlobalKey();
  //final timer = MaxiTimer();
  final mutex = Mutex();

  late Widget child;

  double opacity = 0.0;
  ui.Image? capturedImage;

  @override
  void initState() {
    super.initState();
    child = widget.child;

    if (widget.onCreated != null) {
      widget.onCreated!(this);
    }
  }

  @override
  void didUpdateWidget(covariant SingleStackContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != oldWidget.child) {
      updateChild(newChild: widget.child);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: captureKey,
      child: AnimatedSize(
        duration: widget.duration,
        curve: widget.curve,
        alignment: Alignment.topLeft,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            child,
            capturedImage == null
                ? const SizedBox.shrink()
                : IgnorePointer(
                    ignoring: true,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: AnimatedOpacity(
                        opacity: opacity,
                        duration: widget.duration,
                        curve: widget.curve,
                        onEnd: onEndOpacityAnimation,
                        child: OverflowBox(
                          minWidth: 0,
                          minHeight: 0,
                          maxWidth: double.infinity,
                          maxHeight: double.infinity,
                          alignment: Alignment.topLeft,
                          child: RawImage(image: capturedImage),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void updateChild({required Widget newChild}) {
    if (!mounted) return;
    //timer.cancel();
    mutex.execute(() async {
      await WidgetsBinding.instance.endOfFrame;
      final boundary = captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || !mounted) return;
      capturedImage?.dispose();
      capturedImage = null;
      capturedImage = await boundary.toImage(pixelRatio: View.of(context).devicePixelRatio);
      child = newChild;
      opacity = 1.0;
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => opacity = 0.0);
      });
    });
  }

  void onEndOpacityAnimation() {
    capturedImage?.dispose();
    capturedImage = null;
    setState(() {});
  }
}
