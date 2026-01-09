import 'package:flutter/widgets.dart';
import 'package:maxi_framework/maxi_framework.dart';

mixin ReactiveState<T extends StatefulWidget> on State<T> {
  late final LifeCoordinator? _heart;

  LifeCoordinator get heart {
    if (_heart == null) {
      throw NegativeResult(
        error: ControlledFailure(
          errorCode: ErrorCode.implementationFailure,
          message: FixedOration(message: 'LifeCoordinator has not been initialized yet. Make sure to call super.initState() in your initState method.'),
        ),
      );
    }
    return _heart;
  }

   

  @override
  @mustCallSuper
  void initState() {
    super.initState();

    _heart = LifeCoordinator();
  }

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    _heart?.dispose();
  }
}
