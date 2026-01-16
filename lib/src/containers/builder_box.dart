import 'package:flutter/widgets.dart';

abstract interface class BuilderBoxController {
  void updateState();
  void changeChild({required Widget newChild});
  void rebuild();
}

class BuilderBox extends StatefulWidget {
  final Widget child;
  final void Function(BuilderBoxController)? onCreated;
  const BuilderBox({super.key, required this.child, this.onCreated});

  @override
  State<StatefulWidget> createState() => _BuilderBoxState();
}

class _BuilderBoxState extends State<BuilderBox> implements BuilderBoxController {
  late Widget child;
  int stateNumber = 0;

  @override
  void initState() {
    super.initState();
    child = widget.child;

    if (widget.onCreated != null) {
      widget.onCreated!(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(key: ValueKey(stateNumber), child: child);
  }

  @override
  void changeChild({required Widget newChild}) {
    child = newChild;
    rebuild();
  }

  @override
  void updateState() {
    setState(() {});
  }

  @override
  void rebuild() {
    stateNumber++;
    setState(() {});
  }
}
