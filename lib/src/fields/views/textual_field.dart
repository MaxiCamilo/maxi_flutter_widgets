import 'package:flutter/material.dart';
import 'package:maxi_flutter_widgets/maxi_flutter_widgets.dart';
import 'package:maxi_framework/maxi_framework.dart';

class TextualField extends StatefulWidget {
  final bool enable;
  final Oration title;

  final TextInputAction? inputAction;
  final FocusNode? focusNode;
  final Widget? icon;
  final FieldController<String> Function()? controllerGetter;
  final void Function(FieldController<String> controller)? onControllerCreated;

  const TextualField({super.key, this.enable = true, this.title = emptyOration, this.inputAction, this.focusNode, this.icon, this.controllerGetter, this.onControllerCreated});

  @override
  State<StatefulWidget> createState() => _TextualFieldState();
}

class _TextualFieldState extends ReactiveState<TextualField> {
  late FieldController<String> _controller;

  @override
  void initState() {
    super.initState();

    if (widget.controllerGetter == null) {
      _controller = heart.joinDisposableObject(FieldTextualController(listeningFieldNames: [], initialValue: '', validators: [], aceptInvalidValues: true));
    } else {
      _controller = widget.controllerGetter!();
      
    }
    widget.onControllerCreated?.call(_controller);
  }

  @override
  Widget performanceBuild(BuildContext context) {
    // TODO: implement performanceBuild
    throw UnimplementedError();
  }
}
