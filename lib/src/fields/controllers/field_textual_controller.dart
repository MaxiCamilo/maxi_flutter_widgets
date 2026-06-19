import 'package:maxi_flutter_widgets/src/fields/fieald_template_controller.dart';
import 'package:maxi_framework/maxi_framework.dart';

class FieldTextualController extends FiealdTemplateController<String> {
  final int maxLength;
  final int minLength;
  final int maxLines;
  final int minLines;

  FieldTextualController({
    required super.listeningFieldNames,
    super.initialValue = '',
    this.maxLength = 99999999,
    this.minLength = 0,
    this.maxLines = 99999999,
    this.minLines = 1,
    super.aceptInvalidValues = true,
    super.validators = const [],
  });

  FieldTextualController.oneName({
    required String name,
    super.initialValue = '',
    this.maxLength = 99999999,
    this.minLength = 0,
    this.maxLines = 99999999,
    this.minLines = 1,
    super.aceptInvalidValues = true,
    super.validators = const [],
  }) : super(listeningFieldNames: [name]);

  @override
  Result<void> extraCheckValue(value) {
    final stringValue = value.toString();

    if (maxLength > 0 && stringValue.length > maxLength) {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: '', textParts: [stringValue.length]),
      );
    }

    if ([maxLength, maxLines, minLength, minLines].any((limit) => limit > 0)) {
      final lines = '\n'.allMatches(stringValue).length;

      if (minLength > 0 && stringValue.length < minLength) {
        return NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FlexibleOration(message: 'At least %1 characters are required, but only %2 characters were entered', textParts: [minLength, stringValue.length]),
        );
      }

      if (maxLength > 0 && stringValue.length > maxLength) {
        return NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FlexibleOration(message: 'At most %1 characters are allowed, but %2 characters were entered', textParts: [maxLength, stringValue.length]),
        );
      }

      if (minLines > 0 && lines < minLines) {
        return NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FlexibleOration(message: 'At least %1 lines are required, but %2 were found', textParts: [minLines, lines]),
        );
      }

      if (maxLines > 0 && lines > maxLines) {
        return NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FlexibleOration(message: 'At most %1 lines are allowed, but %2 were found', textParts: [maxLines, lines]),
        );
      }
    }
    return voidResult;
  }

  @override
  Result<void> changeGenericFieldValue({required String name, required newValue}) {
    if (isListeningToFieldName(name) && newValue != null) {
      return changeFieldValue(newValue.toString());
    }

    return voidResult;
  }

  @override
  Result<bool> isControllerAcceptType(Type type) {
    return const ResultValue(content: true);
  }

  @override
  void performObjectDiscard() {}
}
