import 'package:maxi_flutter_widgets/src/fields/fieald_template_controller.dart';
import 'package:maxi_framework/maxi_framework.dart';

class FieldDatetimeController extends FiealdTemplateController<DateTime> {
  final DateTime? minDate;
  final DateTime? maxDate;

  FieldDatetimeController({this.minDate, this.maxDate, required super.listeningFieldNames, DateTime? initialDate, super.validators = const [], super.aceptInvalidValues = true})
    : super(initialValue: initialDate ?? DateTime.now());

  FieldDatetimeController.oneName({required super.name, this.minDate, this.maxDate, DateTime? initialDate, super.validators = const [], super.aceptInvalidValues = true})
    : super.oneName(initialValue: initialDate ?? DateTime.now());

  @override
  Result<void> changeGenericFieldValue({required String name, required newValue}) {
    if (isListeningToFieldName(name) && newValue != null) {
      if (newValue is DateTime) {
        return changeFieldValue(newValue);
      } else if (newValue is String) {
        final parsedDate = DateTime.tryParse(newValue);
        if (parsedDate != null) {
          return changeFieldValue(parsedDate);
        } else {
          return NegativeResult.controller(
            code: ErrorCode.invalidValue,
            message: FlexibleOration(message: 'The value "%1" is not a valid DateTime', textParts: [newValue]),
          );
        }
      } else if (newValue is num) {
        final dateFromEpoch = DateTime.fromMillisecondsSinceEpoch(newValue.toInt(), isUtc: true).toLocal();
        return changeFieldValue(dateFromEpoch);
      } else {
        return NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FlexibleOration(message: 'The value "%1" is not a valid DateTime', textParts: [newValue]),
        );
      }
    }

    return voidResult;
  }

  @override
  Result<void> extraCheckValue(value) {
    if (value is! DateTime) {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The value "%1" is not a valid DateTime', textParts: [value]),
      );
    }

    if (minDate != null && value.isBefore(minDate!)) {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The date must be on or after %1, but %2 was entered', textParts: [minDate!, value]),
      );
    }

    if (maxDate != null && value.isAfter(maxDate!)) {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The date must be on or before %1, but %2 was entered', textParts: [maxDate!, value]),
      );
    }

    return voidResult;
  }

  @override
  Result<bool> isControllerAcceptType(Type type) {
    return const [DateTime, String, int, double, num].contains(type).asResultValue();
  }

  @override
  void performObjectDiscard() {}
}
