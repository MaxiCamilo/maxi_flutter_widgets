import 'package:flutter/material.dart';
import 'package:maxi_framework/maxi_framework.dart';

abstract interface class ContainerOverrideController {
  bool get isOverriding;
  set isOverriding(bool value);
  Future<bool> showAnotherOverride({required Widget newOverrideChild});

  Future<bool> showOverride();
  Future<bool> hideOverride();
}

class ContainerOverride extends StatefulWidget {
  final Widget child;
  final Widget? overrideChild;
  final void Function(ContainerOverrideController)? onCreated;
  final bool isOverriding;
  final Curve curve;
  final Duration duration;

  const ContainerOverride({super.key, required this.child, this.overrideChild, this.onCreated, this.isOverriding = false, this.curve = Curves.easeInOut, this.duration = const Duration(milliseconds: 300)});

  @override
  State<ContainerOverride> createState() => _ContainerOverrideState();
}

class _ContainerOverrideState extends State<ContainerOverride> implements ContainerOverrideController {
  late Widget overrideChild;
  late bool overrideIsVisible;

  late bool _isOverriding;

  final semaphore = Semaphore();
  final timer = MaxiTimer();

  @override
  bool get isOverriding => _isOverriding;

  Widget defaultOverrideChild() {
    return Container(color: const Color.fromARGB(87, 0, 0, 0));
  }

  @override
  void initState() {
    super.initState();

    _isOverriding = widget.isOverriding;
    overrideChild = widget.overrideChild ?? defaultOverrideChild();
    overrideIsVisible = _isOverriding;
  }

  @override
  void didUpdateWidget(covariant ContainerOverride oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isOverriding != oldWidget.isOverriding || widget.overrideChild != oldWidget.overrideChild) {
      _isOverriding = widget.isOverriding;
      overrideChild = widget.overrideChild ?? defaultOverrideChild();
      overrideIsVisible = _isOverriding;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(ignoring: _isOverriding, child: widget.child),
        Positioned.fill(
          child: Visibility(
            visible: overrideIsVisible,
            child: IgnorePointer(
              ignoring: !_isOverriding,
              child: AnimatedOpacity(
                opacity: _isOverriding ? 1.0 : 0.0,
                duration: widget.duration,
                curve: widget.curve,
                onEnd: () {
                  if (!_isOverriding) {
                    setState(() {
                      overrideIsVisible = false;
                    });
                  }
                },
                child: overrideChild,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  set isOverriding(bool value) {
    if (value != _isOverriding) {
      if (value) {
        showOverride();
      } else {
        hideOverride();
      }
    }
  }

  @override
  Future<bool> showAnotherOverride({required Widget newOverrideChild}) {
    timer.cancel();
    return semaphore.execute(() async {
      overrideChild = newOverrideChild;
      _isOverriding = true;
      overrideIsVisible = true;
      setState(() {});
      return timer.startOrReset(duration: widget.duration, payload: true);
    });
  }

  @override
  Future<bool> hideOverride() {
    timer.cancel();
    return semaphore.execute(() async {
      _isOverriding = false;
      setState(() {});
      return timer.startOrReset(duration: widget.duration, payload: true);
    });
  }

  @override
  Future<bool> showOverride() {
    timer.cancel();
    return semaphore.execute(() async {
      overrideIsVisible = true;
      setState(() {});
      await WidgetsBinding.instance.endOfFrame;
      _isOverriding = true;
      setState(() {});

      return timer.startOrReset(duration: widget.duration, payload: true);
    });
  }
}
