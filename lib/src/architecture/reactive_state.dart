import 'package:flutter/widgets.dart';
import 'package:maxi_framework/maxi_framework.dart';

abstract class ReactiveState<T extends StatefulWidget> extends State<T> {
  late final LifecycleScope? _heart;

  bool _wasBuilt = false;

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

  Widget performanceBuild(BuildContext context);

  void performanceFirstBuild(BuildContext context) {}

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
    _heart = null;
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    if (!_wasBuilt) {
      _wasBuilt = true;
      performanceFirstBuild(context);
    }

    return performanceBuild(context);
  }
}
