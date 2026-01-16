import 'package:decimal/decimal.dart';
import 'package:maxi_flutter_widgets/src/fields/controllers/standar_field_controll.dart';
import 'package:maxi_framework/maxi_framework.dart';

class NumberFormController extends StandarFieldControll<num> {
  final bool isDecimal;
  final num? minimum;
  final num? maximum;
  final int decimalDigit;

  NumberFormController({
    required this.isDecimal,
    required this.minimum,
    required this.maximum,
    required super.currentValue,
    required super.heart,
    required super.fieldNames,
    required super.validators,
    required this.decimalDigit,
  });

  @override
  Result<num> adaptedValue(num value) {
    if (!isDecimal) {
      return ResultValue(content: value.toInt());
    }

    num newValue = 0;
    final deciValue = Decimal.parse(value.toString());
    if (deciValue.scale > decimalDigit) {
      newValue = double.parse(deciValue.toDouble().toStringAsFixed(decimalDigit));
    } else {
      newValue = value.toDouble();
    }

    if (maximum != null && newValue > maximum!) {
      newValue = maximum!;
    } else if (minimum != null && newValue < minimum!) {
      newValue = minimum!;
    }

    return ResultValue(content: newValue);
  }

  @override
  Result<num> whenUnkownTypeValue(value) {
    if (value is String) {
      final parsedValue = num.tryParse(value.replaceAll(',', '.').replaceAll('+', '').replaceAll('-', '').replaceAll('e', ''));
      if (parsedValue != null) {
        return ResultValue(content: isDecimal ? parsedValue.toDouble() : parsedValue.toInt());
      }
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The text value %1 is not a valid number', textParts: [value]),
      );
    } else {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The value %1 is not a valid number', textParts: [value]),
      );
    }
  }

  @override
  Result<void> previousChecks(num value) {
    if (minimum != null && value < minimum!) {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The number %1 is less than the minimum allowed of %2', textParts: [value, minimum!]),
      );
    }

    if (maximum != null && value > maximum!) {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The number %1 is greater than the maximum allowed of %2', textParts: [value, maximum!]),
      );
    }

    return voidResult;
  }
}
