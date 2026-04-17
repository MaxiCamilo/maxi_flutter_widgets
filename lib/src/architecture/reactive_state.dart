import 'package:flutter/widgets.dart';
import 'package:maxi_framework/maxi_framework.dart';

mixin ReactiveState<T extends StatefulWidget> on State<T> {
  late final LifecycleScope? _heart;

  LifecycleScope get heart {
    if (_heart == null) {
      throw NegativeResult(
        error: ControlledFailure(
          errorCode: ErrorCode.implementationFailure,
          message: FixedOration(message: 'LifecycleScope has not been initialized yet. Make sure to call super.initState() in your initState method.'),
        ),
      );
    }
    return _heart;
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();

    _heart = LifecycleScope();
  }

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    _heart?.dispose();
  }
}
