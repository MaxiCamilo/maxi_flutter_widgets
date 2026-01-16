import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_widgets/maxi_flutter_widgets.dart';
import 'package:maxi_framework/maxi_framework.dart';

abstract interface class ContractVerticallyController {
  bool get destroy;
  bool get hidden;
  set hidden(bool value);
  Stream<bool> get notifyChildHidden;

  Future<bool> hide({bool? destroy, Duration? delay});
  Future<bool> restore({Widget? replacement, Duration? delay});
  Future<bool> changeChild({required Widget newChild, Duration? delay});
}

class ContractVertically extends StatefulWidget {
  final Widget child;
  final bool contracted;
  final Duration duration;
  final Curve curve;
  final bool destroy;
  final void Function(ContractVerticallyController)? onCreated;

  const ContractVertically({super.key, required this.child, this.contracted = false, this.duration = const Duration(milliseconds: 400), this.curve = Curves.linear, this.destroy = false, this.onCreated});

  @override
  State<ContractVertically> createState() => _ContractVerticallyState();
}

class _ContractVerticallyState extends State<ContractVertically> with ReactiveState<ContractVertically>, SingleTickerProviderStateMixin implements ContractVerticallyController {
  late bool _hidden;
  late bool _destroy;
  late Duration _delay;

  late Widget child;

  late final AnimationController ac;
  late final Animation<double> factor;
  late final MaxiTimer timer;

  StreamController<bool>? _notifyChildHidden;

  @override
  void initState() {
    super.initState();

    _hidden = widget.contracted;
    _destroy = widget.destroy;
    _delay = widget.duration;

    ac = heart.joinDynamicObject(AnimationController(vsync: this, duration: widget.duration));
    factor = heart.joinDynamicObject(CurvedAnimation(parent: ac, curve: widget.curve));
    timer = heart.joinDisposableObject(MaxiTimer());
    child = widget.contracted ? const SizedBox.shrink() : widget.child;

    if (widget.onCreated != null) {
      widget.onCreated!(this);
    }
  }

  @override
  bool get destroy => _destroy;

  @override
  bool get hidden => _hidden;

  @override
  Stream<bool> get notifyChildHidden {
    if (!mounted) {
      throw NegativeResult.controller(
        code: ErrorCode.implementationFailure,
        message: FixedOration(message: '[_ContractVerticallyState] Widget is not mounted'),
      );
    }

    _notifyChildHidden ??= StreamController<bool>.broadcast();
    return _notifyChildHidden!.stream;
  }

  @override
  set hidden(bool value) {
    if (value) {
      hide();
    } else {
      restore();
    }
  }

  @override
  Future<bool> hide({bool? destroy, Duration? delay}) async {
    if (!mounted) {
      throw NegativeResult.controller(
        code: ErrorCode.implementationFailure,
        message: FixedOration(message: '[_ContractVerticallyState] Widget is not mounted'),
      );
    }

    if (destroy != null && _destroy != destroy) {
      _destroy = destroy;
    }
    if (delay != null && _delay != delay) {
      _delay = delay;
    }

    if (_hidden) {
      return true;
    }

    _hidden = true;
    Completer<bool> completer = Completer<bool>();

    timer.startOrReset(
      duration: _delay + Duration(milliseconds: 10),
      payload: null,
      onFinish: (x) {
        if (_destroy && mounted) {
          child = const SizedBox.shrink();
          setState(() {});
        }
        completer.complete(true);
        _notifyChildHidden?.add(true);
      },
      onInterrupt: (_) {
        if (completer.isCompleted) return;
        completer.complete(false);
      },
    );

    setState(() {});
    return await completer.future;
  }

  @override
  Future<bool> restore({Widget? replacement, Duration? delay}) async {
    if (!mounted) {
      throw NegativeResult.controller(
        code: ErrorCode.implementationFailure,
        message: FixedOration(message: '[_ContractVerticallyState] Widget is not mounted'),
      );
    }

    if (delay != null && _delay != delay) {
      _delay = delay;
    }

    if (!_hidden) {
      if (replacement != null && replacement != child) {
        return await changeChild(newChild: replacement, delay: delay);
      }
      return true;
    }

    if (replacement != null && replacement != child) {
      child = replacement;
    }

    _hidden = false;
    Completer<bool> completer = Completer<bool>();

    timer.startOrReset(
      duration: _delay + Duration(milliseconds: 10),
      payload: null,
      onFinish: (x) {
        completer.complete(true);
        _notifyChildHidden?.add(false);
      },
      onInterrupt: (_) {
        if (completer.isCompleted) return;
        completer.complete(false);
      },
    );

    setState(() {});
    return await completer.future;
  }

  @override
  Future<bool> changeChild({required Widget newChild, Duration? delay}) async {
    if (newChild == child) {
      return true;
    }

    if (await hide(delay: delay)) {
      child = newChild;
      await restore(delay: delay);
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: factor,
      builder: (context, _) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: factor.value,
            child: Align(alignment: Alignment.bottomCenter, child: child),
          ),
        );
      },
    );
  }
}
