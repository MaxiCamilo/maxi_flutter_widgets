import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_widgets/maxi_flutter_widgets.dart';
import 'package:maxi_framework/maxi_framework.dart';
import 'package:meta/meta.dart';

mixin FieldTemplateWidget<T> on StatefulWidget {
  FieldController<T>? Function()? get controllerGetter;
  void Function(FieldController<T> controller)? get onControllerCreated;
  String? get propertyName;
  T get defaultValue;
}

abstract class FieldTemplateState<T, W extends FieldTemplateWidget<T>> extends ReactiveState<W> {
  late FieldController<T> controller;

  late T lastValue;
  late NegativeResult lastError;
  late bool isLastValueValid;
  late String lastTranslateError;

  FieldController<T> buildDefaultController();

  void performanInitState();

  bool compareValuesAreEqual(T oldValue, T newValue) => oldValue == newValue;

  bool onControllerValueChanged({required T oldValue, required T newValue});

  void onChangeToValid();

  void onChangeToInvalid({required NegativeResult error, required String translateError});

  void _buildNewController() {
    controller = heart.joinDisposableObject(buildDefaultController());
    lastValue = widget.defaultValue;
    lastError = NegativeResult<T>.empty();
    lastTranslateError = '';
    isLastValueValid = true;

    controller.changeFieldValue(widget.defaultValue).logIfFails(errorName: 'Error setting default value to controller');
  }

  @override
  @nonVirtual
  void initState() {
    super.initState();

    if (widget.controllerGetter == null) {
      _buildNewController();
    } else {
      final possibleController = widget.controllerGetter!();
      if (possibleController == null) {
        _buildNewController();
      } else {
        controller = possibleController;
        final initValueResult = controller.getValue();
        if (initValueResult.itsCorrect) {
          lastValue = initValueResult.content;
          if (controller.isValid) {
            lastTranslateError = '';
            lastError = NegativeResult<T>.empty();
            isLastValueValid = true;
          } else {
            lastError = controller.getActualError();
            lastTranslateError = lastError.error.message.translateText();
            isLastValueValid = false;
          }
        } else {
          lastValue = widget.defaultValue;
          lastError = controller.getActualError();
          lastTranslateError = lastError.error.message.translateText();
          isLastValueValid = false;
        }
      }
    }

    performanInitState();

    widget.onControllerCreated?.call(controller);

    heart.joinStream(stream: controller.onValueChanged, onData: _onControllerValueChanged);
    heart.joinStream(stream: controller.isValidChanged, onData: _onControllerValidChanged);
  }

  void _onControllerValueChanged(T event) {
    if (!compareValuesAreEqual(lastValue, event)) {
      if (onControllerValueChanged(oldValue: lastValue, newValue: event)) {
        lastValue = event;
      }
    }
  }

  void _onControllerValidChanged(bool event) {
    if (event == isLastValueValid) {
      return;
    }

    isLastValueValid = event;
    if (event) {
      lastTranslateError = '';
      lastError = NegativeResult<T>.empty();
      onChangeToValid();
    } else {
      final actualError = controller.getActualError();
      if (actualError.error.message != lastError.error.message) {
        lastError = actualError;
        lastTranslateError = lastError.error.message.translateText();
        onChangeToInvalid(error: lastError, translateError: lastTranslateError);
      }
    }
  }
}
