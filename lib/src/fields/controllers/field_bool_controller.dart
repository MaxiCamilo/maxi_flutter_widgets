import 'package:maxi_flutter_widgets/src/fields/fieald_template_controller.dart';
import 'package:maxi_framework/maxi_framework.dart';

class FieldBoolController extends FiealdTemplateController<bool> {
  FieldBoolController({required super.listeningFieldNames, super.initialValue = false, super.aceptInvalidValues = true, super.validators = const []});

  FieldBoolController.oneName({required super.name, required super.initialValue, required super.validators, required super.aceptInvalidValues}) : super.oneName();

  @override
  Result<void> changeGenericFieldValue({required String name, required newValue}) {
    if (isListeningToFieldName(name) && newValue != null) {
      if (newValue is bool) {
        return changeFieldValue(newValue);
      } else if (newValue is String) {
        final lowerValue = newValue.toLowerCase();
        if (lowerValue == 'true' || lowerValue == 'yes' || lowerValue == '1') {
          return changeFieldValue(true);
        } else if (lowerValue == 'false' || lowerValue == 'no' || lowerValue == '0') {
          return changeFieldValue(false);
        } else {
          return NegativeResult.controller(
            code: ErrorCode.invalidValue,
            message: FlexibleOration(message: 'The value "%1" is not a valid boolean', textParts: [newValue]),
          );
        }
      } else if (newValue is num) {
        if (newValue == 1) {
          return changeFieldValue(true);
        } else if (newValue == 0) {
          return changeFieldValue(false);
        } else {
          return NegativeResult.controller(
            code: ErrorCode.invalidValue,
            message: FlexibleOration(message: 'The value "%1" is not a valid boolean', textParts: [newValue]),
          );
        }
      } else {
        return NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FlexibleOration(message: 'The value "%1" is not a valid boolean', textParts: [newValue]),
        );
      }
    }

    return voidResult;
  }

  @override
  Result<void> extraCheckValue(value) {
    if (value is! bool) {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The value "%1" is not a valid boolean', textParts: [value]),
      );
    }

    return voidResult;
  }

  @override
  Result<bool> isControllerAcceptType(Type type) {
    return (type == bool).asResultValue();
  }

  @override
  void performObjectDiscard() {}
}
