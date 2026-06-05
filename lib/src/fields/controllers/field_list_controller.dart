import 'package:maxi_flutter_widgets/src/fields/fieald_template_controller.dart';
import 'package:maxi_framework/maxi_framework.dart';

class FieldListController<T> extends FiealdTemplateController<List<T>> {
  FieldListController({required super.listeningFieldNames, super.initialValue = const [], super.validators = const [], super.aceptInvalidValues = true});

  FieldListController.oneName({required String name, super.initialValue = const [], super.validators = const [], super.aceptInvalidValues = true}) : super(listeningFieldNames: [name]);

  @override
  bool compareValues(List<T> value) {
    if (value.length != currentValue.length) {
      return false;
    }

    for (int i = 0; i < value.length; i++) {
      if (value[i] != currentValue[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  Result<void> changeGenericFieldValue({required String name, required newValue}) {
    if (isListeningToFieldName(name) && newValue != null) {
      if (newValue is List<T>) {
        return changeFieldValue(newValue);
      } else if (newValue is Iterable<T>) {
        return changeFieldValue(newValue.toList());
      } else if (newValue is T) {
        return changeFieldValue([newValue]);
      } else {
        return NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FlexibleOration(message: 'The value "%1" is not a valid list', textParts: [newValue]),
        );
      }
    }
    return voidResult;
  }

  @override
  Result<void> extraCheckValue(value) {
    if (value is! List<T>) {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The value "%1" is not a valid list', textParts: [value]),
      );
    }

    return voidResult;
  }

  @override
  Result<bool> isControllerAcceptType(Type type) {
    return [List<T>, T, Iterable<T>].contains(type).asResultValue();
  }

  @override
  void performObjectDiscard() {}
}
