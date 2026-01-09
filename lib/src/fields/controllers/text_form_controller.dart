import 'dart:async';

import 'package:maxi_flutter_widgets/src/architecture/field_controller.dart';
import 'package:maxi_framework/maxi_framework.dart';

class TextFormController implements Disposable, FieldController {
  @override
  final List<String> fieldNames;

  final int? maxCharacter;
  final int? maxLines;
  final LifeCoordinator heart;
  final List<Validator> validators;

  MasterChannel<dynamic, Result>? _masterChannel;

  ErrorData _lastError = const ControlledFailure(
    errorCode: ErrorCode.implementationFailure,
    message: FixedOration(message: 'No error has occurred yet'),
  );
  bool _isValid = true;
  String _currentText = '';

  late final StreamController<bool> _validityChangeController;

  @override
  Stream<bool> get validityChange => _validityChangeController.stream;

  @override
  bool get isValid => _isValid;

  @override
  bool get itWasDiscarded => heart.itWasDiscarded;

  @override
  Future<dynamic> get onDispose => heart.onDispose;

  ErrorData get lastError => _lastError;

  TextFormController({required String currentText, required this.fieldNames, required this.maxCharacter, required this.maxLines, required this.heart, required this.validators}) {
    _validityChangeController = StreamController<bool>.broadcast();
    _currentText = currentText;
    final firstValidation = checkValue(_currentText);
    if (firstValidation.itsFailure) {
      defineAsInvalid(firstValidation.error);
    } else {
      defineAsValid();
    }
  }

  @override
  Result<void> checkValue(value) {
    if (value is! String) {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FixedOration(message: 'Only textual values are accepted'),
      );
    }

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

    for (final val in validators) {
      final result = val.validateValue(value: value);
      if (result.itsFailure) {
        return result;
      }
    }
    return voidResult;
  }

  void _onChannelReceive(Stream<dynamic> stream) {
    heart.joinStream(
      stream: stream,
      onData: (data) {
        changeFieldValue(data);
      },
    );
  }

  @override
  Result<Channel<Result, dynamic>> buildFieldChannel() {
    if (heart.itWasDiscarded) {
      return NegativeResult.controller(
        code: ErrorCode.discontinuedFunctionality,
        message: FixedOration(message: 'Cannot build channel from a disposed controller'),
      );
    }
    if (_masterChannel == null) {
      _masterChannel = MasterChannel<dynamic, Result>();
      heart.joinDisposableObject(_masterChannel!);
      _masterChannel!.getReceiver().onCorrectLambda(_onChannelReceive).logIfFails(errorName: '[TextFormController -> buildFieldChannel] Could not get channel receiver');
    }

    return _masterChannel!.buildConnector();
  }

  @override
  Result changeFieldValue(value) {
    if (value is! String) {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FixedOration(message: 'Only textual values are accepted'),
      );
    }

    if (value == _currentText) {
      return isValid ? voidResult : NegativeResult.controller(code: ErrorCode.invalidValue, message: _lastError.message);
    }

    final validation = checkValue(value);
    _currentText = value;
    if (validation.itsFailure) {
      defineAsInvalid(validation.error);
      _masterChannel?.sendItem(validation);
    } else {
      defineAsValid();
      _masterChannel?.sendItem(ResultValue(content: _currentText));
    }

    return validation;
  }

  @override
  void defineAsInvalid(ErrorData reason) {
    if (_isValid) {
      _isValid = false;
      _lastError = reason;
      _validityChangeController.add(_isValid);
    }
  }

  @override
  void defineAsValid() {
    if (!_isValid) {
      _isValid = true;
      _validityChangeController.add(_isValid);
    }
  }

  @override
  void dispose() => heart.dispose();

  @override
  bool itsCanAcceptType(Type type) => type == String;

  @override
  String obtainFieldValue() => _currentText;
}
