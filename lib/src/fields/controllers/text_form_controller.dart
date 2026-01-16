import 'package:maxi_flutter_widgets/src/fields/controllers/standar_field_controll.dart';
import 'package:maxi_framework/maxi_framework.dart';

class TextFormController extends StandarFieldControll<String> {
  final int? maxCharacter;
  final int? maxLines;

  TextFormController({required this.maxCharacter, required this.maxLines, required super.currentValue, required super.heart, required super.fieldNames, required super.validators});

  @override
  Result<void> previousChecks(String value) {
    if (maxCharacter != null && value.length > maxCharacter!) {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: FlexibleOration(message: 'The text exceeds the maximum allowed characters of %1', textParts: [maxCharacter]),
      );
    }

    if (maxLines != null) {
      final lineCount = '\n'.allMatches(value).length + 1;
      if (lineCount > maxLines!) {
        return NegativeResult.controller(
          code: ErrorCode.invalidValue,
          message: FlexibleOration(message: 'The text exceeds the maximum allowed lines of %1', textParts: [maxLines]),
        );
      }
    }

    return voidResult;
  }
}
