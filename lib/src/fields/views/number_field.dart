import 'package:flutter/material.dart';
import 'package:maxi_flutter_widgets/maxi_flutter_widgets.dart';
import 'package:maxi_framework/maxi_framework.dart';

class NumberField<T extends num> extends StatefulWidget with FieldTemplateWidget<T> {
  final FocusNode? focusNode;
  final Widget? icon;
  final bool obscure;
  final bool enable;
  final Oration title;

  @override
  final String? propertyName;
  @override
  final T defaultValue;

  @override
  final FieldController<T> Function()? controllerGetter;
  @override
  final void Function(FieldController<T> controller)? onControllerCreated;

  final void Function(Result<T>)? onSubmitted;

  const NumberField({
    super.key,
    required this.obscure,
    required this.enable,
    required this.title,
    required this.defaultValue,
    this.focusNode,
    this.icon,
    this.propertyName,
    this.controllerGetter,
    this.onControllerCreated,
    this.onSubmitted,
  });

  @override
  State<StatefulWidget> createState() => _NumberFieldState();
}

class _NumberFieldState extends FieldTemplateState<num, NumberField<num>> {
  @override
  FieldController<num> buildDefaultController() {
    // TODO: implement buildDefaultController
    throw UnimplementedError();
  }

  @override
  void onChangeToInvalid({required NegativeResult<dynamic> error, required String translateError}) {
    // TODO: implement onChangeToInvalid
  }

  @override
  void onChangeToValid() {
    // TODO: implement onChangeToValid
  }

  @override
  bool onControllerValueChanged({required num oldValue, required num newValue}) {
    // TODO: implement onControllerValueChanged
    throw UnimplementedError();
  }

  @override
  void performanInitState() {
    // TODO: implement performanInitState
  }

  @override
  Widget performanceBuild(BuildContext context) {
    // TODO: implement performanceBuild
    throw UnimplementedError();
  }

}
