import 'package:flutter/widgets.dart';

mixin BeforeBuild<T extends StatefulWidget> on State<T> {
  bool _hasBuilt = false;

  void previousBuild(BuildContext context);

  Widget continueBuild(BuildContext context);

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    if (!_hasBuilt) {
      _hasBuilt = true;
      previousBuild(context);
    }
    return continueBuild(context);
  }
}
