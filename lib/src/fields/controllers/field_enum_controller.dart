import 'package:maxi_flutter_widgets/src/fields/fieald_template_controller.dart';
import 'package:maxi_framework/maxi_framework.dart';

class FieldEnumController<T extends Enum> extends FiealdTemplateController<T> {
  final List<Enum> options;

  FieldEnumController({required this.options, required super.listeningFieldNames, T? initialValue, super.validators = const [], super.aceptInvalidValues = true}) : super(initialValue: initialValue ?? options.first as T);

  FieldEnumController.oneName({required super.name, required this.options, T? initialValue, super.validators = const [], super.aceptInvalidValues = true})
    : super.oneName(initialValue: initialValue ?? options.first as T);

  @override
  Result<void> changeGenericFieldValue({required String name, required newValue}) {
    if (isListeningToFieldName(name) && newValue != null) {
      if (newValue is T) {
        return changeFieldValue(newValue);
      } else if (newValue is Enum) {
        final matchingOption = options.selectItem((x) => x.index == newValue.index);
        if (matchingOption != null) {
          return changeFieldValue(matchingOption as T);
        } else {
          return NegativeResult.controller(
            code: ErrorCode.invalidValue,
            message: FlexibleOration(message: 'The value "%1" is not a valid option', textParts: [newValue]),
          );
        }
      } else if (newValue is num) {
        final intValue = newValue.toInt();
        final matchingOption = options.selectItem((x) => x.index == intValue);
        if (matchingOption != null) {
          return changeFieldValue(matchingOption as T);
        } else {
          return NegativeResult.controller(
            code: ErrorCode.invalidValue,
            message: FlexibleOration(message: 'The number "%1" is not a valid option', textParts: [newValue]),
          );
        }
      } else if (newValue is String) {
        newValue = newValue.trim().toLowerCase().replaceAll('_', '').replaceAll('-', '');
        final matchingOption = options.selectItem((x) => x.name.toLowerCase() == newValue.toLowerCase());
        if (matchingOption != null) {
          return changeFieldValue(matchingOption as T);
        } else {
          return NegativeResult.controller(
            code: ErrorCode.invalidValue,
            message: FlexibleOration(message: 'The text "%1" is not a valid option', textParts: [newValue]),
          );
        }
      } else {
        return NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: const FixedOration(message: 'The value  is not a valid option type'),
        );
      }
    }
    return voidResult;
  }

  @override
  Result<void> extraCheckValue(value) {
    return voidResult;
  }

  @override
  Result<bool> isControllerAcceptType(Type type) {
    return [T, Enum, String, int, double, num].contains(type).asResultValue();
  }

  @override
  void performObjectDiscard() {}
}
