import 'package:maxi_flutter_widgets/src/fields/fieald_template_controller.dart';
import 'package:maxi_framework/maxi_framework.dart';

typedef FieldIntegerController = FieldNumberController<int>;
typedef FieldDoubleController = FieldNumberController<double>;

class FieldNumberController<T extends num> extends FiealdTemplateController<T> {
  final double maxValue;
  final double minValue;

  bool get isInteger => T == int;

  FieldNumberController({this.maxValue = double.maxFinite, this.minValue = 0, required super.listeningFieldNames, required super.initialValue, super.aceptInvalidValues = true, super.validators = const []});

  FieldNumberController.oneName({required String name, required super.initialValue, super.aceptInvalidValues = true, super.validators = const [], this.maxValue = double.maxFinite, this.minValue = 0})
    : super(listeningFieldNames: [name]);

  T parseValue(num value) {
    if (isInteger) {
      return value.toInt() as T;
    } else {
      return value.toDouble() as T;
    }
  }

  @override
  Result<void> changeGenericFieldValue({required String name, required newValue}) {
    if (isListeningToFieldName(name) && newValue != null) {
      if (newValue is num) {
        return changeFieldValue(parseValue(newValue));
      } else if (newValue is String) {
        final parsedValue = double.tryParse(newValue);
        if (parsedValue != null) {
          return changeFieldValue(parseValue(parsedValue));
        } else {
          return NegativeResult.controller(
            code: ErrorCode.invalidValue,
            message: FlexibleOration(message: 'The value "%1" is not a valid number', textParts: [newValue]),
          );
        }
      }
    }
    return voidResult;
  }

  @override
  Result<void> extraCheckValue(value) {
    late final double numValue;
    if (value is num) {
      numValue = value.toDouble();
    } else if (value is String) {
      final parsedValue = double.tryParse(value);
      if (parsedValue != null) {
        numValue = parsedValue;
      } else {
        return NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FlexibleOration(message: 'The value "%1" is not a valid number', textParts: [value]),
        );
      }
    } else {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The value "%1" is not a valid number', textParts: [value]),
      );
    }

    if (numValue < minValue) {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The value must be at least %1, but %2 was entered', textParts: [minValue, numValue]),
      );
    }

    if (numValue > maxValue) {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The value must be at most %1, but %2 was entered', textParts: [maxValue, numValue]),
      );
    }

    return voidResult;
  }

  @override
  Result<bool> isControllerAcceptType(Type type) {
    return const [int, double, num].contains(type).asResultValue();
  }

  @override
  void performObjectDiscard() {}
}
