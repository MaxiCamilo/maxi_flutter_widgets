import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:maxi_framework/maxi_framework.dart';

abstract interface class DoppelgangerController {
  bool get destroy;
  bool get isFake;
  set isFake(bool value);
  Stream<bool> get notifyChildHidden;

  void fakeWidget({bool? destroy});
  void restoreWidget();

  FutureResult<ui.Image> captureRawImage({double? pixelRatio});
}

class Doppelganger extends StatefulWidget {
  final Widget child;
  final bool destroy;
  final void Function(DoppelgangerController)? onCreated;
  const Doppelganger({super.key, required this.child, this.destroy = false, this.onCreated});

  @override
  State<StatefulWidget> createState() => _DoppelgangerState();
}

class _DoppelgangerState extends State<Doppelganger> implements DoppelgangerController {
  final captureKey = GlobalKey();
  final semaphore = Semaphore();

  StreamController<bool>? notifyChildHiddenController;

  ui.Image? capturedImage;

  @override
  bool get destroy => _destroy;

  bool _isFake = false;
  bool _destroy = false;

  @override
  bool get isFake => _isFake;

  @override
  Stream<bool> get notifyChildHidden {
    if (!mounted) {
      throw NegativeResult.controller(
        code: ErrorCode.implementationFailure,
        message: FixedOration(message: '[_DoppelgangerState] Widget is not mounted'),
      );
    }
    notifyChildHiddenController ??= StreamController<bool>.broadcast();
    return notifyChildHiddenController!.stream;
  }

  @override
  void initState() {
    super.initState();

    _destroy = widget.destroy;

    if (widget.onCreated != null) {
      widget.onCreated!(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        wrapChild(context),
        _isFake
            ? Positioned.fill(
                child: RawImage(image: capturedImage, fit: BoxFit.fill, filterQuality: FilterQuality.high),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget wrapChild(BuildContext context) {
    if (_isFake && _destroy) {
      return const SizedBox();
    }

    return TickerMode(
      enabled: !_isFake,
      child: Visibility(
        visible: !_isFake,
        maintainState: true,
        maintainSize: true,
        maintainAnimation: true,
        maintainSemantics: true,
        child: IgnorePointer(
          ignoring: _isFake,
          child: RepaintBoundary(key: captureKey, child: widget.child),
        ),
      ),
    );
  }

  @override
  set isFake(bool value) {
    if (value) {
      restoreWidget();
    } else {
      fakeWidget();
    }
  }

  @override
  void fakeWidget({bool? destroy}) {
    if (!mounted) {
      debugPrint('[_DoppelgangerState] Widget is not mounted');
      return;
    }

    semaphore.execute(() async {
      if (_isFake) {
        if (destroy != null && destroy != _destroy) {
          _destroy = destroy;
          setState(() {});
        }
        return;
      }
      await WidgetsBinding.instance.endOfFrame;
      final renderObject = captureKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        debugPrint('[_DoppelgangerState] RenderObject is not RenderRepaintBoundary');
        return;
      }

      if (!mounted) {
        return;
      }

      _destroy = destroy ?? widget.destroy;
      capturedImage?.dispose();
      capturedImage = null;

      capturedImage = await renderObject.toImage(pixelRatio: View.of(context).devicePixelRatio);
      if (!mounted) {
        capturedImage?.dispose();
        return;
      }

      _isFake = true;
      setState(() {});
    });
  }

  @override
  FutureResult<ui.Image> captureRawImage({double? pixelRatio}) {
    return semaphore.execute(() async {
      if (!mounted) {
        return NegativeResult.controller(
          code: ErrorCode.implementationFailure,
          message: FixedOration(message: '[_DoppelgangerState] Widget is not mounted'),
        );
      }
      if (_isFake) {
        return capturedImage.asResErrorIfItsNull(message: FixedOration(message: '[_DoppelgangerState] Fake image is null'));
      }
      await WidgetsBinding.instance.endOfFrame;
      final renderObject = captureKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        return NegativeResult.controller(
          code: ErrorCode.implementationFailure,
          message: FixedOration(message: '[_DoppelgangerState] RenderObject is not RenderRepaintBoundary'),
        );
      }

      if (!mounted) {
        return NegativeResult.controller(
          code: ErrorCode.implementationFailure,
          message: FixedOration(message: '[_DoppelgangerState] Widget is not mounted'),
        );
      }

      return renderObject.toImage(pixelRatio: pixelRatio ?? View.of(context).devicePixelRatio).toFutureResult();
    });
  }

  @override
  void restoreWidget() {
    if (!mounted) {
      debugPrint('[_DoppelgangerState] Widget is not mounted');
      return;
    }

    semaphore.execute(() async {
      if (!_isFake) {
        return;
      }
      if (!mounted) {
        return;
      }
      _isFake = false;
      capturedImage?.dispose();
      capturedImage = null;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    capturedImage?.dispose();
    notifyChildHiddenController?.close();
    notifyChildHiddenController = null;
  }
}
